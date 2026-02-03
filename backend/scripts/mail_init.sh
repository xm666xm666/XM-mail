#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_init.sh
# 工作职责: 邮件系统初始化脚本 - 负责邮件数据库的初始化和示例数据导入
#           在系统首次安装或重置时，创建必要的数据库表结构和示例邮件
# 系统组件: XM邮件管理系统 - 初始化模块
# ============================================================================
# 用法说明:
#   mail_init.sh <action> [选项]
#   mail_init.sh init                     - 初始化邮件数据库和表结构（调用mail_db.sh init）
#   mail_init.sh sample                   - 导入示例邮件数据用于测试（欢迎邮件、系统通知、已发送邮件）
#   mail_init.sh services                  - 设置邮件服务（启动Postfix和Dovecot服务）
#   mail_init.sh monitor                  - 配置邮件监控服务（创建systemd服务）
#   mail_init.sh all                      - 执行所有操作（init + sample + services + monitor）
#
# 功能描述:
#   - 数据库初始化：调用mail_db.sh init创建邮件数据库表结构
#   - 示例数据导入：添加示例邮件用于测试（欢迎邮件、系统通知、已发送邮件示例）
#   - 服务管理：确保Postfix和Dovecot服务运行并启用开机自启
#   - 监控配置：创建邮件监控systemd服务，定期检查邮件目录
#   - 日志记录：所有操作记录到/var/log/mail-ops/mail-init.log
#
# 初始化内容:
#   - 调用mail_db.sh init创建完整的邮件数据库表结构
#   - 添加3封示例邮件（欢迎邮件、系统通知、已发送邮件）
#   - 启动并启用Postfix和Dovecot服务
#   - 创建邮件监控systemd服务（/etc/systemd/system/mail-monitor.service）
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表
#   - maildb数据库：由mail_db.sh init命令创建邮件系统核心表（emails, email_folders等15张表）
#
# 依赖关系:
#   - mail_db.sh（邮件数据库管理脚本）
#   - MariaDB数据库
#   - 密码文件：/etc/mail-ops/mail-db.pass（通过mail_db.sh读取数据库密码）
#
# 注意事项:
#   - 仅在首次安装时执行
#   - 重置操作会删除所有邮件数据
#   - 需要root权限执行
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
  echo "[mail_init] $(date '+%Y-%m-%d %H:%M:%S') $*" | tee -a "$LOG_DIR/mail-init.log"
}

# 初始化邮件数据库
init_mail_database() {
  log "初始化邮件数据库..."
  
  local mail_db_script="$BASE_DIR/backend/scripts/mail_db.sh"
  if [[ -f "$mail_db_script" ]]; then
    bash "$mail_db_script" init
    log "邮件数据库初始化完成"
  else
    log "邮件数据库脚本不存在: $mail_db_script"
    return 1
  fi
}

# 添加示例邮件
add_sample_emails() {
  log "添加示例邮件..."
  
  local mail_db_script="$BASE_DIR/backend/scripts/mail_db.sh"
  if [[ ! -f "$mail_db_script" ]]; then
    log "邮件数据库脚本不存在: $mail_db_script"
    return 1
  fi
  
  # 添加欢迎邮件
  bash "$mail_db_script" store \
    "welcome-msg-001" \
    "system@localhost" \
    "admin@localhost" \
    "欢迎使用XM邮件管理系统" \
    "欢迎使用XM邮件管理系统！\n\n这是一个功能完整的邮件系统，支持：\n- 邮件发送和接收\n- 邮件管理\n- 系统监控\n- 用户管理\n\n感谢您的使用！" \
    "<p>欢迎使用XM邮件管理系统！</p><p>这是一个功能完整的邮件系统，支持：</p><ul><li>邮件发送和接收</li><li>邮件管理</li><li>系统监控</li><li>用户管理</li></ul><p>感谢您的使用！</p>" \
    "inbox" \
    "1024" \
    "" \
    "Message-ID: <welcome-msg-001@localhost>\nFrom: system@localhost\nTo: admin@localhost\nSubject: 欢迎使用XM邮件管理系统\nDate: $(date -R)"
  
  # 添加系统通知邮件
  bash "$mail_db_script" store \
    "system-notice-001" \
    "admin@localhost" \
    "admin@localhost" \
    "系统状态通知" \
    "系统运行正常！\n\n当前状态：\n- 邮件服务：运行中\n- 数据库：正常\n- 存储空间：充足\n\n如有问题，请联系系统管理员。" \
    "<p>系统运行正常！</p><p>当前状态：</p><ul><li>邮件服务：运行中</li><li>数据库：正常</li><li>存储空间：充足</li></ul><p>如有问题，请联系系统管理员。</p>" \
    "inbox" \
    "512" \
    "" \
    "Message-ID: <system-notice-001@localhost>\nFrom: admin@localhost\nTo: admin@localhost\nSubject: 系统状态通知\nDate: $(date -R)"
  
  # 添加已发送邮件示例
  bash "$mail_db_script" store \
    "sent-msg-001" \
    "admin@localhost" \
    "test@example.com" \
    "测试邮件" \
    "这是一封测试邮件，用于验证邮件系统功能。\n\n如果您收到此邮件，说明邮件系统工作正常。\n\n谢谢！" \
    "<p>这是一封测试邮件，用于验证邮件系统功能。</p><p>如果您收到此邮件，说明邮件系统工作正常。</p><p>谢谢！</p>" \
    "sent" \
    "256" \
    "" \
    "Message-ID: <sent-msg-001@localhost>\nFrom: admin@localhost\nTo: test@example.com\nSubject: 测试邮件\nDate: $(date -R)"
  
  log "示例邮件添加完成"
}

# 设置邮件服务
setup_mail_services() {
  log "设置邮件服务..."
  
  # 确保Postfix运行
  if systemctl is-active --quiet postfix; then
    log "Postfix服务正在运行"
  else
    log "启动Postfix服务..."
    systemctl start postfix 2>/dev/null || true
    systemctl enable postfix 2>/dev/null || true
  fi
  
  # 确保Dovecot运行
  if systemctl is-active --quiet dovecot; then
    log "Dovecot服务正在运行"
  else
    log "启动Dovecot服务..."
    systemctl start dovecot 2>/dev/null || true
    systemctl enable dovecot 2>/dev/null || true
  fi
  
  log "邮件服务设置完成"
}

# 配置邮件监控
setup_mail_monitoring() {
  log "配置邮件监控..."
  
  # 创建邮件监控脚本
  cat > /usr/local/bin/mail-monitor.sh << EOF
#!/usr/bin/env bash
# 邮件监控脚本

MAIL_DB_SCRIPT="${BASE_DIR}/backend/scripts/mail_db.sh"
MAIL_RECEIVER_SCRIPT="${BASE_DIR}/backend/scripts/mail_receiver.sh"

# 监控邮件目录
monitor_mail_dir() {
  local mail_dir="/var/mail"
  
  for user_mailbox in "$mail_dir"/*; do
    if [[ -f "$user_mailbox" && -s "$user_mailbox" ]]; then
      local user=$(basename "$user_mailbox")
      echo "处理用户邮箱: $user"
      
      # 处理邮件
      if [[ -f "$MAIL_RECEIVER_SCRIPT" ]]; then
        bash "$MAIL_RECEIVER_SCRIPT" process "$user"
      fi
    fi
  done
}

# 主循环
while true; do
  monitor_mail_dir
  sleep 30
done
EOF

  chmod +x /usr/local/bin/mail-monitor.sh
  
  # 创建systemd服务
  cat > /etc/systemd/system/mail-monitor.service << 'EOF'
[Unit]
Description=Mail Monitor Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/mail-monitor.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

  # 启动监控服务
  systemctl daemon-reload
  systemctl enable mail-monitor.service 2>/dev/null || true
  systemctl start mail-monitor.service 2>/dev/null || true
  
  log "邮件监控配置完成"
}

# 主函数
main() {
  local action="${1:-all}"
  
  case "$action" in
    "init")
      init_mail_database
      ;;
    "sample")
      add_sample_emails
      ;;
    "services")
      setup_mail_services
      ;;
    "monitor")
      setup_mail_monitoring
      ;;
    "all")
      init_mail_database
      add_sample_emails
      setup_mail_services
      setup_mail_monitoring
      ;;
    *)
      echo "用法: $0 {init|sample|services|monitor|all}"
      echo "  init      - 初始化邮件数据库"
      echo "  sample    - 添加示例邮件"
      echo "  services  - 设置邮件服务"
      echo "  monitor   - 配置邮件监控"
      echo "  all       - 执行所有操作"
      exit 1
      ;;
  esac
  
  log "邮件系统初始化完成"
}

# 执行主函数
main "$@"
