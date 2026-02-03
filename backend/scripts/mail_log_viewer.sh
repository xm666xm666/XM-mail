#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_log_viewer.sh
# 工作职责: 邮件日志查看工具 - 负责查看和分析邮件操作相关的日志
#           提供邮件日志的查看、搜索、统计和导出功能
# 系统组件: XM邮件管理系统 - 邮件日志管理模块
# ============================================================================
# 用法说明:
#   mail_log_viewer.sh <action> [选项]
#   mail_log_viewer.sh mail [选项]      - 查看邮件发送/接收日志
#   mail_log_viewer.sh user [选项]      - 查看指定用户的邮件操作日志
#   mail_log_viewer.sh combined [选项]  - 查看合并的邮件和用户日志
#   mail_log_viewer.sh stats            - 生成邮件操作统计报告
#   mail_log_viewer.sh search <关键词>  - 搜索邮件日志中的关键词
#   mail_log_viewer.sh export <格式>    - 导出日志数据（txt/csv/json）
#   选项: -n <数量> -f(实时) -u <用户> -o <操作> -d <日期> -s <开始时间> -e <结束时间>
#
# 功能描述:
#   - 日志查看：查看邮件发送、接收等操作日志
#   - 日志搜索：搜索特定关键词或模式
#   - 日志过滤：按用户、操作类型、时间范围过滤
#   - 日志统计：统计邮件操作数量和频率
#   - 日志导出：导出日志为CSV、JSON等格式
#   - 实时跟踪：实时跟踪邮件操作日志
#
# 日志内容:
#   - 邮件发送记录
#   - 邮件接收记录
#   - 用户操作记录
#   - 系统事件记录
#
# 依赖关系:
#   - 日志目录：/var/log/mail-ops
#   - mail-operations.log, user-operations.log
#
# 注意事项:
#   - 需要读取日志文件的权限
#   - 大量日志查询可能较慢
#   - 导出功能需要足够的磁盘空间
# ============================================================================

set -euo pipefail

# 基础目录
BASE_DIR=$(cd "$(dirname "$0")/../.." && pwd)
LOG_DIR="/var/log/mail-ops"
MAIL_LOG="$LOG_DIR/mail-operations.log"
USER_LOG="$LOG_DIR/user-operations.log"

# 显示帮助信息
show_help() {
  echo "邮件日志查看工具"
  echo ""
  echo "用法:"
  echo "  $0 mail [选项]           - 查看邮件操作日志"
  echo "  $0 user [选项]           - 查看用户操作日志"
  echo "  $0 combined [选项]       - 查看合并日志"
  echo "  $0 stats                - 显示日志统计信息"
  echo "  $0 search <关键词>       - 搜索日志内容"
  echo "  $0 export <格式>         - 导出日志"
  echo ""
  echo "选项:"
  echo "  -n <数量>                - 显示最后N行"
  echo "  -f                       - 实时跟踪日志"
  echo "  -u <用户>                - 过滤特定用户"
  echo "  -o <操作>                - 过滤特定操作"
  echo "  -d <日期>                - 过滤特定日期 (YYYY-MM-DD)"
  echo "  -s <开始时间>            - 开始时间 (HH:MM:SS)"
  echo "  -e <结束时间>            - 结束时间 (HH:MM:SS)"
  echo ""
  echo "示例:"
  echo "  $0 mail -n 50                    # 显示最后50行邮件日志"
  echo "  $0 user -u admin -o login        # 显示admin用户的登录日志"
  echo "  $0 combined -d 2025-10-08         # 显示2025-10-08的合并日志"
  echo "  $0 search 'send'                  # 搜索包含'send'的日志"
  echo "  $0 stats                          # 显示日志统计"
}

# 查看邮件日志
show_mail_log() {
  local lines="${1:-50}"
  local user="${2:-}"
  local operation="${3:-}"
  local date="${4:-}"
  local start_time="${5:-}"
  local end_time="${6:-}"
  
  if [[ ! -f "$MAIL_LOG" ]]; then
    echo "邮件日志文件不存在: $MAIL_LOG"
    return 1
  fi
  
  echo "=== 邮件操作日志 ==="
  local cmd="tail -n $lines '$MAIL_LOG'"
  
  if [[ -n "$user" ]]; then
    cmd="$cmd | grep 'User: $user'"
  fi
  
  if [[ -n "$operation" ]]; then
    cmd="$cmd | grep 'Operation: $operation'"
  fi
  
  if [[ -n "$date" ]]; then
    cmd="$cmd | grep '\\[$date'"
  fi
  
  if [[ -n "$start_time" && -n "$end_time" ]]; then
    cmd="$cmd | awk -v start='$start_time' -v end='$end_time' '{
      if (match(\$0, /\\[([0-9-]+) ([0-9:]+)\\]/)) {
        time = substr(\$0, RSTART+11, RLENGTH-11)
        if (time >= start && time <= end) print
      }
    }'"
  fi
  
  eval "$cmd"
}

# 查看用户日志
show_user_log() {
  local lines="${1:-50}"
  local user="${2:-}"
  local operation="${3:-}"
  local date="${4:-}"
  local start_time="${5:-}"
  local end_time="${6:-}"
  
  if [[ ! -f "$USER_LOG" ]]; then
    echo "用户日志文件不存在: $USER_LOG"
    return 1
  fi
  
  echo "=== 用户操作日志 ==="
  local cmd="tail -n $lines '$USER_LOG'"
  
  if [[ -n "$user" ]]; then
    cmd="$cmd | grep 'User: $user'"
  fi
  
  if [[ -n "$operation" ]]; then
    cmd="$cmd | grep -E '(Action: $operation|Operation: $operation)'"
  fi
  
  if [[ -n "$date" ]]; then
    cmd="$cmd | grep '\\[$date'"
  fi
  
  if [[ -n "$start_time" && -n "$end_time" ]]; then
    cmd="$cmd | awk -v start='$start_time' -v end='$end_time' '{
      if (match(\$0, /\\[([0-9-]+) ([0-9:]+)\\]/)) {
        time = substr(\$0, RSTART+11, RLENGTH-11)
        if (time >= start && time <= end) print
      }
    }'"
  fi
  
  eval "$cmd"
}

# 查看合并日志
show_combined_log() {
  local lines="${1:-50}"
  local user="${2:-}"
  local operation="${3:-}"
  local date="${4:-}"
  local start_time="${5:-}"
  local end_time="${6:-}"
  
  echo "=== 合并日志 ==="
  
  # 合并两个日志文件
  local temp_file=$(mktemp)
  if [[ -f "$MAIL_LOG" ]]; then
    cat "$MAIL_LOG" >> "$temp_file"
  fi
  if [[ -f "$USER_LOG" ]]; then
    cat "$USER_LOG" >> "$temp_file"
  fi
  
  # 按时间排序
  sort "$temp_file" > "${temp_file}.sorted"
  
  local cmd="tail -n $lines '${temp_file}.sorted'"
  
  if [[ -n "$user" ]]; then
    cmd="$cmd | grep 'User: $user'"
  fi
  
  if [[ -n "$operation" ]]; then
    cmd="$cmd | grep -E '(Action: $operation|Operation: $operation)'"
  fi
  
  if [[ -n "$date" ]]; then
    cmd="$cmd | grep '\\[$date'"
  fi
  
  if [[ -n "$start_time" && -n "$end_time" ]]; then
    cmd="$cmd | awk -v start='$start_time' -v end='$end_time' '{
      if (match(\$0, /\\[([0-9-]+) ([0-9:]+)\\]/)) {
        time = substr(\$0, RSTART+11, RLENGTH-11)
        if (time >= start && time <= end) print
      }
    }'"
  fi
  
  eval "$cmd"
  
  # 清理临时文件
  rm -f "$temp_file" "${temp_file}.sorted"
}

# 显示统计信息
show_stats() {
  echo "=== 日志统计信息 ==="
  echo ""
  
  # 邮件日志统计
  if [[ -f "$MAIL_LOG" ]]; then
    echo "邮件操作日志统计:"
    echo "  总记录数: $(wc -l < "$MAIL_LOG")"
    echo "  文件大小: $(du -h "$MAIL_LOG" | cut -f1)"
    echo "  最后修改: $(stat -c %y "$MAIL_LOG" 2>/dev/null || stat -f %Sm "$MAIL_LOG" 2>/dev/null || echo '未知')"
    echo ""
    
    echo "操作类型统计:"
    grep -o 'Operation: [^,]*' "$MAIL_LOG" | sort | uniq -c | sort -nr | head -10
    echo ""
    
    echo "用户统计:"
    grep -o 'User: [^,]*' "$MAIL_LOG" | sort | uniq -c | sort -nr | head -10
    echo ""
  else
    echo "邮件日志文件不存在"
    echo ""
  fi
  
  # 用户日志统计
  if [[ -f "$USER_LOG" ]]; then
    echo "用户操作日志统计:"
    echo "  总记录数: $(wc -l < "$USER_LOG")"
    echo "  文件大小: $(du -h "$USER_LOG" | cut -f1)"
    echo "  最后修改: $(stat -c %y "$USER_LOG" 2>/dev/null || stat -f %Sm "$USER_LOG" 2>/dev/null || echo '未知')"
    echo ""
    
    echo "操作类型统计:"
    grep -oE '(Action: [^,]*|Operation: [^,]*)' "$USER_LOG" | sort | uniq -c | sort -nr | head -10
    echo ""
    
    echo "用户统计:"
    grep -o 'User: [^,]*' "$USER_LOG" | sort | uniq -c | sort -nr | head -10
    echo ""
  else
    echo "用户日志文件不存在"
    echo ""
  fi
}

# 搜索日志
search_logs() {
  local keyword="$1"
  
  echo "=== 搜索日志: $keyword ==="
  echo ""
  
  if [[ -f "$MAIL_LOG" ]]; then
    echo "邮件日志中的匹配:"
    grep -n "$keyword" "$MAIL_LOG" | head -20
    echo ""
  fi
  
  if [[ -f "$USER_LOG" ]]; then
    echo "用户日志中的匹配:"
    grep -n "$keyword" "$USER_LOG" | head -20
    echo ""
  fi
}

# 导出日志
export_logs() {
  local format="${1:-txt}"
  local output_file="mail_logs_$(date +%Y%m%d_%H%M%S).$format"
  
  case "$format" in
    "txt")
      {
        echo "=== 邮件操作日志 ==="
        [[ -f "$MAIL_LOG" ]] && cat "$MAIL_LOG"
        echo ""
        echo "=== 用户操作日志 ==="
        [[ -f "$USER_LOG" ]] && cat "$USER_LOG"
      } > "$output_file"
      ;;
    "csv")
      {
        echo "timestamp,user,operation,details,ip"
        [[ -f "$MAIL_LOG" ]] && grep -E '\[.*\] \[MAIL_OP\]' "$MAIL_LOG" | sed -E 's/\[([^\]]+)\] \[MAIL_OP\] User: ([^,]+), Operation: ([^,]+), Details: ([^,]+), IP: ([^,]+)/\1,\2,\3,\4,\5/'
        [[ -f "$USER_LOG" ]] && grep -E '\[.*\] \[USER_LOG\]' "$USER_LOG" | sed -E 's/\[([^\]]+)\] \[USER_LOG\] User: ([^,]+), Action: ([^,]+), Details: ([^,]+), IP: ([^,]+)/\1,\2,\3,\4,\5/'
      } > "$output_file"
      ;;
    "json")
      {
        echo "["
        local first=true
        [[ -f "$MAIL_LOG" ]] && grep -E '\[.*\] \[MAIL_OP\]' "$MAIL_LOG" | while read line; do
          if [[ "$first" == "true" ]]; then
            first=false
          else
            echo ","
          fi
          echo "$line" | sed -E 's/\[([^\]]+)\] \[MAIL_OP\] User: ([^,]+), Operation: ([^,]+), Details: ([^,]+), IP: ([^,]+)/{"timestamp":"\1","user":"\2","operation":"\3","details":"\4","ip":"\5","type":"mail"}/'
        done
        [[ -f "$USER_LOG" ]] && grep -E '\[.*\] \[USER_LOG\]' "$USER_LOG" | while read line; do
          if [[ "$first" == "true" ]]; then
            first=false
          else
            echo ","
          fi
          echo "$line" | sed -E 's/\[([^\]]+)\] \[USER_LOG\] User: ([^,]+), Action: ([^,]+), Details: ([^,]+), IP: ([^,]+)/{"timestamp":"\1","user":"\2","action":"\3","details":"\4","ip":"\5","type":"user"}/'
        done
        echo ""
        echo "]"
      } > "$output_file"
      ;;
    *)
      echo "不支持的格式: $format"
      echo "支持的格式: txt, csv, json"
      return 1
      ;;
  esac
  
  echo "日志已导出到: $output_file"
}

# 实时跟踪日志
tail_logs() {
  local log_type="${1:-combined}"
  
  case "$log_type" in
    "mail")
      if [[ -f "$MAIL_LOG" ]]; then
        tail -f "$MAIL_LOG"
      else
        echo "邮件日志文件不存在"
      fi
      ;;
    "user")
      if [[ -f "$USER_LOG" ]]; then
        tail -f "$USER_LOG"
      else
        echo "用户日志文件不存在"
      fi
      ;;
    "combined")
      {
        [[ -f "$MAIL_LOG" ]] && tail -f "$MAIL_LOG" &
        [[ -f "$USER_LOG" ]] && tail -f "$USER_LOG" &
        wait
      }
      ;;
    *)
      echo "不支持的日志类型: $log_type"
      echo "支持的类型: mail, user, combined"
      return 1
      ;;
  esac
}

# 主函数
main() {
  local action="${1:-help}"
  shift 2>/dev/null || true
  
  # 解析参数
  local lines=50
  local user=""
  local operation=""
  local date=""
  local start_time=""
  local end_time=""
  local follow=false
  
  while [[ $# -gt 0 ]]; do
    case $1 in
      -n)
        lines="$2"
        shift 2
        ;;
      -u)
        user="$2"
        shift 2
        ;;
      -o)
        operation="$2"
        shift 2
        ;;
      -d)
        date="$2"
        shift 2
        ;;
      -s)
        start_time="$2"
        shift 2
        ;;
      -e)
        end_time="$2"
        shift 2
        ;;
      -f)
        follow=true
        shift
        ;;
      *)
        break
        ;;
    esac
  done
  
  case "$action" in
    "mail")
      if [[ "$follow" == "true" ]]; then
        tail_logs "mail"
      else
        show_mail_log "$lines" "$user" "$operation" "$date" "$start_time" "$end_time"
      fi
      ;;
    "user")
      if [[ "$follow" == "true" ]]; then
        tail_logs "user"
      else
        show_user_log "$lines" "$user" "$operation" "$date" "$start_time" "$end_time"
      fi
      ;;
    "combined")
      if [[ "$follow" == "true" ]]; then
        tail_logs "combined"
      else
        show_combined_log "$lines" "$user" "$operation" "$date" "$start_time" "$end_time"
      fi
      ;;
    "stats")
      show_stats
      ;;
    "search")
      if [[ $# -eq 0 ]]; then
        echo "请提供搜索关键词"
        return 1
      fi
      search_logs "$1"
      ;;
    "export")
      if [[ $# -eq 0 ]]; then
        echo "请提供导出格式"
        return 1
      fi
      export_logs "$1"
      ;;
    "help"|*)
      show_help
      ;;
  esac
}

# 执行主函数
main "$@"
