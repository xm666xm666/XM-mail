#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_CX.sh
# 工作职责: 邮件系统数据库检测工具 - 全面检查 maildb/mailapp 数据库结构、健康状态和数据统计
#           生成 Markdown 格式检测报告
# 系统组件: XM邮件管理系统 - 数据库检测模块
# ============================================================================
# 用法说明:
#   ./mail_CX.sh
#   无参数，直接执行；输出报告到 OUTPUT_FILE（默认 /XM_mail_test.md）
#
# 功能描述:
#   - 数据库连接检查：maildb（mailuser）、mailapp（root）
#   - 表结构统计：表数量、记录数、大小、索引
#   - 健康报告：MySQL 版本、连接状态、性能指标、空表/大表建议
#   - 输出格式：Markdown 报告
#
# 数据库来源:
#   - maildb：db_setup.sh init + mail_db.sh init（Postfix 表 + 邮件核心表）
#   - mailapp：app_user.sh schema（app_users, app_accounts）
#
# 依赖关系:
#   - MariaDB/MySQL
#   - 密码文件：/etc/mail-ops/mail-db.pass（maildb 连接）
#
# 注意事项:
#   - 需 root 或 mailuser 权限连接数据库
#   - 报告路径可修改 OUTPUT_FILE 变量
# ============================================================================
#
set -euo pipefail

# 配置参数
OUTPUT_FILE="/XM_mail_test.md"
DB_HOST="localhost"
MAILDB_NAME="maildb"
MAILAPP_NAME="mailapp"
DB_USER="mailuser"
DB_PASS_FILE="/etc/mail-ops/mail-db.pass"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 获取数据库密码
get_db_password() {
if [[ ! -f "$DB_PASS_FILE" ]]; then
    echo -e "${RED}❌ 数据库密码文件不存在: $DB_PASS_FILE${NC}"
  exit 1
fi
  cat "$DB_PASS_FILE"
}

# MySQL 执行函数
mysql_exec() {
  local db_name="$1"
  local query="$2"

  # 根据数据库类型选择不同的连接方式
  if [[ "$db_name" == "maildb" ]]; then
    # maildb使用mailuser
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$(get_db_password)" "$db_name" -s -r -e "$query" 2>/dev/null
  else
    # mailapp和其他数据库使用root
    mysql -u root "$db_name" -s -r -e "$query" 2>/dev/null
  fi
}

# 检查数据库连接
check_db_connection() {
  local db_name="$1"

  # 根据数据库类型选择不同的连接方式
  if [[ "$db_name" == "maildb" ]]; then
    # maildb使用mailuser
    if ! mysql -h "$DB_HOST" -u "$DB_USER" -p"$(get_db_password)" -e "USE $db_name;" >/dev/null 2>&1; then
      return 1
    fi
  else
    # mailapp和其他数据库使用root
    if ! mysql -u root -e "USE $db_name;" >/dev/null 2>&1; then
      return 1
    fi
  fi
  return 0
}

# 获取表统计信息
get_table_stats() {
  local db_name="$1"
  local table="$2"
  local row_count=$(mysql_exec "$db_name" "SELECT COUNT(*) FROM $table;")
  local size_info=$(mysql_exec "$db_name" "SELECT
    ROUND((data_length + index_length) / 1024 / 1024, 2) as size_mb,
    table_rows as estimated_rows
    FROM information_schema.TABLES
    WHERE table_schema = '$db_name' AND table_name = '$table';")

  echo "$row_count|$size_info"
}

# 格式化文件大小
format_size() {
  local size_kb="$1"
  # 简化的格式化逻辑，避免依赖bc命令
  if [[ $size_kb -lt 1024 ]]; then
    echo "${size_kb}KB"
  elif [[ $size_kb -lt 1048576 ]]; then
    echo "$((size_kb / 1024))MB"
  else
    echo "$((size_kb / 1048576))GB"
  fi
}

# 主函数
main() {
  echo -e "${BLUE}🚀 开始XM邮件系统数据库检测...${NC}"

# 写入标题
  cat > "$OUTPUT_FILE" << EOF
# 📊 XM 邮件系统数据库检测报告

## 📈 系统概览

- **生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **服务器**: $(hostname)
- **数据库主机**: $DB_HOST
- **检测工具版本**: 2.0

---

## 🗄️ 数据库状态总览

EOF

  # 检查数据库状态
  local maildb_status="❌ 不存在"
  local mailapp_status="❌ 不存在"
  local total_tables=0
  local total_records=0
  local total_size="0MB"

  # 检查maildb
  if check_db_connection "$MAILDB_NAME"; then
    maildb_status="✅ 正常"
    local maildb_tables=$(mysql_exec "$MAILDB_NAME" "SELECT COUNT(*) FROM information_schema.TABLES WHERE table_schema='$MAILDB_NAME';")
    local maildb_records=$(mysql_exec "$MAILDB_NAME" "SELECT SUM(table_rows) FROM information_schema.TABLES WHERE table_schema='$MAILDB_NAME';")
    local maildb_size=$(mysql_exec "$MAILDB_NAME" "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) FROM information_schema.TABLES WHERE table_schema='$MAILDB_NAME';")

    total_tables=$((total_tables + maildb_tables))
    total_records=$((total_records + maildb_records))
    total_size="${maildb_size}MB"

    echo "| 数据库 | 状态 | 表数量 | 记录数 | 大小 |" >> "$OUTPUT_FILE"
    echo "|--------|------|--------|--------|------|" >> "$OUTPUT_FILE"
    echo "| maildb | $maildb_status | $maildb_tables | $maildb_records | ${maildb_size}MB |" >> "$OUTPUT_FILE"
  else
    echo "| 数据库 | 状态 | 表数量 | 记录数 | 大小 |" >> "$OUTPUT_FILE"
    echo "|--------|------|--------|--------|------|" >> "$OUTPUT_FILE"
    echo "| maildb | $maildb_status | - | - | - |" >> "$OUTPUT_FILE"
  fi

  # 检查mailapp
  if check_db_connection "$MAILAPP_NAME"; then
    mailapp_status="✅ 正常"
    local mailapp_tables=$(mysql_exec "$MAILAPP_NAME" "SELECT COUNT(*) FROM information_schema.TABLES WHERE table_schema='$MAILAPP_NAME';")
    local mailapp_records=$(mysql_exec "$MAILAPP_NAME" "SELECT SUM(table_rows) FROM information_schema.TABLES WHERE table_schema='$MAILAPP_NAME';")
    local mailapp_size=$(mysql_exec "$MAILAPP_NAME" "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) FROM information_schema.TABLES WHERE table_schema='$MAILAPP_NAME';")

    total_tables=$((total_tables + mailapp_tables))
    total_records=$((total_records + mailapp_records))
    total_size="${mailapp_size}MB"

    echo "| mailapp | $mailapp_status | $mailapp_tables | $mailapp_records | ${mailapp_size}MB |" >> "$OUTPUT_FILE"
  else
    echo "| mailapp | $mailapp_status | - | - | - |" >> "$OUTPUT_FILE"
  fi

echo "" >> "$OUTPUT_FILE"
  echo "**📊 汇总统计**: $total_tables 张表, $total_records 条记录, 总大小: $total_size" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

  # 检查并报告每个数据库
  check_database "$MAILDB_NAME" "邮件数据库" "maildb"
  check_database "$MAILAPP_NAME" "应用数据库" "mailapp"

  # 生成数据库健康报告
  generate_health_report

  # 完成报告
  cat >> "$OUTPUT_FILE" << EOF

---

## ✅ 检测完成

- **报告生成时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **报告文件位置**: **$OUTPUT_FILE**
- **检测工具**: mail_CX.sh v2.0

EOF

  echo -e "${GREEN}✅ 数据库检测完成！报告已生成: $OUTPUT_FILE${NC}"
}

# 检查单个数据库
check_database() {
  local db_name="$1"
  local db_desc="$2"
  local db_short="$3"

  echo -e "${BLUE}📋 检查$db_desc ($db_name)...${NC}"

  if ! check_db_connection "$db_name"; then
    echo "## ❌ $db_desc ($db_name) - 数据库不存在" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "请先执行相关初始化脚本创建数据库。" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    return
fi

  echo "## 🗄️ $db_desc ($db_name)" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

# 获取所有表
  local tables=$(mysql_exec "$db_name" "SHOW TABLES;")
  if [[ -z "$tables" ]]; then
  echo "⚠️ 当前数据库中没有任何表。" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    return
  fi

  # 表统计
  echo "### 📋 表列表统计" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"
  echo "| 表名 | 记录数 | 估算大小 | 索引信息 |" >> "$OUTPUT_FILE"
  echo "|------|--------|----------|----------|" >> "$OUTPUT_FILE"

  for table in $tables; do
    local stats=$(get_table_stats "$db_name" "$table")
    IFS='|' read -r row_count size_info <<< "$stats"
    local size_mb=$(echo "$size_info" | awk '{print $1}')
    local estimated_rows=$(echo "$size_info" | awk '{print $2}')

    # 获取索引信息
    local index_count=$(mysql_exec "$db_name" "SELECT COUNT(*) FROM information_schema.STATISTICS WHERE table_schema='$db_name' AND table_name='$table';")

    echo "| $table | $row_count | ${size_mb}MB | $index_count 个索引 |" >> "$OUTPUT_FILE"
  done

  echo "" >> "$OUTPUT_FILE"

  # 遍历每个表显示详细信息
  for table in $tables; do
    echo "### 🧱 表结构：$table" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # 表结构
    echo "#### 结构定义" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "\`\`\`sql" >> "$OUTPUT_FILE"
    mysql_exec "$db_name" "SHOW CREATE TABLE $table\G" >> "$OUTPUT_FILE" 2>/dev/null || echo "⚠️ 无法显示 $table 结构" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # 表信息
    echo "#### 表信息" >> "$OUTPUT_FILE"
    local table_info=$(mysql_exec "$db_name" "SELECT
      ENGINE, TABLE_COLLATION, TABLE_COMMENT,
      ROUND((data_length + index_length) / 1024 / 1024, 2) as size_mb,
      table_rows as estimated_rows
      FROM information_schema.TABLES
      WHERE table_schema = '$db_name' AND table_name = '$table';")

    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "存储引擎: $(echo "$table_info" | awk '{print $1}')" >> "$OUTPUT_FILE"
    echo "字符集: $(echo "$table_info" | awk '{print $2}')" >> "$OUTPUT_FILE"
    echo "表注释: $(echo "$table_info" | awk '{print $3}')" >> "$OUTPUT_FILE"
    echo "数据大小: $(echo "$table_info" | awk '{print $4}')MB" >> "$OUTPUT_FILE"
    echo "估算行数: $(echo "$table_info" | awk '{print $5'})" >> "$OUTPUT_FILE"
    echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # 示例数据
    echo "#### 示例数据（前10行）" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
    mysql_exec "$db_name" "SELECT * FROM $table LIMIT 10;" >> "$OUTPUT_FILE" 2>/dev/null || echo "⚠️ 无法查询 $table 数据" >> "$OUTPUT_FILE"
echo "\`\`\`" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"

    # 外键关系（如果有）
    local foreign_keys=$(mysql_exec "$db_name" "SELECT
      COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
      FROM information_schema.KEY_COLUMN_USAGE
      WHERE table_schema='$db_name' AND table_name='$table' AND REFERENCED_TABLE_NAME IS NOT NULL;")

    if [[ -n "$foreign_keys" ]]; then
      echo "#### 外键关系" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "| 列名 | 引用表 | 引用列 |" >> "$OUTPUT_FILE"
      echo "|------|--------|--------|" >> "$OUTPUT_FILE"
      echo "$foreign_keys" | while read -r line; do
        local col=$(echo "$line" | awk '{print $1}')
        local ref_table=$(echo "$line" | awk '{print $2}')
        local ref_col=$(echo "$line" | awk '{print $3}')
        echo "| $col | $ref_table | $ref_col |" >> "$OUTPUT_FILE"
      done
      echo "" >> "$OUTPUT_FILE"
    fi
  done

  echo "" >> "$OUTPUT_FILE"
}

# 生成数据库健康报告
generate_health_report() {
  echo -e "${BLUE}🏥 生成数据库健康报告...${NC}"

  echo "" >> "$OUTPUT_FILE"
  echo "## 🏥 数据库健康检查报告" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # MySQL版本信息
  local mysql_version=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(get_db_password)" -e "SELECT VERSION();" 2>/dev/null | tail -n1)
  echo "### MySQL版本信息" >> "$OUTPUT_FILE"
  echo "- **版本**: $mysql_version" >> "$OUTPUT_FILE"
  echo "- **主机**: $DB_HOST" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  # 数据库连接状态
  echo "### 数据库连接状态" >> "$OUTPUT_FILE"
  echo "| 数据库 | 连接状态 | 最后活动 |" >> "$OUTPUT_FILE"
  echo "|--------|----------|----------|" >> "$OUTPUT_FILE"

  # 检查maildb
  if check_db_connection "$MAILDB_NAME"; then
    local maildb_activity=$(mysql_exec "$MAILDB_NAME" "SELECT NOW() as current_time;")
    echo "| maildb | ✅ 正常 | $maildb_activity |" >> "$OUTPUT_FILE"
  else
    echo "| maildb | ❌ 无法连接 | - |" >> "$OUTPUT_FILE"
  fi

  # 检查mailapp
  if check_db_connection "$MAILAPP_NAME"; then
    local mailapp_activity=$(mysql_exec "$MAILAPP_NAME" "SELECT NOW() as current_time;")
    echo "| mailapp | ✅ 正常 | $mailapp_activity |" >> "$OUTPUT_FILE"
  else
    echo "| mailapp | ❌ 无法连接 | - |" >> "$OUTPUT_FILE"
  fi

  echo "" >> "$OUTPUT_FILE"

  # 数据库性能指标（如果可用）
  echo "### 数据库性能指标" >> "$OUTPUT_FILE"
  if check_db_connection "$MAILDB_NAME"; then
    # 查询缓存状态
    local query_cache_info=$(mysql_exec "$MAILDB_NAME" "SHOW VARIABLES LIKE 'query_cache%';" 2>/dev/null)
    if [[ -n "$query_cache_info" ]]; then
      echo "#### 查询缓存状态" >> "$OUTPUT_FILE"
  echo "\`\`\`" >> "$OUTPUT_FILE"
      echo "$query_cache_info" >> "$OUTPUT_FILE"
  echo "\`\`\`" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
    fi

    # 连接信息
    local connection_info=$(mysql_exec "$MAILDB_NAME" "SHOW PROCESSLIST;" 2>/dev/null | wc -l)
    echo "#### 活动连接数" >> "$OUTPUT_FILE"
    echo "- 当前活动连接: $((connection_info - 1)) 个" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
  fi

  # 健康检查建议
  echo "### 健康检查建议" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  local issues_found=0

  # 检查是否有空表
  if check_db_connection "$MAILDB_NAME"; then
    local empty_tables=$(mysql_exec "$MAILDB_NAME" "SELECT table_name FROM information_schema.TABLES WHERE table_schema='$MAILDB_NAME' AND table_rows = 0;")
    if [[ -n "$empty_tables" ]]; then
      echo "⚠️ **发现空表**: 以下表没有数据：" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      for table in $empty_tables; do
        echo "- \`$table\`" >> "$OUTPUT_FILE"
      done
      echo "" >> "$OUTPUT_FILE"
      issues_found=$((issues_found + 1))
    fi
  fi

  # 检查表大小异常
  if check_db_connection "$MAILDB_NAME"; then
    local large_tables=$(mysql_exec "$MAILDB_NAME" "SELECT table_name, ROUND((data_length + index_length) / 1024 / 1024, 2) as size_mb FROM information_schema.TABLES WHERE table_schema='$MAILDB_NAME' AND (data_length + index_length) > 100 * 1024 * 1024 ORDER BY (data_length + index_length) DESC LIMIT 5;")
    if [[ -n "$large_tables" ]]; then
      echo "📊 **大表统计**: 超过100MB的表（前5个）：" >> "$OUTPUT_FILE"
      echo "" >> "$OUTPUT_FILE"
      echo "| 表名 | 大小 |" >> "$OUTPUT_FILE"
      echo "|------|------|" >> "$OUTPUT_FILE"
      echo "$large_tables" | while read -r line; do
        local table_name=$(echo "$line" | awk '{print $1}')
        local table_size=$(echo "$line" | awk '{print $2}')
        echo "| $table_name | ${table_size}MB |" >> "$OUTPUT_FILE"
      done
echo "" >> "$OUTPUT_FILE"
    fi
  fi

  if [[ $issues_found -eq 0 ]]; then
    echo "✅ **所有检查通过**: 数据库运行正常。" >> "$OUTPUT_FILE"
  fi

echo "" >> "$OUTPUT_FILE"
}

# 执行主函数
main "$@"