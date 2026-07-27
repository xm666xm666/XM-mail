#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: log_viewer.sh
# 工作职责: 系统日志查看脚本 - 查看 /var/log/mail-ops 下各类运维日志
# 系统组件: XM邮件管理系统 - 日志管理模块
# ============================================================================
# 用法说明:
#   log_viewer.sh <action>
#   log_viewer.sh install              - 查看系统安装日志
#   log_viewer.sh operations           - 查看操作日志
#   log_viewer.sh system               - 查看系统服务日志
#   log_viewer.sh user                 - 查看用户操作日志
#   log_viewer.sh all                  - 查看所有日志
#   log_viewer.sh tail                 - 实时跟踪日志输出
#   log_viewer.sh clean                - 清理过期日志文件（30天前）
#   log_viewer.sh help                 - 显示帮助
#
# 功能描述:
#   - 日志查看：查看 /var/log/mail-ops 下各类日志文件
#   - 实时跟踪：tail -f 跟踪日志输出
#   - 日志清理：清理过期日志文件
#   - 无 search / stats 子命令
#
# 日志路径（/var/log/mail-ops）:
#   - install.log、operations.log、system.log、user-operations.log
#
# 依赖关系:
#   - tail、less 等日志工具
#
# 注意事项:
#   - 需要读取日志文件的权限
#   - 清理日志前建议先备份
# ============================================================================

# 获取项目根目录（BASE_DIR），统一使用 BASE_DIR 规范路径
BASE_DIR=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
if [[ -z "$BASE_DIR" ]]; then
  echo "错误: 无法确定项目根目录，请确保从项目目录运行或使用绝对路径调用脚本" >&2
  exit 1
fi
cd "$BASE_DIR" 2>/dev/null || true

set -euo pipefail

LOG_DIR="/var/log/mail-ops"
ACTION=${1:-help}

show_help() {
  echo "日志查看工具"
  echo ""
  echo "用法:"
  echo "  $0 install     - 查看安装日志"
  echo "  $0 operations  - 查看操作日志"
  echo "  $0 system      - 查看系统日志"
  echo "  $0 user        - 查看用户操作日志"
  echo "  $0 all         - 查看所有日志"
  echo "  $0 tail         - 实时查看日志"
  echo "  $0 clean       - 清理旧日志"
}

show_install_log() {
  echo "=== 安装日志 ==="
  if [[ -f "$LOG_DIR/install.log" ]]; then
    tail -50 "$LOG_DIR/install.log"
  else
    echo "安装日志不存在"
  fi
}

show_operations_log() {
  echo "=== 操作日志 ==="
  if [[ -f "$LOG_DIR/operations.log" ]]; then
    tail -50 "$LOG_DIR/operations.log"
  else
    echo "操作日志不存在"
  fi
}

show_system_log() {
  echo "=== 系统日志 ==="
  if [[ -f "$LOG_DIR/system.log" ]]; then
    tail -50 "$LOG_DIR/system.log"
  else
    echo "系统日志不存在"
  fi
}

show_user_log() {
  echo "=== 用户操作日志 ==="
  if [[ -f "$LOG_DIR/user-operations.log" ]]; then
    tail -50 "$LOG_DIR/user-operations.log"
  else
    echo "用户操作日志不存在"
  fi
}

show_all_logs() {
  echo "=== 所有日志 ==="
  for log_file in "$LOG_DIR"/*.log; do
    if [[ -f "$log_file" ]]; then
      echo "--- $(basename "$log_file") ---"
      tail -20 "$log_file"
      echo ""
    fi
  done
}

tail_logs() {
  echo "实时查看日志 (Ctrl+C 退出)"
  tail -f "$LOG_DIR"/*.log 2>/dev/null || echo "没有日志文件"
}

clean_logs() {
  echo "清理旧日志文件..."
  find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null || true
  echo "清理完成"
}

case "$ACTION" in
  install)
    show_install_log ;;
  operations)
    show_operations_log ;;
  system)
    show_system_log ;;
  user)
    show_user_log ;;
  all)
    show_all_logs ;;
  tail)
    tail_logs ;;
  clean)
    clean_logs ;;
  help|*)
    show_help ;;
esac
