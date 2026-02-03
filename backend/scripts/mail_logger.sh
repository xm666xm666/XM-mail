#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_logger.sh
# 工作职责: 邮件操作日志记录脚本 - 负责记录邮件发送、接收等操作日志
#           确保敏感信息不被明文记录，提供安全的日志记录机制
# 系统组件: XM邮件管理系统 - 日志记录模块
# ============================================================================
# 用法说明:
#   mail_logger.sh <action> [参数...]
#   mail_logger.sh send <user> <to> <subject> <body_length> [ip] - 记录发送
#   mail_logger.sh receive <user> <from> <subject> <body_length> [ip] - 记录接收
#   mail_logger.sh delete <user> <mail_id> [ip] - 记录删除
#   mail_logger.sh mark <user> <mail_id> <action> [ip] - 记录标记
#   mail_logger.sh search <user> <query> <results_count> [ip] - 记录搜索
#   mail_logger.sh forward <user> <original_to> <forward_to> <subject> [ip] - 记录转发
#   mail_logger.sh reply <user> <reply_to> <subject> <body_length> [ip] - 记录回复
#   mail_logger.sh attachment <user> <mail_id> <action> <filename> <file_size> [ip] - 记录附件操作
#   mail_logger.sh folder <user> <action> <folder_name> [ip] - 记录文件夹操作
#   mail_logger.sh rule <user> <action> <rule_name> [ip] - 记录规则操作
#   mail_logger.sh sync <user> <sync_type> <status> <items_count> [ip] - 记录同步
#
# 功能描述:
#   - 邮件发送记录：记录邮件发送操作（不记录内容）
#   - 邮件接收记录：记录邮件接收操作
#   - 用户操作记录：记录用户操作行为
#   - 敏感信息保护：不记录密码、邮件内容等敏感信息
#   - 日志格式统一：统一的日志格式便于分析
#   - 时间戳记录：记录操作时间戳和IP地址
#
# 日志格式:
#   [时间戳] [操作类型] User: 用户, Operation: 操作, Details: 详情, IP: IP地址
#
# 安全特性:
#   - 不记录邮件正文内容
#   - 不记录用户密码
#   - 不记录敏感配置信息
#   - 日志文件权限控制
#
# 依赖关系:
#   - 日志目录：/var/log/mail-ops
#   - mail-operations.log文件
#
# 注意事项:
#   - 日志文件需要适当的权限控制
#   - 定期清理旧日志以节省空间
#   - 敏感操作需要额外审计
# ============================================================================

set -euo pipefail

# 基础目录
BASE_DIR=$(cd "$(dirname "$0")/../.." && pwd)
LOG_DIR="/var/log/mail-ops"
MAIL_LOG="$LOG_DIR/mail-operations.log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"
chown -R xm:xm "$LOG_DIR" 2>/dev/null || true
chmod -R 755 "$LOG_DIR" 2>/dev/null || true

# 日志函数
log_mail_operation() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local operation="$1"
  local user="${2:-unknown}"
  local details="${3:-}"
  local ip="${4:-unknown}"
  
  echo "[$timestamp] [MAIL_OP] User: $user, Operation: $operation, Details: $details, IP: $ip" >> "$MAIL_LOG"
}

# 记录邮件发送
log_mail_send() {
  local user="$1"
  local to="$2"
  local subject="$3"
  local body_length="$4"
  local ip="${5:-unknown}"
  
  # 掩码收件人邮箱
  local masked_to=$(echo "$to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 截断主题
  local truncated_subject=$(echo "$subject" | cut -c1-30)
  if [ ${#subject} -gt 30 ]; then
    truncated_subject="${truncated_subject}..."
  fi
  
  local details="to=$masked_to, subject='$truncated_subject', bodyLength=$body_length"
  log_mail_operation "send" "$user" "$details" "$ip"
}

# 记录邮件接收
log_mail_receive() {
  local user="$1"
  local from="$2"
  local subject="$3"
  local body_length="$4"
  local ip="${5:-unknown}"
  
  # 掩码发件人邮箱
  local masked_from=$(echo "$from" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 截断主题
  local truncated_subject=$(echo "$subject" | cut -c1-30)
  if [ ${#subject} -gt 30 ]; then
    truncated_subject="${truncated_subject}..."
  fi
  
  local details="from=$masked_from, subject='$truncated_subject', bodyLength=$body_length"
  log_mail_operation "receive" "$user" "$details" "$ip"
}

# 记录邮件删除
log_mail_delete() {
  local user="$1"
  local mail_id="$2"
  local ip="${3:-unknown}"
  
  local details="mailId=$mail_id"
  log_mail_operation "delete" "$user" "$details" "$ip"
}

# 记录邮件标记
log_mail_mark() {
  local user="$1"
  local mail_id="$2"
  local action="$3"  # read, unread, important, etc.
  local ip="${4:-unknown}"
  
  local details="mailId=$mail_id, action=$action"
  log_mail_operation "mark" "$user" "$details" "$ip"
}

# 记录邮件搜索
log_mail_search() {
  local user="$1"
  local query="$2"
  local results_count="$3"
  local ip="${4:-unknown}"
  
  # 掩码搜索关键词（保留前2个字符）
  local masked_query=$(echo "$query" | sed 's/\(.\{2\}\).*/\1***/')
  
  local details="query='$masked_query', resultsCount=$results_count"
  log_mail_operation "search" "$user" "$details" "$ip"
}

# 记录邮件转发
log_mail_forward() {
  local user="$1"
  local original_to="$2"
  local forward_to="$3"
  local subject="$4"
  local ip="${5:-unknown}"
  
  # 掩码邮箱地址
  local masked_original=$(echo "$original_to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_forward=$(echo "$forward_to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 截断主题
  local truncated_subject=$(echo "$subject" | cut -c1-30)
  if [ ${#subject} -gt 30 ]; then
    truncated_subject="${truncated_subject}..."
  fi
  
  local details="originalTo=$masked_original, forwardTo=$masked_forward, subject='$truncated_subject'"
  log_mail_operation "forward" "$user" "$details" "$ip"
}

# 记录邮件回复
log_mail_reply() {
  local user="$1"
  local reply_to="$2"
  local subject="$3"
  local body_length="$4"
  local ip="${5:-unknown}"
  
  # 掩码收件人邮箱
  local masked_to=$(echo "$reply_to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 截断主题
  local truncated_subject=$(echo "$subject" | cut -c1-30)
  if [ ${#subject} -gt 30 ]; then
    truncated_subject="${truncated_subject}..."
  fi
  
  local details="replyTo=$masked_to, subject='$truncated_subject', bodyLength=$body_length"
  log_mail_operation "reply" "$user" "$details" "$ip"
}

# 记录邮件附件操作
log_mail_attachment() {
  local user="$1"
  local mail_id="$2"
  local action="$3"  # download, upload, delete
  local filename="$4"
  local file_size="$5"
  local ip="${6:-unknown}"
  
  # 掩码文件名（保留扩展名）
  local masked_filename=$(echo "$filename" | sed 's/\(.\{2\}\).*\(\.[^.]*\)$/\1***\2/')
  
  local details="mailId=$mail_id, action=$action, filename='$masked_filename', size=$file_size"
  log_mail_operation "attachment" "$user" "$details" "$ip"
}

# 记录邮件文件夹操作
log_mail_folder() {
  local user="$1"
  local action="$2"  # create, delete, rename, move
  local folder_name="$3"
  local ip="${4:-unknown}"
  
  local details="action=$action, folderName='$folder_name'"
  log_mail_operation "folder" "$user" "$details" "$ip"
}

# 记录邮件规则操作
log_mail_rule() {
  local user="$1"
  local action="$2"  # create, update, delete, enable, disable
  local rule_name="$3"
  local ip="${4:-unknown}"
  
  local details="action=$action, ruleName='$rule_name'"
  log_mail_operation "rule" "$user" "$details" "$ip"
}

# 记录邮件同步操作
log_mail_sync() {
  local user="$1"
  local sync_type="$2"  # imap, pop3, exchange
  local status="$3"     # success, failed, partial
  local items_count="$4"
  local ip="${5:-unknown}"
  
  local details="syncType=$sync_type, status=$status, itemsCount=$items_count"
  log_mail_operation "sync" "$user" "$details" "$ip"
}

# 主函数
main() {
  local action="${1:-help}"
  
  case "$action" in
    "send")
      log_mail_send "$2" "$3" "$4" "$5" "${6:-unknown}"
      ;;
    "receive")
      log_mail_receive "$2" "$3" "$4" "$5" "${6:-unknown}"
      ;;
    "delete")
      log_mail_delete "$2" "$3" "${4:-unknown}"
      ;;
    "mark")
      log_mail_mark "$2" "$3" "$4" "${5:-unknown}"
      ;;
    "search")
      log_mail_search "$2" "$3" "$4" "${5:-unknown}"
      ;;
    "forward")
      log_mail_forward "$2" "$3" "$4" "$5" "${6:-unknown}"
      ;;
    "reply")
      log_mail_reply "$2" "$3" "$4" "$5" "${6:-unknown}"
      ;;
    "attachment")
      log_mail_attachment "$2" "$3" "$4" "$5" "$6" "${7:-unknown}"
      ;;
    "folder")
      log_mail_folder "$2" "$3" "$4" "${5:-unknown}"
      ;;
    "rule")
      log_mail_rule "$2" "$3" "$4" "${5:-unknown}"
      ;;
    "sync")
      log_mail_sync "$2" "$3" "$4" "$5" "${6:-unknown}"
      ;;
    "help"|*)
      echo "邮件日志记录工具"
      echo ""
      echo "用法:"
      echo "  $0 send <user> <to> <subject> <body_length> [ip]"
      echo "  $0 receive <user> <from> <subject> <body_length> [ip]"
      echo "  $0 delete <user> <mail_id> [ip]"
      echo "  $0 mark <user> <mail_id> <action> [ip]"
      echo "  $0 search <user> <query> <results_count> [ip]"
      echo "  $0 forward <user> <original_to> <forward_to> <subject> [ip]"
      echo "  $0 reply <user> <reply_to> <subject> <body_length> [ip]"
      echo "  $0 attachment <user> <mail_id> <action> <filename> <file_size> [ip]"
      echo "  $0 folder <user> <action> <folder_name> [ip]"
      echo "  $0 rule <user> <action> <rule_name> [ip]"
      echo "  $0 sync <user> <sync_type> <status> <items_count> [ip]"
      echo ""
      echo "示例:"
      echo "  $0 send user@example.com recipient@domain.com 'Test Subject' 150 192.168.1.100"
      echo "  $0 receive user@example.com sender@domain.com 'Important Email' 200"
      ;;
  esac
}

# 执行主函数
main "$@"
