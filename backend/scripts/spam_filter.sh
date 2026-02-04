#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: spam_filter.sh
# 工作职责: 垃圾邮件过滤脚本 - 独立的垃圾邮件过滤系统，支持前后端调用
#           提供智能垃圾邮件检测、过滤规则管理和过滤统计功能
# 系统组件: XM邮件管理系统 - 垃圾邮件过滤模块
# ============================================================================
# 用法说明:
#   spam_filter.sh <action> [参数...]
#   spam_filter.sh check <邮件文件>              - 检查邮件是否为垃圾邮件（退出码 0 正常，1 垃圾）
#   spam_filter.sh test <邮件文件>               - 测试过滤规则并输出结果
#   spam_filter.sh add-keyword <关键词> [cn|en]  - 添加关键词到黑名单（cn 中文 / en 英文）
#   spam_filter.sh add-domain <域名>             - 添加域名到黑名单
#   spam_filter.sh add-email <邮箱>              - 添加邮箱到黑名单
#   spam_filter.sh stats                         - 显示过滤统计信息
#   spam_filter.sh config                        - 显示配置来源与当前规则摘要
#   spam_filter.sh help                          - 显示帮助信息
#
# 功能描述:
#   - 垃圾邮件检测：基于关键词、域名黑名单、邮箱黑名单及内容规则（行数、大写比例、感叹号、特殊字符等）
#   - 配置来源：从数据库 spam_filter_config 表加载（通过 mail_db.sh get-spam-config/update-spam-config）
#   - 黑名单管理：add-keyword、add-domain、add-email 写入数据库
#   - 过滤统计：统计检查数、垃圾数、正常数（stats.txt）
#
# 过滤规则类型:
#   - 关键词：中文/英文关键词列表（存数据库）
#   - 域名/邮箱黑名单（存数据库）
#   - 内容规则：最小正文行数、大写比例、感叹号上限、特殊字符上限（存数据库）
#
# 数据库来源说明:
#   - maildb数据库：由db_setup.sh init命令创建，包含Postfix虚拟用户表
#   - maildb数据库：由mail_db.sh init命令创建邮件系统核心表，包括spam_filter_config表
#
# 依赖关系:
#   - Postfix（邮件服务器）
#   - mail_db.sh（数据库配置脚本）
#   - MariaDB（存储垃圾邮件过滤配置）
#   - Python3（用于JSON解析和配置处理）
#   - 密码文件：/etc/mail-ops/mail-db.pass（从密码文件读取数据库密码）
#
# 注意事项:
#   - 配置存储在数据库 spam_filter_config 表中（不再使用配置文件）
#   - 需要数据库访问权限（mailuser用户）
#   - 需要root权限配置过滤规则
#   - 过滤规则需要定期更新
#   - 误判率需要监控和调整
#   - 配置通过前端界面或API进行管理
#   - 旧的 spam_filter.conf 文件已废弃，配置迁移到数据库
#   - 数据库密码从密码文件读取，向后兼容默认值
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

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIL_DB_SCRIPT="${SCRIPT_DIR}/mail_db.sh"
LOG_FILE="/var/log/spam_filter.log"
LOG_DIR="/var/log/spam_filter"

# 数据库配置（从mail_db.sh读取）
DB_HOST="${DB_HOST:-localhost}"
DB_USER="${DB_USER:-mailuser}"
DB_NAME="${DB_NAME:-maildb}"
DB_PASS_FILE="${DB_PASS_FILE:-/etc/mail-ops/mail-db.pass}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $message" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message" >&2
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        "DEBUG")
            echo -e "${BLUE}[DEBUG]${NC} $message" >&2
            ;;
    esac
    
    # 写入日志文件
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null || true
}

# 初始化配置（从数据库加载）
init_config() {
    # 创建日志目录
    mkdir -p "$LOG_DIR"
    chown postfix:postfix "$LOG_DIR" 2>/dev/null || true
    chmod 755 "$LOG_DIR"
    
    # 从数据库加载配置
    load_config_from_db
}

# 从数据库加载配置
load_config_from_db() {
    log "DEBUG" "从数据库加载垃圾邮件过滤配置..."
    
    # 获取所有配置
    local config_json=$(bash "$MAIL_DB_SCRIPT" get-spam-config 2>/dev/null)
    
    if [ -z "$config_json" ]; then
        log "WARN" "无法从数据库加载配置，使用默认配置"
        load_default_config
        return
    fi
    
    # 解析JSON配置
    SPAM_KEYWORDS_CN=()
    SPAM_KEYWORDS_EN=()
    SPAM_DOMAINS=()
    SPAM_EMAILS=()
    
    # 使用Python解析JSON并提取配置
    eval "$(echo "$config_json" | python3 << 'PYTHON_EOF'
import json
import sys

try:
    config = json.load(sys.stdin)
    
    # 输出中文关键词数组
    keywords_cn = config.get("keywords", {}).get("chinese", [])
    print("SPAM_KEYWORDS_CN=(")
    for kw in keywords_cn:
        print(f'    "{kw}"')
    print(")")
    
    # 输出英文关键词数组
    keywords_en = config.get("keywords", {}).get("english", [])
    print("SPAM_KEYWORDS_EN=(")
    for kw in keywords_en:
        print(f'    "{kw}"')
    print(")")
    
    # 输出域名黑名单数组
    domains = config.get("domainBlacklist", [])
    print("SPAM_DOMAINS=(")
    for domain in domains:
        print(f'    "{domain}"')
    print(")")
    
    # 输出邮箱黑名单数组
    emails = config.get("emailBlacklist", [])
    print("SPAM_EMAILS=(")
    for email in emails:
        print(f'    "{email}"')
    print(")")
    
    # 输出过滤规则
    rules = config.get("rules", {})
    print(f'MIN_BODY_LINES={rules.get("minContentLines", 3)}')
    print(f'MAX_CAPS_RATIO={rules.get("uppercaseRatio", 0.7)}')
    print(f'MAX_EXCLAMATION={rules.get("maxExclamationMarks", 5)}')
    print(f'MAX_SPECIAL_CHARS={rules.get("maxSpecialChars", 10)}')
    
except Exception as e:
    # 如果解析失败，输出默认配置
    print("# 配置解析失败，使用默认值")
    pass
PYTHON_EOF
)"
    
    log "DEBUG" "配置加载完成: 中文关键词 ${#SPAM_KEYWORDS_CN[@]} 个, 英文关键词 ${#SPAM_KEYWORDS_EN[@]} 个, 域名 ${#SPAM_DOMAINS[@]} 个, 邮箱 ${#SPAM_EMAILS[@]} 个"
}

# 加载默认配置（当数据库不可用时）
load_default_config() {
    SPAM_KEYWORDS_CN=("免费" "赚钱" "投资" "理财" "贷款" "信用卡" "中奖" "彩票")
    SPAM_KEYWORDS_EN=("viagra" "casino" "lottery" "winner" "congratulations" "urgent")
    SPAM_DOMAINS=("spam.com" "junk.com" "trash.com" "fake.com")
    SPAM_EMAILS=("noreply@spam.com" "admin@junk.com" "info@trash.com")
    MIN_BODY_LINES=3
    MAX_CAPS_RATIO=0.7
    MAX_EXCLAMATION=5
    MAX_SPECIAL_CHARS=10
}

# 检查邮件内容
check_spam_content() {
    local email_file="$1"
    local result=0
    
    if [ ! -f "$email_file" ]; then
        log "ERROR" "邮件文件不存在: $email_file"
        return 1
    fi
    
    log "DEBUG" "开始检查邮件: $email_file"
    
    # 读取邮件内容（转换为小写）
    local content=$(cat "$email_file" | tr '[:upper:]' '[:lower:]')
    local subject=$(grep -i "^Subject:" "$email_file" | head -1 | cut -d: -f2- | tr '[:upper:]' '[:lower:]')
    local from=$(grep -i "^From:" "$email_file" | head -1 | cut -d: -f2- | tr '[:upper:]' '[:lower:]')
    
    # 检查中文关键词
    for keyword in "${SPAM_KEYWORDS_CN[@]}"; do
        if echo "$content" | grep -q "$keyword"; then
            log "WARN" "检测到垃圾邮件关键词(中文): $keyword"
            result=1
        fi
    done
    
    # 检查英文关键词
    for keyword in "${SPAM_KEYWORDS_EN[@]}"; do
        if echo "$content" | grep -q "$keyword"; then
            log "WARN" "检测到垃圾邮件关键词(英文): $keyword"
            result=1
        fi
    done
    
    # 检查发件人域名黑名单
    for domain in "${SPAM_DOMAINS[@]}"; do
        if echo "$from" | grep -q "$domain"; then
            log "WARN" "发件人域名在黑名单中: $domain"
            result=1
        fi
    done
    
    # 检查发件人邮箱黑名单
    for email in "${SPAM_EMAILS[@]}"; do
        if echo "$from" | grep -q "$email"; then
            log "WARN" "发件人邮箱在黑名单中: $email"
            result=1
        fi
    done
    
    # 检查邮件头标记
    if grep -qi "x-spam-flag: yes" "$email_file"; then
        log "WARN" "邮件头标记为垃圾邮件"
        result=1
    fi
    
    # 检查内容长度
    local body_lines=$(grep -v "^From:\|^To:\|^Subject:\|^Date:\|^Message-ID:" "$email_file" | wc -l)
    if [ "$body_lines" -lt "$MIN_BODY_LINES" ]; then
        log "WARN" "邮件内容过短，疑似垃圾邮件 (行数: $body_lines)"
        result=1
    fi
    
    # 检查大写字母比例
    local total_chars=$(echo "$content" | wc -c)
    local caps_chars=$(echo "$content" | grep -o '[A-Z]' | wc -l)
    if [ "$total_chars" -gt 0 ]; then
        local caps_ratio=$(echo "scale=2; $caps_chars / $total_chars" | bc -l 2>/dev/null || echo "0")
        if (( $(echo "$caps_ratio > $MAX_CAPS_RATIO" | bc -l 2>/dev/null || echo "0") )); then
            log "WARN" "大写字母比例过高: $caps_ratio"
            result=1
        fi
    fi
    
    # 检查感叹号数量
    local exclamation_count=$(echo "$content" | grep -o '!' | wc -l)
    if [ "$exclamation_count" -gt "$MAX_EXCLAMATION" ]; then
        log "WARN" "感叹号数量过多: $exclamation_count"
        result=1
    fi
    
    # 检查特殊字符数量
    local special_chars=$(echo "$content" | grep -o '[!@#$%^&*()_+={}|:"<>?]' | wc -l)
    if [ "$special_chars" -gt "$MAX_SPECIAL_CHARS" ]; then
        log "WARN" "特殊字符数量过多: $special_chars"
        result=1
    fi
    
    return $result
}

# 添加关键词到黑名单（保存到数据库）
add_keyword() {
    local keyword="$1"
    local lang="${2:-cn}"
    
    log "INFO" "添加关键词到数据库: $keyword (语言: $lang)"
    
    # 获取当前配置
    local config_json=$(bash "$MAIL_DB_SCRIPT" get-spam-config 2>/dev/null)
    if [ -z "$config_json" ]; then
        log "ERROR" "无法从数据库获取配置"
        return 1
    fi
    
    # 使用Python更新配置
    local updated_config=$(echo "$config_json" | python3 << PYTHON_EOF
import json
import sys

try:
    config = json.load(sys.stdin)
    keyword = "$keyword"
    lang = "$lang"
    
    if lang == "cn":
        if "chinese" not in config.get("keywords", {}):
            config["keywords"]["chinese"] = []
        if keyword not in config["keywords"]["chinese"]:
            config["keywords"]["chinese"].append(keyword)
    else:
        if "english" not in config.get("keywords", {}):
            config["keywords"]["english"] = []
        if keyword not in config["keywords"]["english"]:
            config["keywords"]["english"].append(keyword)
    
    print(json.dumps(config, ensure_ascii=False))
except Exception as e:
    print("{}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
)
    
    if [ -n "$updated_config" ]; then
        # 更新数据库
        local keywords_json=$(echo "$updated_config" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['keywords']['chinese'] if '$lang' == 'cn' else d['keywords']['english'], ensure_ascii=False))")
        bash "$MAIL_DB_SCRIPT" update-spam-config "keyword_${lang}" "$keywords_json" >/dev/null 2>&1
        log "INFO" "关键词已添加到数据库: $keyword"
    else
        log "ERROR" "更新配置失败"
        return 1
    fi
}

# 添加域名到黑名单（保存到数据库）
add_domain() {
    local domain="$1"
    
    log "INFO" "添加域名到数据库: $domain"
    
    # 获取当前配置
    local config_json=$(bash "$MAIL_DB_SCRIPT" get-spam-config 2>/dev/null)
    if [ -z "$config_json" ]; then
        log "ERROR" "无法从数据库获取配置"
        return 1
    fi
    
    # 使用Python更新配置
    local updated_config=$(echo "$config_json" | python3 << PYTHON_EOF
import json
import sys

try:
    config = json.load(sys.stdin)
    domain = "$domain"
    
    if "domainBlacklist" not in config:
        config["domainBlacklist"] = []
    if domain not in config["domainBlacklist"]:
        config["domainBlacklist"].append(domain)
    
    print(json.dumps(config, ensure_ascii=False))
except Exception as e:
    print("{}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
)
    
    if [ -n "$updated_config" ]; then
        # 更新数据库
        local domains_json=$(echo "$updated_config" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['domainBlacklist'], ensure_ascii=False))")
        bash "$MAIL_DB_SCRIPT" update-spam-config "domain" "$domains_json" >/dev/null 2>&1
        log "INFO" "域名已添加到数据库: $domain"
    else
        log "ERROR" "更新配置失败"
        return 1
    fi
}

# 添加邮箱到黑名单（保存到数据库）
add_email() {
    local email="$1"
    
    log "INFO" "添加邮箱到数据库: $email"
    
    # 获取当前配置
    local config_json=$(bash "$MAIL_DB_SCRIPT" get-spam-config 2>/dev/null)
    if [ -z "$config_json" ]; then
        log "ERROR" "无法从数据库获取配置"
        return 1
    fi
    
    # 使用Python更新配置
    local updated_config=$(echo "$config_json" | python3 << PYTHON_EOF
import json
import sys

try:
    config = json.load(sys.stdin)
    email = "$email"
    
    if "emailBlacklist" not in config:
        config["emailBlacklist"] = []
    if email not in config["emailBlacklist"]:
        config["emailBlacklist"].append(email)
    
    print(json.dumps(config, ensure_ascii=False))
except Exception as e:
    print("{}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
)
    
    if [ -n "$updated_config" ]; then
        # 更新数据库
        local emails_json=$(echo "$updated_config" | python3 -c "import json,sys; d=json.load(sys.stdin); print(json.dumps(d['emailBlacklist'], ensure_ascii=False))")
        bash "$MAIL_DB_SCRIPT" update-spam-config "email" "$emails_json" >/dev/null 2>&1
        log "INFO" "邮箱已添加到数据库: $email"
    else
        log "ERROR" "更新配置失败"
        return 1
    fi
}

# 显示统计信息
show_stats() {
    local stats_file="$LOG_DIR/stats.txt"
    
    if [ -f "$stats_file" ]; then
        log "INFO" "垃圾邮件过滤统计信息:"
        cat "$stats_file"
    else
        log "INFO" "暂无统计信息"
    fi
}

# 更新统计信息
update_stats() {
    local stats_file="$LOG_DIR/stats.txt"
    local action="$1"
    
    # 创建统计文件（如果不存在）
    if [ ! -f "$stats_file" ]; then
        echo "total_checked=0" > "$stats_file"
        echo "spam_detected=0" >> "$stats_file"
        echo "clean_emails=0" >> "$stats_file"
        echo "last_updated=$(date)" >> "$stats_file"
    fi
    
    # 更新统计
    case "$action" in
        "spam")
            local spam_count=$(grep "spam_detected=" "$stats_file" | cut -d= -f2)
            echo "spam_detected=$((spam_count + 1))" > "$stats_file.tmp"
            grep -v "spam_detected=" "$stats_file" >> "$stats_file.tmp"
            mv "$stats_file.tmp" "$stats_file"
            ;;
        "clean")
            local clean_count=$(grep "clean_emails=" "$stats_file" | cut -d= -f2)
            echo "clean_emails=$((clean_count + 1))" > "$stats_file.tmp"
            grep -v "clean_emails=" "$stats_file" >> "$stats_file.tmp"
            mv "$stats_file.tmp" "$stats_file"
            ;;
    esac
    
    # 更新总检查数
    local total_count=$(grep "total_checked=" "$stats_file" | cut -d= -f2)
    echo "total_checked=$((total_count + 1))" > "$stats_file.tmp"
    grep -v "total_checked=" "$stats_file" >> "$stats_file.tmp"
    mv "$stats_file.tmp" "$stats_file"
}

# 主函数
main() {
    local action="${1:-help}"
    local email_file="${2:-}"
    
    # 初始化
    init_config
    
    case "$action" in
        "check")
            if [ -z "$email_file" ]; then
                log "ERROR" "用法: $0 check <邮件文件>"
                exit 1
            fi
            
            if check_spam_content "$email_file"; then
                log "INFO" "邮件通过垃圾邮件检测"
                update_stats "clean"
                exit 0
            else
                log "WARN" "邮件被识别为垃圾邮件"
                update_stats "spam"
                exit 1
            fi
            ;;
        "add-keyword")
            if [ -z "$2" ]; then
                log "ERROR" "用法: $0 add-keyword <关键词> [cn|en]"
                exit 1
            fi
            add_keyword "$2" "$3"
            ;;
        "add-domain")
            if [ -z "$2" ]; then
                log "ERROR" "用法: $0 add-domain <域名>"
                exit 1
            fi
            add_domain "$2"
            ;;
        "add-email")
            if [ -z "$2" ]; then
                log "ERROR" "用法: $0 add-email <邮箱>"
                exit 1
            fi
            add_email "$2"
            ;;
        "stats")
            show_stats
            ;;
        "config")
            log "INFO" "配置来源: 数据库 (spam_filter_config表)"
            log "INFO" "日志文件位置: $LOG_FILE"
            log "INFO" "日志目录: $LOG_DIR"
            log "INFO" "当前配置:"
            log "INFO" "  中文关键词: ${#SPAM_KEYWORDS_CN[@]} 个"
            log "INFO" "  英文关键词: ${#SPAM_KEYWORDS_EN[@]} 个"
            log "INFO" "  域名黑名单: ${#SPAM_DOMAINS[@]} 个"
            log "INFO" "  邮箱黑名单: ${#SPAM_EMAILS[@]} 个"
            ;;
        "test")
            if [ -z "$email_file" ]; then
                log "ERROR" "用法: $0 test <邮件文件>"
                exit 1
            fi
            log "INFO" "开始测试垃圾邮件过滤..."
            if check_spam_content "$email_file"; then
                log "INFO" "✅ 测试通过: 邮件被识别为正常邮件"
            else
                log "INFO" "✅ 测试通过: 邮件被识别为垃圾邮件"
            fi
            ;;
        "help"|*)
            echo "XM邮件系统 - 垃圾邮件过滤脚本"
            echo "用法: $0 <命令> [参数]"
            echo ""
            echo "命令:"
            echo "  check <邮件文件>           - 检查邮件是否为垃圾邮件"
            echo "  test <邮件文件>            - 测试邮件过滤功能"
            echo "  add-keyword <关键词> [语言] - 添加关键词到黑名单"
            echo "  add-domain <域名>          - 添加域名到黑名单"
            echo "  add-email <邮箱>          - 添加邮箱到黑名单"
            echo "  stats                     - 显示统计信息"
            echo "  config                    - 显示配置信息"
            echo "  help                      - 显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 check /path/to/email.txt"
            echo "  $0 add-keyword '免费赚钱' cn"
            echo "  $0 add-domain 'spam.com'"
            echo "  $0 stats"
            ;;
    esac
}

# 执行主函数
main "$@"
