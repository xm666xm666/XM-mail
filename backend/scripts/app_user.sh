#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: app_user.sh
# 工作职责: 应用用户管理脚本 - 负责前端登录/注册/找回密码等用户账户管理功能
#           与邮局账户（mail users）分离，独立管理Web界面的用户认证体系
# 系统组件: XM邮件管理系统 - 用户认证模块
# ============================================================================
# 用法说明:
#   app_user.sh <action> [参数...]
#   app_user.sh init                          - 列出MySQL所有用户信息
#   app_user.sh schema                        - 初始化应用用户数据库表结构（app_users, app_accounts）
#   app_user.sh register <用户名> <邮箱> <密码> - 注册新用户（同时创建app_users和mail_users记录）
#   app_user.sh login <用户名> <密码>         - 用户登录验证（支持用户名或邮箱登录）
#   app_user.sh reset <用户名> <新密码>        - 重置用户密码
#   app_user.sh update <用户名> <邮箱> <密码> - 更新用户信息（不存在则创建）
#   app_user.sh query-users                   - 查询应用用户列表（JSON格式）
#   app_user.sh delete-user <邮箱>            - 删除应用用户（同时删除mail_users和邮件记录）
#   app_user.sh check-user-exists <用户名>    - 检查用户是否存在（检查app_users和mail_users表）
#
# 功能描述:
#   - 用户注册：创建新的应用用户账户（app_users表），同时同步到mail_users表
#   - 用户登录：验证用户凭据（支持用户名或邮箱登录），兼容app_users和app_accounts表
#   - 密码管理：密码使用SHA512哈希存储，不存储明文
#   - 用户查询：查询用户信息和状态，支持JSON格式输出
#   - 用户删除：删除应用用户时同步删除邮件系统用户和相关邮件记录
#   - 域名修复：批量修复用户邮箱域名，更新app_users、mail_users、virtual_users、email_recipients表
#   - 域名同步：注册用户时自动提取域名并添加到virtual_domains表
#
# 数据库表:
#   - app_users(id, username, email, pass_hash, avatar, created_at) - 应用用户主表（mailapp数据库）
#   - app_accounts(id, username, email, pass_hash, role, status, created_at) - 应用账户表（备用，mailapp数据库）
#   - mail_users(id, username, email, display_name, avatar, is_active, created_at) - 邮件系统用户表（同步，maildb数据库）
#   - virtual_domains(id, name) - 虚拟域名表（自动添加，maildb数据库）
#
# 数据库来源说明:
#   - mailapp数据库：由app_user.sh schema命令创建，包含应用用户表（app_users, app_accounts）
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表（virtual_domains, virtual_users等）
#   - maildb数据库：由mail_db.sh init命令创建邮件系统核心表（emails, email_folders等15张表）
#
# 依赖关系:
#   - MariaDB数据库（mailapp和maildb数据库）
#   - 环境变量：APP_DB_NAME, APP_DB_USER, APP_DB_PASS
#   - 密码文件：/etc/mail-ops/app-db.pass（应用数据库密码）
#   - 密码文件：/etc/mail-ops/mail-db.pass（邮件数据库密码，通过get_maildb_password函数读取）
#
# 注意事项:
#   - 需要root权限或sudo权限执行数据库操作
#   - 密码使用SHA512哈希存储，不存储明文
#   - 与邮局用户账户（maildb）分离但同步，注册时自动创建mail_users记录
#   - 支持从密码文件读取maildb数据库密码，向后兼容默认值
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

set -euo pipefail

DB_NAME=${APP_DB_NAME:-mailapp}
DB_USER=${APP_DB_USER:-mailappuser}
# 优先从秘密文件读取密码，其次读取环境变量，最后回退默认值
APP_DB_PASS_FILE_DEFAULT="/etc/mail-ops/app-db.pass"
if [[ -n "${APP_DB_PASS_FILE:-}" && -f "${APP_DB_PASS_FILE}" ]]; then
  DB_PASS=$(cat "${APP_DB_PASS_FILE}")
elif [[ -f "${APP_DB_PASS_FILE_DEFAULT}" ]]; then
  DB_PASS=$(cat "${APP_DB_PASS_FILE_DEFAULT}")
else
  DB_PASS=${APP_DB_PASS:-mailapppass}
fi

# 读取maildb数据库密码的函数
get_maildb_password() {
  if [[ -f /etc/mail-ops/mail-db.pass ]]; then
    cat /etc/mail-ops/mail-db.pass
  else
    echo "mailpass"  # 向后兼容默认值
  fi
}

log() { echo "[app_user] $*" >&1; }

# 权限检查
require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "警告: 当前用户不是 root，某些操作可能失败" >&1
    echo "建议: 使用 sudo 运行此脚本或切换到 root 用户" >&1
  fi
}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: app_user.sh $*" >&1
echo "当前时间: $(date)" >&1
echo "当前用户: $(whoami)" >&1
echo "当前目录: $(pwd)" >&1

# 检查权限
require_root

sha512() { printf "%s" "$1" | sha512sum | awk '{print $1}'; }

mysql_q() { mysql -u"${DB_USER}" -p"${DB_PASS}" -D"${DB_NAME}" -N -B -e "$1"; }

init_schema() {
  mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 创建用户（如果不存在）
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
-- 如果用户已存在，更新密码（确保密码与密码文件一致）
ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
SQL
  mysql -u root ${DB_NAME} <<SQL
CREATE TABLE IF NOT EXISTS app_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(120) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  pass_hash CHAR(128) NOT NULL,
  avatar VARCHAR(500) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 如果表已存在但缺少avatar字段，则添加（使用存储过程避免错误）
SET @dbname = DATABASE();
SET @tablename = 'app_users';
SET @columnname = 'avatar';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (TABLE_SCHEMA = @dbname)
      AND (TABLE_NAME = @tablename)
      AND (COLUMN_NAME = @columnname)
  ) > 0,
  'SELECT 1',
  CONCAT('ALTER TABLE ', @tablename, ' ADD COLUMN ', @columnname, ' VARCHAR(500) DEFAULT NULL')
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;
SQL
  mysql -u root ${DB_NAME} <<SQL
-- 普通登录用户表（与超级管理员 xm 区分），可扩展角色/状态
CREATE TABLE IF NOT EXISTS app_accounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(120) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  pass_hash CHAR(128) NOT NULL,
  role ENUM('user','manager') NOT NULL DEFAULT 'user',
  status TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_app_accounts_username (username),
  INDEX idx_app_accounts_email (email)
) ENGINE=InnoDB;
SQL
  log "app_users schema ready"
  log "app_accounts schema ready"
}

list_mysql_users() {
  log "列出 MySQL 用户 (mysql.user)"
  mysql -u root -e "SELECT User, Host, plugin FROM mysql.user ORDER BY User, Host;" 2>/dev/null || {
    echo "无法连接 MySQL，请确认 root 访问权限" >&1
    return 1
  }
}

register_user() {
  local username="$1" email="$2" password="$3"
  local phash
  phash=$(sha512 "$password")
  
  # 检查用户是否已存在
  if mysql_q "SELECT 1 FROM app_users WHERE username='$username' OR email='$email' LIMIT 1;" 2>/dev/null | grep -q "1"; then
    echo '{"ok":false,"error":"duplicate"}'
    return 1
  fi
  
  # 写入app_users表（前端用户表）
  mysql_q "INSERT INTO app_users(username,email,pass_hash) VALUES ('$username','$email','$phash');" || {
    echo '{"ok":false,"error":"database"}'
    return 1
  }
  
  # 同时写入mail_users表（邮件系统用户表）
  local maildb_pass=$(get_maildb_password)
  mysql -u mailuser -p"$maildb_pass" maildb -e "INSERT IGNORE INTO mail_users(username, email, display_name) VALUES ('$username', '$email', '$username');" 2>/dev/null || {
    echo "警告: 无法同步用户到邮件系统数据库" >&2
  }
  
  # 提取域名并添加到virtual_domains表
  local domain=$(echo "$email" | cut -d'@' -f2)
  if [[ -n "$domain" && "$domain" != "localhost" ]]; then
    mysql -u mailuser -p"$maildb_pass" maildb -e "INSERT IGNORE INTO virtual_domains(name) VALUES ('$domain');" 2>/dev/null || {
      echo "警告: 无法添加域名到邮件系统数据库" >&2
    }
  fi
  
  echo '{"ok":true}'
}

login() {
  # 支持用户名或邮箱登录，并去除首尾空格
  local raw_user="$1" password="$2"
  local username
  username=$(echo -n "$raw_user" | xargs)
  local phash
  phash=$(sha512 "$password")
  
  # 调试输出
  echo "尝试登录用户: ${username}" >&1
  echo "数据库: ${DB_NAME}, 用户: ${DB_USER}" >&1
  
  # 检查数据库连接
  if ! mysql -u"${DB_USER}" -p"${DB_PASS}" -D"${DB_NAME}" -e "SELECT 1;" >/dev/null 2>&1; then
    echo "数据库连接失败" >&1
    echo '{"ok":false,"error":"db_connection_failed"}'
    return 1
  fi
  
  # 检查用户是否存在
  local user_exists
  user_exists=$(mysql_q "SELECT COUNT(*) FROM app_users WHERE username='${username}' OR email='${username}';")
  echo "用户存在检查: ${user_exists}" >&1
  
  if [[ "${user_exists}" -eq 0 ]]; then
    echo "用户不存在: ${username}" >&1
    echo '{"ok":false,"error":"user_not_found"}'
    return 1
  fi
  
  # 1) 在 app_users 中以 用户名 或 邮箱 匹配
  local got
  got=$(mysql_q "SELECT id FROM app_users WHERE (username='${username}' OR email='${username}') AND pass_hash='${phash}' LIMIT 1;")
  echo "密码验证结果: ${got}" >&1
  
  if [[ -n "$got" ]]; then
    echo '{"ok":true}'
    return 0
  fi
  
  # 2) 兼容 app_accounts（如后续切换到该表）
  got=$(mysql_q "SELECT id FROM app_accounts WHERE (username='${username}' OR email='${username}') AND pass_hash='${phash}' AND status=1 LIMIT 1;")
  if [[ -n "$got" ]]; then
    echo '{"ok":true}'
    return 0
  fi
  
  echo "密码错误" >&1
  echo '{"ok":false,"error":"invalid_password"}'
  return 1
}

reset_password() {
  local username="$1" newpass="$2"
  local phash
  phash=$(sha512 "$newpass")
  mysql_q "UPDATE app_users SET pass_hash='${phash}' WHERE username='${username}';"
  echo '{"ok":true}'
}

update_user() {
  local original_username="$1"
  local new_username="${2:-}"
  local email="${3:-}"
  local password="${4:-}"
  local avatar="${5:-}"
  
  # 处理 null 字符串（从前端传来的 "null" 字符串）
  if [[ "$password" == "null" || "$password" == "undefined" || -z "$password" ]]; then
    password=""
  fi
  if [[ "$new_username" == "null" || "$new_username" == "undefined" ]]; then
    new_username=""
  fi
  if [[ "$email" == "null" || "$email" == "undefined" ]]; then
    email=""
  fi
  if [[ "$avatar" == "null" || "$avatar" == "undefined" ]]; then
    avatar=""
  fi
  
  log "开始更新用户: original_username=$original_username, new_username=$new_username, email=$email, password_provided=$([ -n "$password" ] && echo "yes" || echo "no")"
  
  # 检查原用户是否存在
  local user_exists
  user_exists=$(mysql_q "SELECT COUNT(*) FROM app_users WHERE username='$original_username' LIMIT 1;" 2>/dev/null)
  
  log "用户存在检查结果: $user_exists"
  
  if [[ "$user_exists" -eq 0 ]]; then
    log "错误: 用户不存在 - $original_username"
    echo '{"ok":false,"error":"用户不存在"}'
    return 1
  fi
  
  # 如果提供了新用户名，检查是否与其他用户冲突
  if [[ -n "$new_username" && "$new_username" != "$original_username" ]]; then
    local username_exists
    username_exists=$(mysql_q "SELECT COUNT(*) FROM app_users WHERE username='$new_username' AND username!='$original_username' LIMIT 1;" 2>/dev/null)
    if [[ "$username_exists" -gt 0 ]]; then
      echo '{"ok":false,"error":"用户名已存在"}'
      return 1
    fi
  fi
  
  # 构建更新语句
  local update_clause=""
  if [[ -n "$new_username" && "$new_username" != "$original_username" ]]; then
    update_clause="username='$new_username'"
  fi
  
  if [[ -n "$email" ]]; then
    if [[ -n "$update_clause" ]]; then
      update_clause="$update_clause, email='$email'"
    else
      update_clause="email='$email'"
    fi
  fi
  
  if [[ -n "$password" ]]; then
    local phash
    phash=$(sha512 "$password")
    if [[ -n "$update_clause" ]]; then
      update_clause="$update_clause, pass_hash='$phash'"
    else
      update_clause="pass_hash='$phash'"
    fi
  fi
  
  if [[ -n "$avatar" ]]; then
    if [[ -n "$update_clause" ]]; then
      update_clause="$update_clause, avatar='$avatar'"
    else
      update_clause="avatar='$avatar'"
    fi
  fi
  
  if [[ -z "$update_clause" ]]; then
    echo '{"ok":false,"error":"至少需要提供一个要更新的字段"}'
    return 1
  fi
  
  # 执行更新
  log "执行SQL更新: UPDATE app_users SET $update_clause WHERE username='$original_username'"
  mysql_q "UPDATE app_users SET $update_clause WHERE username='$original_username';" || {
    log "错误: 更新app_users表失败"
    echo '{"ok":false,"error":"update_failed"}'
    return 1
  }
  
  log "app_users表更新成功"
  
  # 如果用户名改变了，同时更新mail_users表
  if [[ -n "$new_username" && "$new_username" != "$original_username" ]]; then
    log "用户名已改变，同步更新mail_users和virtual_users表"
    local maildb_pass=$(get_maildb_password)
    mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE mail_users SET username='$new_username' WHERE username='$original_username';" 2>/dev/null && log "mail_users表更新成功" || log "警告: mail_users表更新失败"
    mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE virtual_users SET email=REPLACE(email, '$original_username@', '$new_username@') WHERE email LIKE '$original_username@%';" 2>/dev/null && log "virtual_users表更新成功" || log "警告: virtual_users表更新失败"
  fi
  
  # 如果头像改变了，同时更新mail_users表
  if [[ -n "$avatar" ]]; then
    local current_username="${new_username:-$original_username}"
    local escaped_avatar="${avatar//\'/\\\'}"
    local maildb_pass=$(get_maildb_password)
    mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE mail_users SET avatar='$escaped_avatar' WHERE username='$current_username';" 2>/dev/null && log "mail_users表头像更新成功" || log "警告: mail_users表头像更新失败"
  fi
  
  # 如果邮箱改变了，同时更新mail_users和virtual_users表
  if [[ -n "$email" ]]; then
    local current_username="${new_username:-$original_username}"
    local old_email
    old_email=$(mysql_q "SELECT email FROM app_users WHERE username='$current_username' LIMIT 1;" 2>/dev/null | head -1)
    log "当前邮箱: $old_email, 新邮箱: $email"
    if [[ -n "$old_email" && "$old_email" != "$email" ]]; then
      log "邮箱已改变，同步更新mail_users和virtual_users表"
      local maildb_pass=$(get_maildb_password)
      mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE mail_users SET email='$email' WHERE username='$current_username';" 2>/dev/null && log "mail_users表邮箱更新成功" || log "警告: mail_users表邮箱更新失败"
      mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE virtual_users SET email='$email' WHERE email='$old_email';" 2>/dev/null && log "virtual_users表邮箱更新成功" || log "警告: virtual_users表邮箱更新失败"
    fi
  fi
  
  # 如果密码改变了，记录日志
  if [[ -n "$password" ]]; then
    log "用户密码已更新: username=$current_username"
  fi
  
  # 输出更新后的用户信息用于验证
  local current_username="${new_username:-$original_username}"
  local updated_user
  updated_user=$(mysql_q "SELECT username, email, LEFT(pass_hash, 20) as pass_hash_preview FROM app_users WHERE username='$current_username' LIMIT 1;" 2>/dev/null)
  log "用户信息已更新: $updated_user"
  
  # 验证更新是否成功
  local verify_count
  verify_count=$(mysql_q "SELECT COUNT(*) FROM app_users WHERE username='$current_username' LIMIT 1;" 2>/dev/null)
  if [[ "$verify_count" -eq 0 ]]; then
    log "警告: 验证失败，用户 '$current_username' 不存在于数据库中"
    echo '{"ok":false,"error":"更新后验证失败"}'
    return 1
  fi
  
  log "验证成功: 用户 '$current_username' 已存在于数据库中"
  echo '{"ok":true,"action":"updated","username":"'$current_username'","email":"'$email'","password_updated":'$([ -n "$password" ] && echo "true" || echo "false")'}'
}

query_app_users() {
  echo "查询应用用户列表 (app_users 表)" >&1
  
  # 使用JSON格式输出用户数据，查询mailapp数据库的app_users表
  local json_output
  json_output=$(mysql -u root -e "USE mailapp; SELECT JSON_ARRAYAGG(JSON_OBJECT('id', id, 'username', username, 'email', email, 'display_name', username, 'created_at', created_at)) as users FROM app_users ORDER BY username;" 2>/dev/null | grep -v "users" | grep -v "^$" | head -1)
  
  if [[ -n "$json_output" && "$json_output" != "null" && "$json_output" != "NULL" ]]; then
    echo "$json_output" >&1
  else
    echo "无法查询 app_users 表，请确认数据库和表是否存在" >&1
    echo "尝试检查数据库连接..." >&1
    mysql -u root -e "SHOW DATABASES LIKE 'mailapp';" 2>/dev/null || echo "mailapp 数据库不存在" >&1
    echo "尝试检查表结构..." >&1
    mysql -u root -e "USE mailapp; SHOW TABLES;" 2>/dev/null || echo "无法访问 mailapp 数据库" >&1
    echo "尝试查询用户数据..." >&1
    mysql -u root -e "USE mailapp; SELECT COUNT(*) as user_count FROM app_users;" 2>/dev/null || echo "无法查询用户数量" >&1
    return 1
  fi
}

# 批量修复用户邮箱域名（将localhost域名替换为正确的域名）
fix_user_email_domains() {
  local target_domain="$1"
  
  if [[ -z "$target_domain" ]]; then
    echo '{"ok":false,"error":"target_domain_required"}'
    return 1
  fi
  
  if [[ "$target_domain" == "localhost" ]]; then
    echo '{"ok":false,"error":"target_domain_cannot_be_localhost"}'
    return 1
  fi
  
  echo "批量修复用户邮箱域名: localhost -> $target_domain" >&1
  
  local fixed_count=0
  local failed_count=0
  
  # 创建临时文件存储用户列表
  local temp_file=$(mktemp)
  
  # 获取所有使用localhost域名的用户（排除xm用户）
  mysql -u root -e "USE mailapp; SELECT username, email FROM app_users WHERE email LIKE '%@localhost' AND username != 'xm';" 2>/dev/null | tail -n +2 > "$temp_file"
  
  # 检查是否有需要修复的用户
  if [[ ! -s "$temp_file" ]]; then
    rm -f "$temp_file"
    echo '{"ok":true,"message":"没有需要修复的用户","fixed_count":0,"failed_count":0}'
    return 0
  fi
  
  # 逐行处理用户（不使用管道，避免子shell问题）
  while IFS=$'\t' read -r username email; do
    if [[ -z "$username" || -z "$email" ]]; then
      continue
    fi
    
    local new_email="${username}@${target_domain}"
    
    # 更新app_users表
    if mysql -u root -e "USE mailapp; UPDATE app_users SET email='$new_email' WHERE username='$username';" 2>/dev/null; then
      # 更新mail_users表
      local maildb_pass=$(get_maildb_password)
      mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE mail_users SET email='$new_email' WHERE username='$username';" 2>/dev/null || true
      
      # 更新virtual_users表（如果存在）
      mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE virtual_users SET email='$new_email' WHERE email='$email';" 2>/dev/null || true
      
      # 更新email_recipients表
      mysql -u mailuser -p"$maildb_pass" maildb -e "UPDATE email_recipients SET email_address='$new_email' WHERE email_address='$email';" 2>/dev/null || true
      
      fixed_count=$((fixed_count + 1))
      echo "已修复用户: $username ($email -> $new_email)" >&1
    else
      failed_count=$((failed_count + 1))
      echo "修复用户失败: $username" >&2
    fi
  done < "$temp_file"
  
  # 清理临时文件
  rm -f "$temp_file"
  
  # 统计修复结果
  local total_fixed=$(mysql -u root -e "USE mailapp; SELECT COUNT(*) FROM app_users WHERE email LIKE '%@${target_domain}' AND username != 'xm';" 2>/dev/null | tail -1)
  
  echo "{\"ok\":true,\"message\":\"批量修复完成\",\"fixed_count\":$fixed_count,\"failed_count\":$failed_count,\"total_with_new_domain\":$total_fixed}"
}

check_user_exists() {
  local username="$1"
  echo "检查用户是否存在: $username" >&1
  
  # 检查应用用户表中是否存在该用户名
  local app_user_exists
  app_user_exists=$(mysql -u root -e "USE mailapp; SELECT COUNT(*) FROM app_users WHERE username='$username';" 2>/dev/null | tail -1)
  
  # 检查邮件用户表中是否存在该用户名
  local mail_user_exists
  local maildb_pass=$(get_maildb_password)
  mail_user_exists=$(mysql -u mailuser -p"$maildb_pass" maildb -e "SELECT COUNT(*) FROM mail_users WHERE username='$username';" 2>/dev/null | tail -1)
  
  # 如果任一表中存在该用户，则认为用户已存在
  if [[ "$app_user_exists" -gt 0 || "$mail_user_exists" -gt 0 ]]; then
    echo "用户已存在: $username" >&1
    echo "{\"success\": true, \"exists\": true}" >&1
    return 0
  else
    echo "用户不存在: $username" >&1
    echo "{\"success\": true, \"exists\": false}" >&1
    return 0
  fi
}

delete_app_user() {
  local email="$1"
  echo "删除应用用户: $email" >&1
  
  # 检查用户是否存在
  local user_exists
  user_exists=$(mysql -u root -e "USE mailapp; SELECT COUNT(*) FROM app_users WHERE email='$email';" 2>/dev/null | tail -1)
  
  if [[ "$user_exists" -eq 0 ]]; then
    echo "用户不存在: $email" >&1
    return 1
  fi
  
  # 获取用户名，用于删除maildb中的用户
  local username
  username=$(mysql -u root -e "USE mailapp; SELECT username FROM app_users WHERE email='$email';" 2>/dev/null | tail -1)
  
  # 删除mailapp数据库中的用户
  mysql -u root -e "USE mailapp; DELETE FROM app_users WHERE email='$email';" 2>/dev/null
  
  if [[ $? -eq 0 ]]; then
    echo "应用用户已删除: $email" >&1
    
    # 同时删除maildb数据库中的用户
    if [[ -n "$username" ]]; then
      echo "同步删除邮件系统用户: $username" >&1
      local maildb_pass=$(get_maildb_password)
      mysql -u mailuser -p"$maildb_pass" maildb -e "DELETE FROM mail_users WHERE username='$username';" 2>/dev/null || {
        echo "警告: 无法删除邮件系统用户 $username" >&2
      }
      
      # 删除用户的邮件记录
      echo "删除用户邮件记录: $username" >&1
      mysql -u mailuser -p"$maildb_pass" maildb -e "DELETE FROM emails WHERE from_addr LIKE '%$username%' OR to_addr LIKE '%$username%';" 2>/dev/null || {
        echo "警告: 无法删除用户邮件记录" >&2
      }
    fi
    
    echo "用户完全删除成功: $email" >&1
  else
    echo "删除用户失败: $email" >&1
    return 1
  fi
}

case "${1:-help}" in
  init)
    # 按需求：将初始化行为调整为查看 mysql 所有用户信息
    list_mysql_users ;;
  query-users)
    # 新增：查询应用用户列表
    query_app_users ;;
  delete-user)
    [[ $# -eq 2 ]] || { echo 'usage: app_user.sh delete-user <email>' >&2; exit 2; }
    delete_app_user "$2" ;;
  schema)
    # 原先的初始化 schema 迁移到 schema 子命令
    init_schema ;;
  register)
    [[ $# -eq 4 ]] || { echo 'usage: app_user.sh register <username> <email> <password>' >&2; exit 2; }
    register_user "$2" "$3" "$4" ;;
  login)
    [[ $# -eq 3 ]] || { echo 'usage: app_user.sh login <username> <password>' >&2; exit 2; }
    login "$2" "$3" ;;
  reset)
    [[ $# -eq 3 ]] || { echo 'usage: app_user.sh reset <username> <newpass>' >&2; exit 2; }
    reset_password "$2" "$3" ;;
  update)
    [[ $# -ge 2 ]] || { echo 'usage: app_user.sh update <原用户名> [新用户名] [邮箱] [密码] [头像URL]' >&2; exit 2; }
    update_user "$2" "${3:-}" "${4:-}" "${5:-}" "${6:-}" ;;
  check-user-exists)
    [[ $# -eq 2 ]] || { echo 'usage: app_user.sh check-user-exists <username>' >&2; exit 2; }
    check_user_exists "$2" ;;
  *)
    echo 'usage: app_user.sh {init(查看MySQL用户)|query-users(查询应用用户)|schema(建表)|register|login|reset|update|check-user-exists}' >&2; exit 2 ;;
esac



