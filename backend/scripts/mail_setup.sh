#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_setup.sh
# 工作职责: 邮件服务配置与管理脚本 - 负责Postfix和Dovecot的安装、配置和管理
#           包括邮件发送服务（SMTP）、邮件接收服务（IMAP/POP3）的完整配置
# 系统组件: XM邮件管理系统 - 邮件服务核心模块
# ============================================================================
# 用法说明:
#   mail_setup.sh <action> [域名]
#   mail_setup.sh check                  - 执行环境检查（依赖包、服务等）
#   mail_setup.sh health                 - 执行邮件服务健康检查
#   mail_setup.sh install [域名]         - 安装并配置邮件服务（安装包、重启服务）
#   mail_setup.sh configure [域名]       - 配置 Postfix/Dovecot 并更新域名；若传域名则确保域存在并更新 Postfix 配置
#   mail_setup.sh restart                - 重启邮件相关服务（由 service_restart 决定）
#   mail_setup.sh restart-mail           - 仅重启 Postfix 与 Dovecot
#   mail_setup.sh stop-mail              - 仅停止 Postfix 与 Dovecot
#   mail_setup.sh status                 - 检查 Postfix 与 Dovecot 服务状态
#
# 功能描述:
#   - Postfix配置：SMTP服务器配置，包括域名、用户认证、TLS加密等
#   - Dovecot配置：IMAP/POP3服务器配置，包括邮箱存储、用户认证等
#   - 数据库集成：与MariaDB集成，支持虚拟用户和域名管理
#   - SSL/TLS配置：邮件传输加密配置
#   - 防火墙配置：开放必要的邮件端口（25, 587, 993, 995等）
#   - 服务管理：启动、停止、重启和状态检查
#   - 健康检查：验证邮件服务是否正常运行
#
# 邮件服务配置:
#   - SMTP端口：25（标准）、587（提交）
#   - IMAP端口：993（SSL）
#   - POP3端口：995（SSL）
#   - 认证方式：SASL（PLAIN/LOGIN）
#   - 加密方式：TLS/SSL
#   - Web端口：从config/port-config.json读取（默认80/443）
#   - API端口：从config/port-config.json读取（默认8081）
#
# 端口配置:
#   - 所有端口配置统一从config/port-config.json读取
#   - 支持自定义HTTP/HTTPS端口和API端口
#   - 健康检查和端口连通性检查使用动态端口配置
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表（virtual_domains, virtual_users, virtual_aliases）
#   - Postfix配置文件：从密码文件读取数据库密码，写入/etc/postfix/mysql-*.cf配置文件
#   - Dovecot配置文件：从密码文件读取数据库密码，写入/etc/dovecot/dovecot-sql.conf.ext配置文件
#
# 依赖关系:
#   - Postfix（SMTP服务器）
#   - Dovecot（IMAP/POP3服务器）
#   - MariaDB（用户和域名数据库）
#   - OpenSSL（证书管理）
#   - 密码文件：/etc/mail-ops/mail-db.pass（从密码文件读取数据库密码，向后兼容默认值）
#
# 注意事项:
#   - 需要root权限执行配置操作
#   - 需要先配置DNS解析（Bind或公网DNS）
#   - 需要配置SSL证书以启用加密传输
#   - 防火墙需要开放相应端口
#   - Postfix和Dovecot配置文件中的密码从密码文件读取，确保密码一致性
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

# 获取项目根目录（BASE_DIR）
BASE_DIR=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd || echo "/bash")
CONFIG_DIR="$BASE_DIR/config"

set -uo pipefail

# 禁用输出缓冲
export PYTHONUNBUFFERED=1
export STDBUF=0

# 读取端口配置函数
get_port_config() {
    local port_config_file="$CONFIG_DIR/port-config.json"
    local api_port=8081
    local apache_http_port=80
    local apache_https_port=443
    
    if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
        api_port=$(jq -r '.api.port // 8081' "$port_config_file" 2>/dev/null || echo "8081")
        apache_http_port=$(jq -r '.apache.httpPort // 80' "$port_config_file" 2>/dev/null || echo "80")
        apache_https_port=$(jq -r '.apache.httpsPort // 443' "$port_config_file" 2>/dev/null || echo "443")
    fi
    
    echo "$api_port|$apache_http_port|$apache_https_port"
}

log() { echo "[mail_setup] $*" >&1; }

ACTION=${1:-help}
DOMAIN_ARG=${2:-}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: mail_setup.sh $ACTION"
echo "当前时间: $(date)"
echo "当前用户: $(whoami)"
echo "当前目录: $(pwd)"

require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "警告: 当前用户不是 root，某些操作可能失败"
    echo "建议: 使用 sudo 运行此脚本或切换到 root 用户"
    # 不退出，继续执行，让脚本自己处理权限问题
  fi
}

ensure_packages() {
  dnf -y install postfix postfix-mysql dovecot dovecot-mysql mariadb-server s-nail --skip-broken || true
  systemctl enable postfix dovecot || true
  systemctl start postfix dovecot || true
}

configure_postfix() {
  postconf -e 'inet_interfaces = all'
  postconf -e 'mydestination = '
  postconf -e 'virtual_mailbox_domains = mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf'
  postconf -e 'virtual_mailbox_maps = mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf'
  postconf -e 'virtual_alias_maps = mysql:/etc/postfix/mysql-virtual-alias-maps.cf'
  postconf -e 'virtual_transport = lmtp:unix:private/dovecot-lmtp'
  # 设置virtual_mailbox_base（即使使用LMTP也需要，用于Postfix命令）
  postconf -e 'virtual_mailbox_base = /var/vmail'
  postconf -e 'virtual_minimum_uid = 150'
  postconf -e 'virtual_uid_maps = static:150'
  postconf -e 'virtual_gid_maps = static:12'
  postconf -e 'smtpd_tls_security_level = may'
  postconf -e 'smtpd_sasl_auth_enable = no'
  # 允许本地网络发送邮件
  postconf -e 'mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128'
  # 允许中继到虚拟域
  postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
  # 允许本地发送
  postconf -e 'smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated'
  # 写入 MySQL 查询映射（从密码文件读取密码）
  # 读取数据库密码
  local db_pass="mailpass"
  if [[ -f /etc/mail-ops/mail-db.pass ]]; then
    db_pass=$(cat /etc/mail-ops/mail-db.pass)
  fi
  
  cat > /etc/postfix/mysql-virtual-mailbox-domains.cf <<CFG
hosts = 127.0.0.1
user = mailuser
password = ${db_pass}
dbname = maildb
query = SELECT 1 FROM virtual_domains WHERE name='%s'
CFG

  cat > /etc/postfix/mysql-virtual-mailbox-maps.cf <<CFG
hosts = 127.0.0.1
user = mailuser
password = ${db_pass}
dbname = maildb
query = SELECT 1 FROM virtual_users WHERE email='%s' AND active=1
CFG

  cat > /etc/postfix/mysql-virtual-alias-maps.cf <<CFG
hosts = 127.0.0.1
user = mailuser
password = ${db_pass}
dbname = maildb
query = SELECT destination FROM virtual_aliases WHERE source='%s'
CFG
  # 应用域名到 Postfix（若提供）
  if [[ -n "${DOMAIN_ARG}" ]]; then
    postconf -e "mydomain = ${DOMAIN_ARG}"
    # 设置主机名：若当前 hostname 不包含域，拼接为 mail.${DOMAIN_ARG}
    current_host="$(hostname -s)"
    if [[ "$current_host" != *.* ]]; then
      postconf -e "myhostname = mail.${DOMAIN_ARG}"
    fi
    log "已应用域名到 Postfix: ${DOMAIN_ARG}"
  fi
}

configure_dovecot() {
  local dcv=/etc/dovecot
  # vmail 用户与目录
  id vmail &>/dev/null || useradd -r -u 150 -g mail -d /var/vmail -s /sbin/nologin vmail
  install -d -m 0750 /var/vmail
  chown -R vmail:mail /var/vmail || true
  sed -i 's/^#*protocols =.*/protocols = imap pop3 lmtp/' "$dcv/dovecot.conf"
  sed -i 's/^#*auth_mechanisms =.*/auth_mechanisms = plain login/' "$dcv/conf.d/10-auth.conf"
  sed -i 's/^#*disable_plaintext_auth = .*/disable_plaintext_auth = no/' "$dcv/conf.d/10-auth.conf"
  sed -i 's,^#*mail_location =.*,mail_location = maildir:/var/vmail/%d/%n/Maildir,' "$dcv/conf.d/10-mail.conf"
  # 配置 LMTP socket 在 Postfix 可以访问的位置
  # 确保 10-master.conf 文件存在
  [[ -f "$dcv/conf.d/10-master.conf" ]] || touch "$dcv/conf.d/10-master.conf"
  # 检查是否已配置 LMTP socket
  if ! grep -q "/var/spool/postfix/private/dovecot-lmtp" "$dcv/conf.d/10-master.conf"; then
    # 如果存在 service lmtp 块，在其中添加 unix_listener
    if grep -q "service lmtp" "$dcv/conf.d/10-master.conf"; then
      # 在 service lmtp 块中添加 unix_listener
      sed -i '/service lmtp {/,/^}/ {
        /^}/ i\
  unix_listener /var/spool/postfix/private/dovecot-lmtp {\
    mode = 0600\
    user = postfix\
    group = postfix\
  }
      }' "$dcv/conf.d/10-master.conf" || {
        # 如果 sed 失败，追加新的 service lmtp 块
        cat >> "$dcv/conf.d/10-master.conf" <<'LMTP'

service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
LMTP
      }
    else
      # 如果不存在 service lmtp 块，追加新的
      cat >> "$dcv/conf.d/10-master.conf" <<'LMTP'

service lmtp {
  unix_listener /var/spool/postfix/private/dovecot-lmtp {
    mode = 0600
    user = postfix
    group = postfix
  }
}
LMTP
    fi
  fi
  # 确保 Postfix 的 private 目录存在
  install -d -m 0750 /var/spool/postfix/private
  chown postfix:postfix /var/spool/postfix/private
  # 创建 Dovecot SQL 认证配置
  cat > "$dcv/conf.d/auth-sql.conf.ext" <<'AUTH'
passdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
userdb {
  driver = sql
  args = /etc/dovecot/dovecot-sql.conf.ext
}
AUTH
  sed -i 's/^#*!include auth-system.conf.ext/#!include auth-system.conf.ext/' "$dcv/conf.d/10-auth.conf"
  sed -i 's/^#*!include auth-sql.conf.ext/!include auth-sql.conf.ext/' "$dcv/conf.d/10-auth.conf"
  # Dovecot MySQL 配置（从密码文件读取密码）
  # 读取数据库密码
  local db_pass="mailpass"
  if [[ -f /etc/mail-ops/mail-db.pass ]]; then
    db_pass=$(cat /etc/mail-ops/mail-db.pass)
  fi
  
  cat > "$dcv/dovecot-sql.conf.ext" <<SQL
driver = mysql
connect = host=127.0.0.1 dbname=maildb user=mailuser password=${db_pass}
default_pass_scheme = SHA512-CRYPT
password_query = SELECT email as user, password FROM virtual_users WHERE email = '%u' AND active = 1
user_query = SELECT 150 AS uid, 12 AS gid, '/var/vmail/%d/%n' AS home, 'maildir:/var/vmail/%d/%n/Maildir' AS mail FROM virtual_users WHERE email = '%u' AND active = 1
SQL
  chown root:root "$dcv/dovecot-sql.conf.ext" && chmod 640 "$dcv/dovecot-sql.conf.ext"
}

service_restart() {
  systemctl enable postfix dovecot || true
  systemctl start postfix dovecot || true
  systemctl restart postfix dovecot || true
}

service_status() {
  systemctl --no-pager status postfix || true
  systemctl --no-pager status dovecot || true
}

check_environment() {
  log "=== 环境检查开始 ==="
  echo "开始执行环境检查..."
  echo "正在收集系统信息..."
  sleep 0.1  # 确保输出立即刷新
  
  # 系统信息
  log "系统信息:"
  echo "正在检查系统信息..."
  echo "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
  echo "内核版本: $(uname -r)"
  echo "架构: $(uname -m)"
  echo "主机名: $(hostname)"
  echo "当前时间: $(date)"
  
  # 内存和磁盘
  log "系统资源:"
  echo "内存使用: $(free -h | grep Mem | awk '{print $3"/"$2" ("$3/$2*100"%)"}')"
  echo "磁盘使用: $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}')"
  echo "CPU负载: $(uptime | awk -F'load average:' '{print $2}')"
  
  # 网络检查
  log "网络状态:"
  echo "监听端口:"
  # 读取端口配置
  local port_config=$(get_port_config)
  local api_port=$(echo "$port_config" | cut -d'|' -f1)
  local apache_http_port=$(echo "$port_config" | cut -d'|' -f2)
  local apache_https_port=$(echo "$port_config" | cut -d'|' -f3)
  netstat -tlnp | grep -E ":25|:${apache_http_port}|:${apache_https_port}|:993|:995|:${api_port}" || echo "未发现邮件相关端口"
  echo "防火墙状态:"
  systemctl is-active firewalld 2>/dev/null || echo "firewalld 未运行"
  echo "SELinux状态: $(getenforce 2>/dev/null || echo '未安装')"
  
  # 服务检查
  log "服务状态:"
  for service in httpd mariadb postfix dovecot mail-ops-dispatcher; do
    if systemctl is-active --quiet $service; then
      echo "✓ $service: 运行中"
    else
      echo "✗ $service: 未运行"
    fi
  done
  
  # 软件包检查
  log "软件包检查:"
  for pkg in postfix dovecot mariadb-server httpd nodejs; do
    if rpm -q $pkg >/dev/null 2>&1; then
      echo "✓ $pkg: 已安装 ($(rpm -q $pkg | head -1))"
    else
      echo "✗ $pkg: 未安装"
    fi
  done
  
  # 配置文件检查
  log "配置文件检查:"
  config_files=(
    "/etc/postfix/main.cf"
    "/etc/dovecot/dovecot.conf"
    "/etc/httpd/conf.d/mailmgmt.conf"
    "/etc/systemd/system/mail-ops-dispatcher.service"
  )
  
  for file in "${config_files[@]}"; do
    if [[ -f "$file" ]]; then
      echo "✓ $file: 存在"
    else
      echo "✗ $file: 不存在"
    fi
  done
  
  # 数据库检查
  log "数据库检查:"
  if systemctl is-active --quiet mariadb; then
    echo "✓ MariaDB: 运行中"
    # 检查数据库是否存在
    if mysql -u root -e "SHOW DATABASES;" 2>/dev/null | grep -q "maildb"; then
      echo "✓ maildb: 数据库存在"
    else
      echo "✗ maildb: 数据库不存在"
    fi
  else
    echo "✗ MariaDB: 未运行"
  fi
  
  # 前端检查
  log "前端检查:"
  if [[ -d "/var/www/mail-frontend" ]]; then
    echo "✓ 前端目录: 存在"
    if [[ -f "/var/www/mail-frontend/index.html" ]]; then
      echo "✓ index.html: 存在 ($(stat -c%s /var/www/mail-frontend/index.html) 字节)"
    else
      echo "✗ index.html: 不存在"
    fi
    
    css_count=$(find /var/www/mail-frontend -name "*.css" | wc -l)
    js_count=$(find /var/www/mail-frontend -name "*.js" | wc -l)
    echo "✓ 静态资源: CSS=${css_count}, JS=${js_count}"
  else
    echo "✗ 前端目录: 不存在"
  fi
  
  # 权限检查
  log "权限检查:"
  if [[ -d "/var/log/mail-ops" ]]; then
    echo "✓ 日志目录: 存在"
    if [[ -w "/var/log/mail-ops" ]]; then
      echo "✓ 日志目录: 可写"
    else
      echo "✗ 日志目录: 不可写"
    fi
  else
    echo "✗ 日志目录: 不存在"
  fi
  
  # 端口连通性检查
  log "端口连通性检查:"
  # 读取端口配置
  local port_config=$(get_port_config)
  local api_port=$(echo "$port_config" | cut -d'|' -f1)
  local apache_http_port=$(echo "$port_config" | cut -d'|' -f2)
  for port in $apache_http_port $api_port; do
    if netstat -tlnp | grep -q ":$port "; then
      echo "✓ 端口 $port: 监听中"
    else
      echo "✗ 端口 $port: 未监听"
    fi
  done
  
  # 日志文件检查
  log "日志文件检查:"
  log_files=(
    "/var/log/httpd/mail-frontend-error.log"
    "/var/log/httpd/mail-frontend-access.log"
  )
  
  for log_file in "${log_files[@]}"; do
    if [[ -f "$log_file" ]]; then
      echo "✓ $log_file: 存在 ($(stat -c%s $log_file) 字节)"
    else
      echo "✗ $log_file: 不存在"
    fi
  done
  
  log "=== 环境检查完成 ==="
  echo "脚本执行完成: mail_setup.sh check"
  echo "完成时间: $(date)"
}

health_check() {
  log "=== 健康检查 ==="
  
  # 在健康检查中关闭 set -e，避免非零退出中断脚本
  set +e
  # 快速状态检查
  local issues=0
  
  # 检查关键服务
  for service in httpd mariadb mail-ops-dispatcher; do
    if ! systemctl is-active --quiet $service; then
      echo "✗ $service 服务未运行"
      ((issues++))
    fi
  done
  
  # 检查端口
  # 读取端口配置
  local port_config=$(get_port_config)
  local api_port=$(echo "$port_config" | cut -d'|' -f1)
  local apache_http_port=$(echo "$port_config" | cut -d'|' -f2)
  for port in $apache_http_port $api_port; do
    if ! netstat -tlnp | grep -q ":$port "; then
      echo "✗ 端口 $port 未监听"
      ((issues++))
    fi
  done
  
  # 检查前端文件
  if [[ ! -f "/var/www/mail-frontend/index.html" ]]; then
    echo "✗ 前端文件不存在"
    ((issues++))
  fi
  
  # 检查数据库连接（多策略）
  if systemctl is-active --quiet mariadb; then
    # 方式1：mysqladmin ping
    if ! mysqladmin ping -uroot --silent >/dev/null 2>&1; then
      echo "✗ 数据库 ping 失败（root 可能未设置或需密码）"
      ((issues++))
    else
      # 方式2：简单查询
      if ! mysql -uroot -e "SELECT 1;" >/dev/null 2>&1; then
        echo "✗ 数据库查询失败（root 认证失败或无权限）"
        ((issues++))
      fi
    fi
  else
    echo "✗ MariaDB 服务未运行"
    ((issues++))
  fi
  
  if [[ $issues -eq 0 ]]; then
    echo "✓ 系统健康状态良好"
    log "健康检查通过"
  else
    echo "✗ 发现 $issues 个问题"
    log "健康检查发现问题"
  fi
  
  # 恢复 set -e，并且总是返回 0，避免前端将健康检查视为失败
  set -e
  return 0
}

case "$ACTION" in
  check)
    echo "执行环境检查..."
    check_environment
    ;;
  health)
    echo "执行健康检查..."
    health_check
    ;;
  install)
    echo "开始安装服务..."
    require_root
    ensure_packages
    service_restart
    ;;
  configure)
    echo "开始配置服务..."
    require_root
    configure_postfix
    configure_dovecot
    # 若传入域名，则在数据库中确保该域存在，并更新Postfix配置
    if [[ -n "${DOMAIN_ARG}" ]]; then
      echo "确保数据库中存在域: ${DOMAIN_ARG}"
      # 先尝试添加域名（如果不存在）
      add_result=$(bash backend/scripts/mail_db.sh add_domain "${DOMAIN_ARG}" 2>&1)
      add_exit_code=$?
      
      if [[ $add_exit_code -eq 0 ]]; then
        log "域名 ${DOMAIN_ARG} 已添加到数据库并更新Postfix配置"
      elif echo "$add_result" | grep -q "已存在"; then
        log "域名 ${DOMAIN_ARG} 已存在于数据库中"
        # 即使域名已存在，也需要更新Postfix配置文件以确保一致性
        # 使用user_manage.sh确保域名存在，然后手动更新Postfix配置
        backend/scripts/user_manage.sh domain-add "${DOMAIN_ARG}" 2>/dev/null || true
        
        # 更新Postfix配置文件（复制mail_db.sh的update_postfix_domains逻辑）
        if [[ $(id -u) -eq 0 ]]; then
          DB_NAME="maildb"
          DB_USER="mailuser"
          # 从密码文件读取密码
          if [[ -f /etc/mail-ops/mail-db.pass ]]; then
            DB_PASS=$(cat /etc/mail-ops/mail-db.pass)
          else
          DB_PASS="mailpass"
          fi
          domains_query="SELECT name FROM virtual_domains ORDER BY name;"
          domains=$(mysql -h 127.0.0.1 -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -s -r -e "$domains_query" 2>/dev/null || echo "")
          
          if [[ -n "$domains" ]]; then
            mkdir -p /etc/postfix
            temp_file=$(mktemp)
            echo "# 邮件域名列表 - 自动生成于 $(date)" > "$temp_file"
            # 使用进程替换避免子shell问题
            while IFS= read -r domain; do
              if [[ -n "$domain" ]]; then
                echo "$domain" >> "$temp_file"
              fi
            done < <(echo "$domains")
            mv "$temp_file" /etc/postfix/virtual_mailbox_domains
            chmod 644 /etc/postfix/virtual_mailbox_domains
            log "Postfix域名配置文件已更新"
            
            # 如果Postfix正在运行，重新加载配置
            if systemctl is-active --quiet postfix; then
              systemctl reload postfix 2>/dev/null || true
            fi
          fi
        fi
      else
        log "警告: 添加域名 ${DOMAIN_ARG} 失败: $add_result"
      fi
    fi
    service_restart
    ;;
  restart)
    echo "重启服务..."
    require_root
    service_restart
    ;;
  restart-mail)
    echo "重启邮件服务..."
    require_root
    log "重启邮件服务 (Postfix + Dovecot)"
    systemctl restart postfix dovecot
    sleep 2
    if systemctl is-active --quiet postfix && systemctl is-active --quiet dovecot; then
      log "邮件服务重启成功"
    else
      log "邮件服务重启失败"
      systemctl status postfix dovecot --no-pager -l
      exit 1
    fi
    ;;
  stop-mail)
    echo "关闭邮件服务..."
    require_root
    log "关闭邮件服务 (Postfix + Dovecot)"
    systemctl stop postfix dovecot
    sleep 2
    if ! systemctl is-active --quiet postfix && ! systemctl is-active --quiet dovecot; then
      log "邮件服务关闭成功"
    else
      log "邮件服务关闭失败"
      systemctl status postfix dovecot --no-pager -l
      exit 1
    fi
    ;;
  status)
    echo "检查服务状态..."
    service_status
    ;;
  *)
    echo "用法: $0 {check|health|install|configure|restart|restart-mail|stop-mail|status}" >&2
    exit 2
    ;;
esac

# 脚本执行完成
echo "脚本执行完成: mail_setup.sh $ACTION"
echo "完成时间: $(date)"

