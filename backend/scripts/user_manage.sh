#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: user_manage.sh
# 工作职责: Postfix 虚拟用户与域名管理 - 直接操作 MariaDB 与 Maildir
#           不通过 HTTP API，由 app_user.sh 或调度层 sudo 调用
# 系统组件: XM邮件管理系统 - 用户管理模块
# ============================================================================
# 用法说明:
#   user_manage.sh <action> [参数...]
#   user_manage.sh domain-add <域名>               - 添加邮件域名到 virtual_domains 表
#   user_manage.sh user-add <邮箱> <密码>         - 创建邮件用户（virtual_users + Maildir）
#   user_manage.sh user-del <邮箱>                - 删除邮件用户（virtual_users + Maildir）
#
# 功能描述:
#   - 域名管理：添加邮件域名到 virtual_domains 表
#   - 用户管理：创建、删除 Postfix 虚拟用户
#   - 密码管理：SHA512-CRYPT 加密（doveadm 或 openssl）
#   - 邮件目录：/var/vmail/%d/%n/Maildir（%d=域名，%n=用户名，new/cur/tmp 子目录）
#   - 权限设置：vmail:mail，700
#
# 数据库操作:
#   - virtual_domains、virtual_users 表（maildb）
#
# 依赖关系:
#   - MariaDB（maildb，直接 mysql CLI）
#   - Postfix、Dovecot
#   - 密码文件：/etc/mail-ops/mail-db.pass
#
# 注意事项:
#   - 需要 root 权限执行
#   - 直接 mysql + Maildir 操作，非 HTTP API
#   - 密码以 SHA512-CRYPT 形式存储
# ============================================================================

# 获取项目根目录（BASE_DIR），统一使用 BASE_DIR 规范路径
BASE_DIR=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)
if [[ -z "$BASE_DIR" ]]; then
  echo "错误: 无法确定项目根目录，请确保从项目目录运行或使用绝对路径调用脚本" >&2
  exit 1
fi
cd "$BASE_DIR" 2>/dev/null || true

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
  local domain="${email#*@}"
  local username="${email%%@*}"
  
  mysql_exec "DELETE FROM virtual_users WHERE email='${email}';"
  log "用户已删除（若存在）：$email"
  
  # 删除 Maildir 目录以释放磁盘空间
  local mail_dir="/var/vmail/${domain}/${username}"
  if [[ -d "$mail_dir" ]]; then
    rm -rf "$mail_dir" 2>/dev/null && log "已删除邮件目录: $mail_dir" || log "警告: 无法删除 $mail_dir"
  fi
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


