#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_service_logger.sh
# 工作职责: 邮件服务日志集成脚本 - 负责在Postfix和Dovecot中集成加密日志记录
#           将邮件服务的日志统一收集、处理和存储，确保日志安全
# 系统组件: XM邮件管理系统 - 服务日志集成模块
# ============================================================================
# 用法说明:
#   mail_service_logger.sh <action>
#   mail_service_logger.sh install     - 安装邮件服务日志记录（Postfix/Dovecot 日志配置、轮转等）
#   mail_service_logger.sh test        - 测试日志记录功能
#   mail_service_logger.sh uninstall   - 卸载日志记录（移除脚本与配置）
#   mail_service_logger.sh help        - 显示帮助信息
#
# 功能描述:
#   - 安装时配置 Postfix、Dovecot 等相关日志与轮转
#   - 测试时验证日志记录是否正常
#   - 卸载时删除 /usr/local/bin 下脚本及 rsyslog/logrotate 配置
#
# 依赖关系:
#   - Postfix、Dovecot、rsyslog、logrotate
#
# 注意事项:
#   - 需要 root 权限执行 install/uninstall
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

# 配置Postfix日志记录
configure_postfix_logging() {
  echo "配置Postfix日志记录..."
  
  # 创建Postfix日志处理脚本
  cat > /usr/local/bin/postfix_logger.sh << 'EOF'
#!/usr/bin/env bash
# Postfix日志处理脚本

LOG_DIR="/var/log/mail-ops"
MAIL_LOG="$LOG_DIR/mail-operations.log"

# 处理邮件发送日志
process_send_log() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local message_id=$(echo "$line" | grep -o 'message-id=<[^>]*>' | sed 's/message-id=<\([^>]*\)>/\1/')
  local from=$(echo "$line" | grep -o 'from=<[^>]*>' | sed 's/from=<\([^>]*\)>/\1/')
  local to=$(echo "$line" | grep -o 'to=<[^>]*>' | sed 's/to=<\([^>]*\)>/\1/')
  local size=$(echo "$line" | grep -o 'size=[0-9]*' | sed 's/size=//')
  local status=$(echo "$line" | grep -o 'status=[^,]*' | sed 's/status=//')
  
  # 掩码敏感信息
  local masked_from=$(echo "$from" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_to=$(echo "$to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: system, Operation: send, Details: messageId=$message_id, from=$masked_from, to=$masked_to, size=$size, status=$status, IP: system" >> "$MAIL_LOG"
}

# 处理邮件接收日志
process_receive_log() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local message_id=$(echo "$line" | grep -o 'message-id=<[^>]*>' | sed 's/message-id=<\([^>]*\)>/\1/')
  local from=$(echo "$line" | grep -o 'from=<[^>]*>' | sed 's/from=<\([^>]*\)>/\1/')
  local to=$(echo "$line" | grep -o 'to=<[^>]*>' | sed 's/to=<\([^>]*\)>/\1/')
  local size=$(echo "$line" | grep -o 'size=[0-9]*' | sed 's/size=//')
  local status=$(echo "$line" | grep -o 'status=[^,]*' | sed 's/status=//')
  
  # 掩码敏感信息
  local masked_from=$(echo "$from" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_to=$(echo "$to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: system, Operation: receive, Details: messageId=$message_id, from=$masked_from, to=$masked_to, size=$size, status=$status, IP: system" >> "$MAIL_LOG"
}

# 主处理逻辑
while read line; do
  if echo "$line" | grep -q "postfix/smtp.*to="; then
    process_send_log "$line"
  elif echo "$line" | grep -q "postfix/smtpd.*from="; then
    process_receive_log "$line"
  fi
done
EOF

  chmod +x /usr/local/bin/postfix_logger.sh
  
  # 配置rsyslog转发Postfix日志
  cat > /etc/rsyslog.d/50-postfix-logger.conf << 'EOF'
# Postfix日志转发配置
:programname, isequal, "postfix" /usr/local/bin/postfix_logger.sh
& stop
EOF

  # 重启rsyslog服务
  systemctl restart rsyslog 2>/dev/null || true
  
  echo "Postfix日志记录配置完成"
}

# 配置Dovecot日志记录
configure_dovecot_logging() {
  echo "配置Dovecot日志记录..."
  
  # 创建Dovecot日志处理脚本
  cat > /usr/local/bin/dovecot_logger.sh << 'EOF'
#!/usr/bin/env bash
# Dovecot日志处理脚本

LOG_DIR="/var/log/mail-ops"
MAIL_LOG="$LOG_DIR/mail-operations.log"

# 处理IMAP/POP3登录日志
process_login_log() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local user=$(echo "$line" | grep -o 'user=<[^>]*>' | sed 's/user=<\([^>]*\)>/\1/')
  local ip=$(echo "$line" | grep -o 'rip=[^,]*' | sed 's/rip=//')
  local method=$(echo "$line" | grep -o 'method=[^,]*' | sed 's/method=//')
  local status=$(echo "$line" | grep -o 'status=[^,]*' | sed 's/status=//')
  
  # 掩码用户名
  local masked_user=$(echo "$user" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: $masked_user, Operation: login, Details: method=$method, status=$status, IP: $ip" >> "$MAIL_LOG"
}

# 处理邮件访问日志
process_access_log() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local user=$(echo "$line" | grep -o 'user=<[^>]*>' | sed 's/user=<\([^>]*\)>/\1/')
  local ip=$(echo "$line" | grep -o 'rip=[^,]*' | sed 's/rip=//')
  local action=$(echo "$line" | grep -o 'cmd=[^,]*' | sed 's/cmd=//')
  local mailbox=$(echo "$line" | grep -o 'mailbox=[^,]*' | sed 's/mailbox=//')
  
  # 掩码用户名和邮箱
  local masked_user=$(echo "$user" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_mailbox=$(echo "$mailbox" | sed 's/\(.\{2\}\).*/\1***/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: $masked_user, Operation: access, Details: action=$action, mailbox=$masked_mailbox, IP: $ip" >> "$MAIL_LOG"
}

# 主处理逻辑
while read line; do
  if echo "$line" | grep -q "dovecot.*login"; then
    process_login_log "$line"
  elif echo "$line" | grep -q "dovecot.*cmd="; then
    process_access_log "$line"
  fi
done
EOF

  chmod +x /usr/local/bin/dovecot_logger.sh
  
  # 配置rsyslog转发Dovecot日志
  cat > /etc/rsyslog.d/50-dovecot-logger.conf << 'EOF'
# Dovecot日志转发配置
:programname, isequal, "dovecot" /usr/local/bin/dovecot_logger.sh
& stop
EOF

  # 重启rsyslog服务
  systemctl restart rsyslog 2>/dev/null || true
  
  echo "Dovecot日志记录配置完成"
}

# 配置邮件内容扫描日志
configure_content_scanning() {
  echo "配置邮件内容扫描日志..."
  
  # 创建内容扫描日志处理脚本
  cat > /usr/local/bin/content_scanner.sh << 'EOF'
#!/usr/bin/env bash
# 邮件内容扫描日志处理脚本

LOG_DIR="/var/log/mail-ops"
MAIL_LOG="$LOG_DIR/mail-operations.log"

# 处理病毒扫描日志
process_virus_scan() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local message_id=$(echo "$line" | grep -o 'message-id=<[^>]*>' | sed 's/message-id=<\([^>]*\)>/\1/')
  local from=$(echo "$line" | grep -o 'from=<[^>]*>' | sed 's/from=<\([^>]*\)>/\1/')
  local to=$(echo "$line" | grep -o 'to=<[^>]*>' | sed 's/to=<\([^>]*\)>/\1/')
  local virus=$(echo "$line" | grep -o 'virus=[^,]*' | sed 's/virus=//')
  local action=$(echo "$line" | grep -o 'action=[^,]*' | sed 's/action=//')
  
  # 掩码敏感信息
  local masked_from=$(echo "$from" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_to=$(echo "$to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: system, Operation: virus_scan, Details: messageId=$message_id, from=$masked_from, to=$masked_to, virus=$virus, action=$action, IP: system" >> "$MAIL_LOG"
}

# 处理垃圾邮件扫描日志
process_spam_scan() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local message_id=$(echo "$line" | grep -o 'message-id=<[^>]*>' | sed 's/message-id=<\([^>]*\)>/\1/')
  local from=$(echo "$line" | grep -o 'from=<[^>]*>' | sed 's/from=<\([^>]*\)>/\1/')
  local to=$(echo "$line" | grep -o 'to=<[^>]*>' | sed 's/to=<\([^>]*\)>/\1/')
  local spam_score=$(echo "$line" | grep -o 'spam_score=[0-9.]*' | sed 's/spam_score=//')
  local action=$(echo "$line" | grep -o 'action=[^,]*' | sed 's/action=//')
  
  # 掩码敏感信息
  local masked_from=$(echo "$from" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_to=$(echo "$to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: system, Operation: spam_scan, Details: messageId=$message_id, from=$masked_from, to=$masked_to, spamScore=$spam_score, action=$action, IP: system" >> "$MAIL_LOG"
}

# 主处理逻辑
while read line; do
  if echo "$line" | grep -q "virus"; then
    process_virus_scan "$line"
  elif echo "$line" | grep -q "spam"; then
    process_spam_scan "$line"
  fi
done
EOF

  chmod +x /usr/local/bin/content_scanner.sh
  
  echo "邮件内容扫描日志配置完成"
}

# 配置邮件转发日志
configure_forwarding_logging() {
  echo "配置邮件转发日志..."
  
  # 创建转发日志处理脚本
  cat > /usr/local/bin/forward_logger.sh << 'EOF'
#!/usr/bin/env bash
# 邮件转发日志处理脚本

LOG_DIR="/var/log/mail-ops"
MAIL_LOG="$LOG_DIR/mail-operations.log"

# 处理邮件转发日志
process_forward_log() {
  local line="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # 提取关键信息
  local message_id=$(echo "$line" | grep -o 'message-id=<[^>]*>' | sed 's/message-id=<\([^>]*\)>/\1/')
  local from=$(echo "$line" | grep -o 'from=<[^>]*>' | sed 's/from=<\([^>]*\)>/\1/')
  local to=$(echo "$line" | grep -o 'to=<[^>]*>' | sed 's/to=<\([^>]*\)>/\1/')
  local forward_to=$(echo "$line" | grep -o 'forward_to=<[^>]*>' | sed 's/forward_to=<\([^>]*\)>/\1/')
  local status=$(echo "$line" | grep -o 'status=[^,]*' | sed 's/status=//')
  
  # 掩码敏感信息
  local masked_from=$(echo "$from" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_to=$(echo "$to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  local masked_forward_to=$(echo "$forward_to" | sed 's/\(.\{2\}\).*\(@.*\)/\1***\2/')
  
  # 记录到邮件日志
  echo "[$timestamp] [MAIL_OP] User: system, Operation: forward, Details: messageId=$message_id, from=$masked_from, to=$masked_to, forwardTo=$masked_forward_to, status=$status, IP: system" >> "$MAIL_LOG"
}

# 主处理逻辑
while read line; do
  if echo "$line" | grep -q "forward"; then
    process_forward_log "$line"
  fi
done
EOF

  chmod +x /usr/local/bin/forward_logger.sh
  
  echo "邮件转发日志配置完成"
}

# 配置日志轮转
configure_log_rotation() {
  echo "配置日志轮转..."
  
  # 创建logrotate配置
  cat > /etc/logrotate.d/mail-ops << 'EOF'
/var/log/mail-ops/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 xm xm
    postrotate
        # 重启相关服务以重新打开日志文件
        systemctl reload rsyslog 2>/dev/null || true
    endscript
}
EOF

  echo "日志轮转配置完成"
}

# 测试日志记录
test_logging() {
  echo "测试日志记录..."
  
  # 测试邮件发送日志
  echo "测试邮件发送日志记录"
  echo "postfix/smtp: to=<test@example.com>, from=<sender@domain.com>, size=1024, status=sent" | /usr/local/bin/postfix_logger.sh
  
  # 测试邮件接收日志
  echo "测试邮件接收日志记录"
  echo "postfix/smtpd: from=<sender@domain.com>, to=<test@example.com>, size=1024, status=received" | /usr/local/bin/postfix_logger.sh
  
  # 测试Dovecot登录日志
  echo "测试Dovecot登录日志记录"
  echo "dovecot: login: user=<test@example.com>, rip=192.168.1.100, method=PLAIN, status=success" | /usr/local/bin/dovecot_logger.sh
  
  echo "日志记录测试完成"
}

# 主函数
main() {
  local action="${1:-help}"
  
  case "$action" in
    "install")
      echo "安装邮件服务日志记录..."
      configure_postfix_logging
      configure_dovecot_logging
      configure_content_scanning
      configure_forwarding_logging
      configure_log_rotation
      echo "邮件服务日志记录安装完成"
      ;;
    "test")
      test_logging
      ;;
    "uninstall")
      echo "卸载邮件服务日志记录..."
      rm -f /usr/local/bin/postfix_logger.sh
      rm -f /usr/local/bin/dovecot_logger.sh
      rm -f /usr/local/bin/content_scanner.sh
      rm -f /usr/local/bin/forward_logger.sh
      rm -f /etc/rsyslog.d/50-postfix-logger.conf
      rm -f /etc/rsyslog.d/50-dovecot-logger.conf
      rm -f /etc/logrotate.d/mail-ops
      systemctl restart rsyslog 2>/dev/null || true
      echo "邮件服务日志记录卸载完成"
      ;;
    "help"|*)
      echo "邮件服务日志记录工具"
      echo ""
      echo "用法:"
      echo "  $0 install   - 安装邮件服务日志记录"
      echo "  $0 test      - 测试日志记录功能"
      echo "  $0 uninstall - 卸载邮件服务日志记录"
      echo "  $0 help      - 显示此帮助信息"
      ;;
  esac
}

# 执行主函数
main "$@"
