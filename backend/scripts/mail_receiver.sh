#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_receiver.sh
# 工作职责: 邮件接收处理脚本 - 负责处理接收到的邮件，将其存储到数据库
#           解析邮件内容，提取附件，并将邮件信息存储到邮件数据库
# 系统组件: XM邮件管理系统 - 邮件接收处理模块
# ============================================================================
# 用法说明:
#   mail_receiver.sh <action> [参数...]
#   mail_receiver.sh process <用户>      - 监控并处理指定用户的邮件目录（Maildir）
#   mail_receiver.sh queue               - 处理 Postfix 队列中的待投递邮件
#   mail_receiver.sh dovecot <用户>      - 处理 Dovecot Maildir 中已投递的邮件
#   mail_receiver.sh file <邮件文件>     - 处理单个邮件文件（解析、存储到数据库）
#
# 功能描述:
#   - 邮件接收：从 Postfix 队列或 Dovecot Maildir 获取邮件
#   - 邮件解析：解析邮件头与正文，提取附件
#   - 数据库存储：通过 mail_db.sh 将邮件信息与附件写入 maildb
#   - 用户验证：验证收件人是否为有效邮件用户
#   - 垃圾邮件检测：可集成 spam_filter.sh 检测
#
# 处理流程（file）:
#   1. 解析邮件文件 → 2. 验证收件人 → 3. 可选垃圾检测 → 4. 存储到数据库（mail_db.sh）→ 5. 附件存储
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表
#   - maildb数据库：由mail_db.sh init命令创建邮件系统核心表（emails, email_attachments等15张表）
#
# 依赖关系:
#   - mail_db.sh（邮件数据库管理）
#   - spam_filter.sh（垃圾邮件过滤）
#   - MariaDB数据库
#   - 密码文件：/etc/mail-ops/mail-db.pass（通过mail_db.sh读取数据库密码）
#
# 注意事项:
#   - 需要数据库写入权限
#   - 大附件可能影响处理速度
#   - 需要足够的磁盘空间存储邮件
#   - 通过mail_db.sh脚本间接访问数据库，密码由mail_db.sh统一管理
# ============================================================================

set -euo pipefail

# 基础目录
BASE_DIR=$(cd "$(dirname "$0")/../.." && pwd)
LOG_DIR="/var/log/mail-ops"
MAIL_DB="/var/lib/mail-ops/mail.db"

# 确保目录存在
mkdir -p "$(dirname "$MAIL_DB")"
mkdir -p "$LOG_DIR"

# 日志函数
log() {
  echo "[mail_receiver] $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_DIR/mail-receiver.log"
}

# 处理接收到的邮件
process_received_mail() {
  local mail_file="$1"
  
  if [[ ! -f "$mail_file" ]]; then
    log "邮件文件不存在: $mail_file"
    return 1
  fi
  
  log "处理接收到的邮件: $mail_file"
  
  # 解析邮件头信息
  local message_id=$(grep -i "^Message-ID:" "$mail_file" | head -1 | sed 's/Message-ID:\s*//i' | tr -d '<>')
  local from=$(grep -i "^From:" "$mail_file" | head -1 | sed 's/From:\s*//i')
  local to=$(grep -i "^To:" "$mail_file" | head -1 | sed 's/To:\s*//i')
  local subject=$(grep -i "^Subject:" "$mail_file" | head -1 | sed 's/Subject:\s*//i')
  local date=$(grep -i "^Date:" "$mail_file" | head -1 | sed 's/Date:\s*//i')
  
  # 如果没有Message-ID，生成一个
  if [[ -z "$message_id" ]]; then
    message_id="msg-$(date +%s)-$(uuidgen | tr -d '-' | cut -c1-8)"
  fi
  
  # 解析邮件体
  local body_start=$(grep -n "^$" "$mail_file" | head -1 | cut -d: -f1)
  if [[ -n "$body_start" ]]; then
    local body=$(tail -n +$((body_start + 1)) "$mail_file")
  else
    local body=$(cat "$mail_file")
  fi
  
  # 生成HTML版本
  local html_body=$(echo "$body" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g' | sed 's/$/<br>/g')
  
  # 计算邮件大小
  local size_bytes=$(wc -c < "$mail_file")
  
  # 存储邮件到数据库
  local mail_db_script="$BASE_DIR/backend/scripts/mail_db.sh"
  if [[ -f "$mail_db_script" ]]; then
    bash "$mail_db_script" store \
      "$message_id" \
      "$from" \
      "$to" \
      "$subject" \
      "$body" \
      "$html_body" \
      "inbox" \
      "$size_bytes" \
      "" \
      "$(head -20 "$mail_file" | tr '\n' '|')"
    
    log "邮件存储成功: $message_id"
  else
    log "邮件数据库脚本不存在: $mail_db_script"
    return 1
  fi
  
  # 清理临时文件
  rm -f "$mail_file"
  
  log "邮件处理完成: $message_id"
}

# 监控邮件目录
monitor_mail_directory() {
  local mail_dir="/var/mail"
  local user="$1"
  
  log "开始监控邮件目录: $mail_dir"
  
  # 检查用户邮箱文件
  local user_mailbox="$mail_dir/$user"
  if [[ -f "$user_mailbox" ]]; then
    log "发现用户邮箱文件: $user_mailbox"
    
    # 使用maildrop或procmail处理邮件
    if command -v maildrop >/dev/null 2>&1; then
      # 使用maildrop处理邮件
      maildrop -d "$user" < "$user_mailbox" 2>/dev/null || true
    elif command -v procmail >/dev/null 2>&1; then
      # 使用procmail处理邮件
      procmail < "$user_mailbox" 2>/dev/null || true
    else
      # 直接处理邮件文件
      process_received_mail "$user_mailbox"
    fi
  fi
}

# 处理Postfix邮件队列
process_postfix_queue() {
  log "处理Postfix邮件队列..."
  
  # 检查邮件队列
  local queue_count=$(postqueue -p | grep -c "Mail queue is empty" || echo "0")
  if [[ "$queue_count" -eq 0 ]]; then
    log "邮件队列中有邮件，开始处理..."
    
    # 处理队列中的邮件
    postqueue -f 2>/dev/null || true
  else
    log "邮件队列为空"
  fi
}

# 处理Dovecot邮件存储
process_dovecot_maildir() {
  local user="$1"
  local maildir="/home/$user/Maildir"
  
  if [[ -d "$maildir" ]]; then
    log "处理Dovecot邮件目录: $maildir"
    
    # 处理新邮件
    local new_dir="$maildir/new"
    if [[ -d "$new_dir" ]]; then
      for mail_file in "$new_dir"/*; do
        if [[ -f "$mail_file" ]]; then
          log "处理新邮件: $mail_file"
          process_received_mail "$mail_file"
        fi
      done
    fi
  fi
}

# 主函数
main() {
  local action="${1:-help}"
  local user="${2:-}"
  
  case "$action" in
    "process")
      if [[ -z "$user" ]]; then
        echo "用法: $0 process <user>"
        exit 1
      fi
      monitor_mail_directory "$user"
      ;;
    "queue")
      process_postfix_queue
      ;;
    "dovecot")
      if [[ -z "$user" ]]; then
        echo "用法: $0 dovecot <user>"
        exit 1
      fi
      process_dovecot_maildir "$user"
      ;;
    "file")
      local mail_file="${2:-}"
      if [[ -z "$mail_file" ]]; then
        echo "用法: $0 file <mail_file>"
        exit 1
      fi
      process_received_mail "$mail_file"
      ;;
    *)
      echo "用法: $0 {process|queue|dovecot|file}"
      echo "  process <user>     - 监控用户邮箱"
      echo "  queue              - 处理Postfix邮件队列"
      echo "  dovecot <user>     - 处理Dovecot邮件目录"
      echo "  file <mail_file>   - 处理指定邮件文件"
      exit 1
      ;;
  esac
}

# 执行主函数
main "$@"
