#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: db_setup.sh
# 工作职责: 数据库初始化与配置脚本 - 负责创建和初始化邮件系统所需的数据库
#           包括应用数据库（mailapp）和邮件数据库（maildb）的创建与配置
# 系统组件: XM邮件管理系统 - 数据库初始化模块
# ============================================================================
# 用法说明:
#   db_setup.sh <action> [参数...]
#   db_setup.sh init                     - 初始化Postfix虚拟用户数据库（maildb）
#   db_setup.sh restart                  - 重启MariaDB数据库服务
#   db_setup.sh stop                     - 停止MariaDB数据库服务
#
# 功能描述:
#   - 数据库创建：创建maildb数据库（Postfix虚拟用户数据库），使用utf8mb4字符集
#   - 用户创建：创建mailuser数据库用户并设置密码
#   - 权限配置：为mailuser用户授予maildb数据库的所有权限
#   - 表结构初始化：创建Postfix所需的虚拟用户表结构
#     - virtual_domains：虚拟域名表
#     - virtual_users：虚拟用户表（关联域名，支持密码和激活状态）
#     - virtual_aliases：虚拟别名表（邮件转发）
#     - shared_mailboxes：共享邮箱表（扩展功能）
#   - 默认数据：自动插入localhost域名
#
# 数据库配置:
#   - maildb：Postfix虚拟用户数据库（virtual_domains, virtual_users, virtual_aliases等）
#   - 默认用户：mailuser
#   - 密码：优先从密码文件/etc/mail-ops/mail-db.pass读取，其次从环境变量DB_PASS读取，最后使用默认值mailpass（向后兼容）
#   - 字符集：utf8mb4（支持emoji和完整UTF-8字符）
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表（virtual_domains, virtual_users, virtual_aliases, shared_mailboxes）
#   - 邮件系统核心表：由mail_db.sh init命令创建（emails, email_folders等15张表）
#
# 依赖关系:
#   - MariaDB/MySQL服务器
#   - mysql客户端工具
#   - 密码文件：/etc/mail-ops/mail-db.pass（由start.sh创建，随机生成）
#
# 注意事项:
#   - 需要root权限执行数据库操作
#   - 首次安装时自动执行初始化
#   - 密码文件权限为640（root:xm），xm用户可以读取
#   - 支持密码文件不存在时的向后兼容（使用默认值）
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

set -euo pipefail

log() { echo "[db_setup] $*" >&1; }

# 权限检查
require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "警告: 当前用户不是 root，某些操作可能失败" >&1
    echo "建议: 使用 sudo 运行此脚本或切换到 root 用户" >&1
  fi
}

ACTION=${1:-help}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: db_setup.sh $ACTION" >&1
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

SQL_FILE=/tmp/mail_schema.sql

write_schema() {
  cat > "$SQL_FILE" <<SQL
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ${DB_NAME};

CREATE TABLE IF NOT EXISTS virtual_domains (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS virtual_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  domain_id INT NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS virtual_aliases (
  id INT AUTO_INCREMENT PRIMARY KEY,
  domain_id INT NOT NULL,
  source VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 共享邮箱信息（示例，可扩展权限/ACL）
CREATE TABLE IF NOT EXISTS shared_mailboxes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  domain_id INT NOT NULL,
  mailbox VARCHAR(255) NOT NULL,
  members TEXT NOT NULL,
  FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认域名 localhost
INSERT IGNORE INTO virtual_domains (name) VALUES ('localhost');
SQL
}

apply_schema() {
  log "初始化 MariaDB schema"
  write_schema
  mysql -u root <<MYSQL
CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';
FLUSH PRIVILEGES;
MYSQL
  mysql -u root < "$SQL_FILE"
}

case "$ACTION" in
  init)
    apply_schema
    ;;
  restart)
    log "重启数据库服务 (MariaDB)"
    systemctl restart mariadb
    sleep 3
    if systemctl is-active --quiet mariadb; then
      log "数据库服务重启成功"
    else
      log "数据库服务重启失败"
      systemctl status mariadb --no-pager -l
      exit 1
    fi
    ;;
  stop)
    log "关闭数据库服务 (MariaDB)"
    systemctl stop mariadb
    sleep 3
    if ! systemctl is-active --quiet mariadb; then
      log "数据库服务关闭成功"
    else
      log "数据库服务关闭失败"
      systemctl status mariadb --no-pager -l
      exit 1
    fi
    ;;
  *)
    echo "用法: $0 {init|restart|stop}" >&2
    exit 2
    ;;
esac

