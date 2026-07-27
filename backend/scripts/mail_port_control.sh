#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: mail_port_control.sh
# 工作职责: 邮件服务端口控制脚本 - 按端口单独启用/禁用 Postfix 与 Dovecot 监听
#           支持 25/587（SMTP）与 993/995（IMAP/POP3）端口的独立开关
# 系统组件: XM邮件管理系统 - 邮件服务端口管理模块
# ============================================================================
# 用法说明:
#   mail_port_control.sh status              - 查询各端口当前状态（JSON 格式）
#   mail_port_control.sh <端口> <enable|disable> - 启用或禁用指定端口
#
# 端口说明:
#   - 25：Postfix SMTP（标准邮件接收）
#   - 587：Postfix Submission（邮件提交）
#   - 993：Dovecot IMAPS（IMAP over SSL）
#   - 995：Dovecot POP3S（POP3 over SSL）
#
# 功能描述:
#   - 状态查询：从 master.cf 与 10-master.conf 读取端口启用状态
#   - Postfix 控制：通过注释/取消注释 master.cf 中的 smtp、submission 行
#   - Dovecot 控制：通过设置 port=0 禁用、port=993/995 启用
#   - 服务重载：修改后自动执行 postfix reload 或 systemctl reload dovecot
#
# 依赖关系:
#   - Postfix（/etc/postfix/master.cf）
#   - Dovecot（/etc/dovecot/conf.d/10-master.conf）
#
# 注意事项:
#   - 需要 root 权限执行
#   - 禁用端口后需 reload 服务生效
#   - 本脚本不定义 BASE_DIR
# ============================================================================
set -u

MASTER_CF=/etc/postfix/master.cf
DOVECOT_MASTER=/etc/dovecot/conf.d/10-master.conf

# 读取端口状态（从配置文件）
# Postfix: 禁用时为 #smtp、# smtp、-smtp 等；支持 # 后跟可选空格
# Dovecot: port = 0 表示禁用；port 被注释或缺失时使用默认端口（启用）
status() {
  local result='{"postfix":{"25":true,"587":true},"dovecot":{"993":true,"995":true}}'
  if [[ -f "$MASTER_CF" ]]; then
    grep -qE '^#[[:space:]]*smtp inet|^-smtp inet' "$MASTER_CF" 2>/dev/null && result=$(echo "$result" | sed 's/"25":true/"25":false/')
    grep -qE '^#[[:space:]]*submission inet|^-submission inet' "$MASTER_CF" 2>/dev/null && result=$(echo "$result" | sed 's/"587":true/"587":false/')
  fi
  if [[ -f "$DOVECOT_MASTER" ]]; then
    grep -A8 'inet_listener imaps' "$DOVECOT_MASTER" 2>/dev/null | grep -qE '[[:space:]]*port[[:space:]]*=[[:space:]]*0' && result=$(echo "$result" | sed 's/"993":true/"993":false/')
    grep -A8 'inet_listener pop3s' "$DOVECOT_MASTER" 2>/dev/null | grep -qE '[[:space:]]*port[[:space:]]*=[[:space:]]*0' && result=$(echo "$result" | sed 's/"995":true/"995":false/')
  fi
  echo "$result"
}

# 控制 Postfix 端口 25
# 支持 #smtp、# smtp、-smtp 等注释/禁用格式
postfix_port_25() {
  local enable=$1
  if [[ "$enable" == "true" ]]; then
    sed -i 's/^#[[:space:]]*smtp inet/smtp inet/' "$MASTER_CF"
    sed -i 's/^-smtp inet/smtp inet/' "$MASTER_CF"
  else
    sed -i 's/^[[:space:]]*smtp inet/#smtp inet/' "$MASTER_CF"
  fi
  postfix reload
}

# 控制 Postfix 端口 587（处理主行及 continuation 行）
# 支持 #submission、# submission 等注释格式；启用时去除 # 及前导空格
postfix_port_587() {
  local enable=$1
  local tmp
  tmp=$(mktemp)
  local in_block=0

  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*#?[[:space:]]*submission[[:space:]]+inet ]]; then
      in_block=1
      if [[ "$enable" == "true" ]]; then
        echo "$line" | sed 's/^[[:space:]]*#\?[[:space:]]*//' >> "$tmp"
      else
        [[ "$line" =~ ^[[:space:]]*# ]] && echo "$line" >> "$tmp" || echo "#$line" >> "$tmp"
      fi
    elif [[ $in_block -eq 1 ]] && [[ "$line" =~ ^[[:space:]] ]]; then
      if [[ "$enable" == "true" ]]; then
        echo "$line" | sed 's/^[[:space:]]*#\?[[:space:]]*//' >> "$tmp"
      else
        [[ "$line" =~ ^[[:space:]]*# ]] && echo "$line" >> "$tmp" || echo "#$line" >> "$tmp"
      fi
    else
      [[ $in_block -eq 1 ]] && in_block=0
      echo "$line" >> "$tmp"
    fi
  done < "$MASTER_CF"
  mv "$tmp" "$MASTER_CF"
  postfix reload
}

# 控制 Dovecot 端口 993 或 995
# 注意：Dovecot 默认配置可能将 port 注释掉（#port = 993），此时使用默认端口；需同时匹配注释与未注释行
dovecot_port() {
  local port=$1
  local enable=$2
  local listener="imaps"
  [[ "$port" == "995" ]] && listener="pop3s"
  local want_port=$port
  [[ "$enable" == "false" ]] && want_port=0

  if ! grep -q "inet_listener $listener" "$DOVECOT_MASTER" 2>/dev/null; then
    echo "inet_listener $listener not found in $DOVECOT_MASTER" >&2
    exit 1
  fi

  # 匹配 port 行（含注释 #port = 993、# port = 993、port = 993 等），替换为 port = $want_port
  sed -i "/inet_listener $listener {/,/^[[:space:]]*}/ s/^[[:space:]]*#\?[[:space:]]*port[[:space:]]*=[[:space:]]*[0-9]\+/  port = $want_port/" "$DOVECOT_MASTER"

  # 若块内无 port 行（使用默认端口），在 inet_listener 开括号后插入 port 行
  if ! grep -A8 "inet_listener $listener" "$DOVECOT_MASTER" 2>/dev/null | grep -qE "[[:space:]]*#?[[:space:]]*port[[:space:]]*="; then
    sed -i "/inet_listener $listener {/a\  port = $want_port" "$DOVECOT_MASTER"
  fi

  systemctl restart dovecot
}

case "${1:-}" in
  status)
    status
    ;;
  25)
    [[ "${2:-}" != "enable" && "${2:-}" != "disable" ]] && { echo "Usage: $0 25 enable|disable"; exit 1; }
    postfix_port_25 "$([[ "${2:-}" == "enable" ]] && echo true || echo false)"
    ;;
  587)
    [[ "${2:-}" != "enable" && "${2:-}" != "disable" ]] && { echo "Usage: $0 587 enable|disable"; exit 1; }
    postfix_port_587 "$([[ "${2:-}" == "enable" ]] && echo true || echo false)"
    ;;
  993|995)
    [[ "${2:-}" != "enable" && "${2:-}" != "disable" ]] && { echo "Usage: $0 $1 enable|disable"; exit 1; }
    dovecot_port "$1" "$([[ "${2:-}" == "enable" ]] && echo true || echo false)"
    ;;
  *)
    echo "Usage: $0 status | $0 <25|587|993|995> <enable|disable>"
    exit 1
    ;;
esac
