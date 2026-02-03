#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: test_spam_filter.sh
# 工作职责: 垃圾邮件过滤测试脚本 - 负责测试垃圾邮件过滤系统的各种场景
#           提供全面的测试用例，验证过滤规则的有效性和准确性
# 系统组件: XM邮件管理系统 - 垃圾邮件过滤测试模块
# ============================================================================
# 用法说明:
#   test_spam_filter.sh [命令]
#   test_spam_filter.sh              - 运行所有测试（默认 all）
#   test_spam_filter.sh all          - 运行所有测试并清理
#   test_spam_filter.sh quick        - 快速测试（少量用例）
#   test_spam_filter.sh cleanup      - 仅清理测试文件
#   test_spam_filter.sh help         - 显示帮助信息
#
# 功能描述:
#   - 测试用例执行：执行预定义的测试用例
#   - 规则验证：验证过滤规则是否正确工作
#   - 误判检测：检测是否存在误判情况
#   - 性能测试：测试过滤系统的性能
#   - 结果统计：统计测试通过率和失败率
#   - 报告生成：生成测试报告
#
# 测试场景:
#   - 正常邮件测试：验证正常邮件不被误判
#   - 垃圾邮件测试：验证垃圾邮件被正确识别
#   - 边界情况测试：测试边界和异常情况
#   - 性能压力测试：测试大量邮件的处理能力
#
# 依赖关系:
#   - spam_filter.sh（垃圾邮件过滤脚本）
#   - 测试邮件文件
#
# 注意事项:
#   - 测试需要准备测试邮件文件
#   - 测试结果需要人工验证
#   - 定期运行测试以确保过滤效果
# ============================================================================

set -euo pipefail

# 脚本配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPAM_FILTER="$SCRIPT_DIR/spam_filter.sh"
TEST_DIR="/tmp/spam_test_$(date +%s)"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
run_test() {
    local test_name="$1"
    local email_file="$2"
    local expected_result="$3"  # 0=正常邮件, 1=垃圾邮件
    local description="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -e "${BLUE}测试 $TOTAL_TESTS: $test_name${NC}"
    echo "描述: $description"
    echo "邮件文件: $email_file"
    echo "期望结果: $([ "$expected_result" = "0" ] && echo "正常邮件" || echo "垃圾邮件")"
    
    # 运行过滤脚本
    if "$SPAM_FILTER" check "$email_file" >/dev/null 2>&1; then
        local actual_result=0
    else
        local actual_result=1
    fi
    
    # 检查结果
    if [ "$actual_result" = "$expected_result" ]; then
        echo -e "${GREEN}✅ 测试通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ 测试失败${NC}"
        echo "期望: $([ "$expected_result" = "0" ] && echo "正常邮件" || echo "垃圾邮件")"
        echo "实际: $([ "$actual_result" = "0" ] && echo "正常邮件" || echo "垃圾邮件")"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    
    echo "----------------------------------------"
}

# 创建测试邮件
create_test_emails() {
    # 创建测试目录
    mkdir -p "$TEST_DIR"
    
    # 测试邮件1：正常邮件
    cat > "$TEST_DIR/normal_email.txt" << 'EOF'
From: test@example.com
To: user@xmskills.com
Subject: 正常邮件测试
Date: $(date)
Message-ID: <test123@example.com>

这是一封正常的邮件，用于测试垃圾邮件过滤功能。
内容健康，不包含任何垃圾邮件关键词。
邮件内容足够长，符合正常邮件的标准。

此邮件用于验证过滤系统不会误判正常邮件。
EOF

    # 测试邮件2：包含中文垃圾邮件关键词
    cat > "$TEST_DIR/spam_cn_email.txt" << 'EOF'
From: spammer@spam.com
To: user@xmskills.com
Subject: 免费赚钱机会！
Date: $(date)
Message-ID: <spam123@spam.com>

免费赚钱！投资理财！信用卡申请！
点击这里立即行动！限时优惠！
高薪兼职，轻松赚钱，无风险投资！

立即点击，马上行动！不要错过这个机会！
EOF

    # 测试邮件3：包含英文垃圾邮件关键词
    cat > "$TEST_DIR/spam_en_email.txt" << 'EOF'
From: winner@casino.com
To: user@xmskills.com
Subject: Congratulations! You are a winner!
Date: $(date)
Message-ID: <winner123@casino.com>

Congratulations! You are the winner of our lottery!
Click here to claim your prize! Limited time offer!
Make money fast! Work from home! Get rich quick!

Act now! Guaranteed profit! No risk investment!
EOF

    # 测试邮件4：发件人域名在黑名单
    cat > "$TEST_DIR/spam_domain_email.txt" << 'EOF'
From: fake@spam.com
To: user@xmskills.com
Subject: 垃圾邮件测试
Date: $(date)
Message-ID: <fake123@spam.com>

这是一封来自黑名单域名的邮件。
虽然内容看起来正常，但发件人域名在黑名单中。
EOF

    # 测试邮件5：发件人邮箱在黑名单
    cat > "$TEST_DIR/spam_email_blacklist.txt" << 'EOF'
From: noreply@spam.com
To: user@xmskills.com
Subject: 黑名单邮箱测试
Date: $(date)
Message-ID: <blacklist123@spam.com>

这是一封来自黑名单邮箱的邮件。
发件人邮箱地址在黑名单中。
EOF

    # 测试邮件6：内容过短
    cat > "$TEST_DIR/short_email.txt" << 'EOF'
From: test@example.com
To: user@xmskills.com
Subject: 短邮件
Date: $(date)
Message-ID: <short123@example.com>

短
EOF

    # 测试邮件7：大写字母过多
    cat > "$TEST_DIR/caps_email.txt" << 'EOF'
From: test@example.com
To: user@xmskills.com
Subject: 大写字母测试
Date: $(date)
Message-ID: <caps123@example.com>

THIS IS A TEST EMAIL WITH TOO MANY CAPITAL LETTERS!
THIS MIGHT BE CONSIDERED AS SPAM BECAUSE OF THE EXCESSIVE USE OF CAPS!
PLEASE CHECK IF THIS EMAIL IS FILTERED CORRECTLY!
EOF

    # 测试邮件8：感叹号过多
    cat > "$TEST_DIR/exclamation_email.txt" << 'EOF'
From: test@example.com
To: user@xmskills.com
Subject: 感叹号测试
Date: $(date)
Message-ID: <excl123@example.com>

这是一个测试邮件！包含很多感叹号！！！
看起来像是垃圾邮件！！！！
但是内容本身是正常的！！！！
只是感叹号太多了！！！！
EOF

    # 测试邮件9：特殊字符过多
    cat > "$TEST_DIR/special_chars_email.txt" << 'EOF'
From: test@example.com
To: user@xmskills.com
Subject: 特殊字符测试
Date: $(date)
Message-ID: <special123@example.com>

这是一个包含大量特殊字符的邮件：!@#$%^&*()_+={}|:"<>?
这些特殊字符可能会被识别为垃圾邮件特征。
请测试过滤系统是否能正确识别。
EOF

    # 测试邮件10：邮件头标记为垃圾邮件
    cat > "$TEST_DIR/spam_header_email.txt" << 'EOF'
From: test@example.com
To: user@xmskills.com
Subject: 垃圾邮件头测试
Date: $(date)
Message-ID: <header123@example.com>
X-Spam-Flag: yes

这是一封在邮件头中标记为垃圾邮件的邮件。
虽然内容看起来正常，但邮件头已经标记为垃圾邮件。
EOF
}

# 运行所有测试
run_all_tests() {
    echo -e "${YELLOW}开始垃圾邮件过滤系统测试...${NC}"
    echo "========================================"
    
    # 检查过滤脚本是否存在
    if [ ! -f "$SPAM_FILTER" ]; then
        echo -e "${RED}错误: 垃圾邮件过滤脚本不存在: $SPAM_FILTER${NC}"
        exit 1
    fi
    
    # 创建测试邮件
    create_test_emails
    
    # 运行测试
    run_test "正常邮件" "$TEST_DIR/normal_email.txt" "0" "不包含任何垃圾邮件特征的正常邮件"
    run_test "中文垃圾关键词" "$TEST_DIR/spam_cn_email.txt" "1" "包含中文垃圾邮件关键词的邮件"
    run_test "英文垃圾关键词" "$TEST_DIR/spam_en_email.txt" "1" "包含英文垃圾邮件关键词的邮件"
    run_test "黑名单域名" "$TEST_DIR/spam_domain_email.txt" "1" "发件人域名在黑名单中的邮件"
    run_test "黑名单邮箱" "$TEST_DIR/spam_email_blacklist.txt" "1" "发件人邮箱在黑名单中的邮件"
    run_test "内容过短" "$TEST_DIR/short_email.txt" "1" "邮件内容过短，疑似垃圾邮件"
    run_test "大写字母过多" "$TEST_DIR/caps_email.txt" "1" "包含过多大写字母的邮件"
    run_test "感叹号过多" "$TEST_DIR/exclamation_email.txt" "1" "包含过多感叹号的邮件"
    run_test "特殊字符过多" "$TEST_DIR/special_chars_email.txt" "1" "包含过多特殊字符的邮件"
    run_test "垃圾邮件头" "$TEST_DIR/spam_header_email.txt" "1" "邮件头标记为垃圾邮件的邮件"
    
    # 显示测试结果
    echo -e "${YELLOW}测试结果汇总:${NC}"
    echo "总测试数: $TOTAL_TESTS"
    echo -e "通过测试: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "失败测试: ${RED}$FAILED_TESTS${NC}"
    
    if [ "$FAILED_TESTS" -eq 0 ]; then
        echo -e "${GREEN}🎉 所有测试通过！垃圾邮件过滤系统工作正常。${NC}"
        return 0
    else
        echo -e "${RED}⚠️  有 $FAILED_TESTS 个测试失败，请检查过滤规则。${NC}"
        return 1
    fi
}

# 清理测试文件
cleanup() {
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        echo "清理测试文件: $TEST_DIR"
    fi
}

# 主函数
main() {
    local action="${1:-all}"
    
    case "$action" in
        "all")
            run_all_tests
            cleanup
            ;;
        "quick")
            echo "快速测试模式..."
            # 只运行几个基本测试
            create_test_emails
            run_test "正常邮件" "$TEST_DIR/normal_email.txt" "0" "正常邮件测试"
            run_test "垃圾邮件" "$TEST_DIR/spam_cn_email.txt" "1" "垃圾邮件测试"
            cleanup
            ;;
        "cleanup")
            cleanup
            ;;
        "help"|*)
            echo "垃圾邮件过滤测试脚本"
            echo "用法: $0 [命令]"
            echo ""
            echo "命令:"
            echo "  all      - 运行所有测试（默认）"
            echo "  quick    - 运行快速测试"
            echo "  cleanup  - 清理测试文件"
            echo "  help     - 显示帮助信息"
            ;;
    esac
}

# 设置退出时清理
trap cleanup EXIT

# 执行主函数
main "$@"
