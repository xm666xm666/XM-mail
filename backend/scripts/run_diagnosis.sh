#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: run_diagnosis.sh
# 工作职责: 系统诊断入口脚本 - 调用 start.sh check 执行完整系统诊断（run_diagnosis）
#           供 Dashboard 环境检查按钮通过调度层 API 调用
# 系统组件: XM邮件管理系统 - 诊断模块
# ============================================================================
# 用法说明:
#   run_diagnosis.sh
#   无参数，直接执行 start.sh check
#
# 功能描述:
#   - 作为 start.sh check 的包装脚本，供 dispatcher 从 backend/scripts 目录调用
#   - 执行 run_diagnosis：核心服务、数据库、端口、配置、前端、Apache、API、调度层、用户权限、磁盘、日志等全面检查
#
# 调用链:
#   Dashboard 环境检查按钮 → /api/ops (action=check) → run_diagnosis.sh → start.sh check
#
# 依赖关系:
#   - start.sh（主部署脚本，包含 run_diagnosis 函数）
#   - BASE_DIR：脚本所在目录上两级（backend/scripts → 项目根）
#
# 注意事项:
#   - 需要 root 权限（start.sh check 内部 require_root）
#   - 由调度层通过 sudo 调用
# ============================================================================

set -euo pipefail
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$BASE_DIR"
exec ./start.sh check
