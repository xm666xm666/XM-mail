#!/bin/bash
#
# ============================================================================
# 脚本名称: dispatcher.sh
# 工作职责: 调度层服务管理脚本 - 负责mail-ops-dispatcher服务的启动、停止和管理
#           提供调度层服务的生命周期管理和状态监控功能
# 系统组件: XM邮件管理系统 - 调度层服务管理模块
# ============================================================================
# 用法说明:
#   dispatcher.sh <action> [参数...]
#   dispatcher.sh restart            - 重启mail-ops-dispatcher服务（停止后启动）
#   dispatcher.sh stop               - 停止mail-ops-dispatcher服务
#
# 功能描述:
#   - 服务重启：优雅停止mail-ops-dispatcher服务，等待2秒后重新启动，检查服务状态
#   - 服务停止：停止mail-ops-dispatcher服务，等待3秒后验证服务已停止
#   - 状态检查：使用systemctl检查服务运行状态，失败时显示详细状态信息
#   - 日志输出：使用彩色日志输出（蓝色信息、绿色成功、黄色警告、红色错误）
#
# 服务管理:
#   - systemd服务：mail-ops-dispatcher.service
#   - 服务用户：xm
#   - 工作目录：${BASE_DIR}/backend/dispatcher（动态路径）
#   - 日志目录：/var/log/mail-ops
#
# 依赖关系:
#   - Node.js（运行环境）
#   - systemd（服务管理）
#   - mail-ops-dispatcher（调度层应用）
#
# 注意事项:
#   - 需要root权限管理systemd服务
#   - 服务重启会中断正在处理的请求
#   - 建议在维护窗口进行服务操作
# ============================================================================

set -uo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ✗${NC} $1"
}

# 检查root权限
require_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "此脚本需要root权限运行"
        exit 1
    fi
}

# 重启调度层服务
restart_dispatcher() {
    log "重启调度层服务..."
    
    # 停止服务
    log "停止调度层服务"
    systemctl stop mail-ops-dispatcher || true
    
    # 等待服务完全停止
    sleep 2
    
    # 启动服务
    log "启动调度层服务"
    systemctl start mail-ops-dispatcher
    
    # 等待服务启动
    sleep 3
    
    # 检查服务状态
    if systemctl is-active --quiet mail-ops-dispatcher; then
        log_success "调度层服务重启成功"
        return 0
    else
        log_error "调度层服务重启失败"
        systemctl status mail-ops-dispatcher --no-pager -l
        return 1
    fi
}

# 停止调度层服务
stop_dispatcher() {
    log "停止调度层服务..."
    
    # 停止服务
    log "停止调度层服务"
    systemctl stop mail-ops-dispatcher
    
    # 等待服务完全停止
    sleep 3
    
    # 检查服务状态
    if ! systemctl is-active --quiet mail-ops-dispatcher; then
        log_success "调度层服务停止成功"
        return 0
    else
        log_error "调度层服务停止失败"
        systemctl status mail-ops-dispatcher --no-pager -l
        return 1
    fi
}

# 主函数
main() {
    local action="${1:-}"
    
    case "$action" in
        restart)
            require_root
            restart_dispatcher
            ;;
        stop)
            require_root
            stop_dispatcher
            ;;
        *)
            log_error "未知操作: $action"
            echo "用法: $0 {restart|stop}"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
