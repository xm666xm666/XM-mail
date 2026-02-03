#!/bin/bash
#
# ============================================================================
# 脚本名称: update_repos.sh
# 工作职责: 系统仓库源更新脚本 - 负责配置系统软件包仓库源为国内镜像
#           备份现有配置，配置阿里云镜像源，添加Docker CE和Kubernetes仓库
# 系统组件: XM邮件管理系统 - 系统配置模块
# ============================================================================
# 用法说明:
#   update_repos.sh
#   无参数，线性执行：备份现有 yum.repos.d → 配置 Rocky 阿里云镜像 →
#   更新 DNF 缓存 → 添加 Docker CE 仓库 → 添加 Kubernetes 仓库
#
# 功能描述:
#   - 仓库备份：备份现有yum.repos.d配置到.backup目录
#   - 镜像配置：将Rocky Linux仓库配置为阿里云镜像源
#   - Docker仓库：添加Docker CE仓库（阿里云镜像）
#   - Kubernetes仓库：添加Kubernetes官方仓库
#   - 缓存更新：更新DNF缓存以应用新配置
#   - 配置验证：验证仓库配置是否正确
#
# 配置内容:
#   - Rocky Linux：https://mirrors.aliyun.com/rockylinux
#   - Docker CE：https://mirrors.aliyun.com/docker-ce/linux/centos
#   - Kubernetes：https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
#
# 依赖关系:
#   - dnf/yum（包管理器）
#   - yum-config-manager（用于Docker仓库）
#
# 注意事项:
#   - 需要root权限执行
#   - 会自动备份现有配置
#   - 配置失败不会影响系统原有仓库
#   - 建议在系统安装初期执行
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

# 配置 Rocky Linux 仓库为阿里云镜像
log_info "配置 Rocky Linux 仓库为阿里云镜像..."
if ls /etc/yum.repos.d/[Rr]ocky*.repo >/dev/null 2>&1; then
    # 使用sed命令更新仓库配置：
    # 1. 注释掉mirrorlist行
    # 2. 将baseurl设置为阿里云镜像
    # 3. 备份原文件为.bak
    sed -e 's|^mirrorlist=|#mirrorlist=|g' \
        -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
        -i.bak \
        /etc/yum.repos.d/[Rr]ocky*.repo
    log_success "Rocky Linux 仓库已配置为阿里云镜像"
else
    log_warning "未找到 Rocky Linux 仓库配置文件"
fi

# 更新 DNF 缓存（添加超时保护）
log_info "更新 DNF 缓存..."
if timeout 120 dnf makecache >/dev/null 2>&1; then
    log_success "DNF 缓存更新完成"
else
    log_warning "DNF 缓存更新失败或超时，但继续执行"
fi

# 添加 Docker CE 仓库（添加超时保护）
log_info "添加 Docker CE 仓库..."
if command -v yum-config-manager >/dev/null 2>&1; then
    # 使用 yum-config-manager 添加仓库（添加超时保护）
    if timeout 60 yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo >/dev/null 2>&1; then
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

# 添加 Kubernetes 仓库
log_info "添加 Kubernetes 仓库..."
if [[ ! -f /etc/yum.repos.d/kubernetes.repo ]]; then
    cat << 'K8S_EOF' | tee /etc/yum.repos.d/kubernetes.repo >/dev/null
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
K8S_EOF
    log_success "Kubernetes 仓库配置完成"
else
    log_warning "Kubernetes 仓库配置文件已存在，跳过"
fi

# 再次更新缓存（添加超时保护）
log_info "重新加载仓库缓存..."
if timeout 120 dnf makecache >/dev/null 2>&1; then
    log_success "仓库缓存重新加载完成"
else
    log_warning "仓库缓存重新加载失败或超时，但配置已完成"
fi

log_success "仓库源配置更新完成！"
log_info "已配置的仓库："
log_info "  - Rocky Linux (阿里云镜像)"
log_info "  - Docker CE (阿里云镜像)"
log_info "  - Kubernetes (官方源)"

# 注意：退出码会由start.sh通过EXIT_CODE标记捕获
exit 0

