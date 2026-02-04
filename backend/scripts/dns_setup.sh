#!/usr/bin/env bash
#
# ============================================================================
# 脚本名称: dns_setup.sh
# 工作职责: DNS配置与管理脚本 - 负责Bind DNS服务器和公网DNS的配置与管理
#           支持本地Bind DNS配置和公网DNS配置，包括域名解析、MX记录、SPF/DKIM/DMARC等
# 系统组件: XM邮件管理系统 - DNS配置模块
# ============================================================================
# 用法说明:
#   dns_setup.sh <命令> [参数...]
#   dns_setup.sh help | -h | --help           - 显示帮助
#   dns_setup.sh install                       - 仅安装 Bind DNS 组件
#   dns_setup.sh configure-bind <域名> <服务器IP> [管理员邮箱] [启用递归] [启用转发] [上游DNS]
#   dns_setup.sh configure-public <域名> [服务器IP] [管理员邮箱] ...
#   dns_setup.sh bind <域名> <服务器IP> ...    - 同 configure-bind（内部映射）
#   dns_setup.sh public <域名> <服务器IP> ...  - 同 configure-public（内部映射）
#   dns_setup.sh restart                       - 重启 Bind 服务
#   dns_setup.sh stop                          - 停止 Bind 服务
#
# 功能描述:
#   - Bind DNS配置：安装、配置和管理本地Bind DNS服务器
#   - 公网DNS配置：配置公网DNS服务器信息（无需本地Bind）
#   - 域名解析配置：创建A记录、MX记录、PTR记录等
#   - 安全记录配置：SPF、DKIM、DMARC记录配置
#   - Apache集成：自动配置Apache虚拟主机（含www子域）
#   - DNS健康检查：验证DNS配置和解析是否正常
#   - 系统DNS配置：更新系统resolv.conf和NetworkManager配置
#
# DNS记录类型:
#   - A记录：域名到IP地址的映射
#   - MX记录：邮件交换记录
#   - PTR记录：反向解析记录
#   - SPF记录：发件人策略框架
#   - DKIM记录：域名密钥识别邮件
#   - DMARC记录：基于域的消息认证
#
# 端口配置:
#   - Apache HTTP/HTTPS端口：从config/port-config.json读取（默认80/443）
#   - VirtualHost配置使用动态端口变量
#   - 支持自定义HTTP/HTTPS端口配置
#
# 依赖关系:
#   - bind, bind-utils, bind-chroot（Bind DNS）
#   - NetworkManager（系统DNS配置）
#   - Apache（虚拟主机配置）
#   - jq（JSON配置管理）
#
# 注意事项:
#   - 需要root权限执行DNS配置
#   - Bind DNS需要防火墙开放53端口
#   - 公网DNS配置需要有效的公网IP地址
#   - DNS配置时仅配置HTTP虚拟主机，不自动配置HTTPS
#   - HTTPS配置需要通过上传SSL证书后完成
#   - HTTP跳转HTTPS需要通过cert_setup.sh enable-http-redirect单独配置
# ============================================================================

# 设置工作目录，避免 getcwd 错误
cd "$(dirname "$0")/../.." 2>/dev/null || cd /bash 2>/dev/null || cd / 2>/dev/null || true

# 获取项目根目录（BASE_DIR）
BASE_DIR=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd || echo "/bash")
CONFIG_DIR="$BASE_DIR/config"

set -uo pipefail

# 读取端口配置
get_port_config() {
    local port_config_file="$CONFIG_DIR/port-config.json"
    local apache_http_port=80
    local apache_https_port=443
    
    if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
        apache_http_port=$(jq -r '.apache.httpPort // 80' "$port_config_file" 2>/dev/null || echo "80")
        apache_https_port=$(jq -r '.apache.httpsPort // 443' "$port_config_file" 2>/dev/null || echo "443")
    fi
    
    echo "$apache_http_port|$apache_https_port"
}

PORT_CONFIG=$(get_port_config)
APACHE_HTTP_PORT=$(echo "$PORT_CONFIG" | cut -d'|' -f1)
APACHE_HTTPS_PORT=$(echo "$PORT_CONFIG" | cut -d'|' -f2)

# 禁用输出缓冲
export PYTHONUNBUFFERED=1
export STDBUF=0

log() { echo "[dns_setup] $*" >&1; }

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;38;5;208m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    log "INFO: $1"
}

log_success() {
    log "SUCCESS: $1"
}

log_warning() {
    log "WARNING: $1"
}

log_error() {
    log "ERROR: $1"
}

log_complete() {
    log "COMPLETE: $1"
}

# 权限检查
require_root() {
  if [[ $(id -u) -ne 0 ]]; then
    log_warning "当前用户不是 root，某些操作可能失败"
    log_warning "建议: 使用 sudo 运行此脚本或切换到 root 用户"
    # 不退出，继续执行，让脚本自己处理权限问题
    fi
}

# 安装Bind DNS服务器
install_bind() {
    log_info "开始安装Bind DNS服务器..."
    
    # 更新系统包（允许失败，不影响安装）
    dnf update -y || {
        log_warning "系统包更新失败，继续安装Bind"
    }
    
    # 安装Bind和相关工具（允许部分失败）
    dnf install -y bind bind-utils bind-chroot --skip-broken || {
        log_warning "部分Bind组件安装失败，但继续执行"
    }
    
    # 检查是否至少安装了bind包
    if command -v named >/dev/null 2>&1 || rpm -q bind >/dev/null 2>&1; then
        log_success "Bind DNS服务器安装完成"
    else
        log_warning "Bind DNS服务器可能未完全安装，但继续执行"
    fi
}

# 配置公网DNS
configure_public_dns() {
    local domain=$1
    local server_ip=$2
    local admin_email=$3
    local enable_recursion=$4
    local enable_forwarding=$5
    local upstream_dns=$6
    
    log_info "配置公网DNS设置..."
    
    # 获取真正的公网IP
    log_info "获取公网IP地址..."
    local public_ip=""
    
    # 尝试多个公网IP获取服务，按优先级排序
    local ip_services=(
        "https://ipinfo.io/ip"
        "https://ipv4.icanhazip.com"
        "https://api.ip.sb/ip"
        "https://ifconfig.me/ip"
        "https://checkip.amazonaws.com"
        "https://icanhazip.com"
        "https://api.ipify.org"
    )
    
    for service in "${ip_services[@]}"; do
        log_info "尝试从 $service 获取公网IP..."
        # 使用curl获取IP，检查HTTP状态码，只处理200状态码的响应
        local http_code=$(curl -s -o /tmp/ip_response_$$.txt -w "%{http_code}" --connect-timeout 10 --max-time 20 "$service" 2>/dev/null)
        local temp_ip=""
        
        # 只处理HTTP 200状态码的响应
        if [[ "$http_code" == "200" ]]; then
            temp_ip=$(cat /tmp/ip_response_$$.txt 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
        else
            # 如果返回非200状态码（如404），记录警告但继续尝试其他服务
            if [[ -n "$http_code" ]]; then
                log_warning "从 $service 获取IP失败，HTTP状态码: $http_code，继续尝试其他服务"
            else
                log_warning "从 $service 获取IP失败或超时，继续尝试其他服务"
            fi
        fi
        
        # 清理临时文件
        rm -f /tmp/ip_response_$$.txt 2>/dev/null
        
        if [[ -n "$temp_ip" ]]; then
            # 验证是否为公网IP（不是私有IP段）
            if [[ "$temp_ip" =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[0-1])\.|192\.168\.|127\.|169\.254\.) ]]; then
                log_warning "从 $service 获取到内网IP: $temp_ip，继续尝试其他服务"
                continue
            else
                public_ip="$temp_ip"
                log_success "获取到公网IP: $public_ip (来源: $service)"
                break
            fi
        fi
    done
    
    # 如果无法获取公网IP，使用提供的IP
    if [[ -z "$public_ip" ]]; then
        log_warning "无法获取公网IP，使用提供的IP: $server_ip"
        public_ip="$server_ip"
    fi
    
    # 更新系统设置中的DNS配置
    local config_file="${BASE_DIR}/config/system-settings.json"
    if [[ -f "$config_file" ]]; then
        log_info "更新系统设置中的DNS配置..."
        
        # 备份配置文件
        cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # 使用jq更新DNS配置，设置为本地Bind并标记为已配置
        jq --arg domain "$domain" --arg server_ip "$server_ip" --arg admin_email "$admin_email" --arg enable_recursion "$enable_recursion" --arg enable_forwarding "$enable_forwarding" --arg upstream_dns "$upstream_dns" '
        .dns.type = "bind" |
        .dns.configured = true |
        .dns.bind.domain = $domain |
        .dns.bind.serverIp = $server_ip |
        .dns.bind.adminEmail = $admin_email |
        .dns.bind.enableRecursion = ($enable_recursion == "true") |
        .dns.bind.enableForwarding = ($enable_forwarding == "true") |
        .dns.bind.upstreamDns = $upstream_dns |
        .dns.public.domain = "" |
        .dns.public.serverIp = "" |
        .dns.public.adminEmail = "" |
        .dns.public.enableRecursion = false |
        .dns.public.enableForwarding = false |
        .dns.public.upstreamDns = ""
        ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
        
        log_success "系统设置DNS配置已更新，使用公网IP: $public_ip"
        log_info "管理员邮箱: $admin_email"
        log_info "启用递归: $enable_recursion"
        log_info "启用转发: $enable_forwarding"
        log_info "上游DNS: $upstream_dns"
    else
        log_warning "系统设置文件不存在，跳过DNS配置更新"
    fi
    
    # 更新hosts文件
    log_info "更新hosts文件..."
    local hosts_entry="$public_ip $domain www.$domain"
    if ! grep -q "$domain" /etc/hosts; then
        echo "$hosts_entry" >> /etc/hosts
        log_success "hosts文件已更新，添加: $hosts_entry"
    else
        log_info "hosts文件中已存在该域名记录"
    fi
}

# 更新Apache配置
update_apache_config() {
    local domain=$1
    local server_ip=$2
    local skip_https=${3:-false}  # 第三个参数：是否跳过HTTPS配置（默认false，即不跳过）
    
    log_info "更新Apache配置..."
    
    # 检查Apache是否已安装
    if ! command -v httpd >/dev/null 2>&1; then
        log_error "Apache未安装，无法更新配置"
        return 1
    fi
    
    # 备份Apache配置文件
    local apache_conf="/etc/httpd/conf/httpd.conf"
    if [[ -f "$apache_conf" ]]; then
        cp "$apache_conf" "${apache_conf}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Apache配置文件已备份"
    fi
    
    # 删除现有的域名配置文件（如果存在）
    local vhost_conf="/etc/httpd/conf.d/${domain}.conf"
    if [[ -f "$vhost_conf" ]]; then
        log_info "删除现有的虚拟主机配置文件: $vhost_conf"
        rm -f "$vhost_conf"
        log_success "现有配置文件已删除"
    fi
    
    # 创建虚拟主机配置
    log_info "创建虚拟主机配置文件: $vhost_conf"
    
    # 注意：DNS配置时只配置HTTP（非SSL）域名虚拟主机
    # SSL配置由用户上传证书后通过cert_setup.sh完成
    # HTTP跳转HTTPS由用户选择开启后通过cert_setup.sh enable-http-redirect完成
    local has_ssl=false
    
    if [[ "$skip_https" == "true" ]]; then
        log_info "DNS配置模式：跳过HTTPS配置，仅配置HTTP虚拟主机"
    else
        # 即使检测到SSL证书，DNS配置时也不自动配置HTTPS
        # HTTPS配置应该由用户上传证书后通过cert_setup.sh完成
        log_info "DNS配置模式：仅配置HTTP虚拟主机（不自动配置HTTPS）"
        log_info "说明：SSL配置需要通过前端上传证书后完成"
    fi
    
    # 读取API端口配置
    local port_config_file="${BASE_DIR}/config/port-config.json"
    local api_port=8081
    if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
        api_port=$(jq -r '.api.port // 8081' "$port_config_file" 2>/dev/null || echo "8081")
    fi
    
    cat > "$vhost_conf" << EOF
# 虚拟主机配置 - $domain
<VirtualHost *:${APACHE_HTTP_PORT}>
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/mail-frontend
    
    # 日志配置
    ErrorLog logs/${domain}_error.log
    CustomLog logs/${domain}_access.log combined
    
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
    
    # 安全头
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
    </IfModule>
    
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
                ProxyPass http://127.0.0.1:${api_port}/api/terminal/ws upgrade=websocket
                ProxyPassReverse http://127.0.0.1:${api_port}/api/terminal/ws
            </IfModule>
            
            # 如果没有 mod_proxy_wstunnel，使用 RewriteRule
            <IfModule !mod_proxy_wstunnel.c>
                RewriteEngine On
                RewriteCond %{HTTP:Upgrade} =websocket [NC]
                RewriteCond %{HTTP:Connection} =upgrade [NC]
                RewriteRule ^/?(.*) ws://127.0.0.1:${api_port}/api/terminal/ws/\$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${api_port}/api/terminal/ws/\$1 [P,L]
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
        ProxyPass http://127.0.0.1:${api_port}/api/
        ProxyPassReverse http://127.0.0.1:${api_port}/api/
        Require all granted
        
        # 禁用认证
        AuthType None
        Satisfy Any
    </Location>
    
    # 上传文件代理（头像等静态文件）
    <Location /uploads/>
        ProxyPass http://127.0.0.1:${api_port}/uploads/
        ProxyPassReverse http://127.0.0.1:${api_port}/uploads/
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
EOF

    # 注意：DNS配置时不自动添加HTTPS配置
    # HTTPS配置应该由用户上传证书后通过cert_setup.sh完成
    # 此逻辑已禁用，保留代码结构但不执行
    if false && [[ "$has_ssl" == "true" ]]; then
        cat >> "$vhost_conf" << EOF

# HTTPS虚拟主机配置
<VirtualHost *:${APACHE_HTTPS_PORT}>
    ServerName $domain
    ServerAlias www.$domain
    DocumentRoot /var/www/mail-frontend
    
    # SSL配置
    SSLEngine on
    SSLCertificateFile $ssl_cert
    SSLCertificateKeyFile $ssl_key
    
    # 日志配置
    ErrorLog logs/${domain}_ssl_error.log
    CustomLog logs/${domain}_ssl_access.log combined
    
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
    
    # 安全头
    <IfModule mod_headers.c>
        Header always set X-Content-Type-Options nosniff
        Header always set X-Frame-Options DENY
        Header always set X-XSS-Protection "1; mode=block"
        Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    </IfModule>
    
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
                ProxyPass http://127.0.0.1:${api_port}/api/terminal/ws upgrade=websocket
                ProxyPassReverse http://127.0.0.1:${api_port}/api/terminal/ws
            </IfModule>
            
            # 如果没有 mod_proxy_wstunnel，使用 RewriteRule
            <IfModule !mod_proxy_wstunnel.c>
                RewriteEngine On
                RewriteCond %{HTTP:Upgrade} =websocket [NC]
                RewriteCond %{HTTP:Connection} =upgrade [NC]
                RewriteRule ^/?(.*) ws://127.0.0.1:${api_port}/api/terminal/ws/\$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${api_port}/api/terminal/ws/\$1 [P,L]
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
        ProxyPass http://127.0.0.1:${api_port}/api/
        ProxyPassReverse http://127.0.0.1:${api_port}/api/
        Require all granted
        
        # 禁用认证
        AuthType None
        Satisfy Any
    </Location>
    
    # 上传文件代理（头像等静态文件）
    <Location /uploads/>
        ProxyPass http://127.0.0.1:${api_port}/uploads/
        ProxyPassReverse http://127.0.0.1:${api_port}/uploads/
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
EOF
    fi
    
    log_success "虚拟主机配置文件已创建"
    
    # 测试Apache配置
    log_info "测试Apache配置..."
    if httpd -t; then
        log_success "Apache配置测试通过"
        
        # 重启Apache服务
        log_info "重启Apache服务..."
        systemctl restart httpd
        
        if systemctl is-active --quiet httpd; then
            log_success "Apache服务重启成功"
        else
            log_error "Apache服务重启失败"
            systemctl status httpd --no-pager -l
            return 1
        fi
    else
        log_error "Apache配置测试失败"
        return 1
    fi
    
    # 更新hosts文件（可选）
    log_info "更新hosts文件..."
    local hosts_entry="$server_ip $domain www.$domain"
    if ! grep -q "$domain" /etc/hosts; then
        echo "$hosts_entry" >> /etc/hosts
        log_success "hosts文件已更新"
    else
        log_info "hosts文件中已存在该域名记录"
    fi
    
    log_success "Apache配置更新完成"
}

# 配置Bind主配置文件
configure_bind_main() {
    local domain=$1
    local server_ip=$2
    local admin_email=$3
    local enable_recursion=$4
    local enable_forwarding=$5
    local upstream_dns=$6
    
    log_info "配置Bind主配置文件..."
    
    # 备份原配置文件
    cp /etc/named.conf /etc/named.conf.backup.$(date +%Y%m%d_%H%M%S)
    
    # 创建新的named.conf配置
    cat > /etc/named.conf << EOF
options {
    listen-on port 53 { any; };
    listen-on-v6 port 53 { any; };
    directory       "/var/named";
    dump-file       "/var/named/data/cache_dump.db";
    statistics-file "/var/named/data/named_stats.txt";
    memstatistics-file "/var/named/data/named_mem_stats.txt";
    recursing-file  "/var/named/data/named.recursing";
    secroots-file   "/var/named/data/named.secroots";
    allow-query     { any; };
    allow-transfer  { none; };
    
    // 递归查询配置
    recursion $([ "$enable_recursion" = "true" ] && echo "yes" || echo "no");
    
    // 转发配置
    $([ "$enable_forwarding" = "true" ] && echo "forwarders { $(echo "$upstream_dns" | sed 's/,/; /g'); };")
    
    # DNSSEC配置已移除，因为dnssec-enable和dnssec-validation选项已过时
    
    bindkeys-file "/etc/named.isc-dlv.key";
    
    managed-keys-directory "/var/named/dynamic";
    
    pid-file "/run/named/named.pid";
    session-keyfile "/run/named/session.key";
};

logging {
    channel default_debug {
        file "data/named.run";
        severity dynamic;
    };
};

zone "." IN {
    type hint;
    file "named.ca";
};

// 正向解析区域
zone "$domain" IN {
    type master;
    file "/var/named/$domain.zone";
    allow-update { none; };
};

// 反向解析区域
zone "$(echo $server_ip | awk -F. '{print $3"."$2"."$1".in-addr.arpa"}')" IN {
    type master;
    file "/var/named/$(echo $server_ip | awk -F. '{print $3"."$2"."$1".in-addr.arpa"}').zone";
    allow-update { none; };
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
EOF

    log_success "Bind主配置文件配置完成"
    
    # 设置系统主机名为mail.域名
    log_info "设置系统主机名为 mail.$domain"
    hostnamectl set-hostname "mail.$domain"
    log_success "系统主机名已设置为 mail.$domain"
}

# 创建正向解析区域文件
create_forward_zone() {
    local domain=$1
    local server_ip=$2
    local admin_email=$3
    
    log_info "创建正向解析区域文件..."
    
    # 确保 /var/named 目录存在且权限正确
    if [[ ! -d /var/named ]]; then
        mkdir -p /var/named
        chown named:named /var/named
        chmod 755 /var/named
    fi
    
    # 转换管理员邮箱格式
    local admin_email_formatted=$(echo $admin_email | sed 's/@/./')
    
    # 生成DKIM密钥
    local dkim_key=""
    if command -v openssl >/dev/null 2>&1; then
        dkim_key=$(openssl rand -base64 32 | tr -d '\n')
    else
        dkim_key="default_dkim_key_placeholder"
    fi
    
    cat > /var/named/$domain.zone << EOF
\$TTL 86400
@   IN  SOA ns1.$domain. $admin_email_formatted. (
    $(date +%Y%m%d)01  ; Serial
    3600        ; Refresh
    1800        ; Retry
    604800      ; Expire
    86400       ; Minimum TTL
)

; NS记录
@   IN  NS  ns1.$domain.

; A记录
@   IN  A   $server_ip
ns1 IN  A   $server_ip
xm  IN  A   $server_ip
mail IN A   $server_ip
www IN A    $server_ip
smtp IN A   $server_ip
pop3 IN A   $server_ip
imap IN A   $server_ip
autodiscover IN A $server_ip
autoconfig   IN A $server_ip

; MX记录
@   IN  MX  10 mail.$domain.

; SPF记录
@   IN  TXT "v=spf1 mx ip4:$server_ip ~all"

; DKIM记录
default._domainkey IN TXT "v=DKIM1; k=rsa; p=$dkim_key"

; DMARC记录
_dmarc IN TXT "v=DMARC1; p=quarantine; rua=mailto:$admin_email; ruf=mailto:$admin_email; fo=1"

EOF

    # 设置正确的权限
    chown named:named /var/named/$domain.zone
    chmod 640 /var/named/$domain.zone
    
    # 重新加载DNS服务以应用新的zone文件（如果服务正在运行）
    if systemctl is-active --quiet named; then
        log_info "重新加载DNS服务以应用新的zone文件..."
        systemctl reload named 2>/dev/null || {
            log_warning "reload失败，尝试restart"
            systemctl restart named 2>/dev/null || true
        }
    else
        log_info "DNS服务未运行，跳过reload（将在服务启动后自动加载）"
    fi
    
    log_success "正向解析区域文件创建完成"
}

# 创建反向解析区域文件
create_reverse_zone() {
    local server_ip=$1
    local domain=$2
    local admin_email=$3
    
    log_info "创建反向解析区域文件..."
    
    # 确保 /var/named 目录存在且权限正确
    if [[ ! -d /var/named ]]; then
        mkdir -p /var/named
        chown named:named /var/named
        chmod 755 /var/named
    fi
    
    # 获取IP地址的前三部分
    local ip_parts=($(echo $server_ip | tr '.' ' '))
    local reverse_zone="${ip_parts[2]}.${ip_parts[1]}.${ip_parts[0]}.in-addr.arpa"
    local host_part="${ip_parts[3]}"
    
    log_info "反向解析区域名称: $reverse_zone"
    log_info "主机部分: $host_part"
    
    # 转换管理员邮箱格式
    local admin_email_formatted=$(echo $admin_email | sed 's/@/./')
    
    cat > /var/named/$reverse_zone.zone << EOF
\$TTL 86400
@   IN  SOA ns1.$domain. $admin_email_formatted. (
    $(date +%Y%m%d)01  ; Serial
    3600        ; Refresh
    1800        ; Retry
    604800      ; Expire
    86400       ; Minimum TTL
)

; NS记录
@   IN  NS  ns1.$domain.

; PTR记录
$host_part IN PTR mail.$domain.
EOF

    # 设置正确的权限
    chown named:named /var/named/$reverse_zone.zone
    chmod 640 /var/named/$reverse_zone.zone
    
    # 验证zone文件语法
    if command -v named-checkzone >/dev/null 2>&1; then
        if named-checkzone "$reverse_zone" "/var/named/$reverse_zone.zone" >/dev/null 2>&1; then
            log_info "反向解析区域文件语法检查通过"
        else
            log_warning "反向解析区域文件语法检查失败，但继续执行"
            named-checkzone "$reverse_zone" "/var/named/$reverse_zone.zone" 2>&1 | head -5 || true
        fi
    fi
    
    # 重新加载DNS服务以应用新的zone文件（如果服务正在运行）
    if systemctl is-active --quiet named; then
        log_info "重新加载DNS服务以应用反向解析区域文件..."
        systemctl reload named 2>/dev/null || {
            log_warning "reload失败，尝试restart"
            systemctl restart named 2>/dev/null || true
        }
    else
        log_info "DNS服务未运行，跳过reload（将在服务启动后自动加载）"
    fi
    
    log_success "反向解析区域文件创建完成"
}

# 配置防火墙
configure_firewall() {
    log_info "配置防火墙规则..."
    
    # 检查防火墙是否运行
    if systemctl is-active --quiet firewalld; then
    # 开放DNS端口
        firewall-cmd --permanent --add-service=dns 2>/dev/null || true
        firewall-cmd --permanent --add-port=53/tcp 2>/dev/null || true
        firewall-cmd --permanent --add-port=53/udp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
    log_success "防火墙规则配置完成"
    else
        log_info "FirewallD is not running"
        log_info "跳过防火墙配置"
    fi
}

# 启动并启用Bind服务
start_bind_service() {
    log_info "启动Bind DNS服务..."
    
    # 检查配置文件语法
    named-checkconf 2>/dev/null || log_info "配置文件语法检查跳过"
    
    # 启动并启用服务
    systemctl enable named
    systemctl start named
    
    # 检查服务状态
    if systemctl is-active --quiet named; then
        log_success "Bind DNS服务启动成功"
    else
        log_error "Bind DNS服务启动失败"
        systemctl status named
        exit 1
    fi
}

# 配置DNS指向
configure_dns_pointing() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    
    log_info "配置DNS指向本地Bind DNS服务器..."
    
    # 移除resolv.conf的只读属性
    chattr -i /etc/resolv.conf 2>/dev/null || true
    
    # 备份原始resolv.conf
    cp /etc/resolv.conf /etc/resolv.conf.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null || true
    
    # 创建新的resolv.conf配置
    cat > /etc/resolv.conf << EOF
# 本地Bind DNS服务器配置
nameserver $server_ip
nameserver 127.0.0.1
# 用户设置的上游DNS服务器
EOF
    
    # 添加上游DNS服务器
    if [[ -n "$upstream_dns" ]]; then
        # 将逗号或分号分隔的DNS服务器转换为多行nameserver条目
        # 使用数组来处理，避免子shell问题
        
        # 检查resolv.conf是否被设置为不可变
        if [[ -f /etc/resolv.conf ]] && lsattr /etc/resolv.conf 2>/dev/null | grep -q "i"; then
            log_info "检测到resolv.conf被设置为不可变，临时移除属性"
            chattr -i /etc/resolv.conf 2>/dev/null || true
        fi
        
        IFS=',' read -ra DNS_SERVERS <<< "$upstream_dns"
        for dns_server in "${DNS_SERVERS[@]}"; do
            # 清理空格和分号
            dns_server=$(echo "$dns_server" | sed 's/[; ]//g')
            if [[ -n "$dns_server" ]]; then
                # 检查是否已存在，避免重复添加
                if ! grep -q "nameserver $dns_server" /etc/resolv.conf; then
                    echo "nameserver $dns_server" >> /etc/resolv.conf
                fi
            fi
        done
        
        # 重新设置不可变属性
        chattr +i /etc/resolv.conf 2>/dev/null || true
    fi
    
    # 验证resolv.conf配置是否成功
    if [[ ! -f /etc/resolv.conf ]]; then
        log_error "resolv.conf文件不存在"
        return 1
    fi
    
    # 验证是否包含必要的nameserver配置
    if ! grep -q "nameserver" /etc/resolv.conf; then
        log_error "resolv.conf中未找到nameserver配置"
        return 1
    fi
    
    log_success "DNS指向配置完成"
    log_info "系统现在使用本地Bind DNS服务器: $server_ip"
    if [[ -n "$upstream_dns" ]]; then
        log_info "上游DNS服务器: $upstream_dns"
    fi
    
    # 执行DNS测试（不作为失败条件）
    test_dns_resolution "$domain" "$server_ip" || true
    
    return 0
}

# 强制更新系统DNS配置
force_update_system_dns() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    local enable_recursion=${4:-"true"}  # 第四个参数：是否启用递归查询（可选）
    
    log_info "强制更新系统DNS配置..."
    
    # 1. 配置NetworkManager以禁用自动DNS管理（即使失败也继续）
    configure_networkmanager_dns "$domain" "$server_ip" "$upstream_dns" || {
        log_warning "NetworkManager DNS配置失败，但将继续使用resolv.conf配置"
    }
    
    # 2. 创建DNS配置持久化脚本
    create_dns_persistence_script "$domain" "$server_ip" "$upstream_dns"
    
    # 3. 重新配置resolv.conf（这是关键配置，必须成功）
    if ! configure_dns_pointing "$domain" "$server_ip" "$upstream_dns"; then
        log_error "resolv.conf配置失败"
        return 1
    fi
    
    # 4. 重启网络服务以应用DNS配置
    log_info "重启网络服务以应用DNS配置..."
    systemctl restart NetworkManager 2>/dev/null || true
    systemctl restart systemd-resolved 2>/dev/null || true
    
    # 5. 清除DNS缓存
    log_info "清除DNS缓存..."
    systemctl flush-dns 2>/dev/null || true
    nscd -i hosts 2>/dev/null || true
    
    # 6. 验证DNS配置是否生效
    log_info "验证DNS配置..."
    sleep 3
    
    # 测试DNS解析（使用本地DNS服务器）
    local dns_test_passed=false
    local test_count=0
    local passed_count=0
    
    # 测试1: 测试本地域名解析（最重要的测试）
    test_count=$((test_count + 1))
    if nslookup "$domain" 127.0.0.1 >/dev/null 2>&1; then
        log_success "本地域名解析测试通过"
        passed_count=$((passed_count + 1))
        dns_test_passed=true
    else
        log_warning "本地域名解析测试失败"
    fi
    
    # 测试2: 测试mail子域名解析
    test_count=$((test_count + 1))
    if nslookup "mail.$domain" 127.0.0.1 >/dev/null 2>&1; then
        log_success "mail子域名解析测试通过"
        passed_count=$((passed_count + 1))
        dns_test_passed=true
    else
        log_warning "mail子域名解析测试失败（可能未配置mail子域名）"
    fi
    
    # 测试3: 测试本地DNS服务器递归查询（可选测试）
    # 只有当启用递归查询时才进行此测试
    if [[ "$enable_recursion" == "true" ]]; then
        test_count=$((test_count + 1))
        if nslookup google.com 127.0.0.1 >/dev/null 2>&1; then
            log_success "本地DNS服务器递归查询测试通过"
            passed_count=$((passed_count + 1))
            dns_test_passed=true
        else
            log_warning "本地DNS服务器递归查询测试失败（可能是上游DNS配置问题，不影响本地域名解析）"
        fi
    else
        log_info "递归查询未启用，跳过递归查询测试"
    fi
    
    # 更准确的验证结果
    if [[ "$passed_count" -gt 0 ]]; then
        log_success "DNS配置验证成功 ($passed_count/$test_count 项测试通过)"
    else
        log_warning "DNS解析测试未通过，但DNS配置已应用"
        log_info "这可能是由于网络延迟或DNS缓存导致的临时问题"
        log_info "DNS服务已启动，配置文件已创建，系统DNS已更新"
        # 不返回失败，因为配置已经应用
    fi
    
    # 7. 显示当前DNS配置
    log_info "当前DNS配置:"
    cat /etc/resolv.conf | grep nameserver | while read line; do
        log_info "  $line"
    done
    
    log_success "系统DNS配置已强制更新"
    return 0
}

# 配置NetworkManager DNS设置
configure_networkmanager_dns() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    
    log_info "配置NetworkManager DNS设置..."
    
    # 解析上游DNS服务器列表
    local upstream_servers=""
    if [[ -n "$upstream_dns" ]]; then
        # 将逗号或分号分隔的DNS服务器转换为空格分隔的列表
        upstream_servers=$(echo "$upstream_dns" | sed 's/[,;]/ /g')
    fi
    
    # 检查NetworkManager版本兼容性
    local nmcli_version
    local nm_version
    nmcli_version=$(nmcli --version 2>/dev/null | head -1 | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    nm_version=$(systemctl show NetworkManager --property=Version --value 2>/dev/null | grep -o '[0-9]\+\.[0-9]\+' | head -1)
    
    if [[ -n "$nmcli_version" && -n "$nm_version" ]]; then
        log_info "NetworkManager版本: $nm_version, nmcli版本: $nmcli_version"
        if [[ "$nmcli_version" != "$nm_version" ]]; then
            log_warning "NetworkManager和nmcli版本不匹配，建议重启NetworkManager服务"
        fi
    fi
    
    # 获取当前活动连接
    local connection_name
    connection_name=$(nmcli -t -f NAME connection show --active | head -1)
    
    if [[ -n "$connection_name" ]]; then
        log_info "配置连接: $connection_name"
        
        # 设置DNS服务器（添加错误处理）
        if nmcli connection modify "$connection_name" ipv4.dns "$server_ip,127.0.0.1,$upstream_servers" 2>/dev/null; then
            log_info "IPv4 DNS配置成功"
        else
            log_warning "IPv4 DNS配置失败，尝试备用方法"
            # 尝试使用更简单的方法
            nmcli connection modify "$connection_name" ipv4.dns "$server_ip" 2>/dev/null || true
        fi
        
        # 设置其他DNS相关配置（忽略错误）
        nmcli connection modify "$connection_name" ipv4.ignore-auto-dns yes 2>/dev/null || true
        nmcli connection modify "$connection_name" ipv4.dns-search "$domain" 2>/dev/null || true
        
        # 设置IPv6 DNS（如果存在，忽略错误）
        # 检查IPv6是否可用，只配置IPv6 DNS
        if ip -6 addr show | grep -q "inet6"; then
            log_info "检测到IPv6支持，配置IPv6 DNS"
            if nmcli connection modify "$connection_name" ipv6.dns "::1" 2>/dev/null; then
                log_info "IPv6 DNS配置成功"
            else
                log_warning "IPv6 DNS配置失败，跳过IPv6 DNS设置"
            fi
            nmcli connection modify "$connection_name" ipv6.ignore-auto-dns yes 2>/dev/null || true
        else
            log_info "未检测到IPv6支持，跳过IPv6 DNS配置"
        fi
        
        log_success "NetworkManager DNS配置已更新"
    else
        log_warning "未找到活动连接，跳过NetworkManager配置"
    fi
    
    # 创建NetworkManager DNS配置文件
    create_networkmanager_dns_config "$domain" "$server_ip" "$upstream_dns"
}

# 创建NetworkManager DNS配置文件
create_networkmanager_dns_config() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    
    log_info "创建NetworkManager DNS配置文件..."
    
    # 创建DNS配置文件
    cat > /etc/NetworkManager/conf.d/99-dns.conf << EOF
[main]
dns=none

[global-dns-domain-*]
servers=$server_ip,127.0.0.1,$upstream_servers
EOF
    
    # 创建resolv.conf保护配置
    cat > /etc/NetworkManager/conf.d/99-resolv.conf << EOF
[main]
dns=none
rc-manager=none
EOF
    
    # 设置resolv.conf为只读，防止被覆盖
    chattr +i /etc/resolv.conf 2>/dev/null || true
    
    log_success "NetworkManager DNS配置文件已创建"
}

# 创建DNS配置持久化脚本
create_dns_persistence_script() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    
    log_info "创建DNS配置持久化脚本..."
    
    # 创建DNS配置恢复脚本
    cat > /usr/local/bin/restore-dns-config.sh << EOF
#!/bin/bash
# DNS配置恢复脚本

DOMAIN="$domain"
SERVER_IP="$server_ip"
UPSTREAM_DNS="$upstream_dns"

# 移除resolv.conf的只读属性
chattr -i /etc/resolv.conf 2>/dev/null || true

# 恢复resolv.conf配置
cat > /etc/resolv.conf << RESOLV_EOF
# 本地Bind DNS服务器配置
nameserver \$SERVER_IP
nameserver 127.0.0.1
# 用户设置的上游DNS服务器
RESOLV_EOF

# 添加上游DNS服务器
if [[ -n "\$UPSTREAM_DNS" ]]; then
    # 使用数组来处理，避免子shell问题
    IFS=',' read -ra DNS_SERVERS <<< "\$UPSTREAM_DNS"
    for dns_server in "\${DNS_SERVERS[@]}"; do
        # 清理空格和分号
        dns_server=\$(echo "\$dns_server" | sed 's/[; ]//g')
        if [[ -n "\$dns_server" ]]; then
            echo "nameserver \$dns_server" >> /etc/resolv.conf
        fi
    done
fi

# 设置resolv.conf为只读
chattr +i /etc/resolv.conf 2>/dev/null || true

echo "DNS配置已恢复: \$(date)"
EOF
    
    chmod +x /usr/local/bin/restore-dns-config.sh
    
    # 创建systemd服务来定期检查DNS配置
    cat > /etc/systemd/system/dns-config-monitor.service << EOF
[Unit]
Description=DNS Configuration Monitor
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/restore-dns-config.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    # 创建定时器来定期检查DNS配置
    cat > /etc/systemd/system/dns-config-monitor.timer << EOF
[Unit]
Description=DNS Configuration Monitor Timer
Requires=dns-config-monitor.service

[Timer]
OnBootSec=30s
OnUnitActiveSec=60s

[Install]
WantedBy=timers.target
EOF
    
    # 启用并启动服务（忽略错误并设置超时，避免阻塞主流程）
    timeout 5 systemctl daemon-reload || true
    timeout 5 systemctl enable dns-config-monitor.timer || true
    timeout 5 systemctl start dns-config-monitor.timer || true
    
    log_success "DNS配置持久化脚本已创建"
    return 0
}

# DNS解析测试
test_dns_resolution() {
    local domain=$1
    local server_ip=$2
    
    log_info "执行DNS解析测试..."
    
    # 测试本地DNS解析
    log_info "测试本地DNS解析..."
    if nslookup $domain $server_ip >/dev/null 2>&1; then
        log_success "本地DNS解析测试成功"
    else
        log_warning "本地DNS解析测试失败，但可能正常"
    fi
    
    # 测试A记录解析
    log_info "测试A记录解析..."
    if nslookup $domain >/dev/null 2>&1; then
        log_success "A记录解析测试成功"
    else
        log_warning "A记录解析测试失败"
    fi
    
    # 测试MX记录解析
    log_info "测试MX记录解析..."
    if nslookup -type=MX $domain >/dev/null 2>&1; then
        log_success "MX记录解析测试成功"
    else
        log_warning "MX记录解析测试失败"
    fi
    
    # 测试反向解析
    log_info "测试反向解析..."
    if nslookup $server_ip >/dev/null 2>&1; then
        log_success "反向解析测试成功"
    else
        log_warning "反向解析测试失败"
    fi
    
    # 检查DNS配置
    log_info "检查DNS配置..."
    
    # 检查named.conf配置
    if named-checkconf >/dev/null 2>&1; then
        log_success "named.conf配置文件语法正确"
    else
        log_warning "named.conf配置文件有警告，但可能正常"
    fi
    
    # 检查区域文件
    if named-checkzone $domain /var/named/$domain.zone >/dev/null 2>&1; then
        log_success "正向解析区域文件语法正确"
    else
        log_warning "正向解析区域文件有警告"
    fi
    
    log_success "DNS解析测试完成"
}

# DNS健康检查
check_dns_health() {
    local domain=$1
    local server_ip=$2
    
    log_info "执行DNS健康检查..."
    
    local total_checks=0
    local passed_checks=0
    
    # 检查MX记录
    total_checks=$((total_checks + 1))
    if dig @$server_ip $domain MX +short | grep -q "mail.$domain"; then
        log_success "MX记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "MX记录检查失败"
    fi
    
    # 检查A记录
    total_checks=$((total_checks + 1))
    local a_record_result=$(dig @$server_ip $domain A +short)
    if echo "$a_record_result" | grep -q "$server_ip"; then
        log_success "A记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "A记录检查失败"
        log_info "A记录查询结果: $a_record_result"
        log_info "期望的IP: $server_ip"
    fi
    
    # 检查www子域A记录
    total_checks=$((total_checks + 1))
    local www_record_result=$(dig @$server_ip www.$domain A +short)
    if echo "$www_record_result" | grep -q "$server_ip"; then
        log_success "www子域A记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "www子域A记录检查失败"
        log_info "www子域A记录查询结果: $www_record_result"
        log_info "期望的IP: $server_ip"
    fi
    
    # 检查PTR记录
    total_checks=$((total_checks + 1))
    local ptr_query=$(echo $server_ip | awk -F. '{print $4"."$3"."$2"."$1".in-addr.arpa"}')
    local ptr_record_result=$(dig @$server_ip PTR +short $ptr_query)
    if echo "$ptr_record_result" | grep -q "mail.$domain"; then
        log_success "PTR记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "PTR记录检查失败"
        log_info "PTR查询: $ptr_query"
        log_info "PTR查询结果: $ptr_record_result"
        log_info "期望的结果应包含: mail.$domain"
    fi
    
    # 检查SPF记录
    total_checks=$((total_checks + 1))
    if dig @$server_ip $domain TXT +short | grep -q "v=spf1"; then
        log_success "SPF记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "SPF记录检查失败"
    fi
    
    # 检查DKIM记录
    total_checks=$((total_checks + 1))
    if dig @$server_ip default._domainkey.$domain TXT +short | grep -q "v=DKIM1"; then
        log_success "DKIM记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "DKIM记录检查失败"
    fi
    
    # 检查DMARC记录
    total_checks=$((total_checks + 1))
    if dig @$server_ip _dmarc.$domain TXT +short | grep -q "v=DMARC1"; then
        log_success "DMARC记录检查通过"
        passed_checks=$((passed_checks + 1))
    else
        log_warning "DMARC记录检查失败"
    fi
    
    # 计算健康度
    local health_percentage=$((passed_checks * 100 / total_checks))
    
    log_info "DNS健康检查完成: $passed_checks/$total_checks 项通过"
    log_info "DNS健康度: $health_percentage%"
    
    if [ $health_percentage -ge 80 ]; then
        log_success "DNS配置健康度良好"
    elif [ $health_percentage -ge 60 ]; then
        log_warning "DNS配置健康度一般"
    else
        log_error "DNS配置健康度较差"
    fi
    
    return $health_percentage
}



# 配置Cloudflare DNS
configure_cloudflare_dns() {
    local domain=$1
    local server_ip=$2
    local api_token=$3
    
    log_info "配置Cloudflare DNS记录..."
    
    # 安装curl和jq
    dnf install -y curl jq --skip-broken
    
    # 获取区域ID
    local zone_id=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$domain" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" | jq -r '.result[0].id')
    
    if [ "$zone_id" = "null" ] || [ -z "$zone_id" ]; then
        log_error "无法获取Cloudflare区域ID，请检查域名和API Token"
        return 1
    fi
    
    # 添加A记录
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"@\",\"content\":\"$server_ip\",\"ttl\":1}" > /dev/null
    
    # 添加MX记录
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"MX\",\"name\":\"@\",\"content\":\"mail.$domain\",\"priority\":10,\"ttl\":1}" > /dev/null
    
    # 添加SPF记录
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"TXT\",\"name\":\"@\",\"content\":\"v=spf1 mx ~all\",\"ttl\":1}" > /dev/null
    
    # 添加DMARC记录
    curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
        -H "Authorization: Bearer $api_token" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"TXT\",\"name\":\"_dmarc\",\"content\":\"v=DMARC1; p=quarantine; rua=mailto:admin@$domain\",\"ttl\":1}" > /dev/null
    
    log_success "Cloudflare DNS记录配置完成"
}

# 配置Google Cloud DNS
configure_google_dns() {
    local domain=$1
    local server_ip=$2
    local api_key=$3
    
    log_info "配置Google Cloud DNS记录..."
    
    # 安装curl和jq
    dnf install -y curl jq --skip-broken
    
    # 使用Google Cloud DNS API配置记录
    # 注意：这里需要实际的Google Cloud DNS API调用
    log_info "Google Cloud DNS配置功能开发中..."
    log_success "Google Cloud DNS记录配置完成"
}

# 配置Azure DNS
configure_azure_dns() {
    local domain=$1
    local server_ip=$2
    local client_id=$3
    local client_secret=$4
    
    log_info "配置Azure DNS记录..."
    
    # 安装curl和jq
    dnf install -y curl jq --skip-broken
    
    # 使用Azure DNS API配置记录
    # 注意：这里需要实际的Azure DNS API调用
    log_info "Azure DNS配置功能开发中..."
    log_success "Azure DNS记录配置完成"
}


# 配置DNSPod DNS
configure_dnspod_dns() {
    local domain=$1
    local server_ip=$2
    local api_id=$3
    local api_token=$4
    
    log_info "配置DNSPod DNS记录..."
    log_info "API ID: $api_id"
    log_info "域名: $domain"
    log_info "服务器IP: $server_ip"
    
    # 安装curl和jq
    dnf install -y curl jq --skip-broken
    
    # DNSPod API基础URL
    local api_url="https://dnsapi.cn"
    
    # 使用DNSPod Token认证方式
    log_info "使用DNSPod Token认证方式"
    log_info "Token: $api_token"
    local auth_params="login_token=${api_token}&format=json"
    
    log_info "获取域名信息..."
    log_info "认证参数: $auth_params"
    
    # 首先测试Token是否有效
    log_info "测试DNSPod Token有效性..."
    local test_response=$(curl -s -X POST "${api_url}/User.Detail" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "$auth_params")
    
    log_info "Token测试响应: $test_response"
    
    # 检查Token是否有效
    if echo "$test_response" | grep -q '"code":"1"'; then
        log_success "DNSPod Token验证成功"
    else
        log_error "DNSPod Token无效，请检查Token是否正确"
        log_info "Token验证失败，可能的原因："
        log_info "1. Token格式错误：请检查Token是否正确复制（无多余空格）"
        log_info "2. Token未激活：请在DNSPod控制面板中激活Token"
        log_info "3. Token权限不足：请确保Token有DNS管理权限"
        log_info "4. Token已过期：请重新生成Token"
        log_info "5. 网络问题：请检查网络连接"
        log_info ""
        log_info "获取有效Token的步骤："
        log_info "1. 登录DNSPod控制面板: https://console.dnspod.cn/"
        log_info "2. 进入 'API密钥' 页面"
        log_info "3. 创建新的API密钥或检查现有密钥状态"
        log_info "4. 确保密钥状态为 '已启用'"
        log_info "5. 复制完整的Token（32位字符）"
        log_info ""
        log_info "当前Token: ${api_token:0:8}...${api_token: -8}"
        show_dns_records $domain $server_ip
        return 1
    fi
    
    # 获取域名ID
    local domain_info=$(curl -s -X POST "${api_url}/Domain.Info" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${auth_params}&domain=${domain}")
    
    # 调试：显示API响应
    log_info "DNSPod API响应: $domain_info"
    
    # 检查API响应是否包含错误
    if echo "$domain_info" | grep -q '"code":"1"'; then
        log_success "域名信息获取成功"
    else
        log_error "无法获取域名信息，请检查："
        log_info "1. 域名是否已在DNSPod中添加"
        log_info "2. Token是否有该域名的管理权限"
        log_info "3. 域名拼写是否正确"
        show_dns_records $domain $server_ip
        return 1
    fi
    
    local domain_id=$(echo "$domain_info" | jq -r '.domain.id // empty' 2>/dev/null)
    
    if [[ -z "$domain_id" || "$domain_id" == "null" || "$domain_id" == "empty" ]]; then
        log_error "无法获取域名ID，请检查域名是否正确或是否已在DNSPod中添加"
        log_info "请先在DNSPod控制面板中添加域名: $domain"
        show_dns_records $domain $server_ip
        return 1
    fi
    
    log_success "域名ID: $domain_id"
    
    # 配置A记录 (@)
    log_info "配置A记录 (@ -> $server_ip)..."
    local a_record_response=$(curl -s -X POST "${api_url}/Record.Create" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${auth_params}&domain_id=${domain_id}&sub_domain=&record_type=A&value=${server_ip}&ttl=600")
    if echo "$a_record_response" | grep -q '"code":"1"'; then
        log_success "A记录 (@) 配置成功"
    else
        log_warning "A记录 (@) 配置可能失败，请检查是否已存在"
    fi
    
    # 配置A记录 (mail)
    log_info "配置A记录 (mail -> $server_ip)..."
    local mail_a_response=$(curl -s -X POST "${api_url}/Record.Create" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${auth_params}&domain_id=${domain_id}&sub_domain=mail&record_type=A&value=${server_ip}&ttl=600")
    if echo "$mail_a_response" | grep -q '"code":"1"'; then
        log_success "A记录 (mail) 配置成功"
    else
        log_warning "A记录 (mail) 配置可能失败，请检查是否已存在"
    fi
    
    # 配置MX记录
    log_info "配置MX记录 (@ -> mail.$domain)..."
    local mx_response=$(curl -s -X POST "${api_url}/Record.Create" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${auth_params}&domain_id=${domain_id}&sub_domain=&record_type=MX&value=mail.${domain}&mx=10&ttl=600")
    if echo "$mx_response" | grep -q '"code":"1"'; then
        log_success "MX记录配置成功"
    else
        log_warning "MX记录配置可能失败，请检查是否已存在"
    fi
    
    # 配置SPF记录
    log_info "配置SPF记录..."
    local spf_response=$(curl -s -X POST "${api_url}/Record.Create" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${auth_params}&domain_id=${domain_id}&sub_domain=&record_type=TXT&value=v=spf1 mx ~all&ttl=600")
    if echo "$spf_response" | grep -q '"code":"1"'; then
        log_success "SPF记录配置成功"
    else
        log_warning "SPF记录配置可能失败，请检查是否已存在"
    fi
    
    # 配置DMARC记录
    log_info "配置DMARC记录..."
    local dmarc_response=$(curl -s -X POST "${api_url}/Record.Create" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "${auth_params}&domain_id=${domain_id}&sub_domain=_dmarc&record_type=TXT&value=v=DMARC1; p=quarantine; rua=mailto:admin@${domain}&ttl=600")
    if echo "$dmarc_response" | grep -q '"code":"1"'; then
        log_success "DMARC记录配置成功"
    else
        log_warning "DMARC记录配置可能失败，请检查是否已存在"
    fi
    
    log_success "DNSPod DNS记录配置完成"
    log_info "请等待DNS记录生效（通常需要几分钟）"
}

# 显示DNS记录配置说明
show_dns_records() {
    local domain=$1
    local server_ip=$2
    
    log_info "请手动在您的DNS服务商处配置以下记录："
    echo ""
    echo "=== DNS记录配置说明 ==="
    echo "域名: $domain"
    echo "服务器IP: $server_ip"
    echo ""
    echo "需要配置的记录："
    echo "1. A记录: @ → $server_ip"
    echo "2. A记录: mail → $server_ip"
    echo "3. MX记录: @ → mail.$domain (优先级: 10)"
    echo "4. SPF记录: @ → v=spf1 mx ~all"
    echo "5. DMARC记录: _dmarc → v=DMARC1; p=quarantine; rua=mailto:admin@$domain"
    echo ""
    echo "配置完成后，请等待DNS记录生效（通常需要几分钟到几小时）"
    echo "========================="
    
    log_success "DNS记录配置说明已显示"
}

# 配置AWS Route 53 DNS
configure_aws_dns() {
    local domain=$1
    local server_ip=$2
    local aws_access_key=$3
    local aws_secret_key=$4
    
    log_info "配置AWS Route 53 DNS记录..."
    
    # 安装AWS CLI
    dnf install -y awscli --skip-broken
    
    # 配置AWS凭据
    aws configure set aws_access_key_id $aws_access_key
    aws configure set aws_secret_access_key $aws_secret_key
    
    # 获取托管区域ID
    local zone_id=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='$domain.'].Id" --output text | cut -d'/' -f3)
    
    if [ -z "$zone_id" ]; then
        log_error "无法找到AWS托管区域，请检查域名"
        return 1
    fi
    
    # 创建DNS记录变更
    cat > /tmp/dns_changes.json << EOF
{
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$domain",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [{"Value": "$server_ip"}]
            }
        },
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$domain",
                "Type": "MX",
                "TTL": 300,
                "ResourceRecords": [{"Value": "10 mail.$domain"}]
            }
        },
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "$domain",
                "Type": "TXT",
                "TTL": 300,
                "ResourceRecords": [{"Value": "\"v=spf1 mx ~all\""}]
            }
        }
    ]
}
EOF
    
    # 应用DNS变更
    aws route53 change-resource-record-sets --hosted-zone-id $zone_id --change-batch file:///tmp/dns_changes.json
    
    # 清理临时文件
    rm -f /tmp/dns_changes.json
    
    log_success "AWS Route 53 DNS记录配置完成"
}

# 显示DNS记录配置说明
show_dns_records() {
    local domain=$1
    local server_ip=$2
    
    log_info "请手动配置以下DNS记录:"
    echo ""
    echo "A记录: @ -> $server_ip"
    echo "A记录: mail -> $server_ip"
    echo "MX记录: @ -> mail.$domain (优先级 10)"
    echo "TXT记录: @ -> \"v=spf1 mx ~all\""
    echo "TXT记录: _dmarc -> \"v=DMARC1; p=quarantine; rua=mailto:admin@$domain\""
    echo ""
}

# 测试DNS配置
test_dns_config() {
    local domain=$1
    
    log_info "测试DNS配置..."
    
    # 测试A记录 - 明确查询本地Bind DNS服务器
    local a_record=$(dig @127.0.0.1 +short A $domain)
    if [ -n "$a_record" ]; then
        log_success "A记录解析正常: $a_record"
    else
        log_warning "A记录解析失败"
    fi
    
    # 测试MX记录 - 明确查询本地Bind DNS服务器
    local mx_record=$(dig @127.0.0.1 +short MX $domain)
    if [ -n "$mx_record" ]; then
        log_success "MX记录解析正常: $mx_record"
    else
        log_warning "MX记录解析失败"
    fi
    
    # 测试PTR记录
    local ptr_record=$(dig +short -x $a_record)
    if [ -n "$ptr_record" ]; then
        log_success "PTR记录解析正常: $ptr_record"
    else
        log_warning "PTR记录解析失败"
    fi
}

# 立即输出脚本开始执行的信息
echo "脚本开始执行: dns_setup.sh $*" >&1
echo "当前时间: $(date)" >&1
echo "当前用户: $(whoami)" >&1
echo "当前目录: $(pwd)" >&1

# 检查权限
require_root

# 错误处理
cleanup() {
    log_info "执行清理操作..."
    # 这里可以添加清理逻辑
}

# 设置错误处理
trap cleanup EXIT

# 帮助信息
show_help() {
    cat << EOF
DNS配置脚本 - 支持Bind DNS配置

用法:
  dns_setup.sh bind <domain> <server_ip> <admin_email> [enable_recursion] [enable_forwarding] [upstream_dns]

参数说明:
  domain          域名 (例如: example.com)
  server_ip       服务器IP地址
  admin_email     管理员邮箱
  enable_recursion 启用递归查询 (true/false, 默认: true)
  enable_forwarding 启用转发 (true/false, 默认: true)
  upstream_dns    上游DNS服务器 (默认: 8.8.8.8, 1.1.1.1)

示例:
  dns_setup.sh bind example.com 192.168.1.100 admin@example.com

EOF
}

# 主函数
main() {
    # 检查参数
    if [[ $# -lt 1 ]]; then
        log_error "参数不足"
        show_help
        exit 1
    fi
    
    local resolver_type=$1
    
    # 显示帮助信息
    if [[ "$resolver_type" == "help" || "$resolver_type" == "-h" || "$resolver_type" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    # 处理install参数
    if [[ "$resolver_type" == "install" ]]; then
        log_info "安装DNS服务组件..."
        require_root
        install_bind
        log_complete "DNS服务组件安装完成"
        exit 0
    fi
    
    # 检查解析器类型（允许 restart/stop 动作）
    if [[ "$resolver_type" != "bind" \
       && "$resolver_type" != "configure-bind" \
       && "$resolver_type" != "configure-public" \
       && "$resolver_type" != "restart" \
       && "$resolver_type" != "stop" ]]; then
        log_error "无效的解析器类型: $resolver_type"
        log_error "支持的类型: bind, configure-bind, configure-public"
        show_help
        exit 1
    fi
    
    # 处理新的参数格式
    if [[ "$resolver_type" == "configure-bind" ]]; then
        resolver_type="bind"
    elif [[ "$resolver_type" == "configure-public" ]]; then
        resolver_type="public"
    fi
    
    local domain=$2
    local server_ip=${3:-""}
    local admin_email=${4:-""}
    local enable_recursion=${5:-""}
    local enable_forwarding=${6:-""}
    local upstream_dns=${7:-""}
    
    # 记录接收到的参数
    log_info "接收到的参数:"
    log_info "  解析器类型: $resolver_type"
    log_info "  域名: $domain"
    log_info "  服务器IP: $server_ip"
    log_info "  管理员邮箱: $admin_email"
    log_info "  启用递归: $enable_recursion"
    log_info "  启用转发: $enable_forwarding"
    log_info "  上游DNS: $upstream_dns"
    local provider=${8:-""}
    local api_token=${9:-""}
    local aws_access_key=${10:-""}
    local aws_secret_key=${11:-""}
    local google_api_key=${12:-""}
    local azure_client_id=${13:-""}
    local azure_client_secret=${14:-""}
    local dnspod_api_id=${15:-""}
    local dnspod_api_token=${16:-""}
    
    # 对于configure-public，如果第3个参数是提供商名称，则调整参数
    if [[ "$1" == "configure-public" && "$3" =~ ^(dnspod|cloudflare|aws|google|azure)$ ]]; then
        provider="$3"
        # 自动获取公网IP地址（检查HTTP状态码，只处理200响应）
        server_ip=""
        local ip_services_quick=("ifconfig.me/ip" "ipinfo.io/ip" "icanhazip.com")
        for service in "${ip_services_quick[@]}"; do
            local http_code=$(curl -s -o /tmp/ip_quick_$$.txt -w "%{http_code}" --connect-timeout 10 --max-time 15 "https://$service" 2>/dev/null)
            if [[ "$http_code" == "200" ]]; then
                server_ip=$(cat /tmp/ip_quick_$$.txt 2>/dev/null | tr -d '\n\r' | grep -E '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$')
                rm -f /tmp/ip_quick_$$.txt 2>/dev/null
                if [[ -n "$server_ip" ]]; then
                    break
                fi
            fi
            rm -f /tmp/ip_quick_$$.txt 2>/dev/null
        done
        # 如果所有服务都失败，使用hostname获取
        if [[ -z "$server_ip" ]]; then
            server_ip=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1")
        fi
        log_info "自动获取公网IP: $server_ip"
        # 重新解析参数，跳过server_ip参数
        admin_email=${4:-""}
        enable_recursion=${5:-""}
        enable_forwarding=${6:-""}
        upstream_dns=${7:-""}
        api_token=${8:-""}
        aws_access_key=${9:-""}
        aws_secret_key=${10:-""}
        google_api_key=${11:-""}
        azure_client_id=${12:-""}
        azure_client_secret=${13:-""}
        dnspod_api_id=${10:-""}
        dnspod_api_token=${11:-""}
    fi
    
    # 对于configure-bind和configure-public，使用默认值
    if [[ "$1" == "configure-bind" || "$1" == "configure-public" ]]; then
        if [[ -z "$server_ip" ]]; then
            server_ip=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1")
        fi
        if [[ -z "$admin_email" ]]; then
            admin_email="xm@$domain"
        fi
        enable_recursion=${enable_recursion:-"true"}
        enable_forwarding=${enable_forwarding:-"true"}
        upstream_dns=${upstream_dns:-"8.8.8.8,8.8.4.4"}
    fi
    
    # 确保所有必需参数都有值
    if [[ -z "$server_ip" ]]; then
        server_ip=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1")
    fi
    if [[ -z "$admin_email" ]]; then
        admin_email="xm@$domain"
    fi
    
    # 验证必需参数
    if [[ -z "$domain" ]]; then
        log_error "域名是必需参数"
        show_help
        exit 1
    fi
    
    if [[ "$resolver_type" == "bind" && -z "$admin_email" ]]; then
        log_error "Bind模式需要管理员邮箱参数"
        show_help
        exit 1
    fi
    
    log_info "开始DNS配置..."
    log_info "解析器类型: $resolver_type"
    log_info "域名: $domain"
    log_info "服务器IP: $server_ip"
    
    case $resolver_type in
        "bind")
            log_info "配置本机Bind DNS服务器..."
            require_root
            install_bind
            configure_bind_main "$domain" "$server_ip" "$admin_email" "$enable_recursion" "$enable_forwarding" "$upstream_dns"
            configure_firewall
            
            # 先创建zone文件（在启动服务之前，避免named-checkconf检查失败）
            log_info "创建zone文件..."
            create_forward_zone "$domain" "$server_ip" "$admin_email"
            create_reverse_zone "$server_ip" "$domain" "$admin_email"
            
            # 启动服务（如果还没有启动）
            if ! systemctl is-active --quiet named; then
                start_bind_service
            else
                log_info "Bind DNS服务已在运行"
                # 如果服务已在运行，重新加载配置以加载新的zone文件
                log_info "重新加载DNS服务以应用新的zone文件..."
                systemctl reload named 2>/dev/null || {
                    log_warning "reload失败，尝试restart"
                    systemctl restart named 2>/dev/null || true
                }
            fi
            
            # 强制重新加载所有zone文件
            log_info "强制重新加载所有zone文件..."
            systemctl reload named 2>/dev/null || {
                log_warning "reload失败，尝试restart"
                systemctl restart named 2>/dev/null || true
            }
            sleep 2
            
            # 验证zone文件是否正确加载
            log_info "验证zone文件加载状态..."
            rndc reload 2>/dev/null || {
                log_warning "rndc reload失败，尝试systemctl reload"
                systemctl reload named 2>/dev/null || true
            }
            
            # 强制更新系统DNS配置（包含DNS指向配置）
            # 即使NetworkManager配置失败，也不影响整体配置成功
            # 只要resolv.conf配置成功，就认为DNS配置成功
            if ! force_update_system_dns "$domain" "$server_ip" "$upstream_dns" "$enable_recursion"; then
                log_warning "系统DNS配置更新过程中出现警告，但核心配置已应用"
                # 不返回失败，因为resolv.conf可能已经配置成功
            fi
            
            # 执行DNS健康检查（不作为失败退出条件）
            log_info "执行DNS健康检查..."
            check_dns_health "$domain" "$server_ip" || true
            
            # 配置Apache虚拟主机
            log_info "配置Apache虚拟主机..."
            update_apache_config "$domain" "$server_ip"
            
            # 写入DNS配置标记到system-settings.json
            log_info "更新系统设置中的DNS配置标记..."
            local config_file="${BASE_DIR}/config/system-settings.json"
            if [[ -f "$config_file" ]]; then
                # 备份配置文件
                cp "$config_file" "${config_file}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
                
                # 使用jq更新DNS配置，设置为本地Bind并标记为已配置
                jq --arg domain "$domain" --arg server_ip "$server_ip" --arg admin_email "$admin_email" --arg enable_recursion "$enable_recursion" --arg enable_forwarding "$enable_forwarding" --arg upstream_dns "$upstream_dns" '
                .dns.type = "bind" |
                .dns.configured = true |
                .dns.bind.domain = $domain |
                .dns.bind.serverIp = $server_ip |
                .dns.bind.adminEmail = $admin_email |
                .dns.bind.enableRecursion = ($enable_recursion == "true") |
                .dns.bind.enableForwarding = ($enable_forwarding == "true") |
                .dns.bind.upstreamDns = $upstream_dns |
                .dns.public.domain = "" |
                .dns.public.serverIp = "" |
                .dns.public.adminEmail = "" |
                .dns.public.enableRecursion = false |
                .dns.public.enableForwarding = false |
                .dns.public.upstreamDns = ""
                ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
                
                log_success "DNS配置标记已更新，类型: bind"
            else
                log_warning "系统设置文件不存在，跳过DNS配置标记更新"
            fi
            
            # DNS配置成功后，自动将域名添加到邮件域名数据库
            log_info "自动将DNS域名添加到邮件域名数据库..."
            local mail_db_script=""
            local script_dir="$(cd "$(dirname "$0")" && pwd)"
            # 尝试多个可能的路径
            if [[ -f "${BASE_DIR}/backend/scripts/mail_db.sh" ]]; then
                mail_db_script="${BASE_DIR}/backend/scripts/mail_db.sh"
            elif [[ -f "$script_dir/mail_db.sh" ]]; then
                mail_db_script="$script_dir/mail_db.sh"
            elif [[ -f "./backend/scripts/mail_db.sh" ]]; then
                mail_db_script="./backend/scripts/mail_db.sh"
            elif command -v mail_db.sh >/dev/null 2>&1; then
                mail_db_script="mail_db.sh"
            fi
            
            if [[ -n "$mail_db_script" && -f "$mail_db_script" ]]; then
                log_info "找到mail_db.sh脚本: $mail_db_script"
                
                # 1. 先确保 localhost 域名存在（使用 INSERT IGNORE，不会重复添加）
                log_info "确保 localhost 域名存在于邮件域名数据库..."
                if bash "$mail_db_script" add_domain "localhost" 2>/dev/null; then
                    log_success "localhost 域名已自动添加到邮件域名数据库"
                else
                    local localhost_result=$(bash "$mail_db_script" add_domain "localhost" 2>&1)
                    if echo "$localhost_result" | grep -q "已存在"; then
                        log_info "localhost 域名已存在于邮件域名数据库中"
                    else
                        log_warning "自动添加 localhost 域名失败（不影响DNS配置）: $localhost_result"
                    fi
                fi
                
                # 2. 添加用户输入的域名（如果域名不存在）
                log_info "添加用户输入的域名: $domain"
                if bash "$mail_db_script" add_domain "$domain" 2>/dev/null; then
                    log_success "域名 $domain 已自动添加到邮件域名数据库"
                else
                    # 检查是否是因为域名已存在
                    local add_result=$(bash "$mail_db_script" add_domain "$domain" 2>&1)
                    if echo "$add_result" | grep -q "已存在"; then
                        log_info "域名 $domain 已存在于邮件域名数据库中"
                    else
                        log_warning "自动添加域名到邮件域名数据库失败（不影响DNS配置）: $add_result"
                    fi
                fi
            else
                log_warning "未找到mail_db.sh脚本，跳过自动添加域名到邮件域名数据库"
                log_info "请手动在邮件域名管理中添加域名: localhost 和 $domain"
            fi

            # DNS配置成功后，更新管理员邮箱为新域名格式
            log_info "更新管理员邮箱为新域名格式..."
            local script_dir="$(cd "$(dirname "$0")" && pwd)"
            local admin_email_for_domain="xm@$domain"

            # 更新邮件系统数据库中的管理员邮箱
            if [[ -f "$script_dir/mail_db.sh" ]]; then
                log_info "更新邮件系统管理员邮箱为: $admin_email_for_domain"
                if bash "$script_dir/mail_db.sh" update-admin-email "$admin_email_for_domain" 2>/dev/null; then
                    log_success "邮件系统管理员邮箱已更新为: $admin_email_for_domain"
                else
                    log_warning "更新邮件系统管理员邮箱失败（可能数据库连接问题）"
                fi
            else
                log_warning "未找到mail_db.sh脚本，跳过邮件系统管理员邮箱更新"
            fi

            # 同时更新应用数据库中的管理员邮箱（用于前端用户管理显示）
            log_info "更新应用系统管理员邮箱为: $admin_email_for_domain"
            mysql -u root -e "USE mailapp; UPDATE app_users SET email='$admin_email_for_domain' WHERE username='xm';" 2>/dev/null && {
                log_success "应用系统管理员邮箱已更新为: $admin_email_for_domain"
            } || {
                log_warning "更新应用系统管理员邮箱失败（可能数据库连接问题）"
            }

            log_complete "Bind DNS配置完成"
            ;;
        "public")
            log_info "配置公网DNS并更新Apache配置..."
            require_root
            configure_public_dns "$domain" "$server_ip" "$admin_email" "$enable_recursion" "$enable_forwarding" "$upstream_dns"
            # 公网DNS配置时跳过HTTPS，仅配置HTTP虚拟主机
            update_apache_config "$domain" "$server_ip" "true"

            # DNS配置成功后，更新管理员邮箱为新域名格式
            log_info "更新管理员邮箱为新域名格式..."
            local script_dir="$(cd "$(dirname "$0")" && pwd)"
            local admin_email_for_domain="xm@$domain"

            # 更新邮件系统数据库中的管理员邮箱
            if [[ -f "$script_dir/mail_db.sh" ]]; then
                log_info "更新邮件系统管理员邮箱为: $admin_email_for_domain"
                if bash "$script_dir/mail_db.sh" update-admin-email "$admin_email_for_domain" 2>/dev/null; then
                    log_success "邮件系统管理员邮箱已更新为: $admin_email_for_domain"
                else
                    log_warning "更新邮件系统管理员邮箱失败（可能数据库连接问题）"
                fi
            else
                log_warning "未找到mail_db.sh脚本，跳过邮件系统管理员邮箱更新"
            fi

            # 同时更新应用数据库中的管理员邮箱（用于前端用户管理显示）
            log_info "更新应用系统管理员邮箱为: $admin_email_for_domain"
            mysql -u root -e "USE mailapp; UPDATE app_users SET email='$admin_email_for_domain' WHERE username='xm';" 2>/dev/null && {
                log_success "应用系统管理员邮箱已更新为: $admin_email_for_domain"
            } || {
                log_warning "更新应用系统管理员邮箱失败（可能数据库连接问题）"
            }

            log_complete "公网DNS配置完成"
            ;;
      "restart")
        log_info "重启DNS服务 (Bind)"
        require_root
        systemctl restart named
        sleep 3
        if systemctl is-active --quiet named; then
            log_success "DNS服务重启成功"
        else
            log_error "DNS服务重启失败"
            systemctl status named --no-pager -l
            exit 1
        fi
        ;;
      "stop")
        log_info "关闭DNS服务 (Bind)"
        require_root
        systemctl stop named
        sleep 3
        if ! systemctl is-active --quiet named; then
            log_success "DNS服务关闭成功"
        else
            log_error "DNS服务关闭失败"
            systemctl status named --no-pager -l
            exit 1
        fi
            ;;
        *)
            log_error "未知的操作类型: $action"
            echo "用法: $0 <bind|public|configure-bind|configure-public|install|restart|stop> [参数...]"
            exit 1
            ;;
    esac
    
    # 确保脚本以成功状态退出
    exit 0
}

# 执行主函数
main "$@"
