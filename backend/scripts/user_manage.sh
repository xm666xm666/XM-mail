#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: user_manage.sh
# 工作职责: 用户与域名管理脚本 - 负责邮件用户的创建、删除和域名管理
#           通过调度层API调用，提供邮件账户和域名的CRUD操作
# 系统组件: XM邮件管理系统 - 用户管理模块
# ============================================================================
# 用法说明:
#   user_manage.sh <action> [参数...]
#   user_manage.sh domain-add <域名>               - 添加邮件域名到virtual_domains表
#   user_manage.sh user-add <邮箱> <密码>         - 创建新的邮件用户账户（virtual_users表）
#   user_manage.sh user-del <邮箱>                - 删除邮件用户账户（从virtual_users表）
#
# 功能描述:
#   - 域名管理：添加邮件域名到virtual_domains表（Postfix虚拟域名）
#   - 用户管理：创建、删除邮件用户账户（Postfix虚拟用户）
#   - 密码管理：使用SHA512-CRYPT加密存储用户密码（通过doveadm或openssl）
#   - 邮件目录：自动创建用户的Maildir格式邮件目录（/var/vmail/域名/用户名/Maildir）
#   - 权限设置：自动设置邮件目录权限（vmail:mail, 700）
#   - 用户同步：确保vmail用户和mail组存在
#
# 数据库操作:
#   - virtual_domains表：Postfix虚拟域名表（自动创建不存在的域名）
#   - virtual_users表：Postfix虚拟用户表（关联域名，存储加密密码）
#   - 邮件目录：/var/vmail/<域名>/<用户名>/Maildir（new, cur, tmp子目录）
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表（virtual_domains, virtual_users, virtual_aliases）
#
# 依赖关系:
#   - MariaDB数据库（maildb）
#   - Postfix（邮件服务器）
#   - 调度层API（通过sudo调用）
#   - 密码文件：/etc/mail-ops/mail-db.pass（优先读取，向后兼容默认值）
#
# 注意事项:
#   - 需要root权限或sudo权限执行
#   - 通过调度层API调用，不直接在前端使用
#   - 删除用户会同时删除相关邮件数据
#   - 密码以SHA512-CRYPT加密形式存储
#   - 支持从密码文件读取数据库密码，向后兼容默认值
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

set -euo pipefail

log() { echo "[user_manage] $*" >&1; }

# 权限检查
require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "警告: 当前用户不是 root，某些操作可能失败" >&1
    echo "建议: 使用 sudo 运行此脚本或切换到 root 用户" >&1
  fi
}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: user_manage.sh $*" >&1
echo "当前时间: $(date)" >&1
echo "当前用户: $(whoami)" >&1
echo "当前目录: $(pwd)" >&1

# 检查权限
require_root

DB_NAME=${DB_NAME:-maildb}
DB_USER=${DB_USER:-mailuser}
# 从密码文件读取密码，如果文件不存在则使用默认值（向后兼容）
if [[ -f /etc/mail-ops/mail-db.pass ]]; then
  DB_PASS=${DB_PASS:-$(cat /etc/mail-ops/mail-db.pass)}
else
DB_PASS=${DB_PASS:-mailpass}
fi

mysql_exec() {
  mysql -u"${DB_USER}" -p"${DB_PASS}" -D"${DB_NAME}" -e "$1"
}

sha512_crypt() {
  if command -v doveadm >/dev/null 2>&1; then
    doveadm pw -s SHA512-CRYPT -p "$1"
  else
    # 简易回退：不是完全等价，仅用于占位
    openssl passwd -6 "$1"
  fi
}

ensure_domain() {
  local domain="$1"
  mysql_exec "INSERT IGNORE INTO virtual_domains(name) VALUES ('$domain');"
}

user_add() {
  local email="$1"; local plain="$2"
  local domain="${email#*@}"
  local username="${email%%@*}"
  ensure_domain "$domain"
  local dom_id
  dom_id=$(mysql -u"${DB_USER}" -p"${DB_PASS}" -N -B -D"${DB_NAME}" -e "SELECT id FROM virtual_domains WHERE name='${domain}' LIMIT 1;")
  if [[ -z "$dom_id" ]]; then
    echo "找不到域: ${domain}" >&2; exit 2
  fi
  local hash
  hash=$(sha512_crypt "$plain")
  mysql_exec "INSERT INTO virtual_users(domain_id,email,password,active) VALUES (${dom_id},'${email}','${hash}',1) ON DUPLICATE KEY UPDATE password='${hash}', active=1;"
  log "用户已创建/更新：$email"
  
  # 创建邮件目录（Maildir格式）
  local mail_dir="/var/vmail/${domain}/${username}/Maildir"
  local mail_parent="/var/vmail/${domain}/${username}"
  
  # 确保vmail用户存在
  id vmail &>/dev/null || useradd -r -u 150 -g mail -d /var/vmail -s /sbin/nologin vmail || true
  
  # 创建邮件目录
  if [[ ! -d "$mail_dir" ]]; then
    log "创建邮件目录: $mail_dir"
    mkdir -p "$mail_dir/new" "$mail_dir/cur" "$mail_dir/tmp" 2>/dev/null || {
      log "警告: 无法创建邮件目录 $mail_dir，可能需要root权限"
      return 0  # 不阻止用户创建，目录可能稍后创建
    }
    
    # 设置权限
    chown -R vmail:mail "$mail_parent" 2>/dev/null || true
    chmod 700 "$mail_parent" 2>/dev/null || true
    chmod 700 "$mail_dir" 2>/dev/null || true
    chmod 700 "$mail_dir/new" "$mail_dir/cur" "$mail_dir/tmp" 2>/dev/null || true
    
    log "邮件目录创建成功: $mail_dir"
  else
    log "邮件目录已存在: $mail_dir"
    # 确保权限正确
    chown -R vmail:mail "$mail_parent" 2>/dev/null || true
    chmod 700 "$mail_parent" 2>/dev/null || true
  fi
}

user_del() {
  local email="$1"
  mysql_exec "DELETE FROM virtual_users WHERE email='${email}';"
  log "用户已删除（若存在）：$email"
}

domain_add() {
  ensure_domain "$1"
  log "域已创建/存在：$1"
}

case "${1:-help}" in
  domain-add)
    [[ $# -eq 2 ]] || { echo "用法: $0 domain-add <domain>" >&2; exit 2; }
    domain_add "$2" ;;
  user-add)
    [[ $# -eq 3 ]] || { echo "用法: $0 user-add <email> <password>" >&2; exit 2; }
    user_add "$2" "$3" ;;
  user-del)
    [[ $# -eq 2 ]] || { echo "用法: $0 user-del <email>" >&2; exit 2; }
    user_del "$2" ;;
  *)
    echo "用法: $0 {domain-add|user-add|user-del}" >&2; exit 2 ;;
esac


