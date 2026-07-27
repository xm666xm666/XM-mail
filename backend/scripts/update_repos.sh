#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: update_repos.sh
# 工作职责: Rocky Linux 系统仓库源配置 - 备份、阿里云镜像、Docker/K8s 仓库
# 系统组件: XM邮件管理系统 - 系统配置模块
# ============================================================================
#
# 用法:
#   update_repos.sh
#   无参数，顺序执行：备份 → DNF 优化 → Rocky/EPEL 镜像 → Docker → K8s → makecache
#
# 功能:
#   - 备份 /etc/yum.repos.d 至 .backup（首次执行）
#   - DNF 优化：max_parallel_downloads=10、fastestmirror=True
#   - Rocky 镜像：rocky*.repo、Rocky-*.repo → mirrors.aliyun.com/rockylinux
#   - EPEL 镜像：epel*.repo → mirrors.aliyun.com/epel
#   - Docker CE：添加阿里云镜像仓库（兼容 Rocky 8/9）
#   - Kubernetes：添加官方仓库 pkgs.k8s.io v1.35
#   - 更新 DNF 元数据缓存
#
# 镜像地址:
#   Rocky Linux  https://mirrors.aliyun.com/rockylinux
#   EPEL         https://mirrors.aliyun.com/epel
#   Docker CE    https://mirrors.aliyun.com/docker-ce/linux/centos
#   Kubernetes   https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
#
# 依赖: dnf/yum、yum-config-manager（Docker 仓库）
#
# 注意: 需 root 权限；无命令行参数；不使用 set -e；不定义 BASE_DIR
# ============================================================================

# 不使用 set -e，允许某些命令失败后继续执行
# set -e

# 日志函数（输出纯文本，由start.sh处理日志级别和颜色）
# 使用简单标记来标识日志级别，start.sh会解析这些标记
log_info() {
    echo "INFO: $*"
}

log_success() {
    echo "SUCCESS: $*"
}

log_warning() {
    echo "WARNING: $*"
}

log_error() {
    echo "ERROR: $*"
}

# 检查是否为 root 用户
if [[ $EUID -ne 0 ]]; then
    log_error "此脚本需要 root 权限运行"
    exit 1
fi

log_info "开始更新仓库源配置..."

# 备份现有仓库配置
if [[ -d /etc/yum.repos.d ]]; then
    if [[ ! -d /etc/yum.repos.d.backup ]]; then
        log_info "备份现有仓库配置到 /etc/yum.repos.d.backup"
        cp -r /etc/yum.repos.d /etc/yum.repos.d.backup
        log_success "仓库配置备份完成"
    else
        log_warning "备份目录已存在，跳过备份步骤"
    fi
else
    log_error "/etc/yum.repos.d 目录不存在"
    exit 1
fi

# 优化 DNF 性能（加速后续 makecache 与包安装）
if [[ -f /etc/dnf/dnf.conf ]]; then
    dnf_optimized=0
    for opt in 'max_parallel_downloads=10' 'fastestmirror=True'; do
        key="${opt%%=*}"
        if ! grep -q "^${key}=" /etc/dnf/dnf.conf 2>/dev/null; then
            sed -i "/^\[main\]/a ${opt}" /etc/dnf/dnf.conf 2>/dev/null && dnf_optimized=1
        fi
    done
    [[ $dnf_optimized -eq 1 ]] && log_success "DNF 性能优化已应用（并行下载、最快镜像）"
fi

# 配置 Rocky Linux 仓库为阿里云镜像
# Rocky 8: Rocky-BaseOS.repo, Rocky-AppStream.repo 等
# Rocky 9: rocky.repo, rocky-addons.repo, rocky-devel.repo, rocky-extras.repo
log_info "配置 Rocky Linux 仓库为阿里云镜像..."
rocky_repos=()
while IFS= read -r -d '' f; do
    rocky_repos+=("$f")
done < <(find /etc/yum.repos.d -maxdepth 1 -type f \( -name 'Rocky-*.repo' -o -name 'rocky*.repo' \) -print0 2>/dev/null)

if [[ ${#rocky_repos[@]} -gt 0 ]]; then
    aliyun_mirror='https://mirrors.aliyun.com/rockylinux'
    for repo_file in "${rocky_repos[@]}"; do
        # 1. 禁用 mirrorlist
        # 2. 精准替换 baseurl 域名，保留路径（$releasever/BaseOS/$basearch/os/ 等）
        sed -i.bak \
            -e 's|^mirrorlist=|#mirrorlist=|g' \
            -e "s|^#*baseurl=http://dl.rockylinux.org/\$contentdir/|baseurl=${aliyun_mirror}/|g" \
            -e "s|^#*baseurl=https://dl.rockylinux.org/\$contentdir/|baseurl=${aliyun_mirror}/|g" \
            -e "s|^#*baseurl=http://download.rockylinux.org/\$contentdir/|baseurl=${aliyun_mirror}/|g" \
            -e "s|^#*baseurl=https://download.rockylinux.org/\$contentdir/|baseurl=${aliyun_mirror}/|g" \
            "$repo_file" 2>/dev/null || true
    done
    # 清理 sed 生成的 .bak 文件（已有 /etc/yum.repos.d.backup 完整备份）
    for repo_file in "${rocky_repos[@]}"; do
        [[ -f "${repo_file}.bak" ]] && rm -f "${repo_file}.bak"
    done
    log_success "Rocky Linux 仓库已配置为阿里云镜像（共 ${#rocky_repos[@]} 个文件）"
else
    log_warning "未找到 Rocky Linux 仓库配置文件"
fi

# 配置 EPEL 仓库为阿里云镜像（epel.repo、epel-testing.repo、epel-cisco-openh264.repo）
log_info "配置 EPEL 仓库为阿里云镜像..."
epel_repos=()
while IFS= read -r -d '' f; do
    epel_repos+=("$f")
done < <(find /etc/yum.repos.d -maxdepth 1 -type f -name 'epel*.repo' -print0 2>/dev/null)

if [[ ${#epel_repos[@]} -gt 0 ]]; then
    for repo_file in "${epel_repos[@]}"; do
        # 1. 禁用 metalink  2. 将 baseurl 替换为阿里云（参考阿里云镜像站官方说明）
        sed -i \
            -e 's|^metalink=|#metalink=|g' \
            -e 's|^#baseurl=https://download.example/pub|baseurl=https://mirrors.aliyun.com|g' \
            "$repo_file" 2>/dev/null || true
    done
    log_success "EPEL 仓库已配置为阿里云镜像（共 ${#epel_repos[@]} 个文件）"
else
    log_warning "未找到 EPEL 仓库配置文件"
fi

# 添加 Docker CE 仓库（添加超时保护）
log_info "添加 Docker CE 仓库..."
if command -v yum-config-manager >/dev/null 2>&1; then
    # 使用 yum-config-manager 添加仓库（timeout 不存在时直接执行）
    if command -v timeout >/dev/null 2>&1; then
        _run() { timeout 60 "$@"; }
    else
        _run() { "$@"; }
    fi
    if _run yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo >/dev/null 2>&1; then
        log_success "Docker CE 仓库添加完成"
    else
        # 如果添加失败，检查是否已存在
        if [[ -f /etc/yum.repos.d/docker-ce.repo ]]; then
            log_warning "Docker CE 仓库已存在，跳过添加"
        else
            log_warning "Docker CE 仓库添加失败或超时，尝试手动创建"
            # 手动创建 Docker CE 仓库配置
            cat > /etc/yum.repos.d/docker-ce.repo << 'DOCKER_EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
DOCKER_EOF
            log_success "Docker CE 仓库配置文件已手动创建"
        fi
    fi
else
    log_warning "yum-config-manager 命令不可用，使用手动方式创建 Docker CE 仓库配置"
    # 手动创建 Docker CE 仓库配置
    if [[ ! -f /etc/yum.repos.d/docker-ce.repo ]]; then
        log_info "手动创建 Docker CE 仓库配置..."
        cat > /etc/yum.repos.d/docker-ce.repo << 'DOCKER_EOF'
[docker-ce-stable]
name=Docker CE Stable - $basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/$releasever/$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
DOCKER_EOF
        log_success "Docker CE 仓库配置文件已创建"
    else
        log_info "Docker CE 仓库配置文件已存在，跳过创建"
    fi
fi

# 确保 Docker CE 仓库使用阿里云镜像（若已存在但指向官方源则替换）
for f in /etc/yum.repos.d/*.repo; do
    [[ -f "$f" ]] || continue
    if grep -q 'download.docker.com' "$f" 2>/dev/null; then
        sed -i 's|https://download.docker.com|https://mirrors.aliyun.com/docker-ce|g' "$f"
        log_success "Docker CE 仓库已切换为阿里云镜像 ($(basename "$f"))"
    fi
done

# 添加 Kubernetes 仓库（官方源 pkgs.k8s.io）
log_info "添加 Kubernetes 仓库..."
if [[ ! -f /etc/yum.repos.d/kubernetes.repo ]]; then
    cat << 'K8S_EOF' | tee /etc/yum.repos.d/kubernetes.repo >/dev/null
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.35/rpm/repodata/repomd.xml.key
K8S_EOF
    log_success "Kubernetes 仓库配置完成"
else
    log_warning "Kubernetes 仓库配置文件已存在，跳过"
fi

# 更新 DNF 缓存（超时 5 分钟，NodeSource/K8s 等国外源较慢时需更长时间）
log_info "更新 DNF 仓库缓存..."
if command -v timeout >/dev/null 2>&1; then
    _dnf_cmd="timeout 300 dnf makecache"
else
    _dnf_cmd="dnf makecache"
fi
if eval "$_dnf_cmd" >/dev/null 2>&1; then
    log_success "仓库缓存重新加载完成"
else
    log_warning "仓库缓存重新加载失败或超时，但配置已完成"
fi

log_success "仓库源配置更新完成！"
log_info "已配置的仓库："
log_info "  - Rocky Linux (阿里云镜像)"
log_info "  - EPEL (阿里云镜像)"
log_info "  - Docker CE (阿里云镜像)"
log_info "  - Kubernetes (官方源)"

# 注意：退出码会由start.sh通过EXIT_CODE标记捕获
exit 0
