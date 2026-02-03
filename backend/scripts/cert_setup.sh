#!/bin/bash
#
# ============================================================================
# 脚本名称: cert_setup.sh
# 工作职责: SSL证书申请与管理脚本 - 负责SSL/TLS证书的生成、申请和配置
#           支持自签名证书、CA根证书创建和Let's Encrypt证书申请
# 系统组件: XM邮件管理系统 - 证书管理模块
# ============================================================================
# 用法说明:
#   cert_setup.sh <action> [参数...]
#   cert_setup.sh install <域名> [country] [state] [city] [organization] [unit] [email] [validity] [san] ...
#     - 完整SSL证书申请流程（CA、服务器证书、Apache SSL、系统信任、DNS建议）
#   cert_setup.sh enable-ssl <域名>            - 配置Apache SSL虚拟主机（使用已有证书）
#   cert_setup.sh enable-http-redirect [域名]  - 配置HTTP跳转HTTPS
#
# 功能描述:
#   - install：完整申请流程（创建CA、生成服务器证书、配置 Apache SSL、更新系统信任、DNS 建议）
#   - enable-ssl：使用已有证书文件配置 Apache SSL 虚拟主机（不自动配置 HTTP 跳转）
#   - enable-http-redirect：配置 HTTP 自动跳转 HTTPS（可选域名）
#
# 证书类型:
#   - 自签名证书：用于开发和测试
#   - CA签名证书：用于生产环境
#   - Let's Encrypt：免费SSL证书
#
# 端口配置:
#   - Apache HTTP/HTTPS端口：从config/port-config.json读取（默认80/443）
#   - VirtualHost配置使用动态端口变量
#   - Listen指令使用动态端口变量
#   - 防火墙规则支持自定义端口
#
# 依赖关系:
#   - OpenSSL（证书生成）
#   - certbot（Let's Encrypt）
#   - Apache（Web服务器）
#   - Postfix/Dovecot（邮件服务器）
#   - jq（JSON配置解析）
#
# 注意事项:
#   - 需要root权限执行证书操作
#   - Let's Encrypt需要域名解析正常
#   - 证书过期前需要及时续期
#   - 证书文件需要安全权限（600）
#   - SSL配置时仅配置SSL虚拟主机，不自动创建HTTP跳转配置
#   - HTTP跳转HTTPS需要通过enable-http-redirect命令单独配置
#   - 默认不开启HTTP跳转，需要用户明确选择
# ============================================================================

set -e

# 获取脚本目录和项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_DIR="$BASE_DIR/config"

# 读取端口配置
get_port_config() {
    local port_config_file="$CONFIG_DIR/port-config.json"
    local api_port=8081
    local apache_http_port=80
    local apache_https_port=443
    
    if [[ -f "$port_config_file" ]] && command -v jq >/dev/null 2>&1; then
        api_port=$(jq -r '.api.port // 8081' "$port_config_file" 2>/dev/null || echo "8081")
        apache_http_port=$(jq -r '.apache.httpPort // 80' "$port_config_file" 2>/dev/null || echo "80")
        apache_https_port=$(jq -r '.apache.httpsPort // 443' "$port_config_file" 2>/dev/null || echo "443")
    fi
    
    echo "$api_port|$apache_http_port|$apache_https_port"
}

PORT_CONFIG=$(get_port_config)
API_PORT=$(echo "$PORT_CONFIG" | cut -d'|' -f1)
APACHE_HTTP_PORT=$(echo "$PORT_CONFIG" | cut -d'|' -f2)
APACHE_HTTPS_PORT=$(echo "$PORT_CONFIG" | cut -d'|' -f3)

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
    log "INFO: $1"
}

log_success() {
    log "SUCCESS: $1"
}

log_error() {
    log "ERROR: $1"
}

log_warning() {
    log "WARNING: $1"
}

# 检查SSL依赖
check_ssl_deps() {
    log_info "检查SSL依赖包..."
    if ! command -v openssl &> /dev/null; then
        log_info "安装SSL相关依赖包..."
        yum -y install *ssl* || {
            log_error "SSL依赖包安装失败"
            return 1
        }
    fi
    log_success "SSL依赖检查完成"
}

# 配置OpenSSL
configure_openssl() {
    log_info "配置OpenSSL..."
    local openssl_conf="/etc/pki/tls/openssl.cnf"
    
    # 备份原配置文件
    cp "$openssl_conf" "${openssl_conf}.backup.$(date +%Y%m%d_%H%M%S)"
    
    # 修改默认有效期（第114行）
    sed -i '114s/.*/default_days    = 10950   # CA根证书有效期30年（10950天）/; 115s/.*/default_crl_days = 1825   # 服务器证书有效期5年（1825天）/; 116s/.*/default_md      = sha256  # 加密算法/; 117s/.*/preserve        = no/' "$openssl_conf"
    
    # 启用请求扩展（第167行）
    sed -i '167s/^# *req_extensions = v3_req/req_extensions = v3_req/' "$openssl_conf"
    
    # 配置SAN扩展
    if ! grep -q "subjectAltName=@alt_names" "$openssl_conf"; then
        sed -i '/\[v3_req\]/a subjectAltName=@alt_names' "$openssl_conf"
    fi
    
    log_success "OpenSSL配置完成"
}

# 创建CA根证书
create_ca_cert() {
    local ca_country="$1"
    local ca_state="$2"
    local ca_city="$3"
    local ca_organization="$4"
    local ca_unit="$5"
    local ca_common_name="$6"
    local ca_email="$7"
    local ca_validity="$8"
    
    log_info "创建CA根证书..."
    
    # 设置默认值
    ca_country="${ca_country:-CN}"
    ca_state="${ca_state:-Beijing}"
    ca_city="${ca_city:-Beijing}"
    ca_organization="${ca_organization:-skills}"
    ca_unit="${ca_unit:-system}"
    ca_common_name="${ca_common_name:-CA Server}"
    ca_email="${ca_email:-ca@example.com}"
    ca_validity="${ca_validity:-10950}"
    
    # 检查CA根证书是否已存在
    if [[ -f "/etc/pki/CA/cacert.pem" && -f "/etc/pki/CA/private/cakey.pem" ]]; then
        log_info "CA根证书已存在，跳过创建"
        return 0
    fi
    
    # 创建CA目录结构
    mkdir -p /etc/pki/CA/private
    mkdir -p /etc/pki/CA/newcerts
    mkdir -p /etc/pki/CA/certs
    mkdir -p /etc/pki/CA/crl
    
    # 生成CA私钥
    log_info "生成CA私钥..."
    openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096
    
    # 生成CA根证书
    log_info "生成CA根证书..."
    local ca_subj="/C=${ca_country}/ST=${ca_state}/L=${ca_city}/O=${ca_organization}/OU=${ca_unit}/CN=${ca_common_name}"
    if [[ -n "$ca_email" ]]; then
        ca_subj="${ca_subj}/emailAddress=${ca_email}"
    fi
    openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days "$ca_validity" -subj "$ca_subj"
    
    # 创建索引文件和序列号文件
    touch /etc/pki/CA/index.txt
    echo 01 > /etc/pki/CA/serial
    
    log_success "CA根证书创建完成"
    log_info "CA证书信息:"
    log_info "  国家: ${ca_country}"
    log_info "  省份: ${ca_state}"
    log_info "  城市: ${ca_city}"
    log_info "  组织: ${ca_organization}"
    log_info "  组织单位: ${ca_unit}"
    log_info "  通用名称: ${ca_common_name}"
    log_info "  邮箱: ${ca_email}"
    log_info "  有效期: ${ca_validity}天"
}

# 生成服务器证书
generate_server_cert() {
    local domain="$1"
    local country="$2"
    local state="$3"
    local city="$4"
    local organization="$5"
    local unit="$6"
    local common_name="$7"
    local email="$8"
    local validity="$9"
    local san="${10}"
    
    log_info "生成服务器证书..."
    
    # 创建证书目录
    mkdir -p /etc/ssl
    
    # 生成服务器私钥
    log_info "生成服务器私钥..."
    openssl genrsa -out "/etc/ssl/${domain}.key" 4096
    
    # 创建证书请求配置文件
    local csr_conf="/tmp/${domain}_csr.conf"
    cat > "$csr_conf" << EOF
[req]
default_bits = 4096
prompt = no
distinguished_name = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
C = ${country}
ST = ${state}
L = ${city}
O = ${organization}
OU = ${unit}
CN = ${common_name}
emailAddress = ${email}

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${domain}
DNS.2 = *.${domain}
EOF

    # 自动获取服务器 IP 地址并添加到 SAN
    log_info "自动获取服务器 IP 地址..."
    local server_ip=""
    # 尝试获取公网 IP
    server_ip="$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null || curl -s --connect-timeout 3 ipinfo.io/ip 2>/dev/null || curl -s --connect-timeout 3 icanhazip.com 2>/dev/null || echo "")"
    # 如果获取失败，使用本地 IP（排除 127.0.0.1）
    if [[ -z "$server_ip" || "$server_ip" == "127.0.0.1" ]]; then
        server_ip="$(hostname -I 2>/dev/null | awk '{print $1}' | grep -v "^127\." | head -n1 || echo "")"
    fi
    # 如果还是失败，尝试从网络接口获取
    if [[ -z "$server_ip" ]]; then
        server_ip="$(ip route get 8.8.8.8 2>/dev/null | awk '{print $7}' | head -n1 || echo "")"
    fi
    
    local ip_count=1
    if [[ -n "$server_ip" && "$server_ip" != "127.0.0.1" ]]; then
        echo "IP.${ip_count} = ${server_ip}" >> "$csr_conf"
        log_info "已添加服务器 IP 到证书: ${server_ip}"
        ((ip_count++))
    fi
    
    # 添加本地回环地址
    echo "IP.${ip_count} = 127.0.0.1" >> "$csr_conf"
    log_info "已添加本地回环地址到证书: 127.0.0.1"
    ((ip_count++))
    
    # 添加用户自定义的SAN条目
    if [[ -n "$san" ]]; then
        local san_count=$ip_count
        echo "$san" | while read -r line; do
            if [[ -n "$line" ]]; then
                if [[ "$line" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                    echo "IP.${san_count} = $line" >> "$csr_conf"
                else
                    echo "DNS.${san_count} = $line" >> "$csr_conf"
                fi
                ((san_count++))
            fi
        done
    fi
    
    # 生成证书请求
    log_info "生成证书请求..."
    openssl req -new -key "/etc/ssl/${domain}.key" -out "/etc/ssl/${domain}.csr" -config "$csr_conf"
    
    # 签署证书
    log_info "签署服务器证书..."
    openssl ca -in "/etc/ssl/${domain}.csr" -out "/etc/ssl/${domain}.crt" -config /etc/pki/tls/openssl.cnf -extensions v3_req -days "$validity" -batch
    
    # 清理临时文件
    rm -f "$csr_conf"
    
    log_success "服务器证书生成完成"
}

# 配置Apache SSL
configure_apache_ssl() {
    local domain="$1"
    local cert_name="${2:-$domain}"  # 第二个参数是证书名称，默认为域名
    
    log_info "配置Apache SSL..."
    log_info "域名: $domain, 证书名称: $cert_name"
    
    # 如果证书文件不在/etc/pki/tls目录，尝试从/etc/ssl复制
    if [[ ! -f "/etc/pki/tls/${cert_name}.crt" ]] && [[ -f "/etc/ssl/${cert_name}.crt" ]]; then
        cp "/etc/ssl/${cert_name}.crt" "/etc/pki/tls/"
        cp "/etc/ssl/${cert_name}.key" "/etc/pki/tls/"
        log_info "已从 /etc/ssl 复制证书文件到 /etc/pki/tls"
    fi
    
    # 复制CA证书（如果存在）
    if [[ -f "/etc/pki/CA/cacert.pem" ]] && [[ ! -f "/etc/pki/tls/cacert.pem" ]]; then
        cp "/etc/pki/CA/cacert.pem" "/etc/pki/tls/"
    fi
    
    # 设置正确的权限
    if [[ -f "/etc/pki/tls/${cert_name}.crt" ]]; then
        chmod 644 "/etc/pki/tls/${cert_name}.crt"
    fi
    if [[ -f "/etc/pki/tls/${cert_name}.key" ]]; then
        chmod 600 "/etc/pki/tls/${cert_name}.key"
    fi
    if [[ -f "/etc/pki/tls/cacert.pem" ]]; then
        chmod 644 "/etc/pki/tls/cacert.pem"
    fi
    
    # 检查现有配置
    local mailmgmt_conf="/etc/httpd/conf.d/mailmgmt.conf"
    local vhost_conf="/etc/httpd/conf.d/${domain}_ssl.conf"
    
    # 备份现有配置
    if [[ -f "$mailmgmt_conf" ]]; then
        cp "$mailmgmt_conf" "${mailmgmt_conf}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "已备份现有邮件管理配置"
    fi
    
    # 注意：SSL配置时不创建HTTP跳转配置
    # HTTP跳转HTTPS配置应该由用户选择开启后通过 enable-http-redirect 完成
    # 这里只配置SSL虚拟主机，不创建 *_http.conf 文件
    log_info "SSL配置模式：仅配置SSL虚拟主机，不创建HTTP跳转配置"
    log_info "说明：HTTP跳转HTTPS需要通过前端选择开启后配置"
    
    # 检查是否存在对应的chain证书文件
    local chain_cert_path=""
    if [[ -f "/etc/pki/tls/${cert_name}.chain.crt" ]]; then
        chain_cert_path="/etc/pki/tls/${cert_name}.chain.crt"
        log_info "检测到证书链文件: $chain_cert_path"
    elif [[ -f "/etc/pki/tls/${cert_name}.chain" ]]; then
        chain_cert_path="/etc/pki/tls/${cert_name}.chain"
        log_info "检测到证书链文件: $chain_cert_path"
    elif [[ -f "/etc/pki/CA/cacert.pem" ]]; then
        chain_cert_path="/etc/pki/tls/cacert.pem"
        log_info "使用CA根证书: $chain_cert_path"
    fi
    
    # 创建SSL虚拟主机配置（支持域名访问）
    # 确定ServerAlias：如果域名已经是www.开头，则添加去掉www.的别名；否则添加www.前缀的别名
    local server_alias=""
    if [[ "$domain" =~ ^www\.(.+)$ ]]; then
        # 域名是www.开头，添加去掉www.的别名
        server_alias="${BASH_REMATCH[1]}"
    else
        # 域名不是www.开头，添加www.前缀的别名
        server_alias="www.${domain}"
    fi
    
    if [[ -n "$chain_cert_path" ]]; then
        log_info "创建SSL虚拟主机配置文件（包含证书链）: $vhost_conf"
        if ! cat > "$vhost_conf" << EOF
# SSL虚拟主机配置 - ${domain}
<VirtualHost *:${APACHE_HTTPS_PORT}>
    ServerName ${domain}
    ServerAlias ${server_alias}
    DocumentRoot /var/www/mail-frontend
    
    # SSL配置（使用cert_name指定的证书文件，包含证书链）
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/${cert_name}.crt
    SSLCertificateKeyFile /etc/pki/tls/${cert_name}.key
    SSLCACertificateFile ${chain_cert_path}
    
    # SSL安全配置
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    ErrorLog /var/log/httpd/${domain}-ssl-error.log
    CustomLog /var/log/httpd/${domain}-ssl-access.log combined
    
    # CORS配置（处理HTTP到HTTPS重定向的跨域问题）
    <IfModule mod_headers.c>
        # 允许所有来源（因为前端可能从HTTP重定向到HTTPS）
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
        Header always set Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Auth-Token"
        Header always set Access-Control-Allow-Credentials "true"
        Header always set Access-Control-Max-Age "86400"
        
        # 处理预检请求
        Header always set Access-Control-Expose-Headers "Content-Length, Content-Type"
    </IfModule>
    
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
                RewriteRule ^/?(.*) ws://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
            </IfModule>
            
            Require all granted
            
            # 禁用认证
            AuthType None
            Satisfy Any
        </Location>
    </IfModule>

    # API 代理
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
        AuthType None
        Satisfy Any
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
        then
            log_error "创建SSL虚拟主机配置文件失败（包含证书链）: $vhost_conf"
            return 1
        fi
        
        if [[ ! -f "$vhost_conf" ]]; then
            log_error "SSL虚拟主机配置文件创建后不存在（包含证书链）: $vhost_conf"
            return 1
        fi
        log_success "SSL虚拟主机配置文件创建成功（包含证书链）: $vhost_conf"
    else
        # 如果没有chain证书，使用默认配置（不包含SSLCACertificateFile）
        # 确定ServerAlias（与上面相同的逻辑）
        local server_alias=""
        if [[ "$domain" =~ ^www\.(.+)$ ]]; then
            server_alias="${BASH_REMATCH[1]}"
        else
            server_alias="www.${domain}"
        fi
        
        log_info "创建SSL虚拟主机配置文件（不包含证书链）: $vhost_conf"
        if ! cat > "$vhost_conf" << EOF
# SSL虚拟主机配置 - ${domain}
<VirtualHost *:${APACHE_HTTPS_PORT}>
    ServerName ${domain}
    ServerAlias ${server_alias}
    DocumentRoot /var/www/mail-frontend
    
    # SSL配置（使用cert_name指定的证书文件）
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/${cert_name}.crt
    SSLCertificateKeyFile /etc/pki/tls/${cert_name}.key
    
    # SSL安全配置
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    ErrorLog /var/log/httpd/${domain}-ssl-error.log
    CustomLog /var/log/httpd/${domain}-ssl-access.log combined
    
    # CORS配置（处理HTTP到HTTPS重定向的跨域问题）
    <IfModule mod_headers.c>
        # 允许所有来源（因为前端可能从HTTP重定向到HTTPS）
        Header always set Access-Control-Allow-Origin "*"
        Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS, PATCH"
        Header always set Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Auth-Token"
        Header always set Access-Control-Allow-Credentials "true"
        Header always set Access-Control-Max-Age "86400"
        
        # 处理预检请求
        Header always set Access-Control-Expose-Headers "Content-Length, Content-Type"
    </IfModule>
    
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
                RewriteRule ^/?(.*) ws://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
            </IfModule>
            
            Require all granted
            
            # 禁用认证
            AuthType None
            Satisfy Any
        </Location>
    </IfModule>

    # API 代理
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
        AuthType None
        Satisfy Any
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
        then
            log_error "创建SSL虚拟主机配置文件失败（不包含证书链）: $vhost_conf"
            return 1
        fi
        
        if [[ ! -f "$vhost_conf" ]]; then
            log_error "SSL虚拟主机配置文件创建后不存在（不包含证书链）: $vhost_conf"
            return 1
        fi
        log_success "SSL虚拟主机配置文件创建成功（不包含证书链）: $vhost_conf"
    fi
    
    # 验证SSL配置文件是否成功创建
    if [[ ! -f "$vhost_conf" ]]; then
        log_error "SSL虚拟主机配置文件不存在: $vhost_conf"
        return 1
    fi
    
    log_info "SSL配置文件创建完成:"
    log_info "  - SSL配置: $vhost_conf"
    log_info "说明：HTTP跳转HTTPS配置需要通过前端选择开启后完成"
    
    # 检查是否存在对应的chain证书文件（IP访问虚拟主机，复用上面的chain_cert_path）
    local ip_chain_cert_path="$chain_cert_path"
    
    # 创建独立的IP访问SSL虚拟主机配置文件（文件名以 zz_ 开头，确保最后加载）
    local ip_ssl_conf="/etc/httpd/conf.d/zz_ip_ssl.conf"
    if [[ -n "$ip_chain_cert_path" ]]; then
        cat > "$ip_ssl_conf" << EOF
# SSL虚拟主机配置 - IP访问（默认虚拟主机，用于IP地址访问）
# 此配置必须最后加载，作为默认虚拟主机匹配所有未匹配的请求
<VirtualHost *:${APACHE_HTTPS_PORT}>
    # 不设置 ServerName，使其成为默认虚拟主机，匹配所有未匹配的请求（包括IP访问）
    DocumentRoot /var/www/mail-frontend
    
    # SSL配置（使用cert_name指定的证书文件，包含证书链）
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/${cert_name}.crt
    SSLCertificateKeyFile /etc/pki/tls/${cert_name}.key
    SSLCACertificateFile ${ip_chain_cert_path}
    
    # SSL安全配置
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    ErrorLog /var/log/httpd/ip-ssl-error.log
    CustomLog /var/log/httpd/ip-ssl-access.log combined
    
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
                RewriteRule ^/?(.*) ws://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
            </IfModule>
            
            Require all granted
            
            # 禁用认证
            AuthType None
            Satisfy Any
        </Location>
    </IfModule>

    # API 代理
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
        AuthType None
        Satisfy Any
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
    else
        # 如果没有chain证书，使用默认配置（不包含SSLCACertificateFile）
        cat > "$ip_ssl_conf" << EOF
# SSL虚拟主机配置 - IP访问（默认虚拟主机，用于IP地址访问）
# 此配置必须最后加载，作为默认虚拟主机匹配所有未匹配的请求
<VirtualHost *:${APACHE_HTTPS_PORT}>
    # 不设置 ServerName，使其成为默认虚拟主机，匹配所有未匹配的请求（包括IP访问）
    DocumentRoot /var/www/mail-frontend
    
    # SSL配置（使用cert_name指定的证书文件）
    SSLEngine on
    SSLCertificateFile /etc/pki/tls/${cert_name}.crt
    SSLCertificateKeyFile /etc/pki/tls/${cert_name}.key
    
    # SSL安全配置
    SSLProtocol all -SSLv3 -TLSv1 -TLSv1.1
    SSLCipherSuite ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384
    SSLHonorCipherOrder off
    SSLSessionTickets off
    
    ErrorLog /var/log/httpd/ip-ssl-error.log
    CustomLog /var/log/httpd/ip-ssl-access.log combined
    
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
                RewriteRule ^/?(.*) ws://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
                RewriteCond %{HTTP:Upgrade} !=websocket [NC]
                RewriteRule ^/?(.*) http://127.0.0.1:${API_PORT}/api/terminal/ws/$1 [P,L]
            </IfModule>
            
            Require all granted
            
            # 禁用认证
            AuthType None
            Satisfy Any
        </Location>
    </IfModule>

    # API 代理
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
        AuthType None
        Satisfy Any
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
    
    log_info "已创建HTTP和HTTPS虚拟主机配置"
    
    # 修改默认的 mailmgmt.conf，添加 HTTPS 跳转（支持IP和域名访问）
    if [[ -f "$mailmgmt_conf" ]]; then
        # 备份原配置
        cp "$mailmgmt_conf" "${mailmgmt_conf}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # 检查是否已经有 RewriteEngine（避免重复添加）
        if ! grep -q "RewriteEngine On" "$mailmgmt_conf"; then
            # 在 VirtualHost 标签后、DocumentRoot 之前添加 RewriteEngine
            # 使用更精确的 sed 命令，确保在正确位置插入
            # 使用动态端口匹配
            sed -i "/<VirtualHost \*:${APACHE_HTTP_PORT}>/,/DocumentRoot/ {
                /<VirtualHost \*:${APACHE_HTTP_PORT}>/a\
    # 自动跳转到HTTPS（支持IP和域名访问）\
    RewriteEngine On\
    RewriteCond %{HTTPS} off\
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
            }" "$mailmgmt_conf"
            log_info "已更新默认HTTP虚拟主机配置，添加HTTPS跳转"
        else
            log_info "默认HTTP虚拟主机已配置HTTPS跳转"
        fi
    fi
    
    # 启用SSL模块和Rewrite模块
    if ! grep -q "LoadModule ssl_module" /etc/httpd/conf/httpd.conf; then
        echo "LoadModule ssl_module modules/mod_ssl.so" >> /etc/httpd/conf/httpd.conf
        log_info "已启用SSL模块"
    fi
    if ! grep -q "LoadModule rewrite_module" /etc/httpd/conf/httpd.conf; then
        echo "LoadModule rewrite_module modules/mod_rewrite.so" >> /etc/httpd/conf/httpd.conf
        log_info "已启用Rewrite模块"
    fi
    
    # 确保监听443端口
    if ! grep -q "^Listen ${APACHE_HTTPS_PORT}" /etc/httpd/conf/httpd.conf && ! grep -q "^Listen.*${APACHE_HTTPS_PORT}" /etc/httpd/conf.d/*.conf 2>/dev/null; then
        echo "Listen ${APACHE_HTTPS_PORT} https" >> /etc/httpd/conf/httpd.conf
        log_info "已添加${APACHE_HTTPS_PORT}端口监听"
    fi
    
    # 配置防火墙（如果存在）
    if command -v firewall-cmd &>/dev/null && systemctl is-active --quiet firewalld 2>/dev/null; then
        log_info "配置防火墙规则..."
        firewall-cmd --permanent --add-service=https 2>/dev/null || true
        firewall-cmd --permanent --add-port=${APACHE_HTTPS_PORT}/tcp 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
        log_info "防火墙规则已更新（HTTPS服务已开放）"
    fi
    
    # 检查Apache配置语法
    local config_test_output
    config_test_output=$(httpd -t 2>&1)
    local config_test_exit_code=$?
    
    if [[ $config_test_exit_code -eq 0 ]]; then
        log_info "Apache配置语法检查通过"
        
        # 检查SSL模块是否已加载
        if ! httpd -M 2>/dev/null | grep -q ssl_module; then
            log_warning "SSL模块未加载，尝试加载SSL模块..."
            # 检查SSL配置文件是否存在
            if [[ -f /etc/httpd/conf.modules.d/00-ssl.conf ]] || [[ -f /etc/httpd/conf.d/ssl.conf ]]; then
                log_info "SSL配置文件存在，尝试重新加载配置"
                systemctl daemon-reload
            else
                log_error "SSL模块配置文件不存在，请检查Apache SSL模块安装"
                return 1
            fi
        else
            log_info "SSL模块已加载"
        fi
        
        # 检查HTTPS端口是否监听（在重启前检查）
        if ! netstat -tlnp 2>/dev/null | grep -q ":${APACHE_HTTPS_PORT} " && ! ss -tlnp 2>/dev/null | grep -q ":${APACHE_HTTPS_PORT} "; then
            log_info "${APACHE_HTTPS_PORT}端口当前未监听（重启后将监听）"
        fi
        
        # 重启Apache
        log_info "正在重启Apache服务..."
        if systemctl restart httpd; then
            log_info "Apache重启命令执行成功"
        else
            log_warning "Apache重启命令可能失败，检查服务状态..."
        fi
        sleep 3  # 增加等待时间，确保服务完全启动
        
        # 检查Apache服务状态
        if systemctl is-active --quiet httpd; then
            log_success "Apache服务运行正常"
        else
            log_error "Apache服务未正常运行"
            systemctl status httpd --no-pager -l 2>&1 | while read -r line; do
                log_error "  $line"
            done
            return 1
        fi
        
        log_success "Apache SSL配置完成并重启成功"
        log_info "HTTP请求将自动跳转到HTTPS"
        log_info "支持通过域名和IP地址访问HTTPS"
        
        # 验证443端口监听
        sleep 1  # 再等待1秒，确保端口监听
        if netstat -tlnp 2>/dev/null | grep -q ":${APACHE_HTTPS_PORT} " || ss -tlnp 2>/dev/null | grep -q ":${APACHE_HTTPS_PORT} "; then
            log_success "${APACHE_HTTPS_PORT}端口已成功监听"
        else
            log_warning "${APACHE_HTTPS_PORT}端口可能未监听，请检查防火墙和SELinux配置"
            log_info "运行以下命令检查端口监听: netstat -tlnp | grep ${APACHE_HTTPS_PORT} 或 ss -tlnp | grep ${APACHE_HTTPS_PORT}"
        fi
        
        # 显示访问信息
        local server_ip=""
        server_ip="$(hostname -I 2>/dev/null | awk '{print $1}' | grep -v "^127\." | head -n1 || echo "")"
        if [[ -n "$server_ip" ]]; then
            log_info "可以通过以下方式访问："
            log_info "  - HTTPS域名: https://${domain}"
            log_info "  - HTTPS IP: https://${server_ip}"
            log_info "  - HTTP会自动跳转到HTTPS"
        fi
        return 0
    else
        log_error "Apache配置语法错误，请检查配置"
        log_error "运行 'httpd -t' 查看详细错误信息"
        # 输出详细的配置错误信息
        log_error "配置错误详情："
        httpd -t 2>&1 | while read -r line; do
            log_error "  $line"
        done
        return 1
    fi
}

# 更新系统证书信任
update_system_trust() {
    log_info "更新系统证书信任..."
    
    # 复制CA根证书到系统信任目录
    cp /etc/pki/CA/cacert.pem /etc/pki/ca-trust/source/anchors/cacert.cert
    
    # 更新系统证书信任库
    update-ca-trust
    
    log_success "系统证书信任更新完成"
}

# 配置DNS解析
configure_dns() {
    local domain="$1"
    
    log_info "配置DNS解析..."
    
    # 公网IP探测
    local public_ip="$(curl -s ifconfig.me || curl -s ipinfo.io/ip || curl -s icanhazip.com || hostname -I | awk '{print $1}')"
    if [[ -z "$public_ip" ]]; then
        public_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    fi
    if [[ -z "$public_ip" || "$public_ip" == "127.0.0.1" ]]; then
        log_warning "未能可靠获取公网IP，将继续尝试使用本地DNS信息"
    else
        log_info "检测到公网IP: $public_ip"
    fi

    # 优先检测本地Bind(named)服务
    if systemctl is-active --quiet named; then
        log_info "检测到本地Bind(named)正在运行，优先使用本地DNS"
        if command -v dig &>/dev/null; then
            local current_a
            current_a="$(dig +short @127.0.0.1 "$domain" A | head -n1)"
            if [[ -n "$current_a" ]]; then
                log_success "本地域名已解析: ${domain} -> ${current_a}"
                return 0
            fi
        fi

        # 尝试使用nsupdate添加A记录（需服务器允许更新）
        if command -v nsupdate &>/dev/null; then
            log_info "尝试通过nsupdate向本地Bind添加A记录..."
            local nsupdate_file
            nsupdate_file="/tmp/nsupdate_${domain}_$$.txt"
            {
                echo "server 127.0.0.1"
                echo "update delete ${domain}. A"
                if [[ -n "$public_ip" && "$public_ip" != "127.0.0.1" ]]; then
                    echo "update add ${domain}. 300 A ${public_ip}"
                fi
                echo "send"
            } > "$nsupdate_file"

            if nsupdate "$nsupdate_file" 2>/dev/null; then
                log_info "nsupdate已发送，正在验证解析结果..."
                sleep 1
                if command -v dig &>/dev/null; then
                    local new_a
                    new_a="$(dig +short @127.0.0.1 "$domain" A | head -n1)"
                    if [[ -n "$new_a" ]]; then
                        log_success "本地DNS已更新: ${domain} -> ${new_a}"
                        rm -f "$nsupdate_file"
                        return 0
                    fi
                fi
                log_warning "nsupdate已执行，但未能立即验证，请检查Bind更新策略/权限"
            else
                log_warning "nsupdate执行失败，可能未开启动态更新或缺少TSIG Key"
            fi
            rm -f "$nsupdate_file"
        else
            log_warning "系统未安装nsupdate，跳过本地自动更新"
        fi

        log_info "建议使用系统提供的DNS管理脚本配置本地域名，或手动编辑区域文件"
        return 0
    fi

    # 未检测到本地Bind时，给出公网DNS配置建议
    if [[ -n "$public_ip" && "$public_ip" != "127.0.0.1" ]]; then
        log_info "未检测到本地Bind(named)，请在公网DNS提供商处配置解析: ${domain} -> ${public_ip}"
    else
        log_warning "无法获取公网IP，也未检测到本地Bind(named)，请手动配置DNS解析"
    fi
}

# 主函数
main() {
    local action="$1"
    local domain="$2"
    local country="$3"
    local state="$4"
    local city="$5"
    local organization="$6"
    local unit="$7"
    local common_name="$8"
    local email="$9"
    local validity="${10}"
    local san="${11}"
    local ca_country="${12}"
    local ca_state="${13}"
    local ca_city="${14}"
    local ca_organization="${15}"
    local ca_unit="${16}"
    local ca_common_name="${17}"
    local ca_email="${18}"
    local ca_validity="${19}"
    
    case "$action" in
        "install")
            log_info "开始SSL证书申请流程..."
            
            # 检查参数
            if [[ -z "$domain" ]]; then
                log_error "域名参数不能为空"
                exit 1
            fi
            
    # 设置默认值
    country="${country:-CN}"
    state="${state:-Beijing}"
    city="${city:-Beijing}"
    organization="${organization:-skills}"
    unit="${unit:-system}"
    common_name="${common_name:-${domain}}"
    email="${email:-admin@${domain}}"
    validity="${validity:-1825}"
            
            # 执行证书申请流程
            check_ssl_deps
            configure_openssl
            create_ca_cert "$ca_country" "$ca_state" "$ca_city" "$ca_organization" "$ca_unit" "$ca_common_name" "$ca_email" "$ca_validity"
            generate_server_cert "$domain" "$country" "$state" "$city" "$organization" "$unit" "$common_name" "$email" "$validity" "$san"
            configure_apache_ssl "$domain"
            update_system_trust
            configure_dns "$domain"
            
            log_success "SSL证书申请完成！"
            log_info "证书文件位置:"
            log_info "  - 服务器证书: /etc/ssl/${domain}.crt"
            log_info "  - 服务器私钥: /etc/ssl/${domain}.key"
            log_info "  - CA根证书: /etc/pki/CA/cacert.pem"
            log_info "  - Apache配置: /etc/httpd/conf.d/${domain}_ssl.conf"
            ;;
        "enable-ssl")
            log_info "开始配置Apache SSL..."
            
            # 检查参数
            if [[ -z "$domain" ]]; then
                log_error "域名参数不能为空"
                exit 1
            fi
            
            # 读取域名-证书关联配置
            local base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
            local domain_cert_config_file="$base_dir/config/ssl-domain-cert.json"
            local cert_name="$domain"
            
            # 获取该域名使用的证书名称
            if [[ -f "$domain_cert_config_file" ]]; then
                if command -v jq >/dev/null 2>&1; then
                    local cert_name_from_config=$(jq -r ".[\"$domain\"] // \"$domain\"" "$domain_cert_config_file" 2>/dev/null || echo "$domain")
                    cert_name="$cert_name_from_config"
                else
                    # 使用grep作为后备方案
                    local cert_name_line=$(grep -o "\"$domain\"[[:space:]]*:[[:space:]]*\"[^\"]\+\"" "$domain_cert_config_file" 2>/dev/null | head -1)
                    if [[ -n "$cert_name_line" ]]; then
                        cert_name=$(echo "$cert_name_line" | sed 's/.*:[[:space:]]*"\([^"]*\)".*/\1/')
                    fi
                fi
            fi
            
            # 检查证书文件是否存在
            local cert_file="/etc/pki/tls/${cert_name}.crt"
            local key_file="/etc/pki/tls/${cert_name}.key"
            local ca_cert_file="/etc/pki/CA/cacert.pem"
            
            # 如果证书文件不存在，尝试查找www.前缀或去掉www.前缀的证书
            if [[ ! -f "$cert_file" ]] || [[ ! -f "$key_file" ]]; then
                local found_cert=false
                
                # 如果证书名称是www.开头，尝试查找去掉www.的证书
                if [[ "$cert_name" =~ ^www\.(.+)$ ]]; then
                    local base_cert_name="${BASH_REMATCH[1]}"
                    local base_cert_file="/etc/pki/tls/${base_cert_name}.crt"
                    local base_key_file="/etc/pki/tls/${base_cert_name}.key"
                    
                    if [[ -f "$base_cert_file" ]] && [[ -f "$base_key_file" ]]; then
                        cert_name="$base_cert_name"
                        cert_file="$base_cert_file"
                        key_file="$base_key_file"
                        found_cert=true
                        log_info "找到基础域名证书: $base_cert_name"
                    fi
                else
                    # 如果证书名称不是www.开头，尝试查找www.前缀的证书
                    local www_cert_name="www.${cert_name}"
                    local www_cert_file="/etc/pki/tls/${www_cert_name}.crt"
                    local www_key_file="/etc/pki/tls/${www_cert_name}.key"
                    
                    if [[ -f "$www_cert_file" ]] && [[ -f "$www_key_file" ]]; then
                        cert_name="$www_cert_name"
                        cert_file="$www_cert_file"
                        key_file="$www_key_file"
                        found_cert=true
                        log_info "找到www.前缀证书: $www_cert_name"
                    fi
                fi
                
                # 如果仍然找不到证书文件，报错
                if [[ "$found_cert" == false ]]; then
                    log_error "证书文件不存在: $cert_file"
                    log_error "私钥文件不存在: $key_file"
                    log_error "请先使用'申请证书'功能生成证书或上传证书文件"
                    log_error "已尝试查找的证书文件:"
                    log_error "  - /etc/pki/tls/${cert_name}.crt"
                    if [[ "$cert_name" =~ ^www\. ]]; then
                        log_error "  - /etc/pki/tls/${cert_name#www.}.crt"
                    else
                        log_error "  - /etc/pki/tls/www.${cert_name}.crt"
                    fi
                    exit 1
                fi
            fi
            
            # CA根证书可选（某些证书可能不需要）
            if [[ ! -f "$ca_cert_file" ]]; then
                log_warning "CA根证书文件不存在: $ca_cert_file（某些证书可能不需要CA证书）"
            fi
            
            log_success "证书文件检查通过"
            log_info "  - 域名: $domain"
            log_info "  - 使用的证书: $cert_name"
            log_info "  - 服务器证书: $cert_file"
            log_info "  - 服务器私钥: $key_file"
            if [[ -f "$ca_cert_file" ]]; then
                log_info "  - CA根证书: $ca_cert_file"
            fi
            
            # 配置Apache SSL（使用域名，但证书文件使用cert_name）
            if configure_apache_ssl "$domain" "$cert_name"; then
                log_success "Apache SSL配置完成！"
            else
                log_error "Apache SSL配置失败，请检查错误信息"
                exit 1
            fi
            ;;
        "enable-http-redirect")
            log_info "开始配置HTTP自动跳转HTTPS..."
            
            # 检查参数（域名可选）
            local target_domain="${domain:-}"
            
            # 读取域名-证书关联配置
            local base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
            local domain_cert_config_file="$base_dir/config/ssl-domain-cert.json"
            local domain_cert_map="{}"
            
            if [[ -f "$domain_cert_config_file" ]]; then
                domain_cert_map="$(cat "$domain_cert_config_file" 2>/dev/null || echo "{}")"
            fi
            
            # 如果没有指定域名，从配置中获取所有域名
            local domains_to_configure=()
            if [[ -n "$target_domain" ]]; then
                domains_to_configure=("$target_domain")
            else
                # 从配置文件中提取所有域名（使用jq如果可用，否则使用grep）
                if command -v jq >/dev/null 2>&1 && [[ -f "$domain_cert_config_file" ]]; then
                    while IFS= read -r domain; do
                        if [[ -n "$domain" ]]; then
                            domains_to_configure+=("$domain")
                        fi
                    done < <(echo "$domain_cert_map" | jq -r 'keys[]' 2>/dev/null)
                else
                    # 使用grep作为后备方案
                    while IFS= read -r line; do
                        if [[ "$line" =~ \"([^\"]+)\": ]]; then
                            domains_to_configure+=("${BASH_REMATCH[1]}")
                        fi
                    done <<< "$(echo "$domain_cert_map" | grep -o '\"[^\"]\+\":' 2>/dev/null || echo '')"
                fi
            fi
            
            # 始终从Apache SSL配置文件中获取所有已配置SSL的域名（更可靠）
            # 这样可以确保所有已配置SSL的域名都有HTTP跳转配置
            log_info "从Apache SSL配置文件中获取已配置SSL的域名..."
            if [[ -d "/etc/httpd/conf.d" ]]; then
                for conf_file in /etc/httpd/conf.d/*_ssl.conf; do
                    if [[ -f "$conf_file" ]]; then
                        # 检查是否是有效的SSL配置（包含SSLEngine on）
                        if grep -q "SSLEngine on" "$conf_file" 2>/dev/null; then
                            # 提取ServerName，排除注释行和空行
                            local server_name=$(grep -i "^[[:space:]]*ServerName[[:space:]]" "$conf_file" 2>/dev/null | grep -v "^[[:space:]]*#" | head -1 | sed 's/.*ServerName[[:space:]]*\([^[:space:]#]*\).*/\1/' | sed 's/[[:space:]]*$//')
                            # 如果ServerName为空或包含特殊字符（可能是注释），跳过
                            if [[ -n "$server_name" ]] && [[ ! "$server_name" =~ ^[[:space:]]*$ ]] && [[ ! "$server_name" =~ ^# ]] && [[ "$server_name" =~ ^[a-zA-Z0-9.-]+$ ]]; then
                                # 检查是否已经在列表中，避免重复
                                local already_added=false
                                for existing_domain in "${domains_to_configure[@]}"; do
                                    if [[ "$existing_domain" == "$server_name" ]]; then
                                        already_added=true
                                        break
                                    fi
                                done
                                if [[ "$already_added" == "false" ]]; then
                                    domains_to_configure+=("$server_name")
                                    log_info "从SSL配置文件发现域名: $server_name"
                                fi
                            fi
                        fi
                    fi
                done
            fi
            
            # 如果仍然没有找到域名，尝试从域名-证书配置文件中获取
            if [[ ${#domains_to_configure[@]} -eq 0 ]]; then
                log_warning "未从Apache配置中找到域名，尝试从域名-证书配置文件中获取"
                if command -v jq >/dev/null 2>&1 && [[ -f "$domain_cert_config_file" ]]; then
                    while IFS= read -r domain; do
                        if [[ -n "$domain" ]]; then
                            domains_to_configure+=("$domain")
                        fi
                    done < <(echo "$domain_cert_map" | jq -r 'keys[]' 2>/dev/null)
                fi
            fi
            
            if [[ ${#domains_to_configure[@]} -eq 0 ]]; then
                log_error "未找到要配置的域名，请先为域名配置SSL证书"
                exit 1
            fi
            
            log_info "将为以下域名配置HTTP跳转HTTPS: ${domains_to_configure[*]}"
            
            # 确保mod_rewrite模块已启用
            log_info "检查mod_rewrite模块..."
            if ! grep -q "LoadModule rewrite_module" /etc/httpd/conf/httpd.conf && ! grep -q "LoadModule rewrite_module" /etc/httpd/conf.d/*.conf 2>/dev/null; then
                echo "LoadModule rewrite_module modules/mod_rewrite.so" >> /etc/httpd/conf/httpd.conf
                log_info "已启用mod_rewrite模块"
            else
                log_info "mod_rewrite模块已启用"
            fi
            
            # 为每个域名配置HTTP跳转
            for domain_item in "${domains_to_configure[@]}"; do
                log_info "配置域名: $domain_item"
                
                # 获取该域名使用的证书名称（虽然HTTP跳转不需要证书，但保留此逻辑以备后用）
                local cert_name="$domain_item"
                if command -v jq >/dev/null 2>&1 && [[ -f "$domain_cert_config_file" ]]; then
                    local cert_name_from_config=$(echo "$domain_cert_map" | jq -r ".[\"$domain_item\"].certName // .[\"$domain_item\"] // \"$domain_item\"" 2>/dev/null || echo "$domain_item")
                    cert_name="$cert_name_from_config"
                fi
                
                # 检查并删除旧格式的HTTP配置文件（如 xm666.fun.conf），避免冲突
                # 需要检查所有可能包含该域名的配置文件
                local old_conf_file="/etc/httpd/conf.d/${domain_item}.conf"
                if [[ -f "$old_conf_file" ]]; then
                    # 检查是否是HTTP配置（不包含SSLEngine，且监听80端口）
                    if ! grep -q "SSLEngine" "$old_conf_file" 2>/dev/null && grep -q "<VirtualHost.*:80>" "$old_conf_file" 2>/dev/null; then
                        # 检查是否包含该域名的ServerName或ServerAlias
                        if grep -q "ServerName.*${domain_item}" "$old_conf_file" 2>/dev/null || 
                           grep -q "ServerAlias.*${domain_item}" "$old_conf_file" 2>/dev/null ||
                           grep -q "ServerName.*www\.${domain_item}" "$old_conf_file" 2>/dev/null ||
                           grep -q "ServerAlias.*www\.${domain_item}" "$old_conf_file" 2>/dev/null; then
                            log_warning "发现旧格式HTTP配置文件: $old_conf_file，将备份后删除以避免冲突"
                            mv "$old_conf_file" "${old_conf_file}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || rm -f "$old_conf_file"
                            log_info "已备份/删除旧格式配置文件: $old_conf_file"
                        fi
                    fi
                fi
                
                # 同时检查www.前缀的域名对应的旧配置文件（如果当前域名是www.xxx，检查xxx.conf）
                if [[ "$domain_item" =~ ^www\.(.+)$ ]]; then
                    local base_domain="${BASH_REMATCH[1]}"
                    local base_conf_file="/etc/httpd/conf.d/${base_domain}.conf"
                    if [[ -f "$base_conf_file" ]]; then
                        # 检查是否是HTTP配置且包含www.前缀的ServerAlias
                        if ! grep -q "SSLEngine" "$base_conf_file" 2>/dev/null && grep -q "<VirtualHost.*:80>" "$base_conf_file" 2>/dev/null; then
                            if grep -q "ServerAlias.*www\.${base_domain}" "$base_conf_file" 2>/dev/null || 
                               grep -q "ServerName.*www\.${base_domain}" "$base_conf_file" 2>/dev/null; then
                                log_warning "发现旧格式HTTP配置文件（包含www别名）: $base_conf_file，将备份后删除以避免冲突"
                                mv "$base_conf_file" "${base_conf_file}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || rm -f "$base_conf_file"
                                log_info "已备份/删除旧格式配置文件: $base_conf_file"
                            fi
                        fi
                    fi
                fi
                
                # 如果当前域名是基础域名（非www），检查是否有包含www别名的旧配置文件
                if [[ ! "$domain_item" =~ ^www\. ]]; then
                    local www_conf_file="/etc/httpd/conf.d/${domain_item}.conf"
                    if [[ -f "$www_conf_file" ]]; then
                        # 检查是否包含www.前缀的ServerAlias
                        if ! grep -q "SSLEngine" "$www_conf_file" 2>/dev/null && grep -q "<VirtualHost.*:80>" "$www_conf_file" 2>/dev/null; then
                            if grep -q "ServerAlias.*www\.${domain_item}" "$www_conf_file" 2>/dev/null; then
                                log_warning "发现旧格式HTTP配置文件（包含www别名）: $www_conf_file，将备份后删除以避免冲突"
                                mv "$www_conf_file" "${www_conf_file}.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || rm -f "$www_conf_file"
                                log_info "已备份/删除旧格式配置文件: $www_conf_file"
                            fi
                        fi
                    fi
                fi
                
                # 创建或更新HTTP虚拟主机配置（自动跳转到HTTPS）
                local http_vhost_conf="/etc/httpd/conf.d/${domain_item}_http.conf"
                
                # 检查对应的SSL配置文件，获取ServerAlias（如果有）
                local ssl_conf_file="/etc/httpd/conf.d/${domain_item}_ssl.conf"
                local server_aliases=""
                if [[ -f "$ssl_conf_file" ]]; then
                    # 提取ServerAlias（可能有多行）
                    while IFS= read -r alias_line; do
                        if [[ "$alias_line" =~ ServerAlias[[:space:]]+(.+) ]]; then
                            if [[ -n "$server_aliases" ]]; then
                                server_aliases="${server_aliases}\n    ServerAlias ${BASH_REMATCH[1]}"
                            else
                                server_aliases="ServerAlias ${BASH_REMATCH[1]}"
                            fi
                        fi
                    done < "$ssl_conf_file"
                fi
                
                cat > "$http_vhost_conf" <<EOF
# HTTP虚拟主机配置 - ${domain_item} (自动跳转到HTTPS)
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')
<VirtualHost *:${APACHE_HTTP_PORT}>
    ServerName ${domain_item}
$(if [[ -n "$server_aliases" ]]; then echo "    $server_aliases"; fi)
    
    # 自动跳转到HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
    
    # 日志配置
    ErrorLog /var/log/httpd/${domain_item}-http-error.log
    CustomLog /var/log/httpd/${domain_item}-http-access.log combined
</VirtualHost>
EOF
                log_info "已创建HTTP跳转配置: $http_vhost_conf"
                
                # 验证配置文件语法
                if httpd -t -f /etc/httpd/conf/httpd.conf 2>/dev/null; then
                    log_info "Apache配置语法验证通过"
                else
                    log_warning "Apache配置语法验证失败，请检查配置"
                fi
            done
            
            # 验证Apache配置语法
            log_info "验证Apache配置语法..."
            if httpd -t 2>/dev/null; then
                log_success "Apache配置语法验证通过"
            else
                log_error "Apache配置语法验证失败，请检查配置"
                httpd -t 2>&1 | while read -r line; do
                    log_error "$line"
                done
                exit 1
            fi
            
            # 重启Apache使配置生效
            log_info "重启Apache服务..."
            if systemctl restart httpd 2>/dev/null; then
                log_success "Apache服务重启成功"
                
                # 等待服务启动
                sleep 2
                
                # 验证Apache服务状态
                if systemctl is-active --quiet httpd; then
                    log_success "Apache服务运行正常"
                else
                    log_warning "Apache服务可能未正常运行，请检查: systemctl status httpd"
                fi
                
                # 验证端口监听
                if netstat -tlnp 2>/dev/null | grep -q ":${APACHE_HTTP_PORT} " || ss -tlnp 2>/dev/null | grep -q ":${APACHE_HTTP_PORT} "; then
                    log_success "${APACHE_HTTP_PORT}端口已监听"
                else
                    log_warning "${APACHE_HTTP_PORT}端口可能未监听，请检查防火墙配置"
                fi
            else
                log_error "Apache服务重启失败，请手动重启: systemctl restart httpd"
                log_error "请检查错误日志: journalctl -u httpd -n 50"
                exit 1
            fi
            
            log_success "HTTP自动跳转HTTPS配置完成！"
            log_info "配置已生效，HTTP请求将自动跳转到HTTPS"
            log_info "提示: 如果跳转不生效，请检查防火墙是否开放了${APACHE_HTTP_PORT}和${APACHE_HTTPS_PORT}端口"
            ;;
        *)
            log_error "未知操作: $action"
            echo "用法: $0 install <domain> [country] [state] [city] [organization] [unit] [email] [validity] [san]"
            echo "     $0 enable-ssl <domain>"
            echo "     $0 enable-http-redirect [domain]"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
