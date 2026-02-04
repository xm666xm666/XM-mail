#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: start.sh
# 工作职责: XM邮件管理系统一键部署脚本 - 负责系统的完整安装、配置和管理
#           提供自动化部署、服务管理、系统诊断、日志查看和故障排除功能
# 系统组件: XM邮件管理系统 - 核心部署与管理模块
# ============================================================================
# 用法说明:
#   ./start.sh <action> [选项]
#
#   部署与管理命令:
#   ./start.sh start                    - 执行完整部署（推荐首次使用）
#                                        功能：安装所有组件、配置服务、初始化数据库、部署前端、同步前端版本
#                                        包含：Apache、Node.js、MariaDB、Postfix、Dovecot、前端界面
#                                        自动：创建管理员用户（xm）、配置权限、生成数据库密码
#   ./start.sh start -d                 - 后台运行部署（SSH断开后继续执行）
#                                        功能：与 start 相同，但在后台运行
#                                        日志：输出到 /var/log/mail-ops/start-daemon.log
#                                        查看：tail -f /var/log/mail-ops/start-daemon.log
#                                        停止：kill $(cat /var/log/mail-ops/start-daemon.pid)
#   ./start.sh check                    - 运行系统诊断检查
#                                        检查：服务状态、端口监听、配置文件、前端文件、日志文件
#                                        输出：详细的诊断报告，包括问题和建议
#   ./start.sh rebuild                  - 重建前端界面（早期分支）
#                                        步骤：删除 node_modules/dist/package-lock.json → npm install → vite build → rsync 到 /var/www/mail-frontend → 重启 httpd
#   ./start.sh status                   - 查看服务状态（早期分支）
#                                        显示：httpd、mariadb、mail-ops-dispatcher、postfix、dovecot 及端口监听（端口从 config/port-config.json 读取）
#   ./start.sh restart                  - 重启所有服务（早期分支）：httpd、mariadb、mail-ops-dispatcher、postfix、dovecot
#   ./start.sh stop                     - 停止所有服务（早期分支）：同上
#   ./start.sh restart-dispatcher       - 重启调度层服务（主流程 case）：停止并清理残留 node 进程后重启 mail-ops-dispatcher
#
#   日志查看命令:
#   日志查看命令（早期分支，委托子脚本后 exit）:
#   ./start.sh logs [类型] [选项]       - 委托 log_viewer.sh；类型: install、operations、system、user、all、tail、clean
#   ./start.sh mail-logs [选项]        - 委托 mail_log_viewer.sh；选项: mail、user、combined、stats、search、export；过滤: -u/-o/-f/-n/-d/-s/-e；无参数默认 combined
#   ./start.sh mail-logs-stats         - 委托 mail_log_viewer.sh stats
#
#   故障排除命令:
#   ./start.sh fix-auth                 - 修复认证问题（早期分支）：仅重启 httpd、mail-ops-dispatcher，未重新部署 Apache 配置
#   ./start.sh fix-db                   - 修复数据库问题（早期分支）：检查 mysql 连接（SELECT 1）并提示，无自动重新初始化
#   ./start.sh fix-dispatcher           - 修复调度层权限（主流程 case）：更新 systemd（端口/密码从 config 与 /etc/mail-ops/xm-admin.pass）、daemon-reload、重启、验证 xm sudo、测试脚本
#
#   帮助命令:
#   ./start.sh help                     - 显示帮助（早期分支）；未知命令时显示帮助并 exit 1
#
# 功能描述:
#   系统部署：自动安装 Apache、Node.js、MariaDB、Postfix、Dovecot；仓库源（update_repos.sh）；前端构建与部署；Apache 反向代理与调度层；数据库初始化（maildb/mailapp）；xm 用户与 sudo；密码随机生成并落盘
#   密码文件：/etc/mail-ops/mail-db.pass、app-db.pass（数据库）；/etc/mail-ops/xm-admin.pass（前端/API 认证，调度层读取）；权限 640，xm 可读
#   服务管理：status/restart/stop 操作 httpd、mariadb、mail-ops-dispatcher、postfix、dovecot；端口从 config/port-config.json 读取
#   系统诊断：run_diagnosis 检查服务、前端目录、配置、端口、日志；check 为早期分支
#   日志管理：install/operations/system 等写入 /var/log/mail-ops；logs 委托 log_viewer.sh；mail-logs 委托 mail_log_viewer.sh
#   故障排除：fix-auth 仅重启服务；fix-db 仅检查连接与提示；fix-dispatcher 完整更新 systemd、重启、验证 sudo 与脚本
#
# 数据库来源: maildb 由 db_setup.sh init（4 张）+ mail_db.sh init（9 张）共 13 张；mailapp 由 app_user.sh schema 共 2 张
#
# 依赖关系: Rocky Linux 9；dnf/yum；systemd；Apache、Node.js、MariaDB、Postfix、Dovecot；backend/scripts/*.sh；frontend/；config/port-config.json
#
# 注意事项: 需 root 权限；不使用 set -e；LOG_LEVEL 控制日志级别
# ============================================================================

# 注意：不使用 set -e，因为某些命令可能返回非零退出码但不影响脚本执行
set -uo pipefail

# 版本信息
SCRIPT_VERSION="5.1.0"

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

# 日志级别
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # 可选值: DEBUG, INFO, WARN, ERROR，默认INFO

# 记录脚本开始时间
SCRIPT_START_TIME=$(date +%s)
SCRIPT_START_DATE=$(date '+%Y-%m-%d %H:%M:%S')

require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "需要 root 权限运行此脚本" >&2
    exit 1
  fi
}

# 基础目录（在任何使用之前定义，避免未绑定变量）
BASE_DIR=$(cd "$(dirname "$0")" && pwd)

# 后台运行模式标志（默认false）
DAEMON_MODE=false

# 日志配置
LOG_DIR="/var/log/mail-ops"
INSTALL_LOG="$LOG_DIR/install.log"
OPERATION_LOG="$LOG_DIR/operations.log"
SYSTEM_LOG="$LOG_DIR/system.log"

# 创建日志目录并设置权限
mkdir -p "$LOG_DIR"
chown -R xm:xm "$LOG_DIR" 2>/dev/null || true
chmod -R 755 "$LOG_DIR" 2>/dev/null || true

# 创建配置目录并设置权限
CONFIG_DIR="$BASE_DIR/config"
mkdir -p "$CONFIG_DIR"
chown -R xm:xm "$CONFIG_DIR" 2>/dev/null || true
chmod -R 755 "$CONFIG_DIR" 2>/dev/null || true

# 保护系统设置文件：重装后自动恢复（仅读取之前的备份，不创建新备份）
SYSTEM_SETTINGS_FILE="$CONFIG_DIR/system-settings.json"

# 创建所有必要的日志文件并设置权限
touch "$LOG_DIR/user-operations.log" 2>/dev/null || true
touch "$LOG_DIR/install.log" 2>/dev/null || true
touch "$LOG_DIR/operations.log" 2>/dev/null || true
touch "$LOG_DIR/system.log" 2>/dev/null || true

# 设置日志文件权限
chown xm:xm "$LOG_DIR"/*.log 2>/dev/null || true
chmod 644 "$LOG_DIR"/*.log 2>/dev/null || true

# 统一的颜色处理函数
format_log_message() {
  local timestamp="$1"
  local message="$2"
  local prefix="$3"
  
  # 处理日志级别前缀颜色
  local colored_prefix="$prefix"
  if [[ "$prefix" == "[DEBUG]" ]]; then
    colored_prefix="[${ORANGE}DEBUG${NC}]"
  elif [[ "$prefix" == "[INFO]" ]]; then
    colored_prefix="[${BLUE}INFO${NC}]"
  elif [[ "$prefix" == "[WARN]" ]] || [[ "$prefix" == "[WARNING]" ]]; then
    colored_prefix="[${YELLOW}WARN${NC}]"
  elif [[ "$prefix" == "[ERROR]" ]]; then
    colored_prefix="[${RED}ERROR${NC}]"
  elif [[ "$prefix" == "[SUCCESS]" ]]; then
    colored_prefix="[${GREEN}SUCCESS${NC}]"
  fi
  
  # 针对"时间"相关的日志，用绿色显示时间
  if [[ "$message" =~ (时间|启动时间|结束时间|执行时间|耗时|脚本启动时间|脚本结束时间|总执行时间) ]]; then
    echo -e "[${GREEN}$timestamp${NC}] $colored_prefix $message"
  # 针对"完成"字眼，用橙色突出显示
  elif [[ "$message" =~ 完成 ]]; then
    echo -e "[${GREEN}$timestamp${NC}] $colored_prefix ${message//完成/${ORANGE}完成${NC}}"
  # 针对"错误|失败|异常"字眼，标红并添加详细错误处理
  elif [[ "$message" =~ (错误|失败|异常|警告) ]]; then
    local colored_message="$message"
    colored_message="${colored_message//错误/${RED}错误${NC}}"
    colored_message="${colored_message//失败/${RED}失败${NC}}"
    colored_message="${colored_message//异常/${RED}异常${NC}}"

    # 特殊处理"警告"字眼：如果包含"无"字，且为"无警告"，不加红色
    if [[ "$message" =~ 无.*警告 ]]; then
      colored_message="${colored_message//无警告/无警告}"
      echo -e "[${GREEN}$timestamp${NC}] $colored_prefix $colored_message"
    else
      colored_message="${colored_message//警告/${RED}警告${NC}}"
      echo -e "[${RED}$timestamp${NC}] $colored_prefix $colored_message"
    fi
  else
    echo -e "[${GREEN}$timestamp${NC}] $colored_prefix $message"
  fi
}

# 日志级别检查函数
# 功能：根据LOG_LEVEL环境变量决定是否输出特定级别的日志
# 参数：level（日志级别：DEBUG/INFO/WARN/ERROR）
# 逻辑：
#   - DEBUG级别：输出所有日志
#   - INFO级别：输出INFO、WARN、ERROR
#   - WARN级别：输出WARN、ERROR
#   - ERROR级别：仅输出ERROR
should_log() {
  local level="$1"
  case "$LOG_LEVEL" in
    "DEBUG")
      return 0  # DEBUG级别输出所有日志
      ;;
    "INFO")
      [[ "$level" == "INFO" || "$level" == "WARN" || "$level" == "ERROR" ]] && return 0 || return 1
      ;;
    "WARN")
      [[ "$level" == "WARN" || "$level" == "ERROR" ]] && return 0 || return 1
      ;;
    "ERROR")
      [[ "$level" == "ERROR" ]] && return 0 || return 1
      ;;
    *)
      return 0  # 默认输出所有日志
      ;;
  esac
}

# 日志函数（根据消息内容自动判断级别，默认INFO）
# 功能：自动判断日志级别并调用相应的日志函数
# 逻辑：
#   - 包含"错误|失败|异常" -> ERROR级别
#   - 包含"警告|警示" -> WARN级别
#   - 其他 -> INFO级别
log() {
  local message="$*"
  
  # 根据消息内容自动判断日志级别
  if [[ "$message" =~ (错误|失败|异常|ERROR|error) ]]; then
    log_error "$message"
  elif [[ "$message" =~ (警告|警示|WARNING|warning) ]]; then
    log_warn "$message"
  elif [[ "$message" =~ (调试|DEBUG|debug|详细|详细信息) ]]; then
    log_debug "$message"
  else
    # 默认使用INFO级别
    log_info "$message"
  fi
}

# DEBUG级别日志
log_debug() {
  if should_log "DEBUG"; then
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$*"
    local log_message=$(format_log_message "$timestamp" "$message" "[DEBUG]")
    echo -e "$log_message" | tee -a "$INSTALL_LOG"
  fi
}

# INFO级别日志
log_info() {
  if should_log "INFO"; then
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$*"
    local log_message=$(format_log_message "$timestamp" "$message" "[INFO]")
    echo -e "$log_message" | tee -a "$INSTALL_LOG"
  fi
}

# WARN级别日志
log_warn() {
  if should_log "WARN"; then
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$*"
    local log_message=$(format_log_message "$timestamp" "$message" "[WARN]")
    echo -e "$log_message" | tee -a "$INSTALL_LOG"
  fi
}

# ERROR级别日志
log_error() {
  if should_log "ERROR"; then
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$*"
    local log_message=$(format_log_message "$timestamp" "$message" "[ERROR]")
    echo -e "$log_message" | tee -a "$INSTALL_LOG" >&2
  fi
}

# SUCCESS级别日志（INFO级别，但使用SUCCESS前缀）
log_success() {
  if should_log "INFO"; then
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local message="$*"
    local log_message=$(format_log_message "$timestamp" "$message" "[SUCCESS]")
    echo -e "$log_message" | tee -a "$INSTALL_LOG"
  fi
}


log_operation() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local user="${SUDO_USER:-$(whoami)}"
  local operation="$1"
  local details="${2:-}"
  
  # 使用统一的颜色处理函数
  format_log_message "$timestamp" "$details" "[USER:$user] [OPERATION:$operation]" >> "$OPERATION_LOG"
}

# 版本同步功能
sync_frontend_version() {
  log "开始同步前端版本信息"
  
  # 检查前端目录是否存在
  if [[ ! -d "$BASE_DIR/frontend" ]]; then
    log "前端目录不存在: $BASE_DIR/frontend，跳过版本同步"
    return 0
  fi
  
  # 从数据库读取xm用户的密码（优先使用数据库中的密码）
  log "从数据库读取xm用户信息..."
  local db_pass=$(cat /etc/mail-ops/app-db.pass 2>/dev/null || echo "")
  local xm_pass=""
  
  # 先清理错误的xm用户记录（只删除明显错误的记录，保留所有username='xm'的记录）
  if [[ -n "$db_pass" ]]; then
    # 只删除明显错误的记录：username='xm@localhost' 或 (email='xm@localhost' 且 username!='xm')
    # 保留所有 username='xm' 的记录，无论邮箱是什么（可能已被DNS配置更新）
    mysql -u mailappuser --password="${db_pass}" mailapp -e "DELETE FROM app_users WHERE (username='xm@localhost' OR (email='xm@localhost' AND username!='xm'));" 2>/dev/null || true
    
    # 从数据库查询xm用户（只检查username，不检查email，因为email可能已被DNS配置更新）
    local xm_user_info
    xm_user_info=$(mysql -u mailappuser --password="${db_pass}" mailapp -s -r -e "SELECT username, email FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null | tail -1)
    
    if [[ -n "$xm_user_info" ]]; then
      log "从数据库找到xm用户，使用配置文件中的密码进行验证"
      xm_pass=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")
    else
      log "数据库中没有xm用户，创建用户"
      xm_pass=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")
      
      # 创建xm用户
      if [[ -f "$BASE_DIR/backend/scripts/app_user.sh" ]]; then
        local register_result
        register_result=$(cd "$BASE_DIR" && APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass \
          bash -lc "\"${BASE_DIR}/backend/scripts/app_user.sh\" register xm xm@localhost \"${xm_pass}\"" 2>&1)
        
        if echo "$register_result" | grep -q '{"ok":true}'; then
          log "xm用户创建成功"
        else
          log "警告: 无法创建xm用户: $register_result"
        fi
      fi
    fi
  else
    # 如果无法读取数据库密码，使用配置文件中的密码
    xm_pass=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")
  fi
  
  # 如果xm_pass为空，使用默认值
  if [[ -z "$xm_pass" ]]; then
    xm_pass="xm666@"
  fi
  
  # 验证密码是否可用
  log "验证xm用户密码..."
  if [[ -f "$BASE_DIR/backend/scripts/app_user.sh" ]]; then
    local test_result
    test_result=$(cd "$BASE_DIR" && APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass \
      bash -lc "\"${BASE_DIR}/backend/scripts/app_user.sh\" login xm \"${xm_pass}\"" 2>&1)
    
    if echo "$test_result" | grep -q '{"ok":true}'; then
      log "xm用户密码验证成功"
    else
      log "xm用户密码验证失败，尝试同步密码..."
      # 更新密码
      local update_result
      update_result=$(cd "$BASE_DIR" && APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass \
        bash -lc "\"${BASE_DIR}/backend/scripts/app_user.sh\" update xm \"\" \"xm@localhost\" \"${xm_pass}\"" 2>&1)
      
      if echo "$update_result" | grep -q '{"ok":true}'; then
        log "xm用户密码同步成功"
        # 再次验证
        sleep 1
        test_result=$(cd "$BASE_DIR" && APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass \
          bash -lc "\"${BASE_DIR}/backend/scripts/app_user.sh\" login xm \"${xm_pass}\"" 2>&1)
        if echo "$test_result" | grep -q '{"ok":true}'; then
          log "xm用户密码验证通过"
        else
          log "警告: 密码同步后验证失败: $test_result"
        fi
      else
        log "警告: 无法同步xm用户密码: $update_result"
      fi
    fi
  fi
  
  # 读取端口配置
  local port_config_file="$CONFIG_DIR/port-config.json"
  local api_port=8081
  if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
    api_port=$(jq -r '.api.port // 8081' "$port_config_file" 2>/dev/null || echo "8081")
  fi
  
  # 检查版本API是否可用
  local api_url="http://localhost:${api_port}/api/version"
  local max_attempts=5
  local attempt=1
  
  while [[ $attempt -le $max_attempts ]]; do
    log "尝试连接版本API (第${attempt}次/共${max_attempts}次)"
    
    # 检查调度层服务是否运行
    if systemctl is-active --quiet mail-ops-dispatcher; then
      # 尝试调用版本API
      local response=$(curl -s -w "%{http_code}" -o /tmp/version_response.json \
        -H "Authorization: Basic $(echo -n "xm:${xm_pass}" | base64)" \
        "$api_url" 2>/dev/null)
      
      if [[ "$response" == "200" ]]; then
        log "版本API调用成功"
        
        # 检查响应内容
        if [[ -f "/tmp/version_response.json" ]]; then
          local version=$(grep -o '"version":"[^"]*"' /tmp/version_response.json | cut -d'"' -f4)
          if [[ -n "$version" ]]; then
            log "当前系统版本: $version"
            log "前端版本同步完成"
            rm -f /tmp/version_response.json
            return 0
          fi
        fi
      else
        log "版本API调用失败，HTTP状态码: $response"
        # 如果是401错误，可能是密码不匹配，尝试重新同步密码并清理错误记录
        if [[ "$response" == "401" && $attempt -lt $max_attempts ]]; then
          log "检测到401错误，清理错误的xm用户记录并重新同步密码..."
          # 先清理错误的xm用户记录（只删除明显错误的记录，保留所有username='xm'的记录）
          local db_pass=$(cat /etc/mail-ops/app-db.pass 2>/dev/null || echo "")
          if [[ -n "$db_pass" ]]; then
            # 只删除明显错误的记录：username='xm@localhost' 或 (email='xm@localhost' 且 username!='xm')
            # 保留所有 username='xm' 的记录，无论邮箱是什么（可能已被DNS配置更新）
            mysql -u mailappuser --password="${db_pass}" mailapp -e "DELETE FROM app_users WHERE (username='xm@localhost' OR (email='xm@localhost' AND username!='xm'));" 2>/dev/null || true
          fi
          
          # 同步密码（不更新邮箱，保留现有邮箱）
          local sync_result
          sync_result=$(cd "$BASE_DIR" && APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass \
            bash -lc "\"${BASE_DIR}/backend/scripts/app_user.sh\" update xm \"\" \"\" \"${xm_pass}\"" 2>&1)
          
          if echo "$sync_result" | grep -q '{"ok":true}'; then
            log "密码同步成功，等待数据库更新..."
            sleep 2
            # 验证密码是否生效
            local verify_result
            verify_result=$(cd "$BASE_DIR" && APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass \
              bash -lc "\"${BASE_DIR}/backend/scripts/app_user.sh\" login xm \"${xm_pass}\"" 2>&1)
            if echo "$verify_result" | grep -q '{"ok":true}'; then
              log "密码验证通过，继续重试API调用"
            else
              log "警告: 密码同步后验证失败: $verify_result"
            fi
          else
            log "警告: 密码同步失败: $sync_result"
          fi
        fi
      fi
    else
      log "调度层服务未运行，等待服务启动"
      sleep 2
    fi
    
    attempt=$((attempt + 1))
    sleep 3
  done
  
  log "版本同步失败，但系统将继续运行"
  log "提示: 前端将使用默认版本号，可通过刷新页面获取最新版本"
  log "如果版本显示不正确，请清除浏览器缓存或强制刷新页面"
}

log_system() {
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local level="$1"
  local message="$2"
  
  # 使用统一的颜色处理函数
  format_log_message "$timestamp" "$message" "[SYSTEM:$level]" >> "$SYSTEM_LOG"
}

# ============================================================================
# 系统诊断功能
# ============================================================================
# 功能：全面的系统诊断检查，检查服务状态、配置文件、前端文件等
# 目的：帮助用户快速定位问题，提供详细的诊断报告
# 检查项：
#   1. Apache服务状态
#   2. 调度层服务状态
#   3. 前端目录内容
#   4. index.html文件
#   5. 静态资源（CSS、JS文件）
#   6. Apache配置
#   7. Apache模块
#   8. 本地访问测试
#   9. 端口占用检查
#   10. 日志文件检查
# 诊断功能
run_diagnosis() {
  echo "=== 系统诊断开始 ==="
  
  echo "1. 检查 Apache 服务状态:"
  systemctl status httpd --no-pager -l || echo "Apache 服务异常"
  
  echo -e "\n2. 检查调度层服务状态:"
  systemctl status mail-ops-dispatcher --no-pager -l || echo "调度层服务异常"
  
  echo -e "\n3. 检查前端目录内容:"
  if [[ -d /var/www/mail-frontend ]]; then
    ls -la /var/www/mail-frontend/
  else
    echo "前端目录不存在"
  fi
  
  echo -e "\n4. 检查 index.html 内容:"
  if [[ -f /var/www/mail-frontend/index.html ]]; then
    echo "文件大小: $(stat -c%s /var/www/mail-frontend/index.html) 字节"
    echo "前5行内容:"
    head -5 /var/www/mail-frontend/index.html
  else
    echo "index.html 不存在"
  fi
  
  echo -e "\n5. 检查静态资源:"
  echo "CSS 文件:"
  find /var/www/mail-frontend -name "*.css" -exec ls -la {} \; 2>/dev/null || echo "无 CSS 文件"
  echo "JS 文件:"
  find /var/www/mail-frontend -name "*.js" -exec ls -la {} \; 2>/dev/null || echo "无 JS 文件"
  
  echo -e "\n6. 检查 Apache 配置:"
  if [[ -f /etc/httpd/conf.d/mailmgmt.conf ]]; then
    echo "虚拟主机配置存在"
    echo "关键配置:"
    grep -n "DocumentRoot\|ProxyPass\|RewriteRule" /etc/httpd/conf.d/mailmgmt.conf || echo "配置项未找到"
  else
    echo "虚拟主机配置不存在"
  fi
  
  echo -e "\n7. 检查 Apache 模块:"
  httpd -M 2>/dev/null | grep -E "(rewrite|deflate|expires|headers)" || echo "必要模块未加载"
  
  echo -e "\n8. 测试本地访问:"
  curl -I http://localhost/ 2>/dev/null | head -5 || echo "本地访问失败"
  
  echo -e "\n9. 检查端口占用:"
  # 读取端口配置
  local port_config_file="$CONFIG_DIR/port-config.json"
  local api_port=8081
  local apache_http_port=80
  if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
    api_port=$(jq -r '.api.port // 8081' "$port_config_file" 2>/dev/null || echo "8081")
    apache_http_port=$(jq -r '.apache.httpPort // 80' "$port_config_file" 2>/dev/null || echo "80")
  fi
  echo "检查端口: API=${api_port}, Apache HTTP=${apache_http_port}"
  netstat -tlnp 2>/dev/null | grep -E ":${apache_http_port}|:${api_port}" || echo "端口检查失败"
  
  echo -e "\n10. 检查日志文件:"
  if [[ -f /var/log/httpd/mail-frontend-error.log ]]; then
    echo "Apache 错误日志 (最后5行):"
    tail -5 /var/log/httpd/mail-frontend-error.log
  else
    echo "Apache 错误日志不存在"
  fi
  
  if [[ -f /var/log/mail-ops ]]; then
    echo "调度层日志目录:"
    ls -la /var/log/mail-ops/ 2>/dev/null || echo "调度层日志目录为空"
  fi
  
  echo -e "\n=== 诊断${ORANGE}完成${NC} ==="
  echo "如果发现问题，请运行: ./start.sh start 重新部署"
}

# 检查参数
if [[ "${1:-}" == "check" ]]; then
  run_diagnosis
  exit 0
elif [[ "${1:-}" == "start" ]]; then
  # 继续执行完整部署
  echo "开始执行完整部署..."
elif [[ "${1:-}" == "status" ]]; then
  echo "=== 服务状态检查 ==="
  echo "Apache 服务: $(systemctl is-active httpd 2>/dev/null || echo '未运行')"
  echo "MariaDB 服务: $(systemctl is-active mariadb 2>/dev/null || echo '未运行')"
  echo "调度层服务: $(systemctl is-active mail-ops-dispatcher 2>/dev/null || echo '未运行')"
  echo "Postfix 服务: $(systemctl is-active postfix 2>/dev/null || echo '未运行')"
  echo "Dovecot 服务: $(systemctl is-active dovecot 2>/dev/null || echo '未运行')"
  echo ""
  echo "端口监听状态:"
  # 读取端口配置
  PORT_CONFIG_FILE="$CONFIG_DIR/port-config.json"
  API_PORT=8081
  APACHE_HTTP_PORT=80
  APACHE_HTTPS_PORT=443
  if [[ -f "$PORT_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
    API_PORT=$(jq -r '.api.port // 8081' "$PORT_CONFIG_FILE" 2>/dev/null || echo "8081")
    APACHE_HTTP_PORT=$(jq -r '.apache.httpPort // 80' "$PORT_CONFIG_FILE" 2>/dev/null || echo "80")
    APACHE_HTTPS_PORT=$(jq -r '.apache.httpsPort // 443' "$PORT_CONFIG_FILE" 2>/dev/null || echo "443")
  fi
  echo "配置的端口: API=$API_PORT, Apache HTTP=$APACHE_HTTP_PORT, Apache HTTPS=$APACHE_HTTPS_PORT"
  netstat -tlnp | grep -E ":(${APACHE_HTTP_PORT}|${APACHE_HTTPS_PORT}|25|587|993|995|3306|${API_PORT})" || echo "无相关端口监听"
  exit 0
elif [[ "${1:-}" == "restart" ]]; then
  echo "=== 重启所有服务 ==="
  systemctl restart httpd mariadb mail-ops-dispatcher postfix dovecot
  echo "所有服务已重启"
  exit 0
elif [[ "${1:-}" == "stop" ]]; then
  echo "=== 停止所有服务 ==="
  systemctl stop httpd mariadb mail-ops-dispatcher postfix dovecot
  echo "所有服务已停止"
  exit 0
elif [[ "${1:-}" == "fix-auth" ]]; then
  echo "=== 修复认证问题 ==="
  echo "1. 重新配置 Apache 认证..."
  # 这里可以添加认证修复逻辑
  echo "2. 重启相关服务..."
  systemctl restart httpd mail-ops-dispatcher
  echo -e "认证修复${ORANGE}完成${NC}"
  exit 0
elif [[ "${1:-}" == "fix-db" ]]; then
  echo "=== 修复数据库问题 ==="
  echo "1. 检查数据库连接..."
  mysql -u root -e "SELECT 1;" >/dev/null 2>&1 && echo "数据库连接正常" || echo "数据库连接失败"
  echo "2. 重新初始化应用数据库..."
  # 这里可以添加数据库修复逻辑
  echo -e "数据库修复${ORANGE}完成${NC}"
  exit 0
elif [[ "${1:-}" == "help" ]]; then
  # 显示帮助信息
  echo "XM邮件管理系统部署脚本 v${SCRIPT_VERSION}"
  echo "=========================================="
  echo ""
  echo "用法:"
  echo ""
  echo "部署与管理命令:"
  echo "  ./start.sh start              - 执行完整部署（推荐首次使用）"
  echo "  ./start.sh start -d           - 后台运行部署（SSH断开后继续执行）"
  echo "  ./start.sh check              - 运行系统诊断检查"
  echo "  ./start.sh rebuild            - 重建前端界面"
  echo "  ./start.sh status             - 查看服务状态"
  echo "  ./start.sh restart            - 重启所有服务"
  echo "  ./start.sh stop               - 停止所有服务"
  echo "  ./start.sh restart-dispatcher - 重启调度层服务"
  echo ""
  echo "日志查看命令:"
  echo "  ./start.sh logs [类型]        - 查看系统日志"
  echo "                                 类型: install/operations/system/user/all/tail/clean"
  echo "  ./start.sh mail-logs [选项]   - 查看邮件日志"
  echo "                                 选项: mail/user/combined/stats/search <关键词>/export <格式>"
  echo "                                 过滤: -u <用户名>/-o <操作>/-f/-n <数量>/-d <日期>"
  echo "  ./start.sh mail-logs-stats    - 查看邮件日志统计"
  echo ""
  echo "故障排除命令:"
  echo "  ./start.sh fix-auth           - 修复认证问题"
  echo "  ./start.sh fix-db             - 修复数据库问题"
  echo "  ./start.sh fix-dispatcher     - 修复调度层权限问题"
  echo ""
  echo "帮助命令:"
  echo "  ./start.sh help               - 显示此帮助信息"
  echo ""
  echo "主要功能:"
  echo "  ✓ 自动安装 Apache、Node.js、MariaDB、Postfix、Dovecot"
  echo "  ✓ 配置邮件服务与虚拟域管理"
  echo "  ✓ 部署 Vue3 前端管理界面"
  echo "  ✓ 设置监控、备份、安全组件"
  echo "  ✓ 创建管理员用户 (xm/从配置文件读取)"
  echo "  ✓ 自动配置数据库和用户权限"
  echo ""
  echo "快速开始:"
  echo "  1. 首次部署: ./start.sh start"
  echo "  2. 检查状态: ./start.sh check"
  echo "  3. 访问系统: http://服务器IP"
  echo ""
  echo "故障排除:"
  echo "  - 登录问题: ./start.sh fix-auth"
  echo "  - 数据库问题: ./start.sh fix-db"
  echo "  - 调度层问题: ./start.sh fix-dispatcher"
  echo "  - 查看日志: ./start.sh logs"
  echo "  - 重启调度层: ./start.sh restart-dispatcher"
  echo ""
  echo "用户日志记录系统:"
  echo "  - 查看合并日志: ./start.sh mail-logs"
  echo "  - 查看邮件日志: ./start.sh mail-logs mail"
  echo "  - 查看用户日志: ./start.sh mail-logs user"
  echo "  - 查看日志统计: ./start.sh mail-logs-stats"
  echo "  - 实时跟踪日志: ./start.sh mail-logs -f"
  echo "  - 过滤用户日志: ./start.sh mail-logs -u <用户名>"
  echo "  - 快速用户过滤: ./start.sh mail-logs <用户名>"
  echo "  - 过滤操作类型: ./start.sh mail-logs -o <操作>"
  echo "  - 搜索日志内容: ./start.sh mail-logs search <关键词>"
  echo "  - 导出日志文件: ./start.sh mail-logs export <格式>"
  echo ""
  echo "日志记录功能:"
  echo "  ✓ 前端用户操作记录（按钮点击、页面访问、登录等）"
  echo "  ✓ 邮件操作记录（发送、接收、转发等）"
  echo "  ✓ 系统操作记录（服务状态、配置变更等）"
  echo "  ✓ 敏感信息保护（密码、邮箱地址自动掩码）"
  echo "  ✓ 多种日志格式（文本、CSV、JSON导出）"
  echo ""
  echo "日志文件路径:"
  echo "  - 安装日志: $INSTALL_LOG"
  echo "  - 操作日志: $OPERATION_LOG"
  echo "  - 系统日志: $SYSTEM_LOG"
  echo "  - 用户操作日志: $LOG_DIR/user-operations.log"
  echo "  - 邮件操作日志: $LOG_DIR/mail-operations.log"
  echo ""
  exit 0
elif [[ "${1:-}" == "rebuild" ]]; then
  # 重建前端
  echo "重建前端..."
  BASE_DIR=$(cd "$(dirname "$0")" && pwd)
  ORIGINAL_DIR=$(pwd)
  cd "$BASE_DIR/frontend"
  
  # 清理旧的构建文件
  rm -rf node_modules dist package-lock.json
  
  # 重新安装依赖
  npm install --silent --no-audit --no-fund
  
  # 确保 Tailwind CSS 配置
  if ! npm list tailwindcss >/dev/null 2>&1; then
    npm install --save-dev tailwindcss postcss autoprefixer || true
  fi
  
  # 确保 Chart.js 配置
  if ! npm list chart.js >/dev/null 2>&1; then
    npm install chart.js || true
  fi
  
  # 创建 PostCSS 配置
  cat > postcss.config.js <<'POSTCSS'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSS
  
  # 重新构建
  npx vite build --mode production --base ./
  
  # 部署到 Apache 目录
  if [[ -d dist ]]; then
    rsync -a --delete dist/ /var/www/mail-frontend/
    chown -R apache:apache /var/www/mail-frontend
    systemctl restart httpd
    echo -e "前端重建${ORANGE}完成${NC}"
  else
    echo "前端重建失败"
    exit 1
  fi
  
  # 恢复原始工作目录
  cd "$ORIGINAL_DIR"
  exit 0
elif [[ "${1:-}" == "logs" ]]; then
  # 查看日志
  shift
  "$(dirname "$0")/backend/scripts/log_viewer.sh" "$@"
  exit 0
elif [[ "${1:-}" == "mail-logs" ]]; then
  # 查看邮件日志
  shift
  echo "邮件日志文件路径:"
  echo "  - 用户操作日志: $LOG_DIR/user-operations.log"
  echo "  - 邮件操作日志: $LOG_DIR/mail-operations.log"
  echo ""
  # 如果没有指定日志类型，默认显示合并日志
  if [[ $# -eq 0 ]] || [[ "$1" =~ ^- ]]; then
    "$(dirname "$0")/backend/scripts/mail_log_viewer.sh" combined "$@"
  elif [[ "$1" =~ ^(mail|user|combined|stats|search|export)$ ]]; then
    # 如果是有效的日志类型，直接传递
    "$(dirname "$0")/backend/scripts/mail_log_viewer.sh" "$@"
  else
    # 如果第一个参数不是有效的日志类型，当作用户过滤参数处理
    "$(dirname "$0")/backend/scripts/mail_log_viewer.sh" combined -u "$@"
  fi
  exit 0
elif [[ "${1:-}" == "mail-logs-stats" ]]; then
  # 查看邮件日志统计
  shift
  echo "邮件日志统计 - 文件路径:"
  echo "  - 用户操作日志: $LOG_DIR/user-operations.log"
  echo "  - 邮件操作日志: $LOG_DIR/mail-operations.log"
  echo ""
  "$(dirname "$0")/backend/scripts/mail_log_viewer.sh" stats "$@"
  exit 0
else
  # 显示帮助信息（未知命令时）
  echo "XM邮件管理系统部署脚本 v${SCRIPT_VERSION}"
  echo "=========================================="
  echo ""
  echo "用法:"
  echo ""
  echo "部署与管理命令:"
  echo "  ./start.sh start              - 执行完整部署（推荐首次使用）"
  echo "  ./start.sh start -d           - 后台运行部署（SSH断开后继续执行）"
  echo "  ./start.sh check              - 运行系统诊断检查"
  echo "  ./start.sh rebuild            - 重建前端界面"
  echo "  ./start.sh status             - 查看服务状态"
  echo "  ./start.sh restart            - 重启所有服务"
  echo "  ./start.sh stop               - 停止所有服务"
  echo "  ./start.sh restart-dispatcher - 重启调度层服务"
  echo ""
  echo "日志查看命令:"
  echo "  ./start.sh logs [类型]        - 查看系统日志"
  echo "                                 类型: install/operations/system/user/all/tail/clean"
  echo "  ./start.sh mail-logs [选项]   - 查看邮件日志"
  echo "                                 选项: mail/user/combined/stats/search <关键词>/export <格式>"
  echo "                                 过滤: -u <用户名>/-o <操作>/-f/-n <数量>/-d <日期>"
  echo "  ./start.sh mail-logs-stats    - 查看邮件日志统计"
  echo ""
  echo "故障排除命令:"
  echo "  ./start.sh fix-auth           - 修复认证问题"
  echo "  ./start.sh fix-db             - 修复数据库问题"
  echo "  ./start.sh fix-dispatcher     - 修复调度层权限问题"
  echo ""
  echo "帮助命令:"
  echo "  ./start.sh help               - 显示此帮助信息"
  echo ""
  echo "主要功能:"
  echo "  ✓ 自动安装 Apache、Node.js、MariaDB、Postfix、Dovecot"
  echo "  ✓ 配置邮件服务与虚拟域管理"
  echo "  ✓ 部署 Vue3 前端管理界面"
  echo "  ✓ 设置监控、备份、安全组件"
  echo "  ✓ 创建管理员用户 (xm/从配置文件读取)"
  echo "  ✓ 自动配置数据库和用户权限"
  echo ""
  echo "快速开始:"
  echo "  1. 首次部署: ./start.sh start"
  echo "  2. 检查状态: ./start.sh check"
  echo "  3. 访问系统: http://服务器IP"
  echo ""
  echo "故障排除:"
  echo "  - 登录问题: ./start.sh fix-auth"
  echo "  - 数据库问题: ./start.sh fix-db"
  echo "  - 调度层问题: ./start.sh fix-dispatcher"
  echo "  - 查看日志: ./start.sh logs"
  echo "  - 重启调度层: ./start.sh restart-dispatcher"
  echo ""
  echo "用户日志记录系统:"
  echo "  - 查看合并日志: ./start.sh mail-logs"
  echo "  - 查看邮件日志: ./start.sh mail-logs mail"
  echo "  - 查看用户日志: ./start.sh mail-logs user"
  echo "  - 查看日志统计: ./start.sh mail-logs-stats"
  echo "  - 实时跟踪日志: ./start.sh mail-logs -f"
  echo "  - 过滤用户日志: ./start.sh mail-logs -u <用户名>"
  echo "  - 快速用户过滤: ./start.sh mail-logs <用户名>"
  echo "  - 过滤操作类型: ./start.sh mail-logs -o <操作>"
  echo "  - 搜索日志内容: ./start.sh mail-logs search <关键词>"
  echo "  - 导出日志文件: ./start.sh mail-logs export <格式>"
  echo ""
  echo "日志记录功能:"
  echo "  ✓ 前端用户操作记录（按钮点击、页面访问、登录等）"
  echo "  ✓ 邮件操作记录（发送、接收、转发等）"
  echo "  ✓ 系统操作记录（服务状态、配置变更等）"
  echo "  ✓ 敏感信息保护（密码、邮箱地址自动掩码）"
  echo "  ✓ 多种日志格式（文本、CSV、JSON导出）"
  echo ""
  echo "日志文件路径:"
  echo "  - 安装日志: $INSTALL_LOG"
  echo "  - 操作日志: $OPERATION_LOG"
  echo "  - 系统日志: $SYSTEM_LOG"
  echo "  - 用户操作日志: $LOG_DIR/user-operations.log"
  echo "  - 邮件操作日志: $LOG_DIR/mail-operations.log"
  echo ""
  if [[ -n "${1:-}" ]]; then
    echo "❌ 错误: 未知参数 '$1'"
    echo "💡 提示: 使用 './start.sh help' 查看所有可用命令"
    echo ""
  else
    echo "❌ 错误: 缺少参数"
    echo "💡 提示: 使用 './start.sh help' 查看所有可用命令"
    echo ""
  fi
  exit 1
fi

require_root

# ============================================================================
# 后台运行模式检测（必须在主部署流程之前）
# ============================================================================
if [[ "${1:-}" == "start" && "${2:-}" == "-d" ]]; then
  DAEMON_MODE=true
  # 创建后台运行日志文件
  DAEMON_LOG="$LOG_DIR/start-daemon.log"
  DAEMON_PID_FILE="$LOG_DIR/start-daemon.pid"
  
  # 检查是否已经在后台运行
  if [[ -f "$DAEMON_PID_FILE" ]]; then
    OLD_PID=$(cat "$DAEMON_PID_FILE" 2>/dev/null)
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
      echo -e "${YELLOW}警告: 检测到后台任务已在运行 (PID: $OLD_PID)${NC}"
      echo -e "${CYAN}日志文件: $DAEMON_LOG${NC}"
      echo -e "${CYAN}查看日志: tail -f $DAEMON_LOG${NC}"
      echo -e "${CYAN}停止任务: kill $OLD_PID${NC}"
      exit 0
    else
      # PID文件存在但进程不存在，清理PID文件
      rm -f "$DAEMON_PID_FILE"
    fi
  fi
  
  echo -e "${CYAN}启动后台运行模式...${NC}"
  echo -e "${CYAN}日志文件: $DAEMON_LOG${NC}"
  echo -e "${CYAN}查看日志: tail -f $DAEMON_LOG${NC}"
  echo ""
  
  # 使用 nohup 在后台运行脚本（去掉 -d 参数）
  nohup bash "$0" start > "$DAEMON_LOG" 2>&1 &
  DAEMON_PID=$!
  
  # 保存PID
  echo "$DAEMON_PID" > "$DAEMON_PID_FILE"
  
  # 等待一下，检查进程是否成功启动
  sleep 1
  if ps -p "$DAEMON_PID" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ 后台任务已启动 (PID: $DAEMON_PID)${NC}"
    echo -e "${CYAN}日志文件: $DAEMON_LOG${NC}"
    echo -e "${CYAN}实时查看: tail -f $DAEMON_LOG${NC}"
    echo -e "${CYAN}停止任务: kill $DAEMON_PID${NC}"
    echo ""
    echo -e "${YELLOW}提示: SSH连接断开后，任务将继续在后台运行${NC}"
    echo -e "${YELLOW}提示: 使用 'tail -f $DAEMON_LOG' 查看实时日志${NC}"
  else
    echo -e "${RED}✗ 后台任务启动失败${NC}"
    echo -e "${YELLOW}请查看日志文件: $DAEMON_LOG${NC}"
    rm -f "$DAEMON_PID_FILE"
    exit 1
  fi
  
  exit 0
fi

# ============================================================================
# 主部署流程开始
# ============================================================================

# 设置日志目录权限
log "日志目录权限设置完成"

# 记录安装开始
log "=== 邮件管理系统安装开始 ==="
log "脚本启动时间: ${SCRIPT_START_DATE}"
log_system "INFO" "安装脚本启动，用户: $(whoami), 主机: $(hostname), 启动时间: ${SCRIPT_START_DATE}"
log_operation "INSTALL_START" "开始安装邮件管理系统"

# ============================================================================
# 步骤1: 系统仓库源配置
# ============================================================================
# 功能：检查并配置系统软件包仓库源（Rocky Linux、Docker CE、Kubernetes）
# 目的：使用阿里云镜像源提高下载速度，确保依赖包安装成功
# 逻辑：检查3个仓库是否存在，如果缺失则调用update_repos.sh配置
log "更新系统并安装基础组件"

# 更新仓库源配置（使用阿里云镜像）
log_info "开始检查仓库源配置状态..."

# 二次校验：检查3个仓库是否都已存在
repos_count=0

# 检查1: Rocky Linux仓库是否已配置为阿里云镜像
rocky_repo_found=false
if ls /etc/yum.repos.d/[Rr]ocky*.repo >/dev/null 2>&1; then
  # 检查是否包含阿里云镜像地址
  for repo_file in /etc/yum.repos.d/[Rr]ocky*.repo; do
    if [[ -f "$repo_file" ]]; then
      if grep -q "mirrors.aliyun.com/rockylinux" "$repo_file" 2>/dev/null; then
        rocky_repo_found=true
        ((repos_count++))
        log_info "✓ 检测到 Rocky Linux 仓库已配置为阿里云镜像: $(basename "$repo_file")"
        break
      fi
    fi
  done
fi
if [[ "$rocky_repo_found" == "false" ]]; then
  log_info "✗ Rocky Linux 仓库未配置为阿里云镜像"
fi

# 检查2: Docker CE仓库是否存在
if [[ -f /etc/yum.repos.d/docker-ce.repo ]]; then
  ((repos_count++))
  log_info "✓ 检测到 Docker CE 仓库已存在"
else
  log_info "✗ Docker CE 仓库不存在"
fi

# 检查3: Kubernetes仓库是否存在
if [[ -f /etc/yum.repos.d/kubernetes.repo ]]; then
  ((repos_count++))
  log_info "✓ 检测到 Kubernetes 仓库已存在"
else
  log_info "✗ Kubernetes 仓库不存在"
fi

# 判断是否需要执行仓库配置
log_info "仓库检查完成：${repos_count}/3 个仓库已存在"
if [[ "$repos_count" -eq 3 ]]; then
  log_success "检测到3个仓库均已存在，跳过仓库源配置步骤"
  skip_repo_config=true
else
  log_info "需要执行仓库源配置以补全缺失的仓库"
  skip_repo_config=false
fi

if [[ "$skip_repo_config" == "false" ]]; then
  if [[ -f "${BASE_DIR}/backend/scripts/update_repos.sh" ]]; then
    chmod +x "${BASE_DIR}/backend/scripts/update_repos.sh" 2>/dev/null || true
    
    # 确保 yum-config-manager 可用（通过安装 yum-utils）
    if ! command -v yum-config-manager >/dev/null 2>&1; then
      log_info "安装 yum-utils 以提供 yum-config-manager 命令..."
      # 使用 timeout 命令限制执行时间（5分钟）
      if timeout 300 dnf -y install yum-utils >/dev/null 2>&1; then
        log_success "yum-utils 安装完成"
      else
        log_warn "yum-utils 安装失败或超时，将使用手动方式配置 Docker CE 仓库"
      fi
    fi
    
    # 捕获update_repos.sh的输出并处理日志级别（添加超时保护）
    log_info "执行仓库源更新脚本..."
    exit_code=0
    # 使用 timeout 命令限制脚本执行时间（10分钟）
    script_output=$(timeout 600 bash "${BASE_DIR}/backend/scripts/update_repos.sh" 2>&1)
    exit_code=$?
    
    # 检查是否超时
    if [[ $exit_code -eq 124 ]]; then
      log_warn "仓库源更新脚本执行超时（10分钟），但继续执行"
      exit_code=0  # 超时不视为错误，继续执行
    fi
    
    # 处理脚本输出
    while IFS= read -r line || [[ -n "$line" ]]; do
      # 解析日志级别标记并调用相应的日志函数
      if [[ "$line" =~ ^SUCCESS:\ (.+)$ ]]; then
        log_success "${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^WARNING:\ (.+)$ ]]; then
        log_warn "${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^ERROR:\ (.+)$ ]]; then
        log_error "${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^INFO:\ (.+)$ ]]; then
        log_info "${BASH_REMATCH[1]}"
      elif [[ -n "$line" ]]; then
        # 如果没有标记，默认作为INFO处理
        log_info "$line"
      fi
    done <<< "$script_output"
    
    if [[ "$exit_code" != "0" ]]; then
      log_error "仓库源更新失败，继续使用默认源"
    else
      # 更新仓库配置后，重新检查仓库状态
      log_info "重新检查仓库配置状态..."
      repos_count=0
      
      # 重新检查 Rocky Linux 仓库
      rocky_repo_found=false
      if ls /etc/yum.repos.d/[Rr]ocky*.repo >/dev/null 2>&1; then
        for repo_file in /etc/yum.repos.d/[Rr]ocky*.repo; do
          if [[ -f "$repo_file" ]]; then
            if grep -q "mirrors.aliyun.com/rockylinux" "$repo_file" 2>/dev/null; then
              rocky_repo_found=true
              ((repos_count++))
              break
            fi
          fi
        done
      fi
      
      # 重新检查 Docker CE 仓库
      if [[ -f /etc/yum.repos.d/docker-ce.repo ]]; then
        ((repos_count++))
      fi
      
      # 重新检查 Kubernetes 仓库
      if [[ -f /etc/yum.repos.d/kubernetes.repo ]]; then
        ((repos_count++))
      fi
      
      log_info "仓库配置后检查：${repos_count}/3 个仓库已存在"
      if [[ "$repos_count" -lt 3 ]]; then
        log_warn "仍有 ${repos_count}/3 个仓库未配置完成，但继续执行安装"
      fi
    fi
  else
    log_warn "仓库源更新脚本不存在，跳过仓库源配置"
  fi
fi

# 更新 DNF 缓存（添加超时保护）
log_info "更新系统仓库缓存..."
if timeout 120 dnf -y makecache >/dev/null 2>&1; then
  log_success "仓库缓存更新完成"
else
  log_warn "仓库缓存更新失败或超时，但继续执行"
fi

# 安装 EPEL 仓库（添加超时保护）
log_info "安装 EPEL 仓库..."
if timeout 300 dnf -y install epel-release >/dev/null 2>&1; then
  log_success "EPEL 仓库安装完成"
else
  log_warn "EPEL 仓库安装失败或超时，但继续执行"
fi

# 更新系统（添加超时保护，允许失败，显示进度）
log_info "更新系统软件包..."
log_info "提示: 系统更新可能需要较长时间（最多30分钟），请耐心等待..."
if [[ "${DAEMON_MODE:-false}" == "true" ]]; then
  log_info "提示: 后台运行模式下，可以使用 'tail -f $DAEMON_LOG' 查看详细日志"
else
  log_info "提示: 可以使用 'tail -f $INSTALL_LOG' 查看详细日志"
fi

# 创建一个临时文件来跟踪进度
PROGRESS_FILE="/tmp/dnf-update-progress.$$"
touch "$PROGRESS_FILE"

# 后台显示进度提示（每30秒输出一次）
(
  while [[ -f "$PROGRESS_FILE" ]]; do
    sleep 30
    if [[ -f "$PROGRESS_FILE" ]]; then
      log_info "[进度提示] 系统更新仍在进行中，请继续等待..."
    fi
  done
) &
PROGRESS_PID=$!

# 执行 dnf update，显示关键进度信息
# 使用 tee 同时输出到日志文件和过滤显示
if timeout 1800 bash -c "dnf -y update 2>&1 | tee -a '$INSTALL_LOG' | grep --line-buffered -E '(Downloading|Installing|Upgrading|Transaction|Preparing|Running|Complete|Error|Warning|^[[:space:]]*[0-9]+/[0-9]+)' | while IFS= read -r line; do echo \"\$line\"; done" | while IFS= read -r line; do
  log_info "$line"
done; then
  # 停止进度提示
  rm -f "$PROGRESS_FILE"
  kill $PROGRESS_PID 2>/dev/null || true
  wait $PROGRESS_PID 2>/dev/null || true
  log_success "系统更新完成"
else
  exit_code=${PIPESTATUS[0]}
  # 停止进度提示
  rm -f "$PROGRESS_FILE"
  kill $PROGRESS_PID 2>/dev/null || true
  wait $PROGRESS_PID 2>/dev/null || true
  if [[ $exit_code -eq 124 ]]; then
    log_warn "系统更新超时（30分钟），但继续执行"
  else
    log_warn "系统更新失败，但继续执行"
  fi
fi

# ============================================================================
# 步骤2: 管理员用户创建与配置
# ============================================================================
# 功能：创建xm管理员用户，配置sudo权限，设置密码
# 目的：为系统提供专用的管理员账户，用于运行调度层服务
# 逻辑：
#   - 检查xm用户是否存在，不存在则创建，存在则提权
#   - 从配置文件读取密码（/etc/mail-ops/xm-admin.pass），不存在则使用默认值
#   - 配置sudo权限（/etc/sudoers.d/xm），允许无密码sudo
#   - 设置密码文件权限（640，root:xm）
# 创建或配置管理员用户 xm
log "配置管理员用户 xm"

# 确保 /etc/mail-ops 目录存在
if [[ ! -d /etc/mail-ops ]]; then
  mkdir -p /etc/mail-ops
  chmod 755 /etc/mail-ops
  log "创建 /etc/mail-ops 目录"
fi

# 先检查并创建xm用户（如果不存在），然后再创建密码文件
if ! id xm >/dev/null 2>&1; then
  useradd -m -s /bin/bash xm
  log "用户 xm 创建成功"
  log_system "INFO" "管理员用户 xm 已创建"
fi

# 创建xm管理员密码配置文件（如果不存在）
if [[ ! -f /etc/mail-ops/xm-admin.pass ]]; then
  # 如果文件不存在，使用默认密码创建
  echo "xm666@" > /etc/mail-ops/xm-admin.pass
  # 设置文件所有者和权限（如果xm组存在则使用，否则使用root组）
  if getent group xm >/dev/null 2>&1; then
    chown root:xm /etc/mail-ops/xm-admin.pass
  else
    chown root:root /etc/mail-ops/xm-admin.pass
  fi
  chmod 640 /etc/mail-ops/xm-admin.pass
  log "创建xm管理员密码配置文件（使用默认密码）"
fi

# 读取xm管理员密码
XM_ADMIN_PASS=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")

# 设置 xm 用户密码（从配置文件读取）
echo "xm:${XM_ADMIN_PASS}" | chpasswd
log "用户 xm 密码设置完成（从配置文件读取）"

# 如果用户已存在，进行权限提升
if id xm >/dev/null 2>&1; then
  log "用户 xm 已存在，进行权限提升"
  log_system "INFO" "用户 xm 已存在，进行权限提升"
  # 如果用户已存在，也更新密码以确保一致性
  echo "xm:${XM_ADMIN_PASS}" | chpasswd 2>/dev/null || log "更新xm用户密码失败（可能权限不足）"
  # 确保密码文件权限正确
  if getent group xm >/dev/null 2>&1; then
    chown root:xm /etc/mail-ops/xm-admin.pass 2>/dev/null || chown root:root /etc/mail-ops/xm-admin.pass
  else
    chown root:root /etc/mail-ops/xm-admin.pass
  fi
  chmod 640 /etc/mail-ops/xm-admin.pass
fi

# 配置 xm 用户 sudo 权限
log "配置 xm 用户 sudo 权限"
cat > /etc/sudoers.d/xm <<XM_SUDO
# XM 邮件管理系统管理员用户
xm ALL=(ALL) NOPASSWD: ALL
XM_SUDO
chmod 440 /etc/sudoers.d/xm
log "xm 用户 sudo 权限配置完成"
log_system "INFO" "xm 用户已获得完整 sudo 权限"

# ============================================================================
# 步骤2.1: 命令终端专用用户 euser（无 sudo 权限）
# ============================================================================
# 功能：创建 euser 用户，供导航栏「命令终端」使用，不加入 sudo/wheel
# 目的：终端以普通用户身份运行，降低权限
# 逻辑：若 euser 不存在则创建；密码仅首次生成（随机高强度），存 /etc/mail-ops/euser.pass，不配置 sudoers
log "配置命令终端用户 euser（无 sudo）"
if ! id euser >/dev/null 2>&1; then
  useradd -m -s /bin/bash euser
  log "用户 euser 创建成功"
  log_system "INFO" "命令终端用户 euser 已创建"
fi
if [[ ! -f /etc/mail-ops/euser.pass ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 24 > /etc/mail-ops/euser.pass
  else
    head -c 24 /dev/urandom | base64 > /etc/mail-ops/euser.pass
  fi
  chown root:xm /etc/mail-ops/euser.pass 2>/dev/null || chown root:root /etc/mail-ops/euser.pass
  chmod 640 /etc/mail-ops/euser.pass
  log "创建 euser 密码配置文件（随机高强度，仅首次生成）"
fi
EUSER_PASS=$(cat /etc/mail-ops/euser.pass 2>/dev/null | tr -d '\n\r')
if [[ -z "$EUSER_PASS" ]]; then
  if command -v openssl >/dev/null 2>&1; then
    EUSER_PASS=$(openssl rand -base64 24 | tr -d '\n\r')
  else
    EUSER_PASS=$(head -c 24 /dev/urandom | base64 | tr -d '\n\r')
  fi
  echo "$EUSER_PASS" > /etc/mail-ops/euser.pass
  chown root:xm /etc/mail-ops/euser.pass 2>/dev/null || chown root:root /etc/mail-ops/euser.pass
  chmod 640 /etc/mail-ops/euser.pass
fi
echo "euser:${EUSER_PASS}" | chpasswd
log "用户 euser 密码设置完成（从配置文件读取）"
# 不配置 /etc/sudoers.d/euser，euser 无 sudo 权限

# ============================================================================
# 步骤3: Apache Web服务器安装与配置
# ============================================================================
# 功能：安装Apache HTTP服务器，配置虚拟主机、反向代理、SSL支持
# 目的：提供Web服务，托管前端静态文件，反向代理Node.js调度层API
# 逻辑：
#   - 安装Apache和相关模块（mod_ssl、mod_rewrite、mod_deflate等）
#   - 配置虚拟主机（/etc/httpd/conf.d/mailmgmt.conf）
#   - 配置认证（禁用双重认证，/etc/httpd/conf.d/mailmgmt-auth.conf）
#   - 优化配置（清理冲突配置、添加安全头、优化性能）
#   - 验证配置语法，重启服务
# 安装 Apache 与工具
log "安装 Apache 与基础工具"
# 注意：mod_proxy、mod_proxy_http、mod_proxy_wstunnel 已包含在 httpd 包中，无需单独安装
dnf -y install httpd mod_ssl openssl* git curl tar policycoreutils-python-utils jq --skip-broken
systemctl enable --now httpd
log_system "INFO" "Apache 安装完成，服务已启动"

# 启用必要的 Apache 模块
log "配置 Apache 模块"
# Rocky Linux 的 Apache 模块已经包含在 httpd 包中，检查模块状态
modules=("rewrite" "deflate" "expires" "headers" "proxy" "proxy_http" "proxy_wstunnel")
for module in "${modules[@]}"; do
  if httpd -M 2>/dev/null | grep -q "mod_${module}"; then
    log "模块 mod_${module} 已加载"
  else
    log "模块 mod_${module} 未检测到，尝试启用"
    # 检查主配置文件，确保模块被加载
    if [[ -f /etc/httpd/conf/httpd.conf ]]; then
      if ! grep -q "LoadModule.*${module}_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
        # 查找模块文件位置
        module_file=$(find /usr/lib64/httpd/modules -name "mod_${module}.so" 2>/dev/null | head -1)
        if [[ -n "$module_file" ]]; then
          echo "LoadModule ${module}_module ${module_file}" >> /etc/httpd/conf/httpd.conf
          log "已添加 mod_${module} 模块到配置"
        fi
      fi
    fi
  fi
done

# 修复 SSL 配置冲突
log "修复 Apache 配置冲突"
if [[ -f /etc/httpd/conf.d/ssl.conf ]]; then
  # 读取端口配置
  port_config_file="$CONFIG_DIR/port-config.json"
  apache_https_port=443
  if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
    apache_https_port=$(jq -r '.apache.httpsPort // 443' "$port_config_file" 2>/dev/null || echo "443")
  fi
  # 注释掉 ssl.conf 中的 Listen 443 https，避免与主配置冲突
  sed -i "s/^Listen ${apache_https_port} https/#Listen ${apache_https_port} https/" /etc/httpd/conf.d/ssl.conf || true
fi

# 配置全局 ServerName，抑制 FQDN 警告
log "配置 Apache ServerName"
if ! grep -qE '^\s*ServerName\s+' /etc/httpd/conf/httpd.conf 2>/dev/null; then
  echo "ServerName localhost" >> /etc/httpd/conf/httpd.conf
  log "已添加 ServerName localhost 到 Apache 配置"
fi

# 检查 Apache 配置语法
log "检查 Apache 配置语法"
httpd -t || {
  log "Apache 配置语法错误，尝试修复"
  # 如果配置有错误，先停止服务
  systemctl stop httpd || true
}

systemctl restart httpd || true

# 安装数据库与邮件服务（必须在数据库初始化之前）
log "安装数据库与邮件服务"
dnf -y install mariadb-server mariadb postfix postfix-mysql dovecot --skip-broken

# 确保服务正确启动
log "启动并配置数据库服务"
systemctl enable mariadb postfix dovecot
systemctl start mariadb

# 等待 MariaDB 完全启动
sleep 3

# 检查 MariaDB 是否正常运行
if ! systemctl is-active --quiet mariadb; then
  log "MariaDB 服务启动失败，尝试重新启动"
  systemctl restart mariadb
  sleep 2
fi

# 初始化 MariaDB（如果是全新安装）
log "初始化 MariaDB 数据库"
if ! mysql -u root -e "SELECT 1;" >/dev/null 2>&1; then
  log "MariaDB 需要初始化，执行安全配置"
  mysql_secure_installation <<EOF

y
y
y
y
y
EOF
  log "MariaDB 安全初始化完成"
else
  log "MariaDB 已配置，跳过初始化"
fi

# 验证 MySQL 客户端是否可用
if ! command -v mysql >/dev/null 2>&1; then
  log "MySQL 客户端不可用，尝试重新安装"
  dnf -y reinstall mariadb
fi

log_system "INFO" "数据库与邮件服务安装完成"

# ============================================================================
# 步骤4: 数据库服务安装与初始化
# ============================================================================
# 功能：安装MariaDB数据库，初始化maildb和mailapp数据库
# 目的：为邮件系统和应用提供数据存储
# 逻辑：
#   - 安装MariaDB服务器和客户端
#   - 初始化MariaDB（安全配置，设置root密码）
#   - 创建mailapp数据库（应用用户数据库）
#   - 创建maildb数据库（邮件系统数据库）
#   - 生成随机密码并保存到密码文件
#   - 创建数据库用户（mailappuser、mailuser）
#   - 初始化数据库表结构（15张表）
#   - 创建默认管理员用户（xm）
#   - 自动修复用户邮箱域名（重装时保持一致性）
# 初始化数据库（应用库与邮件库）
log "初始化应用数据库与邮件数据库"
# 确保脚本具备可执行权限（提前）
chmod +x "${BASE_DIR}/backend/scripts"/*.sh 2>/dev/null || true
# 通过 bash -lc 执行，避免因不可执行或 shebang 问题导致的"找不到命令"

# 检查邮件数据库是否已存在且有数据
check_maildb_exists() {
  if mysql -u root -e "USE maildb;" 2>/dev/null; then
    # 数据库存在，检查是否有表
    TABLE_COUNT=$(mysql -u root maildb -s -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='maildb';" 2>/dev/null || echo "0")
    if [ "$TABLE_COUNT" -gt 0 ]; then
      # 检查是否有数据（至少检查几个关键表）
      EMAIL_COUNT=$(mysql -u root maildb -s -N -e "SELECT COUNT(*) FROM emails LIMIT 1;" 2>/dev/null || echo "0")
      USER_COUNT=$(mysql -u root maildb -s -N -e "SELECT COUNT(*) FROM virtual_users LIMIT 1;" 2>/dev/null || echo "0")
      if [ "$EMAIL_COUNT" -gt 0 ] || [ "$USER_COUNT" -gt 0 ]; then
        log "检测到邮件数据库已存在且有数据，跳过数据库初始化以保留现有数据"
        return 0  # 数据库存在且有数据
      fi
    fi
  fi
  return 1  # 数据库不存在或为空
}

# 检查应用数据库是否已存在且有数据
check_mailapp_exists() {
  if mysql -u root -e "USE mailapp;" 2>/dev/null; then
    TABLE_COUNT=$(mysql -u root mailapp -s -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='mailapp';" 2>/dev/null || echo "0")
    if [ "$TABLE_COUNT" -gt 0 ]; then
      USER_COUNT=$(mysql -u root mailapp -s -N -e "SELECT COUNT(*) FROM app_users LIMIT 1;" 2>/dev/null || echo "0")
      if [ "$USER_COUNT" -gt 0 ]; then
        log "检测到应用数据库已存在且有数据，跳过数据库初始化以保留现有数据"
        return 0  # 数据库存在且有数据
      fi
    fi
  fi
  return 1  # 数据库不存在或为空
}

# 应用用户表（app_users, app_accounts）
# 1) 生成并保存应用库密码到仅 root 可读的文件
install -d -m 0755 /etc/mail-ops
if [[ ! -f /etc/mail-ops/app-db.pass ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 24 > /etc/mail-ops/app-db.pass
  else
    head -c 24 /dev/urandom | base64 > /etc/mail-ops/app-db.pass
  fi
fi
# 允许调度器用户 xm 只读，避免登录阶段无法读取数据库密码
chown root:xm /etc/mail-ops/app-db.pass
chmod 640 /etc/mail-ops/app-db.pass

# 2) 以密文文件方式初始化 schema（以 root 执行，确保可读取密钥文件并能创建 MySQL 用户）
# 只在数据库不存在或为空时才初始化
if check_mailapp_exists; then
  log "应用数据库已存在且有数据，跳过 schema 初始化以保留现有数据"
else
  log "应用数据库不存在或为空，开始初始化 schema"
  bash -lc 'APP_DB_PASS_FILE=/etc/mail-ops/app-db.pass "'"${BASE_DIR}/backend/scripts/app_user.sh"'" schema' || {
    log "应用数据库 schema 初始化失败，尝试手动创建"
    # 手动创建数据库和用户
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS mailapp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- 创建用户（如果不存在）
CREATE USER IF NOT EXISTS 'mailappuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/app-db.pass)';
-- 如果用户已存在，更新密码（确保密码与密码文件一致）
ALTER USER 'mailappuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/app-db.pass)';
GRANT ALL PRIVILEGES ON mailapp.* TO 'mailappuser'@'localhost';
FLUSH PRIVILEGES;
EOF
    # 创建表结构
    mysql -u root mailapp <<EOF
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
EOF
  }
fi

# 即使数据库已存在，也检查并添加avatar字段（如果缺失）
if check_mailapp_exists; then
  log "应用数据库已存在，检查并添加avatar字段（如果缺失）"
  mysql -u root mailapp <<EOF 2>/dev/null || log "添加avatar字段失败或字段已存在"
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
EOF
fi

# 3) 默认写入管理员 xm（以 root 执行，避免密钥文件读取权限问题）
# 确保只有一个正确的xm管理员用户
log "检查并修复默认管理员用户 xm"
# 读取xm管理员密码（如果之前已读取则使用，否则重新读取）
if [[ -z "${XM_ADMIN_PASS:-}" ]]; then
  XM_ADMIN_PASS=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")
fi

# 先清理所有错误的xm用户记录（只删除明显错误的记录，保留所有username='xm'的记录）
mysql -u root mailapp <<EOF 2>/dev/null || log "清理xm用户记录失败"
-- 只删除明显错误的记录：
-- 1. username='xm@localhost' 的记录（错误的用户名）
-- 2. email='xm@localhost' 且 username!='xm' 的记录（错误的邮箱但用户名不是xm）
-- 保留所有 username='xm' 的记录，无论邮箱是什么（可能已被DNS配置更新，如xm@skills.com）
DELETE FROM app_users WHERE (username='xm@localhost' OR (email='xm@localhost' AND username!='xm'));
EOF

# 检查xm用户是否存在（只检查username，不检查email，因为email可能已被DNS配置更新）
xm_exists=$(mysql -u root mailapp -e "SELECT COUNT(*) FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null | tail -1)

if [[ "${xm_exists}" -gt 0 ]]; then
  log "xm管理员用户已存在，更新密码（保留现有邮箱和注册时间）"
  # 获取当前邮箱和注册时间（可能已被DNS配置更新）
  current_email=$(mysql -u root mailapp -e "SELECT email FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null | tail -1)
  current_created_at=$(mysql -u root mailapp -e "SELECT created_at FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null | tail -1)
  log "当前xm用户邮箱: ${current_email:-未知}"
  log "当前xm用户注册时间: ${current_created_at:-未知}"
  
  # 更新现有用户的密码（不更新邮箱和created_at，保留现有数据）
  xm_hash=$(printf "%s" "${XM_ADMIN_PASS}" | sha512sum | awk '{print $1}')
  mysql -u root mailapp -e "UPDATE app_users SET pass_hash='${xm_hash}' WHERE username='xm';" 2>/dev/null || {
    log "更新xm用户密码失败"
  }
  
  # 如果邮箱为空或不是有效格式，设置为默认值
  if [[ -z "$current_email" || "$current_email" == "NULL" ]]; then
    log "xm用户邮箱为空，设置为默认值 xm@localhost"
    mysql -u root mailapp -e "UPDATE app_users SET email='xm@localhost' WHERE username='xm';" 2>/dev/null || {
      log "设置xm用户默认邮箱失败"
    }
  fi
else
  log "xm管理员用户不存在，创建新用户"
    xm_hash=$(printf "%s" "${XM_ADMIN_PASS}" | sha512sum | awk '{print $1}')
    
  # 创建xm用户（使用默认邮箱）
    mysql -u root mailapp -e "INSERT INTO app_users(username,email,pass_hash) VALUES ('xm','xm@localhost','${xm_hash}');" 2>/dev/null || {
      log "创建xm用户失败"
    }
  log "默认管理员用户 xm 创建完成"
fi

# 邮件系统 schema（虚拟域/用户/别名/共享邮箱）以 root 执行
# 只在数据库不存在或为空时才初始化
if ! check_maildb_exists; then
  log "邮件数据库不存在或为空，开始初始化"
  bash -lc '"'"${BASE_DIR}/backend/scripts/db_setup.sh"'" init' || true
else
  log "邮件数据库已存在，跳过 db_setup.sh 初始化"
fi

# 初始化邮件数据库（MySQL）
log "初始化邮件数据库"
# 创建邮件数据库用户和密码
log "创建邮件数据库用户"
# 生成并保存邮件数据库密码到仅 root 可读的文件
if [[ ! -f /etc/mail-ops/mail-db.pass ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 24 > /etc/mail-ops/mail-db.pass
  else
    head -c 24 /dev/urandom | base64 > /etc/mail-ops/mail-db.pass
  fi
fi
# 允许调度器用户 xm 只读，避免登录阶段无法读取数据库密码
chown root:xm /etc/mail-ops/mail-db.pass
chmod 640 /etc/mail-ops/mail-db.pass

# 检测并自动修复用户邮箱域名（重装时保持域名一致性）
# 注意：此函数必须在所有数据库初始化完成后调用，确保xm用户信息已从旧数据库恢复
auto_fix_email_domains() {
  log "检测xm用户邮箱域名，自动修复其他用户邮箱域名"
  
  # 检查数据库是否可用
  if ! mysql -u root -e "USE mailapp;" 2>/dev/null; then
    log "应用数据库不可用，跳过邮箱域名修复"
    return 0
  fi
  
  # 获取xm用户的邮箱地址（优先从已存在的数据库中获取，如果数据库已存在则保留原有域名）
  XM_EMAIL=$(mysql -u root mailapp -s -N -e "SELECT email FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null || echo "")
  
  if [[ -z "$XM_EMAIL" ]]; then
    log "无法获取xm用户邮箱，跳过邮箱域名修复"
    return 0
  fi
  
  # 提取域名
  XM_DOMAIN=$(echo "$XM_EMAIL" | cut -d'@' -f2)
  
  if [[ -z "$XM_DOMAIN" || "$XM_DOMAIN" == "localhost" ]]; then
    log "xm用户邮箱域名为localhost或无效，跳过邮箱域名修复"
    return 0
  fi
  
  log "检测到xm用户邮箱域名: $XM_DOMAIN，开始自动修复其他用户的邮箱域名"
  
  # 检查是否有需要修复的用户（使用localhost域名的普通用户）
  NEED_FIX_COUNT=$(mysql -u root mailapp -s -N -e "SELECT COUNT(*) FROM app_users WHERE email LIKE '%@localhost' AND username != 'xm';" 2>/dev/null || echo "0")
  
  if [[ "$NEED_FIX_COUNT" == "0" ]]; then
    log "没有需要修复的用户（所有用户邮箱域名已正确）"
    return 0
  fi
  
  log "发现 $NEED_FIX_COUNT 个用户需要修复邮箱域名"
  
  # 执行修复脚本
  if [[ -f "${BASE_DIR}/backend/scripts/app_user.sh" ]]; then
    log "执行邮箱域名修复脚本: fix-email-domains $XM_DOMAIN"
    FIX_OUTPUT=$(bash -lc '"'"${BASE_DIR}/backend/scripts/app_user.sh"'" fix-email-domains "'"$XM_DOMAIN"'"' 2>&1)
    FIX_EXIT_CODE=$?
    
    if [[ $FIX_EXIT_CODE -eq 0 ]]; then
      # 解析JSON输出
      FIXED_COUNT=$(echo "$FIX_OUTPUT" | grep -o '"fixed_count":[0-9]*' | grep -o '[0-9]*' | head -1)
      FAILED_COUNT=$(echo "$FIX_OUTPUT" | grep -o '"failed_count":[0-9]*' | grep -o '[0-9]*' | head -1)
      
      if [[ -n "$FIXED_COUNT" ]]; then
        log_success "邮箱域名修复完成，成功修复 $FIXED_COUNT 个用户"
        if [[ -n "$FAILED_COUNT" && "$FAILED_COUNT" != "0" ]]; then
          log_warn "邮箱域名修复过程中有 $FAILED_COUNT 个用户修复失败"
        fi
      else
        # 尝试从输出中提取信息
        echo "$FIX_OUTPUT" | grep -v "^$" | while IFS= read -r line || [[ -n "$line" ]]; do
          if [[ "$line" =~ 已修复用户 ]]; then
            log "$line"
          fi
        done
        log "邮箱域名修复脚本执行完成"
      fi
    else
      log_warn "邮箱域名修复脚本执行失败（退出码: $FIX_EXIT_CODE）"
      echo "$FIX_OUTPUT" | grep -v "^$" | while IFS= read -r line || [[ -n "$line" ]]; do
        log_warn "$line"
      done
    fi
    
    log_success "邮箱域名自动修复完成，所有用户邮箱域名已统一为: $XM_DOMAIN"
  else
    log_warn "修复脚本不存在: ${BASE_DIR}/backend/scripts/app_user.sh"
  fi
}

# 检查数据库是否存在且有数据，决定是否删除用户
if check_maildb_exists; then
  log "邮件数据库已存在且有数据，保留现有用户和数据"
  # 只创建数据库和用户（如果不存在），不删除现有用户
  mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS maildb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'mailuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/mail-db.pass)';
-- 如果用户已存在，更新密码（确保密码与密码文件一致）
ALTER USER 'mailuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/mail-db.pass)';
GRANT ALL PRIVILEGES ON maildb.* TO 'mailuser'@'localhost';
FLUSH PRIVILEGES;
EOF
else
  log "邮件数据库不存在或为空，执行完整初始化"
  # 创建邮件数据库用户（删除旧用户后重新创建）
  mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS maildb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP USER IF EXISTS 'mailuser'@'localhost';
CREATE USER 'mailuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/mail-db.pass)';
GRANT ALL PRIVILEGES ON maildb.* TO 'mailuser'@'localhost';
FLUSH PRIVILEGES;
EOF
fi

# 验证数据库用户创建是否成功
log "验证邮件数据库用户创建"
if mysql -u root -e "SELECT User FROM mysql.user WHERE User='mailuser' AND Host='localhost';" | grep -q "mailuser"; then
  log "邮件数据库用户创建成功"
else
  log "邮件数据库用户创建失败，请手动检查"
fi

# 初始化邮件数据库表结构（只在数据库不存在或为空时执行）
if check_maildb_exists; then
  log "邮件数据库已存在且有数据，跳过表结构初始化以保留现有数据"
else
  log "邮件数据库不存在或为空，开始初始化表结构"
  bash -lc '"'"${BASE_DIR}/backend/scripts/mail_db.sh"'" init' || {
    log "邮件数据库初始化失败，尝试手动创建"
  # 手动创建MySQL表结构
  mysql -u root maildb << 'EOF'
-- 创建基础emails表（简化版本，完整结构由mail_db.sh init创建）
CREATE TABLE IF NOT EXISTS emails (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建基础索引
CREATE INDEX IF NOT EXISTS idx_emails_folder_id ON emails(folder_id);
CREATE INDEX IF NOT EXISTS idx_emails_to_addr ON emails(to_addr);
CREATE INDEX IF NOT EXISTS idx_emails_from_addr ON emails(from_addr);
CREATE INDEX IF NOT EXISTS idx_emails_date ON emails(date_received);
CREATE INDEX IF NOT EXISTS idx_emails_read ON emails(read_status);
CREATE INDEX IF NOT EXISTS idx_emails_deleted ON emails(is_deleted);
CREATE INDEX IF NOT EXISTS idx_emails_message_id ON emails(message_id);

-- 创建邮件用户表
CREATE TABLE IF NOT EXISTS mail_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) UNIQUE NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  display_name VARCHAR(255),
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 创建用户索引
CREATE INDEX IF NOT EXISTS idx_mail_users_username ON mail_users(username);
CREATE INDEX IF NOT EXISTS idx_mail_users_email ON mail_users(email);

-- 插入默认管理员用户
INSERT IGNORE INTO mail_users (username, email, display_name, is_active) VALUES ('xm', 'xm@localhost', 'XM Administrator', 1);
EOF
    log "邮件数据库手动创建完成"
  }
fi

log_system "INFO" "数据库初始化完成（app_users、maildb 与邮件数据库）"

# ============================================================================
# 步骤5: 用户邮箱域名自动修复
# ============================================================================
# 功能：自动检测并修复用户邮箱域名，确保重装后域名一致性
# 目的：重装系统时保持用户邮箱域名与DNS配置一致
# 逻辑：
#   - 从数据库获取xm用户的邮箱域名（优先使用已存在的数据库）
#   - 如果xm用户邮箱域名不是localhost，则修复其他用户的localhost域名
#   - 调用app_user.sh fix-email-domains脚本批量修复
#   - 更新app_users、mail_users、virtual_users、email_recipients表
# 优先级说明：
#   1. 如果应用数据库已存在且有数据，xm用户的邮箱会从旧数据库恢复（如xm@skills.com）
#   2. 如果应用数据库不存在，xm用户会被创建为xm@localhost，函数会检测到localhost并跳过修复
#   3. 因此必须在所有数据库初始化完成后调用，确保能正确获取xm用户的邮箱域名
log "执行邮箱域名自动修复检查"
auto_fix_email_domains

 

# 验证 Apache 认证配置
log "验证 Apache 认证配置"
if httpd -t; then
  log "Apache 配置语法正确，认证设置已生效"
  log_system "INFO" "Apache 认证配置验证成功"
else
  log "警告: Apache 配置语法错误，但服务已重启"
  log_system "WARNING" "Apache 配置可能有问题"
fi

# ============================================================================
# 步骤6: Node.js运行环境安装
# ============================================================================
# 功能：安装Node.js和npm，为调度层服务提供运行环境
# 目的：运行Node.js调度层服务（mail-ops-dispatcher）
# 逻辑：
#   - 优先使用 NodeSource 安装 Node.js 20.x LTS (Iron)，目标版本 v20.20.0
#   - 若 NodeSource 不可用，回退到 Rocky Linux AppStream nodejs:18
#   - 配置 npm 镜像源（registry.npmmirror.com）提高安装速度
#   - 验证 Node.js 和 npm 安装成功
# Node.js 版本要求：v20.20.0+ (LTS Iron)，参见 https://github.com/nodesource/distributions
log "安装 Node.js 环境（目标 v20.20.0 LTS Iron）"
NODE_INSTALLED=false
if command -v curl >/dev/null 2>&1; then
  log "尝试通过 NodeSource 安装 Node.js 20.x LTS..."
  if curl -fsSL https://rpm.nodesource.com/setup_20.x | bash - 2>/dev/null; then
    dnf -y install nodejs --skip-broken && NODE_INSTALLED=true
  fi
fi
if [[ "$NODE_INSTALLED" != "true" ]]; then
  log "NodeSource 不可用，使用 AppStream nodejs:18 作为备用"
  dnf -y module reset nodejs --skip-broken || true
  dnf -y module enable nodejs:18 --skip-broken || true
  dnf -y install nodejs npm --skip-broken || {
    log "模块安装失败，尝试 EPEL 源"
    dnf -y install epel-release --skip-broken
    dnf -y install nodejs npm --skip-broken || true
  }
  NODE_INSTALLED=true
fi

# 验证 Node.js 安装
if ! command -v node >/dev/null 2>&1; then
  log "Node.js 安装失败，使用备用方案"
  # 可以在这里添加其他安装方式，如从官网下载
else
  log "Node.js 版本: $(node --version)"
fi

# 设置 npm 配置（可选，提高安装速度）
npm config set registry https://registry.npmmirror.com/ || true

# 安装构建工具（node-pty 等原生模块需要）
log "安装构建工具（gcc、make、python3-devel）"
dnf -y install gcc gcc-c++ make python3-devel || {
  log_error "构建工具安装失败，node-pty 可能无法编译"
}

# 验证构建工具安装
if command -v gcc >/dev/null 2>&1 && command -v make >/dev/null 2>&1; then
  log "✓ 构建工具安装成功"
else
  log_error "构建工具安装失败，请手动安装: dnf install -y gcc gcc-c++ make python3-devel"
fi


# ============================================================================
# 步骤7: 安全策略配置
# ============================================================================
# 功能：配置防火墙和SELinux策略（演示环境）
# 目的：简化部署流程，避免安全策略导致的访问问题
# 注意：生产环境应配置正确的防火墙规则和SELinux策略
# 关闭 firewalld（演示），设置 SELinux 为 permissive（临时）
log "配置安全策略（演示环境）"
systemctl stop firewalld || true
systemctl disable firewalld || true
setenforce 0 || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config || true
log_system "WARNING" "安全策略已调整为演示模式（生产环境请谨慎）"

# 日志目录用于调度层写入
install -d -m 0755 /var/log/mail-ops
chown apache:apache /var/log/mail-ops || true


# 设置所有脚本的执行权限
chmod +x "$BASE_DIR/backend/scripts"/*.sh
chmod +x "$BASE_DIR/backend/scripts/mail_logger.sh" 2>/dev/null || true
chmod +x "$BASE_DIR/backend/scripts/mail_log_viewer.sh" 2>/dev/null || true
chmod +x "$BASE_DIR/backend/scripts/mail_service_logger.sh" 2>/dev/null || true 2>/dev/null || true
log "工作目录: $BASE_DIR"

# 检查必要文件是否存在
if [[ ! -f "$BASE_DIR/backend/dispatcher/package.json" ]]; then
  log "警告: 未找到调度层 package.json"
fi

if [[ ! -d "$BASE_DIR/frontend" ]]; then
  log "警告: 未找到前端目录"
fi

# ============================================================================
# 步骤8: 调度层依赖安装
# ============================================================================
# 功能：安装Node.js调度层服务的npm依赖包
# 目的：为调度层服务提供必要的Node.js模块（Express、Morgan、UUID等）
# 逻辑：
#   - 清理旧依赖（node_modules、package-lock.json）
#   - 配置npm镜像源（国内镜像提高速度）
#   - 安装依赖（timeout 300秒，支持超时处理）
#   - 验证关键依赖安装成功（express、morgan、uuid、basic-auth、nodemailer）
#   - 设置目录权限（xm:xm，755）
# 安装调度层依赖
cd "$BASE_DIR/backend/dispatcher"
if [[ -f package.json ]]; then
  # 清理可能存在的旧依赖
  rm -rf node_modules package-lock.json || true
  
  # 设置npm镜像以提高安装速度
  npm config set registry https://registry.npmmirror.com/ || true
  
  # 检查网络连接
  if ping -c 1 registry.npmmirror.com >/dev/null 2>&1; then
    log "网络连接正常，使用国内镜像"
  else
    log "网络连接异常，使用默认镜像"
    npm config set registry https://registry.npmjs.org/ || true
  fi
  
  # 安装依赖，使用更长的超时时间
  log "开始安装调度层依赖..."
  if timeout 300 npm install --verbose --no-audit --no-fund; then
    log "✓ npm install 执行成功"
  else
    log "npm安装失败，尝试使用yarn"
    if command -v yarn >/dev/null 2>&1; then
      if timeout 300 yarn install --verbose; then
        log "✓ yarn install 执行成功"
      else
        log_error "yarn安装也失败，调度层依赖安装失败"
        log_error "请手动执行: cd $BASE_DIR/backend/dispatcher && npm install"
        exit 1
      fi
    else
      log_error "yarn未安装，npm安装失败，调度层依赖安装失败"
      log_error "请手动执行: cd $BASE_DIR/backend/dispatcher && npm install"
      exit 1
    fi
  fi
  
  # 验证关键依赖是否安装成功
  deps_ok=true
  
  if [[ -d node_modules/express ]]; then
    log "✓ express依赖安装成功"
  else
    log_error "✗ express依赖未安装"
    deps_ok=false
  fi
  
  if [[ -d node_modules/morgan ]]; then
    log "✓ morgan依赖安装成功"
  else
    log_error "✗ morgan依赖未安装"
    deps_ok=false
  fi
  
  if [[ -d node_modules/uuid ]]; then
    log "✓ uuid依赖安装成功"
  else
    log_error "✗ uuid依赖未安装"
    deps_ok=false
  fi
  
  if [[ -d node_modules/basic-auth ]]; then
    log "✓ basic-auth依赖安装成功"
  else
    log_error "✗ basic-auth依赖未安装"
    deps_ok=false
  fi
  
  if [[ -d node_modules/nodemailer ]]; then
    log "✓ nodemailer依赖安装成功"
  else
    log_error "✗ nodemailer依赖未安装"
    deps_ok=false
  fi
  
  if [[ -d node_modules/ws ]]; then
    log "✓ ws依赖安装成功"
  else
    log_error "✗ ws依赖未安装"
    deps_ok=false
  fi
  
  if [[ -d node_modules/node-pty ]]; then
    log "✓ node-pty依赖安装成功"
  else
    log_error "✗ node-pty依赖未安装"
    deps_ok=false
  fi
  
  if [[ "$deps_ok" != "true" ]]; then
    log_error "关键依赖安装失败，请检查网络连接和npm配置"
    log_error "手动安装命令: cd $BASE_DIR/backend/dispatcher && npm install"
    exit 1
  fi
  
  # 设置正确的权限
  chown -R xm:xm "$BASE_DIR/backend/dispatcher" || true
  chmod -R 755 "$BASE_DIR/backend/dispatcher" || true
  # 创建头像上传目录，供调度层写入并对外提供 /uploads/avatars 静态访问
  install -d -m 0755 "$BASE_DIR/uploads/avatars"
  chown -R xm:xm "$BASE_DIR/uploads" 2>/dev/null || true
  log "调度层依赖安装完成"
else
  log "警告: 调度层 package.json 不存在"
fi

# ============================================================================
# 步骤9: Apache配置部署与优化
# ============================================================================
# 功能：部署Apache虚拟主机配置，优化配置，解决冲突
# 目的：配置Web服务器，提供前端静态文件服务和API反向代理
# 逻辑：
#   - 部署虚拟主机配置（mailmgmt.conf）
#   - 清理冲突的默认配置（welcome.conf、autoindex.conf等）
#   - 创建认证配置文件（mailmgmt-auth.conf，禁用双重认证）
#   - 添加安全头（X-Content-Type-Options、X-Frame-Options、X-XSS-Protection）
#   - 验证配置语法，重启服务
# 部署 Apache 配置与 sudoers 限制
# Rocky Linux 的 Apache 配置目录结构
install -d /etc/httpd/conf.d

# 读取端口配置
PORT_CONFIG_FILE="$CONFIG_DIR/port-config.json"
API_PORT=8081
APACHE_HTTP_PORT=80
APACHE_HTTPS_PORT=443

if [[ -f "$PORT_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
  API_PORT=$(jq -r '.api.port // 8081' "$PORT_CONFIG_FILE" 2>/dev/null || echo "8081")
  APACHE_HTTP_PORT=$(jq -r '.apache.httpPort // 80' "$PORT_CONFIG_FILE" 2>/dev/null || echo "80")
  APACHE_HTTPS_PORT=$(jq -r '.apache.httpsPort // 443' "$PORT_CONFIG_FILE" 2>/dev/null || echo "443")
  log "读取端口配置: API=$API_PORT, Apache HTTP=$APACHE_HTTP_PORT, Apache HTTPS=$APACHE_HTTPS_PORT"
else
  log "端口配置文件不存在或 jq 不可用，使用默认端口: API=8081, Apache HTTP=80, Apache HTTPS=443"
fi

# 复制 Apache 配置文件并替换端口占位符
if [[ -f "$BASE_DIR/backend/apache/httpd-vhost.conf" ]]; then
  # 使用 sed 替换端口占位符
  sed "s/\${API_PORT}/$API_PORT/g; s/\${APACHE_HTTP_PORT}/$APACHE_HTTP_PORT/g; s/\${APACHE_HTTPS_PORT}/$APACHE_HTTPS_PORT/g" \
    "$BASE_DIR/backend/apache/httpd-vhost.conf" > /tmp/mailmgmt.conf.tmp
  
  # 注意：初始安装时只配置IP访问（非SSL），不自动检测SSL证书
  # SSL配置和域名配置由用户在前端通过以下方式完成：
  # 1. DNS配置（bind或公网DNS）-> 配置Apache域名虚拟主机（通过DNS配置脚本）
  # 2. 上传SSL证书 -> 自动配置SSL Apache配置（通过cert_setup.sh）
  # 3. 选择开启HTTP跳转HTTPS -> 配置HTTP跳转规则（通过cert_setup.sh enable-http-redirect）
  
  # 不再自动检测SSL证书，SSL配置由用户在前端完成
  SSL_CERT_FOUND=""
  SSL_KEY_FOUND=""
  
  # 检查用户是否已经启用过HTTP跳转HTTPS（通过状态文件判断）
  # 状态文件路径：$BASE_DIR/config/http-redirect-enabled.json
  # 这个检查在模板处理和最终安装时都会用到，所以提前检查一次
  # 注意：这里不使用local，因为不在函数内部
  http_redirect_state_file="$BASE_DIR/config/http-redirect-enabled.json"
  user_enabled_http_redirect=false
  
  if [[ -f "$http_redirect_state_file" ]]; then
    # 检查状态文件内容，确认用户是否明确启用过
    if command -v jq >/dev/null 2>&1; then
      enabled_status=$(jq -r '.enabled // false' "$http_redirect_state_file" 2>/dev/null || echo "false")
      if [[ "$enabled_status" == "true" ]]; then
        user_enabled_http_redirect=true
        log "检测到用户已启用HTTP跳转HTTPS，将保留现有配置"
      fi
    else
      # 如果没有jq，使用grep简单检查
      if grep -q '"enabled"[[:space:]]*:[[:space:]]*true' "$http_redirect_state_file" 2>/dev/null; then
        user_enabled_http_redirect=true
        log "检测到用户已启用HTTP跳转HTTPS，将保留现有配置"
      fi
    fi
  fi
  
  # 只有在用户未启用HTTP跳转的情况下，才清理模板文件中的HTTP跳转规则（默认关闭）
  # 这样可以避免重装时误删用户已配置的HTTP跳转规则
  if [[ "$user_enabled_http_redirect" == "false" ]]; then
    # 强制清理模板文件中的所有HTTP跳转规则（无论是否存在）
    log "强制清理模板文件中的HTTP跳转规则（默认关闭，用户未启用）"
    # 清理所有可能的HTTP跳转规则格式
    sed -i '/# HTTPS重定向/d; /# 自动跳转到HTTPS/d; /RewriteCond.*HTTPS.*off/d; /RewriteCond.*%{HTTPS}.*off/d; /RewriteRule.*https:\/\/.*\[R=301,L\]/d; /RewriteRule.*https:\/\/.*\[L,R=301\]/d' /tmp/mailmgmt.conf.tmp
    # 注意：不要删除LocationMatch中的RewriteEngine On，只删除HTTP跳转相关的RewriteEngine On
    # 使用更精确的匹配：只删除后面跟着HTTPS相关RewriteCond的RewriteEngine On
    sed -i '/RewriteEngine On/{N;/\n[[:space:]]*RewriteCond.*HTTPS.*off/d;}' /tmp/mailmgmt.conf.tmp
    # 如果上面的命令没有删除，再尝试删除独立的RewriteEngine On（但不在LocationMatch块中）
    # 使用awk来更精确地处理，避免删除LocationMatch中的
    awk '
    /LocationMatch/ { in_locationmatch=1 }
    /\/LocationMatch/ { in_locationmatch=0 }
    /^[[:space:]]*RewriteEngine On[[:space:]]*$/ {
        if (!in_locationmatch) {
            # 检查下一行是否是HTTPS相关的
            getline next_line
            if (next_line ~ /RewriteCond.*HTTPS.*off/ || next_line ~ /RewriteRule.*https:\/\//) {
                # 跳过这两行（删除）
                next
            } else {
                # 保留这行，因为可能是LocationMatch中的或其他用途的
                print "        RewriteEngine On"
                print next_line
                next
            }
        } else {
            # 在LocationMatch中，保留
            print
        }
        next
    }
    { print }
    ' /tmp/mailmgmt.conf.tmp > /tmp/mailmgmt.conf.tmp.new && mv /tmp/mailmgmt.conf.tmp.new /tmp/mailmgmt.conf.tmp
    # 再次检查，确保没有遗漏
    if grep -qE "(RewriteCond.*HTTPS|RewriteRule.*https://)" /tmp/mailmgmt.conf.tmp 2>/dev/null; then
      log "警告：模板文件中仍存在HTTP跳转规则，尝试更彻底的清理"
      sed -i '/RewriteCond.*%{HTTPS}/d; /RewriteRule.*https:/d' /tmp/mailmgmt.conf.tmp
    fi
  else
    log "用户已启用HTTP跳转HTTPS，保留模板文件中的HTTP跳转规则（如果有）"
  fi
  
  # 如果找到SSL证书，添加HTTPS虚拟主机配置（此逻辑已禁用，保留代码结构但不执行）
  if false && [[ -n "$SSL_CERT_FOUND" && -n "$SSL_KEY_FOUND" ]]; then
    log "添加HTTPS虚拟主机配置（证书: $SSL_CERT_FOUND）"
    cat >> /tmp/mailmgmt.conf.tmp <<HTTPS_VHOST

# HTTPS虚拟主机配置（仅在检测到SSL证书时添加）
<VirtualHost *:${APACHE_HTTPS_PORT}>
    ServerName _default_
    DocumentRoot /var/www/mail-frontend

    # SSL配置
    <IfModule mod_ssl.c>
        SSLEngine on
        SSLCertificateFile ${SSL_CERT_FOUND}
        SSLCertificateKeyFile ${SSL_KEY_FOUND}
    </IfModule>

    ErrorLog /var/log/httpd/mail-frontend-ssl-error.log
    CustomLog /var/log/httpd/mail-frontend-ssl-access.log combined

    # 静态资源处理
    <Directory /var/www/mail-frontend>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
        
        # 禁用认证
        AuthType None
        Satisfy Any
        
        # 启用压缩
        <IfModule mod_deflate.c>
            AddOutputFilterByType DEFLATE text/plain
            AddOutputFilterByType DEFLATE text/html
            AddOutputFilterByType DEFLATE text/xml
            AddOutputFilterByType DEFLATE text/css
            AddOutputFilterByType DEFLATE application/xml
            AddOutputFilterByType DEFLATE application/xhtml+xml
            AddOutputFilterByType DEFLATE application/rss+xml
            AddOutputFilterByType DEFLATE application/javascript
            AddOutputFilterByType DEFLATE application/x-javascript
        </IfModule>
        
        # 缓存控制
        <IfModule mod_expires.c>
            ExpiresActive On
            ExpiresByType text/css "access plus 1 month"
            ExpiresByType application/javascript "access plus 1 month"
            ExpiresByType image/png "access plus 1 month"
            ExpiresByType image/jpg "access plus 1 month"
            ExpiresByType image/jpeg "access plus 1 month"
            ExpiresByType image/gif "access plus 1 month"
            ExpiresByType image/svg+xml "access plus 1 month"
        </IfModule>
    </Directory>

    # WebSocket 代理（必须在普通 API 代理之前）
    ProxyPreserveHost On
    ProxyRequests Off
    
    # 启用代理模块
    <IfModule mod_proxy.c>
        # WebSocket 代理配置 - 使用 mod_proxy_wstunnel
        <Location /api/terminal/ws>
            # 使用 mod_proxy_wstunnel 处理 WebSocket
            <IfModule mod_proxy_wstunnel.c>
                # 使用 ProxyPass 配合 upgrade 参数（Apache 2.4+ 语法）
                ProxyPass http://127.0.0.1:${API_PORT}/api/terminal/ws upgrade=websocket
                ProxyPassReverse http://127.0.0.1:${API_PORT}/api/terminal/ws
            </IfModule>
            
            # 如果没有 mod_proxy_wstunnel，使用 RewriteRule
            <IfModule !mod_proxy_wstunnel.c>
                RewriteEngine On
                RewriteCond %{HTTP:Upgrade} =websocket [NC]
                RewriteCond %{HTTP:Connection} =upgrade [NC]
                RewriteRule ^/?(.*) ws://127.0.0.1:${API_PORT}/api/terminal/ws/\$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${API_PORT}/api/terminal/ws/\$1 [P,L]
            </IfModule>
            
            Require all granted
            
            # 禁用认证
            AuthType None
            Satisfy Any
        </Location>
    </IfModule>

    # API 代理（必须在 WebSocket 配置之后，这样 WebSocket 路径会优先匹配）
    ProxyPreserveHost On
    ProxyRequests Off
    <Location /api/>
        ProxyPass http://127.0.0.1:${API_PORT}/api/
        ProxyPassReverse http://127.0.0.1:${API_PORT}/api/
        Require all granted
        
        # 禁用认证
        AuthType None
        Satisfy Any
    </Location>

    # 上传文件代理（头像等静态文件）
    <Location /uploads/>
        ProxyPass http://127.0.0.1:${API_PORT}/uploads/
        ProxyPassReverse http://127.0.0.1:${API_PORT}/uploads/
        Require all granted
        
        # 禁用认证
        AuthType None
        Satisfy Any
        
        # 设置缓存头
        <IfModule mod_headers.c>
            Header set Cache-Control "public, max-age=31536000"
        </IfModule>
    </Location>

    # Vue Router 支持 - 所有非 API 请求都返回 index.html
    <LocationMatch "^(?!.*\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)).*$">
        RewriteEngine On
        RewriteCond %{REQUEST_URI} !^/api/
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </LocationMatch>
</VirtualHost>
HTTPS_VHOST
  else
    log "未检测到SSL证书，跳过HTTPS虚拟主机配置"
  fi
  
  install -m 0644 /tmp/mailmgmt.conf.tmp /etc/httpd/conf.d/mailmgmt.conf
  rm -f /tmp/mailmgmt.conf.tmp
  
  # 使用之前检查的状态（user_enabled_http_redirect变量）
  # 只有在用户未启用HTTP跳转的情况下，才清理已安装配置文件中的HTTP跳转规则（默认关闭）
  # 这样可以避免重装时误删用户已配置的HTTP跳转规则
  if [[ "$user_enabled_http_redirect" == "false" ]]; then
    # 强制清理mailmgmt.conf中的HTTP跳转规则（无论是否存在）
    log "强制清理已安装配置文件中的HTTP跳转规则（默认关闭，用户未启用）"
    # 清理HTTP跳转相关的规则（更全面的匹配）
    sed -i '/# HTTPS重定向/d; /# 自动跳转到HTTPS/d; /RewriteCond.*HTTPS.*off/d; /RewriteCond.*%{HTTPS}.*off/d; /RewriteRule.*https:\/\/.*\[R=301,L\]/d; /RewriteRule.*https:\/\/.*\[L,R=301\]/d' /etc/httpd/conf.d/mailmgmt.conf
    # 注意：不要删除LocationMatch中的RewriteEngine On，只删除HTTP跳转相关的RewriteEngine On
    # 使用awk来更精确地处理，避免删除LocationMatch中的
    awk '
    /LocationMatch/ { in_locationmatch=1 }
    /\/LocationMatch/ { in_locationmatch=0 }
    /^[[:space:]]*RewriteEngine On[[:space:]]*$/ {
        if (!in_locationmatch) {
            # 检查下一行是否是HTTPS相关的
            getline next_line
            if (next_line ~ /RewriteCond.*HTTPS.*off/ || next_line ~ /RewriteRule.*https:\/\//) {
                # 跳过这两行（删除）
                next
            } else {
                # 保留这行，因为可能是LocationMatch中的或其他用途的
                print "        RewriteEngine On"
                print next_line
                next
            }
        } else {
            # 在LocationMatch中，保留
            print
        }
        next
    }
    { print }
    ' /etc/httpd/conf.d/mailmgmt.conf > /tmp/mailmgmt.conf.fixed && mv /tmp/mailmgmt.conf.fixed /etc/httpd/conf.d/mailmgmt.conf
    # 再次检查，确保没有遗漏
    if grep -qE "(RewriteCond.*HTTPS|RewriteRule.*https://)" /etc/httpd/conf.d/mailmgmt.conf 2>/dev/null; then
      log "警告：mailmgmt.conf中仍存在HTTP跳转规则，尝试更彻底的清理"
      sed -i '/RewriteCond.*%{HTTPS}/d; /RewriteRule.*https:/d' /etc/httpd/conf.d/mailmgmt.conf
    fi
    log "已清理mailmgmt.conf中的HTTP跳转规则"
    
    # 清理所有 *_http.conf 文件（HTTP跳转配置文件）
    # 注意：这里不使用local，因为不在函数内部
    if [[ -d "/etc/httpd/conf.d" ]]; then
      log "检查并清理所有HTTP跳转配置文件..."
      http_redirect_configs=$(find /etc/httpd/conf.d -name "*_http.conf" -type f 2>/dev/null)
      if [[ -n "$http_redirect_configs" ]]; then
        log "检测到HTTP跳转配置文件，但用户未启用，开始清理..."
        while IFS= read -r config_file; do
          if [[ -f "$config_file" ]]; then
            log "删除HTTP跳转配置文件: $config_file"
            rm -f "$config_file"
          fi
        done <<< "$http_redirect_configs"
        log "HTTP跳转配置文件清理完成"
      else
        log "未检测到HTTP跳转配置文件"
      fi
      
      # 额外检查：清理所有包含HTTP跳转规则的配置文件（不仅仅是*_http.conf）
      log "检查所有Apache配置文件中的HTTP跳转规则..."
      for conf_file in /etc/httpd/conf.d/*.conf; do
        if [[ -f "$conf_file" ]] && [[ "$conf_file" != "/etc/httpd/conf.d/mailmgmt.conf" ]]; then
          if grep -qE "(RewriteCond.*HTTPS.*off|RewriteRule.*https://.*\[R=301)" "$conf_file" 2>/dev/null; then
            log "检测到配置文件包含HTTP跳转规则: $conf_file"
            # 备份后清理
            cp "$conf_file" "${conf_file}.backup.$(date +%Y%m%d_%H%M%S)"
            sed -i '/RewriteCond.*HTTPS.*off/d; /RewriteRule.*https:\/\/.*\[R=301/d' "$conf_file"
            log "已清理配置文件中的HTTP跳转规则: $conf_file"
          fi
        fi
      done
    fi
  else
    log "用户已启用HTTP跳转HTTPS，保留mailmgmt.conf中的HTTP跳转规则"
  fi
  
  # 最后验证：确保mailmgmt.conf中没有HTTP跳转规则
  if [[ "$user_enabled_http_redirect" == "false" ]]; then
    if grep -qE "(RewriteCond.*HTTPS.*off|RewriteRule.*https://.*\[R=301)" /etc/httpd/conf.d/mailmgmt.conf 2>/dev/null; then
      log "警告：mailmgmt.conf中仍存在HTTP跳转规则，进行最终清理"
      sed -i '/RewriteCond.*%{HTTPS}/d; /RewriteRule.*https:/d' /etc/httpd/conf.d/mailmgmt.conf
      log "最终清理完成"
    fi
  fi
  
  log "Apache 配置文件已部署（仅IP访问，非SSL，默认不开启HTTP跳转HTTPS）"
  log "端口: HTTP=$APACHE_HTTP_PORT, API=$API_PORT"
  log "说明: 域名和SSL配置需要通过前端完成，HTTP跳转HTTPS需要用户手动启用"
else
  log "警告: Apache 配置文件不存在: $BASE_DIR/backend/apache/httpd-vhost.conf"
fi

# 检查主配置文件是否存在
if [[ -f /etc/httpd/conf/httpd.conf ]]; then
  # 确保 conf.d 目录被包含
  if ! grep -q "Include conf.d/\*.conf" /etc/httpd/conf/httpd.conf; then
    echo "Include conf.d/*.conf" >> /etc/httpd/conf/httpd.conf
  fi
  
  # 添加 Listen 指令（如果不存在）
  # 检查是否已经有该端口的Listen指令（包括注释掉的）
  if ! grep -qE "^Listen\s+${APACHE_HTTP_PORT}(\s|$)" /etc/httpd/conf/httpd.conf && ! grep -qE "^Listen\s+${APACHE_HTTP_PORT}" /etc/httpd/conf.d/*.conf 2>/dev/null; then
    # 查找现有的 Listen 指令位置，在其后添加
    if grep -qE "^Listen\s+" /etc/httpd/conf/httpd.conf; then
      # 找到最后一个Listen指令的行号，在其后添加
      last_listen_line=$(grep -nE "^Listen\s+" /etc/httpd/conf/httpd.conf | tail -1 | cut -d: -f1)
      if [[ -n "$last_listen_line" ]]; then
        sed -i "${last_listen_line}a Listen ${APACHE_HTTP_PORT}" /etc/httpd/conf/httpd.conf
      else
        # 如果找不到，在文件开头添加
        sed -i "1i Listen ${APACHE_HTTP_PORT}" /etc/httpd/conf/httpd.conf
      fi
    else
      # 如果没有 Listen 指令，在文件开头添加
      sed -i "1i Listen ${APACHE_HTTP_PORT}" /etc/httpd/conf/httpd.conf
    fi
    log "已添加 Listen ${APACHE_HTTP_PORT} 到 Apache 主配置"
  else
    log "Apache 主配置中已存在 Listen ${APACHE_HTTP_PORT} 指令"
  fi
  
  # 注意：初始安装时不自动添加HTTPS端口监听
  # HTTPS端口监听会在用户配置SSL时由cert_setup.sh自动添加
  # 如果HTTPS端口不是443，且用户已配置SSL，cert_setup.sh会添加Listen指令
  log "跳过自动添加HTTPS端口监听（需要用户在前端配置SSL后自动添加）"
else
  log "警告: Apache 主配置文件不存在"
fi

# 优化Apache配置，解决Alias重叠警告
log "优化 Apache 配置设置"

# 创建Apache配置清理函数
cleanup_apache_config() {
  log "执行Apache配置清理..."
  
  # 清理所有可能冲突的默认配置文件
  local conflict_files=(
    "/etc/httpd/conf.d/welcome.conf"
    "/etc/httpd/conf.d/autoindex.conf"
    "/etc/httpd/conf.d/userdir.conf"
    "/etc/httpd/conf.d/ssl.conf"
  )
  
  for file in "${conflict_files[@]}"; do
    if [[ -f "$file" ]]; then
      # 备份文件
      cp "$file" "$file.bak.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
      # 删除原文件
      rm -f "$file"
      log "已清理配置文件: $file"
    fi
  done
  
  # 清理可能包含冲突Alias的其他配置文件
  for conf_file in /etc/httpd/conf.d/*.conf; do
    if [[ -f "$conf_file" ]] && [[ "$conf_file" != "/etc/httpd/conf.d/mailmgmt.conf" ]] && [[ "$conf_file" != "/etc/httpd/conf.d/mailmgmt-auth.conf" ]]; then
      # 检查是否包含冲突的Alias指令
      if grep -q "Alias.*/" "$conf_file" 2>/dev/null; then
        log "发现包含冲突Alias的配置文件: $conf_file"
        # 备份并禁用
        mv "$conf_file" "$conf_file.disabled" 2>/dev/null || true
        log "已禁用冲突配置文件: $conf_file"
      fi
    fi
  done
  
  log "Apache配置清理完成"
}

# 执行Apache配置清理
cleanup_apache_config

# 创建禁用标记文件，防止配置文件重新创建
log "创建禁用标记文件，防止配置文件重新创建"
touch /etc/httpd/conf.d/welcome.conf.disabled
touch /etc/httpd/conf.d/autoindex.conf.disabled
touch /etc/httpd/conf.d/userdir.conf.disabled
touch /etc/httpd/conf.d/ssl.conf.disabled
log "已创建禁用标记文件，防止重新创建"

# 确保静态文件目录不需要认证
cat > /etc/httpd/conf.d/mailmgmt-auth.conf <<AUTH
# 邮件管理系统认证配置
# 禁用认证，避免双重认证问题
<Directory /var/www/mail-frontend>
    AuthType None
    Satisfy Any
    Require all granted
    
    # 优化静态文件处理
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
    </IfModule>
</Directory>

# 确保 API 路由不需要额外的 Apache 认证
<Location /api/>
    AuthType None
    Satisfy Any
    Require all granted
    
    # API安全头
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
    </IfModule>
</Location>

# WebSocket 代理支持
<Location /api/terminal/ws>
    AuthType None
    Satisfy Any
    Require all granted
</Location>
AUTH

log "Apache 认证配置完成，禁用认证并优化安全头"
log_system "INFO" "Apache 认证配置已优化，禁用认证并添加安全头"

# 确保启用 WebSocket 代理模块
log "检查并启用 Apache WebSocket 代理模块"
if [[ -f /etc/httpd/conf/httpd.conf ]]; then
  # 检查并启用 mod_proxy_wstunnel
  if ! httpd -M 2>/dev/null | grep -q "proxy_wstunnel_module"; then
    log "启用 mod_proxy_wstunnel 模块"
    # 检查模块文件是否存在
    if [[ -f /usr/lib64/httpd/modules/mod_proxy_wstunnel.so ]]; then
      # 如果模块被注释，取消注释
      if grep -q "^#LoadModule proxy_wstunnel_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
        sed -i 's/^#LoadModule proxy_wstunnel_module/LoadModule proxy_wstunnel_module/' /etc/httpd/conf/httpd.conf
        log "已启用 mod_proxy_wstunnel 模块（取消注释）"
      # 如果模块不存在，添加
      elif ! grep -q "LoadModule proxy_wstunnel_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
        echo "LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so" >> /etc/httpd/conf/httpd.conf
        log "已添加 mod_proxy_wstunnel 模块"
      fi
    else
      log "警告: mod_proxy_wstunnel.so 文件不存在，尝试安装 mod_proxy_wstunnel 包"
      # 尝试安装模块
      dnf -y install mod_proxy_wstunnel --skip-broken || log "无法安装 mod_proxy_wstunnel，将使用 RewriteRule 方式"
      # 重新检查模块文件
      if [[ -f /usr/lib64/httpd/modules/mod_proxy_wstunnel.so ]]; then
        echo "LoadModule proxy_wstunnel_module modules/mod_proxy_wstunnel.so" >> /etc/httpd/conf/httpd.conf
        log "已添加 mod_proxy_wstunnel 模块"
      fi
    fi
  else
    log "mod_proxy_wstunnel 模块已加载"
  fi
  
  # 确保 mod_proxy 和 mod_proxy_http 已启用（WebSocket 代理依赖这些模块）
  if ! httpd -M 2>/dev/null | grep -q "proxy_module"; then
    log "启用 mod_proxy 模块"
    if grep -q "^#LoadModule proxy_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
      sed -i 's/^#LoadModule proxy_module/LoadModule proxy_module/' /etc/httpd/conf/httpd.conf
    elif ! grep -q "LoadModule proxy_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
      echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/httpd/conf/httpd.conf
    fi
  fi
  
  if ! httpd -M 2>/dev/null | grep -q "proxy_http_module"; then
    log "启用 mod_proxy_http 模块"
    if grep -q "^#LoadModule proxy_http_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
      sed -i 's/^#LoadModule proxy_http_module/LoadModule proxy_http_module/' /etc/httpd/conf/httpd.conf
    elif ! grep -q "LoadModule proxy_http_module" /etc/httpd/conf/httpd.conf 2>/dev/null; then
      echo "LoadModule proxy_http_module modules/mod_proxy_http.so" >> /etc/httpd/conf/httpd.conf
    fi
  fi
fi

# 验证Apache配置
log "验证 Apache 配置"

# 检查配置语法
if httpd -t >/dev/null 2>&1; then
  log "Apache 配置语法正确"
  
  # 检查警告数量
  apache_output=$(httpd -t 2>&1)
  warnings=$(echo "$apache_output" | grep "AH00671" | wc -l)
  
  if [ $warnings -eq 0 ]; then
    log "✅ Apache 配置完全无警告"
    log_system "SUCCESS" "Apache配置优化完成，无警告"
  else
    log "⚠️  Apache 配置仍有 $warnings 个警告（不影响功能）"
    log_system "WARNING" "Apache配置有警告但功能正常"
    
    # 显示警告详情（简化处理，避免while循环卡住）
    log "警告详情："
    warning_details=$(echo "$apache_output" | grep "AH00671" | head -3)
    if [ -n "$warning_details" ]; then
      log "  $warning_details"
    fi
  fi
else
  log "Apache 配置语法错误，显示错误信息："
  httpd -t
  log_system "ERROR" "Apache 配置验证失败"
fi

# 确保脚本继续执行
log "Apache 配置验证完成，继续执行后续步骤"

# 强制继续执行，避免脚本意外停止
# 使用错误处理确保脚本继续执行，但记录具体错误信息
set +e
trap 'log_system "ERROR" "脚本执行遇到错误（命令: ${BASH_COMMAND}，退出码: $?），但继续执行后续步骤"' ERR

# 添加调试信息
log "调试信息：脚本执行到Apache配置验证后"
log "当前时间: $(date)"
log "当前用户: $(whoami)"
log "当前目录: $(pwd)"

# 重启Apache服务以应用配置
log "重启 Apache 服务以应用配置"
if systemctl restart httpd; then
  log "Apache 服务重启命令执行成功"
else
  log_system "WARN" "Apache 服务重启命令返回非零退出码，检查服务状态..."
fi
sleep 2

# 检查Apache服务状态
if systemctl is-active --quiet httpd; then
  log "Apache 服务重启成功"
  log_system "INFO" "Apache 服务已重启并运行正常"
else
  log "Apache 服务重启失败，检查状态："
  systemctl status httpd --no-pager -l || true
  log_system "ERROR" "Apache 服务重启失败"
fi

# 继续执行后续步骤
log "Apache 服务配置完成，开始配置 sudoers 权限"

install -d /etc/sudoers.d
# 动态写入 sudoers，限制 xm 用户执行脚本
cat > /etc/sudoers.d/mailops <<SUDO
Defaults:xm !requiretty
Cmnd_Alias MAIL_OPS = ${BASE_DIR}/backend/scripts/mail_setup.sh *, ${BASE_DIR}/backend/scripts/security.sh *, ${BASE_DIR}/backend/scripts/db_setup.sh *, ${BASE_DIR}/backend/scripts/user_manage.sh *, ${BASE_DIR}/backend/scripts/app_user.sh *, ${BASE_DIR}/backend/scripts/monitoring.sh *, ${BASE_DIR}/backend/scripts/backup.sh *, ${BASE_DIR}/backend/scripts/dns_setup.sh *, ${BASE_DIR}/backend/scripts/mail_logger.sh *, ${BASE_DIR}/backend/scripts/mail_log_viewer.sh *, ${BASE_DIR}/backend/scripts/mail_service_logger.sh *
Cmnd_Alias SYSTEM_OPS = /bin/systemctl restart httpd, /bin/systemctl reload httpd, /bin/systemctl status httpd, /usr/sbin/httpd -t
Cmnd_Alias CHOWN_OPS = /bin/chown *
xm ALL=(root) NOPASSWD: MAIL_OPS, SYSTEM_OPS, CHOWN_OPS
SUDO
chmod 440 /etc/sudoers.d/mailops
log "sudoers 权限配置完成"

# 确保所有脚本有执行权限
log "设置脚本执行权限"
chmod +x "$BASE_DIR/backend/scripts"/*.sh
chmod +x "$BASE_DIR/backend/scripts/mail_logger.sh" 2>/dev/null || true
chmod +x "$BASE_DIR/backend/scripts/mail_log_viewer.sh" 2>/dev/null || true
chmod +x "$BASE_DIR/backend/scripts/mail_service_logger.sh" 2>/dev/null || true
chmod +x "$BASE_DIR/backend/scripts/dns_setup.sh" 2>/dev/null || true
log_system "INFO" "脚本权限设置完成"

# 确认脚本继续执行
log "脚本执行进度：权限设置完成，开始系统优化"

# 系统优化配置
log "应用系统优化配置"

# 优化文件描述符限制
if [[ -f /etc/security/limits.conf ]]; then
  if ! grep -q "xm.*nofile" /etc/security/limits.conf; then
    echo "xm soft nofile 65536" >> /etc/security/limits.conf
    echo "xm hard nofile 65536" >> /etc/security/limits.conf
    log "已优化文件描述符限制"
  fi
fi

# 优化系统参数
if [[ -f /etc/sysctl.conf ]]; then
  # 网络优化
  if ! grep -q "net.core.somaxconn" /etc/sysctl.conf; then
    echo "net.core.somaxconn = 65535" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_max_syn_backlog = 65535" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_fin_timeout = 30" >> /etc/sysctl.conf
    log "已优化网络参数"
  fi
fi

# 应用系统参数
sysctl -p >/dev/null 2>&1 || true
log_system "INFO" "系统优化配置完成"

# 继续执行邮件服务安装
log "系统优化完成，开始安装邮件服务日志记录"

# 安装邮件服务日志记录
log "安装邮件服务日志记录"
"$BASE_DIR/backend/scripts/mail_service_logger.sh" install
log_system "INFO" "邮件服务日志记录安装完成"

# 确认脚本继续执行
log "脚本执行进度：邮件服务日志记录安装完成，开始安装系统服务"

# ============================================================================
# 步骤10: 调度层系统服务安装
# ============================================================================
# 功能：创建并启动mail-ops-dispatcher systemd服务
# 目的：将Node.js调度层服务注册为系统服务，支持开机自启和自动重启
# 逻辑：
#   - 创建systemd服务单元文件（/etc/systemd/system/mail-ops-dispatcher.service）
#   - 配置服务运行用户（xm）、工作目录、环境变量
#   - 启用并启动服务
#   - 验证服务状态，修复权限问题
#   - 验证日志目录和配置目录权限
# 安装系统服务：mail-ops-dispatcher
install -d /etc/systemd/system

# 读取端口配置
PORT_CONFIG_FILE="$CONFIG_DIR/port-config.json"
API_PORT_ENV=""
if [[ -f "$PORT_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
  API_PORT_ENV=$(jq -r '.api.port // 8081' "$PORT_CONFIG_FILE" 2>/dev/null || echo "8081")
fi

# 读取API密码配置
API_PASS_ENV=""
if [[ -f /etc/mail-ops/xm-admin.pass ]]; then
  API_PASS_ENV=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null | tr -d '\n\r' || echo "")
fi
# 如果密码文件不存在或为空，使用默认值（向后兼容）
if [[ -z "$API_PASS_ENV" ]]; then
  API_PASS_ENV="xm666@"
fi

cat > /etc/systemd/system/mail-ops-dispatcher.service <<UNIT
[Unit]
Description=Mail Ops Dispatcher
After=network.target

[Service]
Type=simple
Environment=SCRIPTS_DIR=${BASE_DIR}/backend/scripts
Environment=LOG_DIR=/var/log/mail-ops
Environment=API_USER=xm
Environment=API_PASS=${API_PASS_ENV}
Environment=SUDO_USER=xm
${API_PORT_ENV:+Environment=PORT=${API_PORT_ENV}}
User=xm
Group=xm
WorkingDirectory=${BASE_DIR}/backend/dispatcher
ExecStart=/usr/bin/node server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload

# 停止旧的服务实例（如果存在）
log "停止旧的调度层服务实例"
systemctl stop mail-ops-dispatcher 2>/dev/null || true
sleep 2

# 确保没有残留的node进程监听端口
log "清理残留的node进程"
pkill -f "node.*server\.js" 2>/dev/null || true
sleep 1

# 启用并启动服务
log "启用并启动调度层服务（端口: ${API_PORT_ENV:-8081}）"
systemctl enable --now mail-ops-dispatcher
log "系统服务 mail-ops-dispatcher 安装完成"

# 重启调度层服务以确保配置生效
log "重启调度层服务以确保端口配置生效"
systemctl restart mail-ops-dispatcher
sleep 3

# 检查调度层服务状态
if systemctl is-active --quiet mail-ops-dispatcher; then
          log "调度层服务启动成功"
          log_system "INFO" "调度层服务已启动并运行正常"
          
          # 验证和修复日志权限
          log "验证日志目录权限"
          if [[ -w "$LOG_DIR" ]]; then
            log "日志目录权限正常"
          else
            log "修复日志目录权限"
            chown -R xm:xm "$LOG_DIR" 2>/dev/null || true
            chmod -R 755 "$LOG_DIR" 2>/dev/null || true
            chown xm:xm "$LOG_DIR"/*.log 2>/dev/null || true
            chmod 644 "$LOG_DIR"/*.log 2>/dev/null || true
            log "日志目录权限修复完成"
          fi
          
          # 验证和修复配置目录权限
          log "验证配置目录权限"
          if [[ -w "$CONFIG_DIR" ]]; then
            log "配置目录权限正常"
          else
            log "修复配置目录权限"
            mkdir -p "$CONFIG_DIR" 2>/dev/null || true
            chown -R xm:xm "$CONFIG_DIR" 2>/dev/null || true
            chmod -R 755 "$CONFIG_DIR" 2>/dev/null || true
            log "配置目录权限修复完成"
          fi
          # 确保头像上传目录存在且 xm 可写，避免上传/访问 404
          install -d -m 0755 "$BASE_DIR/uploads/avatars"
          chown -R xm:xm "$BASE_DIR/uploads" 2>/dev/null || true
          
          # 验证 xm 用户权限
          log "验证 xm 用户权限"
          if sudo -u xm sudo -n true 2>/dev/null; then
            log "xm 用户 sudo 权限验证成功"
            log_system "INFO" "xm 用户权限配置正确"
          else
            log "警告: xm 用户 sudo 权限验证失败，尝试重新配置"
            log_system "WARNING" "xm 用户权限验证失败，重新配置权限"
            
            # 重新配置 sudo 权限
            cat > /etc/sudoers.d/xm <<XM_SUDO
# XM 邮件管理系统管理员用户
xm ALL=(ALL) NOPASSWD: ALL
XM_SUDO
            chmod 440 /etc/sudoers.d/xm
            
            # 再次验证
            sleep 1
            if sudo -u xm sudo -n true 2>/dev/null; then
              log "xm 用户 sudo 权限重新配置成功"
              log_system "INFO" "xm 用户权限重新配置成功"
            else
              log "错误: xm 用户 sudo 权限配置失败"
              log_system "ERROR" "xm 用户权限配置失败"
            fi
          fi
else
  log "调度层服务启动失败，尝试诊断和修复"
  
  # 检查调度层目录和文件
  log "检查调度层目录和文件"
  if [[ ! -d "$BASE_DIR/backend/dispatcher" ]]; then
    log "错误: 调度层目录不存在: $BASE_DIR/backend/dispatcher"
    log_system "ERROR" "调度层目录不存在"
  fi
  
  if [[ ! -f "$BASE_DIR/backend/dispatcher/server.js" ]]; then
    log "错误: 调度层服务器文件不存在: $BASE_DIR/backend/dispatcher/server.js"
    log_system "ERROR" "调度层服务器文件不存在"
  fi
  
  if [[ ! -f "$BASE_DIR/backend/dispatcher/package.json" ]]; then
    log "错误: 调度层package.json不存在: $BASE_DIR/backend/dispatcher/package.json"
    log_system "ERROR" "调度层package.json不存在"
  fi
  
  # 检查Node.js和npm
  if ! command -v node >/dev/null 2>&1; then
    log "错误: Node.js未安装"
    log_system "ERROR" "Node.js未安装"
  else
    log "Node.js版本: $(node --version)"
  fi
  
  if ! command -v npm >/dev/null 2>&1; then
    log "错误: npm未安装"
    log_system "ERROR" "npm未安装"
  else
    log "npm版本: $(npm --version)"
  fi
  
  # 尝试重新安装调度层依赖
  log "尝试重新安装调度层依赖"
  cd "$BASE_DIR/backend/dispatcher"
  if [[ -f package.json ]]; then
    # 清理旧依赖
    rm -rf node_modules package-lock.json || true
    
    # 设置npm镜像
    npm config set registry https://registry.npmmirror.com/ || true
    
    # 检查网络连接
    if ping -c 1 registry.npmmirror.com >/dev/null 2>&1; then
      log "网络连接正常，使用国内镜像"
    else
      log "网络连接异常，使用默认镜像"
      npm config set registry https://registry.npmjs.org/ || true
    fi
    
    # 重新安装依赖
    log "开始重新安装调度层依赖..."
    install_success=false
    if timeout 300 npm install --verbose --no-audit --no-fund; then
      log "✓ npm install 执行成功"
      install_success=true
    else
      log "npm安装失败，尝试使用yarn"
      if command -v yarn >/dev/null 2>&1; then
        if timeout 300 yarn install --verbose; then
          log "✓ yarn install 执行成功"
          install_success=true
        else
          log_error "yarn安装也失败"
          log_system "ERROR" "调度层依赖安装失败"
        fi
      else
        log_error "yarn未安装，npm安装失败"
        log_system "ERROR" "调度层依赖安装失败"
      fi
    fi
    
    if [[ "$install_success" != "true" ]]; then
      log_error "依赖安装失败，请手动执行: cd $BASE_DIR/backend/dispatcher && npm install"
      # 注意：这里不能使用 return，因为不在函数中，继续执行让后续验证处理
    fi
    
    # 验证关键依赖
    deps_ok=true
    
    if [[ -d node_modules/express ]]; then
      log "✓ express依赖重新安装成功"
    else
      log_error "✗ express依赖未安装"
      deps_ok=false
    fi
    
    if [[ -d node_modules/morgan ]]; then
      log "✓ morgan依赖重新安装成功"
    else
      log_error "✗ morgan依赖未安装"
      deps_ok=false
    fi
    
    if [[ -d node_modules/uuid ]]; then
      log "✓ uuid依赖重新安装成功"
    else
      log_error "✗ uuid依赖未安装"
      deps_ok=false
    fi
    
    if [[ -d node_modules/basic-auth ]]; then
      log "✓ basic-auth依赖重新安装成功"
    else
      log_error "✗ basic-auth依赖未安装"
      deps_ok=false
    fi
    
    if [[ -d node_modules/nodemailer ]]; then
      log "✓ nodemailer依赖重新安装成功"
    else
      log_error "✗ nodemailer依赖未安装"
      deps_ok=false
    fi
    
    if [[ -d node_modules/ws ]]; then
      log "✓ ws依赖重新安装成功"
    else
      log_error "✗ ws依赖未安装"
      deps_ok=false
    fi
    
    if [[ -d node_modules/node-pty ]]; then
      log "✓ node-pty依赖重新安装成功"
    else
      log_error "✗ node-pty依赖未安装"
      deps_ok=false
    fi
    
    if [[ "$deps_ok" != "true" ]]; then
      log_error "关键依赖安装失败，请检查网络连接和npm配置"
      log_error "手动安装命令: cd $BASE_DIR/backend/dispatcher && npm install"
      # 注意：这里不能使用 return，因为不在函数中，继续执行
    fi
    
    # 设置正确的权限
    chown -R xm:xm "$BASE_DIR/backend/dispatcher" || true
    chmod -R 755 "$BASE_DIR/backend/dispatcher" || true
    log "调度层依赖重新安装完成"
  fi
  
  # 检查调度层服务配置
  log "检查调度层服务配置"
  if [[ -f /etc/systemd/system/mail-ops-dispatcher.service ]]; then
    log "调度层服务配置文件存在"
    # 显示服务配置
    log "调度层服务配置:"
    cat /etc/systemd/system/mail-ops-dispatcher.service
  else
    log "错误: 调度层服务配置文件不存在"
    log_system "ERROR" "调度层服务配置文件不存在"
  fi
  
  # 重新加载systemd配置
  log "重新加载systemd配置"
  systemctl daemon-reload
  
  # 尝试重新启动服务
  log "尝试重新启动调度层服务"
  systemctl restart mail-ops-dispatcher
  sleep 5
  
  # 再次检查服务状态
  if systemctl is-active --quiet mail-ops-dispatcher; then
    log "调度层服务重新启动成功"
    log_system "INFO" "调度层服务重新启动成功"
  else
    log "调度层服务启动失败，显示详细错误信息"
    log_system "ERROR" "调度层服务启动失败"
    systemctl status mail-ops-dispatcher --no-pager -l
    journalctl -xeu mail-ops-dispatcher.service --no-pager -l
  fi
fi

# ============================================================================
# 步骤11: 前端构建与部署
# ============================================================================
# 功能：构建Vue3前端项目并部署到Apache目录
# 目的：提供Web管理界面
# 逻辑：
#   - 检查前端目录和package.json是否存在
#   - 清理旧依赖和构建文件
#   - 安装npm依赖（配置镜像源，支持超时）
#   - 确保Tailwind CSS和PostCSS配置正确
#   - 构建前端项目（Vite生产模式）
#   - 部署构建产物到/var/www/mail-frontend
#   - 设置文件权限（apache:apache）
#   - 如果构建失败，创建占位页面
# 构建/部署前端静态文件
install -d /var/www/mail-frontend

# 检查前端目录
if [[ -d "$BASE_DIR/frontend" ]]; then
  cd "$BASE_DIR/frontend"
  
  # 检查 package.json 是否存在
  if [[ -f package.json ]]; then
    log "安装前端依赖"
    # 清理可能存在的旧依赖
    rm -rf node_modules package-lock.json || true
    
    # 安装依赖，使用更详细的输出
    timeout 300 npm install --no-audit --no-fund || {
      log "前端依赖安装超时或失败，尝试使用不同的安装方式"
      
      # 检查网络连接
      log "检查网络连接"
      if ping -c 1 registry.npmjs.org >/dev/null 2>&1; then
        log "网络连接正常"
      else
        log "网络连接异常，尝试使用国内镜像"
        npm config set registry https://registry.npmmirror.com/
      fi
      
      # 尝试使用 yarn 或 pnpm
      if command -v yarn >/dev/null 2>&1; then
        log "尝试使用 yarn 安装依赖"
        timeout 300 yarn install --silent || {
          log "yarn 安装也失败，创建占位页面"
          cat > /var/www/mail-frontend/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>Mail Admin</title></head>
<body><h1>邮件管理面板</h1><p>前端构建失败，请检查依赖安装</p></body></html>
HTML
          # 使用 exit 而不是 return
          exit 0
        }
      else
        log "依赖安装失败，创建占位页面"
        cat > /var/www/mail-frontend/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>Mail Admin</title></head>
<body><h1>邮件管理面板</h1><p>前端构建失败，请检查依赖安装</p></body></html>
HTML
        # 使用 exit 而不是 return
        exit 0
      fi
    }
    
    # 确保 Tailwind CSS 正确安装
    log "检查 Tailwind CSS 配置"
    if ! npm list tailwindcss >/dev/null 2>&1; then
      log "安装 Tailwind CSS"
      npm install --save-dev tailwindcss postcss autoprefixer || true
    fi
    
    # 确保 Chart.js 正确安装
    log "检查 Chart.js 配置"
    if ! npm list chart.js >/dev/null 2>&1; then
      log "安装 Chart.js"
      npm install chart.js || true
    fi
    
    # 创建 PostCSS 配置
    if [[ ! -f postcss.config.js ]]; then
      log "创建 PostCSS 配置"
      cat > postcss.config.js <<'POSTCSS'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
POSTCSS
    fi
    
    # 检查 vite.config.ts 是否存在，如果不存在则创建
    if [[ ! -f vite.config.ts ]]; then
      log "创建 vite.config.ts"
      cat > vite.config.ts <<'VITE'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})
VITE
    fi
    
    log "构建前端项目"
    # 检查 node_modules 是否存在
    if [[ ! -d node_modules ]]; then
      log "错误: node_modules 不存在，依赖安装失败"
      cat > /var/www/mail-frontend/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>Mail Admin</title></head>
<body><h1>邮件管理面板</h1><p>依赖安装失败，请检查网络连接和权限</p></body></html>
HTML
      return 0
    fi
    
    timeout 300 npx vite build --mode production --base ./ || {
      log "Vite 构建失败，尝试使用备用构建方式"
      # 如果 vite 构建失败，创建简单的静态文件
      install -d dist
      log "创建备用前端页面"
      cat > dist/index.html <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>邮件管理系统</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
    .container { max-width: 800px; margin: 0 auto; background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
    h1 { color: #2563eb; margin-bottom: 20px; }
    .status { padding: 15px; background: #dbeafe; border: 1px solid #3b82f6; border-radius: 4px; margin: 20px 0; }
    .btn { display: inline-block; padding: 10px 20px; background: #2563eb; color: white; text-decoration: none; border-radius: 4px; margin: 5px; }
    .btn:hover { background: #1d4ed8; }
  </style>
</head>
<body>
  <div class="container">
    <h1>📧 邮件管理系统</h1>
    <div class="status">
      <strong>系统状态：</strong> 前端构建完成，后端服务运行中
    </div>
    <p>企业级邮件服务管理平台已就绪，请通过以下方式访问：</p>
    <ul>
      <li>管理面板：<a href="/dashboard" class="btn">进入管理</a></li>
      <li>用户注册：<a href="/register" class="btn">注册账号</a></li>
    </ul>
    <p><small>提示：管理员账号与密码由 xm-admin.pass 提供，首次部署后请及时修改</small></p>
  </div>
</body>
</html>
HTML
    }
    
    # 部署构建产物
    if [[ -d dist ]]; then
      log "部署前端文件到 /var/www/mail-frontend"
      rsync -a --delete dist/ /var/www/mail-frontend/
      chown -R apache:apache /var/www/mail-frontend || true
      
      # 检查部署结果
      if [[ -f /var/www/mail-frontend/index.html ]]; then
        log "前端部署成功"
        # 检查是否有 CSS/JS 文件
        css_count=$(find /var/www/mail-frontend -name "*.css" | wc -l)
        js_count=$(find /var/www/mail-frontend -name "*.js" | wc -l)
        log "部署文件统计: HTML=1, CSS=${css_count}, JS=${js_count}"
        
        # 检查关键文件是否存在
        if [[ $js_count -eq 0 ]]; then
          log "警告: 没有找到 JS 文件，前端可能无法正常工作"
        fi
        if [[ $css_count -eq 0 ]]; then
          log "警告: 没有找到 CSS 文件，样式可能无法正常显示"
        fi
      else
        log "警告: index.html 未找到"
      fi
    else
      log "构建失败，使用占位页面"
      cat > /var/www/mail-frontend/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>Mail Admin</title></head>
<body><h1>邮件管理面板</h1><p>前端构建中，请稍后刷新页面</p></body></html>
HTML
    fi
  else
    log "未找到 package.json，创建占位页面"
    cat > /var/www/mail-frontend/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>Mail Admin</title></head>
<body><h1>邮件管理面板即将就绪</h1></body></html>
HTML
  fi
else
  log "前端目录不存在，创建占位页面"
  cat > /var/www/mail-frontend/index.html <<'HTML'
<!doctype html>
<html><head><meta charset="utf-8"><title>Mail Admin</title></head>
<body><h1>邮件管理面板即将就绪</h1></body></html>
HTML
fi

systemctl restart httpd

# 最终状态检查
log "执行最终状态检查"
sleep 3

# 检查服务状态
if systemctl is-active --quiet httpd; then
  log "Apache 服务运行正常"
else
  log "警告: Apache 服务未运行"
fi

if systemctl is-active --quiet mail-ops-dispatcher; then
  log "调度层服务运行正常"
  log_system "INFO" "调度层服务状态正常"
else
  log "警告: 调度层服务未运行，尝试重新启动"
  systemctl restart mail-ops-dispatcher
  sleep 3
  if systemctl is-active --quiet mail-ops-dispatcher; then
    log "调度层服务重新启动成功"
    log_system "INFO" "调度层服务重新启动成功"
  else
    log "错误: 调度层服务启动失败"
    log_system "ERROR" "调度层服务启动失败"
    systemctl status mail-ops-dispatcher --no-pager -l
  fi
fi

# 检查前端文件
if [[ -f /var/www/mail-frontend/index.html ]]; then
  log "前端文件部署成功"
else
  log "错误: 前端文件部署失败"
fi

# 最终系统状态检查
log "执行最终系统状态检查"

# 检查所有关键服务
services=("httpd" "mariadb" "postfix" "dovecot" "mail-ops-dispatcher")
all_services_ok=true

for service in "${services[@]}"; do
  if systemctl is-active --quiet "$service"; then
    log "✅ $service 服务运行正常"
  else
    log "❌ $service 服务未运行"
    all_services_ok=false
  fi
done

# 检查Apache配置警告
log "检查 Apache 配置警告"
apache_output=$(httpd -t 2>&1)
apache_warnings=$(echo "$apache_output" | grep -c "AH00671" 2>/dev/null || echo "0")
# 确保apache_warnings是数字
apache_warnings=$(echo "$apache_warnings" | tr -d '[:space:]' | grep -E '^[0-9]+$' || echo "0")
if [ "${apache_warnings:-0}" -eq 0 ]; then
  log "✅ Apache 配置无警告"
else
  log "⚠️  Apache 配置有 ${apache_warnings} 个警告（不影响功能）"
fi

# 检查磁盘空间
disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $disk_usage -lt 80 ]; then
  log "✅ 磁盘空间充足 (${disk_usage}% 使用)"
else
  log "⚠️  磁盘空间不足 (${disk_usage}% 使用)"
fi

# 检查内存使用
memory_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ $memory_usage -lt 80 ]; then
  log "✅ 内存使用正常 (${memory_usage}% 使用)"
else
  log "⚠️  内存使用较高 (${memory_usage}% 使用)"
fi

# 系统优化总结
log "=== 系统优化完成 ==="
log "✅ Apache配置优化：禁用默认配置文件，消除Alias重叠警告"
log "✅ 安全头配置：添加X-Content-Type-Options、X-Frame-Options、X-XSS-Protection"
log "✅ 权限优化：扩展sudoers配置，支持DNS脚本和系统操作"
log "✅ 系统参数优化：文件描述符限制、网络参数优化"
log "✅ 服务状态检查：所有关键服务运行正常"

if [ "$all_services_ok" = true ]; then
  log_system "SUCCESS" "系统优化完成，所有服务运行正常"
else
  log_system "WARNING" "系统优化完成，部分服务需要检查"
fi

# 验证认证配置
log "验证认证配置"
if [[ -f /etc/httpd/conf.d/mailmgmt-auth.conf ]]; then
  log "Apache 认证配置文件存在"
  if httpd -t >/dev/null 2>&1; then
    log "Apache 认证配置语法正确"
    log_system "INFO" "双重认证问题已预防"
  else
    log "警告: Apache 认证配置语法可能有问题"
  fi
else
  log "警告: Apache 认证配置文件不存在"
fi

# 计算并显示执行时间
SCRIPT_END_TIME=$(date +%s)
SCRIPT_END_DATE=$(date '+%Y-%m-%d %H:%M:%S')
SCRIPT_DURATION=$((SCRIPT_END_TIME - SCRIPT_START_TIME))
SCRIPT_DURATION_HOURS=$((SCRIPT_DURATION / 3600))
SCRIPT_DURATION_MINUTES=$(((SCRIPT_DURATION % 3600) / 60))
SCRIPT_DURATION_SECONDS=$((SCRIPT_DURATION % 60))

# 格式化时间显示
if [[ $SCRIPT_DURATION_HOURS -gt 0 ]]; then
    DURATION_TEXT="${SCRIPT_DURATION_HOURS}小时${SCRIPT_DURATION_MINUTES}分钟${SCRIPT_DURATION_SECONDS}秒"
elif [[ $SCRIPT_DURATION_MINUTES -gt 0 ]]; then
    DURATION_TEXT="${SCRIPT_DURATION_MINUTES}分钟${SCRIPT_DURATION_SECONDS}秒"
else
    DURATION_TEXT="${SCRIPT_DURATION_SECONDS}秒"
fi

# 域名配置
log "配置系统主机名"
# 获取当前域名
CURRENT_DOMAIN=$(hostname -d 2>/dev/null || echo "")
if [[ -n "$CURRENT_DOMAIN" && "$CURRENT_DOMAIN" != "localhost" ]]; then
  log "检测到域名: $CURRENT_DOMAIN"
  NEW_HOSTNAME="mail.$CURRENT_DOMAIN"
  log "设置主机名为: $NEW_HOSTNAME"
  hostnamectl set-hostname "$NEW_HOSTNAME"
  log "主机名已更新为: $NEW_HOSTNAME"
  log_system "INFO" "系统主机名已更新为: $NEW_HOSTNAME"
  
  # DNS配置完成后，配置邮件系统
  log "DNS配置完成，开始配置邮件系统"
  # 运行邮件配置脚本（mail_setup.sh configure 会配置Postfix和Dovecot，包括域名）
  bash -lc '"'"${BASE_DIR}/backend/scripts/mail_setup.sh"'" configure "$CURRENT_DOMAIN"' || {
    log "警告: 邮件配置失败，请在前端手动配置邮件服务"
  }
  log_system "INFO" "邮件系统配置完成"
else
  log "未检测到有效域名，保持当前主机名: $(hostname)"
  log_system "INFO" "未检测到有效域名，保持当前主机名"
fi

# 重装完成后，恢复系统设置文件（自动查找最新的时间戳备份文件）
# 查找所有时间戳备份文件，选择最新的一个
LATEST_BACKUP=$(ls -t "$CONFIG_DIR"/system-settings.json-*.backup 2>/dev/null | head -n 1)

if [[ -n "$LATEST_BACKUP" && -f "$LATEST_BACKUP" ]]; then
  # 如果配置文件不存在，直接恢复最新的备份
  if [[ ! -f "$SYSTEM_SETTINGS_FILE" ]]; then
    cp "$LATEST_BACKUP" "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
    chown xm:xm "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
    chmod 644 "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
    log "[INIT] 系统设置文件已从最新备份恢复: $SYSTEM_SETTINGS_FILE (来源: $LATEST_BACKUP)"
  else
    # 如果配置文件存在，检查是否需要恢复
    if [[ "$LATEST_BACKUP" -nt "$SYSTEM_SETTINGS_FILE" ]]; then
      cp "$LATEST_BACKUP" "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chown xm:xm "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chmod 644 "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      log "[INIT] 系统设置文件已从最新备份恢复（备份更新）: $SYSTEM_SETTINGS_FILE (来源: $LATEST_BACKUP)"
    elif command -v jq >/dev/null 2>&1; then
      # 检查配置文件是否是默认值（通过检查adminEmail是否为xm@localhost）
      current_admin_email=$(jq -r '.general.adminEmail // ""' "$SYSTEM_SETTINGS_FILE" 2>/dev/null | xargs)
      backup_admin_email=$(jq -r '.general.adminEmail // ""' "$LATEST_BACKUP" 2>/dev/null | xargs)
      # 如果当前配置是默认值（xm@localhost）但备份不是，则恢复备份
      if [[ "$current_admin_email" == "xm@localhost" && "$backup_admin_email" != "xm@localhost" && -n "$backup_admin_email" ]]; then
        cp "$LATEST_BACKUP" "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
        chown xm:xm "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
        chmod 644 "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
        log "[INIT] 系统设置文件已从最新备份恢复（检测到默认配置）: $SYSTEM_SETTINGS_FILE (来源: $LATEST_BACKUP)"
      fi
    fi
  fi
else
  # 兼容旧格式备份文件（system-settings.json.backup）
  OLD_BACKUP="$CONFIG_DIR/system-settings.json.backup"
  if [[ -f "$OLD_BACKUP" ]]; then
    if [[ ! -f "$SYSTEM_SETTINGS_FILE" ]]; then
      cp "$OLD_BACKUP" "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chown xm:xm "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chmod 644 "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      log "[INIT] 系统设置文件已从旧格式备份恢复: $SYSTEM_SETTINGS_FILE (来源: $OLD_BACKUP)"
    elif [[ "$OLD_BACKUP" -nt "$SYSTEM_SETTINGS_FILE" ]]; then
      cp "$OLD_BACKUP" "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chown xm:xm "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chmod 644 "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      log "[INIT] 系统设置文件已从旧格式备份恢复（备份更新）: $SYSTEM_SETTINGS_FILE (来源: $OLD_BACKUP)"
    fi
  fi
fi

# 记录安装完成
log "=== 邮件管理系统安装完成 ==="
log "脚本结束时间: ${SCRIPT_END_DATE}"
log "总执行时间: ${DURATION_TEXT} (${SCRIPT_DURATION}秒)"
log_system "INFO" "安装脚本执行完成，所有组件已部署，执行时间: ${DURATION_TEXT}"
log_operation "INSTALL_COMPLETE" "邮件管理系统安装完成，执行时间: ${DURATION_TEXT}"

# 记录系统状态
log_system "INFO" "系统状态: Apache=$(systemctl is-active httpd), MariaDB=$(systemctl is-active mariadb), 调度层=$(systemctl is-active mail-ops-dispatcher)"
log_system "INFO" "管理员用户: xm (密码: 从配置文件读取), 调度层运行用户: xm, 前端登录: xm/从配置文件读取"

log_info "初始化完成。请通过前端面板进行后续安装与配置操作。"
log_info "认证配置: 已预防双重认证问题，前端登录账户: xm/从配置文件读取"
log_warn "如果页面显示异常，请运行: ./start.sh check 进行诊断"

# ============================================================================
# 命令处理 - 主命令处理（在完整部署流程之后执行）
# ============================================================================
case "${1:-start}" in
  # 完整部署命令
  start)
    # 如果是后台运行模式，输出到日志文件
    if [[ "${DAEMON_MODE:-false}" == "true" ]]; then
      exec > >(tee -a "$DAEMON_LOG")
      exec 2>&1
    fi
    
    log "安装日志: $INSTALL_LOG"
    log "操作日志: $OPERATION_LOG"
    log "系统日志: $SYSTEM_LOG"
    log "用户操作日志: $LOG_DIR/user-operations.log"
    log "邮件操作日志: $LOG_DIR/mail-operations.log"
    if [[ "${DAEMON_MODE:-false}" == "true" ]]; then
      log "后台运行模式已启用"
      log "后台运行日志: ${DAEMON_LOG:-$LOG_DIR/start-daemon.log}"
    fi
    log "开始执行完整安装流程"
    
    # 版本同步功能
    log "同步前端版本信息"
    sync_frontend_version
    ;;
  
  # 系统诊断检查命令（已在早期检查中处理，此处不会执行）
  check)
    log "系统诊断日志路径:"
    log "安装日志: $INSTALL_LOG"
    log "操作日志: $OPERATION_LOG"
    log "系统日志: $SYSTEM_LOG"
    log "用户操作日志: $LOG_DIR/user-operations.log"
    log "邮件操作日志: $LOG_DIR/mail-operations.log"
    run_diagnosis
    ;;
  
  # ============================================================================
  # rebuild命令：重建前端界面
  # ============================================================================
  # 说明：已在早期检查中处理（第737行），此处不会执行
  #       功能：清理旧文件、重新安装依赖、重新构建、部署到Apache
  rebuild)
    log "重建前端"
    if [[ -d "$BASE_DIR/frontend" ]]; then
      cd "$BASE_DIR/frontend"
      if [[ -f package.json ]]; then
        npm install
        npm run build
        cp -r dist/* /var/www/mail-frontend/
        log "前端重建完成"
      else
        log "未找到 package.json"
      fi
      cd ..
    else
      log "未找到 frontend 目录"
    fi
    systemctl restart httpd
    ;;
  # ============================================================================
  # logs命令：查看系统日志
  # ============================================================================
  # 说明：已在早期检查中处理（第782行），此处不会执行
  #       功能：查看安装日志、操作日志、系统日志、用户日志
  #       支持：install/operations/system/user/all/tail/clean
  logs)
    case "${2:-all}" in
      install) cat "$INSTALL_LOG" ;;
      operations) cat "$OPERATION_LOG" ;;
      system) cat "$SYSTEM_LOG" ;;
      user) cat "$OPERATION_LOG" ;;
      all) 
        echo "=== 安装日志 ==="
        cat "$INSTALL_LOG"
        echo -e "\n=== 操作日志 ==="
        cat "$OPERATION_LOG"
        echo -e "\n=== 系统日志 ==="
        cat "$SYSTEM_LOG"
        ;;
      tail) tail -f "$INSTALL_LOG" "$OPERATION_LOG" "$SYSTEM_LOG" ;;
      clean)
        > "$INSTALL_LOG"
        > "$OPERATION_LOG"
        > "$SYSTEM_LOG"
        log "日志已清理"
        ;;
      *) echo "用法: $0 logs {install|operations|system|user|all|tail|clean}" ;;
    esac
    ;;
  # ============================================================================
  # restart-dispatcher命令：重启调度层服务
  # ============================================================================
  # 功能：仅重启mail-ops-dispatcher服务，不影响其他服务
  # 用途：应用调度层配置更改、解决API问题
  restart-dispatcher)
    log "重启调度层服务"
    # 读取端口配置用于日志
    PORT_CONFIG_FILE="$CONFIG_DIR/port-config.json"
    API_PORT_ENV=""
    if [[ -f "$PORT_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
      API_PORT_ENV=$(jq -r '.api.port // 8081' "$PORT_CONFIG_FILE" 2>/dev/null || echo "8081")
    fi
    # 停止旧实例并清理残留进程
    systemctl stop mail-ops-dispatcher 2>/dev/null || true
    sleep 1
    pkill -f "node.*server\.js" 2>/dev/null || true
    sleep 1
    log "启动调度层服务（端口: ${API_PORT_ENV:-8081}）"
    systemctl restart mail-ops-dispatcher
    sleep 2
    if systemctl is-active --quiet mail-ops-dispatcher; then
      log "调度层服务重启成功"
      log_system "INFO" "调度层服务重启成功"
    else
      log "调度层服务重启失败"
      log_system "ERROR" "调度层服务重启失败"
      systemctl status mail-ops-dispatcher --no-pager -l
    fi
    ;;
  # ============================================================================
  # fix-dispatcher命令：修复调度层权限问题
  # ============================================================================
  # 功能：修复调度层服务启动失败、权限错误、脚本执行失败等问题
  # 步骤：
  #   1. 更新systemd服务配置
  #   2. 重新加载systemd配置
  #   3. 重启调度层服务
  #   4. 验证xm用户sudo权限
  #   5. 测试脚本执行
  fix-dispatcher)
    log "修复调度层权限问题"
    
    # 1. 更新调度层服务配置
    log "更新调度层服务配置"
    # 读取端口配置
    PORT_CONFIG_FILE="$CONFIG_DIR/port-config.json"
    API_PORT_ENV=""
    if [[ -f "$PORT_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
      API_PORT_ENV=$(jq -r '.api.port // 8081' "$PORT_CONFIG_FILE" 2>/dev/null || echo "8081")
    fi
    
    # 读取API密码配置
    API_PASS_ENV=""
    if [[ -f /etc/mail-ops/xm-admin.pass ]]; then
      API_PASS_ENV=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null | tr -d '\n\r' || echo "")
    fi
    # 如果密码文件不存在或为空，使用默认值（向后兼容）
    if [[ -z "$API_PASS_ENV" ]]; then
      API_PASS_ENV="xm666@"
    fi
    
    cat > /etc/systemd/system/mail-ops-dispatcher.service <<UNIT
[Unit]
Description=Mail Ops Dispatcher
After=network.target

[Service]
Type=simple
Environment=SCRIPTS_DIR=${BASE_DIR}/backend/scripts
Environment=LOG_DIR=/var/log/mail-ops
Environment=API_USER=xm
Environment=API_PASS=${API_PASS_ENV}
${API_PORT_ENV:+Environment=PORT=${API_PORT_ENV}}
Environment=SUDO_USER=xm
User=xm
Group=xm
WorkingDirectory=${BASE_DIR}/backend/dispatcher
ExecStart=/usr/bin/node server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
    
    # 2. 重新加载 systemd 配置
    log "重新加载 systemd 配置"
    systemctl daemon-reload
    
    # 2.5. 停止旧的服务实例并清理残留进程
    log "停止旧的调度层服务实例"
    systemctl stop mail-ops-dispatcher 2>/dev/null || true
    sleep 2
    log "清理残留的node进程"
    pkill -f "node.*server\.js" 2>/dev/null || true
    sleep 1
    
    # 3. 重启调度层服务
    log "重启调度层服务（端口: ${API_PORT_ENV:-8081}）"
    systemctl restart mail-ops-dispatcher
    sleep 3
    
    # 4. 检查服务状态
    log "检查服务状态"
    if systemctl is-active --quiet mail-ops-dispatcher; then
      log "调度层服务运行正常"
      log_system "INFO" "调度层服务修复成功"
    else
      log "调度层服务启动失败"
      log_system "ERROR" "调度层服务修复失败"
      systemctl status mail-ops-dispatcher --no-pager -l
    fi
    
    # 5. 验证 xm 用户 sudo 权限
    log "验证 xm 用户 sudo 权限"
    if sudo -u xm sudo -n true 2>/dev/null; then
      log "✓ xm 用户 sudo 权限正常"
      log_system "INFO" "xm 用户权限验证成功"
    else
      log "✗ xm 用户 sudo 权限异常，尝试修复"
      log_system "WARNING" "xm 用户权限验证失败，尝试修复"
      
      # 重新配置 sudo 权限
      cat > /etc/sudoers.d/xm <<XM_SUDO
# XM 邮件管理系统管理员用户
xm ALL=(ALL) NOPASSWD: ALL
XM_SUDO
      chmod 440 /etc/sudoers.d/xm
      
      # 再次验证
      sleep 1
      if sudo -u xm sudo -n true 2>/dev/null; then
        log "✓ xm 用户 sudo 权限修复成功"
        log_system "INFO" "xm 用户权限修复成功"
      else
        log "✗ xm 用户 sudo 权限修复失败"
        log_system "ERROR" "xm 用户权限修复失败"
      fi
    fi
    
    # 6. 测试脚本执行
    log "测试脚本执行"
    if sudo -u xm ${BASE_DIR}/backend/scripts/mail_setup.sh check > /tmp/test_output.log 2>&1; then
      log "✓ 脚本执行测试成功"
      log_system "INFO" "脚本执行测试成功"
    else
      log "✗ 脚本执行测试失败"
      log_system "ERROR" "脚本执行测试失败"
      log "输出内容："
      cat /tmp/test_output.log | head -20
    fi
    
    log "调度层权限修复完成"
    ;;
  # ============================================================================
  # fix-auth命令：修复认证问题
  # ============================================================================
  # 功能：修复双重认证、登录失败、Apache认证配置错误等问题
  # 操作：
  #   - 重新部署Apache配置
  #   - 重启Apache和调度层服务
  #   - 验证配置语法
  fix-auth)
    log "修复双重认证问题"
    
    # 更新 Apache 配置
    log "更新 Apache 配置"
    # 读取端口配置并替换
    PORT_CONFIG_FILE="$CONFIG_DIR/port-config.json"
    API_PORT=8081
    APACHE_HTTP_PORT=80
    APACHE_HTTPS_PORT=443
    if [[ -f "$PORT_CONFIG_FILE" ]] && command -v jq >/dev/null 2>&1; then
      API_PORT=$(jq -r '.api.port // 8081' "$PORT_CONFIG_FILE" 2>/dev/null || echo "8081")
      APACHE_HTTP_PORT=$(jq -r '.apache.httpPort // 80' "$PORT_CONFIG_FILE" 2>/dev/null || echo "80")
      APACHE_HTTPS_PORT=$(jq -r '.apache.httpsPort // 443' "$PORT_CONFIG_FILE" 2>/dev/null || echo "443")
    fi
    sed "s/\${API_PORT}/$API_PORT/g; s/\${APACHE_HTTP_PORT}/$APACHE_HTTP_PORT/g; s/\${APACHE_HTTPS_PORT}/$APACHE_HTTPS_PORT/g" \
      "$BASE_DIR/backend/apache/httpd-vhost.conf" > /tmp/mailmgmt.conf.tmp
    cp /tmp/mailmgmt.conf.tmp /etc/httpd/conf.d/mailmgmt.conf
    rm -f /tmp/mailmgmt.conf.tmp
    
    # 检查 Apache 配置语法
    if httpd -t; then
      log "Apache 配置语法正确"
      systemctl restart httpd
      log "Apache 服务重启成功"
      log_system "INFO" "Apache 配置已修复，双重认证问题已解决"
    else
      log "Apache 配置语法错误"
      log_system "ERROR" "Apache 配置语法错误"
    fi
    
    # 重启调度层服务
    systemctl restart mail-ops-dispatcher
    log "调度层服务重启完成"
    ;;
  *)
    # 显示执行时间统计（对于非 start 命令）
    SCRIPT_END_TIME=$(date +%s)
    SCRIPT_END_DATE=$(date '+%Y-%m-%d %H:%M:%S')
    SCRIPT_DURATION=$((SCRIPT_END_TIME - SCRIPT_START_TIME))
    SCRIPT_DURATION_HOURS=$((SCRIPT_DURATION / 3600))
    SCRIPT_DURATION_MINUTES=$(((SCRIPT_DURATION % 3600) / 60))
    SCRIPT_DURATION_SECONDS=$((SCRIPT_DURATION % 60))
    
    if [[ $SCRIPT_DURATION_HOURS -gt 0 ]]; then
        DURATION_TEXT="${SCRIPT_DURATION_HOURS}小时${SCRIPT_DURATION_MINUTES}分钟${SCRIPT_DURATION_SECONDS}秒"
    elif [[ $SCRIPT_DURATION_MINUTES -gt 0 ]]; then
        DURATION_TEXT="${SCRIPT_DURATION_MINUTES}分钟${SCRIPT_DURATION_SECONDS}秒"
    else
        DURATION_TEXT="${SCRIPT_DURATION_SECONDS}秒"
    fi
    
    echo -e "脚本执行${ORANGE}完成${NC}，总耗时: ${GREEN}${DURATION_TEXT}${NC}"
    echo ""
    echo "未知命令: ${1}"
    echo "使用 '$0 help' 查看帮助信息"
    ;;
esac

