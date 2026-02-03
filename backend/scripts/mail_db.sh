#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_db.sh
# 工作职责: 邮件数据库管理脚本 - 负责邮件的存储、检索和数据库操作
#           提供邮件数据的CRUD操作，包括邮件存储、查询、删除和统计功能
# 系统组件: XM邮件管理系统 - 邮件数据管理模块
# ============================================================================
# 用法说明:
#   mail_db.sh <action> [参数...]
#
#   邮件数据库管理:
#   mail_db.sh init                    - 初始化邮件数据库和表结构
#   mail_db.sh store <邮件ID> <发件人> <收件人> <主题> <正文> <HTML> <文件夹> <大小> <抄送> <附件> <头部> - 存储邮件到数据库（已移除优先级和重要性参数）
#   mail_db.sh list <用户邮箱> <文件夹> [每页数量] [偏移量] - 查询用户邮件列表
#   mail_db.sh detail <邮件ID> <用户邮箱> - 获取邮件详情（支持已删除文件夹中的邮件）
#   mail_db.sh delete <邮件ID> <用户邮箱> - 软删除邮件（移动到已删除文件夹）
#   mail_db.sh restore <邮件ID> <用户邮箱> - 还原邮件（从已删除文件夹恢复到原文件夹）
#   mail_db.sh hard-delete <邮件ID> <用户邮箱> - 彻底删除邮件（硬删除，不可恢复）
#   mail_db.sh move <邮件ID> <文件夹> <用户邮箱> - 移动邮件到指定文件夹（移动到已删除文件夹时会自动记录原文件夹）
#   mail_db.sh stats <用户邮箱>          - 获取用户邮件统计信息
#   mail_db.sh cleanup [天数]            - 清理过期邮件（默认30天）
#   mail_db.sh mark_read <邮件ID>        - 标记邮件为已读
#
#   用户管理:
#   mail_db.sh add-user <用户名> <邮箱> [显示名] - 添加邮件用户
#   mail_db.sh list-users               - 列出所有邮件用户
#   mail_db.sh update-user <用户名> <邮箱> [显示名] - 更新用户信息
#   mail_db.sh delete-user <用户名>     - 删除邮件用户
#   mail_db.sh update-admin-email <邮箱> - 更新管理员邮箱
#   mail_db.sh user-stats <用户名>       - 获取用户详细统计
#
#   域名管理:
#   mail_db.sh list_domains             - 列出所有域名
#   mail_db.sh add_domain <域名>        - 添加域名
#   mail_db.sh delete_domain <域名>     - 删除域名
#
#   文件夹管理:
#   mail_db.sh folders [用户ID]         - 获取文件夹列表（包括系统文件夹和自定义文件夹，用户ID为mail_users表的id）
#   mail_db.sh add-folder <名称> <显示名> <用户ID> - 添加自定义文件夹（用户ID为mail_users表的id）
#   mail_db.sh update-folder <文件夹ID> [名称] [显示名] - 更新自定义文件夹（重命名）
#   mail_db.sh delete-folder <文件夹ID> - 删除自定义文件夹（软删除，文件夹中的邮件移动到已删除文件夹）
#   mail_db.sh folder-stats <文件夹ID> <用户> - 获取文件夹统计信息
#
#   标签管理:
#   mail_db.sh labels                   - 获取标签列表
#   mail_db.sh add-label <邮件ID> <标签ID> - 为邮件添加标签
#   mail_db.sh remove-label <邮件ID> <标签ID> - 移除邮件标签
#
#   垃圾邮件过滤配置:
#   mail_db.sh get-spam-config          - 获取垃圾邮件过滤配置
#   mail_db.sh update-spam-config <类型> <JSON值> - 更新垃圾邮件过滤配置
#
# 功能描述:
#   邮件管理功能:
#   - 邮件存储：将接收到的邮件存储到数据库，支持多附件、多收件人
#   - 邮件检索：根据条件查询和检索邮件，支持分页、文件夹过滤、标签过滤
#   - 邮件删除：支持软删除（移动到已删除文件夹）和硬删除（彻底删除）
#   - 邮件还原：从已删除文件夹恢复到原文件夹（自动记录原文件夹信息）
#   - 邮件移动：支持在文件夹间移动邮件，移动到已删除文件夹时自动记录原文件夹
#   - 邮件标记：支持已读/未读标记
#   - 邮件归档：支持将邮件移动到自定义文件夹进行归档管理
#
#   文件夹管理功能:
#   - 系统文件夹：收件箱、已发送、草稿箱、垃圾邮件、已删除（5个默认文件夹）
#   - 自定义文件夹：用户可以创建、重命名、删除自定义文件夹
#   - 文件夹统计：提供每个文件夹的邮件数量、未读数、总大小等统计信息
#   - 文件夹权限：系统文件夹不可删除，自定义文件夹可以删除（删除时邮件移动到已删除文件夹）
#
#   标签管理功能:
#   - 标签系统：支持为邮件添加多个标签（如重要、星标、工作、个人等）
#   - 标签颜色：每个标签可以设置颜色，便于视觉区分
#   - 标签统计：支持统计每个标签的邮件数量
#
#   用户管理功能:
#   - 用户管理：添加、更新、删除邮件用户
#   - 用户统计：提供每个用户的邮件统计信息（收件箱、已发送等）
#   - 域名管理：支持多域名邮件系统
#
#   数据库维护功能:
#   - 数据库初始化：自动创建所有表结构，支持表结构升级和迁移
#   - 数据清理：支持清理过期邮件（可配置保留天数）
#   - 数据一致性：通过外键约束确保数据一致性，级联删除相关数据
#   - 向后兼容：支持从旧表结构自动迁移到新表结构
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表（virtual_domains, virtual_users, virtual_aliases, shared_mailboxes）
#   - maildb数据库：由mail_db.sh init命令创建邮件系统核心表（emails, email_attachments等9张表）
#   - mailapp数据库：由app_user.sh schema命令创建，包含应用用户表（app_users, app_accounts）
#
#   统计功能:
#   - 邮件统计：提供各文件夹的邮件数量、未读数、总大小等统计
#   - 用户统计：提供每个用户的详细邮件统计信息
#   - 文件夹统计：提供每个文件夹的详细统计信息
#
#   垃圾邮件过滤:
#   - 配置管理：支持关键词、域名黑名单、邮箱黑名单、过滤规则等配置
#   - 配置查询：支持查询和更新垃圾邮件过滤配置
#
#   Postfix集成:
#   - 配置同步：与Postfix配置同步更新
#   - 用户同步：邮件用户与Postfix虚拟用户表同步
#
# 数据库表结构（扩展版，共15张表）:
#   注意：以下表分布在两个数据库中，由不同的脚本创建和管理
#
#   邮件系统核心表（maildb数据库，由mail_db.sh init命令创建，9张表）:
#   1. emails：邮件主表
#      - 字段：id, message_id, from_addr, to_addr, cc_addr, subject, body, html_body,
#              date_received, date_sent, folder_id, original_folder_id, read_status,
#              size_bytes, headers, is_deleted, created_at, updated_at
#      - folder_id：关联email_folders表，标识邮件所在文件夹
#      - original_folder_id：记录邮件被删除前的文件夹ID，用于还原功能（移动到已删除文件夹时自动记录）
#      - is_deleted：软删除标记（0=未删除，1=已删除）
#
#   2. email_attachments：邮件附件表
#      - 字段：id, email_id, filename, content_type, size_bytes, file_path, content_base64,
#              is_inline, content_id, created_at
#      - 支持多附件，分离存储，外键关联emails.id（级联删除）
#
#   3. email_recipients：邮件收件人表
#      - 字段：id, email_id, recipient_type, email_address, display_name, is_read, read_at, created_at
#      - recipient_type：收件人类型（to/cc/bcc）
#      - 支持多收件人，外键关联emails.id（级联删除）
#
#   4. email_folders：邮件文件夹表
#      - 字段：id, name, display_name, folder_type, user_id, parent_id, sort_order, is_active, created_at, updated_at
#      - folder_type：文件夹类型（system=系统文件夹，user=用户自定义文件夹）
#      - 系统文件夹：inbox(1), sent(2), drafts(3), trash(4), spam(5)
#      - 用户自定义文件夹：用户可以创建、重命名、删除
#
#   5. email_labels：邮件标签表
#      - 字段：id, name, display_name, color, description, is_system, created_at, updated_at
#      - 支持多标签，如重要、星标、工作、个人等
#      - color：标签颜色（用于前端显示）
#
#   6. email_label_relations：邮件-标签关联表
#      - 字段：id, email_id, label_id, created_at
#      - 多对多关系，外键关联emails.id和email_labels.id（级联删除）
#
#   7. email_metadata：邮件元数据表
#      - 字段：id, email_id, thread_id, spam_score, encryption_status, 等扩展字段
#      - 一对一关系，外键关联emails.id（级联删除）
#
#   8. mail_users：邮件用户表
#      - 字段：id, username, email, display_name, avatar, is_active, created_at, updated_at
#      - 用于用户管理和统计，支持头像字段
#
#   9. spam_filter_config：垃圾邮件过滤配置表
#      - 字段：id, config_type, config_key, config_value, is_active, created_at, updated_at
#      - 存储关键词、域名黑名单、邮箱黑名单、过滤规则等配置
#      - 独立表，无外键关联
#
#   Postfix虚拟用户表（maildb数据库，由db_setup.sh init命令创建，4张表）:
#   10. virtual_domains：虚拟域名表
#       - 字段：id, name
#       - Postfix虚拟域名配置，支持多域名邮件系统
#
#   11. virtual_users：虚拟用户表
#       - 字段：id, domain_id, email, password, active
#       - Postfix虚拟用户配置，关联virtual_domains表
#       - 密码使用SHA512-CRYPT加密存储
#
#   12. virtual_aliases：虚拟别名表
#       - 字段：id, domain_id, source, destination
#       - 邮件转发配置，支持邮件别名和转发规则
#       - 关联virtual_domains表
#
#   13. shared_mailboxes：共享邮箱表
#       - 字段：id, domain_id, mailbox, members
#       - 共享邮箱配置，支持多用户共享邮箱
#       - 关联virtual_domains表
#
#   应用用户表（mailapp数据库，由app_user.sh schema命令创建，2张表）:
#   14. app_users：应用用户主表
#       - 字段：id, username, email, pass_hash, avatar, created_at
#       - 前端登录用户表，密码使用SHA512哈希存储
#       - 与邮局账户（maildb）分离，独立管理Web界面用户认证
#
#   15. app_accounts：应用账户表
#       - 字段：id, username, email, pass_hash, role, status, created_at
#       - 普通登录用户表（与超级管理员xm区分），支持角色和状态管理
#       - role：用户角色（user/manager）
#       - status：账户状态（1=启用，0=禁用）
#
# 表关系说明:
#   邮件主表关联:
#   - emails.folder_id -> email_folders.id（多对一，邮件属于一个文件夹）
#   - emails.original_folder_id -> email_folders.id（多对一，记录删除前的文件夹，用于还原功能）
#      * 当邮件移动到已删除文件夹（trash）时，自动记录原文件夹ID到original_folder_id
#      * 还原邮件时，从original_folder_id获取原文件夹并恢复
#      * 如果没有original_folder_id记录，还原时默认恢复到收件箱
#
#   邮件附件关联:
#   - email_attachments.email_id -> emails.id（多对一，一封邮件可以有多个附件）
#      * 外键约束：ON DELETE CASCADE（删除邮件时自动删除所有附件）
#
#   邮件收件人关联:
#   - email_recipients.email_id -> emails.id（多对一，一封邮件可以有多个收件人）
#      * 外键约束：ON DELETE CASCADE（删除邮件时自动删除所有收件人记录）
#      * recipient_type字段区分收件人类型（to/cc/bcc）
#
#   邮件标签关联（多对多）:
#   - email_label_relations.email_id -> emails.id（多对多，一封邮件可以有多个标签）
#   - email_label_relations.label_id -> email_labels.id（多对多，一个标签可以标记多封邮件）
#      * 外键约束：ON DELETE CASCADE（删除邮件或标签时自动删除关联关系）
#
#   邮件元数据关联:
#   - email_metadata.email_id -> emails.id（一对一，每封邮件对应一条元数据记录）
#      * 外键约束：ON DELETE CASCADE（删除邮件时自动删除元数据）
#
#   文件夹关联:
#   - email_folders.parent_id -> email_folders.id（自关联，支持文件夹嵌套，当前未使用）
#   - email_folders.user_id -> mail_users.id（多对一，自定义文件夹属于特定用户，系统文件夹为NULL）
#      * 注意：文件夹管理统一使用mail_users表的用户ID，而非app_users表的ID
#      * 创建和查询文件夹时，需要从mail_users表获取用户ID，如果不存在则自动创建
#
#   独立表（maildb数据库，由mail_db.sh init命令创建）:
#   - spam_filter_config：独立表，无外键关联，存储垃圾邮件过滤配置
#   - mail_users：独立表，用于用户管理和统计
#
#   Postfix虚拟用户表（maildb数据库，由db_setup.sh init命令创建）:
#   - virtual_domains：虚拟域名表，Postfix域名配置
#   - virtual_users：虚拟用户表，Postfix用户配置，关联virtual_domains表
#   - virtual_aliases：虚拟别名表，邮件转发配置，关联virtual_domains表
#   - shared_mailboxes：共享邮箱表，共享邮箱配置，关联virtual_domains表
#
#   应用用户表（mailapp数据库，由app_user.sh schema命令创建，独立数据库）:
#   - app_users：应用用户主表，前端登录用户，与maildb分离
#   - app_accounts：应用账户表，支持角色和状态管理
#
# 向后兼容性:
#   - 支持从旧表结构（folder字段、attachments字段）自动迁移到新表结构
#   - 查询函数自动检测表结构并适配（JOIN查询或直接查询）
#   - 参数格式保持不变，前端无需修改
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表（virtual_domains, virtual_users, virtual_aliases, shared_mailboxes，共4张表）
#   - maildb数据库：由mail_db.sh init命令创建邮件系统核心表（emails, email_attachments, email_recipients, email_folders, email_labels, email_label_relations, email_metadata, mail_users, spam_filter_config，共9张表）
#   - mailapp数据库：由app_user.sh schema命令创建，包含应用用户表（app_users, app_accounts，共2张表）
#   - 总计：maildb数据库13张表（4张Postfix表+9张邮件系统表），mailapp数据库2张表，共15张表
#
# 密码管理说明:
#   - maildb数据库密码：从密码文件/etc/mail-ops/mail-db.pass读取（由start.sh创建，随机生成Base64密码）
#   - 密码文件权限：640（root:xm），xm用户可以读取
#   - 向后兼容：如果密码文件不存在，使用默认值mailpass
#   - 密码读取：所有MySQL查询通过mysql_connect和mysql_query_json函数统一读取密码文件
#
# 依赖关系:
#   - MariaDB数据库（maildb和mailapp）
#   - Postfix（邮件服务器）
#   - db_setup.sh（创建maildb数据库和Postfix虚拟用户表）
#   - app_user.sh（创建mailapp数据库和应用用户表）
#   - 密码文件：/etc/mail-ops/mail-db.pass（数据库密码文件）
#
# 注意事项:
#   数据库权限:
#   - 需要数据库访问权限（root或mailuser）
#   - 需要读取数据库密码文件：/etc/mail-ops/mail-db.pass
#   - 密码文件不存在时使用默认值（向后兼容）
#
#   邮件操作:
#   - 邮件文件需要正确解析，支持HTML和纯文本格式
#   - 大量邮件操作可能影响性能，建议使用分页查询
#   - 删除邮件使用软删除（移动到已删除文件夹），数据不会真正删除
#   - 彻底删除（hard-delete）会真正删除数据，不可恢复，请谨慎使用
#   - 移动到已删除文件夹时，系统会自动记录原文件夹ID到original_folder_id字段
#   - 还原邮件时，如果没有original_folder_id记录，默认恢复到收件箱
#
#   文件夹管理:
#   - 系统文件夹（inbox, sent, drafts, trash, spam）不可删除
#   - 自定义文件夹可以删除，删除时文件夹中的邮件会自动移动到已删除文件夹
#   - 文件夹名称只能包含字母、数字、下划线和连字符
#   - 文件夹名称不能与系统文件夹名称重复
#   - 用户ID映射：文件夹管理统一使用mail_users表的用户ID，创建文件夹时自动创建mail_users记录（如果不存在）
#   - 参数传递：folders命令需要传递user_id参数（mail_users表的id），否则只返回系统文件夹
#   - 查询优化：使用MySQL的-N选项跳过列名输出，使用tr -d '\n'移除换行符，确保JSON格式正确
#
#   数据一致性:
#   - 附件和收件人数据通过外键级联删除，确保数据一致性
#   - 删除邮件时，相关附件、收件人、标签关联、元数据会自动删除
#   - 删除文件夹时，文件夹中的邮件会移动到已删除文件夹，不会丢失数据
#
#   初始化与迁移:
#   - 首次运行init会自动创建所有表并迁移旧数据
#   - 支持表结构自动升级（检测并添加缺失字段）
#   - 支持从旧表结构（folder字段、attachments字段）自动迁移到新表结构
#
#   参数验证:
#   - 所有函数都包含参数验证，确保系统稳定性
#   - 文件夹名称格式验证（只允许字母、数字、下划线、连字符）
#   - 邮件ID和用户邮箱格式验证
#
#   日志记录:
#   - 所有操作都会记录到日志文件：/var/log/mail-ops/mail-db.log
#   - 日志包含操作时间、用户、操作类型等详细信息
# ============================================================================

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# 基础目录
BASE_DIR=$(cd "$(dirname "$0")/../.." && pwd)
LOG_DIR="/var/log/mail-ops"

# MySQL数据库配置
# MySQL数据库配置
# 注意：maildb数据库由db_setup.sh脚本创建，mail_db.sh脚本负责创建其中的邮件系统核心表
DB_HOST="localhost"
DB_NAME="maildb"  # 数据库来源：db_setup.sh init命令创建
DB_USER="mailuser"  # 数据库用户来源：db_setup.sh init命令创建
DB_PASS_FILE="/etc/mail-ops/mail-db.pass"  # 密码文件由start.sh创建（随机生成），权限640（root:xm）

# 确保目录存在
mkdir -p "$LOG_DIR"

# 日志函数
log() {
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_DIR/mail-db.log"
}

log_info() {
  log "INFO: $*"
}

log_warning() {
  log "WARNING: $*"
}

log_error() {
  log "ERROR: $*"
}

log_success() {
  log "SUCCESS: $*"
}

# 更新Postfix域名配置（重新加载Postfix服务）
# 注意：Postfix已配置为从数据库读取域名，无需创建文件
update_postfix_domains() {
  log "更新Postfix域名配置（重新加载Postfix服务）"
  
  # Postfix已配置为使用MySQL查询读取域名，无需创建文件
  # 只需重新加载Postfix配置即可
  if systemctl is-active --quiet postfix; then
    systemctl reload postfix 2>/dev/null || {
      log_warning "Postfix重新加载失败，但域名已更新到数据库"
    }
    log "Postfix配置已重新加载（域名从数据库读取）"
  else
    log_info "Postfix服务未运行，跳过重新加载"
  fi
}

# MySQL连接函数
mysql_connect() {
  local query="$1"
  if [[ -f "$DB_PASS_FILE" ]]; then
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -e "$query"
  else
    log "错误: 数据库密码文件不存在: $DB_PASS_FILE"
    return 1
  fi
}

# MySQL查询函数（返回JSON格式）
mysql_query_json() {
  local query="$1"
  if [[ -f "$DB_PASS_FILE" ]]; then
    # 检查查询类型并应用相应的JSON格式化
    if echo "$query" | grep -q "COUNT\|SUM\|GROUP BY"; then
      # 统计查询 - 返回原始制表符分隔数据，让调用者处理
      local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$query" 2>/dev/null)
      echo "$result"
    elif echo "$query" | grep -q "body\|html_body\|attachments\|headers"; then
      # 邮件详情查询 - 使用JSON_ARRAYAGG直接返回JSON格式
      echo "[mail_db] 执行邮件详情查询" >> "$LOG_DIR/mail-db.log"
      # 提取邮件ID
      local email_id=$(echo "$query" | grep -o "WHERE id='[^']*'" | sed "s/WHERE id='\\([^']*\\)'/\\1/")
      if [[ -z "$email_id" ]]; then
        # 如果无法提取ID，尝试从查询中提取
        email_id=$(echo "$query" | grep -o "id='[^']*'" | sed "s/id='\\([^']*\\)'/\\1/")
      fi
      
      if [[ -n "$email_id" ]]; then
        local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              'id', id,
              'message_id', message_id,
              'from', from_addr,
              'to', to_addr,
              'cc', COALESCE(cc_addr, ''),
              'subject', subject,
              'body', COALESCE(body, ''),
              'html', COALESCE(html_body, ''),
              'date', date_received,
              'read', read_status,
              'folder', folder,
              'size', size_bytes,
              'attachments', COALESCE(attachments, '[]'),
              'headers', COALESCE(headers, '{}')
            )
          ) as result
          FROM emails 
          WHERE id='$email_id'
        " 2>/dev/null | grep -v "result" | grep -v "^$" | head -1)
      else
        echo "[]"
        return
      fi
      
      if [[ -n "$result" && "$result" != "null" && "$result" != "NULL" ]]; then
        echo "$result"
      else
        echo "[]"
      fi
    else
      # 邮件列表查询 - 使用JSON_ARRAYAGG直接返回JSON格式
      echo "[mail_db] 执行邮件列表查询" >> "$LOG_DIR/mail-db.log"
      local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT JSON_ARRAYAGG(
          JSON_OBJECT(
            'id', id,
            'message_id', message_id,
            'from', from_addr,
            'to', to_addr,
            'cc', COALESCE(cc_addr, ''),
            'subject', subject,
            'date', date_received,
            'read', read_status,
            'folder', folder,
            'size', size_bytes
          )
        ) as result
        FROM emails 
        $where_clause 
        ORDER BY date_received DESC 
        LIMIT $limit OFFSET $offset
      " 2>/dev/null | grep -v "result" | grep -v "^$" | head -1)
      
      if [[ -n "$result" && "$result" != "null" && "$result" != "NULL" ]]; then
        echo "$result"
      else
        echo "[]"
      fi
    fi
  else
    echo "[]"
  fi
}

# 初始化邮件数据库
# 注意：此函数创建maildb数据库中的邮件系统核心表（9张表）
# maildb数据库本身由db_setup.sh init命令创建
# Postfix虚拟用户表（virtual_domains等）由db_setup.sh init命令创建
# 应用用户表（app_users等）由app_user.sh schema命令创建在mailapp数据库中
init_mail_db() {
  log "初始化邮件数据库（maildb数据库中的邮件系统核心表）..."
  
  # 1. 创建邮件主表（保留向后兼容，但简化结构）
  mysql_connect "CREATE TABLE IF NOT EXISTS emails (
    id INT AUTO_INCREMENT PRIMARY KEY,
    message_id VARCHAR(255) UNIQUE,
    from_addr VARCHAR(255) NOT NULL,
    to_addr VARCHAR(255) NOT NULL COMMENT '保留字段，用于向后兼容，实际收件人信息存储在email_recipients表',
    cc_addr VARCHAR(255) DEFAULT '' COMMENT '保留字段，用于向后兼容',
    subject TEXT NOT NULL,
    body LONGTEXT NOT NULL,
    html_body LONGTEXT,
    date_received TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_sent TIMESTAMP NULL,
    folder_id INT DEFAULT 1 COMMENT '关联email_folders表',
    read_status TINYINT(1) DEFAULT 0,
    size_bytes INT DEFAULT 0,
    headers TEXT COMMENT '邮件头信息JSON格式',
    is_deleted TINYINT(1) DEFAULT 0 COMMENT '是否已删除（软删除）',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 如果emails表已存在但没有folder_id字段，添加该字段
  local has_folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA='$DB_NAME' 
    AND TABLE_NAME='emails' 
    AND COLUMN_NAME='folder_id';
  " 2>/dev/null | tail -1)
  
  if [[ "$has_folder_id" -eq 0 ]]; then
    log "emails表已存在但没有folder_id字段，添加该字段..."
    mysql_connect "ALTER TABLE emails ADD COLUMN folder_id INT DEFAULT 1 COMMENT '关联email_folders表' AFTER date_sent;"
    mysql_connect "ALTER TABLE emails ADD COLUMN is_deleted TINYINT(1) DEFAULT 0 COMMENT '是否已删除（软删除）' AFTER headers;"
  fi
  
  # 检查并添加original_folder_id字段（用于记录删除前的文件夹）
  local has_original_folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT COUNT(*) FROM information_schema.COLUMNS 
    WHERE TABLE_SCHEMA='$DB_NAME' 
    AND TABLE_NAME='emails' 
    AND COLUMN_NAME='original_folder_id';
  " 2>/dev/null | tail -1)
  
  if [[ "$has_original_folder_id" -eq 0 ]]; then
    log "添加original_folder_id字段..."
    mysql_connect "ALTER TABLE emails ADD COLUMN original_folder_id INT NULL COMMENT '删除前的文件夹ID，用于还原' AFTER folder_id;"
  fi
  
  # 创建邮件表索引
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_folder_id ON emails(folder_id);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_to_addr ON emails(to_addr);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_from_addr ON emails(from_addr);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_date ON emails(date_received);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_read ON emails(read_status);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_deleted ON emails(is_deleted);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_emails_message_id ON emails(message_id);"

  # 2. 创建邮件附件表
  mysql_connect "CREATE TABLE IF NOT EXISTS email_attachments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email_id INT NOT NULL,
    filename VARCHAR(255) NOT NULL,
    content_type VARCHAR(100),
    size_bytes INT DEFAULT 0,
    file_path VARCHAR(500) COMMENT '附件存储路径',
    content_base64 LONGTEXT COMMENT '附件内容Base64编码（小文件）',
    is_inline TINYINT(1) DEFAULT 0 COMMENT '是否为内联附件',
    content_id VARCHAR(255) COMMENT '内联附件Content-ID',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (email_id) REFERENCES emails(id) ON DELETE CASCADE,
    INDEX idx_attachments_email_id (email_id),
    INDEX idx_attachments_filename (filename)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 3. 创建邮件收件人表（支持多收件人：to、cc、bcc）
  mysql_connect "CREATE TABLE IF NOT EXISTS email_recipients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email_id INT NOT NULL,
    recipient_type ENUM('to', 'cc', 'bcc') NOT NULL DEFAULT 'to',
    email_address VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    is_read TINYINT(1) DEFAULT 0 COMMENT '该收件人是否已读',
    read_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (email_id) REFERENCES emails(id) ON DELETE CASCADE,
    INDEX idx_recipients_email_id (email_id),
    INDEX idx_recipients_type (recipient_type),
    INDEX idx_recipients_address (email_address)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 4. 创建邮件文件夹表（系统文件夹和用户自定义文件夹）
  mysql_connect "CREATE TABLE IF NOT EXISTS email_folders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    display_name VARCHAR(255),
    folder_type ENUM('system', 'user') DEFAULT 'system' COMMENT '系统文件夹或用户自定义文件夹',
    user_id INT NULL COMMENT '用户ID，系统文件夹为NULL',
    parent_id INT NULL COMMENT '父文件夹ID',
    sort_order INT DEFAULT 0,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_folders_type (folder_type),
    INDEX idx_folders_user (user_id),
    INDEX idx_folders_parent (parent_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 插入默认系统文件夹
  mysql_connect "INSERT IGNORE INTO email_folders (id, name, display_name, folder_type, sort_order) VALUES
    (1, 'inbox', '收件箱', 'system', 1),
    (2, 'sent', '已发送', 'system', 2),
    (3, 'drafts', '草稿箱', 'system', 3),
    (4, 'trash', '已删除', 'system', 4),
    (5, 'spam', '垃圾邮件', 'system', 5);"

  # 5. 创建邮件标签表（支持多标签）
  mysql_connect "CREATE TABLE IF NOT EXISTS email_labels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(255),
    color VARCHAR(20) DEFAULT '#3B82F6' COMMENT '标签颜色',
    description TEXT,
    is_system TINYINT(1) DEFAULT 0 COMMENT '是否为系统标签',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_labels_name (name)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 创建邮件-标签关联表（多对多关系）
  mysql_connect "CREATE TABLE IF NOT EXISTS email_label_relations (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email_id INT NOT NULL,
    label_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (email_id) REFERENCES emails(id) ON DELETE CASCADE,
    FOREIGN KEY (label_id) REFERENCES email_labels(id) ON DELETE CASCADE,
    UNIQUE KEY uk_email_label (email_id, label_id),
    INDEX idx_label_relations_email (email_id),
    INDEX idx_label_relations_label (label_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 插入默认系统标签
  mysql_connect "INSERT IGNORE INTO email_labels (name, display_name, is_system, color) VALUES
    ('important', '重要', 1, '#EF4444'),
    ('starred', '星标', 1, '#F59E0B'),
    ('work', '工作', 1, '#3B82F6'),
    ('personal', '个人', 1, '#10B981');"

  # 6. 创建邮件元数据表（扩展字段）
  mysql_connect "CREATE TABLE IF NOT EXISTS email_metadata (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email_id INT NOT NULL UNIQUE,
    reply_to VARCHAR(255),
    in_reply_to VARCHAR(255) COMMENT '回复的邮件Message-ID',
    references_text TEXT COMMENT 'References头',
    thread_id VARCHAR(255) COMMENT '线程ID',
    spam_score DECIMAL(5,2) DEFAULT 0 COMMENT '垃圾邮件评分',
    virus_status VARCHAR(50) DEFAULT 'clean' COMMENT '病毒扫描状态',
    encryption_status VARCHAR(50) DEFAULT 'none' COMMENT '加密状态',
    signature_status VARCHAR(50) DEFAULT 'none' COMMENT '签名状态',
    custom_data JSON COMMENT '自定义扩展数据JSON格式',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (email_id) REFERENCES emails(id) ON DELETE CASCADE,
    INDEX idx_metadata_email_id (email_id),
    INDEX idx_metadata_thread (thread_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 7. 创建邮件用户表（保留）
  mysql_connect "CREATE TABLE IF NOT EXISTS mail_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    avatar VARCHAR(500) DEFAULT NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;"

  # 创建用户索引
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_mail_users_username ON mail_users(username);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_mail_users_email ON mail_users(email);"

  # 插入默认管理员用户
  mysql_connect "INSERT IGNORE INTO mail_users (username, email, display_name, is_active) VALUES ('xm', 'xm@localhost', 'XM Administrator', 1);"

  # 8. 创建垃圾邮件过滤配置表
  mysql_connect "CREATE TABLE IF NOT EXISTS spam_filter_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    config_type VARCHAR(50) NOT NULL COMMENT '配置类型: keyword_cn, keyword_en, domain, email, rule',
    config_key VARCHAR(100) NOT NULL COMMENT '配置键名',
    config_value TEXT COMMENT '配置值（JSON格式存储数组或对象）',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_config_type_key (config_type, config_key)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='垃圾邮件过滤配置表';"

  # 创建配置索引
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_spam_filter_config_type ON spam_filter_config(config_type);"
  mysql_connect "CREATE INDEX IF NOT EXISTS idx_spam_filter_config_active ON spam_filter_config(is_active);"

  # 插入默认垃圾邮件过滤配置
  init_spam_filter_config

  # 9. 确保 localhost 域名存在于 virtual_domains 表中
  mysql_connect "INSERT IGNORE INTO virtual_domains (name) VALUES ('localhost');"
  log "已确保 localhost 域名存在于邮件域名列表中"
  
  # 10. 更新Postfix域名配置文件
  update_postfix_domains

  log "邮件数据库初始化完成（maildb数据库包含9张扩展表，含垃圾邮件过滤配置表；Postfix虚拟用户表由db_setup.sh创建；应用用户表由app_user.sh创建，共15张表）"
}

# 初始化垃圾邮件过滤配置
init_spam_filter_config() {
  log "初始化垃圾邮件过滤默认配置..."
  
  # 检查是否已存在配置，如果存在则跳过初始化（重装时不覆盖）
  local existing_count=$(mysql_connect "SELECT COUNT(*) FROM spam_filter_config WHERE config_key='default' AND is_active=1;" 2>/dev/null | tail -1 | tr -d '[:space:]')
  if [[ "$existing_count" -gt 0 ]]; then
    log "检测到已有垃圾邮件过滤配置（${existing_count}条），跳过默认配置初始化（保留现有数据）"
    return 0
  fi
  
  # 默认中文关键词（扩展列表）
  local keywords_cn='["免费","赚钱","投资","理财","贷款","信用卡","中奖","彩票","优惠","促销","限时","特价","折扣","返现","现金","奖金","兼职","招聘","高薪","轻松","快速","简单","无风险","点击","立即","马上","现在","过期","最后","免费领取","限时优惠","立即购买","马上行动","不要错过","最后机会","限时特价","超值优惠","免费试用","立即注册","马上注册","限时抢购","秒杀","清仓","甩卖","大促销","疯狂折扣","买一送一","免费送","包邮","免运费","特价商品","热销商品","爆款","秒杀价","限时折扣","超值套餐","超值组合","限时秒杀","限时抢购","限时特惠","限时优惠","限时折扣","限时特价","限时促销","限时活动","限时福利","限时好礼","限时大促","限时狂欢","限时钜惠","限时特卖","限时清仓","限时甩卖","限时大减价","限时大降价","限时大优惠","限时大折扣","限时大促销","限时大活动","限时大福利","限时大好礼","限时大促","限时狂欢","限时钜惠","限时特卖","限时清仓","限时甩卖","限时大减价","限时大降价","限时大优惠","限时大折扣","限时大促销","限时大活动","限时大福利","限时大好礼"]'
  mysql_connect "INSERT IGNORE INTO spam_filter_config (config_type, config_key, config_value) VALUES ('keyword_cn', 'default', '$keywords_cn');"
  
  # 默认英文关键词（扩展列表）
  # 注意：使用双引号包裹，内部单引号使用转义
  local keywords_en='["viagra","casino","lottery","winner","congratulations","urgent","click here","limited time","act now","guaranteed","no risk","make money","work from home","get rich","lose weight","free money","cash prize","investment","profit","earn","income","wealth","fortune","opportunity","chance","lucky","win","prize","reward","immediate","limited","exclusive","special","risk-free","no obligation","act fast","free trial","limited offer","special offer","exclusive deal","one time offer","limited edition","while supplies last","order now","buy now","shop now","get it now","order today","buy today","shop today","limited stock","while stock lasts","hurry up","dont miss","last chance","final chance","one last chance","final offer","final sale","clearance sale","going out of business","bankruptcy sale","liquidation sale","fire sale","flash sale","daily deal","deal of the day","today only","todays special","todays deal","todays offer","todays sale","todays discount","todays promotion","todays special offer","todays exclusive deal","todays limited offer","todays one time offer","todays special deal","todays best deal","todays best offer","todays best sale","todays best discount","todays best promotion","todays best special offer","todays best exclusive deal","todays best limited offer","todays best one time offer","todays best special deal"]'
  mysql_connect "INSERT IGNORE INTO spam_filter_config (config_type, config_key, config_value) VALUES ('keyword_en', 'default', '$keywords_en');"
  
  # 默认域名黑名单（调整为xmtest.com）
  local domains='["xmtest.com"]'
  mysql_connect "INSERT IGNORE INTO spam_filter_config (config_type, config_key, config_value) VALUES ('domain', 'default', '$domains');"
  
  # 默认邮箱黑名单
  local emails='["noreply@spam.com","admin@junk.com","info@trash.com","support@fake.com","service@scam.com","noreply@example.com","no-reply@example.com","automated@example.com","robot@example.com"]'
  mysql_connect "INSERT IGNORE INTO spam_filter_config (config_type, config_key, config_value) VALUES ('email', 'default', '$emails');"
  
  # 默认过滤规则（更新为新值）
  # 最小邮件内容行数：0，大写字母比例阈值：0.8，最大感叹号数量：6，最大特殊字符数量：8
  local rules='{"min_body_lines":0,"max_caps_ratio":0.8,"max_exclamation":6,"max_special_chars":8}'
  mysql_connect "INSERT IGNORE INTO spam_filter_config (config_type, config_key, config_value) VALUES ('rule', 'default', '$rules');"
  
  log "垃圾邮件过滤默认配置初始化完成"
}

# 获取垃圾邮件过滤配置
get_spam_filter_config() {
  local config_type="${1:-all}"
  
  if [ "$config_type" = "all" ]; then
    # 返回所有配置的JSON，使用MySQL的JSON函数直接构建
    if [[ ! -f "$DB_PASS_FILE" ]]; then
      log "错误: 数据库密码文件不存在: $DB_PASS_FILE"
      echo '{"keywords": {"chinese": [], "english": []}, "domainBlacklist": [], "emailBlacklist": [], "rules": {}}'
      return 1
    fi
    
    # 使用MySQL的JSON函数直接构建配置JSON
    # config_value字段存储的是JSON字符串，需要先解析为JSON对象
    local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT JSON_OBJECT(
        'keywords', JSON_OBJECT(
          'chinese', COALESCE((
            SELECT JSON_EXTRACT(config_value, '\$')
            FROM spam_filter_config
            WHERE config_type = 'keyword_cn' AND config_key = 'default' AND is_active = 1
            LIMIT 1
          ), JSON_ARRAY()),
          'english', COALESCE((
            SELECT JSON_EXTRACT(config_value, '\$')
            FROM spam_filter_config
            WHERE config_type = 'keyword_en' AND config_key = 'default' AND is_active = 1
            LIMIT 1
          ), JSON_ARRAY())
        ),
        'domainBlacklist', COALESCE((
          SELECT JSON_EXTRACT(config_value, '\$')
          FROM spam_filter_config
          WHERE config_type = 'domain' AND config_key = 'default' AND is_active = 1
          LIMIT 1
        ), JSON_ARRAY()),
        'emailBlacklist', COALESCE((
          SELECT JSON_EXTRACT(config_value, '\$')
          FROM spam_filter_config
          WHERE config_type = 'email' AND config_key = 'default' AND is_active = 1
          LIMIT 1
        ), JSON_ARRAY()),
        'rules', COALESCE((
          SELECT JSON_OBJECT(
            'minContentLines', CAST(JSON_EXTRACT(config_value, '\$.min_body_lines') AS UNSIGNED),
            'uppercaseRatio', CAST(JSON_EXTRACT(config_value, '\$.max_caps_ratio') AS DECIMAL(3,2)),
            'maxExclamationMarks', CAST(JSON_EXTRACT(config_value, '\$.max_exclamation') AS UNSIGNED),
            'maxSpecialChars', CAST(JSON_EXTRACT(config_value, '\$.max_special_chars') AS UNSIGNED)
          )
          FROM spam_filter_config
          WHERE config_type = 'rule' AND config_key = 'default' AND is_active = 1
          LIMIT 1
        ), JSON_OBJECT(
          'minContentLines', 0,
          'uppercaseRatio', 0.8,
          'maxExclamationMarks', 6,
          'maxSpecialChars', 8
        ))
      ) as result;
    " 2>/dev/null | grep -v "result" | grep -v "^$" | head -1)
    
    # 如果查询结果为空或null，返回默认配置
    if [[ -z "$result" || "$result" == "null" || "$result" == "NULL" ]]; then
      echo '{"keywords": {"chinese": [], "english": []}, "domainBlacklist": [], "emailBlacklist": [], "rules": {"minContentLines": 0, "uppercaseRatio": 0.8, "maxExclamationMarks": 6, "maxSpecialChars": 8}}'
    else
      echo "$result"
    fi
  else
    # 返回指定类型的配置
    mysql_connect "SELECT config_value FROM spam_filter_config WHERE config_type='$config_type' AND config_key='default' AND is_active=1 LIMIT 1;" | tail -1
  fi
}

# 更新垃圾邮件过滤配置
update_spam_filter_config() {
  local config_type="$1"
  local config_value="$2"
  
  # 如果config_value是文件路径，读取文件内容
  if [[ -f "$config_value" ]]; then
    config_value=$(cat "$config_value")
  fi
  
  # 验证JSON格式
  if ! echo "$config_value" | python3 -m json.tool >/dev/null 2>&1; then
    log "错误: 配置值不是有效的JSON格式: $config_type"
    echo "错误: 配置值不是有效的JSON格式: $config_type" >&2
    return 1
  fi
  
  # 转义JSON字符串中的单引号（MySQL需要）
  local escaped_value=$(echo "$config_value" | sed "s/'/''/g")
  
  # 执行数据库更新
  local mysql_result
  mysql_result=$(mysql_connect "INSERT INTO spam_filter_config (config_type, config_key, config_value) 
    VALUES ('$config_type', 'default', '$escaped_value')
    ON DUPLICATE KEY UPDATE config_value='$escaped_value', updated_at=CURRENT_TIMESTAMP;" 2>&1)
  local mysql_exit_code=$?
  
  if [ $mysql_exit_code -ne 0 ]; then
    log "错误: 更新垃圾邮件过滤配置失败: $config_type, MySQL错误: $mysql_result"
    echo "错误: 更新失败: $mysql_result" >&2
    return 1
  fi
  
  # 验证更新是否成功
  local count=$(mysql_connect "SELECT COUNT(*) FROM spam_filter_config WHERE config_type='$config_type' AND config_key='default' AND is_active=1;" 2>/dev/null | tail -1 | tr -d '[:space:]')
  if [ "$count" = "1" ]; then
    log "更新垃圾邮件过滤配置成功: $config_type"
    echo "更新成功: $config_type"
  else
    log "警告: 更新后验证失败: $config_type (记录数: $count)"
    echo "警告: 更新后验证失败: $config_type (记录数: $count)" >&2
    # 不返回错误，因为可能只是验证问题
  fi
  
  return 0
}

# 存储邮件
store_email() {
  local message_id="$1"
  local from_addr="$2"
  local to_addr="$3"
  local subject="$4"
  local body_param="$5"
  local html_body_param="${6:-}"
  local folder="${7:-inbox}"
  local size_bytes="${8:-0}"
  local cc_addr="${9:-}"
  local attachments_file="${10:-}"
  local headers="${11:-}"
  
  # 确保空值被正确处理
  cc_addr="${cc_addr:-}"
  attachments_file="${attachments_file:-}"
  headers="${headers:-}"
  
  # 如果body参数是文件路径（以/开头且文件存在），读取文件内容
  local body=""
  if [[ -n "$body_param" && "$body_param" =~ ^/ && -f "$body_param" ]]; then
    body=$(cat "$body_param" 2>/dev/null || echo "")
    log "从临时文件读取body: 文件=$body_param, 长度=${#body}, 前100字符=${body:0:100}"
    # 清理临时文件
    rm -f "$body_param" 2>/dev/null || true
  else
    body="$body_param"
    log "直接使用body参数: 长度=${#body}, 前100字符=${body:0:100}"
  fi
  
  # 如果html_body参数是文件路径（以/开头且文件存在），读取文件内容
  local html_body=""
  if [[ -n "$html_body_param" && "$html_body_param" =~ ^/ && -f "$html_body_param" ]]; then
    html_body=$(cat "$html_body_param" 2>/dev/null || echo "")
    log "从临时文件读取html_body: 文件=$html_body_param, 长度=${#html_body}, 前100字符=${html_body:0:100}"
    # 清理临时文件
    rm -f "$html_body_param" 2>/dev/null || true
  else
    html_body="$html_body_param"
    if [[ -n "$html_body" ]]; then
      log "直接使用html_body参数: 长度=${#html_body}, 前100字符=${html_body:0:100}"
    fi
  fi
  
  # 处理附件数据
  local attachments=""
  if [[ -n "$attachments_file" ]]; then
    # 如果attachments_file是JSON字符串（不以/开头），直接使用
    if [[ ! "$attachments_file" =~ ^/ ]]; then
      attachments="$attachments_file"
    # 如果attachments_file是文件路径，读取文件内容
    elif [[ -f "$attachments_file" ]]; then
      attachments=$(cat "$attachments_file" 2>/dev/null || echo "")
      # 清理临时文件
      rm -f "$attachments_file" 2>/dev/null || true
    fi
  fi
  
  log "存储邮件: $message_id"
  log "参数: message_id=$message_id, from_addr=$from_addr, to_addr=$to_addr, subject=$subject, cc_addr=$cc_addr"
  log "附件数据: $attachments"
  log "附件文件: $attachments_file"
  
  # 检查邮件是否已存在
  local exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT COUNT(*) FROM emails WHERE message_id='$message_id'" 2>/dev/null | tail -1)
  
  if [ "$exists" -gt 0 ]; then
    log "邮件已存在，跳过存储: $message_id"
    return 0
  fi
  
  # 转义特殊字符
  local escaped_subject=$(echo "$subject" | sed "s/'/''/g" | sed 's/"/\\"/g')
  local escaped_body=$(echo "$body" | sed "s/'/''/g" | sed 's/"/\\"/g')
  local escaped_html_body=$(echo "$html_body" | sed "s/'/''/g" | sed 's/"/\\"/g')
  local escaped_cc_addr=$(echo "$cc_addr" | sed "s/'/''/g" | sed 's/"/\\"/g')
  # 对于JSON数据（attachments和headers），只转义单引号，不转义双引号
  local escaped_attachments=$(echo "$attachments" | sed "s/'/''/g")
  local escaped_headers=$(echo "$headers" | sed "s/'/''/g")
  
  # 存储邮件
  # 对于JSON数据，使用MySQL的JSON_VALID函数验证，如果有效则直接存储，否则存储为空
  local attachments_sql=""
  local headers_sql=""
  
  if [[ -n "$attachments" ]]; then
    # 检查是否为有效JSON
    if echo "$attachments" | python3 -m json.tool >/dev/null 2>&1; then
      attachments_sql="'$attachments'"
    else
      attachments_sql="'[]'"
    fi
  else
    attachments_sql="'[]'"
  fi
  
  if [[ -n "$headers" ]]; then
    # 检查是否为有效JSON
    if echo "$headers" | python3 -m json.tool >/dev/null 2>&1; then
      headers_sql="'$headers'"
    else
      headers_sql="'{}'"
    fi
  else
    headers_sql="'{}'"
  fi
  
  # 获取文件夹ID（支持向后兼容：如果folder是字符串，查找对应的folder_id）
  local folder_id=1  # 默认inbox
  if [[ "$folder" =~ ^[0-9]+$ ]]; then
    # folder是数字，直接使用
    folder_id="$folder"
  else
    # folder是字符串，查找对应的folder_id
    local folder_query="SELECT id FROM email_folders WHERE name='$folder' LIMIT 1;"
    local found_folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$folder_query" 2>/dev/null | tail -1)
    if [[ -n "$found_folder_id" && "$found_folder_id" =~ ^[0-9]+$ ]]; then
      folder_id="$found_folder_id"
    else
      log "警告: 文件夹 '$folder' 不存在，使用默认文件夹 (inbox, id=1)"
      folder_id=1
    fi
  fi
  
  # 转义message_id, from_addr, to_addr
  local escaped_message_id=$(echo "$message_id" | sed "s/'/''/g")
  local escaped_from_addr=$(echo "$from_addr" | sed "s/'/''/g")
  local escaped_to_addr=$(echo "$to_addr" | sed "s/'/''/g")
  
  # 存储邮件到emails表（使用folder_id）
  log "准备存储邮件到数据库: message_id=$message_id, body长度=${#body}, html_body长度=${#html_body}"
  mysql_connect "INSERT INTO emails (
    message_id, from_addr, to_addr, cc_addr, subject, body, html_body, 
    folder_id, size_bytes, headers
  ) VALUES (
    '$escaped_message_id', '$escaped_from_addr', '$escaped_to_addr', '$escaped_cc_addr', 
    '$escaped_subject', '$escaped_body', '$escaped_html_body',
    $folder_id, $size_bytes, $headers_sql
  );"
  
  # 获取刚插入的邮件ID
  local email_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT id FROM emails WHERE message_id='$escaped_message_id' LIMIT 1;" 2>/dev/null | tail -1)
  
  # 验证存储的body字段
  if [[ -n "$email_id" && "$email_id" =~ ^[0-9]+$ ]]; then
    local stored_body_length=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT LENGTH(body) FROM emails WHERE id=$email_id LIMIT 1;" 2>/dev/null | tail -1)
    log "邮件存储成功: email_id=$email_id, 数据库中body字段长度=$stored_body_length"
  fi
  
  if [[ -z "$email_id" || ! "$email_id" =~ ^[0-9]+$ ]]; then
    log "错误: 无法获取插入的邮件ID, message_id=$escaped_message_id"
    return 1
  fi
  
  log "邮件已插入，ID: $email_id"
  
  # 存储收件人到email_recipients表
  # 处理主收件人（to）
  if [[ -n "$to_addr" ]]; then
    IFS=',' read -ra TO_ADDRESSES <<< "$to_addr"
    for addr in "${TO_ADDRESSES[@]}"; do
      addr=$(echo "$addr" | xargs)  # 去除空格
      if [[ -n "$addr" ]]; then
        local escaped_addr=$(echo "$addr" | sed "s/'/''/g")
        # 使用INSERT IGNORE避免重复插入
        local insert_result=$(mysql_connect "INSERT IGNORE INTO email_recipients (email_id, recipient_type, email_address) VALUES ($email_id, 'to', '$escaped_addr');" 2>&1)
        if [[ $? -eq 0 ]]; then
          log "收件人存储成功: email_id=$email_id, recipient_type=to, email_address=$escaped_addr"
        else
          log "收件人存储失败: email_id=$email_id, recipient_type=to, email_address=$escaped_addr, error=$insert_result"
        fi
      fi
    done
  fi
  
  # 处理抄送（cc）
  if [[ -n "$cc_addr" ]]; then
    IFS=',' read -ra CC_ADDRESSES <<< "$cc_addr"
    for addr in "${CC_ADDRESSES[@]}"; do
      addr=$(echo "$addr" | xargs)  # 去除空格
      if [[ -n "$addr" ]]; then
        local escaped_addr=$(echo "$addr" | sed "s/'/''/g")
        # 使用INSERT IGNORE避免重复插入
        local insert_result=$(mysql_connect "INSERT IGNORE INTO email_recipients (email_id, recipient_type, email_address) VALUES ($email_id, 'cc', '$escaped_addr');" 2>&1)
        if [[ $? -eq 0 ]]; then
          log "抄送人存储成功: email_id=$email_id, recipient_type=cc, email_address=$escaped_addr"
        else
          log "抄送人存储失败: email_id=$email_id, recipient_type=cc, email_address=$escaped_addr, error=$insert_result"
        fi
      fi
    done
  fi
  
  # 存储附件到email_attachments表
  if [[ -n "$attachments" ]]; then
    # 验证JSON格式并存储附件
    if echo "$attachments" | python3 -m json.tool >/dev/null 2>&1; then
      # 使用Python解析JSON并插入附件
      python3 << PYTHON_EOF
import json
import sys
import subprocess
import os

try:
    attachments_json = '''$attachments'''
    attachments = json.loads(attachments_json)
    email_id = $email_id
    db_host = '$DB_HOST'
    db_user = '$DB_USER'
    db_pass_file = '$DB_PASS_FILE'
    db_name = '$DB_NAME'
    
    # 读取数据库密码
    try:
        with open(db_pass_file, 'r') as f:
            db_pass = f.read().strip()
    except Exception as e:
        print(f"Error reading password file: {e}", file=sys.stderr)
        sys.exit(1)
    
    if isinstance(attachments, list):
        for att in attachments:
            filename = att.get('name', '')
            content_type = att.get('type', '')
            size_bytes = att.get('size', 0)
            content_base64 = att.get('content', '')
            
            if filename:
                # 转义SQL特殊字符
                # 使用原始字符串来避免bash heredoc中的反斜杠转义问题
                # 先转义反斜杠（使用原始字符串），再转义单引号
                backslash = chr(92)  # 反斜杠字符
                filename_escaped = filename.replace(backslash, backslash + backslash).replace("'", "''")
                content_type_escaped = content_type.replace(backslash, backslash + backslash).replace("'", "''") if content_type else ''
                # Base64内容可能很长，需要特殊处理
                content_base64_escaped = content_base64.replace(backslash, backslash + backslash).replace("'", "''") if content_base64 else ''
                
                # 使用mysql命令执行SQL（更安全的方式）
                sql = f"INSERT INTO email_attachments (email_id, filename, content_type, size_bytes, content_base64) VALUES ({email_id}, '{filename_escaped}', '{content_type_escaped}', {size_bytes}, '{content_base64_escaped}');"
                
                # 使用subprocess执行，避免shell注入
                env = os.environ.copy()
                env['MYSQL_PWD'] = db_pass
                cmd = ['mysql', '-h', db_host, '-u', db_user, db_name, '-e', sql]
                result = subprocess.run(cmd, env=env, capture_output=True, text=True)
                
                if result.returncode != 0:
                    print(f"Warning: Failed to insert attachment {filename}: {result.stderr}", file=sys.stderr)
except json.JSONDecodeError as e:
    print(f"Error parsing attachments JSON: {e}", file=sys.stderr)
except Exception as e:
    print(f"Error processing attachments: {e}", file=sys.stderr)
    # 不退出，继续执行
PYTHON_EOF
    else
      log "警告: 附件数据不是有效的JSON格式，跳过附件存储"
    fi
  fi
  
  log "邮件存储成功: $message_id (ID: $email_id)"
}

# 获取邮件列表
get_emails() {
  local user="$1"
  local folder="${2:-inbox}"
  local limit="${3:-50}"
  local offset="${4:-0}"
  
  # 静默记录日志，不输出到标准输出
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 获取邮件列表: user=$user, folder=$folder, limit=$limit, offset=$offset" >> "$LOG_DIR/mail-db.log"
  echo "[mail_db] 调试信息: user='$user', folder='$folder'" >> "$LOG_DIR/mail-db.log"
  
  # 获取文件夹ID（支持向后兼容）
  local folder_id=""
  if [[ "$folder" =~ ^[0-9]+$ ]]; then
    folder_id="$folder"
  else
    local folder_query="SELECT id FROM email_folders WHERE name='$folder' LIMIT 1;"
    folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$folder_query" 2>/dev/null | tail -1)
    if [[ -z "$folder_id" || ! "$folder_id" =~ ^[0-9]+$ ]]; then
      folder_id=1  # 默认inbox
    fi
  fi
  
  # 构建查询条件（使用folder_id和email_recipients表）
  local where_clause="WHERE e.folder_id=$folder_id AND e.is_deleted=0"
  
  if [ "$folder" = "inbox" ] || [ "$folder_id" = "1" ]; then
    # 收件箱：只显示发送给当前用户的邮件（使用email_recipients表）
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址，直接精确匹配
      where_clause="WHERE e.folder_id=1 AND e.is_deleted=0 AND EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND er.email_address = '$user'
      )"
    elif [ "$user" = "xm" ]; then
      # 特殊处理xm用户，支持多种邮箱格式
      where_clause="WHERE e.folder_id=1 AND e.is_deleted=0 AND EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
      )"
    else
      # 普通用户名，使用旧逻辑（向后兼容）
      where_clause="WHERE e.folder_id=1 AND e.is_deleted=0 AND EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
      )"
    fi
  elif [ "$folder" = "sent" ] || [ "$folder_id" = "2" ]; then
    # 已发送：只显示当前用户发送的邮件
    # 获取用户的所有可能邮箱地址（包括数据库中的真实邮箱和localhost邮箱）
    local user_emails=""
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址，匹配该地址和对应的localhost地址
      local username_part=$(echo "$user" | cut -d'@' -f1)
      local domain_part=$(echo "$user" | cut -d'@' -f2)
      user_emails="'$user', '${username_part}@localhost'"
      
      # 也查询数据库中该用户名的所有邮箱地址
      local db_emails=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT email FROM mail_users WHERE username='${username_part}' OR email='$user';" 2>/dev/null | grep -v "^email$" | grep "@" | sed "s/^/'/" | sed "s/$/'/" | tr '\n' ',' | sed 's/,$//')
      if [[ -n "$db_emails" ]]; then
        user_emails="$user_emails, $db_emails"
      fi
    else
      # 如果传入的是用户名，查询该用户的所有邮箱地址
      local db_emails=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT email FROM mail_users WHERE username='$user';" 2>/dev/null | grep -v "^email$" | grep "@" | sed "s/^/'/" | sed "s/$/'/" | tr '\n' ',' | sed 's/,$//')
      if [[ -n "$db_emails" ]]; then
        user_emails="$db_emails, '${user}@localhost'"
      else
        user_emails="'${user}@localhost'"
      fi
    fi
    
    # 构建查询条件：匹配用户的所有可能邮箱地址
    if [[ -z "$user_emails" ]]; then
      # 如果user_emails为空，使用默认值
      user_emails="'${user}@localhost'"
    fi
    where_clause="WHERE e.folder_id=2 AND e.is_deleted=0 AND e.from_addr IN ($user_emails)"
    echo "[mail_db] 已发送邮件查询: user=$user, folder_id=$folder_id, user_emails=$user_emails" >> "$LOG_DIR/mail-db.log"
    echo "[mail_db] 已发送邮件查询WHERE子句: $where_clause" >> "$LOG_DIR/mail-db.log"
  elif [ "$folder" = "trash" ] || [ "$folder_id" = "4" ]; then
    # 已删除文件夹：显示所有已删除的邮件（不检查is_deleted，因为已删除文件夹中的邮件可能is_deleted=1）
    # 根据用户过滤邮件
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址
      where_clause="WHERE e.folder_id=4 AND (e.from_addr = '$user' OR EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND er.email_address = '$user'
      ))"
    elif [ "$user" = "xm" ]; then
      # 特殊处理xm用户
      where_clause="WHERE e.folder_id=4 AND (e.from_addr = 'xm@localhost' OR e.from_addr LIKE '%@xm' OR e.from_addr LIKE 'xm@%' OR EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
      ))"
    else
      # 普通用户名
      where_clause="WHERE e.folder_id=4 AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%' OR EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
      ))"
    fi
  fi
  
  # 查询邮件（JOIN email_folders表获取folder名称，包含优先级、重要性、标签等信息）
  # 使用子查询获取标签和收件人信息
  # 重要：使用email_recipients.is_read来获取当前用户的已读状态，而不是emails.read_status
  # 获取当前用户的邮箱地址列表（用于匹配email_recipients表）
  local user_email_condition=""
  if [[ "$user" == *@* ]]; then
    # 如果传入的是完整邮箱地址，直接精确匹配
    user_email_condition="er_user.email_address = '$user'"
  elif [ "$user" = "xm" ]; then
    # 特殊处理xm用户，支持多种邮箱格式
    user_email_condition="(er_user.email_address = 'xm@localhost' OR er_user.email_address LIKE '%@xm' OR er_user.email_address LIKE 'xm@%')"
  else
    # 普通用户名
    user_email_condition="(er_user.email_address = '$user' OR er_user.email_address LIKE '%@$user' OR er_user.email_address LIKE '$user@%')"
  fi
  
  # 确保user_email_condition不为空
  if [[ -z "$user_email_condition" ]]; then
    user_email_condition="1=0"  # 如果为空，使用永远为假的条件
  fi
  
  echo "[mail_db] 执行查询: folder=$folder, where_clause=$where_clause, user=$user, user_email_condition=$user_email_condition" >> "$LOG_DIR/mail-db.log"
  local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'id', e.id,
        'message_id', e.message_id,
        'from', e.from_addr,
        'to', e.to_addr,
        'cc', COALESCE(e.cc_addr, ''),
        'subject', e.subject,
        'date', e.date_received,
        'read', CASE 
          WHEN e.folder_id = 2 AND e.from_addr = COALESCE((SELECT email FROM mail_users WHERE username='$user' LIMIT 1), '$user') THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '%@$user' THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '$user@%' THEN COALESCE(e.read_status, 0)
          ELSE COALESCE((
            -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则显示为未读
            -- 只考虑相同folder_id的记录，避免sent文件夹的记录影响收件箱的已读状态
            SELECT MIN(er2.is_read) FROM email_recipients er2 
            JOIN emails e3 ON er2.email_id = e3.id
            WHERE SUBSTRING_INDEX(e3.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
              AND e3.folder_id = e.folder_id
              AND er2.recipient_type IN ('to', 'cc')
              AND ($(echo "$user_email_condition" | sed 's/er_user\./er2./g'))
          ), 0)
        END,
        'read_status', CASE 
          WHEN e.folder_id = 2 AND e.from_addr = COALESCE((SELECT email FROM mail_users WHERE username='$user' LIMIT 1), '$user') THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '%@$user' THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '$user@%' THEN COALESCE(e.read_status, 0)
          ELSE COALESCE((
            -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则显示为未读
            -- 只考虑相同folder_id的记录，避免sent文件夹的记录影响收件箱的已读状态
            SELECT MIN(er2.is_read) FROM email_recipients er2 
            JOIN emails e3 ON er2.email_id = e3.id
            WHERE SUBSTRING_INDEX(e3.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
              AND e3.folder_id = e.folder_id
              AND er2.recipient_type IN ('to', 'cc')
              AND ($(echo "$user_email_condition" | sed 's/er_user\./er2./g'))
          ), 0)
        END,
        'folder', COALESCE(f.name, 'inbox'),
        'size', e.size_bytes,
        'original_folder_id', e.original_folder_id,
        'labels', COALESCE((
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              'id', el.id,
              'name', el.name,
              'display_name', el.display_name,
              'color', el.color
            )
          )
          FROM email_label_relations elr
          JOIN email_labels el ON elr.label_id = el.id
          WHERE elr.email_id = e.id
        ), JSON_ARRAY()),
        'recipients', JSON_OBJECT(
          'to', COALESCE((
            SELECT JSON_ARRAYAGG(email_address)
            FROM email_recipients
            WHERE email_id = e.id AND recipient_type = 'to'
          ), JSON_ARRAY()),
          'cc', COALESCE((
            SELECT JSON_ARRAYAGG(email_address)
            FROM email_recipients
            WHERE email_id = e.id AND recipient_type = 'cc'
          ), JSON_ARRAY()),
          'bcc', COALESCE((
            SELECT JSON_ARRAYAGG(email_address)
            FROM email_recipients
            WHERE email_id = e.id AND recipient_type = 'bcc'
          ), JSON_ARRAY())
        )
      )
    ) as result
    FROM emails e
    LEFT JOIN email_folders f ON e.folder_id = f.id
    LEFT JOIN email_recipients er_user ON er_user.email_id = e.id 
      AND er_user.recipient_type IN ('to', 'cc')
      AND $user_email_condition
    WHERE e.id IN (
      SELECT MIN(e2.id)
      FROM emails e2
      $(echo "$where_clause" | sed 's/\be\./e2./g')
      GROUP BY SUBSTRING_INDEX(e2.message_id, '_', 1)
    )
    ORDER BY e.date_received DESC
    LIMIT $limit OFFSET $offset
  " 2>&1 | tail -1)
  
  # 检查是否有错误信息
  if [[ "$result" =~ "ERROR" ]] || [[ "$result" =~ "error" ]]; then
    echo "[mail_db] 查询出错: $result" >> "$LOG_DIR/mail-db.log"
    echo "[]"
    return
  fi
  
  echo "[mail_db] 查询结果长度: ${#result}" >> "$LOG_DIR/mail-db.log"
  
  # 输出结果
  if [[ -n "$result" && "$result" != "null" && "$result" != "NULL" ]]; then
    echo "$result"
  else
    echo "[]"
  fi
}

# 搜索邮件（模糊查询）
search_emails() {
  local user="$1"
  local query="${2:-}"
  local folder="${3:-all}"
  local limit="${4:-100}"
  local offset="${5:-0}"
  
  # 静默记录日志
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 搜索邮件: user=$user, query=$query, folder=$folder, limit=$limit, offset=$offset" >> "$LOG_DIR/mail-db.log"
  
  if [[ -z "$query" ]]; then
    echo "[]"
    return
  fi
  
  # 转义查询字符串，防止SQL注入
  local escaped_query=$(echo "$query" | sed "s/'/''/g")
  
  # 获取文件夹ID
  local folder_id=""
  if [[ "$folder" != "all" ]]; then
    if [[ "$folder" =~ ^[0-9]+$ ]]; then
      folder_id="$folder"
    else
      local folder_query="SELECT id FROM email_folders WHERE name='$folder' LIMIT 1;"
      folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$folder_query" 2>/dev/null | tail -1)
      if [[ -z "$folder_id" || ! "$folder_id" =~ ^[0-9]+$ ]]; then
        folder_id=""
      fi
    fi
  fi
  
  # 构建WHERE子句
  local where_clause="WHERE e.is_deleted=0"
  
  # 添加文件夹过滤
  if [[ -n "$folder_id" ]]; then
    where_clause="$where_clause AND e.folder_id=$folder_id"
  fi
  
  # 添加用户过滤（根据文件夹类型）
  if [[ "$folder" == "inbox" || "$folder_id" == "1" ]]; then
    # 收件箱：只搜索发送给当前用户的邮件
    if [[ "$user" == *@* ]]; then
      where_clause="$where_clause AND EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND er.email_address = '$user'
      )"
    elif [ "$user" = "xm" ]; then
      where_clause="$where_clause AND EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
      )"
    else
      where_clause="$where_clause AND EXISTS (
        SELECT 1 FROM email_recipients er
        WHERE er.email_id = e.id
        AND er.recipient_type IN ('to', 'cc')
        AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
      )"
    fi
  elif [[ "$folder" == "sent" || "$folder_id" == "2" ]]; then
    # 已发送：只搜索当前用户发送的邮件
    if [ "$user" = "xm" ]; then
      where_clause="$where_clause AND e.from_addr = 'xm@localhost'"
    else
      where_clause="$where_clause AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%')"
    fi
  elif [[ "$folder" == "drafts" || "$folder_id" == "3" ]]; then
    # 草稿箱：只搜索当前用户的草稿
    if [ "$user" = "xm" ]; then
      where_clause="$where_clause AND e.from_addr = 'xm@localhost'"
    else
      where_clause="$where_clause AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%')"
    fi
  elif [[ "$folder" == "trash" || "$folder_id" == "4" ]]; then
    # 已删除：搜索当前用户的已删除邮件
    if [ "$user" = "xm" ]; then
      where_clause="$where_clause AND (e.from_addr = 'xm@localhost' OR EXISTS (
        SELECT 1 FROM email_recipients er 
        WHERE er.email_id = e.id 
        AND er.recipient_type IN ('to', 'cc') 
        AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
      ))"
    else
      where_clause="$where_clause AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%' OR EXISTS (
        SELECT 1 FROM email_recipients er 
        WHERE er.email_id = e.id 
        AND er.recipient_type IN ('to', 'cc') 
        AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
      ))"
    fi
  elif [[ "$folder" == "spam" || "$folder_id" == "5" ]]; then
    # 垃圾邮件：搜索当前用户的垃圾邮件
    if [ "$user" = "xm" ]; then
      where_clause="$where_clause AND EXISTS (
        SELECT 1 FROM email_recipients er 
        WHERE er.email_id = e.id 
        AND er.recipient_type IN ('to', 'cc') 
        AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
      )"
    else
      where_clause="$where_clause AND EXISTS (
        SELECT 1 FROM email_recipients er 
        WHERE er.email_id = e.id 
        AND er.recipient_type IN ('to', 'cc') 
        AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
      )"
    fi
  else
    # 其他文件夹或全部：根据用户过滤
    if [ "$user" = "xm" ]; then
      where_clause="$where_clause AND (e.from_addr = 'xm@localhost' OR EXISTS (
        SELECT 1 FROM email_recipients er 
        WHERE er.email_id = e.id 
        AND er.recipient_type IN ('to', 'cc') 
        AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
      ))"
    else
      where_clause="$where_clause AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%' OR EXISTS (
        SELECT 1 FROM email_recipients er 
        WHERE er.email_id = e.id 
        AND er.recipient_type IN ('to', 'cc') 
        AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
      ))"
    fi
  fi
  
  # 添加搜索条件（模糊查询：主题、内容、发件人、收件人）
  where_clause="$where_clause AND (
    e.subject LIKE '%$escaped_query%' 
    OR e.body LIKE '%$escaped_query%' 
    OR e.from_addr LIKE '%$escaped_query%' 
    OR e.to_addr LIKE '%$escaped_query%'
    OR e.cc_addr LIKE '%$escaped_query%'
    OR EXISTS (
      SELECT 1 FROM email_recipients er
      WHERE er.email_id = e.id
      AND er.email_address LIKE '%$escaped_query%'
    )
  )"
  
  # 构建用户邮箱地址匹配条件（用于read和read_status字段的计算）
  local user_email_condition=""
  if [[ -n "$user" ]]; then
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址，直接精确匹配
      user_email_condition="er_user.email_address = '$user'"
    elif [ "$user" = "xm" ]; then
      # 特殊处理xm用户，支持多种邮箱格式
      user_email_condition="(er_user.email_address = 'xm@localhost' OR er_user.email_address LIKE '%@xm' OR er_user.email_address LIKE 'xm@%')"
    else
      # 其他用户：支持多种邮箱格式匹配
      user_email_condition="(er_user.email_address = '$user' OR er_user.email_address LIKE '%@$user' OR er_user.email_address LIKE '$user@%')"
    fi
  fi
  
  # 如果user_email_condition为空，设置为永远为假的条件
  if [[ -z "$user_email_condition" ]]; then
    user_email_condition="1=0"
  fi
  
  # 为子查询创建WHERE子句（将e.替换为e2.）
  local where_clause_subquery=$(echo "$where_clause" | sed 's/\be\./e2./g')
  
  # 执行搜索查询（使用去重逻辑，确保同一封邮件的多个记录只返回一个）
  # 先找到所有匹配搜索条件的邮件，然后对每个base_message_id只选择一条记录（使用MIN(id)）
  local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'id', e.id,
        'message_id', e.message_id,
        'from', e.from_addr,
        'to', e.to_addr,
        'cc', COALESCE(e.cc_addr, ''),
        'subject', e.subject,
        'date', e.date_received,
        'read', CASE 
          WHEN e.folder_id = 2 AND e.from_addr = COALESCE((SELECT email FROM mail_users WHERE username='$user' LIMIT 1), '$user') THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '%@$user' THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '$user@%' THEN COALESCE(e.read_status, 0)
          ELSE COALESCE((
            -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则显示为未读
            -- 只考虑相同folder_id的记录，避免sent文件夹的记录影响收件箱的已读状态
            SELECT MIN(er2.is_read) FROM email_recipients er2 
            JOIN emails e3 ON er2.email_id = e3.id
            WHERE SUBSTRING_INDEX(e3.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
              AND e3.folder_id = e.folder_id
              AND er2.recipient_type IN ('to', 'cc')
              AND ($(echo "$user_email_condition" | sed 's/er_user\./er2./g'))
          ), 0)
        END,
        'read_status', CASE 
          WHEN e.folder_id = 2 AND e.from_addr = COALESCE((SELECT email FROM mail_users WHERE username='$user' LIMIT 1), '$user') THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '%@$user' THEN COALESCE(e.read_status, 0)
          WHEN e.folder_id = 2 AND e.from_addr LIKE '$user@%' THEN COALESCE(e.read_status, 0)
          ELSE COALESCE((
            -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则显示为未读
            -- 只考虑相同folder_id的记录，避免sent文件夹的记录影响收件箱的已读状态
            SELECT MIN(er2.is_read) FROM email_recipients er2 
            JOIN emails e3 ON er2.email_id = e3.id
            WHERE SUBSTRING_INDEX(e3.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
              AND e3.folder_id = e.folder_id
              AND er2.recipient_type IN ('to', 'cc')
              AND ($(echo "$user_email_condition" | sed 's/er_user\./er2./g'))
          ), 0)
        END,
        'folder', COALESCE(f.name, 'inbox'),
        'size', e.size_bytes,
        'original_folder_id', e.original_folder_id,
        'labels', COALESCE((
          SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
              'id', el.id,
              'name', el.name,
              'display_name', el.display_name,
              'color', el.color
            )
          )
          FROM email_label_relations elr
          JOIN email_labels el ON elr.label_id = el.id
          WHERE elr.email_id = e.id
        ), JSON_ARRAY()),
        'recipients', JSON_OBJECT(
          'to', COALESCE((
            SELECT JSON_ARRAYAGG(email_address)
            FROM email_recipients
            WHERE email_id = e.id AND recipient_type = 'to'
          ), JSON_ARRAY()),
          'cc', COALESCE((
            SELECT JSON_ARRAYAGG(email_address)
            FROM email_recipients
            WHERE email_id = e.id AND recipient_type = 'cc'
          ), JSON_ARRAY()),
          'bcc', COALESCE((
            SELECT JSON_ARRAYAGG(email_address)
            FROM email_recipients
            WHERE email_id = e.id AND recipient_type = 'bcc'
          ), JSON_ARRAY())
        )
      )
    ) as result
    FROM emails e
    LEFT JOIN email_folders f ON e.folder_id = f.id
    WHERE e.id IN (
      SELECT MIN(e2.id)
      FROM emails e2
      $where_clause_subquery
      GROUP BY SUBSTRING_INDEX(e2.message_id, '_', 1)
    )
    ORDER BY e.date_received DESC
    LIMIT $limit OFFSET $offset
  " 2>&1 | tail -1)
  
  # 检查是否有错误信息
  if [[ "$result" =~ "ERROR" ]] || [[ "$result" =~ "error" ]]; then
    echo "[mail_db] 搜索出错: $result" >> "$LOG_DIR/mail-db.log"
    echo "[]"
    return
  fi
  
  echo "[mail_db] 查询结果长度: ${#result}" >> "$LOG_DIR/mail-db.log"
  if [[ ${#result} -gt 0 ]]; then
    echo "[mail_db] 查询结果前200字符: ${result:0:200}" >> "$LOG_DIR/mail-db.log"
  fi
  
  # 如果查询结果为空或null，返回空数组
  if [[ -z "$result" || "$result" == "null" || "$result" == "NULL" ]]; then
    echo "[]"
    return
  fi
  
  # 使用Python处理JSON，确保所有字段格式正确
  local processed_result=$(python3 << PYTHON_EOF
import json
import sys

try:
    emails = json.loads('''$result''')
    if not isinstance(emails, list):
        emails = []
    
    # 确保每个邮件都有必要的字段
    for email in emails:
        if 'labels' not in email or not isinstance(email['labels'], list):
            email['labels'] = []
        if 'recipients' not in email:
            email['recipients'] = {'to': [], 'cc': [], 'bcc': []}
        elif not isinstance(email['recipients'], dict):
            email['recipients'] = {'to': [], 'cc': [], 'bcc': []}
    
    print(json.dumps(emails, ensure_ascii=False))
except Exception as e:
    print(f"Error processing emails: {e}", file=sys.stderr)
    print("[]")
    sys.exit(1)
PYTHON_EOF
)
  
  if [[ -n "$processed_result" ]]; then
    echo "$processed_result"
  else
    echo "[]"
  fi
}

# 获取邮件详情（支持新表结构）
get_email_detail() {
  local email_id="$1"
  local user="$2"
  
  # 参数验证
  if [[ -z "$email_id" ]]; then
    log "错误: 邮件ID不能为空"
    echo "[]"
    return 1
  fi
  
  # 静默记录日志，不输出到标准输出
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 获取邮件详情: id=$email_id, user=$user" >> "$LOG_DIR/mail-db.log"
  
  # 获取当前用户的邮箱地址列表（用于匹配email_recipients表）
  local user_email_condition=""
  if [[ -n "$user" ]]; then
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址，直接精确匹配
      user_email_condition="er_user.email_address = '$user'"
    elif [ "$user" = "xm" ]; then
      # 特殊处理xm用户，支持多种邮箱格式
      user_email_condition="(er_user.email_address = 'xm@localhost' OR er_user.email_address LIKE '%@xm' OR er_user.email_address LIKE 'xm@%')"
    else
      # 普通用户名
      user_email_condition="(er_user.email_address = '$user' OR er_user.email_address LIKE '%@$user' OR er_user.email_address LIKE '$user@%')"
    fi
  fi
  
  # 确保user_email_condition不为空
  if [[ -z "$user_email_condition" ]]; then
    user_email_condition="1=0"  # 如果为空，使用永远为假的条件
  fi
  
  # 查询邮件基本信息（JOIN email_folders表，包含优先级和重要性）
  # 注意：允许查询已删除文件夹中的邮件（folder_id=4），所以不检查is_deleted
  # 重要：使用email_recipients.is_read来获取当前用户的已读状态，而不是emails.read_status
  # 注意：使用JSON_QUOTE确保body和html_body字段中的特殊字符被正确转义
  # 修复：先检查邮件是否存在，如果存在则查询，避免权限检查导致邮件无法访问
  local email_exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT COUNT(*) FROM emails WHERE id='$email_id' AND (is_deleted=0 OR folder_id=4);" 2>/dev/null | tail -1)
  
  if [[ "$email_exists" -eq 0 ]]; then
    echo "[mail_db] 邮件ID=$email_id 不存在或已删除" >> "$LOG_DIR/mail-db.log"
    echo "[]"
    return 1
  fi
  
  # 检查用户是否有权限访问此邮件
  # 1. 如果是已发送文件夹（folder_id=2），检查发件人是否是当前用户
  # 2. 如果是收件箱或其他文件夹，检查email_recipients表中是否有当前用户的记录
  local has_permission=0
  local folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT folder_id FROM emails WHERE id='$email_id' LIMIT 1;" 2>/dev/null | tail -1)
  local from_addr=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT from_addr FROM emails WHERE id='$email_id' LIMIT 1;" 2>/dev/null | tail -1)
  
  if [[ "$folder_id" == "2" || "$folder_id" == "3" ]]; then
    # 已发送或草稿箱：检查发件人是否是当前用户（草稿作者=发件人，否则无法读取/编辑草稿）
    if [[ "$user" == *@* ]]; then
      if [[ "$from_addr" == "$user" ]]; then
        has_permission=1
      fi
    elif [ "$user" = "xm" ]; then
      if [[ "$from_addr" == "xm@localhost" ]] || [[ "$from_addr" == *@xm ]] || [[ "$from_addr" == xm@* ]]; then
        has_permission=1
      fi
    else
      if [[ "$from_addr" == "$user" ]] || [[ "$from_addr" == *@$user ]] || [[ "$from_addr" == $user@* ]]; then
        has_permission=1
      fi
    fi
  else
    # 收件箱或其他文件夹：检查email_recipients表中是否有当前用户的记录
    # 构建权限检查条件（email_recipients表中字段名是email_address，不是er_user.email_address）
    local permission_condition=""
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址，直接精确匹配
      permission_condition="email_address = '$user'"
    elif [ "$user" = "xm" ]; then
      # 特殊处理xm用户，支持多种邮箱格式
      permission_condition="(email_address = 'xm@localhost' OR email_address LIKE '%@xm' OR email_address LIKE 'xm@%')"
    else
      # 普通用户名
      permission_condition="(email_address = '$user' OR email_address LIKE '%@$user' OR email_address LIKE '$user@%')"
    fi
    
    echo "[mail_db] 权限检查: email_id=$email_id, user=$user, permission_condition=$permission_condition" >> "$LOG_DIR/mail-db.log"
    
    local recipient_count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT COUNT(*) FROM email_recipients 
      WHERE email_id='$email_id' 
        AND recipient_type IN ('to', 'cc')
        AND ($permission_condition);
    " 2>/dev/null | tail -1)
    
    echo "[mail_db] 权限检查结果: recipient_count=$recipient_count" >> "$LOG_DIR/mail-db.log"
    
    if [[ "$recipient_count" =~ ^[0-9]+$ ]] && [[ $recipient_count -gt 0 ]]; then
      has_permission=1
      echo "[mail_db] 权限检查通过: 用户 $user 有权限访问邮件ID=$email_id" >> "$LOG_DIR/mail-db.log"
    else
      echo "[mail_db] 权限检查失败: recipient_count=$recipient_count (不是有效数字或为0)" >> "$LOG_DIR/mail-db.log"
    fi
  fi
  
  if [[ $has_permission -eq 0 ]]; then
    echo "[mail_db] 用户 $user 无权限访问邮件ID=$email_id (folder_id=$folder_id, from_addr=$from_addr)" >> "$LOG_DIR/mail-db.log"
    echo "[]"
    return 1
  fi
  
  local email_basic=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_OBJECT(
      'id', e.id,
      'message_id', e.message_id,
      'from', e.from_addr,
      'to', e.to_addr,
      'cc', COALESCE(e.cc_addr, ''),
      'subject', e.subject,
      'body', JSON_UNQUOTE(JSON_QUOTE(COALESCE(e.body, ''))),
      'html', JSON_UNQUOTE(JSON_QUOTE(COALESCE(e.html_body, ''))),
      'date', e.date_received,
      'read', CASE 
        WHEN e.folder_id = 2 AND e.from_addr = COALESCE((SELECT email FROM mail_users WHERE username='$user' LIMIT 1), '$user') THEN COALESCE(e.read_status, 0)
        WHEN e.folder_id = 2 AND e.from_addr LIKE '%@$user' THEN COALESCE(e.read_status, 0)
        WHEN e.folder_id = 2 AND e.from_addr LIKE '$user@%' THEN COALESCE(e.read_status, 0)
        ELSE COALESCE((
          -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则显示为未读
          SELECT MIN(er2.is_read) FROM email_recipients er2 
          JOIN emails e3 ON er2.email_id = e3.id
          WHERE SUBSTRING_INDEX(e3.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
            AND er2.recipient_type IN ('to', 'cc')
            AND ($(echo "$user_email_condition" | sed 's/er_user\./er2./g'))
        ), 0)
      END,
      'read_status', CASE 
        WHEN e.folder_id = 2 AND e.from_addr = COALESCE((SELECT email FROM mail_users WHERE username='$user' LIMIT 1), '$user') THEN COALESCE(e.read_status, 0)
        WHEN e.folder_id = 2 AND e.from_addr LIKE '%@$user' THEN COALESCE(e.read_status, 0)
        WHEN e.folder_id = 2 AND e.from_addr LIKE '$user@%' THEN COALESCE(e.read_status, 0)
        ELSE COALESCE((
          -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则显示为未读
          SELECT MIN(er2.is_read) FROM email_recipients er2 
          JOIN emails e3 ON er2.email_id = e3.id
          WHERE SUBSTRING_INDEX(e3.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
            AND er2.recipient_type IN ('to', 'cc')
            AND ($(echo "$user_email_condition" | sed 's/er_user\./er2./g'))
        ), 0)
      END,
      'folder', COALESCE(f.name, 'inbox'),
      'size', e.size_bytes,
      'headers', COALESCE(e.headers, '{}'),
      'original_folder_id', e.original_folder_id
    ) as email
    FROM emails e
    LEFT JOIN email_folders f ON e.folder_id = f.id
    WHERE e.id='$email_id' AND (e.is_deleted=0 OR e.folder_id=4)
    LIMIT 1;
  " 2>/dev/null | grep -v "email" | grep -v "^$" | head -1)
  
  echo "[mail_db] 邮件详情查询结果: email_id=$email_id, user=$user, email_basic长度=${#email_basic}" >> "$LOG_DIR/mail-db.log"
  
  # 调试：检查body字段内容
  if [[ -n "$email_basic" && "$email_basic" != "null" ]]; then
    local body_content=$(echo "$email_basic" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('body', 'NOT_FOUND')[:100] if data.get('body') else 'NULL_OR_EMPTY')" 2>/dev/null || echo "PARSE_ERROR")
    echo "[mail_db] 调试: email_id=$email_id, body字段前100字符: $body_content" >> "$LOG_DIR/mail-db.log"
  fi
  
  if [[ -z "$email_basic" || "$email_basic" == "null" ]]; then
    echo "[mail_db] 警告: 邮件详情查询结果为空，可能原因：1) 邮件ID不存在 2) 用户无权限访问 3) 邮件已删除" >> "$LOG_DIR/mail-db.log"
    echo "[mail_db] 调试: 检查邮件是否存在..." >> "$LOG_DIR/mail-db.log"
    local email_exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT COUNT(*) FROM emails WHERE id='$email_id';" 2>/dev/null | tail -1)
    echo "[mail_db] 邮件ID=$email_id 在数据库中是否存在: $email_exists" >> "$LOG_DIR/mail-db.log"
    if [[ "$email_exists" -gt 0 ]]; then
      local email_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT id, message_id, from_addr, to_addr, folder_id, is_deleted FROM emails WHERE id='$email_id' LIMIT 1;" 2>/dev/null)
      echo "[mail_db] 邮件信息: $email_info" >> "$LOG_DIR/mail-db.log"
    fi
    echo "[]"
    return 1
  fi
  
  # 查询附件列表（从email_attachments表）
  local attachments_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'id', id,
        'name', filename,
        'type', content_type,
        'size', size_bytes,
        'content', content_base64
      )
    ) as attachments
    FROM email_attachments
    WHERE email_id='$email_id';
  " 2>/dev/null | grep -v "attachments" | grep -v "^$" | head -1)
  
  # 如果附件表为空，尝试从emails表的attachments字段读取（向后兼容）
  if [[ -z "$attachments_json" || "$attachments_json" == "null" ]]; then
    # 检查emails表是否有attachments字段
    local has_attachments_col=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT COUNT(*) FROM information_schema.COLUMNS 
      WHERE TABLE_SCHEMA='$DB_NAME' 
      AND TABLE_NAME='emails' 
      AND COLUMN_NAME='attachments';
    " 2>/dev/null | tail -1)
    
    if [[ "$has_attachments_col" -gt 0 ]]; then
      attachments_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT attachments FROM emails WHERE id='$email_id' LIMIT 1;
      " 2>/dev/null | tail -1)
    fi
    
    if [[ -z "$attachments_json" || "$attachments_json" == "null" ]]; then
      attachments_json="[]"
    fi
  fi
  
  # 查询收件人列表（从email_recipients表）
  local recipients_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_OBJECT(
      'to', COALESCE((
        SELECT JSON_ARRAYAGG(email_address)
        FROM email_recipients
        WHERE email_id='$email_id' AND recipient_type='to'
      ), JSON_ARRAY()),
      'cc', COALESCE((
        SELECT JSON_ARRAYAGG(email_address)
        FROM email_recipients
        WHERE email_id='$email_id' AND recipient_type='cc'
      ), JSON_ARRAY()),
      'bcc', COALESCE((
        SELECT JSON_ARRAYAGG(email_address)
        FROM email_recipients
        WHERE email_id='$email_id' AND recipient_type='bcc'
      ), JSON_ARRAY())
    ) as recipients;
  " 2>/dev/null | grep -v "recipients" | grep -v "^$" | head -1)
  
  if [[ -z "$recipients_json" || "$recipients_json" == "null" ]]; then
    recipients_json='{"to":[],"cc":[],"bcc":[]}'
  fi
  
  # 查询标签列表（从email_label_relations和email_labels表）
  local labels_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'id', el.id,
        'name', el.name,
        'display_name', el.display_name,
        'color', el.color
      )
    ) as labels
    FROM email_label_relations elr
    JOIN email_labels el ON elr.label_id = el.id
    WHERE elr.email_id='$email_id';
  " 2>/dev/null | grep -v "labels" | grep -v "^$" | head -1)
  
  if [[ -z "$labels_json" || "$labels_json" == "null" ]]; then
    labels_json="[]"
  fi
  
  # 查询元数据（从email_metadata表）
  local metadata_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_OBJECT(
      'reply_to', COALESCE(reply_to, ''),
      'in_reply_to', COALESCE(in_reply_to, ''),
      'thread_id', COALESCE(thread_id, ''),
      'spam_score', COALESCE(spam_score, 0),
      'virus_status', COALESCE(virus_status, 'clean'),
      'encryption_status', COALESCE(encryption_status, 'none'),
      'signature_status', COALESCE(signature_status, 'none')
    ) as metadata
    FROM email_metadata
    WHERE email_id='$email_id'
    LIMIT 1;
  " 2>/dev/null | grep -v "metadata" | grep -v "^$" | head -1)
  
  if [[ -z "$metadata_json" || "$metadata_json" == "null" ]]; then
    metadata_json='{}'
  fi
  
  # 合并JSON数据（确保attachments是数组格式）
  # 注意：email_basic可能包含换行符等特殊字符，需要通过文件传递而不是heredoc
  local temp_json_file=$(mktemp /tmp/mail_db_json_XXXXXX)
  echo "$email_basic" > "$temp_json_file"
  
  local final_json=$(python3 << PYTHON_EOF
import json
import sys
import os

try:
    # 从文件读取email_basic，避免heredoc中的换行符问题
    temp_file = '''$temp_json_file'''
    with open(temp_file, 'r', encoding='utf-8') as f:
        email_basic_str = f.read()
    
    # 先尝试解析email_basic
    try:
        email = json.loads(email_basic_str)
    except json.JSONDecodeError as e:
        # 如果解析失败，尝试修复控制字符
        import re
        # 移除无效的控制字符（保留换行符\n和制表符\t）
        fixed_basic = re.sub(r'[\x00-\x08\x0b-\x0c\x0e-\x1f]', '', email_basic_str)
        email = json.loads(fixed_basic)
    
    # 处理附件（确保是数组格式）
    try:
        attachments = json.loads('''$attachments_json''')
        if not isinstance(attachments, list):
            attachments = []
    except:
        attachments = []
    
    # 处理收件人
    try:
        recipients = json.loads('''$recipients_json''')
    except:
        recipients = {"to":[],"cc":[],"bcc":[]}
    
    # 处理标签（确保是数组格式）
    try:
        labels = json.loads('''$labels_json''')
        if not isinstance(labels, list):
            labels = []
    except:
        labels = []
    
    # 处理元数据
    try:
        metadata = json.loads('''$metadata_json''')
        if not isinstance(metadata, dict):
            metadata = {}
    except:
        metadata = {}
    
    # 确保body和html字段是字符串（处理None值）
    if 'body' in email:
        if email['body'] is None:
            email['body'] = ''
        elif not isinstance(email['body'], str):
            email['body'] = str(email['body'])
    else:
        email['body'] = ''
    
    if 'html' in email:
        if email['html'] is None:
            email['html'] = ''
        elif not isinstance(email['html'], str):
            email['html'] = str(email['html'])
    else:
        email['html'] = ''
    
    # 合并数据
    email['attachments'] = attachments
    email['recipients'] = recipients
    email['labels'] = labels
    email['metadata'] = metadata
    
    # 输出JSON数组格式（保持向后兼容，后端期望数组格式）
    # 使用ensure_ascii=False保留非ASCII字符，但确保控制字符被正确转义
    print(json.dumps([email], ensure_ascii=False, separators=(',', ':')))
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    import traceback
    traceback.print_exc(file=sys.stderr)
    print("[]")
    sys.exit(1)
finally:
    # 清理临时文件
    if os.path.exists(temp_file):
        os.remove(temp_file)
PYTHON_EOF
)
  
  # 清理临时文件（如果Python没有清理）
  rm -f "$temp_json_file" 2>/dev/null || true
  
  # 标记为已读
  # 收件箱（folder_id=1）：更新email_recipients表中当前用户对应的is_read状态（收件人级别的已读状态）
  # 已发送（folder_id=2）：更新emails.read_status字段（发件人级别的已读状态，不影响收件箱未读计数）
  # 重要：需要更新同一封邮件的所有email_id对应的收件人记录，确保统计查询和列表查询都能正确显示已读状态
  if [[ -n "$user" && -n "$user_email_condition" && "$user_email_condition" != "1=0" ]]; then
    # 获取该邮件的message_id，用于查找所有相关记录
    local message_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT message_id FROM emails WHERE id='$email_id' LIMIT 1;" 2>/dev/null | tail -1)
  
    if [[ -n "$message_id" ]]; then
      # 提取base_message_id（使用SUBSTRING_INDEX逻辑，取第一个_之前的部分）
      # 这与查询中的SUBSTRING_INDEX(message_id, '_', 1)保持一致
      local base_message_id=$(echo "$message_id" | cut -d'_' -f1)
      
      # 转义特殊字符，避免SQL注入
      local escaped_base_message_id=$(echo "$base_message_id" | sed "s/'/''/g" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g')
    
      # 获取所有具有相同base_message_id的邮件ID
      local email_ids=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT id FROM emails WHERE SUBSTRING_INDEX(message_id, '_', 1) = '${escaped_base_message_id}';
      " 2>/dev/null)
      
      # 更新所有相关邮件的已读状态
      local updated_count=0
      local sent_updated_count=0
      while IFS= read -r eid; do
        if [[ -n "$eid" && "$eid" =~ ^[0-9]+$ ]]; then
          # 检查邮件所在的文件夹ID和发件人
          local folder_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT folder_id, from_addr FROM emails WHERE id=$eid LIMIT 1;" 2>/dev/null | tail -1)
          local folder_id=$(echo "$folder_info" | cut -f1)
          local from_addr=$(echo "$folder_info" | cut -f2)
          
          if [[ "$folder_id" == "1" ]]; then
            # 收件箱：更新email_recipients表中的is_read状态
            local update_condition=$(echo "$user_email_condition" | sed 's/er_user\./er./g')
            local update_result=$(mysql_connect "UPDATE email_recipients er 
              SET er.is_read = 1, er.read_at = CURRENT_TIMESTAMP 
              WHERE er.email_id = $eid 
                AND er.recipient_type IN ('to', 'cc')
                AND $update_condition;" 2>&1)
            if [[ $? -eq 0 ]]; then
              # 使用mysql_connect执行UPDATE后，ROW_COUNT()需要在同一个连接中立即查询
              # 但mysql_connect每次都是新连接，所以我们需要直接查询更新的记录数
              local count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
                SELECT COUNT(*) FROM email_recipients er 
                WHERE er.email_id = $eid 
                  AND er.recipient_type IN ('to', 'cc')
                  AND $update_condition
                  AND er.is_read = 1;
              " 2>/dev/null | tail -1)
              if [[ "$count" =~ ^[0-9]+$ ]] && [[ $count -gt 0 ]]; then
                updated_count=$((updated_count + count))
              fi
            fi
          elif [[ "$folder_id" == "2" ]]; then
            # 已发送文件夹：更新emails.read_status字段（发件人级别的已读状态）
            # 检查发件人是否是当前用户
            local from_match=0
            if [[ "$user" == *@* ]]; then
              if [[ "$from_addr" == "$user" ]]; then
                from_match=1
              fi
            elif [ "$user" = "xm" ]; then
              if [[ "$from_addr" == "xm@localhost" ]] || [[ "$from_addr" == *@xm ]] || [[ "$from_addr" == xm@* ]]; then
                from_match=1
              fi
            else
              if [[ "$from_addr" == "$user" ]] || [[ "$from_addr" == *@$user ]] || [[ "$from_addr" == $user@* ]]; then
                from_match=1
              fi
            fi
            
            if [[ $from_match -eq 1 ]]; then
              local update_result=$(mysql_connect "UPDATE emails SET read_status = 1 WHERE id = $eid;" 2>&1)
              if [[ $? -eq 0 ]]; then
                sent_updated_count=$((sent_updated_count + 1))
              fi
            fi
          fi
        fi
      done <<< "$email_ids"
      
      if [[ $updated_count -gt 0 ]] || [[ $sent_updated_count -gt 0 ]]; then
        log "邮件详情查询：已标记邮件 $email_id (base_message_id: $base_message_id) 为已读（用户: $user，收件箱更新了 $updated_count 条记录，已发送更新了 $sent_updated_count 条记录）"
  else
        # 调试：检查为什么没有更新成功
        local debug_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
          SELECT COUNT(*) as total, 
                 SUM(CASE WHEN er.is_read=1 THEN 1 ELSE 0 END) as already_read,
                 GROUP_CONCAT(DISTINCT er.email_address) as addresses
          FROM email_recipients er 
          WHERE er.email_id IN ($(echo "$email_ids" | tr '\n' ',' | sed 's/,$//'))
            AND er.recipient_type IN ('to', 'cc');
        " 2>/dev/null | tail -1)
        log "警告: 邮件详情查询时标记为已读失败：未找到匹配的记录（用户: $user，email_id: $email_id，base_message_id: $base_message_id，email_ids: $email_ids，调试信息: $debug_info，user_email_condition: $user_email_condition）"
      fi
    else
      log "警告: 无法获取邮件 $email_id 的message_id，跳过标记为已读"
    fi
  else
    log "警告: 用户参数为空，无法更新已读状态"
  fi
  
  if [[ -n "$final_json" ]]; then
    echo "$final_json"
  else
    echo "[]"
  fi
}

# 删除邮件（支持软删除）
delete_email() {
  local email_id="$1"
  local user="$2"
  
  # 参数验证
  if [[ -z "$email_id" ]]; then
    log "错误: 邮件ID不能为空"
    return 1
  fi
  
  log "删除邮件: id=$email_id, user=$user"
  
  # 软删除：标记为已删除，而不是真正删除（保留数据）
  mysql_connect "UPDATE emails SET is_deleted=1, updated_at=CURRENT_TIMESTAMP WHERE id='$email_id'"
  
  # 可选：如果确实需要硬删除，可以取消下面的注释
  # mysql_connect "DELETE FROM emails WHERE id='$email_id'"
  # 注意：由于外键约束，email_attachments和email_recipients表的记录会自动删除
  
  log "邮件删除成功: id=$email_id（软删除）"
}

# 还原邮件（从已删除文件夹恢复到原文件夹）
restore_email() {
  local email_id="$1"
  local user="$2"
  
  # 参数验证
  if [[ -z "$email_id" ]]; then
    log "错误: 邮件ID不能为空"
    return 1
  fi
  
  log "还原邮件: id=$email_id, user=$user"
  
  # 获取原文件夹ID
  local original_folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT original_folder_id FROM emails WHERE id='$email_id' LIMIT 1;
  " 2>/dev/null | tail -1)
  
  if [[ -z "$original_folder_id" || "$original_folder_id" == "NULL" ]]; then
    # 如果没有原文件夹记录，默认恢复到收件箱（id=1）
    original_folder_id=1
    log "警告: 邮件 $email_id 没有原文件夹记录，将恢复到收件箱"
  fi
  
  # 还原邮件到原文件夹
  mysql_connect "UPDATE emails SET folder_id=$original_folder_id, original_folder_id=NULL, updated_at=CURRENT_TIMESTAMP WHERE id='$email_id'"
  
  log "邮件还原成功: id=$email_id, folder_id=$original_folder_id"
}

# 彻底删除邮件（硬删除）
hard_delete_email() {
  local email_id="$1"
  local user="$2"
  
  # 参数验证
  if [[ -z "$email_id" ]]; then
    log "错误: 邮件ID不能为空"
    return 1
  fi
  
  log "彻底删除邮件: id=$email_id, user=$user"
  
  # 硬删除：真正删除邮件记录
  # 注意：由于外键约束，email_attachments和email_recipients表的记录会自动删除
  mysql_connect "DELETE FROM emails WHERE id='$email_id'"
  
  log "邮件彻底删除成功: id=$email_id"
}

# 移动邮件到文件夹（支持新表结构）
move_email() {
  local email_id="$1"
  local folder="$2"
  local user="$3"
  
  # 参数验证
  if [[ -z "$email_id" || -z "$folder" ]]; then
    log "错误: 邮件ID和文件夹不能为空"
    return 1
  fi
  
  log "移动邮件: id=$email_id, folder=$folder, user=$user"
  
  # 获取文件夹ID（支持向后兼容）
  local folder_id=""
  if [[ "$folder" =~ ^[0-9]+$ ]]; then
    folder_id="$folder"
  else
    local folder_query="SELECT id FROM email_folders WHERE name='$folder' LIMIT 1;"
    folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$folder_query" 2>/dev/null | tail -1)
    if [[ -z "$folder_id" || ! "$folder_id" =~ ^[0-9]+$ ]]; then
      log "错误: 文件夹 '$folder' 不存在"
      return 1
    fi
  fi
  
  # 获取当前文件夹ID（用于记录原文件夹）
  local current_folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT folder_id FROM emails WHERE id='$email_id' LIMIT 1;
  " 2>/dev/null | tail -1)
  
  # 如果移动到trash（id=4），记录原文件夹
  local update_sql="UPDATE emails SET folder_id=$folder_id, updated_at=CURRENT_TIMESTAMP"
  if [[ "$folder_id" == "4" ]] || [[ "$folder" == "trash" ]]; then
    # 移动到已删除文件夹时，记录原文件夹
    if [[ -n "$current_folder_id" && "$current_folder_id" != "4" ]]; then
      update_sql="$update_sql, original_folder_id=$current_folder_id"
    fi
  fi
  update_sql="$update_sql WHERE id='$email_id'"
  
  mysql_connect "$update_sql"
  
  log "邮件移动成功: id=$email_id, folder_id=$folder_id"
}

# 获取邮件统计
get_mail_stats() {
  local user="$1"
  
  # 静默记录日志，不输出到标准输出
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 获取邮件统计: user=$user" >> "$LOG_DIR/mail-db.log"
  
  # 查询收件箱统计（使用email_recipients.is_read来统计每个用户的未读数量）
  # 重要：只统计当前用户的未读邮件，按邮件去重，避免重复统计
  # 使用子查询获取每封邮件对应的当前用户的is_read状态，然后统计
  # 注意：user参数可能是完整邮箱地址（如xm@skills.com）或用户名（如xm）
  local inbox_stats=""
  if [[ -f "$DB_PASS_FILE" ]]; then
    # 构建用户邮箱地址匹配条件（与mark_email_read函数保持一致）
    local user_email_condition=""
    if [[ -n "$user" ]]; then
      if [[ "$user" == *@* ]]; then
        # 如果传入的是完整邮箱地址，直接精确匹配
        user_email_condition="er.email_address = '$user'"
      elif [ "$user" = "xm" ]; then
        # 特殊处理xm用户，支持多种邮箱格式
        user_email_condition="(er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')"
      else
        # 普通用户名
        user_email_condition="(er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')"
      fi
    fi
    
    if [[ -z "$user_email_condition" ]]; then
      user_email_condition="1=0"  # 如果为空，使用永远为假的条件
    fi
    
    # 收件箱统计：只统计收件人是当前用户的邮件
    # 重要：使用base_message_id去重，确保同一封邮件（即使有多个email_id）只统计一次
    # 注意：不排除发件人是当前用户的邮件，因为用户可能给自己发邮件或发送给多个收件人（包括自己）
    # 收件箱应该显示所有"发送给当前用户"的邮件，不管发件人是谁
      inbox_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT 
          COUNT(*) as total,
          SUM(CASE WHEN user_read_status=0 OR user_read_status IS NULL THEN 1 ELSE 0 END) as unread,
          SUM(CASE WHEN user_read_status=1 THEN 1 ELSE 0 END) as read_count,
          COALESCE(SUM(size_bytes), 0) as total_size
        FROM (
          SELECT 
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MAX(e.size_bytes) as size_bytes,
            -- 对于同一封邮件（相同的base_message_id），如果任何一个email_id对应的收件人记录是未读的，则统计为未读
            -- 使用MIN(er.is_read)来判断：如果MIN=0，说明至少有一个未读；如果MIN=1，说明所有都是已读
            -- 重要：只考虑相同folder_id的记录，避免sent文件夹的记录影响收件箱的未读统计
            COALESCE((
              SELECT MIN(er.is_read) FROM email_recipients er 
              JOIN emails e2 ON er.email_id = e2.id
              WHERE SUBSTRING_INDEX(e2.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
                AND e2.folder_id = e.folder_id
                AND er.recipient_type IN ('to', 'cc')
                AND ($user_email_condition)
            ), 0) as user_read_status
        FROM emails e
        WHERE e.folder_id=1 AND e.is_deleted=0
            AND EXISTS (
              SELECT 1 FROM email_recipients er
              WHERE er.email_id = e.id
                AND er.recipient_type IN ('to', 'cc')
                AND ($user_email_condition)
          )
          GROUP BY SUBSTRING_INDEX(e.message_id, '_', 1)
        ) as email_stats;
      " 2>/dev/null)
    fi
  
  # 查询已发送文件夹统计（folder_id=2）
  # 重要：已发送文件夹不显示未读计数，因为未读计数是收件人级别的，不应该影响发件人的收件箱统计
  # 已发送文件夹只显示总数和总大小，不显示未读/已读数量
  # 注意：user参数可能是完整邮箱地址（如xm@skills.com）或用户名（如xm）
  local sent_stats=""
  if [[ -f "$DB_PASS_FILE" ]]; then
    # 构建发件人邮箱地址匹配条件
    local from_addr_condition=""
    if [[ -n "$user" ]]; then
      if [[ "$user" == *@* ]]; then
        # 如果传入的是完整邮箱地址，直接精确匹配
        from_addr_condition="e.from_addr = '$user'"
      elif [ "$user" = "xm" ]; then
        # 特殊处理xm用户，支持多种邮箱格式
        from_addr_condition="(e.from_addr = 'xm@localhost' OR e.from_addr LIKE '%@xm' OR e.from_addr LIKE 'xm@%')"
      else
        # 普通用户名
        from_addr_condition="(e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%')"
      fi
    fi
    
    if [[ -z "$from_addr_condition" ]]; then
      from_addr_condition="1=0"  # 如果为空，使用永远为假的条件
    fi
    
      sent_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT
          COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) as total,
          0 as unread,
          0 as read_count,
          COALESCE(SUM(DISTINCT e.size_bytes), 0) as total_size
          FROM emails e
        WHERE e.folder_id=2 AND e.is_deleted=0 AND ($from_addr_condition);
      " 2>/dev/null)
  fi
  
  # 解析收件箱统计
  local inbox_total=0
  local inbox_unread=0
  local inbox_read=0
  local inbox_size=0
  
  if [[ -n "$inbox_stats" ]]; then
    inbox_total=$(echo "$inbox_stats" | cut -f1 | sed 's/NULL/0/g')
    inbox_unread=$(echo "$inbox_stats" | cut -f2 | sed 's/NULL/0/g')
    inbox_read=$(echo "$inbox_stats" | cut -f3 | sed 's/NULL/0/g')
    inbox_size=$(echo "$inbox_stats" | cut -f4 | sed 's/NULL/0/g')
  fi
  
  # 解析发件箱统计
  local sent_total=0
  local sent_unread=0
  local sent_read=0
  local sent_size=0
  
  if [[ -n "$sent_stats" ]]; then
    sent_total=$(echo "$sent_stats" | cut -f1 | sed 's/NULL/0/g')
    sent_unread=$(echo "$sent_stats" | cut -f2 | sed 's/NULL/0/g')
    sent_read=$(echo "$sent_stats" | cut -f3 | sed 's/NULL/0/g')
    sent_size=$(echo "$sent_stats" | cut -f4 | sed 's/NULL/0/g')
  fi
  
  # 查询草稿箱统计（folder_id=3，使用base_message_id去重）
  local drafts_stats=""
  if [[ -f "$DB_PASS_FILE" ]]; then
    if [ "$user" = "xm" ]; then
      drafts_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT
          COUNT(DISTINCT base_message_id) as total,
          SUM(CASE WHEN min_read_status=0 THEN 1 ELSE 0 END) as unread,
          SUM(CASE WHEN min_read_status=1 THEN 1 ELSE 0 END) as read_count,
          COALESCE(SUM(size_bytes), 0) as total_size
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MIN(e.read_status) as min_read_status,
            MAX(e.size_bytes) as size_bytes
          FROM emails e
          WHERE e.folder_id=3 AND e.is_deleted=0 AND e.from_addr = 'xm@localhost'
          GROUP BY base_message_id
        ) AS subquery;
      " 2>/dev/null)
    else
      drafts_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT
          COUNT(DISTINCT base_message_id) as total,
          SUM(CASE WHEN min_read_status=0 THEN 1 ELSE 0 END) as unread,
          SUM(CASE WHEN min_read_status=1 THEN 1 ELSE 0 END) as read_count,
          COALESCE(SUM(size_bytes), 0) as total_size
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MIN(e.read_status) as min_read_status,
            MAX(e.size_bytes) as size_bytes
          FROM emails e
          WHERE e.folder_id=3 AND e.is_deleted=0 AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%')
          GROUP BY base_message_id
        ) AS subquery;
      " 2>/dev/null)
    fi
  fi
  
  # 查询已删除统计（folder_id=4，使用base_message_id去重）
  local trash_stats=""
  if [[ -f "$DB_PASS_FILE" ]]; then
    if [ "$user" = "xm" ]; then
      trash_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT
          COUNT(*) as total,
          SUM(CASE WHEN user_read_status=0 OR user_read_status IS NULL THEN 1 ELSE 0 END) as unread,
          SUM(CASE WHEN user_read_status=1 THEN 1 ELSE 0 END) as read_count,
          COALESCE(SUM(size_bytes), 0) as total_size
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MAX(e.size_bytes) as size_bytes,
            -- 对于同一封邮件，如果任何一个email_id对应的收件人记录是未读的，则统计为未读
            -- 重要：只考虑相同folder_id的记录，避免sent文件夹的记录影响统计
            COALESCE((
              SELECT MIN(er.is_read) FROM email_recipients er 
              JOIN emails e2 ON er.email_id = e2.id
              WHERE SUBSTRING_INDEX(e2.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
                AND e2.folder_id = e.folder_id
                AND er.recipient_type IN ('to', 'cc')
                AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
            ), 0) as user_read_status
          FROM emails e
          WHERE e.folder_id=4 AND e.is_deleted=0
          AND (e.from_addr = 'xm@localhost' OR EXISTS (
            SELECT 1 FROM email_recipients er 
            WHERE er.email_id = e.id 
            AND er.recipient_type IN ('to', 'cc') 
            AND (er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')
          ))
          GROUP BY SUBSTRING_INDEX(e.message_id, '_', 1)
        ) as email_stats;
      " 2>/dev/null)
    else
      trash_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT
          COUNT(*) as total,
          SUM(CASE WHEN user_read_status=0 OR user_read_status IS NULL THEN 1 ELSE 0 END) as unread,
          SUM(CASE WHEN user_read_status=1 THEN 1 ELSE 0 END) as read_count,
          COALESCE(SUM(size_bytes), 0) as total_size
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MAX(e.size_bytes) as size_bytes,
            -- 对于同一封邮件，如果任何一个email_id对应的收件人记录是未读的，则统计为未读
            -- 重要：只考虑相同folder_id的记录，避免sent文件夹的记录影响统计
            COALESCE((
              SELECT MIN(er.is_read) FROM email_recipients er 
              JOIN emails e2 ON er.email_id = e2.id
              WHERE SUBSTRING_INDEX(e2.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
                AND e2.folder_id = e.folder_id
                AND er.recipient_type IN ('to', 'cc')
                AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
            ), 0) as user_read_status
          FROM emails e
          WHERE e.folder_id=4 AND e.is_deleted=0
          AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%' OR EXISTS (
            SELECT 1 FROM email_recipients er 
            WHERE er.email_id = e.id 
            AND er.recipient_type IN ('to', 'cc') 
            AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
          ))
          GROUP BY SUBSTRING_INDEX(e.message_id, '_', 1)
        ) as email_stats;
      " 2>/dev/null)
    fi
  fi
  
  # 查询垃圾邮件统计（folder_id=5，使用email_recipients.is_read）
  # 重要：只统计当前用户的未读邮件，按邮件去重
  # 注意：垃圾邮件也应该只统计收件人是当前用户的邮件，排除发件人是当前用户的邮件
  # 注意：user参数可能是完整邮箱地址（如xm@skills.com）或用户名（如xm）
  local spam_stats=""
  if [[ -f "$DB_PASS_FILE" ]]; then
    # 构建用户邮箱地址匹配条件（与mark_email_read函数保持一致）
    local user_email_condition=""
    if [[ -n "$user" ]]; then
      if [[ "$user" == *@* ]]; then
        # 如果传入的是完整邮箱地址，直接精确匹配
        user_email_condition="er.email_address = '$user'"
      elif [ "$user" = "xm" ]; then
        # 特殊处理xm用户，支持多种邮箱格式
        user_email_condition="(er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')"
      else
        # 普通用户名
        user_email_condition="(er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')"
      fi
    fi
    
    if [[ -z "$user_email_condition" ]]; then
      user_email_condition="1=0"  # 如果为空，使用永远为假的条件
    fi
    
    # 垃圾邮件统计：只统计收件人是当前用户的垃圾邮件
    # 注意：不排除发件人是当前用户的邮件，因为用户可能给自己发邮件或发送给多个收件人（包括自己）
      spam_stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT
          COUNT(*) as total,
          SUM(CASE WHEN user_read_status=0 OR user_read_status IS NULL THEN 1 ELSE 0 END) as unread,
          SUM(CASE WHEN user_read_status=1 THEN 1 ELSE 0 END) as read_count,
          COALESCE(SUM(size_bytes), 0) as total_size
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MAX(e.size_bytes) as size_bytes,
            -- 对于同一封邮件，如果任何一个email_id对应的收件人记录是未读的，则统计为未读
            -- 重要：只考虑相同folder_id的记录，避免sent文件夹的记录影响统计
            COALESCE((
              SELECT MIN(er.is_read) FROM email_recipients er 
              JOIN emails e2 ON er.email_id = e2.id
              WHERE SUBSTRING_INDEX(e2.message_id, '_', 1) = SUBSTRING_INDEX(e.message_id, '_', 1)
                AND e2.folder_id = e.folder_id
                AND er.recipient_type IN ('to', 'cc')
                AND ($user_email_condition)
            ), 0) as user_read_status
          FROM emails e
          WHERE e.folder_id=5 AND e.is_deleted=0
            AND EXISTS (
              SELECT 1 FROM email_recipients er
              WHERE er.email_id = e.id
                AND er.recipient_type IN ('to', 'cc')
                AND ($user_email_condition)
          )
          GROUP BY SUBSTRING_INDEX(e.message_id, '_', 1)
        ) as email_stats;
      " 2>/dev/null)
  fi
  
  # 解析草稿箱统计
  local drafts_total=0
  local drafts_unread=0
  local drafts_read=0
  local drafts_size=0
  if [[ -n "$drafts_stats" ]]; then
    drafts_total=$(echo "$drafts_stats" | cut -f1 | sed 's/NULL/0/g')
    drafts_unread=$(echo "$drafts_stats" | cut -f2 | sed 's/NULL/0/g')
    drafts_read=$(echo "$drafts_stats" | cut -f3 | sed 's/NULL/0/g')
    drafts_size=$(echo "$drafts_stats" | cut -f4 | sed 's/NULL/0/g')
  fi
  
  # 解析已删除统计
  local trash_total=0
  local trash_unread=0
  local trash_read=0
  local trash_size=0
  if [[ -n "$trash_stats" ]]; then
    trash_total=$(echo "$trash_stats" | cut -f1 | sed 's/NULL/0/g')
    trash_unread=$(echo "$trash_stats" | cut -f2 | sed 's/NULL/0/g')
    trash_read=$(echo "$trash_stats" | cut -f3 | sed 's/NULL/0/g')
    trash_size=$(echo "$trash_stats" | cut -f4 | sed 's/NULL/0/g')
  fi
  
  # 解析垃圾邮件统计
  local spam_total=0
  local spam_unread=0
  local spam_read=0
  local spam_size=0
  if [[ -n "$spam_stats" ]]; then
    spam_total=$(echo "$spam_stats" | cut -f1 | sed 's/NULL/0/g')
    spam_unread=$(echo "$spam_stats" | cut -f2 | sed 's/NULL/0/g')
    spam_read=$(echo "$spam_stats" | cut -f3 | sed 's/NULL/0/g')
    spam_size=$(echo "$spam_stats" | cut -f4 | sed 's/NULL/0/g')
  fi
  
  # 输出JSON格式的统计信息（包含所有文件夹）
  cat << EOF
{
  "inbox": {
    "total": $inbox_total,
    "unread": $inbox_unread,
    "read": $inbox_read,
    "size": $inbox_size
  },
  "sent": {
    "total": $sent_total,
    "unread": $sent_unread,
    "read": $sent_read,
    "size": $sent_size
  },
  "drafts": {
    "total": $drafts_total,
    "unread": $drafts_unread,
    "read": $drafts_read,
    "size": $drafts_size
  },
  "trash": {
    "total": $trash_total,
    "unread": $trash_unread,
    "read": $trash_read,
    "size": $trash_size
  },
  "spam": {
    "total": $spam_total,
    "unread": $spam_unread,
    "read": $spam_read,
    "size": $spam_size
  }
}
EOF
}

# 获取文件夹列表
get_folders() {
  local user_id="${1:-NULL}"
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 获取文件夹列表 (user_id: $user_id)" >> "$LOG_DIR/mail-db.log"
  
  # 构建查询条件：系统文件夹（user_id为NULL）或当前用户的文件夹
  local where_clause="is_active=1"
  if [[ "$user_id" != "NULL" && -n "$user_id" ]]; then
    # 查询系统文件夹和当前用户的文件夹
    # 注意：需要同时匹配 mail_users 表的 id 和可能的 app_users 表的 id（向后兼容）
    # 如果提供了 user_id，查询该 user_id 的所有文件夹，或者查询用户名匹配的文件夹
    where_clause="is_active=1 AND (folder_type='system' OR (folder_type='user' AND user_id=$user_id))"
    echo "[mail_db] 查询条件: $where_clause" >> "$LOG_DIR/mail-db.log"
    
    # 调试：查询数据库中该用户的所有文件夹
    local debug_query="SELECT id, name, folder_type, user_id, is_active FROM email_folders WHERE folder_type='user' AND user_id=$user_id ORDER BY id DESC;"
    local debug_result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$debug_query" 2>/dev/null)
    echo "[mail_db] 调试：user_id=$user_id 的用户文件夹: $debug_result" >> "$LOG_DIR/mail-db.log"
    
    # 调试：查询所有用户文件夹（用于对比）
    local all_user_folders=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT id, name, folder_type, user_id, is_active FROM email_folders WHERE folder_type='user' ORDER BY id DESC LIMIT 10;" 2>/dev/null)
    echo "[mail_db] 调试：最近10个用户文件夹: $all_user_folders" >> "$LOG_DIR/mail-db.log"
  else
    # 如果没有提供user_id，只返回系统文件夹
    where_clause="is_active=1 AND folder_type='system'"
    echo "[mail_db] 未提供user_id，只查询系统文件夹" >> "$LOG_DIR/mail-db.log"
  fi
  
  # 执行查询并获取结果（使用-N跳过列名，使用-s静默模式）
  local folders_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -N -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'id', id,
        'name', name,
        'display_name', display_name,
        'folder_type', folder_type,
        'user_id', user_id,
        'sort_order', sort_order,
        'is_active', is_active
      )
    ) as folders
    FROM email_folders
    WHERE $where_clause
    ORDER BY sort_order ASC, id ASC;
  " 2>/dev/null | tr -d '\n' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  
  # 如果结果为空或者是null，设置为空数组
  if [[ -z "$folders_json" || "$folders_json" == "null" || "$folders_json" == "NULL" ]]; then
    folders_json="[]"
  fi
  
  # 记录调试信息
  local folder_count=$(echo "$folders_json" | grep -o '"id"' | wc -l)
  echo "[mail_db] 查询结果长度: ${#folders_json}" >> "$LOG_DIR/mail-db.log"
  echo "[mail_db] 返回文件夹数量: $folder_count" >> "$LOG_DIR/mail-db.log"
  if [[ "$folder_count" -eq 0 && "$folders_json" != "[]" ]]; then
    echo "[mail_db] 警告：查询结果可能有问题，JSON: $folders_json" >> "$LOG_DIR/mail-db.log"
  fi
  
  echo "$folders_json"
}

# 添加自定义文件夹
add_folder() {
  local name="$1"
  local display_name="$2"
  local user_id="${3:-NULL}"
  
  if [[ -z "$name" ]]; then
    echo "{\"success\": false, \"error\": \"文件夹名称不能为空\"}"
    exit 1
  fi
  
  # 验证文件夹名称格式（只允许字母、数字、下划线、连字符）
  if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "{\"success\": false, \"error\": \"文件夹名称只能包含字母、数字、下划线和连字符\"}"
    exit 1
  fi
  
  # 转义单引号，防止SQL注入
  local safe_name=$(echo "$name" | sed "s/'/''/g")
  
  # 检查文件夹名称是否已存在（只检查当前用户的文件夹）
  local existing_check=""
  if [[ "$user_id" != "NULL" && -n "$user_id" ]]; then
    existing_check="AND user_id=$user_id"
  else
    existing_check="AND folder_type='system'"
  fi
  
  local existing=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT COUNT(*) FROM email_folders WHERE name='$safe_name' AND is_active=1 $existing_check;
  " 2>/dev/null | tail -1)
  
  if [[ "$existing" -gt 0 ]]; then
    echo "{\"success\": false, \"error\": \"文件夹名称 '$name' 已存在\"}"
    exit 1
  fi
  
  # 获取最大sort_order值
  local max_sort=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT COALESCE(MAX(sort_order), 0) FROM email_folders WHERE folder_type='user';
  " 2>/dev/null | tail -1)
  
  local new_sort=$((max_sort + 1))
  local safe_display_name="${display_name:-$name}"
  
  log "添加自定义文件夹: name=$name, display_name=$safe_display_name, user_id=$user_id"
  
  # 转义显示名称中的单引号，防止SQL注入（name已在前面转义）
  local safe_display=$(echo "$safe_display_name" | sed "s/'/''/g")
  
  mysql_connect "INSERT INTO email_folders (name, display_name, folder_type, user_id, sort_order) VALUES ('$safe_name', '$safe_display', 'user', $user_id, $new_sort);"
  
  if [[ $? -eq 0 ]]; then
    local folder_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT id FROM email_folders WHERE name='$safe_name' AND user_id=$user_id AND is_active=1 LIMIT 1;
    " 2>/dev/null | tail -1)
    
    # 验证文件夹是否创建成功，并获取完整信息
    local folder_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT id, name, display_name, folder_type, user_id, is_active 
      FROM email_folders 
      WHERE id=$folder_id 
      LIMIT 1;
    " 2>/dev/null)
    
    if [[ -n "$folder_info" ]]; then
      # 解析文件夹信息
      local folder_id_val=$(echo "$folder_info" | awk '{print $1}')
      local folder_name_val=$(echo "$folder_info" | awk '{print $2}')
      local folder_display_val=$(echo "$folder_info" | awk '{print $3}')
      local folder_type_val=$(echo "$folder_info" | awk '{print $4}')
      local folder_user_id_val=$(echo "$folder_info" | awk '{print $5}')
      local folder_is_active_val=$(echo "$folder_info" | awk '{print $6}')
      
      log "文件夹创建成功: id=$folder_id_val, name=$folder_name_val, user_id=$folder_user_id_val"
      
      # 返回完整的文件夹信息，包括必要的字段
      echo "{\"success\": true, \"id\": $folder_id_val, \"name\": \"$folder_name_val\", \"display_name\": \"$folder_display_val\", \"folder_type\": \"$folder_type_val\", \"is_active\": $folder_is_active_val, \"user_id\": $folder_user_id_val}"
    else
      echo "{\"success\": false, \"error\": \"文件夹创建失败，无法查询到创建的文件夹\"}"
      exit 1
    fi
  else
    echo "{\"success\": false, \"error\": \"添加文件夹失败，数据库操作错误\"}"
    exit 1
  fi
}

# 更新自定义文件夹
update_folder() {
  local folder_id="$1"
  local name="$2"
  local display_name="$3"
  local user_id="${4:-NULL}"
  
  if [[ -z "$folder_id" ]]; then
    echo "错误: 文件夹ID不能为空"
    exit 1
  fi
  
  # 检查文件夹是否存在且是自定义文件夹
  local folder_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT folder_type, user_id FROM email_folders WHERE id=$folder_id AND is_active=1;
  " 2>/dev/null | tail -1)
  
  if [[ -z "$folder_info" ]]; then
    echo "错误: 文件夹不存在"
    exit 1
  fi
  
  local folder_type=$(echo "$folder_info" | awk '{print $1}')
  local folder_user_id=$(echo "$folder_info" | awk '{print $2}')
  
  if [[ "$folder_type" != "user" ]]; then
    echo "错误: 只能修改自定义文件夹"
    exit 1
  fi
  
  # 检查用户权限：只能修改自己的文件夹
  if [[ "$user_id" != "NULL" && -n "$user_id" ]]; then
    if [[ "$folder_user_id" != "$user_id" ]]; then
      echo "错误: 无权修改其他用户的文件夹"
      exit 1
    fi
  fi
  
  # 如果提供了新名称，检查是否与其他文件夹冲突（只检查当前用户的文件夹）
  if [[ -n "$name" ]]; then
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
      echo "错误: 文件夹名称只能包含字母、数字、下划线和连字符"
      exit 1
    fi
    
    # 转义单引号，防止SQL注入
    local safe_name=$(echo "$name" | sed "s/'/''/g")
    
    local existing_check=""
    if [[ "$user_id" != "NULL" && -n "$user_id" ]]; then
      existing_check="AND user_id=$user_id"
    fi
    
    local existing=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT COUNT(*) FROM email_folders WHERE name='$safe_name' AND id!=$folder_id AND is_active=1 $existing_check;
    " 2>/dev/null | tail -1)
    
    if [[ "$existing" -gt 0 ]]; then
      echo "错误: 文件夹名称 '$name' 已存在"
      exit 1
    fi
  fi
  
  log "更新自定义文件夹: id=$folder_id, name=$name, display_name=$display_name"
  
  # 转义显示名称中的单引号，防止SQL注入（name已在前面转义为safe_name）
  local safe_display_name=""
  if [[ -n "$display_name" ]]; then
    safe_display_name=$(echo "$display_name" | sed "s/'/''/g")
  fi
  
  local update_clause=""
  if [[ -n "$name" ]]; then
    update_clause="name='$safe_name'"
  fi
  if [[ -n "$display_name" ]]; then
    if [[ -n "$update_clause" ]]; then
      update_clause="$update_clause, display_name='$safe_display_name'"
    else
      update_clause="display_name='$safe_display_name'"
    fi
  fi
  
  if [[ -z "$update_clause" ]]; then
    echo "错误: 至少需要提供名称或显示名称之一"
    exit 1
  fi
  
  mysql_connect "UPDATE email_folders SET $update_clause, updated_at=CURRENT_TIMESTAMP WHERE id=$folder_id;"
  
  if [[ $? -eq 0 ]]; then
    echo "{\"success\": true, \"id\": $folder_id}"
  else
    echo "{\"success\": false, \"error\": \"更新文件夹失败\"}"
    exit 1
  fi
}

# 删除自定义文件夹
delete_folder() {
  local folder_id="$1"
  local user_id="${2:-NULL}"
  
  if [[ -z "$folder_id" ]]; then
    echo "错误: 文件夹ID不能为空"
    exit 1
  fi
  
  # 检查文件夹是否存在且是自定义文件夹
  local folder_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT folder_type, user_id FROM email_folders WHERE id=$folder_id AND is_active=1;
  " 2>/dev/null | tail -1)
  
  if [[ -z "$folder_info" ]]; then
    echo "错误: 文件夹不存在"
    exit 1
  fi
  
  local folder_type=$(echo "$folder_info" | awk '{print $1}')
  local folder_user_id=$(echo "$folder_info" | awk '{print $2}')
  
  if [[ "$folder_type" != "user" ]]; then
    echo "错误: 只能删除自定义文件夹"
    exit 1
  fi
  
  # 检查用户权限：只能删除自己的文件夹
  if [[ "$user_id" != "NULL" && -n "$user_id" ]]; then
    if [[ "$folder_user_id" != "$user_id" ]]; then
      echo "错误: 无权删除其他用户的文件夹"
      exit 1
    fi
  fi
  
  log "删除自定义文件夹: id=$folder_id"
  
  # 将文件夹中的邮件移动到已删除文件夹（trash, id=4）
  mysql_connect "UPDATE emails SET folder_id=4 WHERE folder_id=$folder_id;"
  
  # 软删除文件夹（设置is_active=0）
  mysql_connect "UPDATE email_folders SET is_active=0, updated_at=CURRENT_TIMESTAMP WHERE id=$folder_id;"
  
  if [[ $? -eq 0 ]]; then
    echo "{\"success\": true, \"id\": $folder_id}"
  else
    echo "{\"success\": false, \"error\": \"删除文件夹失败\"}"
    exit 1
  fi
}

# 获取文件夹统计信息
get_folder_stats() {
  local folder_id="$1"
  local user="$2"
  
  if [[ -z "$folder_id" ]]; then
    echo "{}"
    return 1
  fi
  
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 获取文件夹统计: folder_id=$folder_id, user=$user" >> "$LOG_DIR/mail-db.log"
  
  local stats=""
  if [[ -f "$DB_PASS_FILE" ]]; then
    if [ "$user" = "xm" ]; then
      stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT JSON_OBJECT(
          'total', COUNT(DISTINCT base_message_id),
          'unread', SUM(CASE WHEN min_read_status=0 THEN 1 ELSE 0 END),
          'read', SUM(CASE WHEN min_read_status=1 THEN 1 ELSE 0 END),
          'size', COALESCE(SUM(size_bytes), 0)
        ) as stats
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MIN(e.read_status) as min_read_status,
            MAX(e.size_bytes) as size_bytes
          FROM emails e
          WHERE e.folder_id=$folder_id AND e.is_deleted=0
          GROUP BY base_message_id
        ) AS subquery;
      " 2>/dev/null | tail -1)
    else
      stats=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT JSON_OBJECT(
          'total', COUNT(DISTINCT base_message_id),
          'unread', SUM(CASE WHEN min_read_status=0 THEN 1 ELSE 0 END),
          'read', SUM(CASE WHEN min_read_status=1 THEN 1 ELSE 0 END),
          'size', COALESCE(SUM(size_bytes), 0)
        ) as stats
        FROM (
          SELECT
            SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
            MIN(e.read_status) as min_read_status,
            MAX(e.size_bytes) as size_bytes
          FROM emails e
          WHERE e.folder_id=$folder_id AND e.is_deleted=0
          AND (e.from_addr = '$user' OR e.from_addr LIKE '%@$user' OR e.from_addr LIKE '$user@%' OR EXISTS (
            SELECT 1 FROM email_recipients er
            WHERE er.email_id = e.id
            AND er.recipient_type IN ('to', 'cc')
            AND (er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')
          ))
          GROUP BY base_message_id
        ) AS subquery;
      " 2>/dev/null | tail -1)
    fi
  fi
  
  if [[ -z "$stats" || "$stats" == "null" ]]; then
    echo '{"total":0,"unread":0,"read":0,"size":0}'
  else
    echo "$stats"
  fi
}

# 获取标签列表
get_labels() {
  echo "[mail_db] $(date '+%Y-%m-%d %H:%M:%S') 获取标签列表" >> "$LOG_DIR/mail-db.log"
  
  local labels_json=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'id', id,
        'name', name,
        'display_name', display_name,
        'color', color,
        'is_system', is_system
      )
    ) as labels
    FROM email_labels
    ORDER BY is_system DESC, id ASC;
  " 2>/dev/null | tail -1)
  
  if [[ -z "$labels_json" || "$labels_json" == "null" ]]; then
    labels_json="[]"
  fi
  
  echo "$labels_json"
}

# 为邮件添加标签
add_email_label() {
  local email_id="$1"
  local label_id="$2"
  
  if [[ -z "$email_id" || -z "$label_id" ]]; then
    log "错误: 邮件ID和标签ID不能为空"
    return 1
  fi
  
  log "为邮件添加标签: email_id=$email_id, label_id=$label_id"
  
  # 检查标签是否存在
  local label_exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT COUNT(*) FROM email_labels WHERE id='$label_id';
  " 2>/dev/null | tail -1)
  
  if [[ "$label_exists" -eq 0 ]]; then
    log "错误: 标签ID $label_id 不存在"
    return 1
  fi
  
  # 检查邮件是否存在
  local email_exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT COUNT(*) FROM emails WHERE id='$email_id' AND is_deleted=0;
  " 2>/dev/null | tail -1)
  
  if [[ "$email_exists" -eq 0 ]]; then
    log "错误: 邮件ID $email_id 不存在或已删除"
    return 1
  fi
  
  # 添加标签关联（使用INSERT IGNORE避免重复）
  mysql_connect "INSERT IGNORE INTO email_label_relations (email_id, label_id) VALUES ('$email_id', '$label_id')"
  
  log "标签添加成功: email_id=$email_id, label_id=$label_id"
}

# 移除邮件标签
remove_email_label() {
  local email_id="$1"
  local label_id="$2"
  
  if [[ -z "$email_id" || -z "$label_id" ]]; then
    log "错误: 邮件ID和标签ID不能为空"
    return 1
  fi
  
  log "移除邮件标签: email_id=$email_id, label_id=$label_id"
  
  # 删除标签关联
  mysql_connect "DELETE FROM email_label_relations WHERE email_id='$email_id' AND label_id='$label_id'"
  
  log "标签移除成功: email_id=$email_id, label_id=$label_id"
}

# 清理旧邮件
cleanup_old_emails() {
  local days="${1:-30}"
  
  log "清理 $days 天前的邮件..."
  
  # 删除旧邮件
  local deleted=$(mysql_connect "DELETE FROM emails WHERE date_received < DATE_SUB(NOW(), INTERVAL $days DAY)" | grep -o '[0-9]*' | head -1)
  
  log "清理完成，删除了 $deleted 封邮件"
}

# 用户管理函数
# 添加邮件用户
add_mail_user() {
  local username="$1"
  local email="$2"
  local display_name="${3:-$username}"
  
  log "添加邮件用户: username=$username, email=$email, display_name=$display_name"
  
  # 检查用户是否已存在
  local exists=$(mysql_connect "SELECT COUNT(*) FROM mail_users WHERE username='$username' OR email='$email'" | tail -1)
  
  if [ "$exists" -gt 0 ]; then
    log "用户已存在: $username"
    return 1
  fi
  
  # 添加用户到mail_users表
  mysql_connect "INSERT INTO mail_users (username, email, display_name, is_active) VALUES ('$username', '$email', '$display_name', 1);"
  
  # 创建邮件目录（Maildir格式）
  local domain="${email#*@}"
  local email_username="${email%%@*}"
  local mail_dir="/var/vmail/${domain}/${email_username}/Maildir"
  local mail_parent="/var/vmail/${domain}/${email_username}"
  
  # 确保vmail用户存在
  id vmail &>/dev/null || useradd -r -u 150 -g mail -d /var/vmail -s /sbin/nologin vmail || true
  
  # 创建邮件目录
  if [[ ! -d "$mail_dir" ]]; then
    log "创建邮件目录: $mail_dir"
    mkdir -p "$mail_dir/new" "$mail_dir/cur" "$mail_dir/tmp" 2>/dev/null || {
      log "警告: 无法创建邮件目录 $mail_dir，可能需要root权限"
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
  
  log "邮件用户添加成功: $username"
}

# 获取邮件用户列表
get_mail_users() {
  log "获取邮件用户列表"
  
  mysql_query_json "SELECT 
    id,
    username,
    email,
    display_name,
    is_active,
    created_at,
    updated_at
  FROM mail_users 
  ORDER BY created_at DESC;"
}

# 更新邮件用户
update_mail_user() {
  local username="$1"
  local email="$2"
  local display_name="${3:-$username}"
  
  log "更新邮件用户: username=$username, email=$email, display_name=$display_name"
  
  mysql_connect "UPDATE mail_users SET email='$email', display_name='$display_name', updated_at=CURRENT_TIMESTAMP WHERE username='$username';"
  
  log "邮件用户更新成功: $username"
}

# 删除邮件用户
delete_mail_user() {
  local username="$1"
  
  log "删除邮件用户: username=$username"
  
  # 检查用户是否有邮件
  local email_count=$(mysql_connect "SELECT COUNT(*) FROM emails WHERE from_addr LIKE '%$username%' OR to_addr LIKE '%$username%'" | tail -1)
  
  if [ "$email_count" -gt 0 ]; then
    log "用户有邮件记录，无法删除: $username"
    return 1
  fi
  
  mysql_connect "DELETE FROM mail_users WHERE username='$username';"
  
  log "邮件用户删除成功: $username"
}

# 获取用户邮件统计
get_user_mail_stats() {
  local username="$1"
  
  log "获取用户邮件统计: username=$username"
  
  mysql_query_json "SELECT 
    'inbox' as folder,
    COUNT(*) as total,
    SUM(CASE WHEN read_status=0 THEN 1 ELSE 0 END) as unread,
    SUM(CASE WHEN read_status=1 THEN 1 ELSE 0 END) as read_count,
    SUM(size_bytes) as total_size
  FROM emails 
  WHERE folder='inbox' AND to_addr LIKE '%$username%'
  UNION ALL
  SELECT 
    'sent' as folder,
    COUNT(*) as total,
    SUM(CASE WHEN read_status=0 THEN 1 ELSE 0 END) as unread,
    SUM(CASE WHEN read_status=1 THEN 1 ELSE 0 END) as read_count,
    SUM(size_bytes) as total_size
  FROM emails 
  WHERE folder='sent' AND from_addr LIKE '%$username%';"
}

# 获取邮件发送趋势统计
# 参数：period (hour/day/week)
get_email_sending_trends() {
  local period="${1:-day}"
  
  log "获取邮件发送趋势统计: period=$period"
  
  if [[ ! -f "$DB_PASS_FILE" ]]; then
    echo "[]"
    return
  fi
  
  local date_format=""
  local time_interval=""
  
  case "$period" in
    "hour")
      # 按小时统计，最近24小时
      date_format="DATE_FORMAT(COALESCE(date_sent, date_received), '%Y-%m-%d %H:00:00')"
      time_interval="DATE_SUB(NOW(), INTERVAL 24 HOUR)"
      ;;
    "day")
      # 按天统计，最近30天
      date_format="DATE(COALESCE(date_sent, date_received))"
      time_interval="DATE_SUB(CURDATE(), INTERVAL 30 DAY)"
      ;;
    "week")
      # 按周统计，最近12周
      date_format="DATE_FORMAT(COALESCE(date_sent, date_received), '%Y-%u')"
      time_interval="DATE_SUB(CURDATE(), INTERVAL 12 WEEK)"
      ;;
    *)
      date_format="DATE(COALESCE(date_sent, date_received))"
      time_interval="DATE_SUB(CURDATE(), INTERVAL 30 DAY)"
      ;;
  esac
  
  # 使用 MySQL JSON 函数直接返回 JSON 格式
  # 根据时间周期计算合理的频率单位
  local frequency_divisor=""
  local frequency_unit=""
  case "$period" in
    "hour")
      # 按小时：频率 = 邮件数量 / 1小时 = 封/小时
      frequency_divisor="1.0"
      frequency_unit="hour"
      ;;
    "day")
      # 按天：频率 = 邮件数量 / 1天 = 封/天（更合理）
      frequency_divisor="1.0"
      frequency_unit="day"
      ;;
    "week")
      # 按周：频率 = 邮件数量 / 7天 = 封/天（平均每天）
      frequency_divisor="7.0"
      frequency_unit="day"
      ;;
    *)
      frequency_divisor="1.0"
      frequency_unit="day"
      ;;
  esac
  
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT JSON_ARRAYAGG(
      JSON_OBJECT(
        'time_label', time_label,
        'email_count', email_count,
        'frequency_per_period', frequency_per_period,
        'frequency_unit', '$frequency_unit'
      )
    ) as result
    FROM (
      SELECT 
        $date_format as time_label,
        COUNT(DISTINCT SUBSTRING_INDEX(message_id, '_', 1)) as email_count,
        COUNT(DISTINCT SUBSTRING_INDEX(message_id, '_', 1)) / $frequency_divisor as frequency_per_period
      FROM emails
      WHERE folder_id = 2 
        AND is_deleted = 0
        AND COALESCE(date_sent, date_received) >= $time_interval
      GROUP BY $date_format
      ORDER BY time_label ASC
    ) as subquery
  " 2>/dev/null | grep -v "result" | grep -v "^$" | head -1 | sed 's/^\[/[/' | sed 's/\]$/]/' | sed 's/null/[]/g' || echo "[]"
}

# 获取发送频率vs发送数量关系统计
# 参数：group_by (user/day) - 按用户或按天分组
get_email_frequency_analysis() {
  local group_by="${1:-user}"
  
  log "获取发送频率vs发送数量关系统计: group_by=$group_by"
  
  if [[ ! -f "$DB_PASS_FILE" ]]; then
    echo "[]"
    return
  fi
  
  if [[ "$group_by" == "user" ]]; then
    # 按用户统计：每个用户的发送频率和发送总量（频率单位：封/天），关联用户表获取显示名称
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'identifier', COALESCE(display_name, identifier, '未知用户'),
          'email', identifier,
          'total_emails', total_emails,
          'frequency_per_day', frequency_per_day
        )
      ) as result
      FROM (
        SELECT 
          e.from_addr as identifier,
          COALESCE(mu.display_name, mu.username, e.from_addr) as display_name,
          COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) as total_emails,
          CASE 
            WHEN TIMESTAMPDIFF(DAY, 
              MIN(COALESCE(e.date_sent, e.date_received)), 
              MAX(COALESCE(e.date_sent, e.date_received))
            ) > 0 
            THEN COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) * 1.0 / 
              TIMESTAMPDIFF(DAY, 
                MIN(COALESCE(e.date_sent, e.date_received)), 
                MAX(COALESCE(e.date_sent, e.date_received))
              ) 
            ELSE COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1))
          END as frequency_per_day
        FROM emails e
        LEFT JOIN mail_users mu ON mu.email = e.from_addr
        WHERE e.folder_id = 2 
          AND e.is_deleted = 0
          AND COALESCE(e.date_sent, e.date_received) >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        GROUP BY e.from_addr, display_name
        HAVING COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) > 0
        ORDER BY total_emails DESC
      ) as subquery
    " 2>/dev/null | grep -v "result" | grep -v "^$" | head -1 | sed 's/^\[/[/' | sed 's/\]$/]/' | sed 's/null/[]/g' || echo "[]"
  else
    # 按天统计：每天的发送频率和发送总量（频率单位：封/天，每天就是邮件数量本身）
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT JSON_ARRAYAGG(
        JSON_OBJECT(
          'identifier', identifier,
          'total_emails', total_emails,
          'frequency_per_day', frequency_per_day
        )
      ) as result
      FROM (
        SELECT 
          DATE(COALESCE(e.date_sent, e.date_received)) as identifier,
          COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) as total_emails,
          COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) * 1.0 as frequency_per_day
        FROM emails e
        WHERE e.folder_id = 2 
          AND e.is_deleted = 0
          AND COALESCE(e.date_sent, e.date_received) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        GROUP BY DATE(COALESCE(e.date_sent, e.date_received))
        HAVING COUNT(DISTINCT SUBSTRING_INDEX(e.message_id, '_', 1)) > 0
        ORDER BY identifier DESC
      ) as subquery
    " 2>/dev/null | grep -v "result" | grep -v "^$" | head -1 | sed 's/^\[/[/' | sed 's/\]$/]/' | sed 's/null/[]/g' || echo "[]"
  fi
}

# 主函数
main() {
  local action="${1:-help}"
  
  case "$action" in
    "init")
      init_mail_db
      ;;
    "store")
      store_email "$2" "$3" "$4" "$5" "$6" "${7:-}" "${8:-inbox}" "${9:-0}" "${10:-}" "${11:-}" "${12:-}" "${13:-0}" "${14:-0}"
      ;;
    "list")
      get_emails "$2" "${3:-inbox}" "${4:-50}" "${5:-0}"
      ;;
    "search")
      search_emails "$2" "$3" "${4:-all}" "${5:-100}" "${6:-0}"
      ;;
    "detail")
      get_email_detail "$2" "$3"
      ;;
    "delete")
      delete_email "$2" "$3"
      ;;
    "restore")
      restore_email "$2" "$3"
      ;;
    "fix-file-paths")
      fix_file_path_emails
      ;;
    "hard-delete")
      hard_delete_email "$2" "$3"
      ;;
    "move")
      move_email "$2" "$3" "$4"
      ;;
    "stats")
      get_mail_stats "$2"
      ;;
    "cleanup")
      cleanup_old_emails "$2"
      ;;
    "add-user")
      add_mail_user "$2" "$3" "$4"
      ;;
    "list-users")
      get_mail_users
      ;;
    "update-user")
      update_mail_user "$2" "$3" "$4"
      ;;
    "delete-user")
      delete_mail_user "$2"
      ;;
    "update-admin-email")
      update_admin_email "$2"
      ;;
    "user-stats")
      get_user_mail_stats "$2"
      ;;
    "sending-trends")
      get_email_sending_trends "$2"
      ;;
    "frequency-analysis")
      get_email_frequency_analysis "$2"
      ;;
    "mark_read")
      mark_email_read "$2" "$3"
      ;;
    "list_domains")
      list_domains
      ;;
    "add_domain")
      add_domain "$2"
      ;;
    "delete_domain")
      delete_domain "$2"
      ;;
    "list_users")
      list_users
      ;;
    "folders")
      get_folders "$2"
      ;;
    "add-folder")
      add_folder "$2" "$3" "$4"
      ;;
    "update-folder")
      update_folder "$2" "$3" "$4"
      ;;
    "delete-folder")
      delete_folder "$2" "$3"
      ;;
    "folder-stats")
      get_folder_stats "$2" "$3"
      ;;
    "labels")
      get_labels
      ;;
    "add-label")
      add_email_label "$2" "$3"
      ;;
    "remove-label")
      remove_email_label "$2" "$3"
      ;;
    "get-spam-config")
      get_spam_filter_config "all"
      ;;
    "update-spam-config")
      if [ -z "$2" ] || [ -z "$3" ]; then
        echo "错误: 用法: $0 update-spam-config <type> <json_value>"
        echo "类型: keyword_cn, keyword_en, domain, email, rule"
        exit 1
      fi
      update_spam_filter_config "$2" "$3"
      ;;
    *)
      echo "用法: $0 <action> [参数...]"
      echo ""
      echo "邮件数据库管理:"
      echo "  init                    - 初始化邮件数据库和表结构"
      echo "  fix-file-paths          - 修复数据库中存储了文件路径的邮件（将文件路径替换为实际内容或空字符串）"
      echo "  store <id> <from> <to> <subject> <body> [html] [folder] [size] [attachments] [headers]"
      echo "                          存储邮件到数据库"
      echo "  list <user> [folder] [limit] [offset]"
      echo "                          查询用户邮件列表（folder默认为inbox，limit默认为50，offset默认为0）"
      echo "  detail <id> <user>     - 获取邮件详情（支持已删除文件夹中的邮件）"
      echo "  delete <id> <user>     - 软删除邮件（移动到已删除文件夹）"
      echo "  restore <id> <user>    - 还原邮件（从已删除文件夹恢复到原文件夹）"
      echo "  hard-delete <id> <user> - 彻底删除邮件（硬删除，不可恢复）"
      echo "  move <id> <folder> <user>"
      echo "                          移动邮件到指定文件夹（移动到已删除文件夹时会自动记录原文件夹）"
      echo "  stats <user>           - 获取用户邮件统计信息"
      echo "  cleanup [days]         - 清理过期邮件（默认30天）"
      echo "  mark_read <id>         - 标记邮件为已读"
      echo ""
      echo "用户管理:"
      echo "  add-user <username> <email> [display_name]"
      echo "                          添加邮件用户"
      echo "  list-users             - 列出所有邮件用户"
      echo "  update-user <username> <email> [display_name]"
      echo "                          更新用户信息"
      echo "  delete-user <username> - 删除邮件用户"
      echo "  update-admin-email <new_email>"
      echo "                          更新管理员邮箱"
      echo "  user-stats <username>  - 获取用户详细统计"
      echo ""
      echo "域名管理:"
      echo "  list_domains           - 列出所有域名"
      echo "  add_domain <domain>    - 添加域名"
      echo "  delete_domain <domain> - 删除域名"
      echo ""
      echo "文件夹管理:"
      echo "  folders [user_id]      - 获取文件夹列表（包括系统文件夹和自定义文件夹，user_id为mail_users表的id）"
      echo "  add-folder <name> <display_name> <user_id>"
      echo "                          添加自定义文件夹（name只能包含字母、数字、下划线、连字符，user_id为mail_users表的id）"
      echo "  update-folder <id> [name] [display_name]"
      echo "                          更新自定义文件夹（重命名，至少需要提供name或display_name之一）"
      echo "  delete-folder <id>     - 删除自定义文件夹（软删除，文件夹中的邮件移动到已删除文件夹）"
      echo "  folder-stats <folder_id> <user>"
      echo "                          获取文件夹统计信息"
      echo ""
      echo "标签管理:"
      echo "  labels                 - 获取标签列表"
      echo "  add-label <email_id> <label_id>"
      echo "                          为邮件添加标签"
      echo "  remove-label <email_id> <label_id>"
      echo "                          移除邮件标签"
      echo ""
      echo "垃圾邮件过滤配置:"
      echo "  get-spam-config        - 获取垃圾邮件过滤配置"
      echo "  update-spam-config <type> <json_value>"
      echo "                          更新垃圾邮件过滤配置（type: keyword_cn, keyword_en, domain, email, rule）"
      echo ""
      echo "更多信息请查看脚本开头的详细注释"
      exit 1
      ;;
  esac
}

# 标记邮件为已读
mark_email_read() {
  local email_id="$1"
  local user="$2"
  
  if [[ -z "$email_id" ]]; then
    echo "错误: 邮件ID不能为空"
    exit 1
  fi
  
  log "标记邮件为已读: email_id=$email_id, user=$user"
  
  # 获取该邮件的message_id，用于查找所有相关记录
  local message_id=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT message_id FROM emails WHERE id='$email_id' LIMIT 1;" 2>/dev/null | tail -1)
  
  if [[ -z "$message_id" ]]; then
    log "错误: 无法获取邮件 $email_id 的message_id"
    echo "标记邮件为已读失败：邮件不存在"
    exit 1
  fi
  
  # 提取base_message_id（使用SUBSTRING_INDEX逻辑，取第一个_之前的部分）
  # 这与查询中的SUBSTRING_INDEX(message_id, '_', 1)保持一致
  local base_message_id=$(echo "$message_id" | cut -d'_' -f1)
    
    # 转义特殊字符，避免SQL注入
    local escaped_base_message_id=$(echo "$base_message_id" | sed "s/'/''/g" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g')
    
  # 获取所有具有相同base_message_id的邮件ID
  local email_ids=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT id FROM emails WHERE SUBSTRING_INDEX(message_id, '_', 1) = '${escaped_base_message_id}';
  " 2>/dev/null)
  
  # 构建用户邮箱地址匹配条件
  local user_email_condition=""
  if [[ -n "$user" ]]; then
    if [[ "$user" == *@* ]]; then
      # 如果传入的是完整邮箱地址，直接精确匹配
      user_email_condition="er.email_address = '$user'"
    elif [ "$user" = "xm" ]; then
      # 特殊处理xm用户，支持多种邮箱格式
      user_email_condition="(er.email_address = 'xm@localhost' OR er.email_address LIKE '%@xm' OR er.email_address LIKE 'xm@%')"
    else
      # 普通用户名
      user_email_condition="(er.email_address = '$user' OR er.email_address LIKE '%@$user' OR er.email_address LIKE '$user@%')"
    fi
  fi
  
  # 更新已读状态
  # 收件箱（folder_id=1）：更新email_recipients表中当前用户对应的is_read状态（收件人级别的已读状态）
  # 已发送（folder_id=2）：更新emails.read_status字段（发件人级别的已读状态，不影响收件箱未读计数）
  if [[ -n "$user_email_condition" ]]; then
    # 更新所有相关邮件的已读状态
    local updated_count=0
    local sent_updated_count=0
    while IFS= read -r eid; do
      if [[ -n "$eid" && "$eid" =~ ^[0-9]+$ ]]; then
        # 检查邮件所在的文件夹ID和发件人
        local folder_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT folder_id, from_addr FROM emails WHERE id=$eid LIMIT 1;" 2>/dev/null | tail -1)
        local folder_id=$(echo "$folder_info" | cut -f1)
        local from_addr=$(echo "$folder_info" | cut -f2)
        
        if [[ "$folder_id" == "1" ]]; then
          # 收件箱：更新email_recipients表中的is_read状态
          # 需要将user_email_condition中的er_user替换为er，因为UPDATE语句中使用的是er别名
          local update_condition=$(echo "$user_email_condition" | sed 's/er_user\./er./g')
          local update_result=$(mysql_connect "UPDATE email_recipients er 
            SET er.is_read = 1, er.read_at = CURRENT_TIMESTAMP 
            WHERE er.email_id = $eid 
              AND er.recipient_type IN ('to', 'cc')
              AND $update_condition;" 2>&1)
          if [[ $? -eq 0 ]]; then
            # 使用mysql_connect执行UPDATE后，ROW_COUNT()需要在同一个连接中立即查询
            # 但mysql_connect每次都是新连接，所以我们需要直接查询更新的记录数
            local count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
              SELECT COUNT(*) FROM email_recipients er 
              WHERE er.email_id = $eid 
                AND er.recipient_type IN ('to', 'cc')
                AND $update_condition
                AND er.is_read = 1;
            " 2>/dev/null | tail -1)
            if [[ "$count" =~ ^[0-9]+$ ]] && [[ $count -gt 0 ]]; then
              updated_count=$((updated_count + count))
            fi
          fi
        elif [[ "$folder_id" == "2" ]]; then
          # 已发送文件夹：更新emails.read_status字段（发件人级别的已读状态）
          # 检查发件人是否是当前用户
          local from_match=0
          if [[ "$user" == *@* ]]; then
            if [[ "$from_addr" == "$user" ]]; then
              from_match=1
            fi
          elif [ "$user" = "xm" ]; then
            if [[ "$from_addr" == "xm@localhost" ]] || [[ "$from_addr" == *@xm ]] || [[ "$from_addr" == xm@* ]]; then
              from_match=1
    fi
  else
            if [[ "$from_addr" == "$user" ]] || [[ "$from_addr" == *@$user ]] || [[ "$from_addr" == $user@* ]]; then
              from_match=1
            fi
          fi
          
          if [[ $from_match -eq 1 ]]; then
            local update_result=$(mysql_connect "UPDATE emails SET read_status = 1 WHERE id = $eid;" 2>&1)
    if [[ $? -eq 0 ]]; then
              sent_updated_count=$((sent_updated_count + 1))
            fi
          fi
        fi
      fi
    done <<< "$email_ids"
    
    if [[ $updated_count -gt 0 ]] || [[ $sent_updated_count -gt 0 ]]; then
      log "邮件 $email_id (base_message_id: $base_message_id) 已标记为已读（用户: $user，收件箱更新了 $updated_count 条记录，已发送更新了 $sent_updated_count 条记录）"
      echo "邮件已标记为已读"
    else
      # 调试：检查为什么没有更新成功
      local debug_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        SELECT COUNT(*) as total, 
               SUM(CASE WHEN er.is_read=1 THEN 1 ELSE 0 END) as already_read,
               GROUP_CONCAT(DISTINCT er.email_address) as addresses
        FROM email_recipients er 
        WHERE er.email_id IN ($(echo "$email_ids" | tr '\n' ',' | sed 's/,$//'))
          AND er.recipient_type IN ('to', 'cc');
      " 2>/dev/null | tail -1)
      log "警告: 邮件 $email_id 标记为已读时未找到匹配的记录（用户: $user，base_message_id: $base_message_id，email_ids: $email_ids，调试信息: $debug_info，user_email_condition: $user_email_condition）"
      echo "邮件已标记为已读"
    fi
  else
    log "错误: 用户参数为空，无法更新收件人级别的已读状态"
    echo "标记邮件为已读失败：用户参数缺失"
      exit 1
  fi
}

# 获取域名列表
list_domains() {
  # 注意：此函数输出JSON，不要使用log函数，避免污染输出
  
  # 查询virtual_domains表
  local query="SELECT id, name FROM virtual_domains ORDER BY id;"
  local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$query" 2>/dev/null)
  
  if [[ -n "$result" ]]; then
    # 转换为JSON格式（输出到stdout，错误输出到stderr）
    echo "$result" | awk 'BEGIN{print "["} {
      if(NR > 1) print ","
      print "{\"id\":\""$1"\",\"name\":\""$2"\"}"
    } END{print "]"}'
  else
    echo "[]"
  fi
}

# 更新管理员邮箱
update_admin_email() {
  local new_email="$1"

  if [[ -z "$new_email" ]]; then
    echo "错误: 新邮箱地址不能为空"
    exit 1
  fi

  if [[ ! "$new_email" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
    echo "错误: 邮箱地址格式无效"
    exit 1
  fi

  log "更新管理员邮箱为: $new_email"

  # 更新xm用户的邮箱
  mysql_connect "UPDATE mail_users SET email='$new_email' WHERE username='xm';"

  if [[ $? -eq 0 ]]; then
    log "管理员邮箱已更新为: $new_email"
    echo "管理员邮箱已更新为: $new_email"
  else
    echo "错误: 更新管理员邮箱失败"
    exit 1
  fi
}

# 添加域名
add_domain() {
  local domain="$1"

  if [[ -z "$domain" ]]; then
    echo "错误: 域名不能为空"
    exit 1
  fi

  log "添加域名: $domain"

  # 检查域名是否已存在
  local check_query="SELECT COUNT(*) FROM virtual_domains WHERE name='$domain';"
  local count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$check_query" 2>/dev/null)

  if [[ "$count" -gt 0 ]]; then
    log "域名 $domain 已存在，跳过添加"
    echo "警告: 域名 $domain 已存在"
    return 0
  fi
  
  # 插入新域名
  mysql_connect "INSERT INTO virtual_domains (name) VALUES ('$domain');"
  
  if [[ $? -eq 0 ]]; then
    log "域名 $domain 添加成功"
    echo "域名添加成功"
    
    # 更新Postfix域名配置文件
    update_postfix_domains
    
    # 重新加载Postfix配置
    if systemctl is-active --quiet postfix; then
      systemctl reload postfix 2>/dev/null || {
        log_warning "Postfix重新加载失败，但域名已添加到数据库"
      }
    else
      log_info "Postfix服务未运行，跳过重新加载"
    fi
  else
    log "添加域名 $domain 失败"
    echo "添加域名失败"
    exit 1
  fi
}

# 删除域名
delete_domain() {
  local domain_id="$1"
  
  if [[ -z "$domain_id" ]]; then
    echo "错误: 域名ID不能为空"
    exit 1
  fi
  
  log "删除域名: $domain_id"
  
  # 检查是否有用户使用此域名
  local check_query="SELECT COUNT(*) FROM virtual_users WHERE domain_id='$domain_id';"
  local user_count=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$check_query" 2>/dev/null)
  
  if [[ "$user_count" -gt 0 ]]; then
    echo "错误: 该域名下还有 $user_count 个用户，无法删除"
    exit 1
  fi
  
  # 获取域名名称（用于Postfix配置更新）
  local domain_name=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT name FROM virtual_domains WHERE id='$domain_id';" 2>/dev/null)
  
  # 删除域名
  mysql_connect "DELETE FROM virtual_domains WHERE id='$domain_id';"
  
  if [[ $? -eq 0 ]]; then
    log "域名 $domain_id ($domain_name) 删除成功"
    
    # 更新Postfix配置（重新加载服务）
    if [[ -n "$domain_name" ]]; then
      log "更新Postfix配置，移除域名: $domain_name"
      
      # 重新加载Postfix配置（域名从数据库读取）
      update_postfix_domains
      
      if [[ $? -eq 0 ]]; then
        log "Postfix配置更新成功"
        echo "域名删除成功，Postfix配置已更新"
      else
        log "Postfix配置更新失败"
        echo "域名删除成功，但Postfix配置更新失败"
      fi
    else
      echo "域名删除成功"
    fi
  else
    log "删除域名 $domain_id 失败"
    echo "删除域名失败"
    exit 1
  fi
}

# 获取用户列表
list_users() {
  log "获取用户列表"
  
  # 查询mail_users表
  local query="SELECT id, username, email, display_name FROM mail_users WHERE is_active=1 ORDER BY username;"
  local result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$query" 2>/dev/null)
  
  if [[ -n "$result" ]]; then
    # 转换为JSON格式
    echo "$result" | awk 'BEGIN{print "["} {
      if(NR > 1) print ","
      print "{\"id\":\""$1"\",\"username\":\""$2"\",\"email\":\""$3"\",\"display_name\":\""$4"\"}"
    } END{print "]"}'
  else
    echo "[]"
  fi
}

# 修复数据库中存储了文件路径的邮件
fix_file_path_emails() {
  log "开始修复数据库中存储了文件路径的邮件..."
  
  # 查找所有body字段以/var/log/mail-ops/开头的邮件ID列表
  local email_ids=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
    SELECT id 
    FROM emails 
    WHERE (body LIKE '/var/log/mail-ops/%' OR html_body LIKE '/var/log/mail-ops/%')
    AND is_deleted=0
    ORDER BY id;
  " 2>/dev/null)
  
  if [[ -z "$email_ids" ]]; then
    log "未找到需要修复的邮件"
    echo "未找到需要修复的邮件"
    return 0
  fi
  
  local fixed_count=0
  local failed_count=0
  
  # 逐行处理每个邮件ID
  while IFS= read -r email_id; do
    if [[ -z "$email_id" || ! "$email_id" =~ ^[0-9]+$ ]]; then
      continue
    fi
    
    log "处理邮件ID=$email_id"
    
    # 获取邮件信息
    local email_info=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT message_id, body, html_body 
      FROM emails 
      WHERE id=$email_id
      LIMIT 1;
    " 2>/dev/null)
    
    if [[ -z "$email_info" ]]; then
      log "无法获取邮件ID=$email_id的信息"
      failed_count=$((failed_count + 1))
      continue
    fi
    
    local message_id=$(echo "$email_info" | cut -f1)
    local body=$(echo "$email_info" | cut -f2)
    local html_body=$(echo "$email_info" | cut -f3)
    
    # 提取base_message_id（去掉后缀，如_inbox, _sent等）
    local base_message_id=$(echo "$message_id" | sed 's/_[^_]*$//')
    local escaped_base_message_id=$(echo "$base_message_id" | sed "s/'/''/g")
    
    # 尝试从相同base_message_id的其他邮件中获取正确的body内容
    local correct_body=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT body 
      FROM emails 
      WHERE message_id LIKE '${escaped_base_message_id}_%'
      AND body NOT LIKE '/var/log/mail-ops/%'
      AND body IS NOT NULL
      AND body != ''
      AND id != $email_id
      LIMIT 1;
    " 2>/dev/null | tail -1)
    
    local correct_html_body=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
      SELECT html_body 
      FROM emails 
      WHERE message_id LIKE '${escaped_base_message_id}_%'
      AND html_body NOT LIKE '/var/log/mail-ops/%'
      AND html_body IS NOT NULL
      AND html_body != ''
      AND id != $email_id
      LIMIT 1;
    " 2>/dev/null | tail -1)
    
    # 构建UPDATE语句
    local update_parts=()
    
    if [[ "$body" =~ ^/var/log/mail-ops/ ]]; then
      if [[ -n "$correct_body" ]]; then
        local escaped_body=$(echo "$correct_body" | sed "s/'/''/g" | sed 's/\\/\\\\/g')
        update_parts+=("body='$escaped_body'")
        log "邮件ID=$email_id: 从其他邮件复制body内容"
      else
        update_parts+=("body=''")
        log "邮件ID=$email_id: 将body设置为空（未找到正确的body内容）"
      fi
    fi
    
    if [[ "$html_body" =~ ^/var/log/mail-ops/ ]]; then
      if [[ -n "$correct_html_body" ]]; then
        local escaped_html_body=$(echo "$correct_html_body" | sed "s/'/''/g" | sed 's/\\/\\\\/g')
        update_parts+=("html_body='$escaped_html_body'")
        log "邮件ID=$email_id: 从其他邮件复制html_body内容"
      else
        update_parts+=("html_body=''")
        log "邮件ID=$email_id: 将html_body设置为空（未找到正确的html_body内容）"
      fi
    fi
    
    # 执行更新
    if [[ ${#update_parts[@]} -gt 0 ]]; then
      local update_clause=$(IFS=','; echo "${update_parts[*]}")
      local update_result=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "
        UPDATE emails 
        SET $update_clause 
        WHERE id=$email_id;
      " 2>&1)
      
      if [[ $? -eq 0 ]]; then
        log "成功修复邮件ID=$email_id"
        fixed_count=$((fixed_count + 1))
      else
        log "修复邮件ID=$email_id失败: $update_result"
        failed_count=$((failed_count + 1))
      fi
    fi
  done <<< "$email_ids"
  
  log "修复完成: 成功修复 $fixed_count 封邮件，失败 $failed_count 封邮件"
  echo "修复完成: 成功修复 $fixed_count 封邮件，失败 $failed_count 封邮件"
}

# 执行主函数
main "$@"

