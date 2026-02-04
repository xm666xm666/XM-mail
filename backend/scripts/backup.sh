#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: backup.sh
# 工作职责: 系统备份与灾备脚本 - 负责邮件系统的全量备份、数据库恢复与定时备份配置
# 系统组件: XM邮件管理系统 - 备份与灾备模块
# ============================================================================
# 用法说明:
#   backup.sh <action> [参数...]
#   backup.sh full-backup                  - 执行全量备份（数据库+配置+邮件数据等）
#   backup.sh restore-db <备份文件>         - 从备份文件恢复数据库（maildb/mailapp）
#   backup.sh setup-cron                   - 配置定时备份 cron 任务
#   backup.sh setup-backup-cron <间隔> <数据库> <配置> <邮件目录> <保留天数> - 配置备份 cron 参数
#   backup.sh check-status                 - 检查备份配置与状态
#
# 功能描述:
#   - 全量备份：数据库（maildb、mailapp）、配置文件、邮件数据等打包备份
#   - 数据库恢复：从指定备份文件恢复 maildb/mailapp
#   - 定时备份：通过 cron 定期执行全量备份
#   - 状态检查：检查备份是否已初始化、cron 是否已配置
#
# 备份内容（full-backup）:
#   - MariaDB 数据库（maildb, mailapp）
#   - 配置文件（Apache、Postfix、Dovecot 等）
#   - 邮件存储目录（Maildir 等，若配置）
#   - 密码文件（/etc/mail-ops/*.pass）等
#
# 数据库来源说明:
#   - maildb：由 db_setup.sh init 与 mail_db.sh init 创建（Postfix 表 + 邮件核心表）
#   - mailapp：由 app_user.sh schema 创建（app_users, app_accounts）
#
# 依赖关系:
#   - mysqldump、tar/gzip、cron
#   - 密码文件：/etc/mail-ops/mail-db.pass、/etc/mail-ops/app-db.pass
#
# 注意事项:
#   - 需要 root 权限执行
#   - 备份路径与保留策略由脚本内变量或 setup-backup-cron 参数决定
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

set -euo pipefail

log() { echo "[backup] $*" >&1; }

# 权限检查
require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "警告: 当前用户不是 root，某些操作可能失败" >&1
    echo "建议: 使用 sudo 运行此脚本或切换到 root 用户" >&1
  fi
}

ACTION=${1:-help}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: backup.sh $ACTION" >&1
echo "当前时间: $(date)" >&1
echo "当前用户: $(whoami)" >&1
echo "当前目录: $(pwd)" >&1

# 检查权限
require_root
BACKUP_DIR=${BACKUP_DIR:-/var/backups/mail}
RETENTION_DAYS=${RETENTION_DAYS:-7}

ensure_backup_dir() {
  install -d -m 0755 "$BACKUP_DIR"
}

backup_database() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local db_backup="$BACKUP_DIR/maildb_${timestamp}.sql"
  local app_backup="$BACKUP_DIR/mailapp_${timestamp}.sql"
  
  log "备份数据库"
  
  # 检查MariaDB服务是否运行
  if systemctl is-active --quiet mariadb; then
    # 备份所有数据库
    if mysqldump -u root --all-databases > "$db_backup" 2>/dev/null; then
      log "全数据库备份完成: $db_backup"
      gzip "$db_backup" || true
    else
      log "全数据库备份失败，尝试单独备份"
    fi
    
    # 备份maildb数据库
    if mysqldump -u root maildb > "$db_backup" 2>/dev/null; then
      log "maildb数据库备份完成: $db_backup"
      gzip "$db_backup" || true
    else
      log "maildb数据库不存在或备份失败"
    fi
    
    # 备份mailapp数据库
    if mysqldump -u root mailapp > "$app_backup" 2>/dev/null; then
      log "mailapp数据库备份完成: $app_backup"
      gzip "$app_backup" || true
    else
      log "mailapp数据库不存在或备份失败"
    fi
  else
    log "MariaDB服务未运行，跳过数据库备份"
  fi
}

backup_config() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local config_backup="$BACKUP_DIR/config_${timestamp}.tar.gz"
  
  log "备份配置文件"
  
  # 构建要备份的目录和文件列表
  local backup_items=()
  
  # 检查并添加存在的目录和文件
  [[ -d "/etc/postfix" ]] && backup_items+=("/etc/postfix")
  [[ -d "/etc/dovecot" ]] && backup_items+=("/etc/dovecot")
  [[ -d "/etc/httpd" ]] && backup_items+=("/etc/httpd")
  [[ -f "/etc/systemd/system/mail-ops-dispatcher.service" ]] && backup_items+=("/etc/systemd/system/mail-ops-dispatcher.service")
  [[ -d "/var/log/mail-ops" ]] && backup_items+=("/var/log/mail-ops")
  
  if [[ ${#backup_items[@]} -gt 0 ]]; then
    tar -czf "$config_backup" "${backup_items[@]}" || true
    log "配置文件备份完成: $config_backup"
  else
    log "没有找到要备份的配置文件"
  fi
}

backup_maildir() {
  local timestamp=$(date +%Y%m%d_%H%M%S)
  local maildir_backup="$BACKUP_DIR/maildir_${timestamp}.tar.gz"
  
  log "备份邮件目录"
  if [[ -d "/var/vmail" ]]; then
    tar -czf "$maildir_backup" /var/vmail || true
    log "邮件目录备份完成: $maildir_backup"
  else
    log "邮件目录 /var/vmail 不存在，跳过邮件目录备份"
  fi
}

cleanup_old_backups() {
  log "清理超过 ${RETENTION_DAYS} 天的备份"
  find "$BACKUP_DIR" -name "*.gz" -mtime +${RETENTION_DAYS} -delete || true
}

full_backup() {
  ensure_backup_dir
  backup_database
  backup_config
  backup_maildir
  cleanup_old_backups
  
  # 显示备份结果统计
  local backup_count=$(find "$BACKUP_DIR" -name "*.gz" | wc -l)
  local backup_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "未知")
  
  log "完整备份完成"
  log "备份文件数量: $backup_count"
  log "备份目录大小: $backup_size"
  log "备份目录位置: $BACKUP_DIR"
}

restore_database() {
  local backup_file="$2"
  [[ -f "$backup_file" ]] || { echo "备份文件不存在: $backup_file" >&2; exit 1; }
  
  log "恢复数据库: $backup_file"
  gunzip -c "$backup_file" | mysql -u root || true
}

setup_cron() {
  log "设置定时备份"
  cat > /etc/cron.d/mail-backup <<CRON
# 每日凌晨 2 点执行完整备份
0 2 * * * root $0 full-backup
CRON
}

setup_backup_cron() {
  local interval=${1:-7}
  local database=${2:-true}
  local config=${3:-true}
  local maildir=${4:-true}
  local retention=${5:-7}
  local custom_time=${6:-false}
  local custom_hour=${7:-2}
  local custom_minute=${8:-0}
  local custom_second=${9:-0}
  
  log "设置自定义定时备份"
  log "备份间隔: ${interval}天"
  log "备份内容: 数据库=${database}, 配置=${config}, 邮件目录=${maildir}"
  log "保留时间: ${retention}天"
  
  # 创建自定义备份脚本
  local backup_script="/usr/local/bin/mail-backup-custom.sh"
  
  cat > "$backup_script" <<SCRIPT
#!/bin/bash
# 自定义邮件系统备份脚本
# 生成时间: $(date)
# 备份间隔: ${interval}天
# 保留时间: ${retention}天

BACKUP_DIR="/var/backups/mail"
RETENTION_DAYS=${retention}

# 确保备份目录存在
mkdir -p "\$BACKUP_DIR"

# 备份数据库
if [[ "${database}" == "true" ]]; then
  echo "[backup] 备份数据库"
  if systemctl is-active --quiet mariadb; then
    timestamp=\$(date +%Y%m%d_%H%M%S)
    mysqldump -u root --all-databases > "\$BACKUP_DIR/maildb_\${timestamp}.sql" 2>/dev/null && gzip "\$BACKUP_DIR/maildb_\${timestamp}.sql" || true
  else
    echo "[backup] MariaDB服务未运行，跳过数据库备份"
  fi
fi

# 备份配置文件
if [[ "${config}" == "true" ]]; then
  echo "[backup] 备份配置文件"
  timestamp=\$(date +%Y%m%d_%H%M%S)
  config_backup="\$BACKUP_DIR/config_\${timestamp}.tar.gz"
  
  backup_items=()
  [[ -d "/etc/postfix" ]] && backup_items+=("/etc/postfix")
  [[ -d "/etc/dovecot" ]] && backup_items+=("/etc/dovecot")
  [[ -d "/etc/httpd" ]] && backup_items+=("/etc/httpd")
  [[ -f "/etc/systemd/system/mail-ops-dispatcher.service" ]] && backup_items+=("/etc/systemd/system/mail-ops-dispatcher.service")
  [[ -d "/var/log/mail-ops" ]] && backup_items+=("/var/log/mail-ops")
  
  if [[ \${#backup_items[@]} -gt 0 ]]; then
    tar -czf "\$config_backup" "\${backup_items[@]}" || true
    echo "[backup] 配置文件备份完成: \$config_backup"
  else
    echo "[backup] 没有找到要备份的配置文件"
  fi
fi

# 备份邮件目录
if [[ "${maildir}" == "true" ]]; then
  echo "[backup] 备份邮件目录"
  if [[ -d "/var/vmail" ]]; then
    timestamp=\$(date +%Y%m%d_%H%M%S)
    maildir_backup="\$BACKUP_DIR/maildir_\${timestamp}.tar.gz"
    tar -czf "\$maildir_backup" /var/vmail || true
    echo "[backup] 邮件目录备份完成: \$maildir_backup"
  else
    echo "[backup] 邮件目录 /var/vmail 不存在，跳过邮件目录备份"
  fi
fi

# 清理旧备份
echo "[backup] 清理超过 \${RETENTION_DAYS} 天的备份"
find "\$BACKUP_DIR" -name "*.gz" -mtime +\${RETENTION_DAYS} -delete || true

echo "[backup] 自定义备份完成"
SCRIPT

  chmod +x "$backup_script"
  
  # 计算cron表达式（精确到秒）
  local cron_schedule
  local exec_second
  local exec_minute
  local exec_hour
  
  # 检查是否使用自定义时间
  if [[ "$custom_time" == "true" ]]; then
    exec_second="$custom_second"
    exec_minute="$custom_minute"
    exec_hour="$custom_hour"
    log "使用自定义执行时间: ${exec_hour}:${exec_minute}:${exec_second}"
  else
    # 获取当前时间的秒数，用于错开执行时间
    exec_second=$(date +%S)
    exec_minute=$(date +%M)
    exec_hour=$(date +%H)
    log "使用当前时间: ${exec_hour}:${exec_minute}:${exec_second}"
  fi
  
  if [[ "$interval" == "1" ]]; then
    # 每天执行
    cron_schedule="${exec_second} ${exec_minute} ${exec_hour} * * *"
  elif [[ "$interval" == "3" ]]; then
    # 每3天执行
    cron_schedule="${exec_second} ${exec_minute} ${exec_hour} */3 * *"
  elif [[ "$interval" == "7" ]]; then
    # 每周执行（周日）
    cron_schedule="${exec_second} ${exec_minute} ${exec_hour} * * 0"
  elif [[ "$interval" == "30" ]]; then
    # 每月执行（每月1号）
    cron_schedule="${exec_second} ${exec_minute} ${exec_hour} 1 * *"
  else
    # 自定义天数，使用每N天执行
    cron_schedule="${exec_second} ${exec_minute} ${exec_hour} */${interval} * *"
  fi
  
  # 清理旧的cron任务文件
  if [[ -f /etc/cron.d/mail-backup-custom ]]; then
    log "清理旧的cron任务文件"
    rm -f /etc/cron.d/mail-backup-custom
  fi
  
  # 创建cron任务
  {
    echo "# 自定义邮件系统备份任务"
    echo "# 备份间隔: ${interval}天"
    echo "# 生成时间: $(date)"
    if [[ "$custom_time" == "true" ]]; then
      echo "# 执行时间: 每天 ${exec_hour}:${exec_minute}:${exec_second} (自定义)"
    else
      echo "# 执行时间: 每天 ${exec_hour}:${exec_minute}:${exec_second} (当前时间)"
    fi
    echo "${cron_schedule} root ${backup_script}"
  } > /etc/cron.d/mail-backup-custom

  # 设置正确的权限
  chmod 644 /etc/cron.d/mail-backup-custom
  
  # 重启cron服务以加载新任务
  systemctl restart crond 2>/dev/null || systemctl restart cron 2>/dev/null || true
  
  # 验证cron任务是否创建成功
  if [[ -f /etc/cron.d/mail-backup-custom ]]; then
    log "自定义定时备份设置完成"
    log "Cron表达式: ${cron_schedule}"
    log "备份脚本: ${backup_script}"
    log "备份目录: ${BACKUP_DIR}"
    log "保留时间: ${retention}天"
    log "Cron任务文件: /etc/cron.d/mail-backup-custom"
    
    # 显示cron任务内容
    log "Cron任务内容:"
    cat /etc/cron.d/mail-backup-custom | while read line; do
      log "  $line"
    done
    
    # 立即执行一次备份
    log "立即执行首次备份..."
    if bash "$backup_script"; then
      log "首次备份执行成功"
    else
      log "首次备份执行失败，请检查备份脚本"
    fi
  else
    log "警告: Cron任务文件创建失败"
  fi
}

check_backup_status() {
  log "检查备份状态"
  
  if [[ -d "$BACKUP_DIR" ]]; then
    local backup_count=$(find "$BACKUP_DIR" -name "*.gz" | wc -l)
    local backup_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "未知")
    local latest_backup=$(find "$BACKUP_DIR" -name "*.gz" -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2- || echo "无")
    
    log "备份目录: $BACKUP_DIR"
    log "备份文件数量: $backup_count"
    log "备份目录大小: $backup_size"
    log "最新备份: $latest_backup"
    
    if [[ $backup_count -gt 0 ]]; then
      log "备份状态: 正常"
    else
      log "备份状态: 无备份文件"
    fi
  else
    log "备份目录不存在: $BACKUP_DIR"
    log "备份状态: 未初始化"
  fi
}

case "$ACTION" in
  full-backup)
    full_backup ;;
  restore-db)
    [[ $# -eq 2 ]] || { echo "用法: $0 restore-db <backup_file>" >&2; exit 2; }
    restore_database "$@" ;;
  setup-cron)
    setup_cron ;;
  setup-backup-cron)
    # 跳过第一个参数（setup-backup-cron），传递其余参数
    shift
    setup_backup_cron "$@" ;;
  check-status)
    check_backup_status ;;
  *)
    echo "用法: $0 {full-backup|restore-db <file>|setup-cron|setup-backup-cron <interval> <database> <config> <maildir> <retention>|check-status}" >&2
    exit 2 ;;
esac
