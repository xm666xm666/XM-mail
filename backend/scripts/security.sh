#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: security.sh
# 工作职责: 系统安全配置脚本 - 负责邮件系统的安全加固和防护配置
#           包括防火墙配置、SSL/TLS设置、访问控制和安全策略管理
# 系统组件: XM邮件管理系统 - 安全模块
# ============================================================================
# 用法说明:
#   security.sh <action> [参数...]
#   security.sh harden               - 执行安全加固（防火墙、TLS、垃圾邮件过滤等）
#   security.sh install-cert [域名]   - 安装/申请 SSL 证书（示例使用 certbot，可传域名）
#   security.sh restart              - 重启安全相关服务（如 firewalld 并重新应用端口规则）
#   security.sh stop                 - 停止安全相关服务
#
# 功能描述:
#   - 防火墙配置：配置iptables/firewalld规则
#   - SSL/TLS配置：配置邮件传输加密
#   - 访问控制：IP白名单/黑名单管理
#   - 安全审计：日志审计和安全检查
#   - 垃圾邮件过滤：集成垃圾邮件过滤系统
#   - 安全策略：实施安全最佳实践
#
# 安全配置项:
#   - 邮件端口：25, 587, 993, 995（固定端口）
#   - Web端口：从config/port-config.json读取（默认80, 443）
#   - DNS端口：53（固定端口）
#   - 防火墙规则：允许/拒绝特定IP
#   - 标准端口（80, 443）使用服务名称，非标准端口使用端口号
#
# 端口配置:
#   - Apache HTTP/HTTPS端口从config/port-config.json读取
#   - 防火墙规则支持自定义端口配置
#   - 标准端口使用服务名称（http/https），非标准端口使用端口号
#
# 依赖关系:
#   - iptables/firewalld（防火墙）
#   - OpenSSL（证书管理）
#   - spam_filter.sh（垃圾邮件过滤）
#
# 注意事项:
#   - 需要root权限执行安全配置
#   - 错误的防火墙配置可能导致服务中断
#   - 建议在测试环境先验证配置
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

# 获取项目根目录（BASE_DIR）
BASE_DIR=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd || echo "/bash")
CONFIG_DIR="$BASE_DIR/config"

set -uo pipefail

# 读取端口配置函数
get_port_config() {
    local port_config_file="$CONFIG_DIR/port-config.json"
    local apache_http_port=80
    local apache_https_port=443
    
    if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
        apache_http_port=$(jq -r '.apache.httpPort // 80' "$port_config_file" 2>/dev/null || echo "80")
        apache_https_port=$(jq -r '.apache.httpsPort // 443' "$port_config_file" 2>/dev/null || echo "443")
    fi
    
    echo "$apache_http_port|$apache_https_port"
}

log() { echo "[security] $*" >&1; }

# 权限检查
require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "警告: 当前用户不是 root，某些操作可能失败" >&1
    echo "建议: 使用 sudo 运行此脚本或切换到 root 用户" >&1
  fi
}

ACTION=${1:-help}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: security.sh $ACTION" >&1
echo "当前时间: $(date)" >&1
echo "当前用户: $(whoami)" >&1
echo "当前目录: $(pwd)" >&1

# 检查权限
require_root

# 自定义垃圾邮件过滤功能
setup_spam_filter() {
  local func_start=$(date +%s)
  log "设置自定义垃圾邮件过滤规则..."
  
  # 复制独立的垃圾邮件过滤脚本到系统目录
  local step_start=$(date +%s)
  local script_dir="$(dirname "$0")"
  local spam_filter_script="$script_dir/spam_filter.sh"
  
  if [ -f "$spam_filter_script" ]; then
    log "找到垃圾邮件过滤脚本: $spam_filter_script"
    cp "$spam_filter_script" /usr/local/bin/spam_filter.sh
    chmod +x /usr/local/bin/spam_filter.sh
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    log "垃圾邮件过滤脚本已安装到: /usr/local/bin/spam_filter.sh（耗时: ${step_duration}秒）"
  else
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    log "警告: 垃圾邮件过滤脚本不存在: $spam_filter_script（耗时: ${step_duration}秒）"
    log "跳过垃圾邮件过滤功能安装"
    return 0  # 不返回错误，继续执行其他配置
  fi
  
  # 创建垃圾邮件日志目录
  step_start=$(date +%s)
  mkdir -p /var/log/spam_filter
  chown postfix:postfix /var/log/spam_filter 2>/dev/null || true
  chmod 755 /var/log/spam_filter
  step_end=$(date +%s)
  step_duration=$((step_end - step_start))
  log "创建日志目录完成（耗时: ${step_duration}秒）"
  
  # 初始化过滤系统
  step_start=$(date +%s)
  if [ -x "/usr/local/bin/spam_filter.sh" ]; then
    log "初始化垃圾邮件过滤系统..."
    /usr/local/bin/spam_filter.sh config || {
      step_end=$(date +%s)
      step_duration=$((step_end - step_start))
      log "警告: 垃圾邮件过滤系统初始化失败，耗时: ${step_duration}秒，但继续执行"
    }
    step_end=$(date +%s)
    step_duration=$((step_end - step_start))
    log "垃圾邮件过滤系统初始化完成（耗时: ${step_duration}秒）"
  else
    step_end=$(date +%s)
    step_duration=$((step_end - step_start))
    log "警告: 垃圾邮件过滤脚本不可执行，跳过初始化（耗时: ${step_duration}秒）"
  fi
  
  local func_end=$(date +%s)
  local func_duration=$((func_end - func_start))
  log "垃圾邮件过滤功能配置完成（总耗时: ${func_duration}秒）"
  log "过滤脚本位置: /usr/local/bin/spam_filter.sh"
  log "日志目录: /var/log/spam_filter"
}

# 检测并等待其他 dnf 进程完成
wait_for_dnf_processes() {
  local max_wait=300  # 最多等待5分钟
  local stuck_threshold=300  # 如果进程运行超过5分钟，认为可能卡住
  local check_interval=5  # 每5秒检查一次
  local waited=0
  
  while [ $waited -lt $max_wait ]; do
    # 检查是否有其他 dnf 进程在运行（排除当前脚本的进程）
    local other_dnf_pids=$(pgrep -f "dnf.*install|dnf.*update|dnf.*upgrade" | grep -v "^$$" || true)
    
    if [ -z "$other_dnf_pids" ]; then
      # 检查 dnf 锁文件
      if [ ! -f /var/run/dnf.pid ] && [ ! -f /var/cache/dnf/metadata_lock.pid ]; then
        log "检测完成: 没有其他 dnf 进程在运行，可以继续安装"
        return 0
      else
        # 检查锁文件中的 PID 是否还在运行
        local lock_pid=""
        if [ -f /var/run/dnf.pid ]; then
          lock_pid=$(cat /var/run/dnf.pid 2>/dev/null || echo "")
          if [ -n "$lock_pid" ] && ! kill -0 "$lock_pid" 2>/dev/null; then
            # PID 不存在，删除锁文件
            rm -f /var/run/dnf.pid 2>/dev/null || true
            log "检测: 发现无效的 dnf 锁文件，已清理"
            return 0
          fi
        fi
      fi
    fi
    
    if [ -n "$other_dnf_pids" ]; then
      log "检测: 发现其他 dnf 进程正在运行（PID: $other_dnf_pids），等待其完成..."
      log "诊断: 这可能是之前的安装操作仍在进行中"
      log "等待时间: ${waited}秒 / ${max_wait}秒"
      
      # 显示进程详细信息和运行时间
      local has_stuck_process=false
      for pid in $other_dnf_pids; do
        if kill -0 "$pid" 2>/dev/null; then
          # 获取进程运行时间（秒）- 使用更可靠的方法
          local proc_etime_str=$(ps -p "$pid" -o etime= --no-headers 2>/dev/null | tr -d ' ' || echo "")
          local proc_etime=0
          
          # 解析运行时间字符串 (格式: [[DD-]HH:]MM:SS 或 MM:SS)
          if [ -n "$proc_etime_str" ]; then
            if echo "$proc_etime_str" | grep -q "-"; then
              # 格式: DD-HH:MM:SS
              local days=$(echo "$proc_etime_str" | cut -d'-' -f1)
              local time_part=$(echo "$proc_etime_str" | cut -d'-' -f2)
              local hours=$(echo "$time_part" | cut -d':' -f1)
              local minutes=$(echo "$time_part" | cut -d':' -f2)
              local seconds=$(echo "$time_part" | cut -d':' -f3)
              proc_etime=$((days * 86400 + hours * 3600 + minutes * 60 + seconds))
            elif [ $(echo "$proc_etime_str" | tr -cd ':' | wc -c) -eq 2 ]; then
              # 格式: HH:MM:SS
              local hours=$(echo "$proc_etime_str" | cut -d':' -f1)
              local minutes=$(echo "$proc_etime_str" | cut -d':' -f2)
              local seconds=$(echo "$proc_etime_str" | cut -d':' -f3)
              proc_etime=$((hours * 3600 + minutes * 60 + seconds))
            else
              # 格式: MM:SS
              local minutes=$(echo "$proc_etime_str" | cut -d':' -f1)
              local seconds=$(echo "$proc_etime_str" | cut -d':' -f2)
              proc_etime=$((minutes * 60 + seconds))
            fi
          fi
          
          local proc_info=$(ps -p "$pid" -o pid,cmd,etime,stat --no-headers 2>/dev/null || echo "")
          
          if [ -n "$proc_info" ]; then
            log "进程信息 (PID $pid): $proc_info"
            
            # 检查进程运行时间
            if [ "$proc_etime" -gt "$stuck_threshold" ]; then
              has_stuck_process=true
              log "⚠️ 警告: 进程 $pid 已运行 ${proc_etime} 秒（超过 ${stuck_threshold} 秒），可能已卡住"
              log "诊断: 该进程可能是之前失败的安装操作留下的"
              
              # 检查进程状态（S=睡眠，R=运行，D=不可中断睡眠，Z=僵尸）
              local proc_stat=$(echo "$proc_info" | awk '{print $NF}' || echo "")
              if [ "$proc_stat" = "D" ]; then
                log "诊断: 进程处于不可中断睡眠状态（D），可能是等待磁盘IO或网络响应"
              elif [ "$proc_stat" = "S" ]; then
                log "诊断: 进程处于睡眠状态（S），可能在等待某些资源"
              fi
              
              # 检查进程是否真的在活动（通过检查 /proc/PID/stat）
              if [ -f "/proc/$pid/stat" ]; then
                local utime=$(awk '{print $14}' "/proc/$pid/stat" 2>/dev/null || echo "0")
                local stime=$(awk '{print $15}' "/proc/$pid/stat" 2>/dev/null || echo "0")
                local total_time=$((utime + stime))
                log "诊断: 进程累计CPU时间: ${total_time} 时钟周期"
                
                # 如果进程运行时间长但CPU时间很少，可能是卡住了
                if [ "$proc_etime" -gt 60 ] && [ "$total_time" -lt 1000 ]; then
                  log "⚠️ 严重警告: 进程运行 ${proc_etime} 秒但CPU时间很少，很可能已卡住"
                  log "建议: 可以考虑终止该进程: kill $pid"
                  log "建议: 或清理 dnf 锁文件后重试: rm -f /var/run/dnf.pid /var/cache/dnf/metadata_lock.pid"
                fi
              fi
            fi
          fi
        fi
      done
      
      # 如果检测到卡住的进程，提供更多建议
      if [ "$has_stuck_process" = "true" ] && [ $waited -gt 60 ]; then
        log "提示: 检测到可能卡住的进程，如果等待超过1分钟，建议手动处理"
        log "手动处理步骤:"
        log "  1. 检查进程: ps -fp $other_dnf_pids"
        log "  2. 如果确认卡住，终止进程: kill $other_dnf_pids"
        log "  3. 清理锁文件: rm -f /var/run/dnf.pid /var/cache/dnf/metadata_lock.pid"
        log "  4. 重新执行安装操作"
      fi
    fi
    
    sleep $check_interval
    waited=$((waited + check_interval))
  done
  
  log "警告: 等待超时（${max_wait}秒），仍有其他 dnf 进程在运行"
  log "提示: 可以手动检查进程: ps aux | grep dnf"
  log "提示: 如果确认无其他操作，可以强制清理: rm -f /var/run/dnf.pid /var/cache/dnf/metadata_lock.pid"
  log "提示: 如果进程卡住，可以终止: kill $other_dnf_pids"
  return 1
}

harden() {
  local start_time=$(date +%s)
  log "配置基本 TLS 与反垃圾/杀毒功能"
  log "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
  
  # 安装基础安全软件包（允许失败，添加超时机制）
  local step_start=$(date +%s)
  log "步骤1: 安装基础安全软件包..."
  log "步骤1开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
  
  # 检测并等待其他 dnf 进程完成
  log "步骤1.1: 检测其他 dnf 进程..."
  local detect_start=$(date +%s)
  if wait_for_dnf_processes; then
    local detect_end=$(date +%s)
    local detect_duration=$((detect_end - detect_start))
    if [ $detect_duration -gt 0 ]; then
      log "步骤1.1完成: 等待其他 dnf 进程完成（耗时: ${detect_duration}秒）"
    fi
  else
    local detect_end=$(date +%s)
    local detect_duration=$((detect_end - detect_start))
    log "步骤1.1警告: 等待其他 dnf 进程超时（耗时: ${detect_duration}秒），继续执行安装"
  fi
  
  # 设置2分钟超时，避免因网络问题导致无限等待（总超时为3分钟）
  # 使用 timeout 命令限制总执行时间，dnf 的 timeout 和 retries 选项限制单个操作
  log "步骤1.2: 开始执行 dnf 安装命令..."
  if timeout 120 dnf -y install certbot clamav clamav-update --skip-broken --setopt=timeout=60 --setopt=retries=1 >/tmp/security_install.log 2>&1; then
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    log "步骤1完成: 基础安全软件包安装成功（耗时: ${step_duration}秒）"
    # 清理临时日志文件
    rm -f /tmp/security_install.log 2>/dev/null || true
  else
    exit_code=$?
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    if [ $exit_code -eq 124 ]; then
      log "步骤1超时: 软件包安装超时（2分钟限制），耗时: ${step_duration}秒"
      log "提示: 安装日志已保存到 /tmp/security_install.log，可查看详细错误信息"
      log "诊断: 可能是网络速度慢或软件包仓库响应慢，建议检查网络连接"
    else
      log "步骤1失败: 部分软件包安装失败（退出码: $exit_code），耗时: ${step_duration}秒"
      log "提示: 安装日志已保存到 /tmp/security_install.log，可查看详细错误信息"
      
      # 检查日志中是否有进程等待信息
      if [ -f /tmp/security_install.log ]; then
        if grep -q "正在等待 pid" /tmp/security_install.log 2>/dev/null; then
          log "诊断: 检测到 dnf 等待其他进程的信息"
          local waiting_pid=$(grep -o "正在等待 pid 为[0-9]*" /tmp/security_install.log | grep -o "[0-9]*" | head -1)
          if [ -n "$waiting_pid" ]; then
            log "诊断: dnf 正在等待进程 PID $waiting_pid"
            if kill -0 "$waiting_pid" 2>/dev/null; then
              local proc_info=$(ps -p "$waiting_pid" -o pid,cmd,etime --no-headers 2>/dev/null || echo "")
              log "诊断: 进程 $waiting_pid 仍在运行: $proc_info"
              log "建议: 等待该进程完成，或检查是否有其他安装操作正在进行"
            else
              log "诊断: 进程 $waiting_pid 已不存在，可能是锁文件未清理"
              log "建议: 清理 dnf 锁文件: rm -f /var/run/dnf.pid /var/cache/dnf/metadata_lock.pid"
            fi
          fi
        fi
      fi
    fi
    log "提示: 可以稍后手动安装: dnf -y install certbot clamav clamav-update"
  fi
  
  # 配置 TLS（允许失败）
  local step_start=$(date +%s)
  log "步骤2: 配置 Postfix TLS 设置..."
  log "步骤2开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
  if command -v postconf >/dev/null 2>&1; then
    postconf -e 'smtpd_tls_security_level = may' 2>/dev/null || {
      local step_end=$(date +%s)
      local step_duration=$((step_end - step_start))
      log "步骤2失败: TLS 配置失败，耗时: ${step_duration}秒，继续执行"
    }
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    log "步骤2完成: Postfix TLS 配置完成（耗时: ${step_duration}秒）"
  else
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    log "步骤2跳过: Postfix未安装，跳过TLS配置（耗时: ${step_duration}秒）"
  fi
  
  # 配置自定义垃圾邮件过滤（允许失败）
  local step_start=$(date +%s)
  log "步骤3: 配置自定义垃圾邮件过滤..."
  log "步骤3开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
  setup_spam_filter || {
    local step_end=$(date +%s)
    local step_duration=$((step_end - step_start))
    log "步骤3失败: 垃圾邮件过滤配置失败，耗时: ${step_duration}秒，但继续执行其他配置"
  }
  local step_end=$(date +%s)
  local step_duration=$((step_end - step_start))
  log "步骤3完成: 垃圾邮件过滤配置完成（耗时: ${step_duration}秒）"
  
  local end_time=$(date +%s)
  local total_duration=$((end_time - start_time))
  log "安全加固基础配置完成"
  log "结束时间: $(date '+%Y-%m-%d %H:%M:%S')"
  log "总耗时: ${total_duration}秒（${total_duration}秒 = $((total_duration / 60))分$((total_duration % 60))秒）"
  
  # 性能诊断
  if [ $total_duration -gt 180 ]; then
    log "⚠️ 性能警告: 总耗时超过3分钟（${total_duration}秒），可能的原因："
    log "  1. 网络速度慢，软件包下载缓慢"
    log "  2. 软件包仓库响应慢"
    log "  3. 系统资源不足（CPU/内存/磁盘IO）"
    log "  4. 软件包依赖关系复杂，需要下载大量依赖"
    log "建议: 检查网络连接、系统资源使用情况和软件包仓库状态"
  fi
}

case "$ACTION" in
  harden)
    harden
    exit 0
    ;;
  install-cert)
    # 示例：证书申请占位，需要 DNS 与域名
    domain=${2:-example.com}
    certbot certonly --standalone -d "$domain" || true
    exit 0
    ;;
  restart)
    log "重启安全服务"
    # 重新启用并启动防火墙
    systemctl enable firewalld || true
    systemctl start firewalld || true
    systemctl restart firewalld || true
    
    # 配置防火墙规则
    if systemctl is-active --quiet firewalld; then
      log "配置防火墙规则"
      # 读取端口配置
      local port_config=$(get_port_config)
      local apache_http_port=$(echo "$port_config" | cut -d'|' -f1)
      local apache_https_port=$(echo "$port_config" | cut -d'|' -f2)
      
      # 开放邮件服务端口（使用服务名称，适用于标准端口）
      firewall-cmd --permanent --add-service=smtp 2>/dev/null || true
      firewall-cmd --permanent --add-service=imap 2>/dev/null || true
      firewall-cmd --permanent --add-service=pop3 2>/dev/null || true
      firewall-cmd --permanent --add-service=dns 2>/dev/null || true
      
      # 如果使用标准端口，使用服务名称；否则使用端口号
      if [[ "$apache_http_port" == "80" ]]; then
        firewall-cmd --permanent --add-service=http 2>/dev/null || true
      else
        firewall-cmd --permanent --add-port=${apache_http_port}/tcp 2>/dev/null || true
      fi
      
      if [[ "$apache_https_port" == "443" ]]; then
        firewall-cmd --permanent --add-service=https 2>/dev/null || true
      else
        firewall-cmd --permanent --add-port=${apache_https_port}/tcp 2>/dev/null || true
      fi
      
      firewall-cmd --reload 2>/dev/null || true
      log "防火墙规则配置完成（HTTP端口: ${apache_http_port}, HTTPS端口: ${apache_https_port}）"
    else
      log "防火墙启动失败，跳过规则配置"
    fi
    
    # 重启杀毒服务
    systemctl enable clamav-daemon || true
    systemctl restart clamav-daemon || true
    
    # 重启垃圾邮件过滤服务
    systemctl restart postfix || true
    sleep 2
    log "安全服务重启完成"
    exit 0
    ;;
  stop)
    log "关闭安全服务"
    # 关闭安全服务
    systemctl stop firewalld || true
    systemctl stop clamav-daemon || true
    systemctl stop postfix || true
    sleep 2
    log "安全服务关闭完成"
    exit 0
    ;;
  *)
    echo "用法: $0 {harden|install-cert <domain>|restart}" >&2
    exit 2
    ;;
esac

