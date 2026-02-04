# XM邮件管理系统 - 更新操作指南 V5.1.0

## 概述

本文档详细记录了XM邮件管理系统的所有更新操作、版本升级步骤和系统维护指南。适用于系统管理员进行版本升级、功能更新和系统维护。

## 🎉 最新版本 - V5.1.0 (2026-02-04) - 公网 DNS 适配、顶部栏手机端与默认菜单折叠

### 🎊 版本亮点

**V5.1.0 将 README 与 UPDATE_GUIDE 统一更新至 5.1.0；系统状态与 Mail 页公网 DNS 自动识别与展示；顶部导航栏个人资料/布局/退出等适配手机端（下拉菜单）；所有用户默认侧栏折叠。**

### 📋 最新更新

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 5.1.0；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **公网 DNS 适配**：系统状态（左侧导航）DNS 解析在公网 DNS 时显示公网域名/公网主机名及蓝色提示；无 system-settings 的 dns 时根据 named 是否运行自动推断公网/本地（使用 8.8.8.8 解析并返回 dns_type）；Mail 页服务检查（/api/mail/service-status）同步从本机获取域名并推断公网，推荐语与「请安装 Bind」区分，域名显示使用实际配置
- **顶部导航栏手机端适配**：右上角整行适配手机端；手机端采用头像+用户名+「更多」下拉菜单（个人资料、布局、退出登录），桌面端保持完整显示；整行高度与间距响应式，点击空白关闭下拉
- **默认菜单折叠**：所有用户默认侧栏折叠（sidebarCollapsed 默认 true），需点击菜单按钮展开

### 📋 主要更新内容

- **README.md**：标题与「版本更新」章节更新为 V5.1.0；版本历史表新增 V5.1.0 行
- **UPDATE_GUIDE.md**：标题更新为 V5.1.0；新增「最新版本 V5.1.0」章节；原 V5.0.4 内容移入「版本历史记录」
- **backend/dispatcher/server.js**：/api/system-status 无 dns 时根据 named 推断公网、覆盖域名/主机名；/api/mail/service-status 中 checkDNSResolution 无 domain 时 getDomainFromSystem + named 推断，getDomainFromSystem/checkDomainResolution 提前定义
- **frontend/src/components/Layout.vue**：顶部 header 响应式（md 下完整右侧、md 以下头像+用户名+下拉）；headerMenuOpen 状态与蒙层关闭；dns 区公网时提示与公网域名/公网主机名标签、dns_type 可选链
- **frontend/src/modules/Mail.vue**：DNS 未配置时域名显示使用 dns.domain || dns.mail_domain
- **frontend/src/components/Layout.vue**：sidebarCollapsed 默认值改为 true（默认菜单折叠）

### 🔄 升级步骤

- 若已部署：拉取代码后无需数据库或配置迁移；重启调度层与前端生效：`./start.sh rebuild` 与 `./start.sh restart`（或仅刷新浏览器）。

```bash
cd /bash
git pull
./start.sh rebuild
./start.sh restart
```

---

## 🎉 版本历史记录

### V5.0.4 (2026-02-03) - 写邮件/列表深色、邮件移动与日志查看适配

### 🎊 版本亮点（V5.0.4）

**V5.0.4 将 README 与 UPDATE_GUIDE 统一更新至 5.0.4；写邮件页与邮件列表深色主题及可读性完善；邮件移动按钮与后端按 base_message_id 移动逻辑修复，避免刷新后出现在两个文件夹；左侧「日志查看」按钮及对话框深色适配。**

#### 📋 最新更新（V5.0.4）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 5.0.4；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **写邮件与列表深色主题**：写邮件页（标题栏、收件人/抄送/主题/附件/正文、草稿提示、操作栏、发送进度、通知）全面适配深色模式；深色主题下各文件夹邮件列表项（发件人、主题、日期、徽章、操作按钮）改为白色/浅色以提升可读性
- **邮件移动与数据库逻辑**：详情页「移动到」使用 `selectedEmail.value?.id` 修复点击无反应；移动成功后从当前列表移除该邮件并关闭详情；后端 `move_email` 按 base_message_id 更新同封邮件所有记录，实现真实移动，刷新后不再在两个文件夹同时出现
- **日志查看深色适配**：左侧导航栏「日志查看」按钮（边框与悬停）及日志查看对话框（遮罩、容器、筛选、统计、内容区、底部栏）全面适配深色主题

#### 📋 主要更新内容（V5.0.4）

- **README.md**：标题与「版本更新」章节更新为 V5.0.4；版本历史表新增 V5.0.4 行
- **UPDATE_GUIDE.md**：标题更新为 V5.0.4；新增「最新版本 V5.0.4」章节；原 V5.0.3 内容移入「版本历史记录」
- **frontend/src/modules/Mail.vue**：写邮件区深色样式；列表项发件人/主题/日期等 dark:text-white 等；moveEmailToFolder 成功时 filter 移除、closeEmailDetail；handleMoveFolderAction 使用 selectedEmail.value?.id
- **frontend/src/components/Layout.vue**：日志查看按钮与日志查看对话框深色样式
- **backend/scripts/mail_db.sh**：move_email 按 message_id 取 base_message_id，UPDATE 所有 SUBSTRING_INDEX(message_id,'_',1) 匹配记录，移动至已删除时写 original_folder_id

#### 🔄 升级步骤（V5.0.4）

- 若已部署：拉取代码后无需数据库或配置迁移；重启调度层与前端生效：`./start.sh rebuild` 与 `./start.sh restart`（或仅刷新浏览器）。

```bash
cd /bash
git pull
./start.sh rebuild
./start.sh restart
```

---

### V5.0.3 (2026-02-03) - 深色主题完善与对话框/左侧导航适配

### 🎊 版本亮点（V5.0.3）

**V5.0.3 将 README 与 UPDATE_GUIDE 统一更新至 5.0.3；邮件页与仪表盘深色主题完善；申请证书/管理SSL/安装服务等对话框底部留白收紧；左侧系统状态/日志查看/命令终端适配菜单折叠与深色主题；系统状态对话框深色适配。**

#### 📋 最新更新（V5.0.3）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 5.0.3；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **深色主题完善**：邮件页整体、邮件详情模态框（头部/发件人收件人/附件/正文/引用块/错误与空状态/底部操作栏）、各文件夹视图（收件箱/已发送/草稿/垃圾/已删除）及服务警告框全面适配深色模式；仪表盘高级功能卡片（备份功能、垃圾邮件过滤、广播）与申请证书、管理SSL 一致适配深色（彩色边框、图标背景与图标颜色）
- **对话框留白与左侧导航**：申请证书、管理SSL、安装服务等对话框底部留白收紧；左侧导航「系统状态」「日志查看」「命令终端」点击后固定关闭侧栏以适配右侧「菜单折叠」，三按钮与系统状态对话框全面适配深色主题

#### 📋 主要更新内容（V5.0.3）

- **README.md**：标题与「版本更新」章节更新为 V5.0.3；版本历史表新增 V5.0.3 行
- **UPDATE_GUIDE.md**：标题更新为 V5.0.3；新增「最新版本 V5.0.3」章节；原 V5.0.2 内容移入「版本历史记录」
- **frontend**：Mail.vue 邮件页与详情模态框、各文件夹视图、服务警告框深色适配；Dashboard.vue 高级功能按钮与对话框底部留白；Layout.vue 左侧系统状态/日志查看/命令终端点击关闭侧栏及系统状态对话框深色适配

#### 🔄 升级步骤（V5.0.3）

- 若已部署：拉取代码后无需数据库或配置迁移；重启前端或刷新页面即可生效：`./start.sh rebuild` 与 `./start.sh restart`（或仅刷新浏览器）。

```bash
cd /bash
git pull
./start.sh rebuild
./start.sh restart
```

---

### V5.0.2 (2026-02-03) - HTTP 跳转状态与邮件页/草稿箱完善

### 🎊 版本亮点（V5.0.2）

**V5.0.2 将 README 与 UPDATE_GUIDE 统一更新至 5.0.2；HTTP 自动跳转 HTTPS 按钮状态识别完善；邮件页主内容区「共 N 封」与侧栏仅收件箱计数；草稿箱去重、权限与点击即编辑。**

#### 📋 最新更新（V5.0.2）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 5.0.2；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **HTTP 跳转状态识别**：后端 /api/cert/http-redirect-status 增加 parseHttpRedirectConfig 统一解析、fs 读取失败时 sudo 回退读取 *_http.conf、无 *_http.conf 时检测 mailmgmt.conf/mail-ops.conf 跳转块，按钮能正确识别已配置/未配置
- **邮件页统计**：主内容区收件箱/已发送/草稿箱/垃圾邮件/已删除/自定义文件夹标题旁显示「共 N 封」；侧栏除收件箱外删除邮件统计（仅收件箱保留未读角标）
- **草稿箱列表与编辑**：列表去重对草稿箱/已删除按 email.id 区分，避免同主题同时间被合并；mail_db.sh get_email_detail 对 folder_id=3（草稿箱）按发件人校验权限，草稿作者可读取/编辑；草稿列表点击卡片直接 editDraft 进入写邮件界面

#### 📋 主要更新内容（V5.0.2）

- **README.md**：标题与「版本更新」章节更新为 V5.0.2；版本历史表新增 V5.0.2 行
- **UPDATE_GUIDE.md**：标题更新为 V5.0.2；新增「最新版本 V5.0.2」章节；原 V5.0.1 内容移入「版本历史记录」
- **backend/dispatcher/server.js**：http-redirect-status 中 parseHttpRedirectConfig、sudo 回退、mailmgmt/mail-ops 检测
- **backend/scripts/mail_db.sh**：get_email_detail 中 folder_id=3 与 2 一同按发件人校验
- **frontend/src/modules/Mail.vue**：主内容区「共 N 封」、侧栏删除非收件箱计数、草稿/已删除按 id 去重、草稿列表 @click 改为 editDraft

#### 🔄 升级步骤（V5.0.2）

- 若已部署：拉取代码后无需数据库或配置迁移；重启调度层与前端生效：`./start.sh rebuild` 与 `./start.sh restart`（或仅重启 dispatcher 与刷新前端）。

```bash
cd /bash
git pull
./start.sh rebuild
./start.sh restart
```

---

### V5.0.1 (2026-02-03) - SSL 证书管理完善

### 🎊 版本亮点（V5.0.1）

**V5.0.1 将 README 与 UPDATE_GUIDE 统一更新至 5.0.1；SSL 证书管理中禁用 HTTP 跳转与禁用域名 SSL 的后端逻辑完善，确保禁用后配置真正生效。**

#### 📋 最新更新（V5.0.1）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 5.0.1；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **禁用 HTTP 跳转完善**：除删除 *_http.conf 与状态文件外，从 mailmgmt.conf、mail-ops.conf 中移除 HTTPS 跳转块（正则匹配「自动跳转到HTTPS」与「HTTPS重定向」两种格式），写回配置后重启 Apache，解决禁用后仍自动跳转的问题
- **禁用域名 SSL 完善**：使用 sudo rm -f 删除该域名的 _ssl.conf / _http.conf（/etc/httpd/conf.d 需 root）；从其他 *_ssl.conf 中移除该域名的 ServerAlias 行，避免通过 www/根域互为主别名时仍能访问 HTTPS；从 ssl-domain-cert.json 移除该域名；语法检查后重启 Apache

#### 📋 主要更新内容（V5.0.1）

- **README.md**：标题与「版本更新」章节更新为 V5.0.1；版本历史表新增 V5.0.1 行
- **UPDATE_GUIDE.md**：标题更新为 V5.0.1；新增「最新版本 V5.0.1」章节；原 V5.0.0 内容移入「版本历史记录」
- **backend/dispatcher/server.js**：disable-http-redirect 中清理 mailmgmt.conf、mail-ops.conf 跳转块；disable-ssl 中 sudo rm 删除配置、扫描其他 _ssl.conf 移除 ServerAlias、更新 ssl-domain-cert.json

#### 🔄 升级步骤（V5.0.1）

- 若已部署：拉取代码后无需数据库或配置迁移；重启调度层使后端逻辑生效：`./start.sh restart` 或仅重启 dispatcher。禁用 HTTP 跳转/禁用域名 SSL 需服务器具备 sudo 权限（rm/cp/httpd -t/systemctl restart httpd）。

```bash
cd /bash
git pull
./start.sh restart
```

---

### V5.0.0 (2026-02-03) - 命令终端 euser 与用户日志升级

### 🎊 版本亮点（V5.0.0）

**V5.0.0 将 README 与 UPDATE_GUIDE 统一更新至 5.0.0；命令终端改用 euser 用户（start.sh 自动创建 euser、无 sudo，密码随机高强度）；移除 Layout 中旧命令终端逻辑，仅保留 WebSocket 终端；用户日志按行记录完整命令，不再逐字符记录。**

#### 📋 最新更新（V5.0.0）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 5.0.0；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **命令终端改用 euser**：start.sh 步骤 2.1 创建 euser（useradd -m -s /bin/bash euser），密码从 /etc/mail-ops/euser.pass 读取（首次随机 openssl rand -base64 24）；不配置 sudoers；server.js 终端 pty 以 sudo -u euser /bin/bash -l 运行，cwd /tmp；导航栏显示「命令终端 (euser)」
- **移除旧命令终端**：Layout.vue 删除 terminalInput/terminalOutput/commandHistory/historyIndex/isExecuting/terminalOutputRef、executeCommand、handleTerminalKeydown 等，showCommandTerminal 仅打开 WebSocket 终端对话框
- **用户日志升级**：server.js 终端输入按 session.inputBuffer 缓冲，仅在收到换行（Enter）时将完整命令行写入一条 TERMINAL_WS_INPUT，避免逐字符刷屏

#### 📋 主要更新内容（V5.0.0）

- **README.md**：标题与「版本更新」章节更新为 V5.0.0；版本历史表新增 V5.0.0 行
- **UPDATE_GUIDE.md**：标题更新为 V5.0.0；新增「最新版本 V5.0.0」章节；原 V4.9.5 内容移入「版本历史记录」
- **start.sh**：步骤 2.1 创建 euser、euser.pass 随机生成、chpasswd
- **backend/dispatcher/server.js**：pty 以 sudo -u euser 运行、session.inputBuffer、按行写 TERMINAL_WS_INPUT
- **frontend**：Layout.vue（删除旧终端逻辑、命令终端按钮显示 euser）

#### 🔄 升级步骤（V5.0.0）

- 若已部署：拉取代码后执行 `./start.sh start` 或至少执行创建 euser 的逻辑（或手动创建 euser 及 /etc/mail-ops/euser.pass），然后 `./start.sh rebuild` 与 `./start.sh restart`（或重启 dispatcher）。

```bash
cd /bash
git pull
./start.sh start
# 或仅需终端时：手动创建 euser 与 euser.pass 后
./start.sh rebuild
./start.sh restart
```

---

### V4.9.5 (2026-02-03) - 邮件页各邮箱总数统计

### 🎊 版本亮点（V4.9.5）

**V4.9.5 将 README 与 UPDATE_GUIDE 统一更新至 4.9.5；邮件页为主内容区标题旁增加当前文件夹邮件总数显示，收件箱、已发送、草稿箱、垃圾邮件、已删除及自定义文件夹均显示该文件夹内邮件总数；侧栏仅保留收件箱未读计数，已发送与垃圾邮件旁不再显示计数。**

#### 📋 最新更新（V4.9.5）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 4.9.5；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **邮件页各邮箱总数统计**：主内容区邮箱标题旁显示「共 N 封」；切换文件夹时根据当前 folderId 显示对应总数（收件箱、已发送、草稿、垃圾、已删除、自定义文件夹）；总数由列表接口 total 或单独统计接口提供
- **侧栏计数简化**：侧栏仅保留收件箱未读计数；已发送、垃圾邮件旁不再显示数字角标，与收件箱以外的文件夹一致

#### 📋 主要更新内容（V4.9.5）

- **README.md**：标题与「版本更新」章节更新为 V4.9.5；版本历史表新增 V4.9.5 行
- **UPDATE_GUIDE.md**：标题更新为 V4.9.5；新增「最新版本 V4.9.5」章节；原 V4.9.4 内容移入「版本历史记录」
- **frontend**：Mail.vue（主内容区标题旁显示当前文件夹邮件总数、侧栏仅收件箱显示未读计数）

#### 🔄 升级步骤（V4.9.5）

- 前端：`git pull` 后执行 `./start.sh rebuild` 或 `cd frontend && npm run build`，无需数据库或配置变更。

---

### V4.9.4 (2026-02-03) - 移除 DNS 配置与邮件未读统一

### 🎊 版本亮点（V4.9.4）

**V4.9.4 将 README 与 UPDATE_GUIDE 统一更新至 4.9.4；系统设置移除 DNS 配置（页面、逻辑、启动清理、配置与备份均不再包含 dns）；邮件页已发送/垃圾邮件未读计数与收件箱逻辑与样式统一；清理 Settings 与后端 DNS 相关残留代码。**

#### 📋 最新更新（V4.9.4）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 4.9.4；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **系统设置移除 DNS 配置**：Settings.vue 删除 DNS 配置整块模板、dns 相关 refs/函数（detectDnsType、saveDnsConfig、getPublicDomain）、onMounted 自动保存；start.sh 删除 RESET_DNS_ON_START 及「跳过DNS清理」「检测到公网DNS配置但缺少状态字段」等逻辑；config/system-settings.json 不再包含 dns 段
- **配置保存与备份不包含 DNS**：POST /api/system-settings 在写入前 `delete mergedSettings.dns`，主配置与时间戳备份均不写入 dns；GET 返回前 `delete systemSettings.dns`；默认配置对象移除 dns；后端移除「同时保护DNS配置中的管理员邮箱」、合并前 DNS 恢复/保留、合并后「保护DNS配置字段」等整块逻辑
- **邮件页未读计数与收件箱一致**：新增 sentUnreadCount、spamUnreadCount，由 loadMailStats 统一更新；每次加载完邮件后都调用 loadMailStats；侧栏已发送/垃圾邮件使用与收件箱相同的红粉渐变+脉冲样式
- **残留代码清理**：Settings.vue 删除 enableSSL 函数及 sslDomain/sslCheckStatus/sslEnabling 使用；server.js 删除 DNS 保护/合并相关代码块

#### 📋 主要更新内容（V4.9.4）

- **README.md**：标题与「版本更新」章节更新为 V4.9.4；版本历史表新增 V4.9.4 行，保留既有版本列表
- **UPDATE_GUIDE.md**：标题更新为 V4.9.4；新增「最新版本 V4.9.4」章节；原 V4.9.3 内容移入「版本历史记录」
- **frontend**：Settings.vue（移除 DNS 模板与逻辑、移除 enableSSL）；Mail.vue（sentUnreadCount/spamUnreadCount、loadMailStats 每次加载后调用、样式统一）
- **backend/dispatcher/server.js**：POST 保存前 delete mergedSettings.dns；GET 返回前 delete systemSettings.dns；默认配置移除 dns；GET 读取分支移除「确保 dns」与「adminEmail 同步到 dns」；POST 移除「保护 DNS 管理员邮箱」、合并前 DNS 恢复/保留、合并后「保护 DNS 配置字段」整块
- **start.sh**：移除 RESET_DNS_ON_START 及 DNS 清理/状态补充逻辑；文件头注释移除 RESET_DNS_ON_START 说明
- **config**：system-settings.json 示例/现有配置不再包含 dns（新保存与备份均无 dns）

#### 🔄 升级步骤（V4.9.4）

- 若已部署：拉取代码后无需数据库或配置迁移；下次保存系统设置或自动备份生成的新文件将不再包含 dns。旧备份文件中若含 dns，GET 接口返回时已剥离，前端不会收到 dns。
- 前端与调度层：`git pull` 后执行 `./start.sh rebuild` 并 `./start.sh restart`（或仅重启 dispatcher）即可。

---

### V4.9.3 (2026-02-02) - 备份反馈与头像/批量创建体验

### 🎊 版本亮点（V4.9.3）

**V4.9.3 将 README 与 UPDATE_GUIDE 统一更新至 4.9.3；完整备份与定时备份一致弹出操作日志框并显示格式化成功信息；修复头像上传成功但 HTTPS 下 404 无法加载（uploads 目录与 cert_setup HTTPS 代理）；批量创建增加密码必填与对话框内提醒。**

#### 📋 最新更新（V4.9.3）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 4.9.3；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **完整备份反馈**：点击「立即执行完整备份」后先关闭备份管理框、弹出「操作日志」框；执行过程中显示脚本输出，完成后追加格式化成功信息（✅ 完整备份完成、📦 备份内容、📁 备份位置、📄 备份文件数、💾 备份大小、🎉 完整备份已成功完成），与定时备份设置成功后的弹框风格一致
- **头像上传与加载**：start.sh 在调度层依赖安装后及调度层启动校验中创建 `uploads/avatars` 并 `chown -R xm:xm`；cert_setup.sh 为所有生成的 HTTPS 虚拟主机添加 `Location /uploads/` 代理，解决 HTTPS 下 `/uploads/avatars/xxx` 返回 404
- **批量创建密码提醒**：`canBatchCreate` 增加密码非空校验，未填密码时「开始创建」禁用；点击创建时先校验密码，未填则在对话框内显示「请先输入用户密码」、密码框红框，并设置全局 notice

#### 📋 主要更新内容（V4.9.3）

- **README.md**：标题与「版本更新」章节更新为 V4.9.3；版本历史表新增 V4.9.3 行
- **UPDATE_GUIDE.md**：标题更新为 V4.9.3；新增「最新版本 V4.9.3」章节；原 V4.9.2 内容移入「版本历史记录」
- **frontend**：Dashboard.vue（完整备份 executeFullBackup 弹框与格式化、批量创建密码校验与 batchCreatePasswordError）
- **backend/scripts**：cert_setup.sh（4 处 HTTPS 虚拟主机增加 Location /uploads/）
- **start.sh**：创建 uploads/avatars 并 chown，两处（依赖安装后、调度层校验后）

#### 🔄 升级步骤（V4.9.3）

- 若已使用 HTTPS 且此前头像 404：为当前 HTTPS 虚拟主机配置手动添加 `Location /uploads/` 代理后 `systemctl reload httpd`，或重新执行证书/域名配置以触发 cert_setup 重新生成带 `/uploads/` 的配置。
- 前端：`git pull` 后执行 `./start.sh rebuild` 或 `cd frontend && npm install && npm run build` 后重启即可。

---

### V4.9.2 (2026-02-02) - 安全审计与文档版本更新

### 🎊 版本亮点（V4.9.2）

**V4.9.2 为安全审计与文档版本更新，将 README 与 UPDATE_GUIDE 统一更新至 4.9.2；同时完成前端安全加固（批量创建不存明文密码、邮件 HTML XSS 消毒、默认账号提示修正、Register/Reset 安全说明）。**

#### 📋 最新更新（V4.9.2）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 4.9.2；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **Dashboard 安全**：批量创建用户结果不再存储或展示明文密码（类型与 push 对象移除 password 字段）；成功提示为「密码已统一设置，请妥善保管并勿在公开场合展示」
- **Mail.vue XSS 防护**：引入 DOMPurify，邮件 HTML 展示前经 `DOMPurify.sanitize()` 消毒后通过 `sanitizedEmailHtml` 输出，防止跨站脚本
- **start.sh 提示修正**：默认管理员账号提示由「默认管理员账号 admin/admin」改为「管理员账号与密码由 xm-admin.pass 提供，首次部署后请及时修改」
- **Register/Reset 安全说明**：未登录使用 xm 默认凭证 fallback 处增加注释，说明首次部署后须在设置中修改 xm 密码并避免暴露默认凭证

#### 📋 主要更新内容（V4.9.2）

- **README.md**：标题与「版本更新」章节更新为 V4.9.2；版本历史表新增 V4.9.2 行，保留既有版本列表
- **UPDATE_GUIDE.md**：标题更新为 V4.9.2；新增「最新版本 V4.9.2」章节；原 V4.9.1 内容移入「版本历史记录」
- **frontend**：Dashboard.vue、Mail.vue（含 dompurify 依赖）、Register.vue、Reset.vue；start.sh 部署完成页提示文案

#### 🔄 升级步骤（V4.9.2）

若已拉取含 4.9.2 的代码，执行 `./start.sh rebuild` 或在前端目录执行 `npm install` 后构建，以安装 dompurify 并应用前端安全更新。无需变更配置或数据库。

---

### V4.9.1 (2026-02-02) - 版本号与文档同步更新

### 🎊 版本亮点（V4.9.1）

**V4.9.1 为版本号与文档同步更新版本，将 README 与 UPDATE_GUIDE 统一更新至 4.9.1；同时补充脚本与 start.sh 注释的贴合实际更新。**

#### 📋 最新更新（V4.9.1）

- **版本号与文档**：README 与 UPDATE_GUIDE 统一更新至 4.9.1；README 仅保留最新版本与版本列表，UPDATE_GUIDE 保留历史版本并更新最新版本
- **backend/scripts 脚本注释**：所有脚本开头注释按实际用法与逻辑更新（用法说明、case 分支、依赖说明等），不修改版本号与日期；涉及 backup.sh、mail_setup.sh、db_setup.sh、log_viewer.sh、update_repos.sh、test_spam_filter.sh、mail_logger.sh、mail_log_viewer.sh、app_user.sh、cert_setup.sh、dns_setup.sh、mail_receiver.sh、mail_service_logger.sh、security.sh、spam_filter.sh、mail_init.sh、user_manage.sh、dispatcher.sh 等
- **start.sh 注释**：开头注释按实际命令行为更新：早期分支与主流程 case 区分（status/restart/stop/fix-auth/fix-db/help/rebuild/logs/mail-logs 等为早期分支并 exit）、fix-auth 仅重启 httpd 与 mail-ops-dispatcher、fix-db 仅检查连接与提示、logs/mail-logs 委托 log_viewer.sh 与 mail_log_viewer.sh、端口与密码文件来源（config/port-config.json、/etc/mail-ops/xm-admin.pass）等

#### 📋 主要更新内容（文档，V4.9.1）

- **README.md**：标题与「版本更新」章节更新为 V4.9.1；版本历史表新增 V4.9.1 行并补充最新更新说明，保留既有版本列表
- **UPDATE_GUIDE.md**：标题更新为 V4.9.1；新增「最新版本 V4.9.1」章节并补充最新更新；原 V4.9.0 内容保留在「版本历史记录」中

#### 🔄 升级步骤（V4.9.1）

本版本仅文档与版本号变更，无需额外升级步骤。若需与代码库同步：`cd /bash && git pull`，如需前端展示最新版本号可 `cd frontend && npm run build && cd ..` 后 `./start.sh restart`。

---

### V4.9.0 (2026-01-28) - Apache配置与前端跳转逻辑优化

### 🎊 版本亮点（V4.9.0）

**V4.9.0 是一个Apache配置与前端跳转逻辑优化版本，修复了Dashboard自动跳转HTTPS问题、优化了Apache配置清理逻辑避免误删Vue Router配置、完整实现了默认不开启HTTP跳转功能，并修复了脚本中的变量作用域问题，提升了系统的稳定性和用户体验。**

#### 🚫 移除前端自动跳转HTTPS逻辑

**Dashboard自动跳转问题修复**：
- **问题描述**：
  - Dashboard页面会自动跳转到HTTPS，但其他页面不会跳转
  - 前端代码中存在自动跳转逻辑，导致用户体验不一致
  - 用户无法控制是否跳转，违反"默认不开启HTTP跳转"的原则
- **修复内容**：
  - 移除Dashboard.vue中onMounted函数里的自动跳转逻辑
  - HTTP跳转HTTPS应该由用户通过前端按钮或Apache配置来控制
  - 确保所有页面行为一致，默认不跳转
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 删除`window.location.protocol === 'http:'`检查
    - 删除`window.location.replace(httpsUrl)`跳转逻辑
    - 添加注释说明跳转应该由用户控制
- **影响范围**：
  - Dashboard页面不再自动跳转到HTTPS
  - 所有页面行为一致，默认不跳转
  - 提升用户体验和功能可控性

#### 🛡️ Apache配置清理逻辑优化

**LocationMatch配置保护**：
- **问题描述**：
  - 清理HTTP跳转规则时，误删了LocationMatch中的`RewriteEngine On`
  - 导致Vue Router无法工作，Dashboard等页面出现404错误
  - `sed`命令无法区分是否在LocationMatch块中
- **修复内容**：
  - 使用`awk`更精确地处理RewriteEngine On的删除
  - 只删除HTTP跳转相关的RewriteEngine On，保留LocationMatch中的
  - 确保Vue Router必需的配置不被误删
- **技术实现**：
  - 文件：`start.sh`
  - 关键改进：
    - 使用`awk`检查是否在LocationMatch块中
    - 只删除后面跟着HTTPS相关RewriteCond的RewriteEngine On
    - 保留LocationMatch块中的RewriteEngine On
- **影响范围**：
  - Vue Router配置得到保护，不再出现404错误
  - Dashboard等页面可以正常访问
  - 提升系统稳定性

#### 🔒 默认不开启HTTP跳转完整实现

**清理逻辑增强**：
- **问题描述**：
  - 系统重装后仍然会自动跳转到HTTPS
  - 清理逻辑不够全面，可能遗漏某些配置文件
  - 需要确保默认不开启HTTP跳转
- **修复内容**：
  - 增强清理逻辑，强制清理所有可能的HTTP跳转规则
  - 检查并清理所有Apache配置文件中的跳转规则
  - 清理所有`*_http.conf`文件
  - 最后验证确保没有遗漏
- **技术实现**：
  - 文件：`start.sh`
  - 关键改进：
    - 强制清理模板文件中的HTTP跳转规则
    - 强制清理mailmgmt.conf中的HTTP跳转规则
    - 清理所有`*_http.conf`文件
    - 检查所有Apache配置文件并清理跳转规则
    - 最后验证确保没有遗漏
- **影响范围**：
  - 系统重装后默认不开启HTTP跳转
  - 所有HTTP跳转规则都被清理
  - 确保用户完全控制

#### 🐛 脚本错误修复

**变量作用域问题修复**：
- **问题描述**：
  - start.sh中使用了`local`关键字，但不在函数内部
  - 导致错误：`local: can only be used in a function`
  - 脚本执行失败
- **修复内容**：
  - 移除不在函数内的`local`关键字
  - 将变量改为普通全局变量
  - 确保脚本可以正常运行
- **技术实现**：
  - 文件：`start.sh`
  - 关键改进：
    - 移除`local http_redirect_state_file`
    - 移除`local user_enabled_http_redirect`
    - 移除`local enabled_status`
    - 移除`local http_redirect_configs`
- **影响范围**：
  - 脚本可以正常运行
  - 不再出现变量作用域错误
  - 提升系统稳定性

### 📋 主要更新内容

#### 🚫 移除前端自动跳转HTTPS逻辑

**1. `frontend/src/modules/Dashboard.vue`**：
- **移除自动跳转逻辑**：
  - 删除`onMounted`函数中的HTTP到HTTPS自动重定向代码
  - 删除`window.location.protocol === 'http:'`检查
  - 删除`window.location.replace(httpsUrl)`跳转逻辑
  - 添加注释说明跳转应该由用户控制

#### 🛡️ Apache配置清理逻辑优化

**1. `start.sh`**：
- **清理逻辑优化**：
  - 使用`awk`更精确地处理RewriteEngine On的删除
  - 检查是否在LocationMatch块中
  - 只删除HTTP跳转相关的RewriteEngine On
  - 保留LocationMatch块中的RewriteEngine On

**2. `start.sh`**：
- **清理逻辑增强**：
  - 强制清理模板文件中的HTTP跳转规则
  - 强制清理mailmgmt.conf中的HTTP跳转规则
  - 清理所有`*_http.conf`文件
  - 检查所有Apache配置文件并清理跳转规则
  - 最后验证确保没有遗漏

#### 🐛 脚本错误修复

**1. `start.sh`**：
- **变量作用域修复**：
  - 移除不在函数内的`local`关键字
  - 将变量改为普通全局变量
  - 确保脚本可以正常运行

### 🔄 升级步骤

#### 自动升级（推荐）

```bash
# 1. 进入项目目录
cd /bash

# 2. 执行更新（自动拉取最新代码）
./start.sh update

# 3. 重启服务（应用更新）
./start.sh restart
```

#### 手动升级

```bash
# 1. 进入项目目录
cd /bash

# 2. 备份当前配置
cp config/system-settings.json config/system-settings.json.backup

# 3. 拉取最新代码（如果使用Git）
git pull

# 4. 重新构建前端（如果前端代码有更新）
cd frontend
npm install
npm run build
cd ..

# 5. 重启服务
./start.sh restart
```

### ⚠️ 注意事项

1. **前端自动跳转**：
   - Dashboard页面不再自动跳转到HTTPS
   - 所有页面行为一致，默认不跳转
   - HTTP跳转HTTPS应该由用户通过前端按钮或Apache配置来控制

2. **Apache配置保护**：
   - Vue Router配置得到保护，不会误删
   - Dashboard等页面可以正常访问
   - 如果出现404错误，请检查LocationMatch块是否完整

3. **默认不开启HTTP跳转**：
   - 系统重装后默认不开启HTTP跳转
   - 所有HTTP跳转规则都被清理
   - 需要用户手动启用HTTP跳转功能

4. **脚本执行**：
   - 确保脚本可以正常运行
   - 如果出现变量作用域错误，请检查是否在函数内使用了`local`

---

### V4.8.2 (2026-01-28) - HTTP跳转HTTPS功能优化

### 🎊 版本亮点

**V4.8.2 是一个HTTP跳转HTTPS功能优化版本，实现了HTTP跳转功能的默认关闭、启用/禁用功能完善和旧格式配置文件清理增强，提升了用户对功能的控制权，确保HTTP跳转功能正常工作。**

#### 🔄 HTTP跳转默认关闭

**默认状态优化**：
- **问题描述**：
  - HTTP跳转功能默认开启，用户无法控制
  - 即使没有配置文件，系统也可能误判为已启用
  - 用户无法明确知道功能状态
- **修复内容**：
  - HTTP自动跳转HTTPS功能默认关闭
  - 添加状态文件管理（`/bash/config/http-redirect-enabled.json`）
  - 只有用户明确启用后，才检查和使用HTTP跳转配置文件
  - 提升用户对功能的控制权
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`GET /api/cert/http-redirect-status`
  - 关键改进：
    - 检查状态文件是否存在
    - 只有状态文件存在且配置文件存在时，才认为已启用
    - 默认返回关闭状态
- **影响范围**：
  - HTTP跳转功能默认关闭
  - 用户需要手动点击启用
  - 提升功能可控性

#### 🛠️ 启用/禁用功能完善

**启用HTTP跳转**：
- **问题描述**：
  - 启用HTTP跳转后，无法禁用
  - 没有明确的禁用功能
- **修复内容**：
  - 点击"启用HTTP跳转"按钮后，创建状态文件并配置Apache
  - 自动检测并删除冲突的旧格式配置文件
  - 配置完成后自动重启Apache服务
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`POST /api/ops` (action: `enable-http-redirect`)
  - 关键改进：
    - 在执行脚本前创建状态文件
    - 状态文件格式：`{ enabled: true, enabledAt: "ISO时间戳" }`
    - 设置文件权限为755

**禁用HTTP跳转**：
- **问题描述**：
  - 用户无法禁用已启用的HTTP跳转功能
  - 需要手动删除配置文件
- **修复内容**：
  - 添加"禁用HTTP跳转"按钮
  - 删除状态文件和所有HTTP跳转配置文件
  - 验证Apache配置并重启服务
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`POST /api/cert/disable-http-redirect`
  - 关键改进：
    - 删除状态文件
    - 删除所有 `*_http.conf` 配置文件
    - 验证Apache配置语法
    - 重启Apache服务
- **影响范围**：
  - 用户可以随时启用/禁用HTTP跳转
  - 功能控制更加灵活
  - 提升用户体验

#### 🗑️ 旧格式配置文件清理增强

**智能冲突检测**：
- **问题描述**：
  - 旧格式配置文件（如`xm666.fun.conf`）可能包含ServerAlias
  - 这些文件会与新的HTTP跳转配置文件冲突
  - 删除逻辑不够完善，可能遗漏某些配置文件
- **修复内容**：
  - 增强旧格式配置文件的检测逻辑
  - 检测包含ServerAlias的配置文件
  - 检测www前缀域名的配置文件
  - 自动备份并删除所有冲突的旧格式配置文件
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 关键改进：
    - 检查 `${domain_item}.conf` 文件
    - 检查是否包含ServerAlias
    - 检查www前缀域名的配置文件
    - 自动备份并删除冲突文件
- **影响范围**：
  - 自动清理所有冲突的旧格式配置文件
  - 确保HTTP跳转功能正常工作
  - 避免配置冲突问题

### 📋 主要更新内容

#### 🔄 HTTP跳转默认关闭

**1. `backend/dispatcher/server.js`**：
- **状态检查API优化**：
  - 检查状态文件是否存在
  - 只有状态文件存在时才检查配置文件
  - 默认返回关闭状态

**2. `backend/dispatcher/server.js`**：
- **启用时创建状态文件**：
  - 在执行脚本前创建状态文件
  - 设置文件权限为755

#### 🛠️ 启用/禁用功能完善

**1. `backend/dispatcher/server.js`**：
- **禁用HTTP跳转API**：
  - 删除状态文件
  - 删除所有HTTP跳转配置文件
  - 验证Apache配置
  - 重启Apache服务

**2. `frontend/src/modules/Dashboard.vue`**：
- **UI更新**：
  - 添加禁用按钮
  - 更新提示文案
  - 添加禁用函数

#### 🗑️ 旧格式配置文件清理增强

**1. `backend/scripts/cert_setup.sh`**：
- **删除逻辑增强**：
  - 检查包含ServerAlias的配置文件
  - 检查www前缀域名的配置文件
  - 自动备份并删除冲突文件

### 🔄 升级步骤

#### 自动升级（推荐）

```bash
# 1. 进入项目目录
cd /bash

# 2. 执行更新（自动拉取最新代码）
./start.sh update

# 3. 重启服务（应用更新）
./start.sh restart
```

#### 手动升级

```bash
# 1. 进入项目目录
cd /bash

# 2. 备份当前配置
cp config/system-settings.json config/system-settings.json.backup

# 3. 拉取最新代码（如果使用Git）
git pull

# 4. 重启服务
./start.sh restart
```

### ⚠️ 注意事项

1. **HTTP跳转状态**：
   - HTTP跳转功能默认关闭
   - 需要用户手动点击启用
   - 可以通过禁用按钮关闭功能

2. **旧格式配置文件**：
   - 系统会自动检测并删除冲突的旧格式配置文件
   - 删除前会自动备份
   - 如果发现冲突文件，建议手动检查并删除

3. **状态文件**：
   - HTTP跳转状态存储在 `/bash/config/http-redirect-enabled.json`
   - 删除此文件即可禁用HTTP跳转
   - 文件权限自动设置为755

---

## 🎉 版本历史记录

### V4.8.1 (2026-01-28) - 系统设置优化与问题修复

### 🎊 版本亮点

**V4.8.1 是一个系统设置优化与问题修复版本，优化了重装逻辑、修复了Chart.js数据验证错误、实现了系统设置自动保存、统一了文件权限管理，并修复了备份文件命名规则问题，提升了系统的稳定性和用户体验。**

#### 🔄 重装逻辑优化

**删除重装时自动备份**：
- **问题描述**：
  - 重装时会自动创建备份文件，导致备份文件过多
  - 重装时创建的备份与用户保存的备份混在一起
  - 影响备份文件的管理和清理
- **修复内容**：
  - 移除重装开始时自动创建备份的逻辑
  - 重装时仅读取用户之前保存的备份文件
  - 避免重装时创建不必要的备份文件
  - 简化重装流程，提升性能
- **技术实现**：
  - 文件：`start.sh`
  - 关键改进：
    - 删除重装开始时的备份创建逻辑
    - 删除 `INSTALL_START_TIME` 变量记录
    - 简化恢复逻辑，直接使用最新的备份文件
- **影响范围**：
  - 重装时不会创建新的备份文件
  - 重装后自动从最新的用户保存的备份恢复
  - 备份文件管理更加清晰

#### 📊 Chart.js错误修复

**数据验证增强**：
- **问题描述**：
  - 图表数据为null时导致Chart.js崩溃
  - 错误信息：`Cannot read properties of null (reading 'save')`
  - 影响邮件发送趋势和频率分析图表的显示
- **修复内容**：
  - 添加数据有效性检查，确保数组不包含null/undefined
  - 使用filter过滤无效值
  - 确保labels、emailCounts、frequencies等数组长度一致
  - 在创建图表前验证数据有效性
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 在数据处理时过滤null/undefined值
    - 确保数组长度一致（取最小值）
    - 创建图表前验证数据有效性
    - 数据无效时显示空状态图表
- **影响范围**：
  - 修复图表渲染错误
  - 提升图表显示稳定性
  - 改善用户体验

#### 💾 系统设置自动保存

**页面打开时自动保存**：
- **问题描述**：
  - 用户打开系统设置页面时，不会自动创建备份
  - 需要手动保存才能创建时间戳备份
- **修复内容**：
  - 系统设置页面加载完成后，自动保存一次配置
  - 使用静默模式，不显示成功提示
  - 确保每次打开页面时创建时间戳备份
  - 延迟1秒执行，确保所有设置已正确加载
- **技术实现**：
  - 文件：`frontend/src/modules/Settings.vue`
  - 关键改进：
    - 在 `onMounted` 中添加自动保存逻辑
    - 使用 `executeSaveSystemSettings(true)` 静默保存
    - 延迟1秒执行，确保配置已加载
- **影响范围**：
  - 每次打开系统设置页面都会创建备份
  - 确保配置的及时备份
  - 提升配置安全性

#### 🔐 文件权限管理

**统一文件权限设置**：
- **问题描述**：
  - 系统设置文件权限不一致
  - 部分文件权限为644，部分为755
  - 需要统一文件权限管理
- **修复内容**：
  - 系统设置文件权限统一设置为755（rwxr-xr-x）
  - 每次保存时自动设置权限
  - 每次打开系统设置页面时自动设置权限
  - 备份文件权限也设置为755
  - DNS配置成功后保存时也设置权限
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 关键改进：
    - POST端点：保存时设置权限为755
    - GET端点：读取时设置权限为755
    - DNS配置成功后：保存时设置权限为755
    - 备份文件：权限设置为755
- **影响范围**：
  - 统一文件权限管理
  - 提升文件访问一致性
  - 改善系统安全性

#### 📝 备份文件命名规则修复

**统一命名格式**：
- **问题描述**：
  - 存在错误格式的备份文件：`system-settings.json.backup.YYYYMMDD_HHMMSS`
  - 正确格式应为：`system-settings.json-YYYYMMDD_HHMMSS.backup`
  - 错误格式的文件无法被正确识别和清理
- **修复内容**：
  - 修复错误格式的备份文件命名
  - 统一使用正确格式：`system-settings.json-YYYYMMDD_HHMMSS.backup`
  - 自动检测并重命名错误格式的文件
  - 清理逻辑中处理错误格式的文件
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`、`start.sh`
  - 关键改进：
    - 修复 `start.sh` 中DNS清理时的错误命名格式
    - 在读取备份文件时自动检测并重命名错误格式的文件
    - 在清理备份文件时处理错误格式的文件
    - 如果正确格式的文件已存在，删除错误格式的文件
- **影响范围**：
  - 统一备份文件命名规则
  - 自动修复错误格式的文件
  - 提升备份文件管理的一致性

### 📋 主要更新内容

#### 🔄 重装逻辑优化

**1. `start.sh`**：
- **删除重装时自动备份**：
  - 移除重装开始时的备份创建逻辑
  - 删除 `INSTALL_START_TIME` 变量
  - 简化恢复逻辑，直接使用最新的备份文件

#### 📊 Chart.js错误修复

**1. `frontend/src/modules/Dashboard.vue`**：
- **数据验证增强**：
  - 在数据处理时过滤null/undefined值
  - 确保数组长度一致
  - 创建图表前验证数据有效性

#### 💾 系统设置自动保存

**1. `frontend/src/modules/Settings.vue`**：
- **自动保存功能**：
  - 在 `onMounted` 中添加自动保存逻辑
  - 使用静默模式保存
  - 延迟1秒执行

#### 🔐 文件权限管理

**1. `backend/dispatcher/server.js`**：
- **权限设置**：
  - POST端点：保存时设置权限为755
  - GET端点：读取时设置权限为755
  - DNS配置成功后：保存时设置权限为755
  - 备份文件：权限设置为755

#### 📝 备份文件命名规则修复

**1. `start.sh`**：
- **修复错误命名格式**：
  - 修复DNS清理时的错误命名格式
  - 统一使用正确格式

**2. `backend/dispatcher/server.js`**：
- **自动修复错误格式**：
  - 读取时自动检测并重命名错误格式的文件
  - 清理时处理错误格式的文件

### 🔄 升级步骤

#### 自动升级（推荐）

```bash
# 1. 进入项目目录
cd /bash

# 2. 执行更新（自动拉取最新代码）
./start.sh update

# 3. 重启服务（应用更新）
./start.sh restart
```

#### 手动升级

```bash
# 1. 进入项目目录
cd /bash

# 2. 备份当前配置
cp config/system-settings.json config/system-settings.json.backup

# 3. 拉取最新代码（如果使用Git）
git pull

# 4. 重启服务
./start.sh restart
```

### ⚠️ 注意事项

1. **备份文件管理**：
   - 系统会自动管理备份文件，只保留最新的3个
   - 错误格式的备份文件会被自动修复
   - 重装时不会创建新的备份文件

2. **文件权限**：
   - 系统设置文件权限会自动设置为755
   - 无需手动设置文件权限

3. **图表显示**：
   - 如果图表数据无效，会显示空状态
   - 不会导致页面崩溃

---

## 🎉 版本历史记录

### V4.8.0 (2026-01-28) - 系统设置配置管理与备份优化

### 🎊 版本亮点

**V4.8.0 是一个系统设置配置管理与备份优化版本，实现了时间戳备份文件的自动管理、配置加载优化和重装时自动恢复功能，确保系统配置的安全性和可恢复性，同时清理了系统设置中的冗余备份管理功能。**

#### 🗑️ 系统设置清理与优化

**删除备份管理模板**：
- **问题描述**：
  - 系统设置页面中仍保留备份管理功能
  - 备份功能已整合到Dashboard，造成功能重复
  - 备份相关字段占用配置空间
- **修复内容**：
  - 从系统设置页面完全移除备份管理UI组件
  - 删除所有备份相关的状态变量和函数
  - 从默认设置中移除 `autoBackup` 和 `backupInterval` 字段
  - 保存和加载时自动过滤备份相关字段
- **技术实现**：
  - 文件：`frontend/src/modules/Settings.vue`
  - 关键改进：
    - 删除备份管理模板（第749-923行）
    - 删除备份相关状态变量（`backupTab`、`backupExecuting`、`backupStatus`等）
    - 删除备份相关函数（`loadBackupStatus`、`executeFullBackup`、`saveScheduledBackup`）
    - 从 `general` 设置中删除备份字段
- **影响范围**：
  - 系统设置页面更加简洁
  - 避免功能重复和混淆
  - 备份功能统一在Dashboard管理

#### 💾 时间戳备份文件管理

**自动创建时间戳备份**：
- **问题描述**：
  - 用户每次修改系统设置后，需要手动备份配置
  - 重装时可能丢失配置
  - 没有历史配置记录
- **修复内容**：
  - 每次保存系统设置时，自动创建时间戳备份文件
  - 备份文件格式：`system-settings.json-YYYYMMDD_HHMMSS.backup`
  - 备份文件保存在 `/bash/config/` 目录
  - 自动设置备份文件权限和所有者
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`POST /api/system-settings`
  - 关键改进：
    - 保存主配置文件后，自动创建时间戳备份文件
    - 时间戳格式：`YYYYMMDD_HHMMSS`（如：`20260128_102312`）
    - 设置备份文件权限：`chown xm:xm`，`chmod 644`
- **影响范围**：
  - 每次保存都有备份记录
  - 便于配置恢复和版本管理
  - 提升配置安全性

**自动清理旧备份**：
- **问题描述**：
  - 备份文件会不断累积，占用磁盘空间
  - 需要手动清理旧备份文件
- **修复内容**：
  - 每次保存后自动检查备份文件数量
  - 只保留最新的3个时间戳备份文件
  - 自动删除最老的备份文件
  - 主配置文件不会被删除
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 关键改进：
    - 查找所有时间戳备份文件（`system-settings.json-*.backup`）
    - 按修改时间排序
    - 保留最新的3个，删除其余的
    - 使用 `fs.unlinkSync` 删除旧文件
- **影响范围**：
  - 自动管理备份文件，避免占用过多空间
  - 保留最近的3个备份，便于恢复
  - 无需手动清理

#### 🔄 配置加载优化

**优先加载最新备份**：
- **问题描述**：
  - 系统设置页面打开时，只从主配置文件加载
  - 如果主配置文件被重置，会丢失配置
  - 无法利用备份文件恢复配置
- **修复内容**：
  - 系统设置API自动查找所有时间戳备份文件
  - 按修改时间排序，优先使用最新的备份文件
  - 如果没有备份文件，使用主配置文件
  - 兼容旧格式备份文件
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`GET /api/system-settings`
  - 关键改进：
    - 扫描 `config` 目录下的所有时间戳备份文件
    - 按修改时间降序排序
    - 选择最新的备份文件加载
    - 如果没有备份文件，回退到主配置文件
- **影响范围**：
  - 系统设置页面自动加载最新配置
  - 即使主配置文件被重置，也能从备份恢复
  - 提升配置的可靠性

#### 🔧 重装时自动恢复

**重装前自动备份**：
- **问题描述**：
  - 重装时可能丢失现有配置
  - 需要手动备份配置
- **修复内容**：
  - 重装开始时，自动备份现有配置到时间戳文件
  - 备份文件格式与用户保存时一致
  - 确保配置不会丢失
- **技术实现**：
  - 文件：`start.sh`
  - 关键改进：
    - 在重装开始前，检查是否存在 `system-settings.json`
    - 如果存在，创建时间戳备份文件
    - 备份文件格式：`system-settings.json-YYYYMMDD_HHMMSS.backup`
- **影响范围**：
  - 重装前自动备份配置
  - 确保配置不会丢失
  - 提升重装安全性

**重装后自动恢复**：
- **问题描述**：
  - 重装后需要手动恢复配置
  - 可能忘记恢复配置
- **修复内容**：
  - 重装完成后，自动查找最新的时间戳备份文件
  - 自动恢复最新的备份文件到主配置文件
  - 确保重装后能恢复上次的配置
- **技术实现**：
  - 文件：`start.sh`
  - 关键改进：
    - 使用 `ls -t` 查找所有时间戳备份文件
    - 选择最新的备份文件（`head -n 1`）
    - 恢复备份文件到主配置文件
    - 兼容旧格式备份文件
- **影响范围**：
  - 重装后自动恢复配置
  - 无需手动操作
  - 提升用户体验

### 📋 主要更新内容

#### 🗑️ 系统设置清理与优化

**1. `frontend/src/modules/Settings.vue`**：
- **删除备份管理模板**：
  - 移除备份管理UI组件（完整备份和定时备份标签页）
  - 删除备份相关状态变量和函数
  - 从默认设置中移除备份字段
- **配置加载优化**：
  - 优先使用后端返回的配置值
  - 从后端设置中过滤备份相关字段
  - 确保配置字段正确合并

#### 💾 时间戳备份文件管理

**1. `backend/dispatcher/server.js`**：
- **保存时创建备份**：
  - 每次保存系统设置时，创建时间戳备份文件
  - 备份文件格式：`system-settings.json-YYYYMMDD_HHMMSS.backup`
  - 设置备份文件权限
- **自动清理旧备份**：
  - 保存后检查备份文件数量
  - 只保留最新的3个备份文件
  - 删除最老的备份文件

**2. `backend/dispatcher/server.js`**：
- **加载时优先使用备份**：
  - 查找所有时间戳备份文件
  - 按修改时间排序，选择最新的
  - 优先使用备份文件加载配置

#### 🔧 重装时自动恢复

**1. `start.sh`**：
- **重装前备份**：
  - 重装开始时，创建时间戳备份文件
  - 备份文件格式与用户保存时一致
- **重装后恢复**：
  - 查找最新的时间戳备份文件
  - 恢复最新的备份文件到主配置文件
  - 兼容旧格式备份文件

### 🔄 升级步骤

#### 自动升级（推荐）

```bash
# 1. 进入项目目录
cd /bash

# 2. 执行更新（自动拉取最新代码）
./start.sh update

# 3. 重建前端（应用配置管理优化）
./start.sh rebuild

# 4. 重启服务
./start.sh restart
```

#### 手动升级

```bash
# 1. 备份当前系统
./start.sh backup

# 2. 拉取最新代码（如果使用Git）
git pull origin main

# 3. 重建前端
cd frontend
npm install
npm run build
cd ..

# 4. 重启服务
./start.sh restart
```

### ⚠️ 注意事项

1. **备份文件管理**：
   - 系统会自动保留最新的3个时间戳备份文件
   - 如果需要保留更多备份，可以手动复制备份文件
   - 主配置文件不会被自动删除

2. **配置恢复**：
   - 系统会自动加载最新的时间戳备份文件
   - 如果主配置文件被重置，会自动从备份恢复
   - 重装后会自动恢复最新的备份文件

3. **兼容性**：
   - 兼容旧格式备份文件（`system-settings.json.backup`）
   - 如果没有时间戳备份文件，会尝试使用旧格式备份文件
   - 确保向后兼容

### 📝 版本历史记录

---

## 🎉 V4.7.3 (2026-01-28) - SSL管理对话框移动端适配优化

### 🎊 版本亮点

**V4.7.3 是一个移动端适配优化版本，全面优化了SSL管理对话框在移动设备上的显示效果和交互体验，包括响应式布局、触摸友好的按钮设计、优化的表单元素，确保在手机和平板设备上也能流畅使用SSL管理功能。**

#### 📱 移动端响应式设计优化

**对话框容器优化**：
- **问题描述**：
  - SSL管理对话框在移动设备上显示不佳
  - 固定宽度导致小屏幕显示不完整
  - 圆角在移动端显示效果不佳
- **修复内容**：
  - 移动端全屏显示（`h-full`），桌面端保持原有样式
  - 移动端移除圆角（`rounded-none`），桌面端保留圆角（`sm:rounded-xl md:rounded-2xl`）
  - 调整内边距以适应不同屏幕尺寸（`p-0 sm:p-2 md:p-4`）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 对话框容器：`w-full h-full sm:h-auto sm:max-w-6xl sm:max-h-[90vh]`
    - 圆角：`rounded-none sm:rounded-xl md:rounded-2xl`
    - 内边距：`p-0 sm:p-2 md:p-4`
- **影响范围**：
  - 移动端显示更加友好
  - 充分利用屏幕空间
  - 提升了移动端用户体验

**通知消息位置优化**：
- **改进内容**：
  - 移动端固定在顶部左侧（`fixed top-4 left-4`）
  - 桌面端保持在右上角（`sm:absolute sm:top-16 sm:right-4`）
  - 宽度自适应移动端屏幕（`w-[calc(100%-2rem)] sm:w-auto`）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 位置：`fixed sm:absolute top-4 sm:top-16 left-4 sm:left-auto sm:right-4`
    - 宽度：`w-[calc(100%-2rem)] sm:w-auto sm:max-w-md`
- **影响范围**：
  - 移动端通知消息位置更合理
  - 不会遮挡重要内容
  - 提升了移动端可用性

**标签页导航优化**：
- **改进内容**：
  - 添加水平滚动支持（`overflow-x-auto`）
  - 调整标签页内边距和字体大小
  - 优化图标和文字间距
  - 确保小屏幕可滚动
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 容器：`overflow-x-auto -mx-3 sm:mx-0`
    - 导航：`flex space-x-2 sm:space-x-4 px-3 sm:px-0 min-w-max sm:min-w-0`
    - 按钮：`py-2.5 sm:py-2 px-3 sm:px-4 text-xs sm:text-sm`
    - 图标：`w-3.5 h-3.5 sm:w-4 sm:h-4`
- **影响范围**：
  - 移动端标签页可以滚动
  - 文字和图标大小适中
  - 提升了移动端导航体验

#### 🎨 UI组件移动端适配

**HTTP跳转HTTPS区域**：
- **改进内容**：
  - 移动端垂直堆叠布局（`flex-col`），桌面端水平排列（`sm:flex-row`）
  - 按钮在移动端全宽显示（`w-full sm:w-auto`）
  - 文本自动换行（`break-words`），防止溢出
  - 添加触摸优化（`touch-manipulation`）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 布局：`flex flex-col sm:flex-row sm:items-center sm:justify-between`
    - 按钮：`w-full sm:w-auto px-4 py-2.5 sm:py-2`
    - 文本：`break-words`
- **影响范围**：
  - 移动端布局更加合理
  - 按钮易于点击
  - 提升了移动端交互体验

**域名列表优化**：
- **改进内容**：
  - 域名卡片在移动端垂直堆叠（`flex-col sm:flex-row`）
  - 按钮组在移动端垂直排列，确保触摸友好
  - 添加最小触摸目标尺寸（`min-h-[44px] sm:min-h-0`）
  - 状态标签自动换行显示（`flex-wrap`）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 卡片：`flex flex-col sm:flex-row sm:items-center sm:justify-between`
    - 按钮组：`flex flex-wrap sm:flex-nowrap gap-2 sm:space-x-2`
    - 按钮：`flex-1 sm:flex-none min-h-[44px] sm:min-h-0`
    - 标签：`flex flex-wrap items-center gap-1.5 sm:gap-2`
- **影响范围**：
  - 移动端域名列表显示更清晰
  - 按钮易于操作
  - 提升了移动端可用性

**证书管理列表**：
- **改进内容**：
  - 证书卡片在移动端垂直布局
  - 按钮在移动端全宽显示，文字始终可见
  - 优化证书信息显示，支持长域名
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 卡片：`flex flex-col sm:flex-row sm:items-center sm:justify-between`
    - 按钮：`flex-1 sm:flex-none min-h-[44px] sm:min-h-0`
    - 文本：`break-words`
- **影响范围**：
  - 移动端证书列表显示更清晰
  - 按钮操作更方便
  - 提升了移动端用户体验

**上传证书表单**：
- **改进内容**：
  - 文件输入框在移动端垂直堆叠（`flex-col sm:flex-row`）
  - 调整字体大小和内边距（`text-sm sm:text-xs`）
  - 上传按钮在移动端全宽显示
  - 优化拖拽上传区域大小
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 输入框：`flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2`
    - 字体：`text-sm sm:text-xs`
    - 内边距：`px-3 py-2.5 sm:px-2 sm:py-1.5`
    - 按钮：`w-full px-4 py-3 sm:py-2 min-h-[44px] sm:min-h-0`
- **影响范围**：
  - 移动端表单更易使用
  - 文件选择更方便
  - 提升了移动端上传体验

#### 🎯 触摸交互优化

**按钮优化**：
- **改进内容**：
  - 所有按钮添加 `touch-manipulation` CSS属性
  - 确保最小触摸目标尺寸为 44x44px
  - 使用响应式字体大小（`text-xs sm:text-sm`）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 触摸优化：`touch-manipulation`
    - 最小尺寸：`min-h-[44px] sm:min-h-0 min-w-[44px] sm:min-w-0`
    - 字体：`text-xs sm:text-sm`
- **影响范围**：
  - 移动端按钮更易点击
  - 符合移动端交互规范
  - 提升了移动端可用性

**表单元素优化**：
- **改进内容**：
  - 输入框和选择框在移动端使用更大的内边距
  - 添加 `break-words` 防止文本溢出
  - 优化间距和布局，确保在小屏幕上可读
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 内边距：`px-3 py-2.5 sm:px-2 sm:py-1.5`
    - 字体：`text-base sm:text-sm`
    - 文本：`break-words`
- **影响范围**：
  - 移动端表单更易使用
  - 文本显示更清晰
  - 提升了移动端用户体验

### 📋 主要更新内容

#### 📱 移动端响应式设计优化

**1. `frontend/src/modules/Dashboard.vue`**：
- **对话框容器优化**：
  - 移动端全屏显示，桌面端保持原有样式
  - 移动端移除圆角，桌面端保留圆角
  - 调整内边距以适应不同屏幕尺寸
- **通知消息位置优化**：
  - 移动端固定在顶部左侧，桌面端保持在右上角
  - 宽度自适应移动端屏幕
- **标签页导航优化**：
  - 添加水平滚动支持
  - 调整标签页内边距和字体大小
  - 优化图标和文字间距

#### 🎨 UI组件移动端适配

**1. `frontend/src/modules/Dashboard.vue`**：
- **HTTP跳转HTTPS区域**：
  - 移动端垂直堆叠布局，桌面端水平排列
  - 按钮在移动端全宽显示
  - 文本自动换行
- **域名列表优化**：
  - 域名卡片在移动端垂直堆叠
  - 按钮组在移动端垂直排列
  - 添加最小触摸目标尺寸
- **证书管理列表**：
  - 证书卡片在移动端垂直布局
  - 按钮在移动端全宽显示
- **上传证书表单**：
  - 文件输入框在移动端垂直堆叠
  - 调整字体大小和内边距
  - 上传按钮在移动端全宽显示

#### 🎯 触摸交互优化

**1. `frontend/src/modules/Dashboard.vue`**：
- **按钮优化**：
  - 所有按钮添加 `touch-manipulation` CSS属性
  - 确保最小触摸目标尺寸为 44x44px
  - 使用响应式字体大小
- **表单元素优化**：
  - 输入框和选择框在移动端使用更大的内边距
  - 添加 `break-words` 防止文本溢出
  - 优化间距和布局

### 🔄 升级步骤

#### 自动升级（推荐）

```bash
# 1. 进入项目目录
cd /bash

# 2. 执行更新（自动拉取最新代码）
./start.sh update

# 3. 重建前端（应用移动端适配优化）
./start.sh rebuild

# 4. 重启服务
./start.sh restart
```

#### 手动升级

```bash
# 1. 备份当前系统
./start.sh backup

# 2. 拉取最新代码（如果使用Git）
git pull origin main

# 3. 重建前端
cd frontend
npm install
npm run build
cd ..

# 4. 重启服务
./start.sh restart
```

### ⚠️ 注意事项

1. **移动端测试**：
   - 建议在移动设备或浏览器开发者工具的移动端模式下测试SSL管理对话框
   - 检查所有按钮和表单元素是否易于操作
   - 验证文本是否完整显示，无溢出

2. **兼容性**：
   - 移动端适配主要针对现代移动浏览器（iOS Safari、Chrome Mobile等）
   - 确保浏览器支持CSS Grid和Flexbox布局

3. **性能**：
   - 移动端适配不影响桌面端性能
   - 响应式布局使用CSS媒体查询，性能开销极小

### 📝 版本历史记录

---

## 🎉 V4.7.2 (2026-01-26) - HTTP跳转HTTPS功能修复与SSL管理优化

### 🎊 版本亮点

**V4.7.2 是一个HTTP跳转HTTPS功能修复和SSL管理优化版本，修复了HTTP跳转状态检查逻辑，改进了域名自动发现机制，增强了删除域名功能，并优化了SSL配置按钮的状态管理，提升了系统的可靠性和用户体验。**

#### 🔧 HTTP跳转HTTPS功能修复

**状态检查逻辑优化**：
- **问题描述**：
  - HTTP跳转状态检查API可能误判配置状态
  - 即使配置未生效，也可能显示"已配置"状态
  - 缺少Apache配置语法验证
  - 域名提取可能包含注释行和无效内容
- **修复内容**：
  - 添加了Apache配置语法验证（`httpd -t`）
  - 改进了配置文件内容验证，排除注释行和无效域名
  - 确保只有配置真正生效时才返回"已配置"状态
  - 添加了详细的调试日志，便于问题排查
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`GET /api/cert/http-redirect-status`
  - 关键改进：
    - 验证RewriteEngine、RewriteCond、RewriteRule配置的有效性
    - 排除注释行和空行
    - 验证域名格式（只包含字母、数字、点、连字符）
    - 执行Apache配置语法检查
    - 返回详细状态信息（配置文件存在、Apache语法验证、域名列表）
- **影响范围**：
  - HTTP跳转状态显示更加准确
  - 避免了误判配置状态的问题
  - 提升了状态检查的可靠性

**域名自动发现优化**：
- **问题描述**：
  - HTTP跳转配置脚本只从配置文件读取域名，可能遗漏已配置SSL的域名
  - 域名提取可能包含注释内容（如"使其成为默认虚拟主机"）
  - 旧格式配置文件可能与HTTP跳转配置冲突
- **修复内容**：
  - 优先从Apache SSL配置文件中自动发现所有已配置SSL的域名
  - 改进了域名提取逻辑，正确排除注释和无效行
  - 自动备份/删除冲突的旧配置文件
  - 确保所有已配置SSL的域名都有HTTP跳转配置
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 关键改进：
    - 从 `*_ssl.conf` 文件中提取ServerName（排除注释行）
    - 验证域名格式有效性
    - 检查并备份/删除旧格式HTTP配置文件（如 `skills.com.conf`）
    - 复制SSL配置中的ServerAlias到HTTP配置
- **影响范围**：
  - 自动为所有已配置SSL的域名创建HTTP跳转配置
  - 避免了配置遗漏的问题
  - 处理了配置文件冲突问题

**配置冲突处理**：
- **问题描述**：
  - 旧格式配置文件（如 `skills.com.conf`）可能与HTTP跳转配置冲突
  - Apache按文件名顺序加载配置，旧配置文件优先级更高
  - 导致HTTP跳转配置不生效
- **修复内容**：
  - 检测并备份冲突的旧格式配置文件
  - 确保HTTP跳转配置优先级正确
  - 自动处理配置文件冲突
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 关键改进：
    - 检查旧格式配置文件是否存在
    - 验证是否为HTTP配置（不包含SSLEngine）
    - 备份或删除冲突的配置文件
- **影响范围**：
  - 解决了配置文件冲突问题
  - 确保HTTP跳转配置正确生效
  - 提升了配置的可靠性

#### 🗑️ 删除域名功能增强

**删除逻辑完善**：
- **问题描述**：
  - 删除域名时提示"未找到该域名的配置"
  - 只删除配置文件中的记录，不删除Apache配置文件
  - 即使Apache配置文件存在，也无法删除
- **修复内容**：
  - 修复了删除域名的API逻辑，即使配置文件中没有记录，也能删除Apache配置文件
  - 删除所有相关配置文件（SSL、HTTP、旧格式配置文件）
  - 添加了Apache配置验证和自动重启功能
  - 返回详细的删除结果信息
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`DELETE /api/cert/domains/:domain`
  - 关键改进：
    - 删除 `域名_ssl.conf`、`域名_http.conf` 和 `域名.conf` 文件
    - 检查配置文件内容，确保只删除相关域名的配置
    - 验证Apache配置语法
    - 自动重启Apache服务
    - 返回删除的文件列表和操作结果
- **影响范围**：
  - 用户可以正确删除域名配置
  - 避免了配置文件残留的问题
  - 提升了删除功能的可靠性

**配置文件清理**：
- **改进内容**：
  - 自动删除所有相关配置文件
  - 检查配置文件内容，确保只删除相关域名的配置
  - 删除后自动验证Apache配置语法并重启服务
- **技术改进**：
  - 支持删除多种格式的配置文件
  - 智能识别配置文件内容
  - 确保删除操作的安全性

#### 🎛️ SSL配置按钮状态管理

**按钮交互逻辑优化**：
- **问题描述**：
  - "配置HTTPS"按钮在已配置时仍可点击
  - "禁用SSL"按钮在未配置时也可点击
  - 按钮状态不符合实际配置状态
- **修复内容**：
  - "配置HTTPS"按钮：已配置时禁用，显示"已配置"状态（绿色，不可点击）
  - "禁用SSL"按钮：未配置时禁用，已配置时可点击（红色）
  - 按钮状态根据SSL配置状态自动更新
  - 添加了加载动画和状态提示
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - `:disabled="domain.sslConfigured || domain.sslConfiguring"` - 配置HTTPS按钮
    - `:disabled="!domain.sslConfigured || domain.sslDisabling"` - 禁用SSL按钮
    - 根据状态动态设置按钮样式和文本
    - 添加了视觉反馈（禁用状态、加载动画）
- **影响范围**：
  - 按钮状态更加直观和准确
  - 避免了误操作
  - 提升了用户体验

#### 📊 HTTP跳转状态检查优化

**严格的状态验证**：
- **改进内容**：
  - 检查配置文件存在性和内容有效性
  - 验证Apache配置语法正确性
  - 确保至少有一个有效域名配置
  - 返回详细的状态信息
- **技术实现**：
  - 文件：
    - `backend/dispatcher/server.js`：状态检查API
    - `frontend/src/modules/Dashboard.vue`：前端状态检查函数
  - 关键改进：
    - 验证RewriteEngine、RewriteCond、RewriteRule配置
    - 排除注释行和无效域名
    - 执行Apache配置语法检查
    - 返回详细状态信息（配置文件存在、Apache语法验证、域名列表）
    - 前端严格验证API返回的状态
- **影响范围**：
  - HTTP跳转状态显示更加准确
  - 避免了误判配置状态的问题
  - 提升了状态检查的可靠性

### 📋 主要更新内容

#### 🔧 HTTP跳转HTTPS功能修复

**1. `backend/dispatcher/server.js`**：
- **状态检查API优化**：
  - 添加Apache配置语法验证
  - 改进配置文件内容验证
  - 排除注释行和无效域名
  - 返回详细状态信息

**2. `backend/scripts/cert_setup.sh`**：
- **域名自动发现优化**：
  - 优先从Apache SSL配置文件中发现域名
  - 改进域名提取逻辑，排除注释和无效行
  - 自动备份/删除冲突的旧配置文件
  - 复制SSL配置中的ServerAlias

#### 🗑️ 删除域名功能增强

**1. `backend/dispatcher/server.js`**：
- **删除域名API优化**：
  - 删除所有相关配置文件（SSL、HTTP、旧格式）
  - 检查配置文件内容，确保只删除相关域名的配置
  - 验证Apache配置语法
  - 自动重启Apache服务

#### 🎛️ SSL配置按钮状态管理

**1. `frontend/src/modules/Dashboard.vue`**：
- **按钮交互逻辑优化**：
  - "配置HTTPS"按钮：已配置时禁用
  - "禁用SSL"按钮：未配置时禁用
  - 根据状态动态设置按钮样式和文本
  - 添加了加载动画和状态提示

#### 📊 HTTP跳转状态检查优化

**1. `backend/dispatcher/server.js`**：
- **状态检查API优化**：
  - 添加Apache配置语法验证
  - 改进配置文件内容验证
  - 返回详细状态信息

**2. `frontend/src/modules/Dashboard.vue`**：
- **前端状态检查优化**：
  - 严格验证API返回的状态
  - 添加详细的调试日志
  - 确保状态显示的准确性

### 🎯 效果与影响

**HTTP跳转HTTPS功能修复**：
- HTTP跳转状态显示更加准确
- 自动为所有已配置SSL的域名创建HTTP跳转配置
- 解决了配置文件冲突问题
- 提升了配置的可靠性

**删除域名功能增强**：
- 用户可以正确删除域名配置
- 避免了配置文件残留的问题
- 提升了删除功能的可靠性

**SSL配置按钮状态管理**：
- 按钮状态更加直观和准确
- 避免了误操作
- 提升了用户体验

**HTTP跳转状态检查优化**：
- HTTP跳转状态显示更加准确
- 避免了误判配置状态的问题
- 提升了状态检查的可靠性

### 📝 升级说明

#### 自动升级
- **无需手动操作**：升级后自动生效
- **向后兼容**：完全兼容之前版本的配置
- **配置迁移**：无需配置迁移

#### 验证方法
1. **测试HTTP跳转状态检查**：
   - 打开SSL管理对话框
   - 查看HTTP跳转按钮状态是否正确
   - 检查浏览器控制台的调试日志

2. **测试删除域名功能**：
   - 选择一个已配置SSL的域名
   - 点击删除按钮
   - 检查是否成功删除所有相关配置文件

3. **测试SSL配置按钮状态**：
   - 检查"配置HTTPS"按钮在已配置时是否禁用
   - 检查"禁用SSL"按钮在未配置时是否禁用
   - 验证按钮状态是否正确更新

## 🎉 历史版本 - V4.7.1 (2026-01-26) - 证书管理功能增强与UI升级

### 🎊 版本亮点

**V4.7.1 是一个证书管理功能增强版本，添加了删除证书和查看证书详细信息的功能，并对证书管理界面进行了全面的UI升级，提升了用户体验和系统管理能力。**

#### 📋 证书管理功能增强

**删除证书功能**：
- **功能描述**：
  - 添加了删除证书的API端点（`DELETE /api/cert/:certName`）
  - 删除前检查证书是否被域名使用，防止误删正在使用的证书
  - 自动删除证书文件（.crt）、私钥文件（.key）和证书链文件（.chain.crt）
  - 提供友好的错误提示和删除确认对话框
- **安全检查**：
  - 删除前检查证书是否被域名使用
  - 如果证书正在被使用，拒绝删除并提示关联的域名列表
  - 确保不会误删正在使用的证书
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`DELETE /api/cert/:certName`
  - 关键功能：
    - 检查域名-证书关联配置（`config/ssl-domain-cert.json`）
    - 删除证书文件（`/etc/pki/tls/${certName}.crt`）
    - 删除私钥文件（`/etc/pki/tls/${certName}.key`）
    - 删除证书链文件（`/etc/pki/tls/${certName}.chain.crt`）
    - 返回删除结果和已删除的文件列表
- **影响范围**：
  - 用户可以安全地删除不再使用的证书
  - 防止误删正在使用的证书
  - 提升了证书管理的灵活性

**证书详细信息查看**：
- **功能描述**：
  - 添加了获取证书详细信息的API端点（`GET /api/cert/:certName/details`）
  - 使用OpenSSL解析证书信息（主题、颁发者、序列号、指纹、SAN等）
  - 显示证书有效期、文件路径、关联域名等完整信息
  - 支持证书状态检查（有效/过期）
- **证书信息解析**：
  - 使用OpenSSL命令解析证书详细信息
  - 提取主题（Subject）、颁发者（Issuer）、序列号（Serial）
  - 提取SHA256指纹、生效日期、到期日期
  - 解析SAN（Subject Alternative Names）列表
  - 检查证书文件、私钥文件、证书链文件的存在性
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - API端点：`GET /api/cert/:certName/details`
  - 关键功能：
    - 使用 `openssl x509` 命令解析证书信息
    - 解析证书日期、主题、颁发者、序列号、指纹
    - 提取SAN列表（DNS和IP地址）
    - 检查证书是否过期
    - 查询证书关联的域名列表
- **影响范围**：
  - 用户可以查看证书的完整信息
  - 便于证书管理和问题排查
  - 提升了证书管理的透明度

#### 🎨 证书管理UI升级

**证书列表UI优化**：
- **设计改进**：
  - 卡片式设计，渐变背景和悬停效果
  - 显示证书状态标签（即将过期警告）
  - 显示证书到期时间和关联域名数量
  - 响应式设计，完美适配移动端
- **视觉优化**：
  - 渐变背景（`from-gray-50 to-white`）
  - 悬停效果（边框颜色变化、阴影效果）
  - 状态标签（绿色=有效，红色=即将过期）
  - 图标和颜色编码（蓝色=证书，绿色=到期时间，蓝色=关联域名）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 证书卡片UI重构
    - 状态标签显示（`isCertExpiringSoon` 函数）
    - 响应式布局优化
    - 按钮布局优化
- **影响范围**：
  - 证书列表更加美观和易用
  - 状态信息更加清晰
  - 提升了用户体验

**证书详情对话框**：
- **设计特点**：
  - 现代化设计，玻璃拟态效果
  - 分卡片显示：基本信息、证书文件信息、证书详细信息、关联域名列表
  - 响应式设计，支持滚动查看
  - 加载状态显示和友好的错误提示
- **功能模块**：
  - **基本信息卡片**：
    - 证书名称、状态（有效/过期）
    - 生效日期、到期日期
    - 状态标签（绿色=有效，红色=过期）
  - **证书文件信息卡片**：
    - 证书文件（.crt）路径和状态
    - 私钥文件（.key）路径和状态
    - 证书链文件（.chain.crt）路径和状态
  - **证书详细信息卡片**：
    - 主题（Subject）、颁发者（Issuer）
    - 序列号（Serial）、SHA256指纹
    - SAN列表（DNS和IP地址）
  - **关联域名卡片**：
    - 显示证书关联的所有域名
    - 如果没有关联域名，显示提示信息
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键功能：
    - 证书详情对话框组件
    - 证书信息加载和显示
    - 响应式布局和滚动支持
    - 加载状态和错误处理
- **影响范围**：
  - 用户可以查看证书的完整信息
  - 证书管理更加直观和便捷
  - 提升了系统的可维护性

**操作按钮优化**：
- **按钮设计**：
  - "查看详情"按钮：蓝色主题，带图标和文字
  - "删除"按钮：红色主题，带图标和文字，删除时显示加载动画
  - 按钮布局优化，提升用户体验
- **交互优化**：
  - 删除前需要确认
  - 删除时显示加载动画
  - 友好的错误提示和成功消息
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键功能：
    - `viewCertDetails()` 函数：查看证书详细信息
    - `deleteCertificate()` 函数：删除证书
    - `isCertExpiringSoon()` 函数：检查证书是否即将过期
- **影响范围**：
  - 操作更加直观和便捷
  - 提升了用户体验
  - 减少了误操作的风险

#### 🔧 技术实现

**后端API增强**：
- **证书详细信息解析**：
  - 使用OpenSSL命令解析证书信息
  - 提取证书的所有关键信息
  - 检查证书文件的存在性
  - 查询证书关联的域名
- **证书删除安全检查**：
  - 检查域名-证书关联配置
  - 如果证书正在被使用，拒绝删除
  - 提供详细的错误信息
- **完整的错误处理**：
  - 文件不存在时的错误处理
  - 证书解析失败时的错误处理
  - 删除失败时的错误处理
- **日志记录**：
  - 记录证书删除操作
  - 记录证书信息查询操作
  - 记录错误信息

**前端功能完善**：
- **证书过期检查**：
  - `isCertExpiringSoon()` 函数检查证书是否在30天内过期
  - 显示过期警告标签
- **删除确认对话框**：
  - 删除前显示确认对话框
  - 显示将要删除的文件列表
- **证书详情对话框**：
  - 美观的UI设计
  - 完整的信息展示
  - 响应式布局
- **友好的错误提示**：
  - 删除失败时的错误提示
  - 证书信息加载失败时的错误提示
  - 成功消息提示

### 📋 主要更新内容

#### 📋 证书管理功能增强

**1. `backend/dispatcher/server.js`**：
- **新增API端点**：
  - `GET /api/cert/:certName/details`：获取证书详细信息
  - `DELETE /api/cert/:certName`：删除证书
- **证书详细信息解析**：
  - 使用OpenSSL命令解析证书信息
  - 提取主题、颁发者、序列号、指纹、SAN等
  - 检查证书文件的存在性
  - 查询证书关联的域名
- **证书删除安全检查**：
  - 检查域名-证书关联配置
  - 如果证书正在被使用，拒绝删除
  - 删除证书文件、私钥文件、证书链文件

#### 🎨 证书管理UI升级

**1. `frontend/src/modules/Dashboard.vue`**：
- **证书列表UI优化**：
  - 卡片式设计，渐变背景和悬停效果
  - 状态标签显示（即将过期警告）
  - 响应式布局优化
- **证书详情对话框**：
  - 现代化设计，玻璃拟态效果
  - 分卡片显示证书信息
  - 响应式布局和滚动支持
- **操作按钮优化**：
  - "查看详情"按钮：蓝色主题
  - "删除"按钮：红色主题，带加载动画
- **辅助功能**：
  - `isCertExpiringSoon()` 函数：检查证书是否即将过期
  - `viewCertDetails()` 函数：查看证书详细信息
  - `deleteCertificate()` 函数：删除证书

### 🎯 效果与影响

**证书管理功能增强**：
- 用户可以安全地删除不再使用的证书
- 用户可以查看证书的完整信息
- 防止误删正在使用的证书
- 提升了证书管理的灵活性

**证书管理UI升级**：
- 证书列表更加美观和易用
- 证书详情对话框提供完整的信息展示
- 操作更加直观和便捷
- 提升了用户体验

**技术实现**：
- 后端API功能完善
- 前端功能完善
- 错误处理和日志记录完善
- 提升了系统的可维护性

### 📝 升级说明

#### 自动升级
- **无需手动操作**：升级后自动生效
- **向后兼容**：完全兼容之前版本的配置
- **配置迁移**：无需配置迁移

#### 验证方法
1. **测试证书删除功能**：
   - 打开SSL管理对话框
   - 切换到"证书管理"标签页
   - 选择一个未使用的证书
   - 点击"删除"按钮
   - 确认删除操作
   - 检查证书是否已删除

2. **测试证书详情查看**：
   - 打开SSL管理对话框
   - 切换到"证书管理"标签页
   - 选择一个证书
   - 点击"查看详情"按钮
   - 检查证书详细信息是否正确显示

3. **测试证书使用检查**：
   - 选择一个正在被域名使用的证书
   - 尝试删除该证书
   - 检查是否提示证书正在被使用
   - 检查是否显示关联的域名列表

## 🎉 历史版本 - V4.7.0 (2026-01-26) - WebSocket SSL连接修复与Apache配置优化

### 🎊 版本亮点

**V4.7.0 是一个WebSocket连接修复和Apache配置优化版本，修复了SSL环境下WebSocket连接失败的问题，优化了Apache自动配置的错误处理，提升了系统的稳定性和可靠性。**

#### 🔌 WebSocket SSL连接修复

**SSL环境下WebSocket连接问题修复**：
- **问题描述**：
  - 在HTTPS环境下，WebSocket连接失败，出现"WebSocket 连接错误，连接已断开"的错误
  - `cert_setup.sh` 中SSL VirtualHost的WebSocket代理配置使用了错误的 `ws://` 协议
  - Apache 2.4+ 需要使用 `http://` 协议配合 `upgrade=websocket` 参数
  - 导致SSL环境下WebSocket无法正常工作，影响Web终端等功能
- **修复内容**：
  - 修复了 `cert_setup.sh` 中所有4处SSL VirtualHost的WebSocket代理配置
  - 将 `ProxyPass ws://127.0.0.1:${API_PORT}/api/terminal/ws` 改为 `ProxyPass http://127.0.0.1:${API_PORT}/api/terminal/ws upgrade=websocket`
  - 统一了HTTP和HTTPS VirtualHost的WebSocket配置格式
  - 确保SSL环境下WebSocket连接正常工作
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 修复位置：
    - 第455-479行：有chain证书的域名SSL VirtualHost
    - 第569-593行：无chain证书的域名SSL VirtualHost
    - 第690-714行：有chain证书的IP访问SSL VirtualHost
    - 第805-828行：无chain证书的IP访问SSL VirtualHost
  - 关键修复：
    - 使用Apache 2.4+ 语法：`ProxyPass http://... upgrade=websocket`
    - 保持ProxyPassReverse配置不变
    - 确保WebSocket升级请求正确转发到后端
- **影响范围**：
  - 修复了HTTPS环境下WebSocket连接失败的问题
  - Web终端功能在SSL环境下正常工作
  - 提升了系统的兼容性和稳定性

**WebSocket配置统一**：
- **优化内容**：
  - 统一了HTTP和HTTPS VirtualHost的WebSocket配置格式
  - 确保SSL环境下WebSocket连接正常工作
  - 提升了系统的兼容性和稳定性
- **技术改进**：
  - 使用标准的Apache 2.4+ WebSocket代理配置
  - 确保WebSocket升级请求正确处理
  - 提升了配置的一致性和可维护性

#### 🛠️ Apache自动配置优化

**错误处理改进**：
- **问题描述**：
  - Apache自动配置失败时，错误信息不够详细
  - 配置文件写入可能未完成就执行配置命令
  - 脚本执行时工作目录不正确
  - 错误输出被截断，难以排查问题
- **修复内容**：
  - 在 `cert_setup.sh` 的 `enable-ssl` 命令中添加了返回值检查
  - 如果 `configure_apache_ssl` 失败，命令会正确退出并返回错误码
  - 改进了错误信息的输出，包含详细的配置错误信息
  - 添加了文件同步机制（fsync），确保配置文件写入完成
  - 添加了工作目录设置（cwd），确保脚本在正确的目录执行
- **技术实现**：
  - 文件：
    - `backend/scripts/cert_setup.sh`：添加返回值检查和错误处理
    - `backend/dispatcher/server.js`：添加文件同步和工作目录设置
  - 关键改进：
    - `enable-ssl` 命令检查 `configure_apache_ssl` 的返回值
    - 添加 `fs.fsyncSync()` 确保文件写入完成
    - 设置 `cwd: ROOT_DIR` 确保脚本在正确目录执行
    - 增加错误输出长度（从1000字符增加到2000-3000字符）
- **影响范围**：
  - Apache配置失败时能正确报告错误
  - 配置文件写入更可靠
  - 错误信息更详细，便于问题排查

**配置可靠性提升**：
- **改进内容**：
  - 添加了文件同步机制，确保配置文件写入完成
  - 添加了工作目录设置，确保脚本在正确的目录执行
  - 增加了更详细的日志输出，包括工作目录和脚本路径
  - 增加了错误输出的长度，便于问题排查
- **技术改进**：
  - 使用 `fs.fsyncSync()` 确保文件写入完成
  - 设置 `cwd` 选项确保脚本执行环境正确
  - 增加日志输出，提升可调试性

#### 📝 日志和错误处理优化

**详细日志记录**：
- **改进内容**：
  - 增加了Apache配置过程的详细日志输出
  - 改进了错误信息的提取和显示
  - 确保stderr和stdout都被正确捕获
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 关键改进：
    - 增加日志输出：工作目录、脚本路径、命令执行过程
    - 增加错误输出长度：从1000字符增加到2000-3000字符
    - 确保stderr和stdout都被捕获
- **影响范围**：
  - 问题排查更容易
  - 错误信息更完整
  - 提升了系统的可维护性

**错误诊断改进**：
- **改进内容**：
  - 输出Apache配置语法检查的详细错误信息
  - 输出Apache服务状态的详细信息
  - 提供更清晰的错误提示和解决建议
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 关键改进：
    - `configure_apache_ssl` 函数输出详细的配置错误信息
    - 输出Apache服务状态的详细信息
    - 提供清晰的错误提示和解决建议
- **影响范围**：
  - 错误诊断更容易
  - 问题解决更快速
  - 提升了用户体验

### 📋 主要更新内容

#### 🔌 WebSocket SSL连接修复

**1. `backend/scripts/cert_setup.sh`**：
- **修复位置**：4处SSL VirtualHost的WebSocket代理配置
- **修复内容**：
  - 将 `ProxyPass ws://...` 改为 `ProxyPass http://... upgrade=websocket`
  - 统一HTTP和HTTPS VirtualHost的WebSocket配置格式
  - 确保SSL环境下WebSocket连接正常工作

#### 🛠️ Apache自动配置优化

**1. `backend/scripts/cert_setup.sh`**：
- **enable-ssl命令改进**：
  - 添加 `configure_apache_ssl` 返回值检查
  - 如果配置失败，正确退出并返回错误码
  - 输出详细的配置错误信息

**2. `backend/dispatcher/server.js`**：
- **证书上传后Apache配置改进**：
  - 添加文件同步机制（fsync）
  - 设置工作目录（cwd）
  - 增加详细的日志输出
  - 增加错误输出长度

#### 📝 日志和错误处理优化

**1. `backend/dispatcher/server.js`**：
- **日志记录改进**：
  - 增加工作目录和脚本路径日志
  - 增加命令执行过程日志
  - 增加错误输出长度

**2. `backend/scripts/cert_setup.sh`**：
- **错误处理改进**：
  - 输出详细的配置错误信息
  - 输出Apache服务状态信息
  - 提供清晰的错误提示

### 🎯 效果与影响

**WebSocket连接修复**：
- 修复了HTTPS环境下WebSocket连接失败的问题
- Web终端功能在SSL环境下正常工作
- 提升了系统的兼容性和稳定性

**Apache配置优化**：
- Apache配置失败时能正确报告错误
- 配置文件写入更可靠
- 错误信息更详细，便于问题排查

**日志和错误处理优化**：
- 问题排查更容易
- 错误信息更完整
- 提升了系统的可维护性

### 📝 升级说明

#### 自动升级
- **无需手动操作**：升级后自动修复WebSocket配置
- **向后兼容**：完全兼容之前版本的配置
- **配置迁移**：对于已存在的SSL配置，需要重新配置Apache以应用修复

#### 验证方法
1. **测试WebSocket连接**：
   - 使用HTTPS访问系统（`https://your-domain`）
   - 登录系统
   - 打开Web终端功能
   - 检查WebSocket连接是否正常

2. **测试Apache配置**：
   - 上传证书后检查Apache配置是否成功
   - 检查错误日志是否包含详细的错误信息
   - 验证Apache服务是否正常重启

3. **检查日志输出**：
   - 查看调度层服务日志，确认日志输出更详细
   - 查看Apache错误日志，确认错误信息更清晰

#### 对于已存在SSL配置的用户
如果之前已经上传了证书并配置了SSL，需要重新配置Apache以应用WebSocket修复：

**方法1：重新上传证书（推荐）**
- 重新上传证书，系统会自动使用修复后的配置重新配置Apache

**方法2：手动重新配置Apache**
```bash
# 查看已配置的SSL域名
cat /bash/config/ssl-domain-cert.json

# 重新配置Apache（替换 <cert_name> 为你的证书名称）
cd /bash/backend/scripts
sudo bash cert_setup.sh enable-ssl <cert_name>

# 或者重启Apache服务
sudo systemctl restart httpd
```

## 🎉 版本历史 - V4.6.4 (2026-01-26) - 系统稳定性修复

### 🎊 版本亮点

**V4.6.4 是一个系统稳定性修复版本，修复了批量上传证书功能中的语法错误，解决了服务启动失败的问题，提升了系统的稳定性和可靠性。**

#### 🐛 代码结构修复

**批量上传证书语法错误修复**：
- **问题描述**：
  - 在 `server.js` 的批量上传证书功能中，存在 try-catch 结构不匹配的问题
  - 内层 `catch (validationError)` 和外层 `catch (loopError)` 的大括号匹配错误
  - 导致服务启动时出现 `SyntaxError: Unexpected token 'catch'` 错误
  - 服务无法正常启动，影响系统正常运行
- **修复内容**：
  - 修复了嵌套 try-catch 块的结构问题
  - 确保内层 `catch (validationError)` 正确匹配第2724行的 `try` 块（验证证书和私钥内容）
  - 确保外层 `catch (loopError)` 正确匹配第2646行的 `try` 块（循环处理）
  - 修复了所有大括号的匹配问题
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 修复位置：第2645-3033行（批量上传证书的循环处理部分）
  - 关键修复：
    - 第2995行：`} catch (validationError) {` 正确关闭内层 try 块
    - 第3020行：`}` 正确关闭内层 catch 块
    - 第3021行：`} catch (loopError) {` 正确匹配外层 try 块
    - 第3032行：`}` 正确关闭外层 catch 块
    - 第3033行：`}` 正确关闭 for 循环
- **影响范围**：
  - 修复了服务启动失败的问题
  - 批量上传证书功能恢复正常
  - 提升了系统的稳定性和可靠性

**代码结构优化**：
- **优化内容**：
  - 优化了批量上传证书功能的错误处理逻辑
  - 确保所有 try-catch 块正确闭合
  - 提升了代码的可读性和可维护性
- **技术改进**：
  - 统一了错误处理的结构
  - 明确了错误处理的层次关系
  - 提升了代码质量

#### 🛠️ 系统稳定性提升

**服务启动修复**：
- **问题描述**：
  - 由于语法错误，调度层服务无法正常启动
  - 系统日志显示 `SyntaxError: Unexpected token 'catch'`
  - 服务启动失败，影响系统正常运行
- **修复效果**：
  - 修复了语法错误后，服务能够正常启动
  - 调度层服务运行稳定
  - 系统功能恢复正常
- **验证方法**：
  - 运行 `node --check server.js` 检查语法
  - 检查服务状态：`systemctl status mail-ops-dispatcher.service`
  - 查看系统日志确认无语法错误

**错误处理完善**：
- **改进内容**：
  - 完善了批量上传证书的错误处理机制
  - 确保所有错误都能被正确捕获和处理
  - 提升了系统的健壮性
- **技术实现**：
  - 内层 catch 处理验证错误（证书格式、文件路径等）
  - 外层 catch 处理循环中的其他错误
  - 错误信息记录到日志中，便于排查问题

### 📋 主要更新内容

#### 🐛 代码结构修复

**1. `backend/dispatcher/server.js`**：
- **修复位置**：第2645-3033行（批量上传证书的循环处理部分）
- **修复内容**：
  - 修复了嵌套 try-catch 块的结构问题
  - 确保内层 `catch (validationError)` 正确匹配第2724行的 `try` 块
  - 确保外层 `catch (loopError)` 正确匹配第2646行的 `try` 块
  - 修复了所有大括号的匹配问题
- **代码结构**：
  ```javascript
  for (let i = 0; i < count; i++) {
    try {
      // 处理证书上传
      try {
        // 验证证书和私钥内容
        ...
      } catch (validationError) {
        // 处理验证错误
        ...
      }
    } catch (loopError) {
      // 处理循环中的其他错误
      ...
    }
  }
  ```

### 🎯 效果与影响

**系统稳定性提升**：
- 修复了服务启动失败的问题
- 批量上传证书功能恢复正常
- 提升了系统的稳定性和可靠性

**代码质量提升**：
- 优化了错误处理逻辑
- 提升了代码的可读性和可维护性
- 减少了潜在的语法错误

**用户体验改善**：
- 服务能够正常启动和运行
- 证书上传功能正常工作
- 系统功能稳定可靠

### 📝 升级说明

#### 自动升级
- **无需手动操作**：升级后自动修复语法错误
- **向后兼容**：完全兼容之前版本的功能
- **配置迁移**：无需迁移配置，系统自动处理

#### 验证方法
1. **检查语法**：
   ```bash
   cd /bash/backend/dispatcher
   node --check server.js
   ```
   应该无任何错误输出

2. **检查服务状态**：
   ```bash
   systemctl status mail-ops-dispatcher.service
   ```
   服务应该处于 `active (running)` 状态

3. **测试证书上传**：
   - 登录管理界面
   - 进入SSL管理页面
   - 测试批量上传证书功能
   - 确认功能正常工作

4. **查看系统日志**：
   ```bash
   journalctl -u mail-ops-dispatcher.service -n 50
   ```
   确认无语法错误和启动失败信息

## 🎉 版本历史 - V4.6.3 (2026-01-26) - SSL证书上传自动化与用户体验优化

### 🎊 版本亮点

**V4.6.3 是一个自动化流程优化版本，实现了SSL证书上传后的自动配置和前端自动构建，优化了用户提示信息显示，提升了系统的自动化程度和用户体验。**

#### 🔄 证书上传自动化流程

**自动配置Apache**：
- **功能描述**：
  - 检测证书名称为域名格式时（如 `www.example.com`），自动配置Apache SSL
  - 自动保存域名-证书关联到SSL域名列表（更新 `config/ssl-domain-cert.json`）
  - 自动调用 `cert_setup.sh enable-ssl` 配置Apache并重启服务
  - 配置完成后提供2-3分钟生效提示，引导用户访问HTTPS页面验证
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 关键功能：
    - 域名格式检测：使用正则表达式检测证书名称是否为域名格式
    - 自动保存关联：更新 `ssl-domain-cert.json` 配置文件
    - Apache配置：调用 `cert_setup.sh enable-ssl` 脚本
    - 服务重启：cert_setup.sh 自动重启Apache服务
- **影响范围**：
  - 证书上传后无需手动配置Apache，系统自动完成所有配置
  - 域名自动添加到SSL域名列表，无需手动添加
  - 提升操作效率，减少人工操作步骤

**自动构建前端**：
- **功能描述**：
  - 证书上传成功后自动触发前端构建（调用 `start.sh rebuild`）
  - 使用异步spawn执行，不阻塞API响应
  - 构建过程在后台进行，有5分钟超时保护
  - 构建结果记录到日志中，便于排查问题
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 关键功能：
    - `spawn('bash', [startScriptPath, 'rebuild'])`：异步执行前端构建
    - 超时保护：5分钟超时，超时后自动终止进程
    - 日志记录：记录构建输出和错误信息
- **影响范围**：
  - 前端代码更新后自动构建，无需手动执行构建命令
  - 提升开发效率，减少手动操作

#### 💬 提示信息优化

**对话框内提示显示**：
- **功能描述**：
  - 在SSL管理对话框右上角添加通知消息区域
  - 支持success、error、warning、info四种类型
  - 消息可手动关闭，显示时间智能调整（有Apache配置时10秒，其他情况8秒）
  - 成功消息包含Apache配置状态和等待时间说明
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键功能：
    - 通知消息区域：使用绝对定位显示在对话框右上角
    - 消息类型样式：success（绿色）、error（红色）、warning（黄色）、info（蓝色）
    - 消息显示逻辑：根据响应结果自动设置消息类型和内容
- **影响范围**：
  - 用户上传证书后能立即看到成功提示
  - 提示信息更加清晰和完整
  - 提升用户体验和操作反馈

**完整的用户提示**：
- **功能描述**：
  - 显示成功上传的证书数量
  - 显示自动配置Apache的证书数量
  - 提示"Apache配置需要2-3分钟生效，请稍后访问HTTPS页面验证"
  - 失败情况显示详细错误信息
- **技术实现**：
  - 文件：
    - `backend/dispatcher/server.js`：构建响应消息，包含apacheConfiguredCount
    - `frontend/src/modules/Dashboard.vue`：解析响应并显示提示信息
  - 关键功能：
    - 响应消息构建：包含成功数量、Apache配置数量、失败数量
    - 前端消息显示：根据响应数据构建完整的提示消息
- **影响范围**：
  - 用户能清楚了解上传结果和后续操作
  - 减少用户困惑，提升操作指导性

#### 🛠️ 技术改进

**后端响应优化**：
- **功能描述**：
  - 添加apacheConfiguredCount字段到响应中
  - 优化响应消息格式，明确说明Apache配置状态
  - 即使有部分失败，只要至少有一个成功也会返回合理响应
- **技术实现**：
  - 文件：`backend/dispatcher/server.js`
  - 关键改进：
    - 响应字段：添加 `apacheConfiguredCount` 字段
    - 消息构建：根据成功数量和Apache配置数量构建消息
    - 响应格式：`{ success, message, results, apacheConfiguredCount }`
- **影响范围**：
  - 前端能准确获取Apache配置状态
  - 响应信息更加完整和准确

**前端响应处理优化**：
- **功能描述**：
  - 修复响应检查逻辑，确保成功消息正确显示
  - 使用后端返回的消息，包含完整的配置信息
  - 延长提示显示时间，确保用户能看到完整信息
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键改进：
    - 响应检查：修复 `response.data.success !== false` 检查逻辑
    - 消息使用：优先使用后端返回的消息，如果没有则自己构建
    - 显示时间：根据是否有Apache配置调整显示时间
- **影响范围**：
  - 成功消息能正确显示
  - 提示信息更加完整和准确

### 📋 主要更新内容

#### 🔄 证书上传自动化流程

**1. `backend/dispatcher/server.js`**：
- **自动配置Apache逻辑**：
  - 检测证书名称是否为域名格式（使用正则表达式）
  - 自动保存域名-证书关联到 `config/ssl-domain-cert.json`
  - 调用 `cert_setup.sh enable-ssl` 配置Apache
  - 记录配置结果（成功或失败）
- **自动构建前端逻辑**：
  - 证书上传成功后，使用 `spawn` 异步执行 `start.sh rebuild`
  - 设置5分钟超时保护
  - 记录构建输出和错误信息
- **响应消息优化**：
  - 添加 `apacheConfiguredCount` 字段
  - 构建包含Apache配置状态的响应消息

#### 💬 提示信息优化

**1. `frontend/src/modules/Dashboard.vue`**：
- **对话框内提示显示**：
  - 在SSL管理对话框右上角添加通知消息区域
  - 支持四种消息类型（success、error、warning、info）
  - 消息可手动关闭
- **响应处理优化**：
  - 修复响应检查逻辑
  - 使用后端返回的消息
  - 根据Apache配置状态调整显示时间

### 🎯 效果与影响

**自动化程度提升**：
- 证书上传后自动配置Apache，无需手动操作
- 前端代码更新后自动构建，提升开发效率
- 减少人工操作步骤，降低操作错误率

**用户体验优化**：
- 上传成功后立即看到提示信息
- 提示信息包含完整的操作结果和后续指导
- 对话框内提示更加直观和友好

**系统稳定性提升**：
- 自动配置流程标准化，减少配置错误
- 构建过程有超时保护，避免长时间阻塞
- 详细的日志记录，便于问题排查

### 📝 升级说明

#### 自动升级
- **无需手动操作**：升级后自动支持证书上传自动化流程
- **向后兼容**：完全兼容之前版本的证书上传功能
- **配置迁移**：无需迁移配置，系统自动处理

#### 验证方法
1. **测试证书上传自动化**：
   - 上传域名格式的证书（如 `www.example.com`）
   - 检查是否自动配置Apache
   - 检查域名是否自动添加到SSL域名列表
   - 检查Apache服务是否自动重启

2. **测试提示信息显示**：
   - 上传证书后检查对话框内是否显示成功提示
   - 检查提示信息是否包含Apache配置状态
   - 检查提示信息是否包含等待时间说明

3. **测试前端自动构建**：
   - 上传证书后检查日志，确认前端构建是否触发
   - 检查构建是否成功完成
   - 检查前端文件是否更新

## 🎉 最新版本 - V4.6.1 (2026-01-23) - 备份功能整合与证书上传体验优化

### 🎊 版本亮点

**V4.6.1 是一个用户体验优化版本，整合了备份功能，优化了证书上传体验，完善了HTTP跳转HTTPS功能，提升了系统的易用性和稳定性。**

#### 💾 备份功能整合

**统一备份入口**：
- **功能描述**：
  - 将"完整备份"和"定时备份"两个独立按钮整合到统一的"备份功能"按钮
  - 创建备份管理对话框，包含两个标签页：
    - 完整备份标签页：显示备份内容说明（数据库、配置文件、邮件目录），提供立即执行完整备份功能
    - 定时备份标签页：包含所有定时备份配置选项（备份间隔、备份内容、保留设置、自定义执行时间）
  - 优化用户体验，备份功能更加集中和统一
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键功能：
    - `openBackupManagementDialog()`：打开备份管理对话框
    - `executeFullBackup()`：执行完整备份
    - `executeBackupSetup()`：设置定时备份
    - `backupTab`：标签页切换（'full' 或 'scheduled'）
- **影响范围**：
  - 备份功能更加集中，用户操作更加便捷
  - 界面更加简洁，减少了按钮数量

#### 📤 证书上传体验优化

**拖拽上传功能**：
- **功能描述**：
  - 移除"添加证书"按钮，改为直接拖拽上传
  - 支持拖拽文件到上传区域或点击选择文件
  - 支持多文件同时上传，自动识别同一域名的证书文件
  - 拖拽时显示视觉反馈（高亮边框和背景色）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键功能：
    - `handleDrop()`：处理拖拽上传
    - `handleFileSelect()`：处理文件选择
    - `processFiles()`：处理文件并自动分组
    - `extractDomainFromFileName()`：从文件名提取域名
    - `getFileType()`：判断文件类型（key、cert、chain）
- **影响范围**：
  - 证书上传更加便捷，支持批量上传
  - 用户体验更加友好和直观

**智能文件识别**：
- **功能描述**：
  - 自动从文件名提取域名（支持www.前缀）
  - 自动识别文件类型：
    - `.key` → 私钥文件
    - `_public.crt` 或普通 `.crt` → 证书文件
    - `_chain.crt` → 证书链文件
  - 按域名自动分组，自动填充证书名称（默认使用域名）
  - 识别失败时显示友好的提示信息
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 关键函数：
    - `extractDomainFromFileName()`：使用正则表达式提取域名
    - `getFileType()`：根据文件名关键词判断文件类型
    - `processFiles()`：按域名分组文件，创建证书上传项
- **影响范围**：
  - 证书上传更加智能，减少用户手动操作
  - 支持多种文件命名格式

**Chain证书保护**：
- **功能描述**：
  - 证书链文件不会绑定到域名，仅在证书选择下拉框中排除chain类型证书
  - 前端和后端双重过滤，确保chain证书不会被误绑定
  - 证书链文件保存为`.chain.crt`格式，用于完整的SSL证书验证
- **技术实现**：
  - 文件：
    - `frontend/src/modules/Dashboard.vue`：`availableCertificatesForBinding`计算属性过滤chain证书
    - `backend/dispatcher/server.js`：`/api/cert/list` API排除chain证书
  - 过滤规则：
    - 排除包含`chain`、`ca-bundle`、`intermediate`等关键词的证书
    - 排除以`_chain`或`-chain`结尾的证书名称
- **影响范围**：
  - 防止chain证书被误绑定到域名
  - 证书选择更加准确和安全

#### ✅ HTTP跳转HTTPS功能完善

**功能可行性确保**：
- **功能描述**：
  - 完善mod_rewrite模块自动启用检查
  - 添加Apache配置语法验证（每个配置文件生成后验证，重启前全局验证）
  - 增强服务重启后的状态验证和端口监听检查
  - 优化错误处理和日志输出，提供详细的配置反馈
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 关键改进：
    - 确保mod_rewrite模块已启用
    - 每个HTTP虚拟主机配置生成后验证语法
    - 重启Apache前全局验证配置语法
    - 重启后验证服务状态和端口监听
    - 提供详细的错误信息和排查建议
- **影响范围**：
  - HTTP跳转HTTPS功能更加可靠和稳定
  - 配置错误能够及时发现和处理

### 📋 主要更新内容

#### 💾 备份功能整合

**1. `frontend/src/modules/Dashboard.vue`**：
- **移除独立按钮**：
  - 删除"完整备份"按钮
  - 删除"定时备份"按钮
- **创建统一备份功能按钮**：
  - 添加"备份功能"按钮（蓝色主题）
  - 按钮位于高级功能区域
- **创建备份管理对话框**：
  - 包含两个标签页：完整备份、定时备份
  - 完整备份标签页：显示备份内容说明，提供立即执行完整备份按钮
  - 定时备份标签页：包含所有定时备份配置选项
- **关键函数**：
  - `openBackupManagementDialog()`：打开备份管理对话框
  - `executeFullBackup()`：执行完整备份（关闭对话框后调用call('full-backup')）
  - `executeBackupSetup()`：设置定时备份（已更新，在开始时关闭对话框）

#### 📤 证书上传体验优化

**1. `frontend/src/modules/Dashboard.vue`**：
- **拖拽上传功能**：
  - 移除"+ 添加证书"按钮
  - 实现拖拽上传区域（支持拖拽和点击）
  - 添加拖拽视觉反馈（isDragging状态）
- **智能文件识别**：
  - `extractDomainFromFileName()`：从文件名提取域名
  - `getFileType()`：判断文件类型（key、cert、chain、unknown）
  - `processFiles()`：按域名分组文件，自动创建证书上传项
- **Chain证书保护**：
  - `availableCertificatesForBinding`计算属性：过滤chain证书
  - 在添加域名和编辑证书关联的下拉框中排除chain证书
  - 显示提示信息说明chain证书不会显示在列表中

**2. `backend/dispatcher/server.js`**：
- **证书列表API更新**：
  - `GET /api/cert/list`：排除chain证书（包含chain、ca-bundle、intermediate等关键词）
  - 确保chain证书不会被包含在可绑定证书列表中
- **批量上传API**：
  - `POST /api/cert/batch-upload`：支持批量上传多个证书
  - 每个证书独立验证和处理
  - 支持证书链文件上传（保存为`.chain.crt`）

#### ✅ HTTP跳转HTTPS功能完善

**1. `backend/scripts/cert_setup.sh`**：
- **mod_rewrite模块检查**：
  - 确保mod_rewrite模块已启用
  - 如果未启用，自动添加到httpd.conf
- **配置语法验证**：
  - 每个HTTP虚拟主机配置生成后验证语法
  - 重启Apache前全局验证配置语法
  - 配置语法错误时中止并显示详细错误信息
- **服务状态验证**：
  - 重启Apache后验证服务状态
  - 验证端口监听状态
  - 提供详细的错误信息和排查建议

**2. `frontend/src/modules/Dashboard.vue`**：
- **HTTP跳转功能改进**：
  - 添加前置检查（检查是否有配置的SSL域名）
  - 配置成功后自动刷新域名列表
  - 优化提示信息

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重新构建前端**：
   ```bash
   # 重新构建前端
   cd frontend
   npm install
   npm run build
   ```

3. **重启服务**：
   ```bash
   # 重启所有服务
   ./start.sh restart
   
   # 或仅重启调度层服务
   ./start.sh restart-dispatcher
   ```

4. **验证功能**：
   ```bash
   # 访问Dashboard，测试以下功能：
   # - 点击"备份功能"按钮，测试备份管理对话框
   # - 拖拽证书文件到上传区域，测试自动识别功能
   # - 测试HTTP跳转HTTPS功能
   ```

### 📝 版本历史

**V4.6.1** (2026-01-23)：
- 备份功能整合（完整备份和定时备份整合到统一按钮、创建备份管理对话框）
- 证书上传体验优化（拖拽上传、自动识别同一域名证书文件、排除chain证书绑定）
- HTTP跳转HTTPS功能完善（mod_rewrite模块检查、配置语法验证、服务状态验证）

## 🎉 历史版本 - V4.6.0 (2026-01-23) - SSL管理功能重构与域名-证书关联管理

### 🎊 版本亮点

**V4.6.0 是一个功能重构和增强版本，重构了SSL管理功能，实现了域名-证书关联管理，添加了HTTP自动跳转HTTPS功能，并优化了系统稳定性。**

#### 🔄 SSL管理功能重构

**统一管理入口**：
- **功能描述**：
  - SSL配置从系统设置（Settings.vue）移除，统一到Dashboard管理
  - 在Dashboard.vue添加"管理SSL"按钮，提供统一的SSL管理入口
  - 创建完整的SSL管理对话框，包含三个标签页：
    - 域名管理：查看、添加、删除SSL域名，支持域名-证书关联
    - 证书管理：查看可用证书列表和关联的域名
    - 上传证书：上传证书文件（仅处理文件，不关联域名）
- **技术实现**：
  - 文件：`frontend/src/modules/Dashboard.vue`
  - 位置：SSL管理对话框和相关函数
  - 关键功能：openSslManagementDialog、loadSslDomains、loadAvailableCertificates
- **影响范围**：
  - SSL管理功能更加集中和统一
  - 用户体验更加友好和直观

#### 🔗 域名与证书关联管理

**灵活的证书管理**：
- **功能描述**：
  - 证书上传仅处理文件，使用证书名称（certName）标识，不再强制关联域名
  - 支持域名-证书手动关联，添加域名时可选择使用的证书
  - 支持多域名使用同一证书，实现证书共享和复用
  - 添加域名-证书关联配置管理（config/ssl-domain-cert.json）
- **技术实现**：
  - 文件：
    - `backend/dispatcher/server.js`：添加域名-证书关联API
    - `frontend/src/modules/Dashboard.vue`：域名-证书关联UI
  - 关键API：
    - `POST /api/cert/upload`：证书上传（使用certName参数）
    - `POST /api/cert/domains`：添加域名（支持certName参数）
    - `PUT /api/cert/domains/:domain/cert`：更新域名证书关联
    - `GET /api/cert/list`：获取证书列表和关联域名
  - 配置文件：`config/ssl-domain-cert.json`（存储域名-证书映射关系）
- **影响范围**：
  - 证书管理更加灵活，支持证书复用
  - 域名和证书可以独立管理，提高管理效率

#### 🔀 HTTP自动跳转HTTPS功能

**自动跳转配置**：
- **功能描述**：
  - 添加HTTP跳转HTTPS按钮（仅在SSL启用后显示）
  - 配置需要2-3分钟生效提示，提醒用户等待配置生效
  - 支持为所有配置的域名自动创建HTTP跳转配置
  - 在cert_setup.sh中添加enable-http-redirect功能
- **技术实现**：
  - 文件：
    - `backend/scripts/cert_setup.sh`：添加enable-http-redirect功能
    - `backend/dispatcher/server.js`：添加enable-http-redirect操作支持
    - `frontend/src/modules/Dashboard.vue`：HTTP跳转按钮和提示
  - 关键功能：
    - 自动读取域名-证书关联配置
    - 为每个域名创建HTTP虚拟主机配置（自动跳转到HTTPS）
    - 重启Apache服务使配置生效
- **影响范围**：
  - 用户访问HTTP时自动跳转到HTTPS，提升安全性
  - 配置过程简单，用户体验友好

#### 🛠️ 系统稳定性优化

**脚本修复**：
- **修复内容**：
  - 修复cert_setup.sh语法错误和heredoc代码块闭合问题
  - 优化configure_apache_ssl函数以支持证书名称参数
  - 改进域名-证书关联配置的读取逻辑（支持jq和grep两种方式）
  - 修复证书上传API以使用certName而不是domain
- **技术实现**：
  - 文件：`backend/scripts/cert_setup.sh`
  - 关键修复：
    - configure_apache_ssl函数添加cert_name参数支持
    - enable-http-redirect功能完善heredoc代码块
    - 域名列表提取逻辑优化（使用jq优先，grep作为后备）
- **影响范围**：
  - 系统稳定性提升，脚本执行更加可靠
  - 证书配置更加灵活和准确

### 📋 主要更新内容

#### 🔄 SSL管理功能重构

**1. `frontend/src/modules/Settings.vue`**：
- **移除SSL配置部分**：
  - 删除所有SSL相关的UI组件和状态变量
  - 删除enableSSL、loadSslDomains、addSslDomain等函数
  - SSL配置功能完全移除

**2. `frontend/src/modules/Dashboard.vue`**：
- **添加"管理SSL"按钮**：
  - 在高级功能区域添加"管理SSL"按钮
  - 按钮样式与其他高级功能按钮保持一致
- **创建SSL管理对话框**：
  - 三个标签页：域名管理、证书管理、上传证书
  - 域名管理：查看、添加、删除SSL域名，支持域名-证书关联
  - 证书管理：查看可用证书列表和关联的域名
  - 上传证书：上传证书文件（使用certName参数）
- **关键函数**：
  - `openSslManagementDialog()`：打开SSL管理对话框
  - `loadSslDomains()`：加载SSL域名列表
  - `loadAvailableCertificates()`：加载可用证书列表
  - `addSslDomain()`：添加SSL域名（支持certName参数）
  - `editDomainCert()`：编辑域名证书关联
  - `uploadCertificate()`：上传证书文件

#### 🔗 域名与证书关联管理

**1. `backend/dispatcher/server.js`**：
- **证书上传API更新**：
  - `POST /api/cert/upload`：使用certName参数而不是domain
  - 证书名称格式验证（字母、数字、连字符、下划线）
  - 仅处理文件上传，不关联域名
- **域名-证书关联API**：
  - `POST /api/cert/domains`：添加域名（支持certName参数）
  - `PUT /api/cert/domains/:domain/cert`：更新域名证书关联
  - `GET /api/cert/list`：获取证书列表和关联域名
  - `GET /api/cert/ssl-status`：检查SSL状态
- **配置文件管理**：
  - 域名-证书关联存储在`config/ssl-domain-cert.json`
  - 自动创建和管理配置文件

**2. `backend/scripts/cert_setup.sh`**：
- **configure_apache_ssl函数优化**：
  - 添加cert_name参数支持（第二个参数）
  - 支持从域名-证书关联配置读取证书名称
  - SSL配置使用cert_name指定的证书文件
- **enable-http-redirect功能**：
  - 添加enable-http-redirect操作支持
  - 自动读取域名-证书关联配置
  - 为每个域名创建HTTP跳转配置
  - 支持jq和grep两种方式读取配置

#### 🔀 HTTP自动跳转HTTPS功能

**1. `backend/scripts/cert_setup.sh`**：
- **enable-http-redirect功能实现**：
  - 读取域名-证书关联配置（config/ssl-domain-cert.json）
  - 从Apache配置中获取域名（如果配置文件中没有）
  - 为每个域名创建HTTP虚拟主机配置（自动跳转到HTTPS）
  - 重启Apache服务使配置生效
- **关键代码**：
  ```bash
  # 创建HTTP虚拟主机配置（自动跳转到HTTPS）
  cat > "$http_vhost_conf" <<EOF
  <VirtualHost *:${APACHE_HTTP_PORT}>
      ServerName ${domain_item}
      RewriteEngine On
      RewriteCond %{HTTPS} off
      RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
  </VirtualHost>
  EOF
  ```

**2. `frontend/src/modules/Dashboard.vue`**：
- **HTTP跳转按钮**：
  - 仅在SSL启用后显示
  - 配置提示需要2-3分钟生效
  - `enableHttpRedirect()`函数调用后端API

#### 🛠️ 系统稳定性优化

**1. `backend/scripts/cert_setup.sh`**：
- **heredoc代码块修复**：
  - 确保所有heredoc代码块正确闭合
  - 修复enable-http-redirect功能中的heredoc问题
- **域名列表提取优化**：
  - 优先使用jq解析JSON配置
  - grep作为后备方案
  - 改进错误处理逻辑

**2. `backend/dispatcher/server.js`**：
- **证书上传API修复**：
  - 修复multer配置以使用certName参数
  - 改进错误处理和临时文件清理
  - 添加证书名称格式验证

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重新构建前端**：
   ```bash
   # 重新构建前端
   cd frontend
   npm install
   npm run build
   ```

3. **重启服务**：
   ```bash
   # 重启所有服务
   ./start.sh restart
   
   # 或仅重启调度层服务
   ./start.sh restart-dispatcher
   ```

4. **验证功能**：
   ```bash
   # 访问Dashboard，点击"管理SSL"按钮
   # 测试SSL管理功能：
   # - 上传证书文件
   # - 添加SSL域名并关联证书
   # - 启用SSL
   # - 启用HTTP跳转HTTPS
   ```

### 📝 版本历史

**V4.6.0** (2026-01-23)：
- SSL管理功能重构（SSL配置从系统设置移除、统一到Dashboard管理、添加"管理SSL"按钮）
- 域名与证书关联管理（证书上传仅处理文件、支持域名-证书手动关联、支持多域名使用同一证书）
- HTTP自动跳转HTTPS功能（添加HTTP跳转按钮、仅在SSL启用后显示、配置需要2-3分钟提示）
- 系统稳定性优化（修复cert_setup.sh语法错误、修复heredoc代码块闭合问题）

**V4.5.3** (2026-01-20)：
- 邮件详情权限检查修复（分离权限检查逻辑、修复SQL字段名错误）
- Python脚本语法错误修复（修复嵌套try语句缩进）
- 邮件内容显示优化（错误状态显示、回退机制）

**V4.5.2** (2026-01-20)：
- 备案号显示问题修复（注册和忘记密码页面）
- 系统设置保存优化（重装时配置保护机制）
- 用户体验优化（删除重新部署提示）

## 🎉 历史版本 - V4.5.3 (2026-01-20) - 邮件详情API问题修复

### 🎊 版本亮点

**V4.5.3 是一个问题修复版本，修复了邮件详情API的权限检查问题、Python脚本语法错误和邮件内容显示问题，提升了系统的稳定性和用户体验。**

#### 🔧 邮件详情权限检查修复

**权限检查逻辑优化**：
- **问题描述**：
  - 邮件详情API返回404或500错误
  - 权限检查失败导致用户无法访问自己的邮件
  - SQL查询使用了错误的字段名（`er_user.email_address`）
- **修复内容**：
  - **分离权限检查逻辑**：
    - 先检查邮件是否存在
    - 区分已发送文件夹（folder_id=2）和收件箱的权限验证
    - 已发送文件夹：检查发件人是否是当前用户
    - 收件箱：检查email_recipients表中是否有当前用户的记录
  - **修复SQL字段名错误**：
    - 权限检查查询中使用`email_address`而不是`er_user.email_address`
    - 构建独立的权限检查条件，避免LEFT JOIN导致的权限检查失败
  - **添加详细日志**：
    - 记录权限检查条件、查询结果和权限检查是否通过
    - 便于问题排查和调试
- **技术实现**：
  - 文件：`backend/scripts/mail_db.sh`
  - 位置：第1702-1764行（权限检查逻辑）
  - 关键改进：先检查存在性，再检查权限，最后查询详情
- **影响范围**：
  - 修复后，用户可以正常访问自己的邮件详情
  - 权限检查更加准确和可靠

#### 🐛 Python脚本语法错误修复

**JSON合并脚本修复**：
- **问题描述**：
  - Python脚本中嵌套try语句的缩进错误
  - 导致JSON数据合并失败，返回空数组
  - 邮件详情API返回500错误
- **修复内容**：
  - 修复第1959行嵌套try语句的缩进错误
  - 确保Python脚本语法正确
  - 修复JSON数据合并逻辑
- **技术实现**：
  - 文件：`backend/scripts/mail_db.sh`
  - 位置：第1947-1966行（Python脚本部分）
  - 关键修复：正确缩进嵌套try语句
- **影响范围**：
  - 修复后，邮件详情API可以正确返回JSON数据
  - 邮件内容可以正常显示

#### 📧 邮件内容显示优化

**前端显示逻辑改进**：
- **问题描述**：
  - 邮件内容为空时显示错误
  - 权限错误和内容为空没有区分
  - 错误提示信息不够友好
- **修复内容**：
  - **错误状态显示**：
    - 添加错误状态显示，区分权限错误和内容为空
    - 权限错误显示红色错误提示框
    - 内容为空显示灰色空内容提示
  - **错误处理优化**：
    - 正确处理404和500错误
    - 解析错误响应，提取错误消息
    - 显示友好的错误提示
  - **回退机制**：
    - 如果详情API返回空内容，尝试使用列表中的email对象的内容
    - 确保邮件内容能够正常显示
- **技术实现**：
  - 文件：`frontend/src/modules/Mail.vue`
  - 位置：第4352-4487行（错误处理逻辑）
  - 关键改进：错误状态显示、错误处理优化、回退机制
- **影响范围**：
  - 修复后，邮件内容可以正常显示
  - 错误提示更加友好和清晰

### 📋 主要更新内容

#### 🔧 邮件详情权限检查修复

**1. `backend/scripts/mail_db.sh`**：
- **权限检查逻辑优化（第1702-1764行）**：
  - 先检查邮件是否存在
  - 分离权限检查逻辑，区分已发送文件夹和收件箱
  - 构建独立的权限检查条件
  - 添加详细的权限检查日志
- **关键代码**：
  ```bash
  # 先检查邮件是否存在
  local email_exists=$(mysql ... "SELECT COUNT(*) FROM emails WHERE id='$email_id' AND (is_deleted=0 OR folder_id=4);" ...)
  
  # 检查权限
  if [[ "$folder_id" == "2" ]]; then
    # 已发送文件夹：检查发件人是否是当前用户
    # ...
  else
    # 收件箱：检查email_recipients表中是否有当前用户的记录
    permission_condition="email_address = '$user'"
    recipient_count=$(mysql ... "SELECT COUNT(*) FROM email_recipients WHERE email_id='$email_id' AND recipient_type IN ('to', 'cc') AND ($permission_condition);" ...)
  fi
  ```

#### 🐛 Python脚本语法错误修复

**1. `backend/scripts/mail_db.sh`**：
- **Python脚本修复（第1947-1966行）**：
  - 修复嵌套try语句的缩进错误
  - 确保JSON数据正确合并
- **关键修复**：
  ```python
  try:
      # 从文件读取email_basic
      temp_file = '''$temp_json_file'''
      with open(temp_file, 'r', encoding='utf-8') as f:
          email_basic_str = f.read()
      
      # 先尝试解析email_basic
      try:  # 修复：正确缩进
          email = json.loads(email_basic_str)
      except json.JSONDecodeError as e:
          # 修复控制字符
          # ...
  ```

#### 📧 邮件内容显示优化

**1. `frontend/src/modules/Mail.vue`**：
- **错误处理优化（第4352-4487行）**：
  - 正确处理404和500错误
  - 添加错误状态显示
  - 实现回退机制
- **关键改进**：
  ```typescript
  // 处理错误响应（404等）
  if (response.status === 404) {
    selectedEmail.value = {
      ...email,
      error: true,
      errorMessage: errorMessage
    }
  }
  
  // 如果详情API返回空内容，尝试使用列表中的email对象的内容
  if ((!emailDetail.body || !emailDetail.body.trim()) && (!emailDetail.html || !emailDetail.html.trim())) {
    if (email && email.body && email.body.trim()) {
      emailDetail.body = email.body
    }
  }
  ```

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重启服务**：
   ```bash
   # 重启Node.js调度层服务
   sudo systemctl restart mail-dispatcher
   
   # 重新构建前端
   cd frontend
   npm run build
   ```

3. **验证修复**：
   ```bash
   # 测试邮件详情API
   curl -u "username:password" http://localhost:8081/api/mail/6
   
   # 查看日志
   tail -f /var/log/mail-ops/mail-db.log | grep -E "权限检查|email_id=6"
   ```

## 🎉 历史版本 - V4.5.2 (2026-01-20) - 问题修复与系统优化

### 🎊 版本亮点

**V4.5.2 是一个问题修复和系统优化版本，修复了注册和忘记密码页面备案号不显示的问题，改进了系统设置在重装时的保存和恢复机制，并优化了用户体验，提升了系统的稳定性和易用性。**

#### 🐛 备案号显示问题修复

**注册和忘记密码页面修复**：
- **问题描述**：
  - 注册页面和忘记密码页面的备案号不显示
  - 原因是`onMounted`中缺少`loadIcpSettings()`调用
- **修复内容**：
  - 在`Register.vue`的`onMounted`中添加`loadIcpSettings()`调用
  - 在`Reset.vue`的`onMounted`中添加`loadIcpSettings()`调用
  - 确保所有页面都能正确加载和显示备案号
- **影响范围**：
  - 修复后，所有页面（主页、登录、注册、重置密码、更新日志、Dashboard、邮件、设置、个人资料）都能正确显示备案号

#### 💾 系统设置保存优化

**重装时配置保护机制**：
- **问题描述**：
  - 使用`start.sh start`重装系统时，系统设置不保存以往配置
  - 重装后用户需要重新配置所有系统设置
- **优化内容**：
  - **改进备份逻辑**：
    - 在重装开始前强制备份现有配置文件
    - 无论备份是否存在，都更新备份（确保备份是最新的）
    - 避免备份文件过时
  - **智能恢复机制**：
    - 重装完成后自动检查并恢复系统设置
    - 三种恢复场景：
      - 配置文件不存在：直接恢复备份
      - 备份比配置文件新：恢复备份
      - 配置文件是默认值（adminEmail为xm@localhost）：恢复备份
  - **默认值检测**：
    - 通过检查`adminEmail`字段判断是否为默认配置
    - 如果当前配置是默认值但备份不是，则恢复备份
- **技术实现**：
  - 文件：`start.sh`
  - 备份位置：第234-242行（重装开始前备份）
  - 恢复位置：第3313-3341行（重装完成后恢复）
- **使用场景**：
  - 系统重装时自动保护用户配置
  - 配置文件意外删除后自动恢复
  - 系统升级时保留用户配置

#### 🎨 用户体验优化

**系统设置界面优化**：
- **删除重新部署提示**：
  - 删除备案号设置中关于重新部署前端的提示框
  - 原因：系统会自动完成前端部署，无需用户手动操作
  - 简化用户操作流程，提升使用体验
- **优化内容**：
  - 移除黄色提示框（"重要提示"、"修改备案号设置后，需要重新部署前端页面才能生效"等）
  - 移除命令提示（`cd frontend && npm run build`）
  - 保持界面简洁，减少用户困惑

### 📋 主要更新内容

#### 🐛 备案号显示问题修复

**1. `frontend/src/modules/Register.vue`**：
- **修复内容**：
  - 在`onMounted`中添加`loadIcpSettings()`调用
  - 确保注册页面能正确加载备案号设置
- **代码变更**：
  ```typescript
  onMounted(() => {
    loadVersion()
    loadIcpSettings()  // 添加了这一行
    loadCaptcha()
  })
  ```

**2. `frontend/src/modules/Reset.vue`**：
- **修复内容**：
  - 在`onMounted`中添加`loadIcpSettings()`调用
  - 确保忘记密码页面能正确加载备案号设置
- **代码变更**：
  ```typescript
  onMounted(() => {
    loadVersion()
    loadIcpSettings()  // 添加了这一行
    loadCaptcha()
  })
  ```

#### 💾 系统设置保存优化

**1. `start.sh`**：
- **备份逻辑改进（第234-242行）**：
  - 在重装开始前强制备份现有配置文件
  - 无论备份是否存在，都更新备份（确保备份是最新的）
  - 避免备份文件过时
- **恢复逻辑改进（第3313-3341行）**：
  - 重装完成后自动检查并恢复系统设置
  - 支持三种恢复场景：配置文件不存在、备份更新、默认值检测
  - 自动设置正确的文件权限和所有者
- **关键代码**：
  ```bash
  # 重装开始前备份
  if [[ -f "$SYSTEM_SETTINGS_FILE" ]]; then
    cp "$SYSTEM_SETTINGS_FILE" "$SYSTEM_SETTINGS_BACKUP" 2>/dev/null || true
    echo "[INIT] 系统设置文件已备份: $SYSTEM_SETTINGS_BACKUP"
  fi
  
  # 重装完成后恢复
  if [[ -f "$SYSTEM_SETTINGS_BACKUP" ]]; then
    # 检查并恢复配置
    # ...恢复逻辑...
  fi
  ```

#### 🎨 用户体验优化

**1. `frontend/src/modules/Settings.vue`**：
- **删除重新部署提示**：
  - 删除黄色提示框（第162-174行）
  - 移除"重要提示"、"修改备案号设置后，需要重新部署前端页面才能生效"等提示
  - 移除命令提示（`cd frontend && npm run build`）
- **优化效果**：
  - 界面更简洁
  - 减少用户困惑
  - 提升用户体验

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重启服务**：
   ```bash
   # 重启Node.js调度层服务
   sudo systemctl restart mail-dispatcher
   
   # 重新构建前端
   cd frontend
   npm run build
   
   # 重启Apache服务
   sudo systemctl restart httpd
   ```

3. **验证功能**：
   ```bash
   # 测试备案号显示
   # 1. 访问注册页面，检查页脚是否显示备案号（如果已启用）
   # 2. 访问忘记密码页面，检查页脚是否显示备案号（如果已启用）
   # 3. 进入系统设置，检查备案号设置是否正常
   # 4. 测试重装后配置恢复
   #    - 修改一些系统设置
   #    - 执行 ./start.sh start 重装
   #    - 检查系统设置是否已恢复
   ```

4. **检查日志**：
   ```bash
   # 查看调度层日志
   sudo journalctl -u mail-dispatcher -n 100 --no-pager
   
   # 查看安装日志
   tail -50 /var/log/mail-ops/install.log
   ```

### 📝 版本历史

**V4.5.2** (2026-01-20)：
- 备案号显示问题修复（注册和忘记密码页面）
- 系统设置保存优化（重装时配置保护机制）
- 用户体验优化（删除重新部署提示）

**V4.5.1** (2026-01-20)：
- ICP备案号功能（全页面备案号显示、备案号配置管理、公开API接口）
- 版权信息更新（版权年份从2024-2025更新为2024-2026）

## 🎉 历史版本 - V4.5.1 (2026-01-20) - ICP备案号功能与版权信息更新

### 🎊 版本亮点

**V4.5.1 是一个ICP备案号功能和版权信息更新版本，在所有页面底部添加了ICP备案号显示功能，支持通过系统设置进行配置管理，并统一更新了所有页面的版权年份信息，提升了系统的合规性和专业性。**

#### 🏛️ ICP备案号功能

**全页面备案号显示**：
- **显示位置**：
  - 所有页面底部显示ICP备案号（主页、登录、注册、重置密码、更新日志、Dashboard、邮件、设置、个人资料等）
  - 备案号显示在版权信息"2024-2026 XM."的右侧
  - 格式：`© 2024-2026 XM. 京ICP备12345678号`
- **功能特点**：
  - 支持点击备案号跳转到配置的链接（默认：工信部备案查询网站）
  - 备案号显示可通过系统设置开启/关闭
  - 未登录用户也可以看到备案号（如主页、登录页等）
  - 响应式设计，适配移动端和桌面端

**备案号配置管理**：
- **系统设置**：
  - 在系统设置中添加备案号配置接口（启用/禁用、备案号、链接URL）
  - 配置存储在`config/system-settings.json`中
  - 配置结构：`general.icp.enabled`（布尔值）、`general.icp.number`（字符串）、`general.icp.url`（字符串）
- **前端部署要求**：
  - 修改备案号设置后需要重新部署前端才能生效
  - 系统设置页面会显示部署提示信息
  - 部署命令：`cd frontend && npm run build`

**公开API接口**：
- **API端点**：
  - 新增`/api/icp-info`公开API端点，无需认证即可获取备案号信息
  - 返回格式：`{ success: true, icp: { enabled: boolean, number: string, url: string } }`
  - 支持未登录用户访问（如主页、登录页等）
- **实现位置**：
  - 后端：`backend/dispatcher/server.js`中的`/api/icp-info`端点
  - 前端：所有页面通过`loadIcpSettings()`函数加载备案号设置

#### 📅 版权信息更新

**版权年份更新**：
- **更新范围**：
  - 将所有页面的版权信息从"2024-2025 XM."更新为"2024-2026 XM."
  - 统一更新所有页面（主页、登录、注册、重置密码、更新日志、Dashboard、邮件、设置、个人资料等）
- **显示位置**：
  - 页面底部版权区域
  - 与ICP备案号并排显示

### 📋 主要更新内容

#### 🏛️ ICP备案号功能

**1. `backend/dispatcher/server.js`**：
- **公开API端点**：
  - 新增`/api/icp-info` GET端点，无需认证
  - 从`config/system-settings.json`读取备案号配置
  - 返回备案号启用状态、备案号和链接URL
- **实现逻辑**：
  ```javascript
  app.get('/api/icp-info', (req, res) => {
    const systemSettings = JSON.parse(fs.readFileSync('config/system-settings.json', 'utf8'));
    const icp = systemSettings.general?.icp || { enabled: false, number: '', url: 'https://beian.miit.gov.cn/' };
    res.json({ success: true, icp });
  });
  ```

**2. `frontend/src/components/Layout.vue`**：
- **备案号显示**：
  - 在页脚添加备案号显示逻辑
  - 使用`icpSettings`响应式变量管理备案号状态
  - 在`onMounted`中调用`loadIcpSettings()`加载备案号设置
- **样式设计**：
  - 备案号显示在版权信息右侧
  - 链接样式：灰色文字，悬停时变深
  - 响应式设计，适配移动端

**3. `frontend/src/modules/Landing.vue`**：
- **备案号显示**：
  - 在页脚添加备案号显示逻辑
  - 使用`icpSettings`响应式变量管理备案号状态
  - 在`onMounted`中调用`loadIcpSettings()`加载备案号设置
- **样式设计**：
  - 使用`.icp-inline`样式类
  - 链接样式：白色半透明，悬停时变亮

**4. `frontend/src/modules/Login.vue`、`Register.vue`、`Reset.vue`、`Changelog.vue`**：
- **备案号显示**：
  - 每个页面都添加了备案号显示逻辑
  - 使用`icpSettings`响应式变量管理备案号状态
  - 在`onMounted`中调用`loadIcpSettings()`加载备案号设置
- **样式设计**：
  - 统一使用`.icp-inline`样式类
  - 链接样式：白色半透明，悬停时变亮

**5. `frontend/src/modules/Settings.vue`**：
- **备案号配置**：
  - 在"常规设置"部分添加备案号配置选项
  - 包括：启用/禁用开关、备案号输入框、链接URL输入框
  - 显示前端部署提示信息
- **配置保存**：
  - 保存到`config/system-settings.json`的`general.icp`对象中
  - 保存成功后提示需要重新部署前端

**6. `config/system-settings.json`**：
- **配置结构**：
  ```json
  {
    "general": {
      "icp": {
        "enabled": false,
        "number": "",
        "url": "https://beian.miit.gov.cn/"
      }
    }
  }
  ```

#### 📅 版权信息更新

**1. 所有页面组件**：
- **版权年份更新**：
  - `Layout.vue`：从"2024-2025 XM."更新为"2024-2026 XM."
  - `Landing.vue`：从"2024-2025 XM."更新为"2024-2026 XM."
  - `Login.vue`：从"2024-2025 XM."更新为"2024-2026 XM."
  - `Register.vue`：从"2024-2025 XM."更新为"2024-2026 XM."
  - `Reset.vue`：从"2024-2025 XM."更新为"2024-2026 XM."
  - `Changelog.vue`：从"2024-2025 XM."更新为"2024-2026 XM."

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **配置备案号**（可选）：
   ```bash
   # 编辑系统配置文件
   vi config/system-settings.json
   
   # 添加或修改备案号配置
   # {
   #   "general": {
   #     "icp": {
   #       "enabled": true,
   #       "number": "京ICP备12345678号",
   #       "url": "https://beian.miit.gov.cn/"
   #     }
   #   }
   # }
   ```

3. **重启服务**：
   ```bash
   # 重启Node.js调度层服务
   sudo systemctl restart mail-dispatcher
   
   # 重新构建前端（必须，因为备案号设置需要前端重新部署）
   cd frontend
   npm run build
   
   # 重启Apache服务
   sudo systemctl restart httpd
   ```

4. **验证功能**：
   ```bash
   # 测试备案号显示功能
   # 1. 访问主页，检查页脚是否显示备案号（如果已启用）
   # 2. 登录系统，检查所有页面是否都显示备案号
   # 3. 进入系统设置，配置备案号
   # 4. 重新部署前端后，检查备案号是否正确显示
   # 5. 点击备案号，检查是否跳转到配置的链接
   # 6. 检查版权年份是否已更新为"2024-2026 XM."
   ```

5. **检查日志**：
   ```bash
   # 查看调度层日志
   sudo journalctl -u mail-dispatcher -n 100 --no-pager
   
   # 查看Apache日志
   sudo tail -50 /var/log/httpd/error_log
   ```

### 📝 版本历史

**V4.5.1** (2026-01-20)：
- ICP备案号功能（全页面备案号显示、备案号配置管理、公开API接口）
- 版权信息更新（版权年份从2024-2025更新为2024-2026）

**V4.5.0** (2026-01-20)：
- 文档格式支持扩展（添加MD文档支持、完善PDF支持）
- 大附件传输算法优化（Express body大小限制提升到100MB、附件大小验证机制、动态超时时间调整）
- 答复邮件进度显示（进度条和时间显示、用户体验优化）
- 错误处理优化（友好的错误提示、详细的错误信息）

## 🎉 历史版本 - V4.5.0 (2026-01-20) - 附件功能增强与大文件传输优化

### 🎊 版本亮点

**V4.5.0 是一个附件功能增强和大文件传输优化版本，扩展了文档格式支持，优化了大附件传输算法，添加了答复邮件进度显示机制，并优化了错误处理，大幅提升了邮件系统的附件处理能力和用户体验。**

#### 📄 文档格式支持扩展

**PDF和MD文档支持**：
- **格式支持**：
  - 添加Markdown（`.md`）文档格式支持
  - 完善PDF文档支持（之前已支持，本次优化）
  - 支持的文件格式：PDF, MD, DOC, DOCX, TXT, 图片（JPG, JPEG, PNG, GIF）, 压缩包（ZIP, RAR）
- **功能实现**：
  - 发送邮件和答复邮件都支持这些格式
  - 文件大小限制：单文件最大10MB，总大小不超过50MB
  - 前端文件选择器更新，支持MD格式

#### 🚀 大附件传输算法优化

**Express body大小限制提升**：
- **限制提升**：
  - 从10MB提升到100MB，支持大附件传输
  - Base64编码后数据量增加约33%，50MB附件约66MB，设置为100MB确保安全
  - 避免请求体过大导致的413错误

**附件大小验证机制**：
- **验证逻辑**：
  - 单文件限制：10MB（原始大小）
  - 总大小限制：50MB（原始大小）
  - 自动计算Base64编码后的实际大小（`fileSize = att.content.length * 0.75`）
  - 返回详细的错误信息，包括超限文件列表和大小
- **错误处理**：
  - 前端和后端双重验证
  - 友好的错误提示，显示超限文件名称和大小
  - 提供明确的解决建议（如分批发送）

**动态超时时间调整**：
- **超时策略**：
  - 根据附件大小动态调整超时时间（1分钟-10分钟）
  - 大于30MB：10分钟
  - 大于20MB：8分钟
  - 大于10MB：6分钟
  - 大于5MB：4分钟
  - 大于1MB：3分钟
  - 大于500KB：2分钟
  - 其他：1分钟
- **实现位置**：
  - 后端：`backend/dispatcher/server.js`中的`/api/mail/send`端点
  - 根据附件总大小计算超时时间

#### 📊 答复邮件进度显示

**进度条和时间显示**：
- **进度显示**：
  - 答复邮件添加与发送邮件相同的进度显示机制
  - 实时显示发送进度（0-100%）
  - 显示已用时间和预计剩余时间
  - 根据附件大小智能估算预计时间
- **UI组件**：
  - 进度条：蓝色渐变，平滑动画
  - 时间信息：已用时间、预计剩余时间、总预计时间
  - 附件提示：显示附件数量和大文件提示

**用户体验优化**：
- **交互优化**：
  - 发送过程中禁用取消和发送按钮
  - 实时显示附件数量和大文件提示
  - 错误处理中也会清理定时器，防止内存泄漏
- **状态管理**：
  - 新增响应式变量：`replyProgress`, `replyIsLargeFile`, `replyEstimatedTime`, `replyElapsedTime`, `replyStartTime`
  - 定时器管理：进度更新定时器和时间更新定时器
  - 发送完成后延迟重置进度，让用户看到100%完成状态

#### 🛡️ 错误处理优化

**友好的错误提示**：
- **错误类型**：
  - 附件大小超限错误：显示超限文件列表和具体大小
  - 网络错误：显示网络连接失败提示
  - 请求体过大错误（413）：显示附件总大小和解决建议
- **错误信息**：
  - 详细的错误描述
  - 超限文件名称和大小
  - 当前总大小和限制大小
  - 明确的解决建议（如删除部分附件或分批发送）

### 📋 主要更新内容

#### 📄 文档格式支持扩展

**1. `frontend/src/modules/Mail.vue`**：
- **文件选择器更新**：
  - 发送邮件附件上传：`accept=".pdf,.md,.doc,.docx,.txt,.jpg,.jpeg,.png,.gif,.zip,.rar"`
  - 答复邮件附件上传：`accept=".pdf,.md,.doc,.docx,.txt,.jpg,.jpeg,.png,.gif,.zip,.rar"`
  - 提示文本更新：从"支持 PDF, DOC, TXT, 图片, 压缩包等格式"改为"支持 PDF, MD, DOC, TXT, 图片, 压缩包等格式"

#### 🚀 大附件传输算法优化

**1. `backend/dispatcher/server.js`**：
- **Express body大小限制**：
  - `app.use(express.json({ limit: '100mb' }))`
  - `app.use(express.urlencoded({ extended: true, limit: '100mb' }))`
- **附件大小验证**：
  - 在`/api/mail/send`端点中添加验证逻辑
  - 计算Base64编码后的实际大小
  - 检查单文件大小和总大小限制
  - 返回详细的错误信息
- **动态超时时间**：
  - 根据附件总大小动态调整超时时间
  - 支持大附件传输（最长10分钟）

**2. `frontend/src/modules/Mail.vue`**：
- **错误处理优化**：
  - 发送邮件和答复邮件都添加了详细的错误处理
  - 针对附件大小超限错误提供友好提示
  - 处理网络错误和请求体过大错误（413）

#### 📊 答复邮件进度显示

**1. `frontend/src/modules/Mail.vue`**：
- **响应式变量**：
  - `replyProgress`：答复邮件发送进度（0-100）
  - `replyIsLargeFile`：是否为大文件
  - `replyEstimatedTime`：预计剩余时间（秒）
  - `replyElapsedTime`：已用时间（秒）
  - `replyStartTime`：开始时间戳
- **进度更新逻辑**：
  - 根据附件总大小（包括原始附件和新附件）计算预计时间
  - 根据文件大小调整进度更新速度
  - 大文件：进度步长5%，更新间隔500ms
  - 小文件：进度步长15%，更新间隔200ms
- **UI组件**：
  - 在答复对话框底部添加进度条
  - 显示进度百分比、已用时间、预计剩余时间
  - 显示附件数量和大文件提示
- **定时器管理**：
  - 在成功、失败和异常情况下正确清理定时器
  - 防止内存泄漏

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重启服务**：
   ```bash
   # 重启Node.js调度层服务
   sudo systemctl restart mail-dispatcher
   
   # 重新构建前端
   cd frontend
   npm run build
   
   # 重启Apache服务
   sudo systemctl restart httpd
   ```

3. **验证功能**：
   ```bash
   # 测试大附件发送功能
   # 1. 登录系统
   # 2. 发送一封包含大附件的邮件（接近50MB）
   # 3. 检查是否显示进度条和时间信息
   # 4. 检查是否成功发送
   # 5. 测试答复邮件，添加大附件
   # 6. 检查答复邮件是否也显示进度条
   # 7. 测试MD和PDF文档上传
   # 8. 测试附件大小超限时的错误提示
   ```

4. **检查日志**：
   ```bash
   # 查看邮件操作日志
   tail -50 /var/log/mail-ops/mail-operations.log
   
   # 查看数据库日志
   tail -50 /var/log/mail-ops/mail-db.log
   
   # 查看调度层日志
   sudo journalctl -u mail-dispatcher -n 100 --no-pager
   ```

### 📝 版本历史

**V4.5.0** (2026-01-20)：
- 文档格式支持扩展（添加MD文档支持、完善PDF支持）
- 大附件传输算法优化（Express body大小限制提升到100MB、附件大小验证机制、动态超时时间调整）
- 答复邮件进度显示（进度条和时间显示、用户体验优化）
- 错误处理优化（友好的错误提示、详细的错误信息）

**V4.4.1** (2026-01-19)：

### 🎊 版本亮点

**V4.4.1 是一个答复邮件UI优化和附件功能增强版本，全面优化了邮件正文显示逻辑，实现了多引用原文独立显示，添加了收件人和抄送人的颜色区分，完善了答复邮件的附件功能，并优化了加载状态提示，大幅提升了邮件系统的用户体验和可读性。**

#### ✨ 邮件正文分离显示

**多引用原文独立显示**：
- **解析逻辑**：
  - 解析邮件正文，分离用户输入和多个引用原文（以"--- 原始邮件 ---"分隔）
  - 支持多个引用原文，每个独立显示为一个区域
  - 从每个引用原文中提取发件人、收件人、抄送、时间、主题、正文等信息
- **用户输入区域**：
  - 独立显示用户输入的内容（蓝色渐变背景）
  - 标注"您的回复"，突出显示
  - 只显示用户新添加的内容
- **引用原文区域**：
  - 每个引用原文独立显示为一个区域（灰色渐变背景）
  - 标题显示"原始邮件 #N"（N为序号）
  - 显示完整的原始邮件信息（发件人、收件人、抄送、主题、时间）
  - 原始邮件正文可滚动查看（最大高度限制）

#### 🎨 收件人和抄送人颜色区分

**颜色标签区分**：
- **发件人**：
  - 紫色标签（`text-purple-700 bg-purple-50 border-purple-200`）
  - 在原始邮件信息卡片中显示
- **收件人**：
  - 蓝色标签（`text-blue-700 bg-blue-50 border-blue-200`）
  - 在邮件详情和原始邮件信息中显示
- **抄送**：
  - 绿色标签（`text-green-700 bg-green-50 border-green-200`）
  - 在邮件详情和原始邮件信息中显示
- **显示效果**：
  - 每个地址独立显示为标签
  - 便于快速识别和区分
  - 响应式设计，适配移动端和桌面端

#### 📎 答复邮件附件功能

**附件功能完善**：
- **原始附件保留**：
  - 自动保留原始邮件的所有附件
  - 只读显示，标注"原始"标签
  - 显示发件人来源（"来自: xxx@xxx.com"）
  - 灰色样式，不可删除
- **新附件添加**：
  - 支持上传多个新附件
  - 蓝色/紫色样式，可删除
  - 文件大小和格式限制（单文件10MB，总大小50MB）
- **发送逻辑**：
  - 发送时包含所有附件（原始+新）
  - 原始附件直接使用已有的Base64内容
  - 新附件转换为Base64格式
  - 防止重复添加相同文件

#### 🔄 加载状态优化

**智能加载提示**：
- **邮件内容为空**：
  - 显示"邮件内容为空"
  - 显示邮件ID和调试信息
- **内容加载完成**：
  - 当有内容但解析后没有分离的内容时显示
  - 显示"内容加载完成"（绿色对勾图标）
  - 提示"已显示所有邮件内容"
- **正在加载**：
  - 仅在`selectedEmail`为`null`时显示
  - 显示"邮件内容加载中..."（带旋转动画）

### 📋 主要更新内容

#### ✨ 邮件正文分离显示

**1. `frontend/src/modules/Mail.vue`**：
- **解析函数**：
  - `parseEmailContent()`：解析邮件正文，分离用户输入和多个引用原文
  - 支持多个"--- 原始邮件 ---"分隔符
  - 从每个引用原文中提取发件人、收件人、抄送、时间、主题、正文
- **计算属性**：
  - `parsedEmailContent`：解析当前选中邮件的正文
  - 返回用户输入内容和引用原文数组
- **显示逻辑**：
  - 用户输入内容独立显示（蓝色区域）
  - 每个引用原文独立显示（灰色区域）
  - 如果没有解析到内容，显示原始body

#### 🎨 收件人和抄送人颜色区分

**1. `frontend/src/modules/Mail.vue`**：
- **邮件详情显示**：
  - 收件人：蓝色标签
  - 抄送：绿色标签
  - 发件人：普通文本（带系统通知/管理员标签）
- **原始邮件信息显示**：
  - 发件人：紫色标签
  - 收件人：蓝色标签
  - 抄送：绿色标签
  - 每个地址独立显示为标签

#### 📎 答复邮件附件功能

**1. `frontend/src/modules/Mail.vue`**：
- **状态变量**：
  - `replyAttachments`：新附件列表
  - `replyOriginalAttachments`：原始附件列表（包含发件人信息）
  - `replyFileInput`：文件输入引用
- **附件处理函数**：
  - `handleReplyFileSelect()`：处理文件选择
  - `removeReplyAttachment()`：删除新附件
  - 检查文件大小、重复文件、总大小限制
- **发送逻辑**：
  - 合并原始附件和新附件
  - 原始附件直接使用，新附件转换为Base64
  - 发送时包含所有附件

#### 🔄 加载状态优化

**1. `frontend/src/modules/Mail.vue`**：
- **加载状态判断**：
  - 邮件内容为空：`selectedEmail`存在但body和html都为空
  - 内容加载完成：有body但解析后没有分离的内容
  - 正在加载：`selectedEmail`为`null`
- **UI显示**：
  - 空内容：显示"邮件内容为空"
  - 加载完成：显示"内容加载完成"（绿色对勾）
  - 加载中：显示"邮件内容加载中..."（旋转动画）

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重启前端服务**：
   ```bash
   # 如果使用开发模式，重新构建前端
   cd frontend
   npm run build
   
   # 或者重启Apache服务
   sudo systemctl restart httpd
   ```

3. **验证功能**：
   ```bash
   # 测试答复邮件功能
   # 1. 登录系统
   # 2. 打开一封邮件
   # 3. 检查邮件正文是否分离显示（用户输入和引用原文）
   # 4. 检查收件人和抄送人是否用颜色区分
   # 5. 点击"答复"按钮
   # 6. 检查原始附件是否显示发件人来源
   # 7. 添加新附件
   # 8. 发送答复邮件
   # 9. 检查邮件详情是否正确显示
   ```

4. **检查日志**：
   ```bash
   # 查看邮件操作日志
   tail -50 /var/log/mail-ops/mail-operations.log
   
   # 查看数据库日志
   tail -50 /var/log/mail-ops/mail-db.log
   ```

### 📝 版本历史

**V4.4.1** (2026-01-19)：
- 邮件正文分离显示（多引用原文独立显示、用户输入独立显示）
- 收件人和抄送人颜色区分（发件人紫色、收件人蓝色、抄送绿色）
- 答复邮件附件功能（保留原始附件并标注来源、支持添加新附件）
- 加载状态优化（智能加载提示）

**V4.4.0** (2026-01-19)：

### 🎊 版本亮点

**V4.4.0 是一个答复邮件功能完善和问题修复版本，全面增强了答复邮件功能，修复了邮件显示问题，优化了垃圾邮件检测逻辑，并添加了数据库修复工具，大幅提升了邮件系统的稳定性和用户体验。**

#### ✉️ 答复邮件功能完善

**答复功能增强**：
- **答复按钮下拉菜单**：
  - 添加"单独答复"和"全部答复"选项
  - 下拉菜单UI优化（悬停显示、箭头旋转动画）
  - 智能收件人处理（单独答复仅对原发件人，全部答复包含所有收件人和抄送人）
- **答复对话框UI优化**：
  - 用户输入区域与引用原文分离（用户只能编辑自己的回复内容）
  - 引用原文只读显示（不允许编辑，明确标注"只读，不可编辑"）
  - 引用原文自动附加到邮件末尾（发送时合并）
  - 引用原文折叠/展开功能（默认折叠，可展开查看完整内容）
  - 显示原始邮件信息（发件人、时间、主题）
- **智能处理**：
  - 自动添加"Re:"前缀（如果主题还没有）
  - 排除自己避免自回复
  - 日期格式化（今天、昨天、X天前）

#### 🐛 邮件显示问题修复

**邮件详情显示修复**：
- **JSON解析失败修复**：
  - 使用临时文件传递JSON，避免heredoc中的换行符问题
  - Python从文件读取JSON，而不是通过heredoc传递
  - 添加JSON解析错误处理和修复逻辑
- **body字段为空修复**：
  - 修复临时文件共享导致的文件路径被存储问题
  - 为每个存储操作创建独立临时文件（收件箱、抄送、已发送、垃圾邮箱）
  - 确保每个存储操作都有独立的临时文件，不会相互影响
- **邮件详情API修复**：
  - 支持JSON数组和对象格式
  - 增强错误处理和调试日志
  - 确保body和html字段始终存在（即使为空字符串）

#### 🗑️ 垃圾邮件检测优化

**答复邮件垃圾邮件检测优化**：
- **答复邮件识别**：
  - 检测Subject是否以"Re:"或"RE:"开头
  - 答复邮件跳过所有内容规则检查
- **保留的检查项**：
  - 关键词检测（所有邮件都检查）
  - 域名黑名单检测（所有邮件都检查）
- **优化效果**：
  - 答复邮件不会被内容规则误判为垃圾邮件
  - 提升答复邮件的用户体验
  - 仍会检查关键词和域名黑名单，确保安全性

#### 🔧 数据库修复工具

**旧邮件修复功能**：
- **fix-file-paths命令**：
  - 查找所有body或html_body字段包含文件路径的邮件
  - 尝试从相同message_id的其他邮件副本中恢复正确的body内容
  - 如果找不到正确的body，将文件路径替换为空字符串
- **修复逻辑**：
  - 提取base_message_id（去掉后缀如_inbox、_sent等）
  - 从相同base_message_id的其他邮件中查找正确的body
  - 批量修复所有受影响的邮件

### 📋 主要更新内容

#### ✉️ 答复邮件功能

**1. `frontend/src/modules/Mail.vue`**：
- **答复按钮下拉菜单**：
  - 添加`.reply-button-group`和`.reply-dropdown`样式
  - 悬停显示下拉菜单
  - "单独答复"和"全部答复"选项
- **答复对话框UI**：
  - 用户输入区域（可编辑的textarea）
  - 引用原文区域（只读显示，可折叠/展开）
  - 引用原文自动附加到邮件末尾
- **答复逻辑**：
  - `openReplyDialog(replyAll: boolean)`函数
  - 智能收件人处理（排除自己）
  - 自动添加"Re:"前缀
  - 引用原文格式化（显示发件人、时间、主题）

#### 🐛 邮件显示修复

**1. `backend/dispatcher/server.js`**：
- **临时文件管理**：
  - 为每个存储操作创建独立的临时文件
  - 收件箱：`body_inbox`、`html_inbox`
  - 抄送：`body_cc_${index}`、`html_cc_${index}`
  - 已发送：`body_sent`、`html_sent`
  - 垃圾邮箱：`body_spam_sent`、`html_spam_sent`
- **邮件详情API**：
  - 支持JSON数组和对象格式
  - 增强错误处理和调试日志
  - 确保body和html字段始终存在

**2. `backend/scripts/mail_db.sh`**：
- **JSON解析修复**：
  - 使用临时文件传递JSON，避免heredoc中的换行符问题
  - Python从文件读取JSON
  - 添加JSON解析错误处理
- **修复函数**：
  - `fix_file_path_emails()`函数
  - 修复数据库中存储了文件路径的旧邮件
  - 从相同邮件的其他副本中恢复正确的body内容

#### 🗑️ 垃圾邮件检测优化

**1. `backend/dispatcher/server.js`**：
- **答复邮件识别**：
  - 检测Subject是否以"Re:"或"RE:"开头
  - 答复邮件跳过内容规则检查
- **检查逻辑优化**：
  - 答复邮件仅检查关键词和域名黑名单
  - 普通邮件检查所有规则

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重启服务**：
   ```bash
   # 重启dispatcher服务
   sudo systemctl restart mail-dispatcher
   # 或者
   pkill -f "node.*server\.js"
   ```

3. **修复旧邮件（可选）**：
   ```bash
   # 修复数据库中存储了文件路径的旧邮件
   bash backend/scripts/mail_db.sh fix-file-paths
   ```

4. **验证功能**：
   ```bash
   # 测试答复邮件功能
   # 1. 登录系统
   # 2. 打开一封邮件
   # 3. 点击"答复"按钮
   # 4. 检查答复对话框是否正常显示
   # 5. 发送答复邮件
   # 6. 检查邮件详情是否正确显示
   ```

5. **检查日志**：
   ```bash
   # 查看邮件操作日志
   tail -50 /var/log/mail-ops/mail-operations.log
   
   # 查看数据库日志
   tail -50 /var/log/mail-ops/mail-db.log
   ```

### 📝 版本历史

**V4.4.0** (2026-01-19)：
- 答复邮件功能完善（答复按钮下拉菜单、答复对话框UI优化、引用原文只读显示）
- 邮件显示问题修复（JSON解析失败修复、body字段为空修复、临时文件共享问题修复）
- 垃圾邮件检测优化（答复邮件默认不标记为垃圾邮件、仅检查关键词）
- 数据库修复工具（添加fix-file-paths命令修复旧邮件）

**V4.3.3** (2026-01-16)：

### 🎊 版本亮点

**V4.3.3 是一个文档完善和脚本注释更新版本，全面更新了README.md文档内容，确保文档与实际项目状态一致，并更新了所有脚本的开头注释，提升了文档的可读性和可维护性。**

#### 📝 文档全面更新

**README.md完善**：
- **功能描述**：
  - 更新系统架构说明，确保与实际项目结构一致
  - 更新技术栈版本信息（Vue 3.4.38、Chart.js 4.4.0、xterm.js 5.5.0等）
  - 更新目录结构说明，包含所有新增文件和组件
  - 更新功能特性说明，包含验证码保护、Web终端、数据可视化等新功能
  - 更新端口配置说明，明确从`config/port-config.json`读取
  - 更新密码配置说明，明确从`/etc/mail-ops/xm-admin.pass`读取
  - 删除冗余内容，精简文档结构
- **更新内容**：
  - **系统架构**：更新架构图中的端口说明，明确端口从配置文件读取
  - **技术栈**：更新前端、代理层、调度层的技术栈版本和功能说明
  - **目录结构**：添加新增的组件和文件（Terminal.vue、Changelog.vue、Landing.vue、activityTracker.ts、port-config.json）
  - **功能特性**：添加验证码保护、Web终端、数据可视化、活动追踪等功能说明
  - **命令参考**：添加后台运行命令（`start -d`）说明
  - **文档精简**：删除日志系统、监控与维护、故障排除、生产环境部署、开发与扩展等冗余章节

#### 🔧 脚本注释更新

**脚本注释统一更新**：
- **功能描述**：
  - 更新`backend/scripts/`目录下所有脚本的开头注释
  - 确保注释内容与实际脚本功能一致
  - 统一注释格式和风格
- **更新范围**：
  - 19个Bash脚本的开头注释全部更新
  - 确保注释准确反映脚本的实际功能
  - 统一注释格式，提升可读性

### 📋 主要更新内容

#### 📝 文档更新

**1. `README.md`**：
- **系统架构更新**：
  - 更新架构图中的端口说明
  - 添加端口配置来源说明
- **技术栈更新**：
  - 更新前端技术栈版本（Vue 3.4.38、Chart.js 4.4.0、xterm.js 5.5.0）
  - 更新代理层说明（WebSocket代理、动态端口配置）
  - 更新调度层说明（WebSocket服务器、验证码功能、密码管理）
- **目录结构更新**：
  - 添加新增组件和文件说明
  - 更新页面数量（10个页面）
- **功能特性更新**：
  - 添加验证码保护功能说明
  - 添加Web终端功能说明
  - 添加数据可视化功能说明
  - 添加活动追踪功能说明
- **文档精简**：
  - 删除日志系统详细说明（前面已有命令参考）
  - 删除监控与维护章节（内容简单且重复）
  - 删除故障排除详细章节（前面已有命令参考）
  - 删除生产环境部署章节（内容简单）
  - 删除开发与扩展章节（不是用户关心的）
  - 删除版本历史详细说明（UPDATE_GUIDE.md已有）

#### 🔧 脚本注释更新

**1. `backend/scripts/`目录下所有脚本**：
- **注释格式统一**：
  - 统一脚本开头注释格式
  - 确保注释内容准确反映脚本功能
  - 更新脚本功能描述

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **验证文档更新**：
   ```bash
   # 查看README.md更新内容
   head -30 README.md
   
   # 查看UPDATE_GUIDE.md更新内容
   head -30 UPDATE_GUIDE.md
   ```

3. **验证脚本注释**：
   ```bash
   # 查看脚本注释更新
   head -20 backend/scripts/*.sh
   ```

### ⚠️ 注意事项

1. **文档更新**：
   - 文档更新不影响系统功能
   - 建议阅读最新文档了解系统功能
   - 如有疑问，请参考UPDATE_GUIDE.md获取详细说明

2. **脚本注释**：
   - 脚本注释更新不影响脚本执行
   - 注释仅用于说明脚本功能
   - 脚本功能保持不变

### 🔧 故障排除

**如果文档内容与实际不符**：
- 检查文档版本是否为最新版本
- 参考UPDATE_GUIDE.md获取详细说明
- 如有问题，请提交Issue反馈

### 📝 版本历史

**V4.3.3** (2026-01-16)：
- 文档全面更新
- 脚本注释更新

**V4.3.2** (2026-01-16)：

### 🎊 版本亮点

**V4.3.2 是一个验证码验证逻辑修复版本，修复了验证码答案为0时无法通过验证的bug，优化了验证逻辑，提升了用户体验。**

#### 🔢 验证码答案为0的bug修复

**问题修复**：
- **功能描述**：
  - 修复验证码答案为0时无法通过验证的问题
  - 原逻辑使用 `!captchaAnswer.value` 判断，导致0被误判为空值
  - 更新为明确检查 `null`、`undefined` 和空字符串，确保0可以正常验证
- **问题原因**：
  - JavaScript中，`!0` 返回 `true`，导致验证码答案为0时被误判为空值
  - 原验证逻辑：`if (!captchaId.value || !captchaAnswer.value)`
  - 当 `captchaAnswer.value = 0` 时，`!0` 为 `true`，导致验证失败
- **修复方案**：
  - 更新验证逻辑为：`if (!captchaId.value || captchaAnswer.value == null || captchaAnswer.value === '')`
  - 明确检查 `null`、`undefined`（使用 `== null`）和空字符串
  - 确保数字0可以正常通过验证
- **修复效果**：
  - 验证码答案为0时可以正常通过验证
  - 空值检查更加严格和准确
  - 提升用户体验，避免误报错误

#### 📝 验证逻辑优化

**修复范围**：
- **登录页面（Login.vue）**：
  - 修复验证码验证逻辑
  - 确保答案为0时可以正常验证
- **注册页面（Register.vue）**：
  - 修复验证码验证逻辑
  - 确保答案为0时可以正常验证
- **重置密码页面（Reset.vue）**：
  - 修复验证码验证逻辑
  - 确保答案为0时可以正常验证

**修复统计**：
- 修复的文件数量：3个
- 修复的验证逻辑位置：3处
- 修复的bug类型：falsy值误判问题

### 📋 主要更新内容

#### 🔢 前端验证逻辑更新

**1. `frontend/src/modules/Login.vue`**：
- **验证码验证逻辑修复**：
  - 修复前：`if (!captchaId.value || !captchaAnswer.value)`
  - 修复后：`if (!captchaId.value || captchaAnswer.value == null || captchaAnswer.value === '')`
  - 确保答案为0时可以正常验证

**2. `frontend/src/modules/Register.vue`**：
- **验证码验证逻辑修复**：
  - 修复前：`if (!captchaId.value || !captchaAnswer.value)`
  - 修复后：`if (!captchaId.value || captchaAnswer.value == null || captchaAnswer.value === '')`
  - 确保答案为0时可以正常验证

**3. `frontend/src/modules/Reset.vue`**：
- **验证码验证逻辑修复**：
  - 修复前：`if (!captchaId.value || !captchaAnswer.value)`
  - 修复后：`if (!captchaId.value || captchaAnswer.value == null || captchaAnswer.value === '')`
  - 确保答案为0时可以正常验证

### 🚀 升级步骤

1. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重新构建前端**（如果需要）：
   ```bash
   # 进入前端目录
   cd frontend
   
   # 安装依赖（如果需要）
   npm install
   
   # 构建前端
   npm run build
   ```

3. **验证修复**：
   ```bash
   # 访问登录页面，测试验证码答案为0的情况
   # 应该可以正常通过验证
   ```

### ⚠️ 注意事项

1. **验证码验证**：
   - 验证码答案为0时可以正常通过验证
   - 空值检查更加严格和准确
   - 如果仍有问题，检查浏览器控制台错误信息

2. **向后兼容**：
   - 修复不影响其他验证码答案的验证
   - 所有验证码答案（包括0）都可以正常验证

### 🔧 故障排除

**如果验证码答案为0时仍然无法通过验证**：
- 检查浏览器控制台是否有JavaScript错误
- 检查前端代码是否已更新
- 清除浏览器缓存后重试
- 检查验证码输入框的值是否正确传递

**如果其他验证码答案也无法通过验证**：
- 检查后端验证逻辑是否正确
- 检查验证码是否过期
- 刷新验证码后重试

### 📝 版本历史

**V4.3.2** (2026-01-16)：
- 验证码答案为0的bug修复
- 验证逻辑优化（登录/注册/重置密码页面）

**V4.3.1** (2026-01-16)：

### 🎊 版本亮点

**V4.3.1 是一个Apache配置优化和前端图表错误修复版本，修复了Apache端口监听配置问题，优化了HTTPS虚拟主机配置逻辑，修复了Chart.js图表渲染错误，并优化了服务启动流程，提升了系统的稳定性和用户体验。**

#### 🌐 Apache端口监听自动配置

**Listen指令自动添加**：
- **功能描述**：
  - 部署时自动检测Apache主配置文件中的 `Listen` 指令
  - 如果配置的端口没有 `Listen` 指令，自动添加
  - 支持自定义HTTP和HTTPS端口，自动配置监听
  - 避免端口配置后Apache无法监听的问题
- **实现逻辑**：
  - `start.sh` 部署Apache配置时检查 `Listen` 指令
  - 如果HTTP端口没有 `Listen` 指令，自动添加到主配置文件
  - 如果HTTPS端口不是443且检测到SSL证书，自动添加 `Listen ${APACHE_HTTPS_PORT} https`
  - 使用行号精确添加，避免重复
- **修复的问题**：
  - 修复了自定义端口配置后Apache无法监听的问题
  - 修复了虚拟主机配置存在但端口未监听的问题
  - 确保端口配置和监听配置一致

#### 🔒 HTTPS虚拟主机智能配置

**SSL证书检测**：
- **功能描述**：
  - 仅在检测到SSL证书时才添加HTTPS虚拟主机配置
  - 自动检测常见证书路径（/etc/pki/tls/certs、/etc/pki/tls、/etc/ssl/certs）
  - 检查对应的私钥文件是否存在
  - 未配置证书时仅部署HTTP配置，避免配置错误
- **实现逻辑**：
  - `start.sh` 部署Apache配置时检测SSL证书
  - 检查证书文件和私钥文件是否都存在
  - 如果找到证书，动态添加HTTPS虚拟主机配置到 `mailmgmt.conf`
  - 如果未找到证书，跳过HTTPS配置
- **修复的问题**：
  - 修复了未配置证书时HTTPS虚拟主机配置错误的问题
  - 避免了Apache配置语法错误
  - 提升了配置的灵活性和正确性

#### 📊 前端图表错误修复

**Chart.js Canvas上下文检查**：
- **功能描述**：
  - 修复 `Cannot read properties of null (reading 'save')` 错误
  - 添加Canvas元素和上下文完整性检查
  - 确保图表在DOM完全渲染后才创建
  - 避免在Canvas元素未准备好时创建图表
- **实现逻辑**：
  - 创建图表前检查Canvas元素是否存在
  - 检查Canvas元素是否在DOM中
  - 检查Canvas上下文是否可用
  - 如果检查失败，延迟500ms后重试
- **修复的问题**：
  - 修复了Chart.js图表渲染错误
  - 修复了Canvas上下文为null的问题
  - 提升了图表渲染的稳定性

#### 🚀 服务启动优化

**残留进程清理**：
- **功能描述**：
  - 服务启动前自动清理残留的node进程
  - 确保只有一个服务实例运行
  - 修复多端口监听问题
- **实现逻辑**：
  - `start.sh` 部署和重启服务时清理残留进程
  - 使用 `pkill -f "node.*server\.js"` 清理残留进程
  - 在 `restart-dispatcher` 和 `fix-dispatcher` 命令中也添加清理逻辑
- **修复的问题**：
  - 修复了多个服务实例同时运行的问题
  - 修复了端口被多个进程占用的问题
  - 提升了服务启动的可靠性

### 📋 主要更新内容

#### 🌐 Apache配置更新

**1. `start.sh`**：
- **Listen指令自动添加**：
  - 检查HTTP端口是否有 `Listen` 指令
  - 如果没有，自动添加到主配置文件
  - 检查HTTPS端口是否有 `Listen` 指令（仅在检测到SSL证书时）
  - 使用行号精确添加，避免重复
- **HTTPS虚拟主机智能配置**：
  - 检测SSL证书是否存在
  - 如果找到证书，动态添加HTTPS虚拟主机配置
  - 如果未找到证书，跳过HTTPS配置

**2. `backend/apache/httpd-vhost.conf`**：
- **移除HTTPS配置模板**：
  - 从模板文件中移除HTTPS虚拟主机配置
  - HTTPS配置仅在检测到SSL证书时动态添加

#### 📊 前端更新

**1. `frontend/src/modules/Dashboard.vue`**：
- **Chart.js错误修复**：
  - 添加Canvas元素存在性检查
  - 添加Canvas元素DOM检查
  - 添加Canvas上下文可用性检查
  - 检查失败时延迟重试

#### 🚀 服务启动优化

**1. `start.sh`**：
- **残留进程清理**：
  - 服务部署时清理残留进程
  - `restart-dispatcher` 命令添加清理逻辑
  - `fix-dispatcher` 命令添加清理逻辑

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   # 备份Apache配置
   cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.backup
   cp /etc/httpd/conf.d/mailmgmt.conf /etc/httpd/conf.d/mailmgmt.conf.backup 2>/dev/null || true
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

3. **重新部署Apache配置**：
   ```bash
   # 重新部署（会自动检测并添加Listen指令和HTTPS配置）
   ./start.sh fix-auth
   ```

4. **验证配置**：
   ```bash
   # 检查Listen指令
   grep -E "^Listen" /etc/httpd/conf/httpd.conf
   
   # 检查虚拟主机配置
   grep -E "VirtualHost" /etc/httpd/conf.d/mailmgmt.conf
   
   # 检查端口监听
   netstat -tlnp | grep -E ":(80|443|8081)"
   ```

5. **重启服务**：
   ```bash
   # 重启Apache服务
   systemctl restart httpd
   
   # 重启调度层服务（清理残留进程）
   ./start.sh restart-dispatcher
   ```

### ⚠️ 注意事项

1. **Apache配置**：
   - 重新部署后会自动添加 `Listen` 指令
   - 如果配置了自定义端口，确保防火墙规则允许
   - HTTPS配置仅在检测到SSL证书时添加

2. **SSL证书**：
   - 如果未配置SSL证书，系统仅使用HTTP
   - 配置SSL证书后需要重新部署才能启用HTTPS
   - 证书路径支持：/etc/pki/tls/certs、/etc/pki/tls、/etc/ssl/certs

3. **前端图表**：
   - 图表渲染错误已修复
   - 如果仍有问题，检查浏览器控制台错误信息
   - 确保Canvas元素在DOM中

### 🔧 故障排除

**如果Apache端口未监听**：
- 检查 `Listen` 指令是否已添加：`grep -E "^Listen" /etc/httpd/conf/httpd.conf`
- 检查端口配置是否正确：`cat config/port-config.json`
- 重新部署：`./start.sh fix-auth`

**如果HTTPS配置未添加**：
- 检查SSL证书是否存在：`ls -la /etc/pki/tls/*.crt /etc/ssl/certs/*.crt`
- 检查私钥文件是否存在：`ls -la /etc/pki/tls/*.key /etc/ssl/private/*.key`
- 重新部署：`./start.sh fix-auth`

**如果图表渲染错误**：
- 检查浏览器控制台错误信息
- 检查Canvas元素是否存在：`document.querySelector('canvas')`
- 刷新页面重试

**如果服务启动失败**：
- 检查残留进程：`ps aux | grep "node.*server\.js"`
- 清理残留进程：`pkill -f "node.*server\.js"`
- 重启服务：`./start.sh restart-dispatcher`

### 📝 版本历史

**V4.3.1** (2026-01-16)：
- Apache端口监听自动配置
- HTTPS虚拟主机智能配置
- 前端图表错误修复
- 服务启动优化

**V4.3.0** (2026-01-15)：

### 🎊 版本亮点

**V4.3.0 是一个端口与密码配置硬编码全面修复版本，创建了统一的端口配置文件，修复了所有脚本和配置文件中的硬编码端口和密码问题，支持完全自定义端口和密码配置，大幅提升了系统的灵活性和安全性。**

#### 🔌 端口配置统一管理

**统一端口配置文件**：
- **功能描述**：
  - 创建 `config/port-config.json` 统一管理所有端口配置
  - API端口（默认8081）、前端开发端口（默认5173）、Apache HTTP/HTTPS端口（默认80/443）全部可自定义
  - 所有脚本和配置文件从统一配置文件读取端口
  - 支持通过修改配置文件自定义所有端口，无需修改代码
- **实现逻辑**：
  - 创建 `config/port-config.json` 配置文件
  - 所有脚本添加 `get_port_config()` 函数读取端口配置
  - `start.sh` 部署时自动读取端口配置并注入到Apache和systemd配置
  - `backend/dispatcher/server.js` 和 `frontend/vite.config.ts` 从配置文件读取端口
- **配置文件结构**：
  ```json
  {
    "api": {
      "port": 8081,
      "description": "后端API服务端口"
    },
    "frontend": {
      "devPort": 5173,
      "description": "前端开发服务器端口（仅开发环境使用）"
    },
    "apache": {
      "httpPort": 80,
      "httpsPort": 443,
      "description": "Apache Web服务器端口（HTTP和HTTPS）"
    }
  }
  ```
- **使用场景**：
  - 端口冲突时自定义端口
  - 多实例部署时使用不同端口
  - 安全策略要求使用非标准端口

#### 📝 密码配置统一管理

**API密码从文件读取**：
- **功能描述**：
  - systemd服务文件中的API密码从 `/etc/mail-ops/xm-admin.pass` 文件读取
  - 移除所有硬编码密码，提升安全性
  - 支持密码动态修改，无需修改代码
- **实现逻辑**：
  - `start.sh` 创建systemd服务文件时从密码文件读取API密码
  - 如果密码文件不存在，使用默认值（向后兼容）
  - 密码自动注入到systemd服务文件的环境变量中
- **密码文件位置**：
  - `/etc/mail-ops/xm-admin.pass`（由start.sh创建和管理）
- **使用场景**：
  - 定期更换密码提升安全性
  - 多环境部署时使用不同密码
  - 符合安全审计要求

#### 🛠️ 脚本全面优化

**端口配置修复**：
- **修复的脚本**：
  - `cert_setup.sh`：VirtualHost、Listen、防火墙规则、端口检查均使用变量
  - `dns_setup.sh`：VirtualHost配置使用变量
  - `mail_setup.sh`：网络检查、端口连通性检查、健康检查均使用变量
  - `security.sh`：防火墙规则支持自定义端口
  - `start.sh`：API检查、端口占用检查、SSL配置均使用变量
  - `backend/dispatcher/server.js`：从配置文件读取端口
  - `frontend/vite.config.ts`：从配置文件读取开发端口
  - `backend/apache/httpd-vhost.conf`：使用占位符，部署时自动替换
- **修复统计**：
  - 修复的脚本/配置文件数量：11个
  - 修复的硬编码端口位置：30+处
  - 修复的硬编码密码位置：2处
  - 添加的端口配置读取函数：5个

**密码配置修复**：
- **修复的文件**：
  - `backend/apache/systemd/mail-ops-dispatcher.service`：添加注释说明API_PASS从文件读取
  - `start.sh`：两处创建systemd服务文件的位置都从密码文件读取

### 📋 主要更新内容

#### 🔌 配置文件更新

**1. `config/port-config.json`（新建）**：
- **端口配置统一管理**：
  - API端口配置（默认8081）
  - 前端开发端口配置（默认5173）
  - Apache HTTP/HTTPS端口配置（默认80/443）
- **配置说明**：
  - 所有端口配置集中在一个文件中
  - 支持自定义所有端口
  - 修改配置文件后需要重新部署生效

#### 🛠️ 脚本更新

**1. `start.sh`**：
- **端口配置读取**：
  - 从 `config/port-config.json` 读取所有端口配置
  - 部署Apache配置时自动替换端口占位符
  - 创建systemd服务文件时注入PORT环境变量
- **密码配置读取**：
  - 从 `/etc/mail-ops/xm-admin.pass` 读取API密码
  - 创建systemd服务文件时注入API_PASS环境变量
  - 如果密码文件不存在，使用默认值（向后兼容）

**2. `backend/scripts/cert_setup.sh`**：
- **端口配置函数**：
  - 添加 `get_port_config()` 函数读取端口配置
  - VirtualHost配置使用 `${APACHE_HTTP_PORT}` 和 `${APACHE_HTTPS_PORT}`
  - Listen指令使用 `${APACHE_HTTPS_PORT}`
  - 防火墙规则使用 `${APACHE_HTTPS_PORT}`
  - 端口检查使用 `${APACHE_HTTPS_PORT}`

**3. `backend/scripts/dns_setup.sh`**：
- **端口配置函数**：
  - 添加 `get_port_config()` 函数读取端口配置
  - VirtualHost配置使用 `${APACHE_HTTP_PORT}` 和 `${APACHE_HTTPS_PORT}`

**4. `backend/scripts/mail_setup.sh`**：
- **端口配置函数**：
  - 添加 `get_port_config()` 函数读取端口配置
  - 网络检查使用动态端口
  - 端口连通性检查使用动态端口
  - 健康检查使用动态端口

**5. `backend/scripts/security.sh`**：
- **端口配置函数**：
  - 添加 `get_port_config()` 函数读取端口配置
  - 防火墙规则支持自定义端口（标准端口使用服务名称，非标准端口使用端口号）

**6. `backend/dispatcher/server.js`**：
- **端口配置读取**：
  - 添加 `getPortConfig()` 函数从配置文件读取端口
  - 环境变量PORT优先级最高

**7. `frontend/vite.config.ts`**：
- **端口配置读取**：
  - 添加 `getPortConfig()` 函数从配置文件读取开发端口

**8. `backend/apache/httpd-vhost.conf`**：
- **端口占位符**：
  - 使用 `${API_PORT}`、`${APACHE_HTTP_PORT}`、`${APACHE_HTTPS_PORT}` 占位符
  - 部署时由start.sh自动替换

**9. `backend/apache/systemd/mail-ops-dispatcher.service`**：
- **密码配置说明**：
  - 添加注释说明API_PASS环境变量会在部署时从文件读取
  - 移除硬编码密码

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   # 备份配置文件
   cp config/port-config.json config/port-config.json.backup 2>/dev/null || true
   cp /etc/mail-ops/xm-admin.pass /etc/mail-ops/xm-admin.pass.backup 2>/dev/null || true
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

3. **创建端口配置文件**（如果不存在）：
   ```bash
   # 检查配置文件是否存在
   if [[ ! -f config/port-config.json ]]; then
     cat > config/port-config.json <<EOF
   {
     "api": {
       "port": 8081,
       "description": "后端API服务端口"
     },
     "frontend": {
       "devPort": 5173,
       "description": "前端开发服务器端口（仅开发环境使用）"
     },
     "apache": {
       "httpPort": 80,
       "httpsPort": 443,
       "description": "Apache Web服务器端口（HTTP和HTTPS）"
     },
     "updatedAt": "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
   }
   EOF
   fi
   ```

4. **重新部署系统**：
   ```bash
   # 重新部署（会自动读取端口配置）
   ./start.sh start
   ```

5. **验证配置**：
   ```bash
   # 检查端口配置
   cat config/port-config.json
   
   # 检查systemd服务配置
   systemctl show mail-ops-dispatcher --property=Environment | grep -E "PORT|API_PASS"
   
   # 检查Apache配置
   grep -E "Listen|VirtualHost" /etc/httpd/conf.d/mailmgmt.conf | head -5
   ```

### ⚠️ 注意事项

1. **端口配置**：
   - 修改端口配置后需要重新部署系统才能生效
   - 确保新端口没有被其他服务占用
   - 修改防火墙规则以允许新端口

2. **密码配置**：
   - API密码文件 `/etc/mail-ops/xm-admin.pass` 权限为640（root:xm）
   - 修改密码后需要重启mail-ops-dispatcher服务
   - 确保密码文件安全，不要泄露

3. **向后兼容**：
   - 如果端口配置文件不存在，使用默认端口（8081、80、443）
   - 如果密码文件不存在，使用默认密码（向后兼容）

### 🔧 故障排除

**如果端口配置不生效**：
- 检查 `config/port-config.json` 文件是否存在且格式正确
- 检查 `jq` 命令是否可用：`command -v jq`
- 重新部署系统：`./start.sh start`

**如果密码配置不生效**：
- 检查 `/etc/mail-ops/xm-admin.pass` 文件是否存在
- 检查文件权限：`ls -l /etc/mail-ops/xm-admin.pass`
- 重启服务：`systemctl restart mail-ops-dispatcher`

**如果服务启动失败**：
- 检查端口是否被占用：`netstat -tlnp | grep -E "8081|80|443"`
- 检查日志：`journalctl -xeu mail-ops-dispatcher --no-pager -l`
- 检查配置：`systemctl show mail-ops-dispatcher --property=Environment`

### 📝 版本历史

**V4.3.0** (2026-01-15)：
- 端口配置统一管理
- 密码配置统一管理
- 脚本全面优化

## 📚 历史版本记录

## 🎉 V4.2.3 (2026-01-15) - 后台运行模式与安装流程优化

### 🎊 版本亮点

**V4.2.3 是一个后台运行模式与安装流程优化版本，新增后台运行模式支持 SSH 断开后继续执行，优化了仓库配置和系统更新的超时保护，添加了进度显示功能，大幅提升了安装流程的稳定性和用户体验。**

#### 🚀 后台运行模式

**SSH 断开保护**：
- **功能描述**：
  - 新增 `./start.sh start -d` 后台运行模式
  - SSH 断开后任务继续执行，避免安装中断
  - 日志输出到 `/var/log/mail-ops/start-daemon.log`
  - PID 文件管理，支持任务状态查询和停止
- **实现逻辑**：
  - 更新 `start.sh`：在主部署流程之前检测 `-d` 参数
  - 使用 `nohup` 在后台运行脚本（去掉 `-d` 参数）
  - 保存进程 PID 到 `/var/log/mail-ops/start-daemon.pid`
  - 检查是否已有后台任务在运行，避免重复启动
  - 输出日志文件位置和查看方法
- **使用场景**：
  - SSH 连接不稳定时执行长时间安装任务
  - 避免因网络断开导致安装中断
  - 方便查看安装进度和日志

#### ⏱️ 超时保护优化

**仓库配置超时**：
- **功能描述**：
  - `yum-config-manager` 添加 60 秒超时保护
  - `update_repos.sh` 脚本添加 10 分钟超时保护
  - `dnf makecache` 和 `dnf install` 添加超时保护
  - 超时后继续执行，不会中断安装流程
- **实现逻辑**：
  - 更新 `backend/scripts/update_repos.sh`：为 `yum-config-manager --add-repo` 添加 60 秒超时
  - 更新 `start.sh`：为 `update_repos.sh` 脚本添加 10 分钟超时保护
  - 为 `dnf makecache`、`dnf install epel-release`、`dnf update` 添加超时保护
  - 移除 `set -e`，允许某些命令失败后继续执行
- **使用场景**：
  - 网络较慢时避免长时间等待
  - 防止命令执行卡住导致安装中断
  - 提升安装流程的稳定性

#### 📊 进度显示优化

**系统更新进度**：
- **功能描述**：
  - 添加每 30 秒进度提示，避免看起来卡住
  - 显示关键操作信息（下载、安装、升级等）
  - 后台运行模式下提示查看日志文件
  - 30 分钟超时保护，确保不会无限等待
- **实现逻辑**：
  - 更新 `start.sh`：添加后台进度提示进程
  - 使用 `grep` 过滤并显示关键进度信息
  - 后台运行模式下提示查看 `DAEMON_LOG`
  - 前台运行模式下提示查看 `INSTALL_LOG`
  - 使用 `timeout` 命令限制 `dnf update` 执行时间（30分钟）
- **使用场景**：
  - 长时间安装时了解当前进度
  - 避免误以为系统卡住
  - 方便查看详细日志

### 📋 主要更新内容

#### 🚀 脚本更新

**1. `start.sh`**：
- **后台运行模式**：
  - 在主部署流程之前检测 `-d` 参数
  - 使用 `nohup` 启动后台任务
  - PID 文件管理和任务状态检查
- **超时保护**：
  - `yum-utils` 安装：5 分钟超时
  - `update_repos.sh` 脚本：10 分钟超时
  - `dnf makecache`：2 分钟超时
  - `dnf install epel-release`：5 分钟超时
  - `dnf update`：30 分钟超时
- **进度显示**：
  - 后台进度提示（每 30 秒）
  - 关键操作信息显示
  - 日志文件查看提示

**2. `backend/scripts/update_repos.sh`**：
- **超时保护**：
  - `yum-config-manager --add-repo`：60 秒超时
  - `dnf makecache`：2 分钟超时（两处）
- **错误处理**：
  - 移除 `set -e`，允许部分失败后继续执行
  - 超时后使用手动创建方式

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **使用后台运行模式（推荐）**：
   ```bash
   # 启动后台运行模式
   ./start.sh start -d
   
   # 查看实时日志
   tail -f /var/log/mail-ops/start-daemon.log
   
   # 检查任务状态
   ps -p $(cat /var/log/mail-ops/start-daemon.pid)
   
   # 停止任务（如需要）
   kill $(cat /var/log/mail-ops/start-daemon.pid)
   ```

4. **或使用正常模式**：
   ```bash
   ./start.sh start
   ```

5. **验证功能**：
   ```bash
   # 检查服务状态
   ./start.sh status
   
   # 运行系统诊断
   ./start.sh check
   ```

### ⚠️ 注意事项

1. **后台运行模式**：
   - 推荐在网络不稳定或需要长时间安装时使用
   - SSH 断开后任务会继续执行
   - 使用 `tail -f` 查看实时日志
   - PID 文件位于 `/var/log/mail-ops/start-daemon.pid`

2. **超时保护**：
   - 超时后脚本会继续执行，不会中断安装
   - 如果看到超时警告，可以查看日志了解详情
   - 某些命令可能因为网络问题超时，但不影响整体安装

3. **进度显示**：
   - 系统更新可能需要较长时间（最多30分钟）
   - 每 30 秒会显示进度提示
   - 关键操作信息会实时显示
   - 后台运行模式下建议使用 `tail -f` 查看日志

### 📝 版本历史

**V4.2.3** (2026-01-15)：
- 后台运行模式
- 超时保护优化
- 进度显示优化

## 🎉 V4.2.2 (2026-01-15) - 系统状态监控性能优化

### 🎊 版本亮点

**V4.2.2 是一个系统状态监控性能优化版本，修复了系统状态监控导致网站服务卡住的问题，通过异步非阻塞优化、并行执行优化和超时保护，大幅提升了系统状态监控的响应速度和系统整体稳定性。**

#### ⚡ 异步非阻塞优化

**API 端点异步化**：
- **功能描述**：
  - 将系统状态监控 API 从同步改为异步执行
  - 避免阻塞 Node.js 事件循环，提升系统响应速度
  - 添加请求级别超时保护（30秒）
- **实现逻辑**：
  - 更新 `backend/dispatcher/server.js`：添加 `execCommandAsync` 辅助函数
  - 将 `/api/system-status` 端点从同步改为异步（`async`）
  - 使用 Promise 包装 `exec`，避免阻塞事件循环
  - 添加请求级别超时定时器（30秒）
- **使用场景**：
  - 系统状态监控页面加载
  - 避免长时间阻塞其他 API 请求
  - 提升系统整体响应速度

#### 🚀 并行执行优化

**命令并行执行**：
- **功能描述**：
  - 服务状态检查改为并行执行，大幅减少总执行时间
  - DNS 查询并行执行，所有 DNS 记录同时查询
  - 系统资源查询优化，提升数据获取效率
- **实现逻辑**：
  - 服务状态检查：使用 `Promise.allSettled` 并行执行所有服务状态检查
  - DNS 查询：并行执行 MX、A、SPF、DKIM、DMARC 记录查询
  - 错误隔离：使用 `Promise.allSettled` 确保单个命令失败不影响其他命令
  - 超时控制：每个命令都有独立的超时限制（2-3秒）
- **使用场景**：
  - 快速获取系统状态信息
  - 减少系统状态监控页面加载时间
  - 提升用户体验

#### 🛡️ 超时与错误处理

**多层超时保护**：
- **功能描述**：
  - 命令执行超时限制（2-3秒）
  - DNS 查询超时优化（从5秒降至3秒）
  - 请求级别超时保护（30秒）
  - 错误隔离机制，单个命令失败不影响其他命令
- **实现逻辑**：
  - `execCommandAsync` 函数内置超时机制
  - DNS 查询超时从 5 秒优化为 3 秒
  - 请求级别超时：30 秒后自动返回超时错误
  - 使用 `Promise.allSettled` 实现错误隔离
- **使用场景**：
  - 防止长时间阻塞
  - 提升系统稳定性
  - 避免单个命令失败影响整体功能

### 📋 主要更新内容

#### ⚡ 后端更新

**1. `backend/dispatcher/server.js`**：
- **异步命令执行函数**：
  - 添加 `execCommandAsync` 辅助函数
  - 支持超时和错误处理
  - 使用 Promise 包装 `exec`
- **API 端点异步化**：
  - `/api/system-status` 端点改为异步
  - 添加请求级别超时保护
  - 优化错误处理逻辑
- **并行执行优化**：
  - 服务状态检查并行执行
  - DNS 查询并行执行
  - 使用 `Promise.allSettled` 实现错误隔离

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重启调度层服务**：
   ```bash
   systemctl restart mail-ops-dispatcher
   ```
   或
   ```bash
   ./start.sh restart
   ```

4. **验证功能**：
   ```bash
   # 检查调度层服务状态
   systemctl status mail-ops-dispatcher
   
   # 访问系统，测试系统状态监控
   # 1. 打开系统状态监控页面
   # 2. 检查加载速度是否提升
   # 3. 确认不会阻塞其他页面
   # 4. 测试超时保护是否生效
   ```

### ⚠️ 注意事项

1. **性能提升**：
   - 系统状态监控加载速度应该明显提升
   - 不会再出现长时间卡顿问题
   - 其他 API 请求不会被阻塞

2. **超时处理**：
   - 如果某个命令执行超时，会返回默认值或错误状态
   - 不会影响其他命令的执行
   - 30 秒请求超时会返回超时错误

3. **错误处理**：
   - 单个命令失败不会影响其他命令
   - 错误信息会记录在日志中
   - 前端会显示部分数据（即使某些命令失败）

### 📝 版本历史

**V4.2.2** (2026-01-15)：
- 异步非阻塞优化
- 并行执行优化
- 超时与错误处理

## 📚 历史版本记录

## 🎉 V4.2.1 (2026-01-15) - 仓库配置修复与系统优化

### 🎊 版本亮点

**V4.2.1 是一个仓库配置修复和系统优化版本，修复了仓库配置不完整的问题，添加了 yum-config-manager 的自动安装，优化了仓库补全逻辑，并为登录、注册、忘记密码页面添加了移动端适配支持。**

#### 🔧 仓库配置问题修复

**yum-config-manager 自动安装**：
- **功能描述**：
  - 自动检测并安装 yum-utils 包，确保 yum-config-manager 命令可用
  - 修复 Docker CE 仓库配置失败问题
  - 提升仓库配置成功率
- **实现逻辑**：
  - 更新 `start.sh`：在执行 `update_repos.sh` 之前检查 yum-config-manager
  - 如果命令不可用，自动安装 yum-utils 包
  - 安装失败时回退到手动配置方式
  - 确保 Docker CE 仓库能够正确配置
- **使用场景**：
  - 系统首次安装时自动配置仓库
  - 修复仓库配置不完整的问题
  - 提升系统安装成功率

#### 📦 仓库补全逻辑优化

**完整仓库配置**：
- **功能描述**：
  - 改进 Docker CE 仓库配置逻辑，支持多种配置方式
  - 添加配置后二次验证，确保所有仓库正确配置
  - 修复仓库补全不完整的问题
  - 优化错误处理和日志输出
- **实现逻辑**：
  - 更新 `backend/scripts/update_repos.sh`：改进 Docker CE 仓库配置逻辑
  - 优先使用 yum-config-manager 添加仓库
  - 如果失败，检查是否已存在，否则手动创建配置文件
  - 更新 `start.sh`：添加配置后的二次验证逻辑
  - 重新检查所有3个仓库（Rocky Linux、Docker CE、Kubernetes）的状态
- **使用场景**：
  - 确保所有仓库都能正确配置
  - 修复仓库补全不完整的问题
  - 提升系统安装的可靠性

#### 🎨 登录注册页面移动端适配

**移动端体验优化**：
- **功能描述**：
  - 登录页面移动端适配（响应式布局、触摸优化）
  - 注册页面移动端适配（表单优化、按钮尺寸）
  - 忘记密码页面移动端适配（布局优化、交互改进）
  - 统一的移动端设计风格
- **实现逻辑**：
  - 更新 `frontend/src/modules/Login.vue`：添加移动端响应式 CSS
  - 更新 `frontend/src/modules/Register.vue`：添加移动端响应式 CSS
  - 更新 `frontend/src/modules/Reset.vue`：添加移动端响应式 CSS
  - 使用媒体查询：`@media (max-width: 768px)` 和 `@media (max-width: 480px)`
  - 优化表单输入框、按钮、验证码区域的移动端布局
  - 确保按钮最小尺寸符合触摸标准（44-48px）
- **使用场景**：
  - 移动设备用户登录和注册
  - 触摸设备交互优化
  - 小屏幕设备显示优化

### 📋 主要更新内容

#### 🔧 后端更新

**1. `start.sh`**：
- **仓库配置优化**：
  - 在执行 `update_repos.sh` 之前检查并安装 yum-utils
  - 添加配置后的二次验证逻辑
  - 重新检查所有仓库状态
  - 优化错误处理和日志输出

**2. `backend/scripts/update_repos.sh`**：
- **Docker CE 仓库配置改进**：
  - 改进配置逻辑，支持多种配置方式
  - 优先使用 yum-config-manager
  - 失败时检查是否已存在
  - 手动创建完整的配置文件

#### 🎨 前端更新

**1. `frontend/src/modules/Login.vue`**：
- **移动端适配**：
  - 卡片 padding 和间距优化
  - Logo 和标题字体大小自适应
  - 表单输入框 padding 和字体大小优化
  - 验证码区域移动端自动换行
  - 按钮最小高度 48px
  - 页脚链接垂直布局

**2. `frontend/src/modules/Register.vue`**：
- **移动端适配**：
  - 与登录页面一致的移动端优化
  - 多字段表单布局优化
  - 页脚链接垂直布局

**3. `frontend/src/modules/Reset.vue`**：
- **移动端适配**：
  - 与登录页面一致的移动端优化
  - 表单布局优化
  - 按钮和输入框触摸友好

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重建前端界面**：
   ```bash
   ./start.sh rebuild
   ```
   脚本会自动：
   - 重新构建前端界面
   - 应用移动端适配样式
   - 更新响应式布局

4. **验证功能**：
   ```bash
   # 检查仓库配置
   # 1. 检查 yum-config-manager 是否可用
   command -v yum-config-manager
   
   # 2. 检查仓库配置文件
   ls -la /etc/yum.repos.d/
   
   # 3. 检查 Docker CE 仓库是否配置
   cat /etc/yum.repos.d/docker-ce.repo
   
   # 访问系统，检查移动端适配
   # 1. 使用移动设备或浏览器开发者工具模拟移动设备
   # 2. 访问登录页面，检查移动端布局
   # 3. 访问注册页面，检查移动端布局
   # 4. 访问忘记密码页面，检查移动端布局
   # 5. 测试触摸操作是否流畅
   ```

### ⚠️ 注意事项

1. **仓库配置**：
   - 确保系统能够访问互联网以下载 yum-utils 包
   - 如果网络受限，可以手动安装 yum-utils：`dnf -y install yum-utils`
   - 仓库配置失败不会影响系统原有仓库

2. **移动端测试**：
   - 建议使用真实移动设备测试
   - 或使用浏览器开发者工具模拟移动设备
   - 测试不同屏幕尺寸（768px、480px）

3. **触摸优化**：
   - 确保按钮尺寸符合触摸标准（最小44px）
   - 检查间距是否足够，避免误触
   - 测试表单输入和提交操作是否流畅

### 📝 版本历史

**V4.2.1** (2026-01-15)：
- 仓库配置问题修复
- 仓库补全逻辑优化
- 登录注册页面移动端适配

## 📚 历史版本记录

## 🎉 V4.2.0 (2026-01-15) - 移动端适配全面优化

### 🎊 版本亮点

**V4.2.0 是一个移动端适配全面优化版本，为主页和更新日志页面添加了完整的移动端适配支持，包括响应式导航菜单、触摸优化、多列布局优化，确保系统在移动设备上提供优秀的用户体验。**

#### 📱 响应式导航菜单

**移动端导航优化**：
- **功能描述**：
  - 添加汉堡菜单按钮，移动端友好的导航体验
  - 侧边滑出菜单，从右侧平滑滑出
  - 点击链接自动关闭菜单，提升用户体验
  - 菜单动画效果，平滑过渡
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue` 和 `frontend/src/modules/Changelog.vue`：添加移动端菜单按钮
  - 使用 CSS 过渡动画实现侧边滑出效果
  - 添加 `mobileMenuOpen` 状态管理菜单显示/隐藏
  - 添加 `toggleMobileMenu` 和 `closeMobileMenu` 函数
  - 响应式 CSS：768px 以下显示汉堡菜单，隐藏桌面导航
- **使用场景**：
  - 移动设备用户导航
  - 提升移动端用户体验
  - 统一移动端和桌面端设计风格

#### 🎨 主页移动端适配

**响应式布局优化**：
- **功能描述**：
  - Hero区域字体大小自适应，移动端友好
  - 统计数据移动端2列布局，小屏1列
  - 特性卡片单列布局，触摸友好
  - 架构层垂直布局，移动端优化
  - 技术栈单列布局，信息清晰
  - CTA按钮全宽设计，易于点击
  - 页脚多列布局，与桌面端一致
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue`：添加响应式 CSS
  - 使用媒体查询：`@media (max-width: 768px)` 和 `@media (max-width: 480px)`
  - Hero区域：字体大小使用 `clamp()` 函数自适应
  - 统计数据：移动端2列，小屏1列网格布局
  - 特性卡片：单列布局，间距优化
  - 架构层：垂直布局，移动端友好
  - 页脚：2列网格布局，Logo区域横跨整行
- **使用场景**：
  - 移动设备浏览主页
  - 触摸设备交互
  - 小屏幕设备显示优化

#### 📄 更新日志页移动端适配

**移动端体验优化**：
- **功能描述**：
  - 版本卡片移动端布局优化，信息层次清晰
  - 分页控件移动端垂直布局，按钮全宽
  - 页码按钮触摸友好尺寸（最小32px）
  - 最新版本卡片移动端布局优化
  - 页脚多列布局，保持一致性
- **实现逻辑**：
  - 更新 `frontend/src/modules/Changelog.vue`：添加响应式 CSS
  - 版本卡片：移动端 padding 和字体大小优化
  - 分页控件：移动端垂直布局，按钮全宽
  - 页码按钮：最小尺寸32px，触摸友好
  - 页脚：2列网格布局，与主页保持一致
- **使用场景**：
  - 移动设备浏览更新日志
  - 触摸设备分页操作
  - 小屏幕设备显示优化

#### 🎯 触摸优化

**移动端交互优化**：
- **功能描述**：
  - 按钮最小尺寸36-40px，符合触摸标准
  - 间距优化，移动端增加间距避免误触
  - 字体大小自适应，移动端使用合适字号
  - 响应式断点：768px以下平板和手机布局，480px以下小屏手机优化
- **实现逻辑**：
  - 所有按钮：最小高度36px，移动端40px
  - 间距：移动端增加 padding 和 gap
  - 字体：使用 `clamp()` 或媒体查询调整大小
  - 响应式断点：`@media (max-width: 768px)` 和 `@media (max-width: 480px)`
- **使用场景**：
  - 触摸设备交互
  - 小屏幕设备显示
  - 提升移动端用户体验

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/modules/Landing.vue`**：
- **移动端菜单**：
  - 添加汉堡菜单按钮（`.mobile-menu-toggle`）
  - 添加侧边滑出菜单（`.nav-links.mobile-menu-open`）
  - 添加菜单状态管理（`mobileMenuOpen`）
  - 添加菜单切换函数（`toggleMobileMenu`、`closeMobileMenu`）
- **响应式布局**：
  - Hero区域响应式字体和间距
  - 统计数据移动端2列布局
  - 特性卡片单列布局
  - 架构层垂直布局
  - 技术栈单列布局
  - CTA按钮全宽设计
  - 页脚2列布局

**2. `frontend/src/modules/Changelog.vue`**：
- **移动端菜单**：
  - 添加汉堡菜单按钮
  - 添加侧边滑出菜单
  - 添加菜单状态管理
  - 添加菜单切换函数
- **响应式布局**：
  - 版本卡片移动端布局优化
  - 分页控件移动端垂直布局
  - 页码按钮触摸友好尺寸
  - 页脚2列布局

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重建前端界面**：
   ```bash
   ./start.sh rebuild
   ```
   脚本会自动：
   - 重新构建前端界面
   - 应用移动端适配样式
   - 更新响应式布局

4. **验证功能**：
   ```bash
   # 检查前端文件
   ls -la /var/www/mail-frontend/
   
   # 访问系统，检查移动端适配
   # 1. 使用移动设备或浏览器开发者工具模拟移动设备
   # 2. 访问主页，检查汉堡菜单是否显示
   # 3. 测试侧边滑出菜单是否正常工作
   # 4. 检查响应式布局是否正确
   # 5. 访问更新日志页面，检查移动端适配
   # 6. 测试触摸操作是否流畅
   ```

### ⚠️ 注意事项

1. **移动端测试**：
   - 建议使用真实移动设备测试
   - 或使用浏览器开发者工具模拟移动设备
   - 测试不同屏幕尺寸（768px、480px）

2. **触摸优化**：
   - 确保按钮尺寸符合触摸标准（最小36px）
   - 检查间距是否足够，避免误触
   - 测试滚动和滑动操作是否流畅

3. **响应式布局**：
   - 检查所有页面元素在不同屏幕尺寸下的显示
   - 确保文字大小合适，不会太小或太大
   - 验证页脚多列布局是否正确显示

### 📝 版本历史

**V4.2.0** (2026-01-15)：
- 响应式导航菜单
- 主页移动端适配
- 更新日志页移动端适配
- 触摸优化

## 📚 历史版本记录

## 🎉 V4.1.4 (2026-01-14) - 更新日志页面优化与问题修复

### 🎊 版本亮点

**V4.1.4 是一个更新日志页面优化和问题修复版本，修复了版本历史解析问题，优化了导航栏功能，改进了版本历史管理逻辑，确保所有版本都能正确显示。**

#### 🐛 版本解析问题修复

**版本历史解析优化**：
- **功能描述**：
  - 修复版本表格行首空格导致的解析失败问题
  - 优化过滤逻辑，支持行首有空格的版本行
  - 改进 emoji 字符处理，确保正确移除
  - 修复 V4.1.3 版本无法显示的问题
- **实现逻辑**：
  - 更新 `backend/dispatcher/server.js`：改进版本行过滤逻辑
  - 支持检测 `| **V` 模式，即使行首有空格也能识别
  - 自动修复格式问题：如果 trim 后不是以 `|` 开头但包含 `| **V`，自动添加 `|`
  - 优化 emoji 移除逻辑，确保所有 emoji 字符都被正确移除
- **使用场景**：
  - 确保所有版本都能正确解析
  - 支持灵活的表格格式
  - 提升版本历史显示的可靠性

#### 🎨 导航栏功能增强

**注册按钮添加**：
- **功能描述**：
  - 更新日志页面导航栏添加注册按钮
  - 与首页导航栏保持一致的设计风格
  - 提升用户注册转化率
- **实现逻辑**：
  - 更新 `frontend/src/modules/Changelog.vue`：在导航栏添加注册按钮
  - 添加 `goToRegister` 函数，跳转到注册页面
  - 添加 `secondary` 按钮样式（透明背景 + 边框）
  - 响应式设计优化，确保移动端正常显示
- **使用场景**：
  - 用户快速注册
  - 提升用户转化率
  - 统一用户体验

#### 📋 版本历史管理优化

**解析逻辑改进**：
- **功能描述**：
  - 支持更灵活的表格格式（允许行首空格）
  - 自动修复格式问题（行首缺少 | 的情况）
  - 确保所有版本都能正确解析和显示
  - 版本排序逻辑优化（日期相同按版本号倒序）
- **实现逻辑**：
  - 改进过滤条件：检测 `| **V` 模式，即使行首有空格
  - 自动修复逻辑：trim 后如果不是以 `|` 开头，但包含 `| **V`，自动添加 `|`
  - 版本排序：按日期倒序，日期相同按版本号倒序（V4.1.4 > V4.1.3 > V4.1.2）
- **使用场景**：
  - 支持各种表格格式
  - 自动修复格式问题
  - 确保版本正确排序

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/modules/Changelog.vue`**：
- **导航栏更新**：
  - 添加注册按钮（`@click="goToRegister"`）
  - 添加 `goToRegister` 函数
  - 添加 `secondary` 按钮样式

**2. `frontend/src/modules/Landing.vue`**：
- **导航栏更新**：
  - 添加注册按钮（与更新日志页面一致）

#### 🔧 后端更新

**1. `backend/dispatcher/server.js`**：
- **版本解析逻辑优化**：
  - 改进过滤条件，支持行首有空格的版本行
  - 添加自动修复逻辑，处理格式问题
  - 优化版本排序逻辑

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重建前端界面**：
   ```bash
   ./start.sh rebuild
   ```
   脚本会自动：
   - 重新构建前端界面
   - 更新路由配置
   - 应用新的导航栏功能

4. **重启后端服务**：
   ```bash
   sudo systemctl restart mail-ops-dispatcher
   ```

5. **验证功能**：
   ```bash
   # 检查前端文件
   ls -la /var/www/mail-frontend/
   
   # 访问系统，检查更新日志页面
   # 1. 访问 /changelog 页面
   # 2. 检查 V4.1.4 是否显示为最新版本
   # 3. 检查导航栏是否有注册按钮
   # 4. 测试注册按钮是否正常跳转
   # 5. 检查版本历史列表是否正确显示所有版本
   ```

### ⚠️ 注意事项

1. **后端服务重启**：
   - 必须重启后端服务才能应用新的解析逻辑
   - 使用 `sudo systemctl restart mail-ops-dispatcher` 重启
   - 检查服务状态：`sudo systemctl status mail-ops-dispatcher`

2. **版本格式**：
   - 确保 README.md 中版本表格格式正确
   - 每行应以 `|` 开头
   - 如果行首有空格，系统会自动修复

3. **版本排序**：
   - 版本按时间倒序排列（最新的在前）
   - 日期相同的版本按版本号倒序排列
   - 确保版本号格式正确（V4.1.4 > V4.1.3）

### 📝 版本历史

**V4.1.4** (2026-01-14)：
- 版本解析问题修复
- 导航栏功能增强
- 版本历史管理优化

## 📚 历史版本记录

## 🎉 V4.1.3 (2026-01-14) - 更新日志页面与版本历史管理

### 🎊 版本亮点

**V4.1.3 是一个更新日志页面和版本历史管理版本，创建了独立的更新日志页面，实现了自动同步 README.md 内容的功能，支持分页浏览完整版本历史，提升了版本信息管理的便利性。**

#### 📄 更新日志页面创建

**全新更新日志页面**：
- **功能描述**：
  - 创建独立的更新日志页面（`/changelog`）
  - 科幻风格设计，与首页风格一致
  - 自动同步 README.md 中的版本历史
  - 支持完整版本历史展示（从 V4.1.2 到 V1.0.0）
- **实现逻辑**：
  - 创建 `frontend/src/modules/Changelog.vue` 组件
  - 添加路由配置：`{ path: '/changelog', component: Changelog }`
  - 将更新日志页面设为公开页面（无需登录）
  - 在首页导航栏和页脚添加"更新日志"链接
- **使用场景**：
  - 用户查看系统版本历史
  - 了解系统更新内容
  - 版本信息集中管理

#### 🔄 自动同步机制

**版本信息自动同步**：
- **功能描述**：
  - 后端 API 自动读取并解析 README.md
  - 提取版本历史表格中的所有版本信息
  - 前端页面自动加载并显示最新内容
  - 无需手动维护，更新 README 即可自动同步
- **实现逻辑**：
  - 后端 API 端点：`/api/changelog`
  - 解析 README.md 中的版本历史表格
  - 支持两种格式：有标题格式和无标题格式
  - 返回 JSON 格式数据（版本列表、最新版本信息、总数）
- **使用场景**：
  - 版本信息自动更新
  - 减少维护工作量
  - 确保版本信息一致性

#### 📑 分页功能

**智能分页系统**：
- **功能描述**：
  - 每页显示 15 个版本
  - 支持上一页/下一页导航
  - 智能页码显示（最多显示 7 个页码）
  - 分页信息显示（总版本数、当前页/总页数）
- **实现逻辑**：
  - 使用 Vue 3 `computed` 计算属性实现分页
  - 分页控件包含：上一页/下一页按钮、页码按钮、分页信息
  - 切换页面时自动滚动到顶部
  - 滚动动画在切换页面后重新初始化
- **使用场景**：
  - 浏览大量版本历史
  - 快速定位特定版本
  - 提升浏览体验

#### 🎨 用户体验优化

**滚动动画效果**：
- **功能描述**：
  - 版本卡片滚动触发动画
  - 最新版本突出显示
  - 响应式设计，适配移动端和桌面端
  - 切换页面时自动滚动到顶部
- **实现逻辑**：
  - 使用 `Intersection Observer API` 实现滚动动画
  - 最新版本卡片使用特殊样式突出显示
  - 响应式 CSS 适配不同屏幕尺寸
  - 平滑滚动效果提升用户体验
- **使用场景**：
  - 提升视觉体验
  - 增强交互反馈
  - 优化移动端体验

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/modules/Changelog.vue`**（新建）：
- **页面结构**：
  - 科幻背景效果（渐变光球、网格图案、粒子动画）
  - 导航栏和页脚与首页一致
  - 最新版本卡片突出显示
  - 版本历史列表支持分页
- **功能实现**：
  - 自动加载版本历史数据
  - 分页功能（每页15个版本）
  - 滚动触发动画效果
  - 响应式设计

**2. `frontend/src/main.ts`**：
- **路由配置**：
  - 添加 `/changelog` 路由
  - 将更新日志页面设为公开页面

**3. `frontend/src/modules/Landing.vue`**：
- **导航栏更新**：
  - 添加"更新日志"链接
- **页脚更新**：
  - 资源部分添加"更新日志"链接

#### 🔧 后端更新

**1. `backend/dispatcher/server.js`**：
- **API 端点**：
  - 新增 `/api/changelog` API 端点
  - 自动读取并解析 README.md
  - 提取版本历史表格信息
  - 支持两种格式（有标题/无标题）

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重建前端界面**：
   ```bash
   ./start.sh rebuild
   ```
   脚本会自动：
   - 重新构建前端界面
   - 更新路由配置
   - 应用新的更新日志页面

4. **验证功能**：
   ```bash
   # 检查前端文件
   ls -la /var/www/mail-frontend/
   
   # 访问系统，检查更新日志页面
   # 1. 访问 /changelog 页面
   # 2. 检查版本历史是否正确显示
   # 3. 测试分页功能是否正常
   # 4. 检查最新版本卡片是否突出显示
   # 5. 测试滚动动画效果
   ```

### ⚠️ 注意事项

1. **前端重建**：
   - 必须执行 `./start.sh rebuild` 重新构建前端
   - 确保路由配置正确更新
   - 检查浏览器缓存，可能需要强制刷新（Ctrl+F5）

2. **API 端点**：
   - 确保 `/api/changelog` API 端点正常工作
   - 检查 README.md 文件路径是否正确
   - 如果版本信息显示异常，检查 API 响应

3. **版本信息同步**：
   - 更新 README.md 中的版本历史表格
   - 页面会自动读取并显示最新内容
   - 无需修改代码，只需更新 README

### 📝 版本历史

**V4.1.3** (2026-01-14)：
- 更新日志页面创建
- 自动同步机制实现
- 分页功能添加
- 用户体验优化

## 📚 历史版本记录

## 🎉 V4.1.2 (2026-01-14) - 首页优化与用户体验提升

### 🎊 版本亮点

**V4.1.2 是一个首页优化和用户体验提升版本，优化了首页的版本号同步、CTA按钮、文案排版和页脚信息，提升了用户引导和整体体验。**

#### 🔄 版本号自动同步

**版本号统一管理**：
- **功能描述**：
  - 首页顶部版本号与页脚版本号自动同步
  - 使用 `versionManager` 动态获取版本信息
  - 确保版本号显示一致性
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue`：顶部版本号从硬编码改为使用 `{{ currentVersion }}` 变量
  - 添加 `versionManager` 导入和 `loadVersion` 函数
  - 在 `onMounted` 钩子中自动加载版本信息
- **使用场景**：
  - 版本号自动更新，无需手动修改
  - 确保版本号显示一致性
  - 提升系统维护便利性

#### 🎯 CTA按钮优化

**按钮功能更新**：
- **功能描述**：
  - "立即部署"改为"立即登录"，跳转到登录页面
  - "查看文档"改为"立即注册"，跳转到注册页面
  - 提升用户引导和转化率
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue`：修改CTA区域按钮文字和功能
  - 添加 `goToRegister` 函数，跳转到注册页面
  - 将第二个按钮从链接改为按钮，保持样式一致
- **使用场景**：
  - 新用户快速注册
  - 已有用户快速登录
  - 提升用户转化率

#### 📝 文案与排版优化

**副标题优化**：
- **功能描述**：
  - 移除"自动部署"描述，简化文案
  - 优化副标题排版，增加分行提升可读性
  - 文案更简洁明了
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue`：修改副标题文字内容
  - 调整换行结构，增加空行提升可读性
- **使用场景**：
  - 提升文案可读性
  - 简化用户理解
  - 优化视觉层次

#### 🔗 页脚信息同步

**页脚格式统一**：
- **功能描述**：
  - 首页页脚与登录页面页脚格式保持一致
  - 统一版权信息、版本信息显示格式
  - 提升整体视觉一致性
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue`：页脚结构与登录页面保持一致
  - 添加版本号动态显示功能
  - 统一CSS样式
- **使用场景**：
  - 统一用户体验
  - 提升视觉一致性
  - 增强品牌识别

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/modules/Landing.vue`**：
- **版本号自动同步**：
  - 顶部版本号：`V4.1.0` → `{{ currentVersion }}`
  - 添加 `versionManager` 导入和版本加载逻辑
- **CTA按钮更新**：
  - "立即部署" → "立即登录"（`@click="goToLogin"`）
  - "查看文档" → "立即注册"（`@click="goToRegister"`）
  - 添加 `goToRegister` 函数
- **文案优化**：
  - 副标题：移除"自动部署"描述
  - 排版：增加分行提升可读性
- **页脚同步**：
  - 页脚结构与登录页面保持一致
  - 添加版本号动态显示

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重建前端界面**：
   ```bash
   ./start.sh rebuild
   ```
   脚本会自动：
   - 重新构建前端界面
   - 更新所有页面的版本号显示逻辑
   - 应用新的按钮和文案

4. **验证功能**：
   ```bash
   # 检查前端文件
   ls -la /var/www/mail-frontend/
   
   # 访问系统，检查首页
   # 1. 检查顶部版本号是否与页脚版本号一致
   # 2. 测试"立即登录"按钮是否跳转到登录页
   # 3. 测试"立即注册"按钮是否跳转到注册页
   # 4. 检查页脚信息是否与登录页面一致
   ```

### ⚠️ 注意事项

1. **前端重建**：
   - 必须执行 `./start.sh rebuild` 重新构建前端
   - 确保版本号显示逻辑正确更新
   - 检查浏览器缓存，可能需要强制刷新（Ctrl+F5）

2. **版本号同步**：
   - 版本号会从 `versionManager` 自动获取
   - 确保版本号API正常工作
   - 如果版本号显示异常，检查网络连接和API状态

3. **按钮功能**：
   - 确保路由配置正确（`/login` 和 `/register`）
   - 测试按钮点击功能是否正常
   - 检查页面跳转是否流畅

### 📝 版本历史

**V4.1.2** (2026-01-14)：
- 版本号自动同步（顶部与页脚版本号统一）
- CTA按钮优化（立即登录、立即注册）
- 文案与排版优化（副标题简化、排版优化）
- 页脚信息同步（与登录页面格式一致）

---

## 📚 历史版本记录

## 🎉 V4.1.1 (2026-01-14) - 品牌统一与UI优化

### 🎊 版本亮点

**V4.1.1 是一个品牌统一和UI优化版本，统一了系统名称和图标系统，提升了系统的专业性和视觉一致性。**

#### 🌐 品牌名称统一

**系统名称统一**：
- **功能描述**：
  - 所有页面（主页、登录、注册、重置密码）统一使用"XM邮件管理系统"名称
  - 替换原有的"XM Mail"标识，提升品牌一致性
  - 统一用户界面体验
- **实现逻辑**：
  - 更新 `frontend/src/modules/Landing.vue`：导航栏和页脚统一名称
  - 更新 `frontend/src/modules/Login.vue`：Logo区域统一名称
  - 更新 `frontend/src/modules/Register.vue`：Logo区域统一名称
  - 更新 `frontend/src/modules/Reset.vue`：Logo区域统一名称
- **使用场景**：
  - 提升品牌识别度
  - 统一用户体验
  - 增强系统专业性

#### 🎨 图标系统优化

**Favicon统一**：
- **功能描述**：
  - 所有页面统一使用 `frontend/favicon.ico` 作为系统图标
  - 替换原有的emoji图标（📧），使用专业的图标文件
  - 提升系统专业性和视觉一致性
- **实现逻辑**：
  - 将所有页面的emoji图标（`<div class="logo-icon">📧</div>`）替换为图片标签（`<img src="/favicon.ico" alt="Logo" class="logo-icon" />`）
  - 更新CSS样式：从 `font-size` 改为 `width/height` 适配图片
  - 添加 `object-fit: contain` 确保图标正确显示
- **使用场景**：
  - 浏览器标签页显示专业图标
  - 统一视觉识别
  - 提升用户体验

#### 🔧 界面优化

**Logo显示优化**：
- **功能描述**：
  - Logo图标从emoji改为图片标签（`<img>`）
  - CSS样式从 `font-size` 改为 `width/height` 适配图片
  - 响应式设计，适配不同屏幕尺寸
- **实现逻辑**：
  - 主页导航栏和页脚：图标大小 `2rem × 2rem`
  - 登录/注册/重置页面：图标大小 `3rem × 3rem`
  - 使用 `object-fit: contain` 保持图标比例
- **使用场景**：
  - 清晰的图标显示
  - 响应式适配
  - 专业视觉效果

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/modules/Landing.vue`**：
- **品牌名称统一**：
  - 导航栏：`XM Mail` → `XM邮件管理系统`
  - 页脚：`XM Mail` → `XM邮件管理系统`
- **图标更新**：
  - emoji图标（📧）→ `<img src="/favicon.ico">`
  - CSS样式：`font-size: 2rem` → `width: 2rem; height: 2rem`

**2. `frontend/src/modules/Login.vue`**：
- **品牌名称统一**：
  - Logo区域：`XM Mail` → `XM邮件管理系统`
- **图标更新**：
  - emoji图标（📧）→ `<img src="/favicon.ico">`
  - CSS样式：`font-size: 3rem` → `width: 3rem; height: 3rem`

**3. `frontend/src/modules/Register.vue`**：
- **品牌名称统一**：
  - Logo区域：`XM Mail` → `XM邮件管理系统`
- **图标更新**：
  - emoji图标（📧）→ `<img src="/favicon.ico">`
  - CSS样式：`font-size: 3rem` → `width: 3rem; height: 3rem`

**4. `frontend/src/modules/Reset.vue`**：
- **品牌名称统一**：
  - Logo区域：`XM Mail` → `XM邮件管理系统`
- **图标更新**：
  - emoji图标（📧）→ `<img src="/favicon.ico">`
  - CSS样式：`font-size: 3rem` → `width: 3rem; height: 3rem`

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重建前端界面**：
   ```bash
   ./start.sh rebuild
   ```
   脚本会自动：
   - 重新构建前端界面
   - 更新所有页面的品牌名称和图标
   - 应用新的CSS样式

4. **验证功能**：
   ```bash
   # 检查前端文件
   ls -la /var/www/mail-frontend/
   
   # 访问系统，检查所有页面
   # 1. 主页：检查导航栏和页脚的品牌名称和图标
   # 2. 登录页：检查Logo区域的品牌名称和图标
   # 3. 注册页：检查Logo区域的品牌名称和图标
   # 4. 重置密码页：检查Logo区域的品牌名称和图标
   ```

### ⚠️ 注意事项

1. **前端重建**：
   - 必须执行 `./start.sh rebuild` 重新构建前端
   - 确保所有页面都更新了品牌名称和图标
   - 检查浏览器缓存，可能需要强制刷新（Ctrl+F5）

2. **图标文件**：
   - 确保 `frontend/favicon.ico` 文件存在
   - 图标文件路径为 `/favicon.ico`（相对于网站根目录）
   - 如果图标不显示，检查文件路径和权限

3. **浏览器缓存**：
   - 更新后可能需要清除浏览器缓存
   - 使用强制刷新（Ctrl+F5）查看最新版本
   - 检查浏览器开发者工具中的网络请求

### 📝 版本历史

**V4.1.1** (2026-01-14)：
- 品牌名称统一（所有页面统一使用"XM邮件管理系统"）
- 图标系统优化（统一使用favicon.ico）
- Logo显示优化（响应式设计、CSS样式更新）

---

## 📚 历史版本记录

## 🎉 V4.1.0 (2026-01-13) - 系统命令终端重构

### 🎊 版本亮点

**V4.1.0 是一个重要的终端功能重构版本，实现了类似阿里云 Workbench 的现代化终端体验，使用 WebSocket 和 node-pty 提供完整的交互式终端功能，提升了系统的可用性和用户体验。**

#### 🖥️ WebSocket 实时终端通信

**WebSocket 服务器**：
- **功能描述**：
  - 后端使用 `ws` 库实现 WebSocket 服务器
  - 支持实时双向通信，无延迟交互
  - 处理终端输入输出、认证、会话管理
  - 支持多客户端并发连接
- **实现逻辑**：
  - 在 `backend/dispatcher/server.js` 中创建 WebSocket 服务器
  - 监听 `/api/terminal/ws` 路径
  - 通过 Apache `mod_proxy_wstunnel` 代理 WebSocket 连接
  - 支持认证和会话管理
- **使用场景**：
  - 实时终端输出显示
  - 用户命令输入传输
  - 终端大小调整
  - 多标签页终端管理

**伪终端支持**：
- **功能描述**：
  - 使用 `node-pty` 创建真正的伪终端（PTY）
  - 支持完整的交互式 shell 功能
  - 正确的终端格式显示（无 bash 错误）
  - 支持终端大小调整和颜色显示
- **实现逻辑**：
  - 使用 `pty.spawn('/bin/bash', ['-l'])` 创建交互式 shell
  - 设置正确的环境变量（TERM、HOME、USER 等）
  - 通过 `shell.onData()` 接收输出
  - 通过 `shell.write()` 发送输入
- **使用场景**：
  - 执行系统命令
  - 交互式程序运行
  - 文件编辑和管理
  - 系统监控和调试

#### 🎨 现代化终端界面

**多标签页管理**：
- **功能描述**：
  - 支持创建多个终端标签页
  - 每个标签页独立的终端会话
  - 标签页切换和关闭功能
  - 类似阿里云 Workbench 的用户体验
- **实现逻辑**：
  - 使用 Vue 3 的响应式数据管理标签页
  - 每个标签页维护独立的 Terminal 实例和 WebSocket 连接
  - 支持标签页的动态创建和销毁
- **使用场景**：
  - 同时执行多个任务
  - 不同目录的操作
  - 多会话管理

**工具栏功能**：
- **功能描述**：
  - 复制、粘贴、清屏功能
  - 终端设置（字体大小、主题切换）
  - 响应式设计，支持移动端
  - 优雅的 UI 设计
- **实现逻辑**：
  - 使用 xterm.js 的 API 实现复制粘贴
  - 支持多种终端主题（dark、light、green）
  - 响应式布局适配不同屏幕尺寸
- **使用场景**：
  - 快速复制命令输出
  - 粘贴长命令
  - 清空终端屏幕
  - 调整终端显示效果

#### 🔧 系统改进

**依赖管理优化**：
- **xterm 依赖更新**：
  - 更新到新包名：`@xterm/xterm`、`@xterm/addon-fit` 等
  - 修复弃用警告
  - 使用最新版本的 xterm.js
- **构建工具自动安装**：
  - 自动安装 gcc、gcc-c++、make、python3-devel
  - 确保 node-pty 能够正确编译
  - 完善的错误处理和验证
- **依赖验证**：
  - 安装后验证所有关键依赖
  - 如果依赖缺失，给出明确的错误提示
  - 支持手动安装指导

**脚本完善**：
- **start.sh 改进**：
  - 改进依赖安装逻辑，严格的错误处理
  - 修复 bash 脚本语法错误（local、return 等）
  - 添加构建工具安装步骤
  - 完善依赖验证机制
- **终端资源管理**：
  - 修复终端关闭后重新打开的问题
  - 正确清理 WebSocket 连接和终端实例
  - 支持终端重新初始化

**技术实现**：
- **前端文件**：
  - `frontend/src/components/Terminal.vue`：终端组件
  - `frontend/package.json`：更新 xterm 依赖
- **后端文件**：
  - `backend/dispatcher/server.js`：WebSocket 服务器和 PTY 管理
  - `backend/dispatcher/package.json`：添加 node-pty 依赖
- **配置文件**：
  - `backend/apache/httpd-vhost.conf`：WebSocket 代理配置
  - `start.sh`：构建工具安装和依赖管理

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/components/Terminal.vue`**：
- **WebSocket 连接**：
  - 实现 WebSocket 客户端连接
  - 支持认证和会话管理
  - 处理终端输入输出
- **多标签页管理**：
  - 标签页创建、切换、关闭功能
  - 每个标签页独立的终端实例
  - 资源清理和重新初始化
- **工具栏功能**：
  - 复制、粘贴、清屏功能
  - 终端设置（字体大小、主题）
  - 响应式设计

**2. `frontend/package.json`**：
- **依赖更新**：
  - `xterm` → `@xterm/xterm`
  - `xterm-addon-fit` → `@xterm/addon-fit`
  - `xterm-addon-web-links` → `@xterm/addon-web-links`
  - `xterm-addon-search` → `@xterm/addon-search`

#### 🔧 后端更新

**1. `backend/dispatcher/server.js`**：
- **WebSocket 服务器**：
  - 创建 WebSocket 服务器实例
  - 处理连接、认证、消息路由
  - 管理终端会话和进程
- **PTY 管理**：
  - 使用 node-pty 创建伪终端
  - 处理 shell 输入输出
  - 支持终端大小调整

**2. `backend/dispatcher/package.json`**：
- **新增依赖**：
  - `node-pty`：伪终端支持

#### 🛠️ 系统脚本更新

**1. `start.sh`**：
- **构建工具安装**：
  - 自动安装 gcc、gcc-c++、make、python3-devel
  - 确保 node-pty 能够正确编译
- **依赖管理改进**：
  - 严格的错误处理和验证
  - 修复 bash 脚本语法错误
  - 完善的依赖验证机制

**2. `backend/apache/httpd-vhost.conf`**：
- **WebSocket 代理**：
  - 配置 WebSocket 代理路径
  - 支持 WebSocket 升级请求

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **执行安装/重装**：
   ```bash
   ./start.sh start
   ```
   脚本会自动：
   - 安装构建工具（gcc、make、python3-devel）
   - 安装调度层依赖（包括 node-pty）
   - 验证所有依赖安装成功
   - 配置 WebSocket 代理

4. **验证功能**：
   ```bash
   # 检查调度层服务状态
   systemctl status mail-ops-dispatcher
   
   # 检查 WebSocket 连接
   # 登录系统，打开命令终端，测试终端功能
   
   # 测试多标签页功能
   # 创建多个终端标签页，测试切换和关闭
   
   # 测试终端功能
   # 执行命令，测试输入输出、复制粘贴等功能
   ```

### ⚠️ 注意事项

1. **构建工具要求**：
   - 系统需要安装 gcc、gcc-c++、make、python3-devel
   - 脚本会自动安装，如果安装失败请手动安装
   - node-pty 需要编译原生模块，必须有构建工具

2. **WebSocket 配置**：
   - 确保 Apache `mod_proxy_wstunnel` 模块已启用
   - 检查 WebSocket 代理配置是否正确
   - 如果连接失败，检查防火墙和网络配置

3. **终端使用**：
   - 关闭终端时会自动清理资源
   - 重新打开终端时会自动重新初始化
   - 如果终端无响应，刷新页面或重新打开终端

4. **依赖安装**：
   - 如果 npm install 失败，检查网络连接
   - 确保构建工具已正确安装
   - 查看日志文件获取详细错误信息

### 📝 版本历史

**V4.1.0** (2026-01-13)：
- WebSocket 实时终端通信
- 伪终端支持（node-pty）
- 多标签页终端管理
- 现代化终端界面
- 依赖管理优化
- 脚本完善和错误修复

---

## 📚 历史版本记录

## 🎉 V4.0.2 (2026-01-13) - 系统设置自动备份与恢复

**自动备份功能**：
- **功能描述**：
  - 系统启动时（执行 `./start.sh start`）自动检测系统设置文件
  - 如果配置文件存在，自动备份到 `config/system-settings.json.backup`
  - 仅在备份不存在或配置文件更新时创建/更新备份
  - 避免重复备份，节省存储空间
- **实现逻辑**：
  - 检查 `config/system-settings.json` 是否存在
  - 如果存在，检查备份文件是否存在或配置文件是否更新
  - 满足条件时自动创建或更新备份文件
  - 备份文件与配置文件保持同步
- **使用场景**：
  - 系统正常运行时自动备份配置
  - 用户修改系统设置后自动更新备份
  - 为系统重装提供配置恢复基础

**自动恢复功能**：
- **功能描述**：
  - 系统启动时检测配置文件是否存在
  - 如果配置文件不存在但备份存在，自动恢复备份
  - 恢复后自动设置正确的文件权限（所有者：xm，权限：644）
  - 确保恢复的文件可以正常使用
- **实现逻辑**：
  - 检查 `config/system-settings.json` 是否存在
  - 如果不存在，检查备份文件是否存在
  - 如果备份存在，自动恢复备份文件
  - 设置正确的文件权限和所有者
- **使用场景**：
  - 系统重装后自动恢复用户配置
  - 配置文件意外删除后自动恢复
  - 系统升级时保留用户配置

**配置保护机制**：
- **重装保护**：
  - 执行 `./start.sh start` 时自动保护现有配置
  - 系统设置、DNS配置、安全设置等全部保留
  - 无需手动备份和恢复配置文件
  - 提升系统重装的便利性和安全性
- **配置持久化**：
  - 用户的所有系统设置都会自动保存和恢复
  - 包括：安全设置（会话超时、登录限制、密码策略等）
  - 包括：邮件设置（邮箱大小、消息大小、垃圾邮件过滤等）
  - 包括：DNS配置（域名、服务器IP、DNS类型等）
  - 包括：通知设置（邮件提醒、系统提醒等）
  - 重装系统后无需重新配置，提升用户体验

**技术实现**：
- **文件**：`start.sh`
- **实现位置**：第226-243行（系统设置备份和恢复逻辑）
- **关键代码**：
  ```bash
  # 保护系统设置文件：如果存在则备份，重装后自动恢复
  SYSTEM_SETTINGS_FILE="$CONFIG_DIR/system-settings.json"
  SYSTEM_SETTINGS_BACKUP="$CONFIG_DIR/system-settings.json.backup"
  if [[ -f "$SYSTEM_SETTINGS_FILE" ]]; then
    # 备份现有系统设置文件（如果备份不存在或配置文件更新）
    if [[ ! -f "$SYSTEM_SETTINGS_BACKUP" ]] || [[ "$SYSTEM_SETTINGS_FILE" -nt "$SYSTEM_SETTINGS_BACKUP" ]]; then
      cp "$SYSTEM_SETTINGS_FILE" "$SYSTEM_SETTINGS_BACKUP" 2>/dev/null || true
      echo "[INIT] 系统设置文件已备份: $SYSTEM_SETTINGS_BACKUP"
    fi
  else
    # 如果配置文件不存在但备份存在，恢复备份
    if [[ -f "$SYSTEM_SETTINGS_BACKUP" ]]; then
      cp "$SYSTEM_SETTINGS_BACKUP" "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chown xm:xm "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      chmod 644 "$SYSTEM_SETTINGS_FILE" 2>/dev/null || true
      echo "[INIT] 系统设置文件已从备份恢复: $SYSTEM_SETTINGS_FILE"
    fi
  fi
  ```
- **验证方法**：
  ```bash
  # 1. 检查备份文件是否存在
  ls -l config/system-settings.json.backup
  
  # 2. 删除配置文件，测试自动恢复
  rm config/system-settings.json
  ./start.sh start
  
  # 3. 检查配置文件是否已恢复
  ls -l config/system-settings.json
  
  # 4. 检查配置文件内容是否正确
  cat config/system-settings.json
  ```

### 📋 主要更新内容

#### 🔧 系统脚本更新

**1. `start.sh`**：
- **系统设置保护机制**：
  - 添加了系统设置文件的自动备份功能
  - 添加了系统设置文件的自动恢复功能
  - 确保重装系统后用户配置完整保留
  - 提升了系统的可靠性和用户体验

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **执行安装/重装**：
   ```bash
   ./start.sh start
   ```

4. **验证功能**：
   ```bash
   # 检查备份文件是否存在
   ls -l config/system-settings.json.backup
   
   # 检查系统设置是否正确恢复
   # 登录系统设置页面，确认所有配置都已保留
   
   # 测试重装后配置恢复
   # 删除配置文件，重新执行 start.sh start
   # 确认配置文件自动恢复
   ```

### ⚠️ 注意事项

1. **备份文件管理**：
   - 备份文件位置：`config/system-settings.json.backup`
   - 备份文件不会被自动删除，需要手动清理
   - 如果同时存在配置文件和备份，以配置文件为准

2. **配置恢复时机**：
   - 仅在配置文件不存在且备份存在时自动恢复
   - 如果配置文件已存在，不会覆盖现有配置
   - 恢复后自动设置正确的文件权限

3. **重装系统**：
   - 执行 `./start.sh start` 时会自动检测并恢复配置
   - 无需手动备份和恢复配置文件
   - 所有系统设置都会自动保留

### 📝 版本历史

**V4.0.2** (2026-01-13)：
- 系统设置自动备份功能
- 系统设置自动恢复功能
- 配置保护机制（重装保护、配置持久化）

---

## 📚 历史版本记录

## 🎉 V4.0.1 (2026-01-13) - 用户体验优化与错误提示改进

### 🎊 版本亮点

**V4.0.1 是一个用户体验优化版本，修复了安全设置的默认值显示问题，改进了错误提示的详细程度，优化了SSL配置流程，提升了系统的易用性和用户体验。**

#### 🎯 安全设置优化

**要求特殊字符默认值修复**：
- **问题描述**：
  - "要求特殊字符"开关默认显示为开启状态
  - 即使配置文件中值为 `false`，前端仍显示为开启
  - 用户无法准确了解当前的配置状态
- **修复内容**：
  - 修复了后端配置读取逻辑，确保默认值正确处理
  - 改进了前端配置加载逻辑，正确显示实际配置状态
  - 优化了前后端配置同步机制
  - 确保 `requireSpecialChars` 为 `undefined` 或 `null` 时默认为 `false`
- **修复效果**：
  - 页面正确显示"要求特殊字符"的实际状态
  - 默认状态为关闭，需要管理员手动开启
  - 配置状态显示准确，提升了用户体验

**技术实现**：
- **后端文件**：`backend/dispatcher/server.js`
- **前端文件**：`frontend/src/modules/Settings.vue`
- **修复位置**：
  - 后端：第2740-2745行（配置读取时的默认值处理）
  - 前端：第1454-1462行（配置加载时的默认值处理）
- **验证方法**：
  - 检查系统设置页面中"要求特殊字符"开关的状态
  - 确认默认状态为关闭
  - 测试手动开启和关闭功能

#### 📝 错误提示详细化

**批量创建用户错误提示优化**：
- **问题描述**：
  - 批量创建用户失败时只显示"API调用失败"
  - 无法了解具体的失败原因（密码长度不符合、缺少特殊字符等）
  - 用户难以快速定位和解决问题
- **修复内容**：
  - 改进了API错误响应解析逻辑
  - 提取并显示服务器返回的详细错误信息
  - 支持多种响应格式（JSON、文本）
  - 显示具体的密码验证错误（密码长度、特殊字符要求等）
- **修复效果**：
  - 批量创建失败时显示详细的错误原因
  - 用户可以快速了解问题所在
  - 提升了错误信息的可读性和可操作性

**注册和重置密码页面错误提示优化**：
- **问题描述**：
  - 密码验证失败时只显示通用错误信息
  - 无法了解具体缺少哪些字符类型
  - 用户需要多次尝试才能了解密码要求
- **修复内容**：
  - 改进了客户端密码验证逻辑
  - 明确指出缺少的字符类型（大写字母、小写字母、数字、特殊字符）
  - 改进了API错误响应解析，支持多种响应格式
  - 提供了更友好的错误提示和解决建议
- **修复效果**：
  - 密码验证失败时显示详细的错误信息
  - 明确指出缺少的字符类型
  - 用户可以快速了解密码要求并修改密码

**技术实现**：
- **文件**：
  - `frontend/src/modules/Dashboard.vue`（批量创建）
  - `frontend/src/modules/Register.vue`（注册页面）
  - `frontend/src/modules/Reset.vue`（重置密码页面）
- **修复位置**：
  - Dashboard.vue：第2900-2934行（错误处理逻辑）
  - Register.vue：第223-227行（密码验证提示）、第263-272行（API错误处理）
  - Reset.vue：第203-207行（密码验证提示）、第241-250行（API错误处理）
- **验证方法**：
  - 测试批量创建用户功能，使用不符合要求的密码
  - 测试注册页面，使用不符合要求的密码
  - 测试重置密码页面，使用不符合要求的密码
  - 确认错误提示显示详细的错误信息

#### 🔒 SSL配置优化

**SSL域名输入优化**：
- **问题描述**：
  - SSL域名输入框自动填充DNS配置中的域名
  - 可能导致用户误操作，使用错误的域名
  - 配置流程不够清晰
- **修复内容**：
  - 移除了SSL域名输入框的自动填充功能
  - 用户需要手动输入已申请证书的域名
  - 简化了SSL配置流程
- **修复效果**：
  - 用户需要明确输入域名，避免误操作
  - 配置流程更加清晰
  - 提升了配置的准确性

**技术实现**：
- **文件**：`frontend/src/modules/Settings.vue`
- **修复位置**：第1874-1879行（移除自动填充逻辑）
- **验证方法**：
  - 检查SSL配置页面，确认域名输入框为空
  - 测试手动输入域名功能

### 📋 主要更新内容

#### 🎨 前端更新

**1. `frontend/src/modules/Settings.vue`**：
- **安全设置优化**：
  - 改进了配置加载逻辑，正确显示实际配置状态
  - 优化了默认值处理，确保 `requireSpecialChars` 正确显示
- **SSL配置优化**：
  - 移除了SSL域名输入框的自动填充功能
  - 用户需要手动输入域名

**2. `frontend/src/modules/Dashboard.vue`**：
- **错误提示优化**：
  - 改进了批量创建用户时的错误处理逻辑
  - 提取并显示详细的错误信息
  - 支持多种响应格式

**3. `frontend/src/modules/Register.vue`**：
- **错误提示优化**：
  - 改进了密码验证错误提示，明确指出缺少的字符类型
  - 改进了API错误响应解析
  - 提供了更友好的错误提示

**4. `frontend/src/modules/Reset.vue`**：
- **错误提示优化**：
  - 改进了密码验证错误提示，明确指出缺少的字符类型
  - 改进了API错误响应解析
  - 提供了更友好的错误提示

#### 🔧 后端更新

**1. `backend/dispatcher/server.js`**：
- **配置读取优化**：
  - 改进了 `requireSpecialChars` 的默认值处理
  - 确保值为 `undefined` 或 `null` 时默认为 `false`
  - 优化了配置读取逻辑

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码或更新文件
   git pull
   # 或手动更新相关文件
   ```

3. **重启调度层服务**：
   ```bash
   ./start.sh restart-dispatcher
   ```

4. **验证更新**：
   ```bash
   # 检查服务状态
   ./start.sh status
   
   # 检查系统设置页面
   # 确认"要求特殊字符"开关状态正确
   
   # 测试批量创建用户功能
   # 测试注册和重置密码功能
   # 确认错误提示显示详细信息
   ```

### ⚠️ 注意事项

1. **配置状态检查**：
   - 更新后请检查系统设置页面中"要求特殊字符"的状态
   - 如果之前配置为开启，更新后仍会保持开启状态
   - 如果之前未配置，更新后会显示为关闭状态

2. **错误提示改进**：
   - 批量创建、注册、重置密码的错误提示更加详细
   - 用户可以根据错误提示快速定位和解决问题

3. **SSL配置**：
   - SSL域名输入框不再自动填充
   - 用户需要手动输入已申请证书的域名

### 📝 版本历史

**V4.0.1** (2026-01-13)：
- 安全设置优化（要求特殊字符默认值修复）
- 错误提示详细化（批量创建/注册/重置密码页面）
- SSL配置优化（移除自动填充）

---

## 📚 历史版本记录

## 🎉 V4.0.0 (2026-01-12) - 关键问题修复与系统稳定性提升

### 🎊 版本亮点

**V4.0.0 是一个重要的系统稳定性修复版本，修复了调度层服务启动失败的关键问题，优化了批量创建用户功能，提升了系统的稳定性和可维护性。**

#### 🔧 调度层服务启动修复

**重复声明问题修复**：
- **问题描述**：
  - `mail-ops-dispatcher.service` 启动失败，返回 `SyntaxError: Identifier 'loginAttempts' has already been declared`
  - 服务无法正常启动，导致系统无法使用
- **修复内容**：
  - 移除了重复的 `loginAttempts` 变量声明（第1415行和第1433行）
  - 移除了重复的清理函数（`setInterval`）
  - 确保变量和函数只声明一次
- **修复效果**：
  - 调度层服务可以正常启动
  - 系统功能恢复正常
  - 消除了语法错误

**技术实现**：
- **文件**：`backend/dispatcher/server.js`
- **修复位置**：第1432-1448行（删除重复代码）
- **验证方法**：
  ```bash
  systemctl restart mail-ops-dispatcher
  systemctl status mail-ops-dispatcher
  journalctl -u mail-ops-dispatcher.service -n 50
  ```

#### 👥 批量创建用户功能优化

**验证码验证优化**：
- **问题描述**：
  - 管理员批量创建用户时返回400错误
  - 错误信息：`请完成验证码验证`
  - 批量创建功能无法正常使用
- **修复内容**：
  - 已认证的管理员批量创建用户时跳过验证码验证
  - 普通用户注册时仍需要验证码验证，保持安全性
  - 优化了验证码验证逻辑，区分管理员操作和普通用户操作
- **修复效果**：
  - 管理员批量创建用户功能恢复正常
  - 提升了管理员批量操作的便利性
  - 保持了普通用户注册的安全性

**技术实现**：
- **文件**：`backend/dispatcher/server.js`
- **修复位置**：`app-register` case（第961-976行）
- **逻辑说明**：
  - 如果提供了验证码，则进行验证（普通用户注册场景）
  - 如果没有提供验证码，但已通过auth中间件认证，则跳过验证（管理员批量创建场景）
- **验证方法**：
  - 测试管理员批量创建用户功能
  - 测试普通用户注册功能（需要验证码）

#### 🛠️ 系统稳定性提升

**代码质量改进**：
- **代码清理**：
  - 移除了重复的变量声明
  - 移除了重复的函数定义
  - 优化了代码结构
- **错误处理优化**：
  - 改进了错误处理机制
  - 提升了错误信息的可读性
- **可维护性提升**：
  - 代码结构更加清晰
  - 减少了代码冗余
  - 提升了代码的可读性和可维护性

### 📋 主要更新内容

#### 🔐 后端更新

**1. `backend/dispatcher/server.js`**：
- **重复声明修复**：
  - 移除了重复的 `loginAttempts` 变量声明
  - 移除了重复的清理函数
- **批量创建优化**：
  - 优化了 `app-register` 操作的验证码验证逻辑
  - 已认证的管理员批量创建时跳过验证码验证
  - 普通用户注册时仍需要验证码验证

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   git pull origin main
   # 或手动更新相关文件
   ```

3. **重启调度层服务**：
   ```bash
   systemctl restart mail-ops-dispatcher
   systemctl status mail-ops-dispatcher
   ```

4. **验证更新**：
   - 检查调度层服务状态，确保正常启动
   - 测试管理员批量创建用户功能
   - 测试普通用户注册功能（需要验证码）
   - 查看日志确认没有错误

### ⚠️ 注意事项

- **调度层服务**：更新后需要重启调度层服务才能生效
- **批量创建功能**：管理员批量创建用户时不需要验证码，但普通用户注册仍需要验证码
- **服务状态**：如果服务启动失败，请检查日志文件 `/var/log/mail-ops/operations.log`

---

## 📚 历史版本记录

## 🎉 V3.9.2 (2025-12-21) - 安全功能全面增强

### 🎊 版本亮点

**V3.9.2 是一个重要的安全增强版本，全面提升了系统的安全防护能力，包括验证码系统、登录安全增强、会话超时保护和SSL证书功能增强，有效防止自动化攻击、暴力破解和未授权访问。**

#### ✨ 验证码系统

**验证码保护机制**：
- **注册页面验证码**：
  - 添加数学验证码（加法、减法、乘法），防止自动化注册攻击
  - 验证码5分钟过期，一次性使用，自动刷新机制
  - 验证码错误时自动刷新，提升用户体验
- **重置密码页面验证码**：
  - 添加验证码验证，防止未授权密码重置
  - 与注册页面相同的验证码机制
- **登录页面验证码**：
  - 添加验证码验证，有效防止DDoS和暴力破解攻击
  - 验证码错误也算一次失败尝试，计入登录失败次数
  - 自动刷新机制，确保验证码有效性

**验证码技术实现**：
- **后端API**：
  - `/api/captcha/generate`：生成验证码，返回验证码ID和数学题
  - 使用内存存储（生产环境建议使用Redis）
  - 自动清理过期验证码
- **前端实现**：
  - 美观的验证码显示区域（渐变背景）
  - 一键刷新功能
  - 页面加载时自动获取验证码

#### 🔒 登录安全增强

**登录页面优化**：
- **移除预留账号密码**：
  - 移除默认的管理员账号（`xm`）和密码（`xm666@`）
  - 用户必须手动输入账号和密码，提升安全性
- **登录失败次数限制**：
  - IP级别的失败次数追踪
  - 5次失败后自动锁定15分钟
  - 锁定期间显示剩余时间
  - 登录成功后自动清除失败记录
- **自动清理机制**：
  - 每分钟清理一次过期记录
  - 锁定过期后自动解除
  - 15分钟无活动后清除记录，避免内存泄漏

**安全特性**：
- **IP追踪**：基于IP地址记录失败次数，防止暴力破解
- **时间限制**：15分钟锁定时间，平衡安全性和可用性
- **自动恢复**：锁定过期后自动解除，无需人工干预

#### ⏱️ 会话超时保护

**无操作自动退出**：
- **活动监听**：
  - 监听鼠标移动、点击、滚轮
  - 监听键盘输入（keydown、keypress）
  - 监听触摸事件（移动设备）
  - 监听窗口焦点和页面可见性变化
- **超时机制**：
  - 5分钟无操作自动退出登录
  - 每30秒检查一次，减少性能开销
  - 活动更新有节流（30秒内不重复更新）
- **自动清理**：
  - 退出登录时自动停止追踪
  - 访问公开页面时自动停止追踪
  - 避免内存泄漏

**技术实现**：
- **活动追踪器**（`activityTracker.ts`）：
  - 单例模式，确保全局唯一追踪器
  - 事件监听器自动管理
  - 定时检查机制
- **路由守卫集成**：
  - 访问需要认证的页面时自动启动追踪
  - 访问公开页面时自动停止追踪
  - 登录成功后自动启动追踪

#### 🔐 SSL证书功能增强

**证书申请优化**：
- **IP地址支持**：
  - 自动检测服务器公网IP和本地IP
  - 自动将IP地址添加到证书的Subject Alternative Name (SAN)
  - 支持通过IP地址直接访问HTTPS
- **Apache自动配置**：
  - 自动配置HTTP到HTTPS跳转（端口80到443）
  - 自动配置HTTPS虚拟主机（端口443）
  - 支持域名和IP地址访问
  - 自动启用SSL和Rewrite模块
  - 自动配置防火墙规则，开放HTTPS端口
- **根证书下载**：
  - 提供根证书下载功能（`/api/cert/ca-cert`）
  - 在证书申请对话框中添加"下载根证书"按钮
  - 避免浏览器安全警告

**配置文件优化**：
- **虚拟主机配置**：
  - 域名HTTPS配置：`/etc/httpd/conf.d/${domain}_ssl.conf`
  - IP访问HTTPS配置：`/etc/httpd/conf.d/zz_ip_ssl.conf`（最后加载）
  - HTTP跳转配置：`/etc/httpd/conf.d/${domain}_http.conf`
- **默认虚拟主机**：
  - 更新默认HTTP虚拟主机，添加HTTPS跳转
  - 确保所有HTTP请求自动跳转到HTTPS

### 📋 主要更新内容

#### 🔐 后端更新

**1. `backend/dispatcher/server.js`**：
- **验证码API**：
  - `/api/captcha/generate`：生成验证码
  - 验证码存储和验证逻辑
  - 登录失败次数限制和IP追踪
- **登录验证**：
  - 在`app-login`操作中验证验证码
  - 在`auth`中间件中记录登录失败次数
  - 登录成功后清除失败记录
- **CA证书下载API**：
  - `/api/cert/ca-cert`：下载CA根证书

**2. `backend/scripts/cert_setup.sh`**：
- **IP地址检测**：
  - 自动检测公网IP和本地IP
  - 添加到证书SAN扩展
- **Apache配置**：
  - 自动配置HTTP到HTTPS跳转
  - 自动配置HTTPS虚拟主机（支持IP和域名）
  - 自动启用SSL和Rewrite模块
  - 自动配置防火墙规则

#### 🎨 前端更新

**1. `frontend/src/modules/Register.vue`**：
- 添加验证码输入框和显示区域
- 添加刷新验证码按钮
- 提交时验证验证码

**2. `frontend/src/modules/Reset.vue`**：
- 添加验证码输入框和显示区域
- 添加刷新验证码按钮
- 提交时验证验证码

**3. `frontend/src/modules/Login.vue`**：
- 移除预留的管理员账号和密码
- 添加验证码输入框和显示区域
- 添加刷新验证码按钮
- 提交时验证验证码
- 登录成功后启动活动追踪

**4. `frontend/src/modules/Dashboard.vue`**：
- 证书申请对话框中添加"下载根证书"按钮
- 实现根证书下载功能

**5. `frontend/src/utils/activityTracker.ts`**（新文件）：
- 用户活动追踪器
- 监听多种用户活动事件
- 5分钟无操作自动退出

**6. `frontend/src/main.ts`**：
- 路由守卫中集成活动追踪
- 访问公开页面时停止追踪
- 访问需要认证的页面时启动追踪

**7. `frontend/src/components/Layout.vue`**：
- 退出登录时停止活动追踪

**8. `frontend/src/modules/Dashboard.vue`、`Mail.vue`、`Profile.vue`**：
- 退出登录时停止活动追踪

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   git pull origin main
   # 或手动更新相关文件
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```
   - 会自动重新构建前端界面
   - 会自动部署到 Apache 目录

4. **重启调度层服务**（如果需要）：
   ```bash
   systemctl restart mail-ops-dispatcher
   ```

5. **验证更新**：
   - 测试注册页面验证码功能
   - 测试重置密码页面验证码功能
   - 测试登录页面验证码功能
   - 测试登录失败次数限制
   - 测试5分钟无操作自动退出功能
   - 测试SSL证书申请和IP访问功能

### ⚠️ 注意事项

- **验证码功能**：所有需要安全保护的操作（注册、重置密码、登录）都需要完成验证码验证
- **登录失败限制**：5次失败后会被锁定15分钟，请妥善保管账号密码
- **会话超时**：5分钟无操作会自动退出，请及时保存工作内容
- **SSL证书**：申请证书后会自动配置Apache，支持IP和域名访问HTTPS
- **根证书安装**：下载根证书后需要安装到操作系统或浏览器中，避免安全警告

---

## 📚 历史版本记录

## 🎉 V3.9.0 (2025-12-15) - 路径硬编码问题全面修复

### 🎊 版本亮点

**V3.9.0 是一个重要的系统架构改进版本，全面修复了所有硬编码路径问题，使系统支持任意文件夹名称部署，大大提升了部署的灵活性和可移植性。**

#### ✨ 动态路径支持

**路径硬编码修复**：
- **核心文件修复**：
  - `backend/dispatcher/server.js`：
    - 登录验证路径：从硬编码 `/bash` 改为使用 `ROOT_DIR` 变量
    - 系统设置文件路径：从硬编码 `/bash/config/system-settings.json` 改为使用 `path.join(ROOT_DIR, 'config', 'system-settings.json')`
    - 所有路径均基于 `__dirname` 动态解析，确保路径正确性
  - `backend/apache/systemd/mail-ops-dispatcher.service`：
    - `SCRIPTS_DIR` 环境变量：从硬编码 `/bash/backend/scripts` 改为使用 `${BASE_DIR}/backend/scripts`
    - `WorkingDirectory`：从硬编码 `/bash/backend/dispatcher` 改为使用 `${BASE_DIR}/backend/dispatcher`
    - 添加注释说明路径会被 `start.sh` 自动替换
  - `backend/scripts/dns_setup.sh`：
    - 添加 `BASE_DIR` 变量定义：`BASE_DIR=$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd || echo "/bash")`
    - 系统设置文件路径：从硬编码 `/bash/config/system-settings.json` 改为使用 `${BASE_DIR}/config/system-settings.json`
    - mail_db.sh 脚本路径：从硬编码 `/bash/backend/scripts/mail_db.sh` 改为使用 `${BASE_DIR}/backend/scripts/mail_db.sh`
  - `backend/scripts/mail_init.sh`：
    - 邮件监控脚本路径：从硬编码 `/bash/backend/scripts/mail_db.sh` 改为使用 `${BASE_DIR}/backend/scripts/mail_db.sh`
    - 使用变量替换 heredoc 中的路径
  - `backend/apache/sudoers.d/mailops`：
    - 所有脚本路径：从硬编码 `/e/bash/backend/scripts/...` 改为使用 `${BASE_DIR}/backend/scripts/...`
    - 添加注释说明路径会被动态替换
  - `start.sh`：
    - 部署 sudoers 文件时：从硬编码 `/bash/backend/scripts/...` 改为使用 `${BASE_DIR}/backend/scripts/...`
    - 部署 systemd 服务文件时：自动替换 `${BASE_DIR}` 为实际路径

**路径解析机制**：
- **动态路径获取**：
  - 所有脚本使用 `$(cd "$(dirname "$0")/../.." && pwd)` 获取项目根目录
  - Node.js 脚本使用 `path.resolve(__dirname, '..', '..')` 获取项目根目录
  - 确保路径解析的准确性和可靠性
- **回退机制**：
  - 保留 `/bash` 作为回退路径，当无法获取动态路径时使用
  - 确保在特殊情况下系统仍能正常工作
  - 不影响现有部署的稳定性

#### 📋 部署灵活性提升

**文件夹名称无关性**：
- **任意文件夹名称支持**：
  - 项目可以部署到任意名称的文件夹（如 `bash_M`、`mail-system`、`xm-mail` 等）
  - 不再限制文件夹必须命名为 `bash`
  - 支持多实例部署到不同文件夹
- **路径自动适配**：
  - 部署时自动检测项目根目录
  - 自动替换所有配置文件中的路径占位符
  - 无需手动修改任何配置文件

**部署改进**：
- **自动路径替换**：
  - `start.sh` 部署时自动检测 `BASE_DIR`
  - 自动替换 systemd 服务文件中的 `${BASE_DIR}` 占位符
  - 自动替换 sudoers 配置中的路径变量
  - 确保所有路径配置正确
- **部署验证**：
  - 部署后自动验证路径配置正确性
  - 检查 systemd 服务文件路径是否正确
  - 检查 sudoers 配置路径是否正确
  - 提供路径检查工具和诊断信息

#### 🔄 向后兼容性

**回退机制保留**：
- **路径回退**：
  - 所有脚本在无法获取动态路径时会回退到 `/bash`
  - 确保在特殊情况下系统仍能正常工作
  - 不影响现有部署的稳定性
- **现有部署兼容**：
  - 现有部署无需修改即可继续使用
  - 新部署自动使用动态路径
  - 支持平滑升级

### 📋 主要更新内容

#### 🔧 后端更新

**1. `backend/dispatcher/server.js`**：
- 登录验证路径：使用 `ROOT_DIR` 替代硬编码 `/bash`
- 系统设置文件路径：使用 `path.join(ROOT_DIR, 'config', 'system-settings.json')`
- 所有路径均基于 `__dirname` 动态解析

**2. `backend/apache/systemd/mail-ops-dispatcher.service`**：
- 使用 `${BASE_DIR}` 占位符替代硬编码路径
- 添加注释说明路径会被 `start.sh` 自动替换

**3. `backend/scripts/dns_setup.sh`**：
- 添加 `BASE_DIR` 变量定义
- 所有配置文件路径使用 `${BASE_DIR}` 变量
- 脚本路径使用 `${BASE_DIR}` 变量

**4. `backend/scripts/mail_init.sh`**：
- 邮件监控脚本路径使用 `${BASE_DIR}` 变量
- 使用变量替换 heredoc 中的路径

**5. `backend/apache/sudoers.d/mailops`**：
- 所有脚本路径使用 `${BASE_DIR}` 占位符
- 添加注释说明路径会被动态替换

#### 🛠️ 部署脚本更新

**`start.sh`**：
- 部署 systemd 服务文件时自动替换 `${BASE_DIR}` 为实际路径
- 部署 sudoers 文件时使用 `${BASE_DIR}` 变量
- 自动检测项目根目录并应用到所有配置

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   git pull origin main
   # 或手动更新相关文件
   ```

3. **重新部署（推荐）**：
   ```bash
   ./start.sh start
   ```
   - 会自动检测项目根目录
   - 会自动替换所有路径配置
   - 会自动重启相关服务

4. **或手动更新路径（如果文件夹已改名）**：
   ```bash
   # 获取当前项目路径
   CURRENT_DIR=$(pwd)
   
   # 更新 systemd 服务文件
   sudo sed -i "s|/bash|${CURRENT_DIR}|g" /etc/systemd/system/mail-ops-dispatcher.service
   sudo systemctl daemon-reload
   sudo systemctl restart mail-ops-dispatcher
   
   # 更新 sudoers 文件
   sudo sed -i "s|/bash|${CURRENT_DIR}|g" /etc/sudoers.d/mailops
   ```

5. **验证部署**：
   - 检查 systemd 服务状态：`systemctl status mail-ops-dispatcher`
   - 检查服务日志：`journalctl -u mail-ops-dispatcher -n 50`
   - 测试登录功能：访问 Web 管理界面并登录

### ⚠️ 注意事项

- **路径兼容性**：本次更新完全向后兼容，现有部署无需修改即可继续使用
- **文件夹改名**：如果要将项目文件夹改名，建议使用 `start.sh start` 重新部署
- **多实例部署**：现在支持在同一服务器上部署多个实例到不同文件夹
- **路径检查**：部署后可以使用 `./start.sh check` 检查路径配置是否正确

---

## 📚 历史版本记录

## 🎉 V3.8.3 (2025-12-15) - 图表功能优化与错误修复

### 🎊 版本亮点

**V3.8.3 是一个图表功能优化和错误修复版本，优化了发送频率分析图表的显示方式，改为混合图表（柱状图+折线图），显示用户名称，优化了发送频率的显示格式，修复了 Chart.js 混合图表配置错误和构建错误。**

#### ✨ 发送频率分析图表优化

**图表类型改进**：
- **混合图表设计**：
  - 将散点图改为混合图表（柱状图+折线图）
  - 柱状图显示邮件发送总量（紫色）
  - 折线图显示平均发送频率（蓝色）
  - 双Y轴设计：左侧显示邮件总量（封），右侧显示发送频率（封/天）
- **用户名称显示**：
  - 按用户分组时显示用户显示名称（display_name）
  - 关联 `mail_users` 表获取用户显示名称
  - 优先显示 `display_name`，如果没有则显示 `username`，最后显示邮箱
  - Tooltip中显示用户名称和邮箱地址（格式：`用户名 (email@domain.com)`）
- **数据单位优化**：
  - 发送频率显示格式优化：
    - 小于0.01：显示 "< 0.01"
    - 0.01-0.1：保留2位小数
    - 0.1-1：保留1位小数
    - 1-10：保留1位小数
    - 大于等于10：显示整数
  - Y轴刻度动态调整，根据数据范围自动优化步长
  - 工具提示显示"平均发送频率"，更符合语义

**技术实现**（backend/scripts/mail_db.sh）：
- **`get_email_frequency_analysis` 函数**：
  - 按用户统计时，关联 `mail_users` 表获取 `display_name`
  - 返回 `identifier`（显示名称）、`email`（邮箱地址）、`total_emails`、`frequency_per_day`
  - 使用 `COALESCE(mu.display_name, mu.username, e.from_addr)` 确保有显示名称

**前端实现**（frontend/src/modules/Dashboard.vue）：
- 混合图表配置（bar + line）
- 在数据集级别显式指定 `type`
- 用户名称和邮箱地址显示优化
- 频率显示格式优化

#### 📈 邮件发送趋势图表优化

**频率单位优化**：
- **动态单位显示**：
  - 按小时统计：显示封/小时
  - 按天统计：显示封/天（不再除以24，更直观）
  - 按周统计：显示封/天（平均每天）
- **后端计算优化**（backend/scripts/mail_db.sh）：
  - 根据时间周期计算合理的频率单位
  - 按小时：频率 = 邮件数量 / 1.0 = 封/小时
  - 按天：频率 = 邮件数量 / 1.0 = 封/天
  - 按周：频率 = 邮件数量 / 7.0 = 封/天（平均每天）
  - 返回 `frequency_unit` 字段标识单位类型

**显示格式优化**：
- **频率值格式化**：
  - 小于0.01：显示 "< 0.01"
  - 0.01-0.1：保留2位小数
  - 0.1-1：保留2位小数
  - 1-10：保留1位小数
  - 大于等于10：显示整数
- **图表标签和Y轴标题**：
  - 根据时间周期动态显示单位
  - Tooltip中显示对应单位的频率值

#### 🔧 Chart.js 错误修复

**混合图表配置**：
- **数据集类型显式指定**：
  - 第一个数据集：`type: 'bar'`（柱状图）
  - 第二个数据集：`type: 'line'`（折线图）
  - 主图表类型保持为 `'bar'`
- **配置优化**：
  - 为折线图添加 `fill: false` 避免填充问题
  - 优化点的大小、颜色、边框样式
  - 线条宽度和平滑度调整

**Canvas 上下文检查**：
- **DOM检查**：
  - 检查 Canvas 元素是否在 DOM 中
  - 如果不在 DOM 中，延迟500ms后重试
- **上下文检查**：
  - 检查 Canvas 上下文是否可用
  - 如果无法获取上下文，延迟500ms后重试
  - 添加 try-catch 错误处理

**错误处理优化**：
- **错误捕获**：
  - 完善的错误捕获和处理机制
  - 清理可能损坏的图表实例
  - 详细的错误日志记录（错误消息和堆栈）
- **自动重试**：
  - 错误时不抛出异常，避免中断执行
  - 在下次刷新时自动重试

#### 🐛 构建错误修复

**语法错误修复**：
- **重复属性修复**：
  - 修复重复的 `fill: false` 导致的构建错误
  - 确保代码语法正确

### 📋 主要更新内容

#### 🔧 后端更新（backend/scripts/mail_db.sh）

**1. `get_email_frequency_analysis` 函数**：
- 按用户统计时，关联 `mail_users` 表获取 `display_name`
- 返回 `identifier`（显示名称）、`email`（邮箱地址）
- 使用 `COALESCE(mu.display_name, mu.username, e.from_addr)` 确保有显示名称

**2. `get_email_sending_trends` 函数**：
- 根据时间周期计算合理的频率单位
- 返回 `frequency_unit` 字段标识单位类型
- 频率计算逻辑优化（按天不再除以24）

#### 🎨 前端更新（frontend/src/modules/Dashboard.vue）

**1. 发送频率分析图表**：
- 改为混合图表（bar + line）
- 在数据集级别显式指定 `type`
- 用户名称和邮箱地址显示优化
- 频率显示格式优化
- Y轴刻度动态调整

**2. 邮件发送趋势图表**：
- 频率单位动态显示
- 频率值格式化优化
- 图表标签和Y轴标题动态更新

**3. Chart.js 错误处理**：
- Canvas DOM 检查
- Canvas 上下文检查
- 完善的错误捕获和处理
- 自动重试机制

**4. BarController 注册**：
- 添加 `BarController` 到 Chart.js 导入和注册

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   git pull origin main
   # 或手动更新相关文件
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

4. **重启调度层服务**（如果修改了后端代码）：
   ```bash
   ./start.sh restart-dispatcher
   ```

5. **清除浏览器缓存**：
   - 按 `Ctrl+Shift+R` 强制刷新页面
   - 或清除浏览器缓存

6. **验证功能**：
   - 访问 Dashboard 页面
   - 查看发送频率分析图表是否正常显示（混合图表）
   - 测试按用户分组，查看是否显示用户名称
   - 查看邮件发送趋势图表，测试时间周期切换
   - 验证图表是否每30秒自动刷新

### ⚠️ 注意事项

- **数据库兼容性**：本次更新不需要数据库结构变更，完全向后兼容
- **前端依赖**：Chart.js 库已包含在依赖中，无需额外安装
- **浏览器兼容性**：需要支持 Canvas API 的现代浏览器
- **性能影响**：图表每30秒自动刷新，对服务器性能影响很小
- **用户显示名称**：如果用户没有设置 `display_name`，将显示 `username` 或邮箱地址

---

## 📚 历史版本记录

## 🎉 V3.8.2 (2025-12-15) - 邮件发送统计图表与数据可视化

### 🎊 版本亮点

**V3.8.2 是一个数据可视化增强版本，添加了邮件发送趋势图表和发送频率分析图表，使用 Chart.js 实现现代化的数据可视化，支持实时更新和多种数据展示方式，优化了数据单位显示，确保符合人类基本常识。**

#### ✨ 邮件发送趋势图表

**功能特性**：
- **折线图展示**：使用 Chart.js LineController 实现双折线图
- **双Y轴设计**：
  - 左侧Y轴：邮件发送数量（封），显示为整数
  - 右侧Y轴：发送频率（封/小时），显示为小数
- **时间周期切换**：
  - 小时：显示最近24小时的发送趋势
  - 天：显示最近30天的发送趋势（默认）
  - 周：显示最近12周的发送趋势
- **数据去重**：使用 `base_message_id` 去重，确保每封邮件只统计一次
- **实时更新**：每30秒自动刷新数据

**技术实现**（backend/scripts/mail_db.sh）：
- **`get_email_sending_trends` 函数**：
  - 使用 MySQL JSON 函数直接返回 JSON 格式
  - 支持按小时/天/周统计
  - 计算发送频率（封/小时）

**前端实现**（frontend/src/modules/Dashboard.vue）：
- Chart.js 集成和组件注册
- 响应式图表容器
- 时间周期切换按钮
- 加载状态和空数据状态显示

#### 📈 发送频率分析图表

**功能特性**：
- **散点图展示**：使用 Chart.js ScatterController 实现散点图
- **分组方式**：
  - 按用户：显示每个用户的发送频率和发送总量关系
  - 按天：显示每天的发送频率和发送总量关系
- **数据单位优化**：
  - X轴：发送频率（封/天），刻度以1为单位
  - Y轴：邮件发送总量（封），显示为整数
- **工具提示**：显示用户/日期、发送频率、发送总量

**技术实现**（backend/scripts/mail_db.sh）：
- **`get_email_frequency_analysis` 函数**：
  - 按用户统计：计算每个用户平均每天发送的邮件数
  - 按天统计：频率等于当天的邮件数量
  - 使用 MySQL JSON 函数返回 JSON 格式

**前端实现**（frontend/src/modules/Dashboard.vue）：
- 散点图数据映射和处理
- 分组方式切换按钮
- 数据验证和错误处理

#### 🔄 实时更新功能

**自动刷新机制**：
- **定时刷新**：每30秒自动刷新图表数据
- **立即更新**：切换时间周期或分组方式时立即更新
- **资源管理**：组件卸载时清除定时器，避免内存泄漏

**空数据状态**：
- **友好提示**：显示"暂无数据"提示和图标
- **自动刷新说明**：提示用户图表将自动刷新
- **图表框架**：即使没有数据也显示图表框架

#### 🎨 Chart.js 集成

**组件注册**：
- LineController：折线图控制器
- ScatterController：散点图控制器
- CategoryScale、LinearScale：坐标轴
- PointElement、LineElement：图表元素
- Title、Tooltip、Legend、Filler：图表插件

**错误处理**：
- Canvas 元素存在性检查
- 图表创建错误捕获
- 详细的调试日志

### 📋 主要更新内容

#### 🔧 后端更新（backend/scripts/mail_db.sh）

**1. `get_email_sending_trends` 函数**：
- 使用 MySQL JSON 函数直接返回 JSON 格式
- 支持按小时/天/周统计
- 计算发送频率（封/小时）

**2. `get_email_frequency_analysis` 函数**：
- 频率单位改为封/天
- 按用户统计：计算平均每天发送的邮件数
- 按天统计：频率等于邮件数量
- 使用 MySQL JSON 函数返回 JSON 格式

#### 🎨 前端更新（frontend/src/modules/Dashboard.vue）

**1. Chart.js 集成**：
- 导入和注册所有必需的组件
- 添加 ArcElement 支持
- 完善的错误处理

**2. 图表组件**：
- 邮件发送趋势图表（折线图）
- 发送频率分析图表（散点图）
- 响应式布局和样式优化

**3. 数据单位优化**：
- 邮件数量使用 `Math.round()` 确保整数显示
- Y轴刻度 `stepSize: 1`，以1为单位
- 工具提示显示整数邮件数量

**4. 实时更新**：
- 定时刷新机制（30秒）
- 组件卸载时清除定时器
- 空数据状态显示

#### 📦 依赖更新（frontend/package.json）

**新增依赖**：
- `chart.js`: ^4.4.0 - 图表库

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   git pull origin main
   # 或手动更新相关文件
   ```

3. **安装前端依赖**：
   ```bash
   cd frontend
   npm install chart.js
   cd ..
   ```

4. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

5. **重启调度层服务**（如果修改了后端代码）：
   ```bash
   ./start.sh restart-dispatcher
   ```

6. **清除浏览器缓存**：
   - 按 `Ctrl+Shift+R` 强制刷新页面
   - 或清除浏览器缓存

7. **验证功能**：
   - 访问 Dashboard 页面
   - 查看邮件发送趋势图表是否正常显示
   - 测试时间周期切换功能
   - 查看发送频率分析图表是否正常显示
   - 测试分组方式切换功能
   - 验证图表是否每30秒自动刷新

### ⚠️ 注意事项

- **数据库兼容性**：本次更新不需要数据库结构变更，完全向后兼容
- **前端依赖**：需要安装 Chart.js 库，已包含在 `start.sh rebuild` 流程中
- **浏览器兼容性**：需要支持 Canvas API 的现代浏览器
- **性能影响**：图表每30秒自动刷新，对服务器性能影响很小

---

## 📚 历史版本记录

## 🎉 V3.8.1 (2025-12-14) - 邮件未读计数修复与用户体验优化

### 🎊 版本亮点

**V3.8.1 是一个核心功能修复和用户体验优化版本，全面修复了邮件未读计数的独立性问题，确保每个用户看到的是自己的未读数量，修复了已发送和收件箱未读计数的区分问题，优化了前端刷新体验，并添加了优美的删除确认对话框UI。**

#### ✨ 邮件未读计数核心修复

**问题背景**：
- 每个用户的未读计数不独立，导致多个用户看到相同的未读数量
- 同一封邮件发送给多个用户时，未读计数被重复统计
- 已发送文件夹的未读计数影响了收件箱的未读统计
- `base_message_id` 提取逻辑不一致，导致查询结果错误
- 子查询中缺少文件夹过滤，导致跨文件夹影响统计

**解决方案**：

**1. 独立用户计数修复**（backend/scripts/mail_db.sh）：

**`get_mail_stats` 函数优化**：
- **收件箱统计**：
  - 使用 `base_message_id` 去重，确保每封邮件只统计一次
  - 使用 `MIN(er.is_read)` 获取每个用户的最小已读状态
  - 添加 `e2.folder_id = e.folder_id` 条件，只考虑相同文件夹的记录
  - 确保只统计当前用户是收件人的邮件
- **已发送文件夹统计**：
  - 明确设置 `unread = 0` 和 `read_count = 0`
  - 只统计总数和总大小，不显示未读/已读数量
- **垃圾邮件和已删除文件夹统计**：
  - 同样添加 `folder_id` 过滤条件
  - 确保只考虑相同文件夹的记录

**`get_emails` 函数优化**：
- **`read` 和 `read_status` 字段计算**：
  - 使用 `CASE` 语句区分已发送和收件箱
  - 已发送：使用 `emails.read_status` 字段
  - 收件箱：使用子查询获取 `MIN(er2.is_read)`，添加 `e3.folder_id = e.folder_id` 条件
- **用户邮箱匹配条件**：
  - 构建 `user_email_condition` 变量，支持完整邮箱地址和用户名匹配
  - 特殊处理 `xm` 用户，支持多种邮箱格式

**`search_emails` 函数优化**：
- **添加 `user_email_condition` 构建逻辑**：
  - 与 `get_emails` 函数保持一致的用户邮箱匹配逻辑
- **修复 `read` 和 `read_status` 字段**：
  - 使用与列表查询相同的 `CASE` 语句
  - 添加 `folder_id` 过滤条件

**2. `base_message_id` 提取逻辑修复**：

**问题**：
- `mark_email_read` 和 `get_email_detail` 函数使用 `sed 's/_[^_]*$//'` 提取 `base_message_id`
- 查询中使用 `SUBSTRING_INDEX(message_id, '_', 1)`，两者不一致

**解决方案**：
- 统一使用 `cut -d'_' -f1` 提取 `base_message_id`
- 与查询中的 `SUBSTRING_INDEX(message_id, '_', 1)` 保持一致
- 修复了 `mark_email_read` 和 `get_email_detail` 两个函数

**3. `mark_email_read` 函数优化**：

**别名问题修复**：
- 在 UPDATE 语句中使用 `$user_email_condition` 前，先将 `er_user.` 替换为 `er.`
- 因为 UPDATE 语句中的别名是 `er`，而不是 `er_user`

**文件夹区分**：
- 收件箱（folder_id=1）：更新 `email_recipients.is_read` 状态
- 已发送（folder_id=2）：更新 `emails.read_status` 状态
- 确保查看已发送不会影响收件箱的未读计数

#### 🎨 用户体验优化

**问题背景**：
- 点击邮件后强制刷新整个邮件列表，导致页面闪烁
- 删除邮件时使用浏览器默认 `confirm` 对话框，不够美观
- 已读状态更新有延迟，用户体验不够流畅

**解决方案**：

**1. 前端刷新优化**（frontend/src/modules/Mail.vue）：

**`openEmail` 函数优化**：
- **移除重复的 `mark_read` API 调用**：
  - `get_email_detail` API 已经会标记为已读，无需再次调用
- **立即更新本地状态**：
  - 获取邮件详情后立即更新邮件列表和选中邮件的状态
  - 不需要等待，提升响应速度
- **异步更新统计**：
  - 使用 100ms 延迟异步更新未读计数，不阻塞UI
  - 移除了 300ms 的等待时间

**2. 删除确认对话框UI改进**（frontend/src/modules/Mail.vue）：

**自定义对话框设计**：
- **背景遮罩**：
  - 半透明黑色背景（`bg-black/40`）
  - 模糊效果（`backdrop-blur-sm`）
- **对话框卡片**：
  - 白色背景，圆角设计（`rounded-2xl`）
  - 阴影效果（`shadow-2xl`）
  - 顶部渐变装饰条（红色→橙色→红色）
- **图标和标题**：
  - 红色圆形图标容器
  - 清晰的标题和说明文字
- **警告提示框**：
  - 琥珀色背景（`bg-amber-50`）
  - 警告图标和详细说明
- **按钮组**：
  - 取消按钮：灰色边框，白色背景
  - 确认删除按钮：红色渐变背景，带图标
  - 悬停效果和过渡动画

**过渡动画**：
- 使用 Vue `Transition` 组件实现淡入淡出效果
- 对话框缩放和位移动画
- 平滑的过渡效果

**函数重构**：
- `showDeleteConfirmDialog`：显示确认对话框
- `confirmDeleteEmail`：确认删除并执行删除操作
- `cancelDeleteEmail`：取消删除并关闭对话框

### 📋 主要修复内容

#### 🔧 后端修复（backend/scripts/mail_db.sh）

**1. `get_mail_stats` 函数**：
- 收件箱统计：添加 `e2.folder_id = e.folder_id` 条件
- 已发送统计：明确设置 `unread = 0`
- 垃圾邮件和已删除统计：添加 `folder_id` 过滤

**2. `get_emails` 函数**：
- `read` 和 `read_status` 字段：添加 `e3.folder_id = e.folder_id` 条件
- 用户邮箱匹配：构建 `user_email_condition` 变量

**3. `search_emails` 函数**：
- 添加 `user_email_condition` 构建逻辑
- 修复 `read` 和 `read_status` 字段计算

**4. `mark_email_read` 函数**：
- 修复别名问题：`er_user.` → `er.`
- 修复 `base_message_id` 提取：`cut -d'_' -f1`

**5. `get_email_detail` 函数**：
- 修复 `base_message_id` 提取：`cut -d'_' -f1`
- 添加 `folder_id` 过滤条件

#### 🎨 前端优化（frontend/src/modules/Mail.vue）

**1. `openEmail` 函数**：
- 移除 `mark_read` API 调用
- 立即更新本地状态
- 异步更新统计（100ms延迟）

**2. 删除确认对话框**：
- 添加 `showDeleteConfirm` 和 `emailToDelete` 状态变量
- 创建自定义对话框UI组件
- 添加过渡动画样式

**3. 函数重构**：
- `showDeleteConfirmDialog`：显示对话框
- `confirmDeleteEmail`：执行删除
- `cancelDeleteEmail`：取消删除

### 🚀 升级步骤

1. **备份当前系统**：
   ```bash
   ./start.sh backup
   ```

2. **更新代码**：
   ```bash
   git pull origin main
   # 或手动更新相关文件
   ```

3. **重启调度层服务**（如果修改了后端代码）：
   ```bash
   ./start.sh restart-dispatcher
   ```

4. **清除浏览器缓存**（如果修改了前端代码）：
   - 按 `Ctrl+Shift+R` 强制刷新页面
   - 或清除浏览器缓存

5. **验证功能**：
   - 测试邮件未读计数是否正确
   - 测试点击邮件后是否流畅更新
   - 测试删除邮件确认对话框是否正常显示

### ⚠️ 注意事项

- **数据库兼容性**：本次更新不需要数据库结构变更，完全向后兼容
- **缓存问题**：如果前端更新后看不到效果，请清除浏览器缓存
- **性能影响**：优化后的刷新逻辑减少了不必要的API调用，提升了性能

---

## V3.8.0 (2025-12-13) - 文档完善与架构说明优化

### 🎊 版本亮点

**V3.8.0 是一个文档完善与架构说明优化版本，全面重构了README.md文档，完善了系统架构说明，优化了目录结构，使文档内容与实际项目完全一致，提升了文档的可读性和实用性。**

#### 📖 文档全面更新

**问题背景**：
- README.md文档内容与实际项目存在差异
- 系统架构说明不够详细和准确
- 快速开始、命令参考、功能特性等部分需要更新
- 目录结构不完整，缺少部分文件和目录说明

**解决方案**：

**1. README.md 全面重构**：

**系统架构部分更新**：
- **架构图更新**：
  - 更新为7层架构图（用户访问层、Web服务层、应用服务层、业务逻辑层、邮件服务层、数据存储层、基础设施层）
  - 详细展示各层之间的交互关系和数据流向
  - 添加架构说明，解释各层职责和技术选型
- **技术栈详解**：
  - 更新所有技术栈版本信息（Vue 3、Node.js、Express、Tailwind CSS等）
  - 添加19个Bash脚本的详细分类和功能说明
  - 完善数据库架构说明（15张表的详细分布：maildb 13张表 + mailapp 2张表）

**快速开始部分更新**：
- **系统要求完善**：
  - 添加硬件要求（CPU、内存、磁盘、网络）
  - 添加软件要求（操作系统、权限、网络）
- **默认账户信息**：
  - 详细说明Web管理界面登录账户
  - 说明系统用户和数据库用户信息
  - 说明数据库密码存储位置和读取方式
- **安装步骤完善**：
  - 更新为6步安装流程
  - 添加首次配置建议（DNS配置、SSL证书、邮件域名、邮件用户）

**命令参考部分更新**：
- **根据实际start.sh命令更新**：
  - 部署与管理命令（start、check、rebuild、status、restart、stop、restart-dispatcher）
  - 日志查看命令（系统日志、邮件日志，包含所有选项和过滤功能）
  - 故障排除命令（fix-auth、fix-db、fix-dispatcher）
  - 帮助命令（help）
- **添加命令使用示例**：
  - 部署与管理示例
  - 日志查看示例
  - 故障排除示例

**功能特性部分更新**：
- **核心功能模块**：
  - 详细列出7大核心功能模块（邮件服务管理、用户与域管理、系统管理、安全功能、备份与恢复、DNS配置管理、系统监控）
  - 每个模块列出详细功能点
- **管理界面功能**：
  - 完整列出所有页面和功能点
  - 邮件管理界面（Mail.vue）
  - 管理面板（Dashboard.vue）
  - 日志查看器（Layout.vue）
  - 系统设置（Settings.vue）
  - 个人资料（Profile.vue）

**技术架构部分更新**：
- **系统架构层次**：
  - 详细说明7层架构（表现层、代理层、调度层、业务逻辑层、邮件服务层、数据存储层、基础设施层）
  - 每层详细说明技术栈和功能
- **数据流架构**：
  - 用户操作流程
  - 邮件收发流程
  - 认证流程
- **安全架构**：
  - 多层安全防护说明
  - 权限管理说明

**目录结构部分更新**：
- **完整目录结构**：
  - 更新为完整的目录树结构
  - 包含所有19个Bash脚本文件
  - 包含所有配置文件和目录
  - 添加详细的文件功能说明注释
- **目录说明**：
  - 添加"目录说明"章节
  - 解释各个目录的用途和内容

**2. 目录结构优化**：
- **删除冗余文件**：
  - 删除`frontend/README.md`文件（内容已过时）
  - 更新目录结构说明，移除对该文件的引用
- **目录结构完善**：
  - 添加根目录`config/`目录说明（系统设置配置）
  - 添加`mail_CX.sh`文件说明（邮件系统检测工具）
  - 添加所有前端页面组件说明（包括Settings.vue和Profile.vue）

#### 🏗️ 架构说明完善

**系统架构图更新**：
- **7层架构图**：
  - 用户访问层：Web浏览器、邮件客户端、移动设备
  - Web服务层：Apache静态文件服务和API反向代理
  - 应用服务层：Node.js Express调度层
  - 业务逻辑层：19个Bash脚本
  - 邮件服务层：Postfix + Dovecot
  - 数据存储层：MariaDB双数据库架构（15张表）
  - 基础设施层：DNS、systemd、日志系统
- **架构说明**：
  - 详细说明各层职责和技术选型
  - 说明各层之间的交互关系

**技术栈详解**：
- **前端层**：Vue 3 + TypeScript + Tailwind CSS + Vite
- **代理层**：Apache HTTP Server 2.4+
- **调度层**：Node.js 20.x (v20.20.0 LTS Iron) + Express.js 4.19.2
- **邮件服务层**：Postfix + Dovecot + MariaDB
- **Bash脚本层**：19个脚本，详细分类和功能说明
- **数据存储层**：MariaDB双数据库架构（maildb 13张表 + mailapp 2张表）
- **基础设施层**：Rocky Linux 9 + systemd + Bind DNS

#### 📋 主要更新内容

**文档更新**：
1. **README.md**：
   - 系统架构部分全面更新（7层架构图、架构说明、技术栈详解）
   - 快速开始部分完善（系统要求、默认账户信息、安装步骤、首次配置建议）
   - 命令参考部分更新（根据实际start.sh命令更新完整命令列表和使用示例）
   - 功能特性部分更新（详细列出所有核心功能模块和管理界面功能）
   - 技术架构部分更新（系统架构层次、数据流架构、安全架构）
   - 目录结构部分更新（完整目录结构、目录说明）
   - 版本历史部分更新（添加V3.8.0版本信息）

2. **目录结构优化**：
   - 删除`frontend/README.md`文件
   - 更新目录结构说明，移除对该文件的引用

**文档改进**：
- 文档内容与实际项目完全一致
- 所有功能说明和命令参考都基于实际代码
- 架构说明更加详细和准确
- 目录结构完整且准确

#### 🔄 升级步骤

**从 V3.7.3 或更早版本升级到 V3.8.0**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份文档文件
   cp README.md README.md.backup
   cp UPDATE_GUIDE.md UPDATE_GUIDE.md.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码（如果使用Git）
   git pull origin main
   
   # 或手动更新README.md和UPDATE_GUIDE.md文件
   ```

3. **验证更新**：
   ```bash
   # 检查文档文件是否存在
   ls -la README.md UPDATE_GUIDE.md
   
   # 检查目录结构是否正确
   ls -la frontend/ | grep README.md  # 应该不存在
   ```

4. **完成升级**：
   - 文档更新完成，无需重启服务
   - 可以查看新的README.md了解系统架构和功能特性

#### ⚠️ 注意事项

- **文档更新**：本次更新主要是文档完善，不涉及代码和功能变更
- **向后兼容**：完全向后兼容，不影响现有功能
- **无需操作**：无需执行任何系统操作，仅需更新文档文件

---

## 📋 历史版本记录

## 🎉 V3.7.3 (2025-12-13) - 用户界面优化与体验提升

### 🎊 版本亮点

**V3.7.3 是一个用户界面优化与体验提升版本，完善了日志查看器的显示格式和解析功能，改进了广播确认对话框的UI设计，提升了系统的用户体验和界面美观度。**

#### ✨ 日志查看器完善

**问题背景**：
- 日志显示格式不够友好，时间戳格式不够直观
- 日志消息中的操作类型和详细信息无法自动提取
- 日志图标显示不够丰富，无法快速识别操作类型
- 日志统计信息显示不够清晰

**解决方案**：

**1. 日志显示格式优化**（frontend/src/components/Layout.vue）：
- **时间戳格式改进**：
  - 将时间戳格式从 `toLocaleString('zh-CN')` 改为 `[YYYY/MM/DD HH:mm:ss]`
  - 更符合中文用户习惯，更易读
- **日志文件名简化**：
  - 显示简化的日志文件名（如 `mail-operations.log`）
  - 使用颜色区分不同日志源
- **详细信息展示**：
  - 自动提取并显示 Email、Folder、Limit、Offset 等信息
  - 使用图标和颜色区分不同类型的信息

**2. 日志解析增强**：
- **新增 `parseLogMessage()` 函数**：
  - 智能解析日志消息，提取操作类型（如 `MAIL_LIST`、`MAIL_SEND`）
  - 自动提取 Email 地址、Folder 信息、Limit 和 Offset 参数
  - 支持多种日志格式的解析
- **操作类型识别**：
  - 优先使用解析出的操作类型
  - 如果无法解析，使用日志类型或默认值
- **图标映射优化**：
  - 根据操作类型显示对应图标（📧、📤、📥、📁、🔐等）
  - 支持多种操作类型的图标映射

**3. 用户体验优化**：
- **自动滚动**：日志加载后自动滚动到最新日志
- **未知日志标记**：为无法正确分类的日志添加特殊标记和警告提示
- **统计信息改进**：优化日志统计信息的显示格式和更新机制

#### 🎨 广播确认对话框UI改进

**问题背景**：
- 使用原生 `confirm` 对话框，UI 不够美观
- 缺少视觉反馈和操作提示
- 无法显示当前广播消息预览

**解决方案**：

**1. 自定义确认对话框**（frontend/src/modules/Dashboard.vue）：
- **顶部渐变装饰条**：
  - 红色→橙色→黄色的渐变效果
  - 提升视觉吸引力和警告感
- **删除图标设计**：
  - 圆形背景，渐变配色（红色到橙色）
  - 垃圾桶图标，清晰表达删除操作
- **警告提示框**：
  - 橙色主题，包含警告图标
  - 明确说明操作不可撤销
  - 详细的操作说明文字
- **消息预览**：
  - 显示当前广播消息内容
  - 帮助用户确认要清除的内容

**2. 交互体验优化**：
- **动画效果**：
  - 使用 `animate-scale-in` 和 `animate-fade-in` 动画
  - 流畅的对话框出现和消失效果
- **按钮设计**：
  - 取消按钮：白色背景，灰色边框
  - 确认按钮：红色到橙色渐变，悬停效果和阴影
  - 加载状态：显示加载动画和"清除中..."文字
- **响应式设计**：
  - 支持移动端和桌面端
  - 按钮布局自适应屏幕大小

#### 📋 主要更新内容

**前端更新**：
1. **Layout.vue**：
   - 新增 `parseLogMessage()` 函数解析日志消息
   - 改进 `updateLogDisplay()` 函数优化日志显示格式
   - 优化日志图标映射和颜色方案
   - 添加自动滚动和未知日志标记功能

2. **Dashboard.vue**：
   - 新增 `showClearBroadcastConfirm` 状态变量
   - 新增 `showClearBroadcastConfirmDialog()` 函数显示确认对话框
   - 修改 `clearBroadcast()` 为 `confirmClearBroadcast()` 执行清除操作
   - 添加自定义确认对话框UI组件

#### 🚀 升级步骤

**从 V3.7.2 或更早版本升级到 V3.7.3**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端文件
   cp -r frontend frontend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新以下文件：
   # - frontend/src/components/Layout.vue
   # - frontend/src/modules/Dashboard.vue
   ```

3. **重新构建前端**：
   ```bash
   cd frontend
   npm install  # 如果需要更新依赖
   npm run build
   ```

4. **部署前端**：
   ```bash
   # 使用 start.sh 重建前端
   ./start.sh rebuild
   # 或手动复制
   cp -r frontend/dist/* /var/www/mail-frontend/
   ```

5. **验证功能**：
   - 打开日志查看器，检查日志显示格式是否正确
   - 测试广播消息清除功能，检查确认对话框是否正常显示
   - 验证日志解析功能是否正常工作

#### 📋 实现细节

**日志解析函数**：
```typescript
// frontend/src/components/Layout.vue
const parseLogMessage = (message) => {
  const parsed = {
    operation: 'unknown',
    email: '',
    folder: '',
    limit: '',
    offset: '',
    details: {}
  }
  
  // 提取操作类型
  const operationMatch = message.match(/\[([A-Z_]+)\]/)
  if (operationMatch) {
    parsed.operation = operationMatch[1]
  }
  
  // 提取 Email、Folder、Limit、Offset 等信息
  // ...
  
  return parsed
}
```

**确认对话框组件**：
```vue
<!-- frontend/src/modules/Dashboard.vue -->
<div v-if="showClearBroadcastConfirm" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-4">
  <div class="relative bg-white rounded-2xl shadow-2xl w-full max-w-md transform transition-all duration-300 scale-100 animate-scale-in">
    <!-- 顶部渐变装饰条 -->
    <div class="h-1 bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 rounded-t-2xl"></div>
    <!-- 对话框内容 -->
    <!-- ... -->
  </div>
</div>
```

#### 🔧 故障排除

**如果日志显示格式不正确**：
- 检查浏览器控制台是否有 JavaScript 错误
- 验证日志数据格式是否符合预期
- 检查 `parseLogMessage()` 函数是否正确解析日志消息

**如果确认对话框不显示**：
- 检查 `showClearBroadcastConfirm` 状态变量是否正确设置
- 验证对话框组件是否正确渲染
- 检查 CSS 动画类是否正确定义

**如果前端构建失败**：
- 检查 Node.js 版本是否符合要求（Node.js 20.x，推荐 v20.20.0 LTS Iron）
- 清理 node_modules 和重新安装依赖：`rm -rf node_modules && npm install`
- 检查 TypeScript 和 Vue 版本兼容性

#### 🎨 用户体验提升

- ✅ **日志显示优化**：更友好的时间格式和详细信息展示
- ✅ **日志解析增强**：自动提取操作类型和详细信息
- ✅ **图标映射丰富**：根据操作类型显示对应图标
- ✅ **确认对话框美化**：渐变装饰、警告提示、消息预览
- ✅ **动画效果流畅**：scale-in 和 fade-in 动画
- ✅ **响应式设计**：支持移动端和桌面端

---

## 📋 历史版本 - V3.7.2 (2025-12-13) - 数据库密码安全增强

### 🎊 版本亮点

**V3.7.2 是一个数据库密码安全增强版本，将 maildb 数据库密码从固定密码改为随机生成，统一密码管理方式，提高系统安全性。**

#### ✨ 数据库密码随机生成

**问题背景**：
- maildb 数据库使用固定密码 `mailpass`，存在安全风险
- mailapp 数据库已使用随机密码，但 maildb 仍使用固定密码
- 密码管理方式不统一，不利于安全维护

**解决方案**：

**1. 密码生成优化**（start.sh）：
- **随机密码生成**：
  - 使用 `openssl rand -base64 24` 或 `head -c 24 /dev/urandom | base64` 生成随机 Base64 密码
  - 仅在密码文件不存在时生成，保留现有密码文件
  - 密码文件路径：`/etc/mail-ops/mail-db.pass`
- **权限设置**：
  - 文件权限设置为 `640`（root:xm）
  - xm 用户可以读取密码文件，用于调度层服务
- **数据库用户创建**：
  - 数据库用户创建时自动从密码文件读取密码
  - 包含 `ALTER USER` 语句确保密码与文件一致

**2. 脚本密码读取统一**（backend/scripts/）：
- **db_setup.sh**：
  - 优先从 `/etc/mail-ops/mail-db.pass` 读取密码
  - 如果文件不存在，使用默认值 `mailpass`（向后兼容）
- **user_manage.sh**：
  - 优先从密码文件读取密码
  - 支持向后兼容默认值
- **mail_setup.sh**：
  - Postfix 配置文件（3个）从密码文件读取密码
  - Dovecot 配置文件从密码文件读取密码
  - 域名更新逻辑从密码文件读取密码
- **app_user.sh**：
  - 新增 `get_maildb_password()` 函数统一密码读取
  - 替换所有硬编码密码为函数调用
  - 支持向后兼容默认值

**3. API 密码读取统一**（backend/dispatcher/server.js）：
- **新增 `getMailDbPassword()` 函数**：
  - 从 `/etc/mail-ops/mail-db.pass` 文件读取密码
  - 支持环境变量 `MAIL_DB_PASS` 覆盖
  - 如果文件不存在，使用默认值 `mailpass`（向后兼容）
- **替换所有硬编码密码**：
  - 替换所有 `mysql -u mailuser -pmailpass` 为从密码文件读取
  - 包括 bash 脚本块中的密码处理
  - 统一密码转义处理，防止特殊字符问题

#### 📋 主要更新内容

**密码生成**：
1. **start.sh**：
   - 密码生成逻辑改为随机生成
   - 数据库用户创建语句更新为从密码文件读取
   - 添加 `ALTER USER` 语句确保密码一致性

**脚本更新**：
1. **db_setup.sh**：优先从密码文件读取密码
2. **user_manage.sh**：优先从密码文件读取密码
3. **mail_setup.sh**：Postfix 和 Dovecot 配置从密码文件读取
4. **app_user.sh**：新增密码读取函数，替换所有硬编码密码

**API 更新**：
1. **server.js**：新增密码读取函数，替换所有硬编码密码

#### 🚀 升级步骤

**从 V3.7.1 或更早版本升级到 V3.7.2**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端和后端文件
   cp -r frontend frontend.backup
   cp -r backend backend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新以下文件：
   # - start.sh
   # - backend/dispatcher/server.js
   # - backend/scripts/db_setup.sh
   # - backend/scripts/user_manage.sh
   # - backend/scripts/mail_setup.sh
   # - backend/scripts/app_user.sh
   ```

3. **生成新密码**（首次安装或需要更新密码）：
   ```bash
   # 如果密码文件不存在，start.sh 会自动生成
   # 如果需要更新密码，可以手动生成：
   openssl rand -base64 24 > /etc/mail-ops/mail-db.pass
   chown root:xm /etc/mail-ops/mail-db.pass
   chmod 640 /etc/mail-ops/mail-db.pass
   
   # 更新数据库用户密码
   mysql -u root -e "ALTER USER 'mailuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/mail-db.pass)';"
   ```

4. **更新 Postfix 和 Dovecot 配置**（如果已安装）：
   ```bash
   # 重新运行 mail_setup.sh 以更新配置文件
   bash backend/scripts/mail_setup.sh configure
   # 或重启服务让配置生效
   systemctl restart postfix dovecot
   ```

5. **重启服务**：
   ```bash
   ./start.sh restart
   # 或单独重启调度层服务
   systemctl restart mail-ops-dispatcher
   ```

6. **验证功能**：
   - 检查密码文件是否存在：`ls -l /etc/mail-ops/mail-db.pass`
   - 检查密码文件权限：应该是 `640`，所有者 `root:xm`
   - 测试数据库连接：`mysql -u mailuser -p$(cat /etc/mail-ops/mail-db.pass) maildb -e "SELECT 1;"`
   - 检查 Postfix 和 Dovecot 配置是否包含正确密码

#### 📋 实现细节

**密码生成逻辑**：
```bash
# start.sh
if [[ ! -f /etc/mail-ops/mail-db.pass ]]; then
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -base64 24 > /etc/mail-ops/mail-db.pass
  else
    head -c 24 /dev/urandom | base64 > /etc/mail-ops/mail-db.pass
  fi
fi
chown root:xm /etc/mail-ops/mail-db.pass
chmod 640 /etc/mail-ops/mail-db.pass
```

**脚本密码读取**：
```bash
# backend/scripts/app_user.sh
get_maildb_password() {
  if [[ -f /etc/mail-ops/mail-db.pass ]]; then
    cat /etc/mail-ops/mail-db.pass
  else
    echo "mailpass"  # 向后兼容默认值
  fi
}
```

**API 密码读取**：
```javascript
// backend/dispatcher/server.js
function getMailDbPassword() {
  try {
    if (fs.existsSync(MAIL_DB_PASS_FILE)) {
      return fs.readFileSync(MAIL_DB_PASS_FILE, 'utf8').trim()
    }
  } catch (error) {
    console.error('Failed to read mail-db.pass file:', error.message)
  }
  return process.env.MAIL_DB_PASS || 'mailpass'  // 向后兼容
}
```

#### 🔧 故障排除

**如果密码文件不存在**：
- 系统会自动使用默认值 `mailpass`（向后兼容）
- 首次安装时，`start.sh` 会自动生成密码文件
- 可以手动创建密码文件：`openssl rand -base64 24 > /etc/mail-ops/mail-db.pass`

**如果数据库连接失败**：
- 检查密码文件权限：`ls -l /etc/mail-ops/mail-db.pass`
- 检查密码文件内容：`cat /etc/mail-ops/mail-db.pass`
- 更新数据库用户密码：`mysql -u root -e "ALTER USER 'mailuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/mail-db.pass)';"`

**如果 Postfix/Dovecot 配置错误**：
- 重新运行 `mail_setup.sh configure` 更新配置
- 检查配置文件中的密码是否正确：`grep password /etc/postfix/mysql-*.cf`
- 检查 Dovecot 配置：`grep password /etc/dovecot/dovecot-sql.conf.ext`

#### 🔒 安全性提升

- ✅ **密码随机生成**：使用加密安全的随机数生成器
- ✅ **密码文件权限**：`640` 权限，只有 root 和 xm 用户可以读取
- ✅ **统一密码管理**：maildb 和 mailapp 数据库使用相同的密码管理方式
- ✅ **向后兼容**：支持密码文件不存在的情况，使用默认值
- ✅ **无硬编码密码**：所有脚本和 API 都从密码文件读取（除向后兼容默认值）

---

## 📋 历史版本 - V3.7.1 (2025-12-13) - 文件夹管理功能修复

### 🎊 版本亮点

**V3.7.1 是一个文件夹管理功能修复版本，修复了创建自定义文件夹后不显示的问题，解决了用户ID映射不一致和参数传递错误的问题，确保文件夹管理功能正常工作。**

#### ✨ 文件夹显示问题修复

**问题背景**：
- 创建自定义文件夹后，文件夹不显示在列表中
- 查询文件夹时只返回系统文件夹，不返回用户自定义文件夹
- `app_users` 表和 `mail_users` 表用户ID不一致
- `main` 函数中 `folders` 命令未传递 `user_id` 参数

**解决方案**：

**1. 用户ID映射优化**（backend/dispatcher/server.js）：
- **新增 `getMailUserIdFromUsername` 函数**：
  - 从 `mail_users` 表获取用户ID（而不是 `app_users` 表）
  - 如果用户不存在，自动调用 `createMailUserFromUsername` 创建用户
- **新增 `createMailUserFromUsername` 函数**：
  - 从 `app_users` 表获取用户邮箱信息
  - 在 `mail_users` 表中创建用户记录（如果不存在）
  - 使用 `ON DUPLICATE KEY UPDATE` 确保幂等性
- **统一用户ID使用**：
  - 创建文件夹API（`POST /api/mail/folders`）使用 `getMailUserIdFromUsername`
  - 查询文件夹API（`GET /api/mail/folders`）使用 `getMailUserIdFromUsername`
  - 确保创建和查询使用相同的用户ID

**2. 脚本参数传递修复**（backend/scripts/mail_db.sh）：
- **修复 `main` 函数参数传递**：
  ```bash
  # 修复前
  "folders")
    get_folders    # ❌ 没有传递 $2 参数
    ;;
  
  # 修复后
  "folders")
    get_folders "$2"    # ✅ 传递 $2 参数（user_id）
    ;;
  ```
- **改进 MySQL 查询输出处理**：
  - 使用 `-N` 选项跳过列名输出
  - 使用 `tr -d '\n'` 移除换行符
  - 改进 JSON 提取逻辑

**3. 前端响应式更新优化**（frontend/src/modules/Mail.vue）：
- **修复数组响应式更新**：
  ```typescript
  // 修复前
  folders.value = data.folders    // ❌ 可能不触发响应式更新
  
  // 修复后
  folders.value = [...data.folders]    // ✅ 确保响应式更新
  ```
- **改进文件夹过滤逻辑**：
  - 兼容缺少 `folder_type` 字段的情况
  - 使用 `(f.folder_type === 'user' || f.user_id) && f.is_active !== 0` 过滤条件
- **错误处理优化**：
  - 文件夹已存在时自动刷新列表
  - 打开管理文件夹对话框时自动刷新文件夹列表

#### 📋 主要更新内容

**后端修复**：
1. **用户ID映射优化**（backend/dispatcher/server.js）：
   - 新增 `getMailUserIdFromUsername` 函数
   - 新增 `createMailUserFromUsername` 函数
   - 统一使用 `mail_users` 表的用户ID

2. **脚本参数传递修复**（backend/scripts/mail_db.sh）：
   - 修复 `main` 函数中 `folders` 命令的参数传递
   - 改进 MySQL 查询输出处理
   - 添加调试日志

**前端优化**：
1. **响应式更新修复**（frontend/src/modules/Mail.vue）：
   - 修复数组响应式更新问题
   - 改进文件夹过滤逻辑
   - 优化错误处理

#### 🚀 升级步骤

**从 V3.7.0 或更早版本升级到 V3.7.1**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端和后端文件
   cp -r frontend frontend.backup
   cp -r backend backend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新以下文件：
   # - backend/dispatcher/server.js
   # - backend/scripts/mail_db.sh
   # - frontend/src/modules/Mail.vue
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

4. **重启服务**：
   ```bash
   ./start.sh restart
   # 或单独重启调度层服务
   systemctl restart mail-ops-dispatcher
   ```

5. **验证功能**：
   - 打开"管理文件夹"对话框
   - 创建新的自定义文件夹
   - 验证文件夹是否正确显示在列表中
   - 检查浏览器控制台是否有错误信息

#### 📋 实现细节

**用户ID映射函数**：
```javascript
// backend/dispatcher/server.js
function getMailUserIdFromUsername(username, callback) {
  // 查询mail_users表获取用户ID（根据用户名或邮箱）
  const query = `mysql -u mailuser -pmailpass maildb -s -r -e "SELECT id FROM mail_users WHERE username='${escapedUsername}' OR email='${escapedUsername}' LIMIT 1;" 2>&1 | tail -1`
  
  exec(query, (error, stdout, stderr) => {
    if (error || !stdout.trim()) {
      // 如果用户不存在，尝试创建
      return createMailUserFromUsername(username, callback)
    }
    
    const userId = stdout.trim()
    if (userId && !isNaN(parseInt(userId))) {
      callback(null, parseInt(userId))
    } else {
      createMailUserFromUsername(username, callback)
    }
  })
}
```

**脚本参数传递修复**：
```bash
# backend/scripts/mail_db.sh
main() {
  local action="${1:-help}"
  
  case "$action" in
    "folders")
      get_folders "$2"    # ✅ 传递 user_id 参数
      ;;
    # ...
  esac
}
```

**前端响应式更新修复**：
```typescript
// frontend/src/modules/Mail.vue
async function loadFolders() {
  const data = await response.json()
  if (data.success && data.folders) {
    // ✅ 使用数组展开运算符确保响应式更新
    folders.value = [...data.folders]
  }
}
```

#### 🔧 故障排除

**如果文件夹仍然不显示**：

1. **检查后端日志**：
   ```bash
   journalctl -u mail-ops-dispatcher.service -f
   # 查看是否有 "Mail User ID" 相关的日志
   ```

2. **检查数据库日志**：
   ```bash
   tail -f /var/log/mail-ops/mail-db.log
   # 查看查询条件和返回的文件夹数量
   ```

3. **手动测试脚本**：
   ```bash
   cd /bash
   bash backend/scripts/mail_db.sh folders "1"
   # 应该返回所有文件夹（系统文件夹 + 用户自定义文件夹）
   ```

4. **检查数据库中的用户ID**：
   ```bash
   mysql -u mailuser -pmailpass maildb -e "SELECT id, username, email FROM mail_users WHERE username='xm' OR email LIKE '%xm%';"
   mysql -u mailuser -pmailpass maildb -e "SELECT id, name, folder_type, user_id FROM email_folders WHERE folder_type='user';"
   ```

---

## 📋 历史版本更新记录

## V3.7.0 (2025-12-09) - 安全设置完善与邮件显示修复

### 🎊 版本亮点

**V3.7.0 是一个安全设置完善和邮件显示修复版本，完善了系统设置中的安全设置功能，包括前端UI完善、后端处理逻辑优化，同时修复了抄送邮件显示错误的问题，确保所有收件人看到的邮件信息都是正确的。**

#### ✨ 系统安全设置完善

**问题背景**：
- 前端安全设置缺少一些重要选项（如forceHTTPS、requireSpecialChars）
- 后端安全设置处理逻辑不完整
- SSL/HTTPS配置可能破坏现有的RewriteEngine规则
- 缺少配置测试机制

**解决方案**：

**1. 前端安全设置UI完善**（frontend/src/modules/Settings.vue）：
- **新增"强制HTTPS"开关**：
  - 当enableSSL禁用时，forceHTTPS自动禁用
  - 说明：自动将HTTP请求重定向到HTTPS
- **新增"要求特殊字符"开关**：
  - 说明：密码必须包含大小写字母、数字和特殊字符
- **UI优化**：
  - 为所有输入框添加详细说明文字
  - 改进布局和间距
  - 统一开关样式

**2. 后端安全设置处理完善**（backend/dispatcher/server.js）：
- **SSL/HTTPS设置处理**：
  - 智能判断：根据enableSSL和forceHTTPS的组合决定是否启用HTTPS重定向
  - 配置保护：只移除HTTPS相关的重定向规则，保留LocationMatch中的RewriteEngine规则
  - 配置测试：修改前先测试Apache配置，失败时自动恢复，避免破坏服务
  - 配置位置：在VirtualHost块内正确位置添加重定向规则
- **密码策略处理**：
  - 最小长度：更新`/etc/security/pwquality.conf`中的`minlen`配置
  - 特殊字符要求：根据`requireSpecialChars`设置`dcredit`、`ucredit`、`lcredit`、`ocredit`参数
- **登录尝试限制处理**：
  - PAM配置：更新`/etc/pam.d/httpd`中的`pam_tally2`配置
  - 锁定时间：设置合理的解锁时间（600秒）
- **会话超时处理**：
  - Apache配置：更新Apache虚拟主机配置中的`SessionTimeout`设置
- **服务重启逻辑**：
  - 修改安全设置后自动重载/重启相关服务
  - 修改PAM配置后重启Apache服务
  - 修改Apache配置后重载Apache服务

#### 🔧 抄送邮件显示修复

**问题背景**：
- 抄送收件人看到的邮件信息错误
- 收件人显示为自己，抄送显示为主收件人
- 应该显示：收件人为主收件人，抄送为所有抄送地址（包括自己）

**解决方案**（backend/dispatcher/server.js）：
- **修复抄送邮件存储逻辑**：
  - 为每个抄送收件人单独存储邮件
  - 对于抄送收件人，`to_addr`是主收件人（tete@skills.com）
  - `cc_addr`是所有抄送地址（xm@skills.com，包括自己）
  - 确保每个抄送收件人看到的邮件信息正确
- **存储逻辑优化**：
  - 解析抄送地址列表，为每个抄送收件人单独存储
  - 使用唯一的messageId（`${messageId}_cc_${index}`）
  - 临时文件清理优化（延迟清理，确保所有存储操作完成）

#### 📋 主要更新内容

**系统安全设置完善**：
1. **前端UI完善**（frontend/src/modules/Settings.vue）：
   - 添加forceHTTPS开关
   - 添加requireSpecialChars开关
   - 为所有输入框添加说明文字
   - 改进UI布局

2. **后端处理完善**（backend/dispatcher/server.js）：
   - SSL/HTTPS设置智能处理
   - 密码策略PAM配置更新
   - 登录尝试限制PAM配置更新
   - 会话超时Apache配置更新
   - 配置测试和恢复机制

**抄送邮件显示修复**：
1. **存储逻辑修复**（backend/dispatcher/server.js）：
   - 为每个抄送收件人单独存储
   - 修复参数顺序（to_addr和cc_addr）
   - 确保信息正确显示

#### 🚀 升级步骤

**从 V3.6.3 或更早版本升级到 V3.7.0**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端和后端文件
   cp -r frontend frontend.backup
   cp -r backend backend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新以下文件：
   # - frontend/src/modules/Settings.vue
   # - backend/dispatcher/server.js
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

4. **重启服务**：
   ```bash
   ./start.sh restart
   ```

5. **验证功能**：
   - 检查系统设置中的安全设置选项（forceHTTPS、requireSpecialChars等）
   - 测试安全设置的保存和应用
   - 发送带抄送的邮件，检查抄送收件人看到的邮件信息是否正确
   - 检查主收件人和抄送收件人看到的邮件信息是否一致

#### 📋 实现细节

**SSL/HTTPS设置处理**：
```javascript
// backend/dispatcher/server.js
// 确定是否启用HTTPS重定向
const enableSSL = settings.security.enableSSL !== undefined 
  ? settings.security.enableSSL 
  : (currentSettings.security?.enableSSL !== undefined ? currentSettings.security.enableSSL : true)
const forceHTTPS = settings.security.forceHTTPS !== undefined 
  ? settings.security.forceHTTPS 
  : (currentSettings.security?.forceHTTPS !== undefined ? currentSettings.security.forceHTTPS : false)
const shouldRedirect = enableSSL && forceHTTPS

if (shouldRedirect) {
  // 启用SSL重定向
  // 在VirtualHost开始处添加HTTPS重定向规则
  configContent = configContent.replace(
    /(<VirtualHost \*:80>\s*\n)/,
    '$1    # HTTPS重定向\n    RewriteEngine On\n    RewriteCond %{HTTPS} off\n    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n\n'
  )
} else {
  // 禁用SSL重定向 - 只移除HTTPS相关的重定向规则
  configContent = configContent.replace(/\s*# HTTPS重定向\s*\n/gi, '')
  configContent = configContent.replace(/\s*RewriteCond %{HTTPS} off\s*\n/gi, '')
  configContent = configContent.replace(/\s*RewriteRule \^\(\.\*\)\$ https:\/\/%{HTTP_HOST}%{REQUEST_URI} \[L,R=301\]\s*\n/gi, '')
}
```

**抄送邮件存储逻辑**：
```javascript
// backend/dispatcher/server.js
// 如果有抄送，为每个抄送收件人单独存储邮件
if (ccValue) {
  // 解析抄送地址列表
  const ccAddresses = ccValue.split(',').map(addr => addr.trim()).filter(addr => addr.length > 0)
  
  // 为每个抄送收件人单独存储
  ccAddresses.forEach((ccAddr, index) => {
    const ccMessageId = `${messageId}_cc_${index}`
    
    // 对于抄送收件人，to应该是主收件人，cc应该是所有抄送地址（包括自己）
    const ccCommand = `bash "${mailDbScript}" store "${safeCcMessageId}" "${safeFromAddr}" "${safeTo}" "${safeSubject}" "${safeBody}" "${safeHtmlBody}" "inbox" "${bodySize}" "${safeCcValue}" "${safeAttachmentsParamCc}" "{}" "0" "0"`
    // ...
  })
}
```

#### ⚠️ 注意事项

1. **Apache配置测试**：修改Apache配置前会自动测试，如果测试失败会自动恢复原配置
2. **服务重启**：修改安全设置后会自动重启相关服务，确保配置生效
3. **抄送邮件存储**：每个抄送收件人都会收到一封独立的邮件，确保信息正确显示
4. **向后兼容**：所有修改都保持向后兼容，不会影响现有功能

#### 🐛 已知问题

1. **Apache配置测试**：在某些情况下，配置测试可能需要几秒钟时间
2. **抄送邮件存储**：如果有大量抄送收件人，存储过程可能需要一些时间

#### 📈 性能优化

1. **配置测试**：使用临时文件测试配置，避免破坏现有配置
2. **服务重启**：只在必要时重启服务，减少服务中断时间
3. **抄送存储**：异步存储抄送邮件，不阻塞主流程

---

## V3.6.3 (2025-12-08) - 广播UI重新设计与问题修复

### 🎊 版本亮点

**V3.6.3 是一个UI重新设计和问题修复版本，将邮件广播UI从深色渐变改为优雅的浅色卡片设计，使其与邮件系统整体风格保持一致，同时修复了广播重复显示问题，优化了桌面端适配，添加了智能滚动判断，并统一了高级功能按钮的动画效果。**

#### ✨ 邮件广播UI重新设计

**问题背景**：
- 之前的深色渐变设计（蓝色→靛蓝→紫色）与邮件系统的浅色风格不一致
- UI过于突出，不够优雅
- 需要更符合邮件系统整体设计风格

**解决方案**：
- **优雅浅色卡片设计**：
  - 白色半透明背景（`bg-white/95 backdrop-blur-md`）
  - 与邮件页面其他卡片风格一致
  - 圆角和阴影与整体设计统一
- **左侧装饰条**：
  - 渐变竖条（蓝色→靛蓝→紫色）
  - 作为视觉标识，增加设计感
- **图标设计优化**：
  - 小尺寸图标（8x8）
  - 渐变背景容器（蓝色到靛蓝）
  - 圆角和阴影效果
- **文字排版优化**：
  - "系统广播"：小号、粗体、蓝色、大写、字距
  - 分隔点：小圆点
  - 消息内容：中等大小、灰色文字
- **顶部装饰线**：
  - 细渐变线（蓝色→靛蓝→紫色）
  - 增加视觉层次

#### 🔧 广播功能修复与优化

**问题背景**：
- 广播消息在桌面端出现2个重复显示
- 短消息也显示两个副本，造成视觉混乱
- 桌面端遮罩不够宽，效果不佳
- 所有消息都滚动，短消息不需要滚动

**解决方案**：
- **修复重复显示问题**：
  - 添加 `needsScroll` 计算属性，智能判断消息长度
  - 短消息只显示一个，不显示第二个副本
  - 长消息才显示两个副本并滚动
- **桌面端适配优化**：
  - 响应式遮罩宽度：桌面端更宽（`md:w-20`），移动端较窄（`w-12`）
  - 添加窗口大小监听器，实时更新判断
  - 组件卸载时清理事件监听器
- **智能滚动判断**：
  - 根据消息长度和窗口宽度动态决定是否需要滚动
  - 估算消息宽度：每个字符约8px，加上图标和标签约200px
  - 如果消息宽度超过容器宽度的80%，则需要滚动
- **动画优化**：
  - 仅在需要滚动时应用滚动动画
  - 短消息时禁用动画，避免不必要的动画效果
  - 使用条件类绑定控制动画状态

#### 🎯 高级功能按钮动画同步

**问题背景**：
- 广播按钮的悬停动画与其他高级功能按钮不一致
- 缺少蓝色按钮的CSS样式定义

**解决方案**：
- **广播按钮动画统一**：
  - 添加 `.advanced-feature-card-blue::after` 背景装饰图案样式
  - 添加 `.advanced-feature-card-blue::before` 顶部渐变条样式
  - 添加 `.advanced-feature-card-blue:hover` 悬停边框颜色样式
  - 添加 `.advanced-feature-card-blue:hover .advanced-feature-text` 悬停文字颜色样式
- **动画效果同步**：
  - 上移效果（`translateY(-8px)`）
  - 阴影增强
  - 顶部渐变条展开
  - 图标旋转和缩放
  - 文字颜色变化和轻微放大

#### 📋 主要更新内容

**邮件广播UI重新设计**：
1. **浅色卡片设计**（frontend/src/modules/Mail.vue）：
   - 白色半透明背景和模糊效果
   - 左侧渐变装饰条
   - 顶部装饰线

2. **图标与文字优化**（frontend/src/modules/Mail.vue）：
   - 小尺寸图标容器
   - 优化的文字排版
   - 分隔点设计

**广播功能修复与优化**：
1. **智能滚动判断**（frontend/src/modules/Mail.vue）：
   - 添加 `needsScroll` 计算属性
   - 添加窗口大小监听器
   - 条件渲染第二个副本

2. **响应式适配**（frontend/src/modules/Mail.vue）：
   - 响应式遮罩宽度
   - 窗口大小变化自动调整
   - 组件卸载时清理监听器

3. **动画优化**（frontend/src/modules/Mail.vue）：
   - 条件应用滚动动画
   - 添加 `no-scroll` 类禁用动画

**高级功能按钮动画同步**：
1. **CSS样式添加**（frontend/src/modules/Dashboard.vue）：
   - 蓝色按钮的背景装饰图案样式
   - 蓝色按钮的顶部渐变条样式
   - 蓝色按钮的悬停效果样式

#### 🚀 升级步骤

**从 V3.6.2 或更早版本升级到 V3.6.3**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端文件
   cp -r frontend frontend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新以下文件：
   # - frontend/src/modules/Mail.vue
   # - frontend/src/modules/Dashboard.vue
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

4. **验证功能**：
   - 检查邮件页面广播消息的UI效果（浅色卡片设计）
   - 检查短消息是否只显示一个
   - 检查长消息是否正确滚动
   - 检查桌面端和移动端的适配效果
   - 检查高级功能中广播按钮的悬停动画

#### 📋 实现细节

**智能滚动判断**：
```typescript
// frontend/src/modules/Mail.vue
const windowWidth = ref(window.innerWidth)

const needsScroll = computed(() => {
  if (!broadcastMessage.value) return false
  // 估算消息宽度：每个字符约8px，加上图标和标签约200px
  const estimatedWidth = broadcastMessage.value.length * 8 + 200
  // 如果消息宽度超过容器宽度的80%，则需要滚动
  return estimatedWidth > windowWidth.value * 0.8
})

const updateWindowWidth = () => {
  windowWidth.value = window.innerWidth
}

onMounted(async () => {
  // 监听窗口大小变化
  window.addEventListener('resize', updateWindowWidth)
  // ...
})

onUnmounted(() => {
  window.removeEventListener('resize', updateWindowWidth)
})
```

**条件渲染和动画**：
```vue
<!-- frontend/src/modules/Mail.vue -->
<div class="flex items-center" 
     :class="{ 'animate-scroll': needsScroll, 'no-scroll': !needsScroll }" 
     :style="needsScroll ? { animationDuration: `${scrollDuration}s` } : {}">
  <!-- 第一份内容 -->
  <div class="flex items-center space-x-3 ...">
    <!-- 图标和文字 -->
  </div>
  <!-- 重复显示以实现无缝循环 - 仅在需要滚动时显示 -->
  <div v-if="needsScroll" class="flex items-center space-x-3 ...">
    <!-- 图标和文字 -->
  </div>
</div>
```

**响应式遮罩**：
```vue
<!-- frontend/src/modules/Mail.vue -->
<!-- 左右渐变遮罩 - 桌面端更宽 -->
<div class="absolute left-0 top-0 bottom-0 w-12 md:w-20 bg-gradient-to-r from-white/95 via-white/95 to-transparent z-20 pointer-events-none"></div>
<div class="absolute right-0 top-0 bottom-0 w-12 md:w-20 bg-gradient-to-l from-white/95 via-white/95 to-transparent z-20 pointer-events-none"></div>
```

**广播按钮动画样式**：
```css
/* frontend/src/modules/Dashboard.vue */
.advanced-feature-card-blue::after {
  color: #3b82f6;
}

.advanced-feature-card-blue::before {
  background: linear-gradient(to right, #3b82f6, #2563eb);
}

.advanced-feature-card-blue:hover {
  border-color: #3b82f6;
  background: white;
}

.advanced-feature-card-blue:hover .advanced-feature-text {
  color: #3b82f6;
}
```

#### ✅ 验证步骤

1. **检查广播UI效果**：
   - 登录系统，进入邮件页面
   - 查看广播消息的浅色卡片设计
   - 确认左侧装饰条和顶部装饰线

2. **检查重复显示修复**：
   - 设置一个短消息（如"测试"）
   - 确认只显示一个广播消息，不滚动
   - 设置一个长消息（如"这是一条很长的测试消息，用于测试滚动效果"）
   - 确认显示两个副本并滚动

3. **检查桌面端适配**：
   - 在桌面浏览器中查看广播消息
   - 确认遮罩宽度合适
   - 调整浏览器窗口大小，确认自动调整

4. **检查高级功能按钮动画**：
   - 进入高级功能区域
   - 将鼠标悬停在广播按钮上
   - 确认动画效果与其他按钮一致

---

## 📋 历史版本更新记录

## V3.6.2 (2025-12-08) - UI优化与功能完善

### 🎊 版本亮点

**V3.6.2 是一个UI优化和功能完善版本，大幅美化了邮件广播UI的视觉效果，增强了动态效果和视觉层次，同时优化了关键词管理中的统计显示，添加了中英文关键词数量的实时统计，提升了系统的美观性和用户体验。**

#### ✨ 邮件广播UI美化

**问题背景**：
- 广播消息UI较为简单，缺乏视觉吸引力
- 缺少动态效果和视觉层次
- 图标和文字样式较为基础

**解决方案**：
- **视觉层次提升**：
  - 更深的渐变背景（`from-blue-600 via-indigo-600 to-purple-600`）
  - 增强阴影效果（`shadow-2xl`）
  - 圆角优化（`rounded-2xl`）
  - 半透明边框（`border-white/20`）
- **动态效果增强**：
  - 背景光效：脉冲动画的渐变光效
  - 装饰性光点：两个模糊光点，带延迟动画
  - 图标动画：图标容器带脉冲效果
  - 顶部高光：顶部渐变高光线
- **图标与文字优化**：
  - 图标容器：带半透明背景、模糊和边框的圆角容器
  - 文字样式：粗体、小号、大写、字距、阴影效果
  - 分隔符：使用"•"分隔符
- **布局与间距优化**：
  - 高度从 `h-12` 增加到 `h-14`
  - 左右遮罩从 `w-16` 增加到 `w-20`
  - 内边距从 `px-4` 增加到 `px-6`
  - 元素间距从 `space-x-2` 增加到 `space-x-3`

#### 📊 关键词统计显示优化

**问题背景**：
- 关键词管理部分缺少中英文关键词的统计显示
- 无法快速了解中文和英文关键词的数量分布

**解决方案**：
- **中文关键词统计**：在关键词管理标题旁显示中文关键词数量（橙色标签）
- **英文关键词统计**：在关键词管理标题旁显示英文关键词数量（琥珀色标签）
- **实时统计更新**：统计信息随关键词变化实时更新
- **UI一致性**：统计标签样式与其他统计信息保持一致

#### 📋 主要更新内容

**邮件广播UI美化**：
1. **视觉层次提升**（frontend/src/modules/Mail.vue）：
   - 更深的渐变背景和增强阴影效果
   - 圆角优化和半透明边框
   - 背景光效和装饰性光点

2. **动态效果增强**（frontend/src/modules/Mail.vue）：
   - 背景光效动画
   - 装饰性光点动画
   - 图标脉冲动画
   - 顶部高光效果

3. **图标与文字优化**（frontend/src/modules/Mail.vue）：
   - 图标容器样式优化
   - 文字样式分层
   - 分隔符添加

4. **布局与间距优化**（frontend/src/modules/Mail.vue）：
   - 高度、遮罩、内边距、元素间距优化

**关键词统计显示优化**：
1. **统计标签添加**（frontend/src/modules/Dashboard.vue）：
   - 在关键词管理标题旁添加中英文关键词统计标签
   - 使用 `filter()` 方法实时计算数量

2. **UI样式统一**（frontend/src/modules/Dashboard.vue）：
   - 统计标签样式与其他统计信息保持一致
   - 使用橙色和琥珀色区分中英文

#### 🚀 升级步骤

**从 V3.6.1 或更早版本升级到 V3.6.2**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端文件
   cp -r frontend frontend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新以下文件：
   # - frontend/src/modules/Mail.vue
   # - frontend/src/modules/Dashboard.vue
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

4. **验证功能**：
   - 检查邮件页面广播消息的UI效果
   - 检查关键词管理中的中英文统计显示

#### 📋 实现细节

**邮件广播UI美化**：
```vue
<!-- frontend/src/modules/Mail.vue -->
<div v-if="broadcastMessage" class="mb-6 relative group">
  <!-- 主容器 - 更精致的渐变和阴影 -->
  <div class="relative bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 rounded-2xl shadow-2xl overflow-hidden border border-white/20 backdrop-blur-sm">
    <!-- 背景光效 -->
    <div class="absolute inset-0 bg-gradient-to-r from-blue-400/20 via-transparent to-purple-400/20 animate-pulse"></div>
    
    <!-- 装饰性光点 -->
    <div class="absolute top-0 left-1/4 w-32 h-32 bg-white/10 rounded-full blur-2xl animate-pulse" style="animation-delay: 0.5s;"></div>
    <div class="absolute bottom-0 right-1/4 w-24 h-24 bg-white/10 rounded-full blur-xl animate-pulse" style="animation-delay: 1s;"></div>
    
    <!-- 图标容器 - 带背景和动画 -->
    <div class="flex-shrink-0 p-1.5 bg-white/20 rounded-lg backdrop-blur-sm border border-white/30">
      <svg class="h-5 w-5 flex-shrink-0 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <!-- 图标路径 -->
      </svg>
    </div>
    
    <!-- 文字内容 -->
    <div class="flex items-center space-x-2">
      <span class="font-bold text-sm tracking-wide uppercase text-white/90">系统广播</span>
      <span class="text-white/80">•</span>
      <span class="text-sm font-medium text-white drop-shadow-sm">{{ broadcastMessage }}</span>
    </div>
  </div>
</div>
```

**关键词统计显示优化**：
```vue
<!-- frontend/src/modules/Dashboard.vue -->
<div class="flex items-center justify-between mb-3">
  <h4 class="text-sm font-medium text-gray-900">关键词管理</h4>
  <div class="flex items-center space-x-2">
    <span class="px-2 py-1 bg-orange-100 text-orange-700 rounded text-xs font-medium">
      中文: {{ spamKeywords.filter(k => k.lang === 'cn').length }}
    </span>
    <span class="px-2 py-1 bg-amber-100 text-amber-700 rounded text-xs font-medium">
      英文: {{ spamKeywords.filter(k => k.lang === 'en').length }}
    </span>
  </div>
</div>
```

#### ✅ 验证步骤

1. **检查广播UI效果**：
   - 登录系统，进入邮件页面
   - 查看广播消息的视觉效果
   - 确认动态效果和视觉层次

2. **检查关键词统计**：
   - 进入高级功能 -> 垃圾邮件过滤配置
   - 查看关键词管理部分
   - 确认中英文关键词统计显示

---

## 📋 历史版本更新记录

## V3.6.1 (2025-12-08) - 邮件抄送标记显示优化

### 🎊 版本亮点

**V3.6.1 是一个用户体验优化版本，修复了邮件抄送标记的显示逻辑，确保只有被抄送的用户才显示"抄送"标记，主收件人不会误显示抄送标记，提升了邮件界面的准确性和用户体验。**

#### ✨ 抄送标记显示逻辑优化

**问题背景**：
- 主收件人（to）误显示"抄送"标记
- 前端仅检查邮件是否有 `cc` 字段，未判断当前用户是否为抄送收件人
- 无法准确区分主收件人和抄送收件人

**解决方案**：
- **精确判断逻辑**：只有被抄送的用户才显示"抄送"标记，主收件人不显示
- **用户角色识别**：通过检查当前用户邮箱是否在 `recipients.cc` 数组中判断是否为抄送收件人
- **主收件人保护**：如果用户同时在 `to` 和 `cc` 列表中，优先识别为主收件人，不显示抄送标记
- **向后兼容**：支持旧的 `email.cc` 字符串格式，确保兼容性

#### 📋 主要修复内容

**抄送标记显示优化**：
1. **前端判断函数**（frontend/src/modules/Mail.vue）：
   - 添加 `isCurrentUserCC()` 函数精确判断当前用户角色
   - 检查当前用户邮箱是否在 `email.recipients.cc` 数组中
   - 如果用户在 `cc` 中但不在 `to` 中，返回 `true`（显示抄送标记）
   - 如果用户同时在 `to` 和 `cc` 中，返回 `false`（不显示抄送标记）

2. **用户邮箱获取**（frontend/src/modules/Mail.vue）：
   - 添加 `currentUserEmail` 响应式变量存储当前用户邮箱
   - 组件挂载时自动调用 `getCurrentUserEmail()` 获取用户邮箱

3. **显示条件优化**（frontend/src/modules/Mail.vue）：
   - 收件箱列表：将 `v-if="email.cc"` 改为 `v-if="isCurrentUserCC(email)"`
   - 已发送列表：将 `v-if="email.cc && email.cc.trim()"` 改为 `v-if="isCurrentUserCC(email)"`

#### 🚀 升级步骤

**从 V3.6.0 或更早版本升级到 V3.6.1**：

1. **备份系统**（可选，建议）：
   ```bash
   # 备份前端文件
   cp -r frontend frontend.backup
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull origin main
   # 或手动更新 frontend/src/modules/Mail.vue 文件
   ```

3. **重建前端**：
   ```bash
   ./start.sh rebuild
   ```

4. **验证功能**：
   - 发送一封包含主收件人和抄送收件人的邮件
   - 检查主收件人是否不显示"抄送"标记
   - 检查抄送收件人是否显示"抄送"标记

#### 📋 实现细节

**前端判断函数**：
```typescript
// frontend/src/modules/Mail.vue
function isCurrentUserCC(email: any): boolean {
  if (!currentUserEmail.value || !email) return false
  
  const userEmail = currentUserEmail.value.toLowerCase().trim()
  
  // 检查 recipients.cc 数组
  if (email.recipients && email.recipients.cc && Array.isArray(email.recipients.cc)) {
    const isInCC = email.recipients.cc.some((addr: string) => {
      return addr && addr.toLowerCase().trim() === userEmail
    })
    if (isInCC) {
      // 检查用户不在 to 列表中
      if (email.recipients.to && Array.isArray(email.recipients.to)) {
        const isInTo = email.recipients.to.some((addr: string) => {
          return addr && addr.toLowerCase().trim() === userEmail
        })
        if (isInTo) return false  // 主收件人不显示抄送标记
      }
      return true  // 抄送收件人显示抄送标记
    }
  }
  
  // 向后兼容：检查旧的 cc 字段
  if (email.cc && typeof email.cc === 'string') {
    const ccAddresses = email.cc.split(',').map((addr: string) => addr.trim().toLowerCase())
    if (ccAddresses.includes(userEmail)) {
      if (email.to && typeof email.to === 'string') {
        const toAddresses = email.to.split(',').map((addr: string) => addr.trim().toLowerCase())
        if (toAddresses.includes(userEmail)) return false
      }
      return true
    }
  }
  
  return false
}
```

**用户邮箱获取**：
```typescript
// frontend/src/modules/Mail.vue
const currentUserEmail = ref<string | null>(null)

onMounted(async () => {
  // 获取当前用户邮箱
  try {
    const userEmail = await getCurrentUserEmail()
    currentUserEmail.value = userEmail
    console.log('当前用户邮箱已设置:', userEmail)
  } catch (error) {
    console.error('获取当前用户邮箱失败:', error)
  }
  
  // ... 其他初始化代码
})
```

**显示条件优化**：
```vue
<!-- 收件箱列表 -->
<span v-if="isCurrentUserCC(email)" class="...">
  抄送
</span>

<!-- 已发送列表 -->
<span v-if="isCurrentUserCC(email)" class="...">
  抄送
</span>
```

#### ✅ 验证步骤

1. **发送测试邮件**：
   - 收件人：test01@skills.com
   - 抄送：test02@skills.com, test03@skills.com

2. **检查主收件人（test01）**：
   - 登录 test01 账户
   - 查看收件箱，确认不显示"抄送"标记

3. **检查抄送收件人（test02、test03）**：
   - 登录 test02 或 test03 账户
   - 查看收件箱，确认显示"抄送"标记

---

## 📋 历史版本更新记录

## V3.6.0 (2025-12-08) - 垃圾邮件过滤配置优化与全文件夹计数修复

### 🎊 版本亮点

**V3.6.0 是一个功能优化和问题修复版本，优化了垃圾邮件过滤配置的默认规则和关键词列表，添加了重装保护机制，并修复了所有文件夹（已发送、草稿箱、已删除、垃圾邮件等）的未读邮件计数问题，确保所有文件夹的统计准确性。**

#### 🛡️ 垃圾邮件过滤配置优化

**问题背景**：
- 默认过滤规则不够灵活，最小邮件内容行数设置为3行可能误判短邮件
- 默认关键词列表较少，无法覆盖更多垃圾邮件场景
- 重装系统时会覆盖用户已修改的垃圾邮件过滤配置
- 域名黑名单包含多个测试域名，不够精简

**解决方案**：
- **默认规则调整**：
  - 最小邮件内容行数：从3行调整为0行（允许短邮件）
  - 大写字母比例阈值：从0.7调整为0.8（更宽松）
  - 最大感叹号数量：从5调整为6（更宽松）
  - 最大特殊字符数量：从10调整为8（更严格）
- **关键词扩展**：
  - 中文关键词：从29个扩展到81个，包含更多常见的垃圾邮件关键词和短语
  - 英文关键词：从35个扩展到89个，包含更多常见的垃圾邮件关键词和短语
- **域名黑名单优化**：默认域名黑名单调整为单个域名 `xmtest.com`
- **重装保护机制**：添加配置检查逻辑，如果数据库中已存在配置，则跳过初始化，确保重装时保留用户已修改的配置

#### 📊 全文件夹未读计数修复

**问题背景**：
- 收件箱的未读计数已修复，但其他文件夹（已发送、草稿箱、已删除、垃圾邮件等）仍使用旧的统计逻辑
- 垃圾邮件文件夹显示错误的未读计数（例如：实际2封未读，显示5封未读）
- 所有文件夹的统计查询不一致，导致计数不准确

**解决方案**：
- **统一去重逻辑**：所有文件夹都使用与收件箱相同的去重逻辑
  - 使用 `SUBSTRING_INDEX(message_id, '_', 1)` 提取基础message_id
  - 使用 `GROUP BY base_message_id` 确保每封邮件只计数一次
  - 使用 `MIN(read_status)` 判断邮件是否未读
- **统计查询统一**：
  - 已发送文件夹（folder_id=2）：应用去重逻辑
  - 草稿箱（folder_id=3）：应用去重逻辑
  - 已删除文件夹（folder_id=4）：应用去重逻辑
  - 垃圾邮件文件夹（folder_id=5）：应用去重逻辑
  - 自定义文件夹（get_folder_stats函数）：应用去重逻辑

#### 📋 主要修复内容

**垃圾邮件过滤配置优化**：
1. **默认规则调整**（backend/scripts/mail_db.sh）：
   - 最小邮件内容行数：从3行调整为0行
   - 大写字母比例阈值：从0.7调整为0.8
   - 最大感叹号数量：从5调整为6
   - 最大特殊字符数量：从10调整为8

2. **关键词扩展**（backend/scripts/mail_db.sh）：
   - 中文关键词：从29个扩展到81个
   - 英文关键词：从35个扩展到89个
   - 包含更多常见的垃圾邮件关键词和短语

3. **域名黑名单优化**（backend/scripts/mail_db.sh）：
   - 默认域名黑名单调整为单个域名 `xmtest.com`

4. **重装保护机制**（backend/scripts/mail_db.sh）：
   - 添加配置检查逻辑，如果数据库中已存在配置，则跳过初始化
   - 使用 `INSERT IGNORE` 确保不会覆盖现有数据

5. **前端默认值更新**（frontend/src/modules/Dashboard.vue）：
   - 更新所有默认规则值
   - 更新输入框的min属性（从1改为0）
   - 更新加载失败时的默认配置

**全文件夹未读计数修复**：
1. **已发送文件夹统计**（backend/scripts/mail_db.sh）：
   - 应用与收件箱相同的去重逻辑
   - 使用 `SUBSTRING_INDEX(message_id, '_', 1)` 提取基础message_id
   - 使用 `GROUP BY base_message_id` 确保每封邮件只计数一次

2. **草稿箱统计**（backend/scripts/mail_db.sh）：
   - 应用与收件箱相同的去重逻辑

3. **已删除文件夹统计**（backend/scripts/mail_db.sh）：
   - 应用与收件箱相同的去重逻辑

4. **垃圾邮件文件夹统计**（backend/scripts/mail_db.sh）：
   - 应用与收件箱相同的去重逻辑
   - 使用 `email_recipients` 表过滤用户邮件

5. **通用文件夹统计**（backend/scripts/mail_db.sh）：
   - `get_folder_stats` 函数应用去重逻辑
   - 支持所有自定义文件夹

#### 📋 实现细节

**垃圾邮件过滤配置优化**：

1. **默认规则调整**：
   ```bash
   # backend/scripts/mail_db.sh - init_spam_filter_config函数
   local rules='{"min_body_lines":0,"max_caps_ratio":0.8,"max_exclamation":6,"max_special_chars":8}'
   mysql_connect "INSERT IGNORE INTO spam_filter_config (config_type, config_key, config_value) VALUES ('rule', 'default', '$rules');"
   ```

2. **重装保护机制**：
   ```bash
   # 检查是否已存在配置，如果存在则跳过初始化
   local existing_count=$(mysql_connect "SELECT COUNT(*) FROM spam_filter_config WHERE config_key='default' AND is_active=1;" 2>/dev/null | tail -1 | tr -d '[:space:]')
   if [[ "$existing_count" -gt 0 ]]; then
     log "检测到已有垃圾邮件过滤配置（${existing_count}条），跳过默认配置初始化（保留现有数据）"
     return 0
   fi
   ```

3. **前端默认值更新**：
   ```typescript
   // frontend/src/modules/Dashboard.vue
   const spamFilterConfig = ref({
     minBodyLines: 0,        // 从3改为0
     maxCapsRatio: 0.8,     // 从0.7改为0.8
     maxExclamation: 6,     // 从5改为6
     maxSpecialChars: 8     // 从10改为8
   })
   ```

**全文件夹未读计数修复**：

1. **统一统计查询逻辑**：
   ```sql
   -- 所有文件夹都使用相同的去重逻辑
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
     WHERE e.folder_id=X AND e.is_deleted=0
     [用户过滤条件]
     GROUP BY base_message_id
   ) AS subquery;
   ```

2. **已发送文件夹示例**：
   ```sql
   -- folder_id=2 (已发送)
   SELECT
     COUNT(DISTINCT base_message_id) as total,
     SUM(CASE WHEN min_read_status=0 THEN 1 ELSE 0 END) as unread
   FROM (
     SELECT
       SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
       MIN(e.read_status) as min_read_status
     FROM emails e
     WHERE e.folder_id=2 AND e.is_deleted=0 AND e.from_addr = 'xm@localhost'
     GROUP BY base_message_id
   ) AS subquery;
   ```

3. **垃圾邮件文件夹示例**：
   ```sql
   -- folder_id=5 (垃圾邮件)
   SELECT
     COUNT(DISTINCT base_message_id) as total,
     SUM(CASE WHEN min_read_status=0 THEN 1 ELSE 0 END) as unread
   FROM (
     SELECT
       SUBSTRING_INDEX(e.message_id, '_', 1) as base_message_id,
       MIN(e.read_status) as min_read_status
     FROM emails e
     WHERE e.folder_id=5 AND e.is_deleted=0
     AND e.id IN (
       SELECT DISTINCT er.email_id
       FROM email_recipients er 
       WHERE er.recipient_type IN ('to', 'cc') 
       AND (er.email_address = 'xm@localhost' OR ...)
     )
     GROUP BY base_message_id
   ) AS subquery;
   ```

#### 🚀 升级步骤

**从 V3.5.2 或更早版本升级到 V3.6.0**：

1. **备份系统**：
   ```bash
   # 备份数据库（可选，建议）
   mysqldump -u mailuser -p maildb > /bash/backup/maildb_$(date +%Y%m%d_%H%M%S).sql
   
   # 备份后端脚本
   cp backend/scripts/mail_db.sh backend/scripts/mail_db.sh.bak
   
   # 备份前端代码
   cp -r frontend/src/modules/Dashboard.vue frontend/src/modules/Dashboard.vue.bak
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull
   
   # 或手动更新相关文件
   # - backend/scripts/mail_db.sh
   # - backend/dispatcher/server.js
   # - frontend/src/modules/Dashboard.vue
   ```

3. **重建前端**：
   ```bash
   # 重建前端
   ./start.sh rebuild
   ```

4. **重启服务**（可选）：
   ```bash
   # 重启调度层服务（如果修改了后端脚本，通常不需要重启）
   systemctl restart mail-ops-dispatcher.service
   
   # 检查服务状态
   systemctl status mail-ops-dispatcher.service
   ```

5. **验证功能**：
   ```bash
   # 测试垃圾邮件过滤配置
   # 1. 打开Dashboard -> 垃圾邮件过滤配置
   # 2. 检查默认规则值是否正确（0行、0.8比例、6个感叹号、8个特殊字符）
   # 3. 检查默认域名黑名单是否为 xmtest.com
   # 4. 检查关键词列表是否已扩展
   
   # 测试全文件夹未读计数
   # 1. 检查垃圾邮件文件夹的未读计数是否准确
   # 2. 检查已发送文件夹的未读计数是否准确
   # 3. 检查草稿箱的未读计数是否准确
   # 4. 检查已删除文件夹的未读计数是否准确
   ```

#### 📝 注意事项

1. **数据验证**：
   - 升级后检查垃圾邮件过滤配置的默认值是否正确
   - 验证所有文件夹的未读邮件计数是否准确
   - 确保重装时不会覆盖用户已修改的配置

2. **功能测试**：
   - 测试垃圾邮件过滤配置的默认规则值
   - 测试关键词列表是否已扩展
   - 测试所有文件夹（收件箱、已发送、草稿箱、已删除、垃圾邮件）的未读计数是否准确
   - 验证重装保护机制是否正常工作

3. **回滚方案**：
   - 如果升级后出现问题，可以使用备份文件恢复
   - 恢复后重启调度层服务并重建前端

### 🎯 效果与影响

**垃圾邮件过滤配置优化**：
- 默认规则更灵活，减少误判短邮件
- 关键词列表更全面，覆盖更多垃圾邮件场景
- 重装保护机制确保用户配置不丢失
- 域名黑名单更精简，便于管理

**全文件夹计数准确性**：
- 所有文件夹的未读邮件计数准确，不再出现重复计数问题
- 统一的去重逻辑确保计数一致性
- 每个用户的未读邮件计数独立，不受其他用户影响
- 统计查询基于message_id前缀去重，确保每封邮件只计数一次

**用户体验改善**：
- 垃圾邮件过滤配置更合理，减少误判
- 所有文件夹的未读计数准确，提升了用户信任度
- 重装保护机制确保用户配置不丢失，提升了系统可靠性

---

## 🎉 历史版本 - V3.5.2 (2025-12-06) - 未读邮件计数与标记已读优化

### 🎊 版本亮点

**V3.5.2 是一个问题修复版本，修复了未读邮件计数不准确的问题（同一封邮件被存储多次导致重复计数），优化了标记已读功能，确保刷新后邮件状态能够正确保持，提升了邮件管理的准确性和用户体验。**

#### 🔢 未读邮件计数修复

**问题背景**：
- 同一封邮件被存储多次（`_inbox` 和 `_cc` 后缀），导致未读邮件计数不准确
- 例如：test01用户有3封邮件，2封未读，但系统显示5封未读
- 统计查询没有基于message_id前缀去重，导致重复计数

**解决方案**：
- **精确去重**：使用 `SUBSTRING_INDEX(message_id, '_', 1)` 提取基础message_id进行去重统计
- **用户独立计数**：确保每个用户的未读邮件计数准确，不受其他用户影响
- **状态优先判断**：如果同一封邮件的多个记录有不同的read_status，使用 `MIN(read_status)` 确保只要有一条记录是未读，整封邮件就视为未读
- **统计查询优化**：使用 `GROUP BY base_message_id` 和子查询确保每封邮件只计数一次

#### ✅ 标记已读功能优化

**问题背景**：
- 点击邮件后刷新页面，邮件状态恢复为未读，需要再点击一次才能显示已读
- 标记已读时只更新了当前记录，没有更新同一封邮件的其他记录（`_inbox` 和 `_cc`）
- 前端状态更新不完整，没有同步更新所有相同邮件的状态

**解决方案**：
- **批量更新**：标记已读时，使用 `SUBSTRING_INDEX(message_id, '_', 1)` 匹配所有相关记录，自动更新同一封邮件的所有记录
- **状态同步**：前端在标记已读后，立即更新本地邮件列表中所有具有相同base_message_id的邮件状态
- **刷新后保持**：延迟重新加载邮件列表，确保后端更新完成后再刷新，保证已读状态持久化
- **字段兼容**：同时支持 `read` 和 `read_status` 字段，确保向后兼容

---

## 🎉 历史版本 - V3.5.1 (2025-12-06) - DNS配置保留与识别优化

### 🎊 版本亮点

**V3.5.1 是一个问题修复版本，修复了重装系统后DNS配置（域名、服务器IP等）丢失的问题，优化了DNS类型识别逻辑，确保重装后能够正确保留和显示DNS配置。**

#### 🔧 DNS配置重装保留

**问题背景**：
- 重装系统后，之前配置的Bind DNS预设值（域名、服务器IP等）丢失
- DNS配置类型（bind/public）无法正确识别，默认显示为公网DNS
- 系统设置中保存的DNS配置在重装后无法正确加载

**解决方案**：
- **配置保护机制**：在保存系统设置时，如果新设置中的DNS配置字段是空字符串，则从现有配置中恢复这些值
- **深度合并优化**：改进了深度合并函数，确保target中存在但source中不存在的键会被保留
- **启动时检测**：在系统启动时自动检测并补充DNS配置状态字段（configured和type）
- **预设值保护**：确保DNS配置的预设值在重装后能够正确保留和显示

#### 🎯 DNS类型检测优化

**问题背景**：
- 前端依赖后端API返回的DNS类型，但API可能返回错误的类型
- 即使系统设置中有正确的DNS类型，前端也可能被API返回的错误类型覆盖
- Bind配置的优先级低于公网DNS配置

**解决方案**：
- **前端优先策略**：前端优先使用系统设置中保存的DNS类型，不再依赖API返回
- **智能推断**：如果系统设置中没有类型，根据实际配置（bind或public）自动推断
- **后端优化**：后端API优先识别Bind配置，确保Bind配置的优先级高于公网DNS
- **加载顺序优化**：在组件挂载时先加载系统设置，再检测DNS类型

---

## 🎉 历史版本 - V3.5.0 (2025-12-06) - 时区功能修复与调度层服务优化

### 🎊 版本亮点

**V3.5.0 是一个问题修复版本，修复了系统设置页面时区列表不显示的问题，并修复了导致调度层服务无法启动的代码语法错误，提升了系统的稳定性和可用性。**

#### 🌍 时区列表功能修复

**问题背景**：
- 系统设置页面时区列表不显示，前端显示"加载时区列表失败: HTTP 500: Internal Server Error"
- 后端时区API返回500错误，导致前端无法加载时区列表
- 存在重复的路由定义，导致错误的代码被执行

**解决方案**：
- **删除重复路由**：删除了错误的 `/api/timezones` 路由定义（第2973行），保留了正确的实现（第3716行）
- **修复代码结构**：修复了时区API的代码结构错误，确保所有代码块正确闭合
- **错误处理增强**：添加了多层错误处理机制，即使系统命令执行失败也能返回默认时区列表
- **数据保障**：确保API始终返回有效的时区数据，前端始终可用

#### 🚀 调度层服务启动修复

**问题背景**：
- 调度层服务无法启动，systemd显示"SyntaxError: Unexpected token 'catch'"
- 代码中存在语法错误，导致Node.js无法解析
- 重复的路由定义导致代码结构混乱

**解决方案**：
- **语法错误修复**：修复了所有导致服务无法启动的语法错误
- **代码清理**：删除了错误的重复路由定义，清理了混乱的代码结构
- **结构优化**：优化了try-catch块的结构，确保所有代码块正确嵌套和闭合

#### 📋 主要修复内容

**时区API修复**：
1. **删除错误路由**（第2972-3468行）：
   - 删除了包含通知邮件逻辑的错误时区路由
   - 该路由使用了未定义的变量 `to`，导致 `ReferenceError`

2. **修复通知邮件API**（第2976行）：
   - 修复了 `/api/notifications/test-system-alert` 路由
   - 添加了缺失的变量定义（`timestamp`, `clientIP`, `user`）
   - 添加了收件人地址的默认值处理

3. **时区API错误处理**（第3716行）：
   - 改进了时区API的错误处理逻辑
   - 添加了完整的后备方案，确保即使命令失败也能返回默认时区列表
   - 增加了数据验证和边界情况处理

**代码结构优化**：
1. **语法错误修复**：
   - 修复了try-catch块的嵌套结构
   - 确保所有代码块正确闭合
   - 移除了多余的括号和catch块

2. **代码清理**：
   - 删除了重复的路由定义
   - 清理了混乱的代码结构
   - 优化了错误处理逻辑

#### 📋 实现细节

**修复的语法错误**：

1. **Unexpected token 'catch'** (line 3860)
   - **原因**：try-catch块嵌套不正确，导致catch块找不到对应的try块
   - **修复**：重新组织了代码结构，确保所有try-catch块正确嵌套
   - **影响**：修复了调度层服务无法启动的问题

2. **ReferenceError: to is not defined** (line 2980)
   - **原因**：错误的时区路由中使用了未定义的变量 `to`
   - **修复**：删除了错误的重复路由定义
   - **影响**：修复了时区API的500错误

**代码修改**：

**主要修改文件**：
- `backend/dispatcher/server.js` - 修复时区API和调度层服务启动问题

**修改内容**：
1. 删除了错误的时区路由定义（第2972-3468行）
2. 修复了通知邮件API的变量定义问题
3. 改进了时区API的错误处理逻辑
4. 修复了所有语法错误，确保服务能够正常启动

#### 🚀 升级步骤

**从 V3.4.3 或更早版本升级到 V3.5.0**：

1. **备份系统**：
   ```bash
   # 备份后端代码
   cp -r backend/dispatcher/server.js backend/dispatcher/server.js.bak
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull
   
   # 或手动更新 backend/dispatcher/server.js
   ```

3. **重启调度层服务**：
   ```bash
   # 重启调度层服务
   systemctl restart mail-ops-dispatcher.service
   
   # 检查服务状态
   systemctl status mail-ops-dispatcher.service
   ```

4. **验证功能**：
   ```bash
   # 测试时区API
   curl -u xm:xm666@ http://localhost:8081/api/timezones
   
   # 访问系统设置页面，验证时区列表是否正常显示
   # 检查浏览器控制台是否有错误
   ```

#### 📝 注意事项

1. **服务验证**：
   - 升级后检查调度层服务是否正常启动
   - 验证时区API是否返回正确的数据
   - 确保前端能够正常加载时区列表

2. **功能测试**：
   - 测试系统设置页面的时区选择功能
   - 验证时区更改是否能够正常保存和应用
   - 检查其他API是否正常工作

3. **回滚方案**：
   - 如果升级后出现问题，可以使用备份文件恢复
   - 恢复后重启调度层服务

### 🎯 效果与影响

**功能恢复**：
- 时区列表功能完全恢复，用户可以正常选择时区
- 系统设置页面功能正常，不再出现500错误
- 调度层服务稳定运行，不再出现启动失败

**稳定性提升**：
- 代码结构更加清晰，减少了潜在的语法错误
- 错误处理更加完善，提高了系统的健壮性
- 服务启动更加可靠，减少了服务中断的风险

**用户体验改善**：
- 时区选择功能恢复正常，用户可以正常配置系统时区
- 系统设置页面功能完整，提升了用户体验
- 系统更加稳定可靠，减少了故障发生的可能性

---

## 🎉 历史版本 - V3.4.3 (2025-12-06) - 未读邮件计数修复与数据库用户初始化优化

### 🎊 版本亮点

**V3.4.3 是一个问题修复版本，修复了收件箱未读邮件计数显示不准确的问题（1封信件显示2封），并优化了数据库用户初始化逻辑，确保重装系统时保留现有用户数据（包括注册时间）。**

#### 🔢 未读邮件计数修复

**问题背景**：
- 收件箱未读邮件计数显示不准确，1封信件显示2封
- 前端基于当前页面邮件列表重新计算未读数量，只统计当前页，不准确
- 在标记已读和删除邮件时也基于当前列表重新计算，可能导致重复计数

**解决方案**：
- **统一数据源**：未读计数统一从 `loadMailStats()` 获取，该函数从后端 `/api/mail/stats` 获取准确的统计数据
- **移除重复计算**：移除基于当前页面邮件列表的重新计算逻辑，避免只统计当前页导致的不准确
- **实时更新**：在标记已读、删除邮件等操作后，调用 `loadMailStats()` 刷新统计信息

#### 🗄️ 数据库用户初始化优化

**问题背景**：
- 重装系统时，管理员用户 `xm` 被重新创建，导致注册时间被重置
- 之前的清理逻辑过于激进，会删除邮箱已更新的 `xm` 用户（如 `xm@skills.com`）
- 导致重装时用户被重新创建，`created_at` 时间戳被重置

**解决方案**：
- **用户保留机制**：如果数据库中已存在 `xm` 用户，只更新密码，保留现有邮箱和注册时间
- **清理逻辑优化**：只删除明显错误的记录（如 `username='xm@localhost'`），保留所有正确的用户数据
- **数据保护**：确保重装时保留现有用户的所有数据，包括邮箱和注册时间

#### 📋 主要修复内容

**前端计数修复**：
1. **`loadEmails()` 函数**（第3265-3274行）：
   - 移除基于当前页面邮件列表的重新计算逻辑
   - 改为调用 `loadMailStats()` 获取准确统计
   - 只在切换到已发送文件夹时清空未读计数

2. **`markAsRead()` 函数**（第3371行）：
   - 移除基于当前页面邮件列表的重新计算
   - 改为调用 `loadMailStats()` 刷新统计

3. **`softDeleteEmail()` 函数**（第3405行）：
   - 移除基于当前页面邮件列表的重新计算
   - 统一使用 `loadMailStats()` 获取准确统计

**后端查询优化**：
- 后端统计查询使用 `COUNT(DISTINCT e.id)` 和 `EXISTS` 子查询，确保不会因为多个收件人导致重复计数
- 查询逻辑正确，不会导致重复计数问题

**用户初始化修复**：
1. **`fix_auth` 函数**（第254行）：
   - 修复清理逻辑，只删除明显错误的记录
   - 保留所有 `username='xm'` 的记录，无论邮箱是什么

2. **`wait_for_dispatcher` 函数**（第361行）：
   - 修复清理逻辑，只删除明显错误的记录
   - 保留所有正确的用户数据

3. **主初始化流程**（第1107行）：
   - 修复清理逻辑，只删除明显错误的记录
   - 如果用户已存在，只更新密码，保留现有邮箱和注册时间
   - 添加日志记录，显示当前邮箱和注册时间

#### 📋 实现细节

**修复的计数问题**：

1. **未读邮件计数不准确**
   - **原因**：前端基于当前页面邮件列表重新计算未读数量，只统计当前页，不准确
   - **修复**：统一使用 `loadMailStats()` 获取准确的统计数据
   - **影响**：未读邮件计数现在准确显示，不会出现1封信件显示2封的情况

2. **用户初始化时数据丢失**
   - **原因**：清理逻辑过于激进，会删除邮箱已更新的用户
   - **修复**：优化清理逻辑，只删除明显错误的记录，保留所有正确的用户数据
   - **影响**：重装系统时，现有用户数据（包括注册时间）会被保留

**代码修改**：

**主要修改文件**：
- `frontend/src/modules/Mail.vue` - 修复未读邮件计数逻辑
- `start.sh` - 优化数据库用户初始化逻辑

**修改内容**：
1. `loadEmails()` 函数：移除基于当前页面邮件列表的重新计算，改为调用 `loadMailStats()`
2. `markAsRead()` 函数：移除重新计算，改为调用 `loadMailStats()`
3. `softDeleteEmail()` 函数：移除重新计算，统一使用 `loadMailStats()`
4. `fix_auth` 函数：修复清理逻辑，只删除明显错误的记录
5. `wait_for_dispatcher` 函数：修复清理逻辑，只删除明显错误的记录
6. 主初始化流程：修复清理逻辑，如果用户已存在，只更新密码，保留现有数据

#### 🚀 升级步骤

**从 V3.4.2 或更早版本升级到 V3.4.3**：

1. **备份系统**：
   ```bash
   # 备份前端代码
   cp -r frontend/src/modules/Mail.vue frontend/src/modules/Mail.vue.bak
   
   # 备份启动脚本
   cp start.sh start.sh.bak
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull
   
   # 或手动更新文件
   # - frontend/src/modules/Mail.vue
   # - start.sh
   ```

3. **重新构建前端**：
   ```bash
   # 重新构建前端
   cd frontend
   npm run build
   
   # 或使用部署脚本
   cd ..
   ./start.sh rebuild
   ```

4. **验证功能**：
   ```bash
   # 检查前端构建是否成功
   ls -la frontend/dist/
   
   # 访问邮件页面，验证未读邮件计数显示正确
   # 检查浏览器控制台是否有错误
   # 测试标记已读、删除邮件等操作后计数是否正确更新
   ```

#### 📝 注意事项

1. **计数验证**：
   - 升级后检查收件箱未读邮件计数是否准确
   - 验证标记已读、删除邮件后计数是否正确更新
   - 确保不会出现1封信件显示2封的情况

2. **用户数据保护**：
   - 重装系统时，确保现有用户数据（包括注册时间）被保留
   - 验证管理员用户不会被重新创建
   - 检查用户邮箱是否正确保留

3. **回滚方案**：
   - 如果升级后出现问题，可以使用备份文件恢复
   - 恢复后重新构建前端

### 🎯 效果与影响

**计数准确性提升**：
- 未读邮件计数现在准确显示，与后端数据库统计一致
- 不会出现1封信件显示2封的情况
- 计数实时更新，操作后立即反映最新状态

**数据保护增强**：
- 重装系统时，现有用户数据（包括注册时间）会被保留
- 管理员用户不会被重新创建，保持原有注册时间
- 用户邮箱正确保留，不会因为DNS配置更新而丢失

**用户体验改善**：
- 未读邮件计数准确，用户可以准确了解未读邮件数量
- 用户数据保护，重装系统不会丢失用户信息
- 系统更加稳定和可靠

---

## 🎉 历史版本 - V3.4.2 (2025-12-04) - 邮件页面UI全面优化与统一

### 🎊 版本亮点

**V3.4.2 是一个UI/UX优化版本，全面优化了邮件页面的UI设计，将已发送文件夹的现代化卡片设计统一应用到所有邮件文件夹，提升了整体视觉一致性和用户体验，同时保持了每个文件夹的独特颜色主题。**

#### 🎨 邮件文件夹UI统一优化

**优化背景**：
- 已发送文件夹采用了现代化的卡片设计，视觉效果更美观
- 其他文件夹（收件箱、草稿箱、垃圾邮件、已删除、自定义文件夹）的UI设计不够统一
- 需要将优化的UI设计同步到所有文件夹，保持视觉一致性

**解决方案**：
- **UI设计统一**：将已发送文件夹的优化UI设计同步到所有其他文件夹
- **颜色主题保持**：每个文件夹保持各自的颜色主题，体现功能区分
- **交互体验提升**：统一的悬停效果、选中状态、操作按钮和过渡动画
- **结构优化**：修复了多余的 `</transition-group>` 标签，确保模板结构正确

#### 🔧 主要优化内容

**标题栏统一设计**：
- **渐变背景**：所有文件夹使用统一的渐变背景设计（backdrop-blur效果）
- **图标卡片**：统一的图标容器设计，使用渐变背景的圆角卡片
- **标题文字**：统一的标题文字样式，使用渐变文字效果
- **刷新按钮**：统一的刷新按钮样式和交互效果

**邮件项布局统一**：
- **圆角卡片设计**：所有邮件项使用统一的 `rounded-2xl` 圆角设计
- **选中状态指示**：使用左侧渐变条替代红色边框，视觉效果更优雅
- **统一间距**：统一的 `p-5`、`p-6` 间距设计
- **统一阴影**：统一的阴影效果和悬停动画

**信息展示优化**：
- **发件人/收件人信息**：统一的图标和标签样式展示
- **邮件主题**：统一的字体大小和粗体样式
- **底部信息栏**：统一的时间、状态标签设计
- **状态标签**：统一的"新邮件"、"已查看"标签样式

**操作按钮统一**：
- **悬停显示**：统一的 `opacity-0 group-hover:opacity-100` 悬停显示效果
- **按钮样式**：统一的按钮样式和过渡动画
- **下拉菜单**：统一的下拉菜单设计和定位

**空状态和加载状态**：
- **空状态设计**：统一的空状态图标、文字和布局
- **加载动画**：统一的加载动画和文字提示

#### 📋 各文件夹颜色主题

**收件箱 (Inbox)**：
- **颜色主题**：蓝色系（blue/indigo）
- **渐变背景**：`from-blue-50/80 via-indigo-50/80 to-purple-50/80`
- **图标背景**：`from-blue-500 to-indigo-600`
- **文字颜色**：`from-blue-700 to-indigo-700`

**已发送 (Sent)**：
- **颜色主题**：绿色系（emerald/green/teal）
- **渐变背景**：`from-emerald-50/80 via-green-50/80 to-teal-50/80`
- **图标背景**：`from-emerald-500 to-green-600`
- **文字颜色**：`from-emerald-700 to-green-700`

**草稿箱 (Drafts)**：
- **颜色主题**：黄色系（yellow/amber）
- **渐变背景**：`from-yellow-50/80 via-amber-50/80 to-orange-50/80`
- **图标背景**：`from-yellow-500 to-amber-600`
- **文字颜色**：`from-yellow-700 to-amber-700`

**垃圾邮件 (Spam)**：
- **颜色主题**：红色系（red/pink）
- **渐变背景**：`from-red-50/80 via-pink-50/80 to-rose-50/80`
- **图标背景**：`from-red-500 to-pink-600`
- **文字颜色**：`from-red-700 to-pink-700`

**已删除 (Trash)**：
- **颜色主题**：灰色系（gray/slate）
- **渐变背景**：`from-gray-50/80 via-slate-50/80 to-zinc-50/80`
- **图标背景**：`from-gray-500 to-slate-600`
- **文字颜色**：`from-gray-700 to-slate-700`

**自定义文件夹 (Custom Folders)**：
- **颜色主题**：紫色系（indigo/purple）
- **渐变背景**：`from-indigo-50/80 via-purple-50/80 to-violet-50/80`
- **图标背景**：`from-indigo-500 to-purple-600`
- **文字颜色**：`from-indigo-700 to-purple-700`

#### 📋 实现细节

**修复的编译错误**：

1. **Invalid end tag** (line 558)
   - **原因**：多余的 `</transition-group>` 标签，`transition-group` 已经在第525行正确关闭
   - **修复**：移除第558行多余的 `</transition-group>` 标签
   - **影响**：修复了Vue编译错误，确保前端可以成功构建

**代码修改**：

**主要修改文件**：
- `frontend/src/modules/Mail.vue` - 全面优化所有文件夹的UI设计

**修改内容**：
1. 将已发送文件夹的优化UI设计同步到收件箱
2. 将已发送文件夹的优化UI设计同步到草稿箱
3. 将已发送文件夹的优化UI设计同步到垃圾邮件
4. 将已发送文件夹的优化UI设计同步到已删除
5. 将已发送文件夹的优化UI设计同步到自定义文件夹
6. 修复多余的 `</transition-group>` 标签
7. 保持每个文件夹的独特颜色主题

#### 🚀 升级步骤

**从 V3.4.1 或更早版本升级到 V3.4.2**：

1. **备份系统**：
   ```bash
   # 备份前端代码
   cp -r frontend/src/modules/Mail.vue frontend/src/modules/Mail.vue.bak
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull
   
   # 或手动更新 frontend/src/modules/Mail.vue
   ```

3. **重新构建前端**：
   ```bash
   # 重新构建前端
   cd frontend
   npm run build
   
   # 或使用部署脚本
   cd ..
   ./start.sh rebuild
   ```

4. **验证功能**：
   ```bash
   # 检查前端构建是否成功
   ls -la frontend/dist/
   
   # 访问邮件页面，验证所有文件夹的UI显示正常
   # 检查浏览器控制台是否有错误
   # 测试各个文件夹的交互功能
   ```

#### 📝 注意事项

1. **UI验证**：
   - 升级后检查所有文件夹的UI显示是否统一
   - 验证每个文件夹的颜色主题是否正确
   - 检查交互功能（悬停、点击、选中状态）是否正常

2. **功能测试**：
   - 测试收件箱的邮件列表显示
   - 测试已发送文件夹的邮件列表显示
   - 测试草稿箱、垃圾邮件、已删除文件夹的显示
   - 测试自定义文件夹的显示
   - 测试所有文件夹的交互功能（移动、删除等）

3. **回滚方案**：
   - 如果升级后出现问题，可以使用备份文件恢复
   - 恢复后重新构建前端

### 🎯 效果与影响

**UI一致性提升**：
- 所有文件夹使用统一的UI设计语言
- 视觉一致性显著提升，用户体验更加统一
- 界面更加美观和专业

**用户体验改善**：
- 统一的交互体验，降低学习成本
- 更清晰的视觉层次和信息展示
- 更流畅的动画和过渡效果

**代码质量提升**：
- 统一的UI设计模式，提升代码可维护性
- 修复了编译错误，确保前端可以成功构建
- 代码结构更加清晰和规范

---

## 🎉 历史版本 - V3.4.1 (2025-12-04) - 邮件页面重构与编译问题修复

### 🎊 版本亮点

**V3.4.1 是一个前端编译问题修复版本，全面重构了 Mail.vue 邮件页面，修复了所有 Vue 模板编译错误，解决了 v-if/v-else 链式问题、标签匹配问题和模板结构问题，确保了前端可以成功编译和构建。**

#### 📧 邮件页面全面重构

**问题背景**：
- Mail.vue 组件存在多个 Vue 编译错误，导致前端构建失败
- `v-if`/`v-else-if`/`v-else` 指令链式不正确，缺少相邻的 `v-if`
- 存在无效的结束标签，HTML 结构不匹配
- 嵌套的 `template` 标签导致条件渲染逻辑混乱

**解决方案**：
- **模板结构修复**：全面审查和修复所有模板结构问题
- **条件渲染优化**：修复所有 `v-if`/`v-else-if`/`v-else` 链式问题
- **标签匹配修复**：移除冗余的结束标签，确保所有标签正确匹配
- **代码简化**：将复杂的嵌套 `template` 标签替换为简单的 `span` 元素

#### 🔧 主要修复内容

**v-if/v-else 链式修复**：
- **问题**：`v-else-if="view==='compose'"` 缺少相邻的 `v-if`，因为前面的 `v-if` 块被提前关闭
- **解决**：移除多余的 `</div>` 标签，确保 `v-if`/`v-else-if` 链式正确
- **位置**：修复了自定义文件夹视图和写邮件视图之间的条件渲染链

**模板标签优化**：
- **问题**：嵌套的 `template` 标签导致 Vue 编译器混淆
- **解决**：将嵌套的 `template` 标签替换为 `span` 元素
- **示例**：
  ```vue
  <!-- 修复前 -->
  <template v-if="attachments.length > 0">
    <span>包含 {{ attachments.length }} 个附件</span>
    <span v-if="isLargeFile">...</span>
    <span v-else>，正在处理中...</span>
  </template>
  
  <!-- 修复后 -->
  <span v-if="attachments.length > 0">
    包含 {{ attachments.length }} 个附件
    <span v-if="isLargeFile">...</span>
    <span v-if="!isLargeFile">，正在处理中...</span>
  </span>
  ```

**结束标签修复**：
- **问题**：存在冗余的 `</div>` 标签，导致 HTML 结构不匹配
- **解决**：移除所有冗余的结束标签，确保标签正确匹配
- **位置**：修复了主内容区域和模态框区域的标签匹配问题

**模态框结构优化**：
- **问题**：邮件详情、文件夹管理等模态框的标签嵌套不正确
- **解决**：确保所有模态框正确嵌套在最外层容器内
- **结构**：确保最外层 `div` 包含所有内容，包括所有模态框

#### 📋 实现细节

**修复的编译错误**：

1. **v-else/v-else-if has no adjacent v-if or v-else-if** (line 1108)
   - **原因**：前面的 `v-if` 块被多余的 `</div>` 提前关闭
   - **修复**：移除多余的 `</div>`，确保条件渲染链正确

2. **v-else/v-else-if has no adjacent v-if or v-else-if** (lines 1391, 1393)
   - **原因**：嵌套的 `template` 标签导致条件渲染链混乱
   - **修复**：将嵌套的 `template` 替换为 `span`，使用独立的 `v-if` 条件

3. **Invalid end tag** (line 1810)
   - **原因**：冗余的 `</div>` 标签
   - **修复**：移除冗余的结束标签

4. **Invalid end tag** (line 1618)
   - **原因**：主内容区域和容器区域的标签匹配错误
   - **修复**：移除错误的结束标签，确保结构正确

**代码修改**：

**主要修改文件**：
- `frontend/src/modules/Mail.vue` - 全面重构模板结构

**修改内容**：
1. 修复所有 `v-if`/`v-else-if`/`v-else` 链式问题
2. 优化条件渲染逻辑，简化模板结构
3. 修复所有标签匹配问题
4. 确保所有模态框正确嵌套

#### 🚀 升级步骤

**从 V3.4.0 或更早版本升级到 V3.4.1**：

1. **备份系统**：
   ```bash
   # 备份前端代码
   cp -r frontend/src/modules/Mail.vue frontend/src/modules/Mail.vue.bak
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull
   
   # 或手动更新 frontend/src/modules/Mail.vue
   ```

3. **重新构建前端**：
   ```bash
   # 重新构建前端
   cd frontend
   npm run build
   
   # 或使用部署脚本
   cd ..
   ./start.sh rebuild
   ```

4. **验证功能**：
   ```bash
   # 检查前端构建是否成功
   ls -la frontend/dist/
   
   # 访问邮件页面，验证功能正常
   # 检查浏览器控制台是否有错误
   ```

#### 📝 注意事项

1. **编译验证**：
   - 升级后务必重新构建前端，确保编译成功
   - 检查浏览器控制台，确保没有运行时错误

2. **功能测试**：
   - 测试邮件列表显示功能
   - 测试写邮件功能
   - 测试邮件详情查看功能
   - 测试文件夹管理功能

3. **回滚方案**：
   - 如果升级后出现问题，可以使用备份文件恢复
   - 恢复后重新构建前端

### 🎯 效果与影响

**编译问题解决**：
- 彻底解决了所有 Vue 编译错误
- 前端可以成功编译和构建
- 消除了构建过程中的警告和错误

**代码质量提升**：
- 模板结构更加清晰和规范
- 条件渲染逻辑更加简洁
- 代码可维护性显著提升

**用户体验改善**：
- 邮件页面功能完全正常
- 所有交互功能正常工作
- 界面显示正确，无结构错误

---

## 🎉 历史版本 - V3.4.0 (2025-12-03) - 脚本执行超时机制优化

### 🎊 版本亮点

**V3.4.0 是一个系统稳定性优化版本，为脚本执行添加了智能超时机制，解决了长时间操作（如DNS配置、系统更新）导致的超时问题，提升了系统的可靠性和用户体验。**

#### ⏱️ 脚本执行超时机制

**问题背景**：
- DNS配置等操作可能涉及系统软件包更新，耗时较长（可能超过10分钟）
- 之前的实现没有超时机制，导致前端长时间等待或操作失败
- 系统更新时可能下载大量软件包，需要更长的执行时间

**解决方案**：
- **智能超时管理**：根据脚本类型和操作自动设置合适的超时时间
- **长时间操作支持**：为可能涉及系统更新的操作设置30分钟超时
- **优雅终止机制**：超时时先尝试优雅终止，避免数据丢失
- **详细日志记录**：记录超时时间、操作类型和执行状态

#### 🔧 超时时间配置

**默认超时**：10分钟（600000毫秒）
- 适用于常规操作，如用户管理、邮件操作等

**系统更新操作**：30分钟（1800000毫秒）
- `dns_setup.sh configure-bind` - DNS配置（可能安装/更新Bind）
- `dns_setup.sh install` - DNS服务安装
- `mail_setup.sh install` - 邮件服务安装
- `security.sh harden` - 安全加固（可能安装软件包）

**数据库初始化**：20分钟（1200000毫秒）
- `db_setup.sh init` - 数据库初始化

#### 🛡️ 超时处理机制

**优雅终止流程**：
1. 检测到超时后，先发送 `SIGTERM` 信号尝试优雅终止
2. 等待5秒，如果进程仍未退出，发送 `SIGKILL` 强制终止
3. 记录超时日志，包含操作类型、超时时间和终止方式
4. 返回退出码124（timeout标准退出码）

**日志记录**：
- 操作开始时记录超时时间设置
- 超时时记录警告信息和终止过程
- 提供用户友好的提示信息，说明可能的原因

#### 📋 实现细节

**后端修改**（`backend/dispatcher/server.js`）：

1. **超时时间判断逻辑**：
   ```javascript
   let timeoutMs = 600000 // 默认10分钟
   const firstArg = args[0] || ''
   
   // 可能涉及系统更新的操作，设置30分钟超时
   if (scriptName === 'dns_setup.sh' && (firstArg === 'configure-bind' || firstArg === 'install')) {
     timeoutMs = 1800000 // 30分钟
   } else if (scriptName === 'mail_setup.sh' && firstArg === 'install') {
     timeoutMs = 1800000 // 30分钟
   } else if (scriptName === 'security.sh' && firstArg === 'harden') {
     timeoutMs = 1800000 // 30分钟
   } else if (scriptName === 'db_setup.sh' && firstArg === 'init') {
     timeoutMs = 1200000 // 20分钟
   }
   ```

2. **超时定时器设置**：
   ```javascript
   let timeoutHandle = null
   let isTimedOut = false
   
   if (timeoutMs > 0) {
     timeoutHandle = setTimeout(() => {
       if (!child.killed && child.exitCode === null) {
         isTimedOut = true
         // 记录超时日志
         // 尝试优雅终止
         child.kill('SIGTERM')
         // 5秒后强制终止
         setTimeout(() => {
           if (!child.killed && child.exitCode === null) {
             child.kill('SIGKILL')
           }
         }, 5000)
       }
     }, timeoutMs)
   }
   ```

3. **超时日志记录**：
   ```javascript
   if (isTimedOut) {
     out.write(`[${endTime}] [WARNING] ⚠️ 脚本执行超时（${Math.floor(timeoutMs / 60000)}分钟），请检查系统状态\n`)
     out.write(`[${endTime}] [INFO] 提示: 如果系统正在更新软件包，这是正常的，请稍后重试\n`)
   }
   ```

#### 🚀 升级步骤

**从 V3.3.3 或更早版本升级到 V3.4.0**：

1. **备份系统**：
   ```bash
   # 备份数据库
   ./start.sh backup
   
   # 备份配置文件
   cp -r backend/dispatcher/server.js backend/dispatcher/server.js.bak
   ```

2. **更新代码**：
   ```bash
   # 拉取最新代码
   git pull
   
   # 或手动更新 backend/dispatcher/server.js
   ```

3. **重启调度层服务**：
   ```bash
   # 重启调度层服务以应用新代码
   systemctl restart mail-ops-dispatcher
   
   # 检查服务状态
   systemctl status mail-ops-dispatcher
   ```

4. **验证功能**：
   ```bash
   # 测试DNS配置（应该支持30分钟超时）
   # 在前端执行DNS配置操作，观察日志
   tail -f /var/log/mail-ops/operations.log
   ```

#### 📝 注意事项

1. **超时时间调整**：
   - 如果某些操作经常超时，可以适当增加超时时间
   - 修改 `backend/dispatcher/server.js` 中的超时时间配置

2. **系统更新**：
   - 如果系统正在更新软件包，操作可能需要更长时间
   - 建议在网络状况良好时执行长时间操作

3. **日志查看**：
   - 超时操作会在日志中记录详细信息
   - 查看 `/var/log/mail-ops/operations.log` 了解超时原因

### 📋 详细更新内容

#### ⏱️ 超时机制实现

**超时时间配置**：
- 根据脚本名称和参数自动判断操作类型
- 为不同类型的操作设置合适的超时时间
- 在操作开始时记录超时时间设置

**超时检测与处理**：
- 使用 `setTimeout` 实现超时检测
- 超时时先尝试优雅终止（SIGTERM）
- 5秒后如果仍未退出，强制终止（SIGKILL）
- 记录详细的超时日志和终止过程

**日志改进**：
- 操作开始时记录超时时间
- 超时时记录警告信息和提示
- 提供用户友好的错误提示

#### 🔧 代码修改

**主要修改文件**：
- `backend/dispatcher/server.js` - 添加超时机制

**修改内容**：
1. 在 `runScript` 函数中添加超时时间判断逻辑
2. 设置超时定时器，检测脚本执行时间
3. 超时时优雅终止进程，记录详细日志
4. 改进错误处理，区分超时和其他错误

### 🎯 效果与影响

**系统稳定性提升**：
- 解决了长时间操作导致的超时问题
- 避免了前端长时间等待无响应的情况
- 提供了清晰的超时提示和错误信息

**用户体验改善**：
- 长时间操作（如DNS配置）可以正常完成
- 超时时有明确的提示信息
- 日志记录详细，便于问题排查

**运维友好**：
- 超时时间可以根据实际情况调整
- 日志记录详细，便于问题诊断
- 支持优雅终止，避免数据丢失

---

## 🎉 历史版本 - V3.3.3 (2025-11-27) - 功能完善与问题修复

### 🎊 版本亮点

**V3.3.3 是一个功能完善与问题修复版本，修复了邮件页面分页功能缺失问题，增强了个人资料管理功能（密码更改后自动退出、头像同步更新），优化了版本API调用机制，提升了文件上传能力，进一步改善了用户体验和系统稳定性。**

#### 📧 邮件页面功能完善

**分页功能修复**：
- **问题**：草稿箱、垃圾邮件、已删除视图缺少分页组件，导致邮件列表显示异常
- **解决**：为所有邮件视图添加完整的分页组件，统一分页体验
- **实现**：
  - 草稿箱视图：添加黄色主题分页组件（`bg-yellow-600`）
  - 垃圾邮件视图：添加红色主题分页组件（`bg-red-600`）
  - 已删除视图：添加灰色主题分页组件（`bg-gray-600`）
- **功能**：所有视图支持页码导航、上一页/下一页、当前页高亮显示

**统一分页体验**：
- 所有邮件视图（收件箱、已发送、草稿、垃圾邮件、已删除）均支持分页浏览
- 使用统一的`visiblePages`、`goToPage`和`resetPagination`函数
- 分页组件显示当前页范围（如"显示第 1-8 条，共 20 条邮件"）

#### 👤 个人资料功能增强

**密码更改安全机制**：
- **功能**：个人资料页面更改密码后自动退出登录
- **流程**：
  1. 用户更改密码并保存
  2. 系统显示"密码已成功更改，请重新登录"提示
  3. 2秒后自动清除`sessionStorage`中的认证信息
  4. 自动跳转到登录页面，要求使用新密码重新登录
- **安全**：确保旧密码无法继续使用，防止会话劫持风险

**头像同步更新机制**：
- **Layout组件头像加载**：
  - 组件初始化时自动从数据库加载用户头像
  - 支持从`sessionStorage`解析用户名，确保头像正确加载
  - 头像加载失败时静默处理，显示默认图标
- **实时同步**：
  - 个人资料页面更新头像后，Layout组件右上角头像自动刷新
  - 通过`window.refreshUserAvatar`方法实现跨组件通信
- **头像显示优化**：
  - 修复NULL值处理（过滤"NULL"字符串）
  - URL格式规范化（确保以`/`开头）
  - 加载错误降级处理（显示默认图标）

#### 🔐 认证与API优化

**版本API调用修复**：
- **问题**：版本同步功能返回401未授权错误，数据库中存在重复和错误的xm用户记录
- **原因**：
  1. 数据库中存在多条xm用户记录，其中包含错误的记录（如username='xm@localhost', email='xm666@'）
  2. 版本同步时使用配置文件中的密码，但数据库中的密码可能不一致
- **解决**：
  1. **清理错误记录**：在版本同步前，先清理所有错误的xm用户记录（保留username='xm'且email='xm@localhost'的记录）
  2. **从数据库读取密码**：版本同步时从数据库读取xm用户信息，确保使用正确的用户数据
  3. **密码验证与同步**：如果验证失败，自动同步密码到数据库
  4. **401错误重试**：401错误时自动清理错误记录并重新同步密码，最多重试5次
- **日志**：添加详细的日志输出，记录清理、验证、同步、重试过程

**xm用户管理优化**：
- **问题**：数据库中可能存在多条xm用户记录，导致用户列表显示错乱
- **解决**：
  1. **初始化时清理**：在创建/更新xm用户前，先清理所有错误的记录
  2. **确保唯一性**：确保数据库中只有一个正确的xm用户（username='xm', email='xm@localhost'）
  3. **自动修复**：如果检测到错误的记录，自动删除并创建/更新正确的记录
- **实现**：
  ```bash
  # 清理错误的xm用户记录
  DELETE FROM app_users 
  WHERE (username='xm' OR email='xm@localhost' OR username='xm@localhost' OR email='xm') 
    AND NOT (username='xm' AND email='xm@localhost');
  ```

**密码同步机制**：
- **验证流程**：
  ```bash
  # 1. 先清理错误的xm用户记录
  mysql -e "DELETE FROM app_users WHERE ..."
  
  # 2. 从数据库查询xm用户信息
  xm_user_info=$(mysql -e "SELECT username, email FROM app_users WHERE username='xm' AND email='xm@localhost'")
  
  # 3. 如果用户存在，使用配置文件中的密码进行验证
  app_user.sh login xm "密码"
  
  # 4. 如果验证失败，同步密码
  app_user.sh update xm "" "xm@localhost" "密码"
  
  # 5. 同步后再次验证
  app_user.sh login xm "密码"
  ```
- **错误处理**：401错误时自动清理错误记录并触发密码同步，提高成功率

#### 📤 文件上传优化

**请求体大小限制增加**：
- **修改**：将Express请求体大小限制从`1mb`增加到`10mb`
- **原因**：Base64编码后约为原文件的1.33倍，5MB图片编码后约6.6MB
- **实现**：
  ```javascript
  app.use(express.json({ limit: '10mb' }))
  app.use(express.urlencoded({ extended: true, limit: '10mb' }))
  ```

**错误处理完善**：
- **Payload Too Large处理**：添加`entity.too.large`错误处理中间件
- **JSON格式响应**：确保返回JSON格式错误响应，而不是HTML错误页面
- **统一错误格式**：`{ success: false, error: '...', message: '...' }`

### 📋 详细更新内容

#### 📧 邮件页面分页功能修复实现

**前端修改**（`frontend/src/modules/Mail.vue`）：

1. **草稿箱视图分页组件**（第725行后）：
   ```vue
   <!-- 分页组件 -->
   <div v-if="totalPages > 1" class="mt-6 flex items-center justify-between border-t border-gray-200 pt-4">
     <!-- 分页按钮，使用黄色主题 -->
   </div>
   ```

2. **垃圾邮件视图分页组件**（第763行后）：
   ```vue
   <!-- 分页组件 -->
   <div v-if="totalPages > 1" class="mt-6 flex items-center justify-between border-t border-gray-200 pt-4">
     <!-- 分页按钮，使用红色主题 -->
   </div>
   ```

3. **已删除视图分页组件**（第820行后）：
   ```vue
   <!-- 分页组件 -->
   <div v-if="totalPages > 1" class="mt-6 flex items-center justify-between border-t border-gray-200 pt-4">
     <!-- 分页按钮，使用灰色主题 -->
   </div>
   ```

#### 👤 个人资料功能增强实现

**密码更改后自动退出**（`frontend/src/modules/Profile.vue`）：

1. **检测密码是否更改**：
   ```typescript
   const passwordChanged = !!formData.value.password
   ```

2. **保存成功后处理**：
   ```typescript
   if (passwordChanged) {
     success.value = '密码已成功更改，请重新登录'
     setTimeout(() => {
       sessionStorage.removeItem('apiAuth')
       router.push('/login')
     }, 2000)
   }
   ```

**Layout组件头像同步**（`frontend/src/components/Layout.vue`）：

1. **头像加载函数**：
   ```typescript
   const fetchUserAvatar = async () => {
     // 从数据库查询用户头像
     // 处理NULL值、URL格式等
   }
   ```

2. **暴露刷新方法**：
   ```typescript
   ;(window as any).refreshUserAvatar = fetchUserAvatar
   ```

3. **Profile组件调用**：
   ```typescript
   if ((window as any).refreshUserAvatar) {
     (window as any).refreshUserAvatar()
   }
   ```

#### 🔐 版本API调用修复实现

**xm用户清理与密码同步机制**（`start.sh`）：

1. **清理错误的xm用户记录**：
   ```bash
   # 在版本同步前，先清理所有错误的xm用户记录
   local db_pass=$(cat /etc/mail-ops/app-db.pass 2>/dev/null || echo "")
   if [[ -n "$db_pass" ]]; then
     mysql -u mailappuser --password="${db_pass}" mailapp -e \
       "DELETE FROM app_users WHERE (username='xm' OR email='xm@localhost' OR username='xm@localhost' OR email='xm') AND NOT (username='xm' AND email='xm@localhost');" 2>/dev/null || true
   fi
   ```

2. **从数据库读取xm用户信息**：
   ```bash
   # 从数据库查询xm用户信息
   local xm_user_info
   xm_user_info=$(mysql -u mailappuser --password="${db_pass}" mailapp -s -r -e \
     "SELECT username, email FROM app_users WHERE username='xm' AND email='xm@localhost' LIMIT 1;" 2>/dev/null | tail -1)
   
   if [[ -n "$xm_user_info" ]]; then
     log "从数据库找到xm用户，使用配置文件中的密码进行验证"
     xm_pass=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")
   else
     log "数据库中没有正确的xm用户，创建用户"
     # 创建xm用户
   fi
   ```

3. **密码验证**：
   ```bash
   test_result=$(app_user.sh login xm "${xm_pass}")
   if echo "$test_result" | grep -q '{"ok":true}'; then
     log "xm用户密码验证成功"
   else
     log "xm用户密码验证失败，尝试同步密码..."
     # 同步密码
   fi
   ```

4. **密码同步**：
   ```bash
   update_result=$(app_user.sh update xm "" "xm@localhost" "${xm_pass}")
   if echo "$update_result" | grep -q '{"ok":true}'; then
     log "xm用户密码同步成功"
     # 再次验证
   fi
   ```

5. **401错误重试**：
   ```bash
   if [[ "$response" == "401" && $attempt -lt $max_attempts ]]; then
     log "检测到401错误，清理错误的xm用户记录并重新同步密码..."
     # 先清理错误的xm用户记录
     mysql -u mailappuser --password="${db_pass}" mailapp -e \
       "DELETE FROM app_users WHERE ..." 2>/dev/null || true
     # 重新同步密码并验证
   fi
   ```

**xm用户初始化优化**（`start.sh`，第1102-1131行）：

1. **确保唯一性**：
   ```bash
   # 先清理所有错误的xm用户记录
   mysql -u root mailapp <<EOF 2>/dev/null || log "清理xm用户记录失败"
   DELETE FROM app_users 
   WHERE (username='xm' OR email='xm@localhost' OR username='xm@localhost' OR email='xm') 
     AND NOT (username='xm' AND email='xm@localhost');
   EOF
   ```

2. **检查正确的xm用户是否存在**：
   ```bash
   xm_exists=$(mysql -u root mailapp -e \
     "SELECT COUNT(*) FROM app_users WHERE username='xm' AND email='xm@localhost' LIMIT 1;" 2>/dev/null | tail -1)
   
   if [[ "${xm_exists}" -gt 0 ]]; then
     log "xm管理员用户已存在且正确，更新密码"
     # 更新密码
   else
     log "xm管理员用户不存在或数据错误，创建/修复用户"
     # 创建/修复用户
   fi
   ```

#### 📤 文件上传优化实现

**请求体大小限制**（`backend/dispatcher/server.js`）：

1. **增加限制**：
   ```javascript
   app.use(express.json({ limit: '10mb' }))
   app.use(express.urlencoded({ extended: true, limit: '10mb' }))
   ```

2. **错误处理中间件**：
   ```javascript
   app.use((err, req, res, next) => {
     if (err.type === 'entity.too.large') {
       return res.status(413).json({
         success: false,
         error: '请求体过大',
         message: '上传的文件大小超过限制（最大10MB）'
       })
     }
   })
   ```

### 🚀 升级步骤

1. **备份当前系统**
   - 备份数据库：`mysqldump -u root mailapp > backup.sql`
   - 备份配置文件：`cp -r /etc/mail-ops /backup/mail-ops`

2. **更新代码**
   - 拉取最新代码或手动更新相关文件
   - 确保所有代码文件已更新到V3.3.3

3. **重启服务**
   ```bash
   sudo systemctl restart mail-ops-dispatcher
   sudo systemctl restart httpd
   ```

4. **验证功能**
   - 测试邮件页面分页功能（草稿、垃圾邮件、已删除）
   - 测试个人资料密码更改后自动退出
   - 测试头像上传和显示
   - 检查版本API调用是否正常

### ⚠️ 注意事项

1. **密码同步**：
   - 如果版本API调用失败，检查`/etc/mail-ops/xm-admin.pass`文件中的密码
   - 确保数据库中的xm用户密码与配置文件一致

2. **头像上传**：
   - 支持最大5MB的图片文件（Base64编码后约6.6MB）
   - 建议使用200x200像素的头像图片

3. **分页功能**：
   - 所有邮件视图现在都支持分页
   - 分页大小可在系统设置中配置

## 🎉 最新版本 - V3.3.2 (2025-11-27) - 认证系统优化与数据库修复

### 🎊 版本亮点

**V3.3.2 是一个认证系统优化与数据库修复版本，重构了认证系统，实现了动态密码管理，修复了数据库连接问题，优化了前端认证逻辑，提升了系统的安全性和可维护性。**

#### 🔄 认证系统重构

**统一数据库验证**：
- 删除xm用户特殊处理逻辑，所有用户（包括xm管理员）统一通过数据库验证
- xm用户存储在`app_users`表中，与其他用户使用相同的验证流程
- 简化认证逻辑，提高代码可维护性

**动态密码管理**：
- 创建xm密码配置文件：`/etc/mail-ops/xm-admin.pass`
- 首次创建时使用默认密码`xm666@`
- 文件权限：`root:xm`，`640`（仅root和xm用户可读）
- 所有需要xm密码的地方改为从配置文件动态读取
- 支持密码动态修改，修改后更新配置文件即可

**系统用户同步**：
- xm系统用户密码与数据库密码保持一致
- 创建/更新xm用户时，同时更新系统用户密码和数据库密码
- 确保系统用户、数据库用户、配置文件三者密码一致

#### 🛠️ 数据库连接修复

**密码不匹配问题修复**：
- 问题：`mailappuser`数据库用户密码与密码文件`/etc/mail-ops/app-db.pass`不匹配
- 解决：更新数据库用户密码，确保与密码文件一致
- 验证：测试数据库连接，确认连接正常

**脚本创建逻辑优化**：
- 问题：`CREATE USER IF NOT EXISTS`不会更新已存在用户的密码
- 解决：在`init_schema()`函数中添加`ALTER USER`语句
- 效果：重装时自动更新数据库用户密码，确保与密码文件一致
- 应用：`app_user.sh`和`start.sh`中的数据库创建逻辑都已更新

**自动密码同步**：
- 重装时自动检测密码文件
- 如果密码文件存在，使用文件中的密码
- 如果密码文件不存在，创建新文件并使用默认密码
- 确保数据库用户密码始终与密码文件一致

#### 🐛 脚本语法错误修复

**SQL结构修复**：
- 问题：`app_user.sh`第126行附近SQL heredoc结构错误
- 原因：`app_accounts`表创建语句缺少正确的SQL块开始标记
- 解决：修复SQL heredoc结构，确保`app_accounts`表在正确的SQL块中创建
- 验证：测试脚本执行，确认语法错误已修复

#### 🎯 前端认证优化

**动态认证读取**：
- `Mail.vue`：用户列表查询改为从`sessionStorage`读取认证信息
- `versionManager.ts`：版本API调用改为从`sessionStorage`读取认证信息
- `Register.vue`和`Reset.vue`：保留fallback机制，但优先使用`sessionStorage`
- 移除所有硬编码的认证信息，提高安全性

**Fallback机制优化**：
- 保留必要的fallback，确保未登录状态下的基本功能
- Register和Reset操作在未登录时使用fallback认证
- 主要功能优先使用`sessionStorage`中的认证信息

#### 📝 代码清理

**移除硬编码**：
- 移除`server.js`中xm用户的特殊处理代码
- 移除`start.sh`中所有硬编码的`xm666@`密码
- 移除systemd服务配置中的`API_PASS`环境变量
- 更新日志输出，使用"从配置文件读取"替代硬编码显示

**配置文件管理**：
- 创建统一的密码配置文件管理机制
- 所有需要xm密码的地方都从配置文件读取
- 支持密码动态修改，无需修改代码

### 📋 详细更新内容

#### 🔄 认证系统重构实现

**后端修改**（`backend/dispatcher/server.js`）：

1. **删除特殊处理**
   ```javascript
   // 删除前：
   // 特殊处理：xm管理员用户（使用环境变量验证）
   const apiUser = process.env.API_USER || 'xm'
   const apiPass = process.env.API_PASS || 'xm666@'
   if (credentials.name === apiUser && credentials.pass === apiPass) {
     next()
     return
   }
   
   // 删除后：
   // 所有用户统一通过数据库验证
   const result = execSync(`cd /bash && ./backend/scripts/app_user.sh login "${credentials.name}" "${credentials.pass}"`)
   ```

2. **统一验证流程**
   - 所有用户（包括xm）都通过`app_user.sh login`验证
   - xm用户存储在`app_users`表中，使用相同的验证逻辑
   - 简化代码，提高可维护性

**配置文件创建**（`start.sh`）：

1. **创建密码配置文件**
   ```bash
   # 创建xm管理员密码配置文件（如果不存在）
   if [[ ! -f /etc/mail-ops/xm-admin.pass ]]; then
     echo "xm666@" > /etc/mail-ops/xm-admin.pass
     chown root:xm /etc/mail-ops/xm-admin.pass
     chmod 640 /etc/mail-ops/xm-admin.pass
   fi
   
   # 读取xm管理员密码
   XM_ADMIN_PASS=$(cat /etc/mail-ops/xm-admin.pass 2>/dev/null || echo "xm666@")
   ```

2. **动态密码使用**
   - 设置xm系统用户密码：`echo "xm:${XM_ADMIN_PASS}" | chpasswd`
   - 创建/更新xm数据库用户：使用`${XM_ADMIN_PASS}`
   - 版本API调用：从配置文件读取密码

#### 🛠️ 数据库连接修复实现

**数据库密码同步**（`backend/scripts/app_user.sh`）：

1. **init_schema函数优化**
   ```sql
   CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
   -- 如果用户已存在，更新密码（确保密码与密码文件一致）
   ALTER USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';
   ```

2. **密码文件读取逻辑**
   ```bash
   # 优先从秘密文件读取密码，其次读取环境变量，最后回退默认值
   APP_DB_PASS_FILE_DEFAULT="/etc/mail-ops/app-db.pass"
   if [[ -n "${APP_DB_PASS_FILE:-}" && -f "${APP_DB_PASS_FILE}" ]]; then
     DB_PASS=$(cat "${APP_DB_PASS_FILE}")
   elif [[ -f "${APP_DB_PASS_FILE_DEFAULT}" ]]; then
     DB_PASS=$(cat "${APP_DB_PASS_FILE_DEFAULT}")
   else
     DB_PASS=${APP_DB_PASS:-mailapppass}
   fi
   ```

**start.sh数据库创建优化**：

1. **手动创建逻辑优化**
   ```bash
   CREATE USER IF NOT EXISTS 'mailappuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/app-db.pass)';
   -- 如果用户已存在，更新密码（确保密码与密码文件一致）
   ALTER USER 'mailappuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/app-db.pass)';
   ```

#### 🐛 脚本语法错误修复实现

**SQL结构修复**（`backend/scripts/app_user.sh`）：

1. **修复前的问题**
   ```bash
   SQL
   -- 普通登录用户表（与超级管理员 xm 区分），可扩展角色/状态
   CREATE TABLE IF NOT EXISTS app_accounts (
   ```

2. **修复后的结构**
   ```bash
   SQL
     mysql -u root ${DB_NAME} <<SQL
   -- 普通登录用户表（与超级管理员 xm 区分），可扩展角色/状态
   CREATE TABLE IF NOT EXISTS app_accounts (
   ```

#### 🎯 前端认证优化实现

**Mail.vue优化**：

```typescript
// 修改前：
'Authorization': `Basic ${btoa('xm:xm666@')}`

// 修改后：
const auth = sessionStorage.getItem('apiAuth')
if (!auth) {
  console.error('未找到认证信息，无法查询用户列表')
  return
}
'Authorization': `Basic ${auth}`
```

**versionManager.ts优化**：

```typescript
// 修改前：
'Authorization': `Basic ${btoa('xm:xm666@')}`

// 修改后：
const auth = sessionStorage.getItem('apiAuth')
if (!auth) {
  console.warn('未找到认证信息，使用默认版本')
  return '2.5.5'
}
'Authorization': `Basic ${auth}`
```

### 🔧 升级步骤

1. **更新代码**
   - 确保所有代码文件已更新到V3.3.2
   - 检查`backend/dispatcher/server.js`已删除xm特殊处理
   - 检查`start.sh`已添加密码配置文件创建逻辑

2. **创建密码配置文件**
   - 如果文件不存在，系统会自动创建
   - 手动创建：`echo "xm666@" > /etc/mail-ops/xm-admin.pass`
   - 设置权限：`chown root:xm /etc/mail-ops/xm-admin.pass && chmod 640 /etc/mail-ops/xm-admin.pass`

3. **修复数据库密码**
   - 如果数据库连接失败，更新密码：`mysql -u root -e "ALTER USER 'mailappuser'@'localhost' IDENTIFIED BY '$(cat /etc/mail-ops/app-db.pass)';"`

4. **重启服务**
   - 重启调度层服务：`systemctl restart mail-ops-dispatcher`
   - 验证服务状态：`systemctl status mail-ops-dispatcher`

5. **测试验证**
   - 测试登录功能：使用xm用户登录
   - 测试数据库连接：`mysql -u mailappuser -p$(cat /etc/mail-ops/app-db.pass) mailapp -e "SELECT 1;"`
   - 测试版本API：`curl -H "Authorization: Basic $(echo -n 'xm:密码' | base64)" http://localhost:8081/api/version`

### ⚠️ 注意事项

1. **密码配置文件**：
   - 文件路径：`/etc/mail-ops/xm-admin.pass`
   - 文件权限：`640`（root:xm）
   - 修改密码时，需要同时更新数据库和配置文件

2. **数据库密码**：
   - 确保`mailappuser`用户密码与`/etc/mail-ops/app-db.pass`文件一致
   - 重装时会自动同步，但手动修改时需要注意一致性

3. **认证流程**：
   - 所有用户（包括xm）都通过数据库验证
   - xm用户必须存在于`app_users`表中
   - 如果xm用户不存在，需要先创建

4. **前端认证**：
   - 前端代码优先使用`sessionStorage`中的认证信息
   - Register和Reset操作保留fallback机制
   - 主要功能需要用户先登录

## 🎉 最新版本 - V3.3.1 (2025-11-26) - 个人资料管理功能

### 🎊 版本亮点

**V3.3.1 是一个个人资料管理功能版本，新增了完整的个人资料编辑页面和头像上传功能，用户可以方便地管理个人信息和头像，提升了系统的用户管理能力和用户体验。**

#### 🎨 个人资料编辑页面

**功能特性**：
- 新增独立的个人资料编辑页面（路由：`/profile`）
- 支持编辑用户名、邮箱、密码等个人信息
- 实时表单验证，确保数据有效性
- 友好的错误提示和成功反馈
- 支持表单重置功能，一键恢复原始数据

**技术实现**：
- 创建`frontend/src/modules/Profile.vue`组件
- 使用Vue 3 Composition API实现响应式表单
- 集成表单验证逻辑，支持邮箱格式和密码强度验证
- 使用`/api/ops`接口的`query-user-profile`操作查询用户信息
- 使用`app-update`操作更新用户信息

#### 📸 头像上传功能

**功能特性**：
- 支持JPG、PNG、GIF、WebP等常见图片格式
- 文件大小限制：最大5MB
- 实时图片预览功能
- Base64编码上传，简化文件处理
- 头像文件保存在`uploads/avatars/`目录
- 头像URL自动保存到数据库

**技术实现**：
- 前端使用`FileReader` API将图片转换为Base64编码
- 后端`/api/upload-avatar`接口接收Base64数据并保存为文件
- 使用`fs.writeFileSync`同步写入文件，确保文件保存成功
- 生成唯一文件名：`{username}_{timestamp}.{ext}`
- 文件路径格式：`/uploads/avatars/{filename}`

**文件上传流程**：
1. 用户选择图片文件
2. 前端验证文件类型和大小
3. 使用FileReader转换为Base64
4. 发送POST请求到`/api/upload-avatar`
5. 后端保存文件并更新数据库
6. 返回头像URL给前端
7. 前端更新预览显示

#### 🔄 数据库结构优化

**avatar字段添加**：
- 在`app_users`表中添加`avatar`字段（VARCHAR(500)）
- 字段类型：`VARCHAR(500) DEFAULT NULL`
- 存储头像文件的相对路径URL

**自动迁移支持**：
- 使用MySQL的`INFORMATION_SCHEMA`检查字段是否存在
- 如果字段不存在，自动执行`ALTER TABLE`添加字段
- 使用存储过程避免重复添加字段的错误

**多表同步更新**：
- 更新用户名时同步更新`mail_users`表
- 更新邮箱时同步更新`mail_users`和`virtual_users`表
- 确保邮件系统用户信息一致性

#### 🛠️ 后端API增强

**头像上传API**（`/api/upload-avatar`）：
- 接收Base64编码的图片数据
- 验证图片格式和文件大小
- 保存文件到`uploads/avatars/`目录
- 更新数据库`app_users`表的`avatar`字段
- 返回头像URL供前端使用

**用户资料查询API**（`/api/ops` - `query-user-profile`）：
- 根据用户名或邮箱查询用户信息
- 返回用户名、邮箱、头像URL
- 支持头像URL格式转换（相对路径转绝对路径）

**用户更新API优化**（`/api/ops` - `app-update`）：
- 支持头像字段更新
- 传递头像URL参数到`app_user.sh`脚本
- 同步更新多个相关表

#### 🎯 用户体验优化

**导航集成**：
- 在Layout组件右上角添加"个人资料"按钮
- 按钮位于用户信息和退出登录按钮之间
- 使用router-link实现路由跳转
- 集成用户操作日志记录

**界面设计**：
- 使用渐变背景（蓝色→靛蓝→紫色）
- 卡片式布局，清晰的视觉层次
- 响应式设计，适配不同屏幕尺寸
- 加载状态动画，提供视觉反馈

**交互优化**：
- 实时表单验证，即时反馈错误
- 成功提示自动消失（3秒后）
- 密码字段留空则不修改密码
- 头像预览支持移除功能

### 📋 详细更新内容

#### 🎨 个人资料编辑页面实现

**前端组件**（`frontend/src/modules/Profile.vue`）：

1. **组件结构**
   ```vue
   <template>
     <Layout>
       <div class="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
         <!-- 页面标题 -->
         <!-- 错误/成功提示 -->
         <!-- 个人资料表单 -->
       </div>
     </Layout>
   </template>
   ```

2. **表单字段**
   - 头像上传区域（支持预览和移除）
   - 用户名输入框
   - 邮箱输入框
   - 密码输入框（可选）
   - 确认密码输入框（仅在输入密码时显示）

3. **表单验证**
   - 邮箱格式验证：`/^[^\s@]+@[^\s@]+\.[^\s@]+$/`
   - 密码长度验证：至少6位
   - 密码确认验证：两次输入必须一致

4. **数据加载**
   ```typescript
   const loadUserProfile = async () => {
     // 调用query-user-profile API
     // 更新表单数据和头像预览
   }
   ```

5. **数据保存**
   ```typescript
   const saveProfile = async () => {
     // 验证表单数据
     // 上传头像（如果有）
     // 更新用户信息
     // 更新sessionStorage（如果用户名改变）
   }
   ```

#### 📸 头像上传功能实现

**前端实现**：

1. **文件选择处理**
   ```typescript
   const handleAvatarChange = (event: Event) => {
     // 验证文件类型和大小
     // 使用FileReader转换为Base64
     // 更新预览显示
   }
   ```

2. **Base64转换**
   ```typescript
   const reader = new FileReader()
   reader.onload = (e) => {
     avatarPreview.value = e.target?.result as string
   }
   reader.readAsDataURL(file)
   ```

3. **上传处理**
   ```typescript
   const uploadAvatar = async (): Promise<string | null> => {
     // 转换为Base64
     // 发送POST请求到/api/upload-avatar
     // 返回头像URL
   }
   ```

**后端实现**（`backend/dispatcher/server.js`）：

1. **头像上传目录**
   ```javascript
   const AVATAR_DIR = path.join(ROOT_DIR, 'uploads', 'avatars')
   fs.mkdirSync(AVATAR_DIR, { recursive: true })
   ```

2. **静态文件服务**
   ```javascript
   app.use('/uploads', express.static(path.join(ROOT_DIR, 'uploads')))
   ```

3. **上传API处理**
   ```javascript
   app.post('/api/upload-avatar', auth, (req, res) => {
     // 解析Base64数据
     // 验证文件类型和大小
     // 保存文件
     // 更新数据库
     // 返回头像URL
   })
   ```

#### 🔄 数据库结构优化实现

**数据库迁移**（`backend/scripts/app_user.sh`）：

1. **表结构更新**
   ```sql
   CREATE TABLE IF NOT EXISTS app_users (
     id INT AUTO_INCREMENT PRIMARY KEY,
     username VARCHAR(120) UNIQUE NOT NULL,
     email VARCHAR(255) UNIQUE NOT NULL,
     pass_hash CHAR(128) NOT NULL,
     avatar VARCHAR(500) DEFAULT NULL,
     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   ) ENGINE=InnoDB;
   ```

2. **自动迁移逻辑**
   ```sql
   SET @preparedStatement = (SELECT IF(
     (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
      WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'app_users'
      AND COLUMN_NAME = 'avatar') > 0,
     'SELECT 1',
     'ALTER TABLE app_users ADD COLUMN avatar VARCHAR(500) DEFAULT NULL'
   ));
   PREPARE alterIfNotExists FROM @preparedStatement;
   EXECUTE alterIfNotExists;
   ```

3. **更新函数增强**
   ```bash
   update_user() {
     local original_username="$1"
     local new_username="${2:-}"
     local email="${3:-}"
     local password="${4:-}"
     local avatar="${5:-}"
     # ... 处理avatar字段更新
   }
   ```

#### 🛠️ 后端API增强实现

**用户资料查询API**：

```javascript
if (action === 'query-user-profile') {
  // 查询用户信息
  const query = `mysql -u mailappuser -pmailapppass mailapp -s -r -e 
    "SELECT username, email, avatar FROM app_users 
     WHERE username='${username}' OR email='${username}' LIMIT 1;"`
  // 返回用户信息
}
```

**用户更新API优化**：

```javascript
case 'app-update':
  const avatarParam = (finalParams?.avatar && 
    finalParams.avatar !== 'null' && 
    finalParams.avatar !== 'undefined') ? finalParams.avatar : ''
  scriptName = 'app_user.sh'
  args = ['update', 
    finalParams?.original_username || finalParams?.username,
    finalParams?.new_username || '',
    finalParams?.email || '',
    passwordParam,
    avatarParam]
  break
```

### 🔧 升级步骤

1. **更新前端代码**
   - 确保`frontend/src/modules/Profile.vue`已创建
   - 确保`frontend/src/main.ts`已添加`/profile`路由
   - 确保`frontend/src/components/Layout.vue`已添加个人资料按钮

2. **更新后端代码**
   - 确保`backend/dispatcher/server.js`已添加头像上传API
   - 确保`backend/scripts/app_user.sh`已更新支持avatar字段

3. **数据库迁移**
   - 运行`app_user.sh schema`初始化或更新数据库结构
   - 或者手动执行SQL添加avatar字段

4. **创建上传目录**
   - 确保`uploads/avatars/`目录存在且可写
   - 设置适当的目录权限

5. **重启服务**
   - 重启Node.js调度层服务
   - 刷新前端页面

### ⚠️ 注意事项

1. **文件权限**：确保`uploads/avatars/`目录对Node.js进程可写
2. **文件大小**：建议限制上传文件大小，避免服务器存储压力
3. **文件类型**：严格验证文件类型，防止恶意文件上传
4. **数据库备份**：更新数据库结构前建议备份数据库
5. **测试验证**：在生产环境部署前，先在测试环境验证所有功能

## 🎉 最新版本 - V3.3.0 (2025-11-26) - 系统设置与交互优化 + 邮件页面动画优化

### 🎊 版本亮点

**V3.3.0 是一个系统设置与交互优化版本，修复了系统设置页面的按钮和选择器失效问题，优化了邮件页面的动画效果，将Settings页面独立分离，提升了用户交互体验和系统可用性。**

#### ⚙️ 系统设置按钮修复

**操作按钮修复**：
- 修复系统设置页面底部"重置"和"保存设置"按钮失效问题
- 添加`@click.stop`事件修饰符，防止事件冒泡被其他元素拦截
- 添加`type="button"`属性，确保按钮类型正确
- 添加`relative z-10`层级，确保按钮在其他元素之上
- 添加`cursor-pointer`样式，确保鼠标指针正确显示

**技术实现**：
- 在按钮容器添加`relative z-10`，提升按钮层级
- 使用`@click.stop`阻止事件冒泡，防止事件被拦截
- 添加调试信息（console.log），便于问题排查
- 优化按钮样式，统一交互体验

#### 📊 常规设置选择器修复

**用户分页大小选择器修复**：
- 修复用户分页大小下拉选择框失效问题
- 添加`@change.stop`和`@input.stop`事件处理
- 新增`handleUserPageSizeChange`函数处理变化
- 添加`cursor-pointer`确保鼠标指针正确
- 添加`pointer-events-none`到加载指示器，避免遮挡选择框

**时区选择器修复**：
- 修复时区下拉选择框失效问题
- 添加`@change.stop`和`@input.stop`事件处理
- 改进`onTimezoneChange`函数，更好地处理事件对象
- 添加`cursor-pointer`确保鼠标指针正确
- 优化事件处理逻辑，支持多种事件格式

**技术实现**：
- 使用`@change.stop`和`@input.stop`双重事件处理，确保兼容性
- 添加`@click.stop`防止点击事件被拦截
- 改进事件处理函数，支持event对象和直接值两种格式
- 添加详细的调试信息，便于问题排查

#### 🎨 邮件页面动画优化

**浮动动画效果**：
- 添加多种浮动邮件图标动画效果
  - `animate-float`：基础浮动动画（6秒循环）
  - `animate-float-delayed`：延迟浮动动画（8秒循环，延迟2秒）
  - `animate-float-slow`：慢速浮动动画（10秒循环，延迟1秒）
  - `animate-float-reverse`：反向浮动动画（7秒循环，延迟3秒）
- 每个动画都有独特的旋转和位移效果，创建生动的视觉体验

**邮件漂移动画**：
- 实现`animate-mail-drift`动画，邮件图标在页面中平滑漂移
- 12秒循环的复杂路径动画，包含X和Y轴的组合位移
- 创建动态的邮件主题背景效果

**列表过渡动画**：
- 使用Vue的`transition-group`组件实现邮件列表的进入/离开动画
- 邮件项进入时：淡入 + 向上位移 + 缩放效果
- 邮件项离开时：淡出 + 向左位移 + 缩放效果
- 支持平滑的列表重排动画

**邮件项动画**：
- 每个邮件项支持延迟动画（`animation-delay`）
- 创建依次出现的视觉效果，提升用户体验
- 使用`fadeInUp`动画，从下方淡入出现

**装饰元素动画**：
- 旋转动画：邮件图标缓慢旋转（20秒循环）
- 脉冲动画：装饰元素脉冲效果（3秒循环）
- 闪烁动画：粒子效果的闪烁动画
- 多种动画组合，创建丰富的视觉层次

**背景效果优化**：
- 网格背景图案：使用CSS渐变创建网格背景
- 渐变背景：多层次渐变背景（蓝色→靛蓝→紫色）
- 装饰线条：水平渐变线条，增加视觉深度
- 粒子效果：小圆点的闪烁动画，增加动态感

**技术实现**：
- 使用CSS `@keyframes`定义动画
- 使用`transform`属性实现硬件加速
- 优化动画性能，确保60fps流畅运行
- 使用`opacity`和`transform`组合，避免重排和重绘

#### 🔧 Settings页面独立分离

**独立路由页面**：
- Settings页面从Dashboard中完全分离，成为独立的路由页面
- 路由路径：`/settings`
- 独立组件文件：`frontend/src/modules/Settings.vue`
- 独立的页面布局和样式

**权限控制**：
- Settings页面仅管理员可访问（`meta: { requiresAdmin: true }`）
- 普通用户访问时自动重定向到邮件页面
- 与Dashboard页面共享相同的权限验证逻辑

**代码结构优化**：
- 独立组件文件，提升代码可维护性
- 模块化设计，便于后续功能扩展
- 清晰的代码结构，易于理解和维护

**导航集成**：
- Settings页面已集成到左侧导航栏
- 管理员用户可以通过导航栏快速访问
- 统一的导航体验，与其他页面保持一致

**技术实现**：
- 在`frontend/src/main.ts`中添加Settings路由
- 使用Vue Router进行路由管理
- 路由守卫自动处理权限验证
- 与Layout组件集成，共享导航栏

#### 🎯 用户体验优化

**交互体验提升**：
- 统一按钮和选择器的交互样式
- 优化加载状态的显示，避免遮挡交互元素
- 添加详细的调试信息，便于问题排查
- 改进错误处理和用户反馈
- 邮件页面动画提升视觉体验
- Settings页面独立，提升导航便利性

**代码质量提升**：
- 统一事件处理方式
- 优化代码结构，提高可维护性
- 添加详细的注释和文档
- 改进错误处理机制
- 模块化设计，提升代码组织性

### 📋 详细更新内容

#### 🎨 邮件页面动画优化实现

**前端修改**（`frontend/src/modules/Mail.vue`）：

1. **浮动动画定义**
   ```css
   @keyframes float {
     0%, 100% { transform: translateY(0px) rotate(0deg); }
     50% { transform: translateY(-20px) rotate(5deg); }
   }
   
   @keyframes float-delayed {
     0%, 100% { transform: translateY(0px) rotate(0deg); }
     50% { transform: translateY(-15px) rotate(-3deg); }
   }
   
   @keyframes float-slow {
     0%, 100% { transform: translateY(0px) rotate(0deg); }
     50% { transform: translateY(-10px) rotate(2deg); }
   }
   
   @keyframes float-reverse {
     0%, 100% { transform: translateY(0px) rotate(0deg); }
     50% { transform: translateY(15px) rotate(-2deg); }
   }
   ```

2. **邮件漂移动画**
   ```css
   @keyframes mail-drift {
     0% { transform: translateX(0px) translateY(0px); }
     25% { transform: translateX(10px) translateY(-5px); }
     50% { transform: translateX(-5px) translateY(-10px); }
     75% { transform: translateX(-10px) translateY(5px); }
     100% { transform: translateX(0px) translateY(0px); }
   }
   ```

3. **邮件列表过渡动画**
   ```vue
   <transition-group name="email-list" tag="div">
     <div v-for="(email, index) in paginatedEmails" 
          :key="email.id"
          :style="{ 'animation-delay': `${index * 50}ms` }"
          class="email-item">
       <!-- 邮件内容 -->
     </div>
   </transition-group>
   ```

4. **邮件项进入动画**
   ```css
   @keyframes fadeInUp {
     from {
       opacity: 0;
       transform: translateY(20px);
     }
     to {
       opacity: 1;
       transform: translateY(0);
     }
   }
   
   .email-item {
     animation: fadeInUp 0.5s ease-out forwards;
     opacity: 0;
   }
   ```

5. **背景效果实现**
   ```vue
   <!-- 网格背景 -->
   <div class="absolute inset-0 bg-grid-pattern opacity-5"></div>
   
   <!-- 渐变背景 -->
   <div class="absolute inset-0 bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50"></div>
   
   <!-- 装饰线条 -->
   <div class="absolute top-1/4 left-0 w-full h-px bg-gradient-to-r from-transparent via-blue-300 to-transparent opacity-30"></div>
   ```

#### 🔧 Settings页面独立分离实现

**路由配置**（`frontend/src/main.ts`）：

1. **导入Settings组件**
   ```typescript
   import Settings from './modules/Settings.vue'
   ```

2. **添加Settings路由**
   ```typescript
   const router = createRouter({
     history: createWebHistory(),
     routes: [
       // ... 其他路由
       { path: '/settings', component: Settings, meta: { requiresAdmin: true } }
     ]
   })
   ```

3. **权限验证**
   ```typescript
   router.beforeEach((to, from, next) => {
     // ... 认证检查
     
     // 检查是否需要管理员权限
     if (to.meta.requiresAdmin) {
       if (!isAdmin) {
         next('/mail')
         return
       }
     }
     
     next()
   })
   ```

4. **导航栏集成**
   - Settings页面已集成到Layout组件的左侧导航栏
   - 管理员用户可以看到并访问Settings菜单项
   - 普通用户不会看到Settings菜单项

#### ⚙️ 系统设置按钮修复实现

**前端修改**（`frontend/src/modules/Settings.vue`）：

1. **操作按钮容器优化**
   ```vue
   <!-- 操作按钮 -->
   <div v-if="!settingsLoading" class="mt-8 flex items-center justify-end space-x-3 relative z-10">
     <button @click.stop="resetSystemSettings" type="button" class="... cursor-pointer">
       重置
     </button>
     <button @click.stop="saveSystemSettings(true)" type="button" :disabled="settingsSaving" class="... cursor-pointer">
       保存设置
     </button>
   </div>
   ```

2. **按钮事件处理优化**
   - 添加`@click.stop`防止事件冒泡
   - 添加`type="button"`确保按钮类型
   - 添加`cursor-pointer`确保鼠标指针
   - 添加`relative z-10`提升层级

3. **调试信息添加**
   ```javascript
   const resetSystemSettings = () => {
     console.log('重置按钮被点击')
     // ...
   }
   
   const saveSystemSettings = async (immediate = false) => {
     console.log('保存按钮被点击, immediate:', immediate)
     // ...
   }
   ```

#### 📊 常规设置选择器修复实现

**用户分页大小选择器修复**：

1. **选择器事件处理**
   ```vue
   <select v-model="systemSettings.general.userPageSize" 
           @change.stop="handleUserPageSizeChange" 
           @input.stop="handleUserPageSizeChange" 
           @click.stop 
           :disabled="settingsSaving" 
           class="... cursor-pointer">
   ```

2. **新增处理函数**
   ```javascript
   const handleUserPageSizeChange = async (event: any) => {
     console.log('用户分页大小选择器被触发, event:', event)
     const pageSize = event?.target?.value || systemSettings.value.general?.userPageSize
     if (pageSize) {
       systemSettings.value.general.userPageSize = parseInt(pageSize, 10)
       await saveSystemSettings()
     }
   }
   ```

**时区选择器修复**：

1. **选择器事件处理**
   ```vue
   <select v-model="systemSettings.general.timezone" 
           @change.stop="onTimezoneChange" 
           @input.stop="onTimezoneChange" 
           @click.stop 
           :disabled="timezoneSaving" 
           class="... cursor-pointer">
   ```

2. **事件处理函数优化**
   ```javascript
   const onTimezoneChange = async (event: any) => {
     console.log('时区选择器被触发, event:', event)
     const selectedTimezone = event?.target?.value || event
     if (selectedTimezone && (typeof selectedTimezone === 'string' ? selectedTimezone.includes('/') : true)) {
       systemSettings.value.general.timezone = selectedTimezone
       // ... 保存逻辑
     }
   }
   ```

### 🔄 升级步骤

#### 从 V3.2.7 升级到 V3.3.0

1. **备份系统**
   ```bash
   # 备份数据库
   mysqldump -u root -p mailapp > backup_v3.2.7.sql
   
   # 备份配置文件
   cp -r config config_backup_v3.2.7
   ```

2. **更新代码**
   ```bash
   # 拉取最新代码
   git pull origin main
   
   # 或手动更新文件
   # 更新 frontend/src/modules/Settings.vue
   ```

3. **重建前端**
   ```bash
   cd frontend
   npm install
   npm run build
   cd ..
   ```

4. **重启服务**
   ```bash
   ./start.sh restart
   ```

5. **验证功能**
   - 访问系统设置页面
   - 测试"重置"和"保存设置"按钮
   - 测试用户分页大小选择器
   - 测试时区选择器
   - 检查浏览器控制台是否有错误

### ⚠️ 注意事项

1. **浏览器缓存**：如果按钮仍然失效，请清除浏览器缓存或使用无痕模式
2. **JavaScript错误**：检查浏览器控制台是否有JavaScript错误
3. **事件冲突**：确保没有其他JavaScript代码拦截了事件
4. **权限问题**：确保前端文件有正确的读取权限

### 🐛 已知问题

无

### 📝 更新日志

- 2025-11-26: V3.3.0 发布
  - 修复系统设置页面按钮失效问题
  - 修复用户分页大小选择器失效问题
  - 修复时区选择器失效问题
  - 优化用户交互体验
  - 添加调试信息

---

## 📚 历史版本记录

## 🎉 V3.2.7 (2025-11-25) - 权限控制与用户管理优化

### 🎊 版本亮点

**V3.2.7 是一个权限控制与用户管理优化版本，实现了文件夹的用户级权限隔离，优化了Dashboard用户管理界面，完善了修改用户功能，提升了系统的安全性和易用性。**

#### 📁 文件夹权限控制

**用户级权限隔离**：
- 每个用户只能看到和管理自己创建的文件夹
- 系统文件夹（收件箱、已发送、草稿箱、已删除、垃圾邮件）对所有用户可见
- 管理员创建的文件夹只能管理员看到，普通用户创建的文件夹只能自己看到
- 文件夹操作（创建、编辑、删除）都进行用户权限验证

**技术实现**：
- 后端API自动从认证信息获取用户ID
- 数据库查询时添加用户ID过滤条件
- 文件夹操作时验证用户权限，防止越权访问
- 同步更新相关数据库表（mail_users、virtual_users）

#### 👥 Dashboard用户管理优化

**序号列显示**：
- 用户列表添加序号列，显示格式：`(当前页 - 1) × 每页数量 + 索引 + 1`
- 方便用户查看和定位特定用户
- 序号列位于表格第一列

**修改用户功能**：
- 在操作列添加修改按钮（编辑图标），位于删除按钮旁边
- 支持修改用户名、邮箱、密码（密码可选）
- 修改用户名时会同步更新相关数据库表
- 修改邮箱时会同步更新mail_users和virtual_users表
- 修改密码时使用SHA512哈希存储

**智能提示**：
- 修改成功后显示详细提示信息
- 明确告知用户名是否改变，以及是否需要使用新用户名登录
- 明确告知密码是否更新，以及是否需要使用新密码登录
- 提示信息显示5秒，确保用户有足够时间阅读

#### 🔑 登录与认证优化

**错误信息优化**：
- 登录失败时显示更友好的错误提示信息
- 针对`unauthorized`错误，显示："登录失败：用户名或密码错误，请检查您的凭据"
- 支持解析JSON错误响应，显示具体的错误信息
- 记录登录失败日志，便于问题排查

**参数验证增强**：
- 完善修改用户功能的参数验证逻辑
- 处理`null`和`undefined`字符串参数
- 支持部分字段更新（只更新提供的字段）
- 添加数据库验证，确认更新是否成功

### 📋 详细更新内容

#### 📁 文件夹权限控制实现

**后端API修改**（`backend/dispatcher/server.js`）：

1. **添加用户ID获取函数**
   ```javascript
   // 从请求中获取用户名
   function getUsernameFromRequest(req)
   
   // 从用户名获取用户ID（从app_users表）
   function getUserIdFromUsername(username, callback)
   ```

2. **修改文件夹列表API**
   ```javascript
   // GET /api/mail/folders
   // 传递用户ID，只返回系统文件夹和当前用户的文件夹
   ```

3. **修改文件夹创建API**
   ```javascript
   // POST /api/mail/folders
   // 自动获取用户ID，创建文件夹时关联到当前用户
   ```

4. **修改文件夹更新和删除API**
   ```javascript
   // PUT /api/mail/folders/:id
   // DELETE /api/mail/folders/:id
   // 添加用户权限检查，只能操作自己的文件夹
   ```

**数据库脚本修改**（`backend/scripts/mail_db.sh`）：

1. **修改get_folders()函数**
   ```bash
   # 接受用户ID参数，只返回系统文件夹和当前用户的文件夹
   get_folders() {
     local user_id="${1:-NULL}"
     # 构建查询条件：系统文件夹或当前用户的文件夹
   }
   ```

2. **修改add_folder()函数**
   ```bash
   # 名称冲突检查只针对当前用户的文件夹
   ```

3. **修改update_folder()和delete_folder()函数**
   ```bash
   # 添加用户权限检查，只能操作自己的文件夹
   ```

#### 👥 Dashboard用户管理优化实现

**前端代码修改**（`frontend/src/modules/Dashboard.vue`）：

1. **添加序号列**
   ```vue
   <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">序号</th>
   <td class="px-4 py-3 text-sm text-gray-500">{{ (currentPage - 1) * pageSize + index + 1 }}</td>
   ```

2. **添加修改按钮**
   ```vue
   <button @click="openEditUserDialog(user)" 
           class="text-blue-600 hover:text-blue-800">
     <svg class="w-4 h-4" fill="none" stroke="currentColor">
       <!-- 编辑图标 -->
     </svg>
   </button>
   ```

3. **创建修改用户对话框**
   ```vue
   <!-- 修改用户弹窗 -->
   <div v-if="showEditUserDialog">
     <!-- 用户名、邮箱、密码输入框 -->
   </div>
   ```

4. **实现修改用户功能**
   ```typescript
   function openEditUserDialog(user: any)
   function cancelEditUser()
   async function confirmEditUser()
   ```

**后端脚本修改**（`backend/scripts/app_user.sh`）：

1. **增强update_user()函数**
   ```bash
   # 支持修改用户名（原用户名 → 新用户名）
   # 支持修改邮箱
   # 支持修改密码（可选，留空则不修改）
   # 用户名冲突检查
   # 同步更新mail_users和virtual_users表
   ```

2. **处理null参数**
   ```bash
   # 处理从前端传来的"null"和"undefined"字符串
   if [[ "$password" == "null" || "$password" == "undefined" || -z "$password" ]]; then
     password=""
   fi
   ```

3. **添加数据库验证**
   ```bash
   # 验证更新是否成功
   local verify_count
   verify_count=$(mysql_q "SELECT COUNT(*) FROM app_users WHERE username='$current_username' LIMIT 1;")
   ```

**后端API修改**（`backend/dispatcher/server.js`）：

1. **添加app-update操作**
   ```javascript
   case 'app-update':
     // 处理密码参数：如果是 null/undefined/空字符串，不传递密码参数
     const passwordParam = (finalParams?.password && finalParams.password !== 'null' && finalParams.password !== 'undefined') ? finalParams.password : ''
     scriptName = 'app_user.sh'; args = ['update', finalParams?.username, finalParams?.new_username || '', finalParams?.email || '', passwordParam]; break
   ```

2. **添加到ALLOWED_ACTIONS**
   ```javascript
   const ALLOWED_ACTIONS = new Set([
     // ...
     'app-update',
     // ...
   ])
   ```

3. **参数验证优化**
   ```javascript
   // app-update 只需要 username 参数，其他参数都是可选的
   if (action === 'app-update') {
     if (isMissing(finalParams?.username)) {
       return res.status(400).json({ error: 'missing username' })
     }
   }
   ```

#### 🔑 登录与认证优化实现

**前端代码修改**（`frontend/src/modules/Login.vue`）：

1. **优化错误处理**
   ```typescript
   if (!res.ok) {
     let errorMessage = '登录失败'
     try {
       const errorData = await res.json()
       if (errorData.error === 'unauthorized') {
         errorMessage = '登录失败：用户名或密码错误，请检查您的凭据'
       }
       // ...
     } catch (e) {
       // 处理文本错误响应
     }
   }
   ```

### 🔧 技术实现细节

#### 权限控制原则

1. **最小权限原则**：用户只能访问和操作自己的资源
2. **系统资源共享**：系统文件夹对所有用户可见
3. **权限验证**：所有操作都进行用户权限验证
4. **数据隔离**：用户数据完全隔离，互不可见

#### 用户管理原则

1. **完整性**：修改用户时同步更新所有相关表
2. **安全性**：密码使用SHA512哈希存储
3. **可追溯性**：所有操作都有详细日志记录
4. **用户友好**：提供清晰的提示信息

### 📊 更新统计

- **修改文件数**：4个主要文件（Mail.vue, Dashboard.vue, server.js, app_user.sh, mail_db.sh）
- **新增功能**：文件夹权限控制、用户修改功能
- **优化功能**：登录错误处理、参数验证
- **安全增强**：用户权限验证、数据隔离

### 🚀 升级指南

#### 从 V3.2.6 升级到 V3.2.7

1. **更新代码**
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重启服务**
   ```bash
   # 重启调度层服务
   systemctl restart mail-ops-dispatcher
   
   # 重建前端（如果需要）
   cd frontend && npm run build
   ```

3. **验证功能**
   - 验证不同用户登录后只能看到自己的文件夹
   - 验证无法编辑或删除其他用户的文件夹
   - 验证系统文件夹对所有用户可见
   - 验证用户列表显示序号
   - 验证修改用户功能正常
   - 验证登录错误提示友好

### ⚠️ 注意事项

1. **文件夹权限**：现有文件夹的`user_id`字段可能为NULL，需要手动更新或重新创建
2. **用户修改**：修改用户名后需要使用新用户名登录
3. **密码修改**：如果修改了密码，需要使用新密码登录；如果未修改密码，继续使用原密码
4. **数据库同步**：修改用户信息时会同步更新多个表，确保数据库连接正常

---

## 📚 历史版本更新记录

## V3.2.6 (2025-11-25) - UI优化与用户体验提升

### 🎊 版本亮点

**V3.2.6 是一个UI优化与用户体验提升版本，重新设计了收件箱未读消息显示和邮件详情页面，修复了布局错位问题，移除了调试信息，提升了用户界面的美观性和易用性。**

#### 📬 收件箱未读消息显示优化

**永久常驻显示**：
- 移除了条件显示逻辑（`v-if="!unreadCountLoading && unreadCount > 0"`），未读数量始终显示
- 移除了延迟显示逻辑（`setTimeout`），避免闪烁效果
- 未读消息数量徽章永久显示在收件箱按钮右侧

**智能状态显示**：
- 有未读邮件时：显示红色背景（`bg-red-500`）和白色文字，显示具体未读数量
- 无未读邮件时：显示灰色背景（`bg-gray-200`）和灰色文字（`text-gray-500`），显示"0"
- 使用动态class绑定实现状态切换

**平滑过渡动画**：
- 添加了`transition-colors duration-200`，实现颜色平滑过渡
- 状态切换时视觉效果更流畅

#### ✉️ 邮件详情页面UI重新设计

**布局修复**：
- 修复了邮件详情模态框的布局错位问题
- 重新设计了模态框结构，使用更清晰的布局
- 修复了按钮区域和正文区域的错位问题
- 优化了响应式布局，确保在不同屏幕尺寸下正常显示

**UI优化**：
- 头部区域：使用渐变背景，更清晰的标题和时间显示
- 邮件信息区域：使用网格布局，信息展示更清晰
- 附件区域：优化样式，移除调试按钮
- 邮件正文：优化显示区域，更好的滚动体验
- 底部操作栏：重新排列按钮，修复错位问题
- 整体风格：更现代化的设计，使用圆角、阴影和渐变效果

**调试信息清理**：
- 移除了邮件正文区域的调试信息显示
- 移除了附件区域的调试信息切换按钮和显示
- 移除了加载状态中的调试信息
- 移除了`showDebugInfo`状态变量

#### 🗑️ 移除邮件优先级和重要性功能

**前端代码清理**：
- 删除邮件列表中的优先级和重要性显示标签
- 删除邮件详情中的优先级和重要性显示
- 删除邮件编写界面中的优先级和重要性设置UI
- 删除`emailPriority`和`emailImportance`状态变量
- 删除`Email`接口中的`priority`和`importance`字段定义
- 删除保存草稿和发送邮件时的优先级和重要性参数

**后端代码清理**：
- 删除`/api/mail/save-draft` API中的`priority`和`importance`参数处理
- 删除`/api/mail/send` API中的`priority`和`importance`参数处理
- 删除所有`mail_db.sh store`调用中的优先级和重要性参数
- 删除邮件列表API返回数据中的`priority`和`importance`字段

**数据库脚本清理**：
- 删除`store_email()`函数中的`priority`和`importance`参数
- 删除`CREATE TABLE emails`中的`priority`和`importance`字段定义
- 删除`ALTER TABLE`中添加`priority`和`importance`字段的语句
- 删除`INSERT INTO emails`中的`priority`和`importance`字段
- 删除邮件列表查询中的`priority`和`importance`字段
- 删除帮助文档中关于优先级和重要性的说明

**数据库初始化脚本清理**：
- 删除手动创建`emails`表时的`priority`和`importance`字段定义

#### 📝 脚本注释文档更新

**全面更新所有脚本的注释文档**：

1. **mail_db.sh** - 邮件数据库管理脚本
   - 更新了`store`命令说明，注明已移除优先级和重要性参数
   - 保持了其他功能的准确描述

2. **app_user.sh** - 应用用户管理脚本
   - 更新了用法说明，包含所有实际支持的命令（init, schema, register, login, reset, update, query-users, delete-user, check-user-exists, fix-email-domains）
   - 添加了域名修复功能的详细说明
   - 更新了数据库表说明，包含app_accounts表

3. **db_setup.sh** - 数据库初始化脚本
   - 更新了用法说明，仅包含实际支持的命令（init, restart, stop）
   - 更新了功能描述，明确说明只创建maildb数据库（Postfix虚拟用户数据库）
   - 更新了表结构说明，包含virtual_domains, virtual_users, virtual_aliases, shared_mailboxes
   - 添加了utf8mb4字符集说明

4. **mail_init.sh** - 邮件系统初始化脚本
   - 更新了用法说明，包含实际支持的命令（init, sample, services, monitor, all）
   - 更新了功能描述，说明调用mail_db.sh init进行数据库初始化
   - 添加了监控服务配置的说明

5. **user_manage.sh** - 用户与域名管理脚本
   - 更新了用法说明，仅包含实际支持的命令（domain-add, user-add, user-del）
   - 更新了功能描述，说明自动创建Maildir格式邮件目录
   - 添加了权限设置和vmail用户同步的说明

6. **dispatcher.sh** - 调度层服务管理脚本
   - 更新了用法说明，仅包含实际支持的命令（restart, stop）
   - 更新了功能描述，说明服务重启和停止的具体流程

### 📋 详细更新内容

#### 📬 收件箱未读消息显示优化实现

**前端代码修改**（`frontend/src/modules/Mail.vue`）：

1. **移除条件显示逻辑**
   ```vue
   <!-- 修改前 -->
   <span v-if="!unreadCountLoading && unreadCount > 0" 
         class="ml-2 inline-flex items-center justify-center min-w-[24px] h-6 px-2 text-xs font-bold text-white bg-red-500 rounded-full shadow-sm">
     {{ unreadCount }}
   </span>
   
   <!-- 修改后 -->
   <span class="ml-2 inline-flex items-center justify-center min-w-[24px] h-6 px-2 text-xs font-bold rounded-full shadow-sm transition-colors duration-200"
         :class="unreadCount > 0 
           ? 'text-white bg-red-500' 
           : 'text-gray-500 bg-gray-200'">
     {{ unreadCount }}
   </span>
   ```

2. **移除延迟显示逻辑**
   ```typescript
   // 修改前
   } finally {
     emailsLoading.value = false
     // 延迟一点时间再显示未读计数，避免闪烁
     setTimeout(() => {
       unreadCountLoading.value = false
     }, 100)
   }
   
   // 修改后
   } finally {
     emailsLoading.value = false
     unreadCountLoading.value = false
   }
   ```

**技术实现细节**：
- 使用动态class绑定（`:class`）实现状态切换
- 添加`transition-colors duration-200`实现平滑过渡
- 移除所有条件显示逻辑，确保永久常驻
- 保持最小宽度（`min-w-[24px]`）确保数字显示稳定

#### ✉️ 邮件详情页面UI重新设计实现

**前端代码修改**（`frontend/src/modules/Mail.vue`）：

1. **移除调试信息显示**
   ```vue
   <!-- 删除邮件正文区域的调试信息 -->
   <!-- 删除附件区域的调试信息切换按钮 -->
   <!-- 删除加载状态中的调试信息 -->
   ```

2. **移除调试状态变量**
   ```typescript
   // 删除
   const showDebugInfo = ref(false)
   ```

3. **优化模态框布局**
   - 重新设计头部区域，使用渐变背景
   - 优化邮件信息区域，使用网格布局
   - 修复按钮区域和正文区域的错位问题
   - 优化附件区域样式，移除调试按钮
   - 重新排列底部操作栏按钮

**技术实现细节**：
- 使用`flex`和`grid`布局确保元素对齐
- 优化按钮下拉菜单位置（从`mt-1`改为`bottom-full mb-2`）
- 改进邮件正文的文本换行和显示
- 使用圆角、阴影和渐变效果提升视觉效果

### 🔧 技术实现细节

#### UI优化原则

1. **永久显示**：移除所有条件显示逻辑，确保重要信息始终可见
2. **无闪烁设计**：移除延迟显示逻辑，避免视觉干扰
3. **状态反馈**：使用颜色和样式清晰区分不同状态
4. **平滑过渡**：添加过渡动画，提升用户体验

#### 布局修复原则

1. **结构清晰**：使用语义化的HTML结构
2. **响应式设计**：确保在不同屏幕尺寸下正常显示
3. **对齐优化**：使用flex和grid布局确保元素对齐
4. **视觉层次**：使用颜色、大小、间距建立清晰的视觉层次

### 📊 更新统计

- **修改文件数**：1个主要文件（Mail.vue）
- **删除代码行数**：约10行（调试信息相关）
- **新增代码行数**：约5行（状态显示优化）
- **UI改进**：2个主要界面（收件箱未读消息、邮件详情页面）

### 🚀 升级指南

#### 从 V3.2.5 升级到 V3.2.6

1. **更新代码**
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

2. **重建前端**
   ```bash
   # 重建前端
   cd frontend && npm run build
   ```

3. **验证功能**
   - 验证收件箱未读消息数量始终显示（包括0）
   - 验证未读消息数量不闪烁
   - 验证邮件详情页面布局正常
   - 验证邮件详情页面无调试信息
   - 验证不同屏幕尺寸下的显示效果

### ⚠️ 注意事项

1. **前端缓存**：更新后可能需要清除浏览器缓存才能看到新界面
2. **未读计数**：未读数量现在会始终显示，包括0的情况
3. **调试信息**：所有调试信息已移除，如需调试请使用浏览器开发者工具

---

## 📚 历史版本更新记录

## V3.2.5 (2025-11-24) - 代码清理与文档完善

### 🎊 版本亮点

**V3.2.5 是一个代码清理与文档完善版本，移除了邮件优先级和重要性功能，全面更新了所有脚本的注释文档，提升了代码的可维护性和文档的完整性。**

#### 🗑️ 移除邮件优先级和重要性功能

**前端代码清理**：
- 删除邮件列表中的优先级和重要性显示标签
- 删除邮件详情中的优先级和重要性显示
- 删除邮件编写界面中的优先级和重要性设置UI
- 删除`emailPriority`和`emailImportance`状态变量
- 删除`Email`接口中的`priority`和`importance`字段定义
- 删除保存草稿和发送邮件时的优先级和重要性参数

**后端代码清理**：
- 删除`/api/mail/save-draft` API中的`priority`和`importance`参数处理
- 删除`/api/mail/send` API中的`priority`和`importance`参数处理
- 删除所有`mail_db.sh store`调用中的优先级和重要性参数
- 删除邮件列表API返回数据中的`priority`和`importance`字段

**数据库脚本清理**：
- 删除`store_email()`函数中的`priority`和`importance`参数
- 删除`CREATE TABLE emails`中的`priority`和`importance`字段定义
- 删除`ALTER TABLE`中添加`priority`和`importance`字段的语句
- 删除`INSERT INTO emails`中的`priority`和`importance`字段
- 删除邮件列表查询中的`priority`和`importance`字段
- 删除帮助文档中关于优先级和重要性的说明

**数据库初始化脚本清理**：
- 删除手动创建`emails`表时的`priority`和`importance`字段定义

#### 📝 脚本注释文档更新

**全面更新所有脚本的注释文档**：

1. **mail_db.sh** - 邮件数据库管理脚本
   - 更新了`store`命令说明，注明已移除优先级和重要性参数
   - 保持了其他功能的准确描述

2. **app_user.sh** - 应用用户管理脚本
   - 更新了用法说明，包含所有实际支持的命令（init, schema, register, login, reset, update, query-users, delete-user, check-user-exists, fix-email-domains）
   - 添加了域名修复功能的详细说明
   - 更新了数据库表说明，包含app_accounts表

3. **db_setup.sh** - 数据库初始化脚本
   - 更新了用法说明，仅包含实际支持的命令（init, restart, stop）
   - 更新了功能描述，明确说明只创建maildb数据库（Postfix虚拟用户数据库）
   - 更新了表结构说明，包含virtual_domains, virtual_users, virtual_aliases, shared_mailboxes
   - 添加了utf8mb4字符集说明

4. **mail_init.sh** - 邮件系统初始化脚本
   - 更新了用法说明，包含实际支持的命令（init, sample, services, monitor, all）
   - 更新了功能描述，说明调用mail_db.sh init进行数据库初始化
   - 添加了监控服务配置的说明

5. **user_manage.sh** - 用户与域名管理脚本
   - 更新了用法说明，仅包含实际支持的命令（domain-add, user-add, user-del）
   - 更新了功能描述，说明自动创建Maildir格式邮件目录
   - 添加了权限设置和vmail用户同步的说明

6. **dispatcher.sh** - 调度层服务管理脚本
   - 更新了用法说明，仅包含实际支持的命令（restart, stop）
   - 更新了功能描述，说明服务重启和停止的具体流程

### 📋 详细更新内容

#### 🗑️ 移除邮件优先级和重要性功能实现

**前端代码修改**（`frontend/src/modules/Mail.vue`）：

1. **删除UI组件**
   ```vue
   <!-- 删除优先级和重要性显示标签 -->
   <!-- 删除优先级和重要性设置UI -->
   ```

2. **删除状态变量**
   ```typescript
   // 删除
   const emailPriority = ref<number>(0)
   const emailImportance = ref<number>(0)
   ```

3. **删除接口字段**
   ```typescript
   // 删除
   priority?: number
   importance?: number
   ```

**后端代码修改**（`backend/dispatcher/server.js`）：

1. **删除参数处理**
   ```javascript
   // 修改前
   const { to, cc, subject, body, from, attachments, folder, priority, importance } = req.body
   
   // 修改后
   const { to, cc, subject, body, from, attachments, folder } = req.body
   ```

2. **删除参数传递**
   ```javascript
   // 修改前
   exec(`bash "${mailDbScript}" store ... "${priorityValue}" "${importanceValue}"`, ...)
   
   // 修改后
   exec(`bash "${mailDbScript}" store ... "0" "0"`, ...)
   ```

**数据库脚本修改**（`backend/scripts/mail_db.sh`）：

1. **删除字段定义**
   ```sql
   -- 删除
   priority TINYINT DEFAULT 0 COMMENT '优先级：0=普通，1=高，2=低',
   importance TINYINT DEFAULT 0 COMMENT '重要性：0=普通，1=重要',
   ```

2. **删除参数处理**
   ```bash
   # 删除
   local priority="${12:-0}"
   local importance="${13:-0}"
   ```

3. **删除INSERT字段**
   ```sql
   -- 修改前
   INSERT INTO emails (..., priority, importance) VALUES (..., ${priority}, ${importance})
   
   -- 修改后
   INSERT INTO emails (...) VALUES (...)
   ```

#### 📝 脚本注释文档更新实现

**更新策略**：
1. 读取每个脚本的实际代码，了解其真实功能
2. 检查脚本支持的所有命令和参数
3. 更新用法说明，确保与实际功能一致
4. 更新功能描述，补充缺失的说明
5. 更新数据库表说明，确保准确

**更新范围**：
- `backend/scripts/mail_db.sh`
- `backend/scripts/app_user.sh`
- `backend/scripts/db_setup.sh`
- `backend/scripts/mail_init.sh`
- `backend/scripts/user_manage.sh`
- `backend/scripts/dispatcher.sh`
- 其他脚本的注释文档已与实际功能匹配

### 🔧 技术实现细节

#### 代码清理原则

1. **彻底删除**：不仅删除功能代码，还删除相关的UI组件、状态变量、接口定义
2. **保持兼容**：删除功能时保持向后兼容，使用默认值（0）替代已删除的参数
3. **文档同步**：代码删除后同步更新相关文档和注释

#### 文档更新原则

1. **准确性**：确保文档描述与实际代码功能完全一致
2. **完整性**：补充缺失的命令说明和功能描述
3. **可维护性**：使用清晰的结构和格式，便于后续维护

### 📊 更新统计

- **删除代码行数**：约200行（前端+后端+数据库脚本）
- **更新文档行数**：约500行（所有脚本的注释文档）
- **涉及文件数**：6个主要文件（Mail.vue, server.js, mail_db.sh, start.sh, app_user.sh等）
- **脚本文档更新**：6个脚本的完整注释文档更新

### 🚀 升级指南

#### 从 V3.2.4 升级到 V3.2.5

1. **备份数据**
   ```bash
   # 备份数据库
   mysqldump -u root maildb > maildb_backup.sql
   mysqldump -u root mailapp > mailapp_backup.sql
   ```

2. **更新代码**
   ```bash
   # 拉取最新代码
   git pull origin main
   ```

3. **数据库迁移**（可选）
   ```sql
   -- 如果数据库中仍有priority和importance字段，可以手动删除
   ALTER TABLE emails DROP COLUMN priority;
   ALTER TABLE emails DROP COLUMN importance;
   ```

4. **重启服务**
   ```bash
   # 重启调度层服务
   systemctl restart mail-ops-dispatcher
   
   # 重启前端（如果需要）
   cd frontend && npm run build
   ```

5. **验证功能**
   - 验证邮件发送功能正常
   - 验证邮件列表显示正常
   - 验证邮件详情显示正常
   - 验证脚本帮助文档正确

### ⚠️ 注意事项

1. **数据兼容性**：如果数据库中仍有`priority`和`importance`字段，不会影响系统运行，但建议删除以保持一致性
2. **API兼容性**：前端发送的`priority`和`importance`参数会被忽略，使用默认值0
3. **文档准确性**：所有脚本的注释文档已更新，请参考最新的文档使用脚本

---

## 📚 历史版本更新记录

## V3.2.4 (2025-11-22) - 邮件发送性能优化与收件人自动创建

### 🎊 版本亮点

**V3.2.4 是一个邮件发送性能优化与收件人自动创建版本，全面优化了邮件发送流程，解决了邮件发送卡住的问题，新增了收件人自动创建功能，优化了邮件存储逻辑，提升了系统的性能和用户体验。**

#### ⚡ 邮件发送性能优化
- **立即返回响应**：SMTP发送开始后立即返回响应，避免前端长时间等待
- **后台异步处理**：邮件发送和存储在后台异步执行，不阻塞HTTP请求
- **SMTP超时优化**：优化SMTP连接和Socket超时设置，加快响应速度
- **超时时间调整**：根据附件大小动态调整超时时间，设置合理上限（30秒-2分钟）

#### 🔧 收件人自动创建功能
- **主收件人检查**：发送邮件前自动检查主收件人是否存在于`virtual_users`表
- **抄送人检查**：自动检查所有抄送收件人，确保都存在于`virtual_users`表
- **自动创建机制**：如果收件人不存在，自动创建用户记录和邮件目录
- **异步处理**：抄送人的检查和创建在后台异步执行，不阻塞请求

#### 📦 邮件存储逻辑优化
- **智能存储策略**：即使SMTP发送失败（如抄送地址错误），也会存储到主收件人的收件箱
- **错误判断**：只有当明确是主收件人地址错误时才跳过收件箱存储
- **详细日志记录**：添加完整的邮件发送和存储日志，便于问题排查

#### 🗄️ 数据库操作优化
- **减少查询次数**：优化数据库查询逻辑，减少同步查询次数
- **异步目录创建**：邮件目录创建改为异步执行，不阻塞请求
- **批量处理**：抄送收件人的处理改为批量异步执行

### 📋 详细更新内容

#### ⚡ 邮件发送性能优化实现

**`backend/dispatcher/server.js` 优化**：

1. **立即返回响应机制**
   - SMTP发送开始后立即返回响应，避免前端长时间等待
   - 响应包含 `processing: true` 标记，表示邮件正在后台处理
   - 邮件发送和存储在后台异步执行

2. **SMTP配置优化**
   ```javascript
   const transporter = nodemailer.createTransport({
     host: 'localhost',
     port: 25,
     secure: false,
     connectionTimeout: 5000, // 连接超时5秒
     greetingTimeout: 5000, // 问候超时5秒
     socketTimeout: 30000, // Socket超时30秒
     pool: false, // 不使用连接池
     maxConnections: 1,
     maxMessages: 1
   })
   ```

3. **超时时间优化**
   - 默认超时：30秒（从10秒增加）
   - 小附件（<500KB）：30秒
   - 中等附件（500KB-1MB）：1分钟
   - 大附件（1MB-5MB）：1.5分钟
   - 超大附件（>5MB）：2分钟
   - 大幅减少超时时间（从5-15分钟减少到30秒-2分钟）

#### 🔧 收件人自动创建功能实现

**主收件人检查（同步，已优化）**：

1. **快速检查**
   - 只查询一次数据库检查主收件人是否存在
   - 如果不存在，快速创建（不查询密码，直接生成默认密码）
   - 目录创建改为异步，不阻塞请求

2. **实现逻辑**
   ```javascript
   // 快速检查主收件人是否存在
   const toUserCheck = execSync(
     `mysql -u mailuser -pmailpass maildb -s -r -e "SELECT id FROM virtual_users WHERE email='${to}' LIMIT 1;" 2>/dev/null || echo ""`,
     { encoding: 'utf8', timeout: 2000 }
   ).trim()
   
   if (!toUserCheck) {
     // 快速创建用户（不查询密码，直接生成）
     const userPassword = '$6$rounds=5000$defaultsalt$' + crypto.randomBytes(16).toString('hex')
     execSync(
       `mysql -u mailuser -pmailpass maildb -e "INSERT INTO virtual_users (domain_id, email, password, active) VALUES (${toDomainId}, '${to}', '${userPassword}', 1);" 2>/dev/null`,
       { timeout: 2000 }
     )
     // 目录创建异步执行
     exec(`mkdir -p ${mailDir}/new ${mailDir}/cur ${mailDir}/tmp && chown -R vmail:mail /var/vmail/${toEmailDomain}/${toEmailUsername} && chmod 700 /var/vmail/${toEmailDomain}/${toEmailUsername} ${mailDir}`, { timeout: 5000 }, () => {})
   }
   ```

**抄送收件人检查（异步）**：

- 所有抄送人的检查和创建都在后台异步执行
- 使用bash脚本批量处理，不阻塞HTTP请求
- 自动创建域名、用户和邮件目录

#### 📦 邮件存储逻辑优化

**智能存储策略**：

1. **存储判断逻辑**
   ```javascript
   let shouldStoreToInbox = true
   if (isError && errorObj && errorObj.response && to) {
     // 检查错误信息中是否包含主收件人地址
     const errorResponse = String(errorObj.response)
     if (errorResponse.includes(`<${to}>`)) {
       shouldStoreToInbox = false // 主收件人不存在，不存储
     }
   }
   ```

2. **存储场景**
   - SMTP成功：存储到收件箱和已发送文件夹
   - SMTP失败（抄送地址错误）：存储到主收件人收件箱和已发送文件夹
   - SMTP失败（主收件人错误）：只存储到已发送文件夹

#### 🗄️ 数据库操作优化

1. **减少同步查询**
   - 主收件人只查询一次数据库
   - 不再查询密码（直接生成默认密码）
   - 目录操作全部异步

2. **异步处理**
   - 抄送人检查：异步执行
   - 目录创建：异步执行
   - 邮件存储：异步执行（不影响响应）

### 🔧 技术实现细节

#### 后端实现

**立即返回响应机制**：
```javascript
// 先立即返回响应，避免前端长时间等待
const messageId = `msg-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
responseSent = true

res.json({
  success: true,
  messageId: messageId,
  message: '邮件正在发送中，请稍候查看已发送文件夹',
  processing: true
})

// 在后台异步发送邮件
transporter.sendMail(mailOptions, (error, info) => {
  // 处理发送结果和存储
})
```

**收件人自动创建**：
- 主收件人：同步快速检查（2秒超时）
- 抄送人：异步批量处理（不阻塞请求）
- 目录创建：全部异步执行

#### 前端实现

**进度条优化**：
- 前端进度条是模拟的，会持续更新
- 收到响应后立即完成进度条
- 用户可以在"已发送"文件夹查看邮件状态

### 📊 更新统计

- **性能优化**：3个（立即返回响应、SMTP超时优化、异步处理）
- **新增功能**：1个（收件人自动创建）
- **功能优化**：2个（邮件存储逻辑、数据库操作）
- **代码调整**：多处（响应机制、SMTP配置、存储逻辑）

### 🚀 升级指南

#### 升级步骤

1. **备份数据库**
   ```bash
   mysqldump -u mailuser -p maildb > maildb_backup_$(date +%Y%m%d).sql
   ```

2. **更新代码**
   ```bash
   cd /bash
   git pull  # 或直接替换文件
   ```

3. **重启调度层服务**
   ```bash
   systemctl restart mail-ops-dispatcher
   ```

4. **测试邮件发送**
   - 发送一封测试邮件
   - 检查响应是否立即返回
   - 检查邮件是否成功存储

#### 注意事项

- 邮件发送现在是异步的，响应会立即返回
- 如果发送失败，邮件仍会存储到已发送文件夹
- 收件人不存在时会自动创建，但可能需要几秒钟时间
- 建议在发送邮件后稍等片刻再查看收件箱

---

## 🎉 历史版本 - V3.2.3 (2025-11-22) - 邮箱域名自动修复与重装保护

### 🎊 版本亮点

**V3.2.3 是一个邮箱域名自动修复与重装保护版本，新增了自动检测和修复用户邮箱域名的功能，确保系统重装时用户邮箱域名保持一致，避免域名被重置为localhost，提升了系统的数据一致性和用户体验。**

#### 🔧 邮箱域名自动修复功能
- **自动检测机制**：系统重装时自动检测xm用户的邮箱域名
- **智能修复逻辑**：如果xm用户邮箱域名为有效域名（非localhost），自动修复其他用户的邮箱域名
- **数据库同步**：修复功能会更新所有相关数据库表（app_users、mail_users、virtual_users、email_recipients）
- **重装保护**：确保重装后用户邮箱域名保持一致，避免域名被重置为localhost

#### 🛠️ 修复功能实现
- **bash脚本实现**：修复功能在`app_user.sh`脚本中实现，通过命令行调用
- **执行时机**：在所有数据库初始化完成后自动执行，确保xm用户信息已从旧数据库恢复
- **优先级处理**：优先从已存在的数据库中获取xm用户邮箱，如果数据库不存在则跳过修复
- **日志记录**：详细的修复过程日志，包括成功修复数量和失败数量

#### 📋 修复范围
- **用户邮箱修复**：将所有使用`@localhost`域名的普通用户邮箱修复为与xm用户相同的域名
- **多表同步更新**：同时更新应用用户表、邮件用户表、虚拟用户表和邮件收件人表
- **管理员保护**：xm管理员用户不会被修改，保持其原有邮箱域名

### 📋 详细更新内容

#### 🔧 邮箱域名自动修复功能实现

**`start.sh` 脚本增强**：

1. **自动修复函数 `auto_fix_email_domains()`**
   - 位置：在所有数据库初始化完成后执行（第1131行）
   - 功能：检测xm用户邮箱域名，自动修复其他用户的邮箱域名
   - 执行时机：确保数据库完全初始化，xm用户信息已从旧数据库恢复

2. **检测逻辑**
   ```bash
   # 获取xm用户的邮箱地址（优先从已存在的数据库中获取）
   XM_EMAIL=$(mysql -u root mailapp -s -N -e "SELECT email FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null || echo "")
   
   # 提取域名
   XM_DOMAIN=$(echo "$XM_EMAIL" | cut -d'@' -f2)
   
   # 判断是否需要修复
   if [[ -z "$XM_DOMAIN" || "$XM_DOMAIN" == "localhost" ]]; then
     log "xm用户邮箱域名为localhost或无效，跳过邮箱域名修复"
     return 0
   fi
   ```

3. **修复执行**
   - 统计需要修复的用户数量（使用`@localhost`域名的普通用户）
   - 调用`app_user.sh fix-email-domains`脚本执行修复
   - 解析修复结果，记录成功和失败数量
   - 输出详细的修复日志

**`backend/scripts/app_user.sh` 脚本增强**：

1. **修复函数 `fix_user_email_domains()`**
   - 功能：批量修复用户邮箱域名（将localhost域名替换为正确的域名）
   - 参数：目标域名（如`skills.com`）
   - 实现：使用临时文件避免子shell问题，确保变量正确传递

2. **修复范围**
   - `app_users`表：更新应用用户邮箱
   - `mail_users`表：更新邮件用户邮箱
   - `virtual_users`表：更新虚拟用户邮箱
   - `email_recipients`表：更新邮件收件人邮箱

3. **安全保护**
   - 排除xm管理员用户，不修改管理员邮箱
   - 验证目标域名有效性（不能为localhost）
   - 详细的错误处理和日志记录

**执行优先级说明**：

1. **数据库初始化阶段**
   - 检查应用数据库是否存在（`check_mailapp_exists`）
   - 如果存在且有数据：跳过初始化，保留现有数据（包括xm用户的邮箱，如`xm@skills.com`）
   - 如果不存在：初始化schema，创建xm用户为`xm@localhost`

2. **自动修复执行时机**
   - 在所有数据库初始化完成后调用`auto_fix_email_domains()`
   - 确保xm用户信息已从旧数据库恢复
   - 如果数据库已存在，xm用户的邮箱会从旧数据库恢复（如`xm@skills.com`）
   - 如果数据库不存在，xm用户会被创建为`xm@localhost`，函数会检测到`localhost`并跳过修复

3. **修复逻辑优先级**
   - 从数据库查询xm用户的邮箱（优先从已存在的数据库中获取）
   - 如果xm用户邮箱域名为`localhost`或无效，跳过修复
   - 如果xm用户邮箱有有效域名（如`skills.com`），修复其他用户的邮箱域名

#### 🗑️ 前端功能调整

**删除修复邮箱域名按钮**：
- 移除了前端的"修复邮箱域名"按钮和相关UI
- 移除了修复邮箱域名的对话框和相关状态变量
- 移除了相关的函数（`showFixEmailDomainDialogFunc`、`closeFixEmailDomainDialog`、`executeFixEmailDomain`）
- 功能改为在bash脚本中自动完成，无需手动操作

#### 🔄 域名获取逻辑优化

**`frontend/src/modules/Dashboard.vue` 优化**：

1. **`getLocalDomain()` 函数增强**
   - 优先级顺序：
     1. 系统设置的邮件域名列表（最优先）
     2. 管理员邮箱中的域名
     3. DNS配置中的域名
     4. 从API查询域名列表
     5. 从用户列表中查询xm用户的邮箱
     6. 默认返回'skills.com'
   - 支持异步查询，确保能获取到最新的域名信息

2. **批量创建用户域名修复**
   - 批量创建用户时自动使用正确的域名
   - 不再默认使用`localhost`域名
   - 确保新创建的用户邮箱域名与系统配置一致

### 🔧 技术实现细节

#### 后端实现

**`start.sh` 自动修复函数**：
```bash
auto_fix_email_domains() {
  # 检查数据库是否可用
  if ! mysql -u root -e "USE mailapp;" 2>/dev/null; then
    log "应用数据库不可用，跳过邮箱域名修复"
    return 0
  fi
  
  # 获取xm用户的邮箱地址（优先从已存在的数据库中获取）
  XM_EMAIL=$(mysql -u root mailapp -s -N -e "SELECT email FROM app_users WHERE username='xm' LIMIT 1;" 2>/dev/null || echo "")
  
  # 提取域名并判断是否需要修复
  XM_DOMAIN=$(echo "$XM_EMAIL" | cut -d'@' -f2)
  
  if [[ -z "$XM_DOMAIN" || "$XM_DOMAIN" == "localhost" ]]; then
    log "xm用户邮箱域名为localhost或无效，跳过邮箱域名修复"
    return 0
  fi
  
  # 执行修复脚本
  bash -lc '"'"${BASE_DIR}/backend/scripts/app_user.sh"'" fix-email-domains "'"$XM_DOMAIN"'"'
}
```

**`backend/scripts/app_user.sh` 修复函数**：
```bash
fix_user_email_domains() {
  local target_domain="$1"
  
  # 创建临时文件存储用户列表
  local temp_file=$(mktemp)
  
  # 获取所有使用localhost域名的用户（排除xm用户）
  mysql -u root -e "USE mailapp; SELECT username, email FROM app_users WHERE email LIKE '%@localhost' AND username != 'xm';" 2>/dev/null | tail -n +2 > "$temp_file"
  
  # 逐行处理用户（不使用管道，避免子shell问题）
  while IFS=$'\t' read -r username email; do
    local new_email="${username}@${target_domain}"
    
    # 更新所有相关数据库表
    mysql -u root -e "USE mailapp; UPDATE app_users SET email='$new_email' WHERE username='$username';" 2>/dev/null
    mysql -u mailuser -pmailpass maildb -e "UPDATE mail_users SET email='$new_email' WHERE username='$username';" 2>/dev/null || true
    mysql -u mailuser -pmailpass maildb -e "UPDATE virtual_users SET email='$new_email' WHERE email='$email';" 2>/dev/null || true
    mysql -u mailuser -pmailpass maildb -e "UPDATE email_recipients SET email_address='$new_email' WHERE email_address='$email';" 2>/dev/null || true
  done < "$temp_file"
  
  rm -f "$temp_file"
}
```

#### 前端实现

**域名获取逻辑优化**：
- `getLocalDomain()`函数改为异步函数，支持从多个来源获取域名
- 优先从系统设置的邮件域名列表获取
- 支持从API查询域名列表
- 支持从用户列表中查询xm用户的邮箱

**批量创建用户优化**：
- 批量创建用户时自动使用正确的域名
- 不再默认使用`localhost`域名
- 确保新创建的用户邮箱域名与系统配置一致

### 📊 更新统计

- **新增功能**：1个（邮箱域名自动修复功能）
- **功能优化**：2个（域名获取逻辑优化、批量创建用户域名修复）
- **代码调整**：删除前端修复按钮和相关UI
- **脚本增强**：2个（start.sh、app_user.sh）

### 🚀 升级指南

#### 升级步骤

1. **备份数据库**
   ```bash
   mysqldump -u mailuser -p maildb > maildb_backup_$(date +%Y%m%d).sql
   mysqldump -u root mailapp > mailapp_backup_$(date +%Y%m%d).sql
   ```

2. **更新代码**
   ```bash
   cd /bash
   git pull  # 或直接替换文件
   ```

3. **执行重装**（如果需要）
   ```bash
   ./start.sh start
   ```
   - 系统会自动检测xm用户的邮箱域名
   - 如果xm用户邮箱有有效域名，会自动修复其他用户的邮箱域名
   - 修复过程会输出详细的日志信息

4. **手动修复**（如果需要）
   ```bash
   bash backend/scripts/app_user.sh fix-email-domains skills.com
   ```

#### 注意事项

- 自动修复功能只在系统重装时执行，不会影响正常运行的系统
- 修复功能会更新所有相关数据库表，确保数据一致性
- xm管理员用户不会被修改，保持其原有邮箱域名
- 如果xm用户邮箱域名为`localhost`，修复功能会自动跳过
- 修复过程会输出详细的日志，便于问题排查

---

## 🎉 历史版本 - V3.2.2 (2025-11-21) - 邮件文件夹UI重新设计与功能完善

### 🎊 版本亮点

**V3.2.2 是一个邮件文件夹UI重新设计与功能完善版本，全面重新设计了邮件文件夹的用户界面，完善了自定义文件夹功能，优化了邮件移动逻辑，新增了已删除邮件的还原和彻底删除功能，提升了邮件管理的用户体验和功能完整性。**

#### 🎨 邮件文件夹UI全面重新设计
- **侧边栏布局**：采用现代化的左侧固定侧边栏 + 右侧主内容区域布局，更符合现代邮件客户端设计
- **视觉层次优化**：使用卡片式设计、毛玻璃效果、渐变背景，提升视觉美感
- **交互体验提升**：选中状态使用左侧彩色边框和背景色区分，悬停效果更加流畅
- **图标设计**：每个文件夹都有独特的图标和颜色主题，便于快速识别

#### 📁 自定义文件夹功能完善
- **文件夹管理**：支持创建、编辑、删除、重命名自定义文件夹
- **数据库同步**：自定义文件夹信息同步至数据库，支持多用户独立文件夹
- **文件夹操作**：悬停显示编辑和删除按钮，操作更加便捷
- **文件夹统计**：支持查看每个文件夹的邮件数量和统计信息

#### 🔄 邮件移动逻辑优化
- **智能移动规则**：按照业务逻辑重新设计移动规则
  - 收件箱 → 垃圾邮件、已删除、自定义文件夹
  - 已发送 → 已删除、自定义文件夹（不移动到垃圾邮件）
  - 草稿箱 → 已删除（不移动到其他文件夹）
  - 垃圾邮件 → 收件箱、已删除、自定义文件夹
  - 已删除 → 原文件夹（收件箱/已发送/草稿）、自定义文件夹
- **原文件夹记录**：移动到已删除文件夹时自动记录原文件夹，支持还原功能

#### ♻️ 已删除邮件管理功能
- **邮件还原**：支持将已删除邮件还原到原文件夹
- **彻底删除**：支持彻底删除邮件（硬删除，不可恢复）
- **原文件夹追踪**：自动记录邮件删除前的文件夹，还原时自动恢复
- **数据库优化**：添加`original_folder_id`字段，记录删除前的文件夹信息

#### 🗄️ 数据库结构优化
- **字段扩展**：emails表添加`original_folder_id`字段，用于记录删除前的文件夹
- **表结构升级**：自动检测并添加新字段，保证向后兼容性
- **数据一致性**：通过外键约束确保数据一致性，级联删除相关数据

### 📋 详细更新内容

#### 🎨 邮件文件夹UI重新设计

**侧边栏布局实现**：

1. **布局结构**
   - 左侧固定宽度侧边栏（256px）：包含所有文件夹和管理功能
   - 右侧主内容区域（自适应宽度）：显示邮件列表和详情
   - 使用flex布局，响应式设计

2. **视觉设计**
   - 白色半透明背景 + 毛玻璃效果（backdrop-blur-md）
   - 圆角卡片设计（rounded-2xl）
   - 阴影效果（shadow-xl）
   - 统一的间距和圆角

3. **写邮件按钮**
   - 顶部突出显示，使用紫色到靛蓝色渐变背景
   - 悬停时图标旋转动画
   - 选中状态有脉冲动画效果

4. **系统文件夹设计**
   - 图标 + 文字 + 计数器的布局
   - 图标背景色区分（选中时显示对应颜色）
   - 选中状态：
     - 左侧4px彩色边框
     - 浅色背景
     - 文字颜色加深
   - 未读数量徽章（红色圆角，带阴影）
   - 平滑过渡动画

5. **自定义文件夹设计**
   - 与系统文件夹一致的样式
   - 悬停时显示编辑/删除按钮（透明度过渡）
   - 编辑按钮：灰色，悬停时变深
   - 删除按钮：悬停时变红色

#### 📁 自定义文件夹功能实现

**文件夹管理功能**：

1. **创建文件夹**
   - 前端UI：文件夹管理对话框，支持输入文件夹名称和显示名称
   - 后端API：`POST /api/mail/folders`
   - 数据库：插入`email_folders`表，`folder_type='user'`
   - 验证：文件夹名称只能包含字母、数字、下划线、连字符

2. **编辑文件夹（重命名）**
   - 前端UI：编辑对话框，支持修改名称和显示名称
   - 后端API：`PUT /api/mail/folders/:id`
   - 数据库：更新`email_folders`表
   - 验证：检查名称是否与其他文件夹冲突

3. **删除文件夹**
   - 前端UI：确认对话框
   - 后端API：`DELETE /api/mail/folders/:id`
   - 数据库：软删除（设置`is_active=0`），文件夹中的邮件移动到已删除文件夹
   - 安全：系统文件夹不可删除

**数据库同步**：

- 文件夹信息存储在`email_folders`表中
- 支持`folder_type='user'`标识自定义文件夹
- 支持`user_id`字段，实现多用户独立文件夹（当前版本为NULL，预留扩展）

#### 🔄 邮件移动逻辑优化

**智能移动规则实现**：

1. **前端逻辑**
   - `getAvailableFolders()`函数：根据当前文件夹和邮件状态返回可用的目标文件夹
   - 支持自定义文件夹：从`folders` ref中获取自定义文件夹列表
   - 已删除文件夹特殊处理：优先显示原文件夹

2. **移动规则**
   ```typescript
   switch (currentFolder) {
     case 'inbox':
       // 收件箱可以移动到：垃圾邮件、已删除、自定义文件夹
       availableFolders = [
         ...systemFolders.filter(f => f.value === 'spam' || f.value === 'trash'),
         ...customFolders
       ]
       break
     case 'sent':
       // 已发送可以移动到：已删除、自定义文件夹（不需要移动到垃圾邮件）
       availableFolders = [
         ...systemFolders.filter(f => f.value === 'trash'),
         ...customFolders
       ]
       break
     // ... 其他规则
   }
   ```

3. **原文件夹记录**
   - 移动到已删除文件夹时，自动记录原文件夹ID到`original_folder_id`字段
   - 还原时从`original_folder_id`获取原文件夹
   - 如果没有原文件夹记录，默认恢复到收件箱

#### ♻️ 已删除邮件管理功能

**还原功能实现**：

1. **后端实现**
   - `restore_email()`函数：从`original_folder_id`获取原文件夹并恢复
   - API端点：`POST /api/mail/:id/restore`
   - 数据库操作：更新`folder_id`为原文件夹ID，清空`original_folder_id`

2. **前端实现**
   - `restoreEmail()`函数：调用还原API
   - UI：已删除文件夹中每封邮件显示"还原"按钮（绿色）
   - 操作后自动更新邮件列表和统计信息

**彻底删除功能实现**：

1. **后端实现**
   - `hard_delete_email()`函数：真正删除邮件记录
   - API端点：`DELETE /api/mail/:id/permanent`
   - 数据库操作：`DELETE FROM emails WHERE id=?`（级联删除附件和收件人）

2. **前端实现**
   - `permanentlyDeleteEmail()`函数：调用彻底删除API
   - UI：已删除文件夹中每封邮件显示"彻底删除"按钮（红色）
   - 确认对话框：防止误操作
   - 操作后自动更新邮件列表和统计信息

**数据库结构更新**：

1. **字段添加**
   ```sql
   ALTER TABLE emails ADD COLUMN original_folder_id INT NULL 
   COMMENT '删除前的文件夹ID，用于还原' AFTER folder_id;
   ```

2. **自动升级**
   - 检测`original_folder_id`字段是否存在
   - 如果不存在，自动添加字段
   - 保证向后兼容性

3. **数据迁移**
   - 已存在的邮件`original_folder_id`为NULL
   - 新删除的邮件自动记录原文件夹ID

### 🔧 技术实现细节

#### 前端实现

**文件夹UI组件**：
- 侧边栏组件：固定宽度，包含所有文件夹按钮
- 文件夹按钮：统一的样式和交互效果
- 自定义文件夹：悬停显示操作按钮
- 管理对话框：创建、编辑、删除文件夹

**邮件移动逻辑**：
- `getAvailableFolders()`函数：根据业务规则返回可用文件夹
- 支持自定义文件夹：动态获取并显示
- 已删除文件夹特殊处理：显示原文件夹选项

**已删除邮件管理**：
- 还原按钮：绿色主题，调用还原API
- 彻底删除按钮：红色主题，带确认对话框
- 操作后自动刷新列表

#### 后端实现

**文件夹管理API**：
- `POST /api/mail/folders`：创建自定义文件夹
- `PUT /api/mail/folders/:id`：更新自定义文件夹
- `DELETE /api/mail/folders/:id`：删除自定义文件夹
- `GET /api/mail/folders`：获取文件夹列表

**邮件还原和删除API**：
- `POST /api/mail/:id/restore`：还原邮件
- `DELETE /api/mail/:id/permanent`：彻底删除邮件

**数据库脚本**：
- `add_folder()`函数：创建自定义文件夹
- `update_folder()`函数：更新自定义文件夹
- `delete_folder()`函数：删除自定义文件夹（软删除）
- `restore_email()`函数：还原邮件
- `hard_delete_email()`函数：彻底删除邮件
- `move_email()`函数：移动到已删除文件夹时记录原文件夹

### 📊 更新统计

- **UI重新设计**：1个（邮件文件夹侧边栏布局）
- **新增功能**：5个（自定义文件夹创建/编辑/删除、邮件还原、彻底删除）
- **功能优化**：2个（邮件移动逻辑、原文件夹记录）
- **数据库优化**：1个（添加original_folder_id字段）
- **代码优化**：多处（UI组件、API端点、数据库脚本）

### 🚀 升级指南

#### 升级步骤

1. **备份数据库**
   ```bash
   mysqldump -u mailuser -p maildb > maildb_backup_$(date +%Y%m%d).sql
   ```

2. **更新代码**
   ```bash
   cd /bash
   git pull  # 或直接替换文件
   ```

3. **数据库结构升级**
   - 系统会自动检测并添加`original_folder_id`字段
   - 运行`mail_db.sh init`确保数据库结构最新

4. **重启服务**
   ```bash
   systemctl restart mail-ops-dispatcher
   ```

5. **前端重新构建**（如果需要）
   ```bash
   cd frontend
   npm run build
   ```

#### 注意事项

- 数据库结构升级会自动执行，无需手动操作
- 已存在的邮件`original_folder_id`字段为NULL，不影响使用
- 自定义文件夹功能需要前端支持，确保前端代码已更新
- 已删除邮件的还原功能依赖`original_folder_id`字段，旧邮件可能无法还原

---

## 🎉 历史版本 - V3.2.1 (2025-11-21) - 系统设置完善与邮件功能优化

### 🎊 版本亮点

**V3.2.1 是一个系统设置完善与邮件功能优化版本，全面完善了通知设置功能，优化了系统设置的自动保存机制，修复了邮件发送相关问题，提升了系统的稳定性和用户体验。**

#### 🔔 通知设置功能全面完善
- **指标阈值配置**：添加CPU、内存、磁盘、网络使用率阈值设置，达到阈值自动发送警报
- **自动保存功能**：所有通知设置开关和阈值修改后自动保存，无需手动点击保存按钮
- **测试邮件增强**：测试邮件包含实时系统指标数据（CPU、内存、磁盘、负载、运行时间等）
- **智能阈值判断**：根据配置的阈值自动判断警告和严重级别，邮件中显示不同颜色标识

#### 🛠️ 系统设置自动保存优化
- **自动备份开关**：点击自动备份开关后自动保存设置
- **垃圾邮件过滤开关**：点击垃圾邮件过滤开关后自动保存设置
- **病毒扫描开关**：点击病毒扫描开关后自动保存设置
- **防抖优化**：使用500ms防抖机制，避免频繁保存请求

#### 📧 邮件发送功能修复
- **邮件目录自动创建**：发送测试邮件时自动检查并创建邮件目录，确保邮件能正常投递
- **变量作用域修复**：修复`domain is not defined`错误，确保变量在正确的作用域内定义
- **用户创建优化**：创建用户时自动创建邮件目录，支持Maildir格式
- **错误处理增强**：添加详细的错误日志和诊断信息，便于问题排查

#### 🔍 环境检查功能优化
- **操作日志保留**：环境检查按钮点击后，操作日志会保留在操作日志对话框中，与其他功能一致
- **yum仓库二次校验**：添加yum仓库二次校验功能，如果3个仓库（Rocky Linux、Docker CE、Kubernetes）都已存在，自动跳过配置步骤

#### 📦 安装脚本优化
- **仓库检测增强**：智能检测Rocky Linux仓库是否已配置为阿里云镜像
- **安装效率提升**：避免重复配置已存在的仓库，提升重装系统时的安装效率

### 📋 详细更新内容

#### 🔔 通知设置功能完善

**指标阈值配置实现**：

1. **前端UI增强**
   - 在通知设置中添加了指标阈值配置区域
   - 每个指标（CPU、内存、磁盘、网络）都有警告阈值和严重阈值两个配置项
   - 使用网格布局，清晰展示阈值配置

2. **自动保存功能**
   ```javascript
   const saveNotificationSettings = async () => {
     // 使用防抖，避免频繁保存
     if (saveNotificationSettings.timeout) {
       clearTimeout(saveNotificationSettings.timeout)
     }
     saveNotificationSettings.timeout = setTimeout(async () => {
       await saveSystemSettings()
     }, 500) // 500ms防抖
   }
   ```

3. **后端监控增强**
   - 修改了`SystemMonitor`类，从配置文件读取阈值而不是硬编码
   - 添加了`getNotificationThresholds()`方法，读取配置的阈值
   - 添加了`checkCpuUsage()`和`checkMemoryUsage()`方法
   - 所有检查都根据配置的阈值发送相应的警报

**测试邮件功能增强**：

1. **实时系统指标获取**
   - CPU使用率：实时获取并显示百分比
   - 内存使用率：实时获取并显示百分比
   - 磁盘使用率：实时获取并显示百分比
   - 系统负载：显示当前负载平均值
   - 运行时间：显示系统运行时长
   - 主机名：显示系统主机名

2. **邮件内容增强**
   - HTML格式：包含进度条和颜色标识（绿色/橙色/红色）
   - 纯文本格式：包含所有指标数据的文本版本
   - 阈值信息：显示当前配置的警告和严重阈值

#### 🛠️ 系统设置自动保存优化

**自动保存功能实现**：

1. **防抖机制**
   - `saveSystemSettings`函数添加了500ms防抖
   - 手动点击"保存设置"按钮时立即执行（不使用防抖）
   - 自动保存使用防抖，避免频繁请求

2. **按钮事件绑定**
   - 自动备份开关：`@change="saveSystemSettings"`
   - 垃圾邮件过滤开关：`@change="saveSystemSettings"`
   - 病毒扫描开关：`@change="saveSystemSettings"`

#### 📧 邮件发送功能修复

**邮件目录自动创建**：

1. **用户创建时自动创建目录**
   - `user_manage.sh`的`user_add`函数：创建用户时自动创建邮件目录
   - `mail_db.sh`的`add_mail_user`函数：添加邮件用户时自动创建邮件目录
   - 设置正确的权限（vmail:mail，700）

2. **测试邮件发送时创建目录**
   - 发送测试邮件时自动检查邮件目录是否存在
   - 如果不存在，自动创建目录和设置权限
   - 记录详细的错误日志

**变量作用域修复**：

1. **问题分析**
   - `domain`和`username`变量在`try`块内定义
   - 如果`try`块抛出异常，后续代码无法访问这些变量
   - 导致`domain is not defined`错误

2. **修复方案**
   - 将`domain`和`username`的定义移到`try`块之前
   - 添加邮箱格式验证
   - 在使用前检查变量是否存在

#### 🔍 环境检查功能优化

**操作日志保留功能**：

1. **问题分析**
   - 环境检查功能使用自己的对话框
   - 关闭对话框时清理了所有状态，导致日志丢失
   - 与其他功能（安装服务等）的行为不一致

2. **修复方案**
   - 修改`callEnvironmentCheck()`函数，执行后关闭环境检查对话框并显示操作日志对话框
   - 修改`closeEnvironmentCheckDialog()`函数，如果操作正在进行中，不清理状态
   - 修改`call()`函数，保留已有日志内容

**yum仓库二次校验功能**：

1. **检查逻辑实现**
   ```bash
   # 检查1: Rocky Linux仓库是否已配置为阿里云镜像
   if ls /etc/yum.repos.d/[Rr]ocky*.repo >/dev/null 2>&1; then
     if grep -q "mirrors.aliyun.com/rockylinux" /etc/yum.repos.d/[Rr]ocky*.repo; then
       repos_count++
     fi
   fi
   
   # 检查2: Docker CE仓库是否存在
   if [[ -f /etc/yum.repos.d/docker-ce.repo ]]; then
     repos_count++
   fi
   
   # 检查3: Kubernetes仓库是否存在
   if [[ -f /etc/yum.repos.d/kubernetes.repo ]]; then
     repos_count++
   fi
   ```

2. **智能跳过逻辑**
   - 如果3个仓库都存在（`repos_count == 3`），跳过`update_repos.sh`的执行
   - 如果部分仓库存在，继续执行配置以补全缺失的仓库

### 🔧 技术实现细节

#### 前端实现

**通知设置自动保存**：
- `saveNotificationSettings()`函数：使用防抖机制，500ms后自动保存
- 所有开关按钮和阈值输入框都绑定`@change`事件
- 警报邮箱输入框绑定`@blur`事件

**系统设置自动保存**：
- `saveSystemSettings()`函数：支持防抖和立即执行两种模式
- 手动保存按钮：`saveSystemSettings(true)`立即执行
- 自动保存：`saveSystemSettings()`使用防抖

#### 后端实现

**邮件目录自动创建**：
- `user_manage.sh`：创建用户时自动创建Maildir目录
- `mail_db.sh`：添加邮件用户时自动创建Maildir目录
- `server.js`：发送测试邮件时检查并创建目录

**系统监控阈值**：
- `getNotificationThresholds()`方法：从配置文件读取阈值
- `checkCpuUsage()`方法：检查CPU使用率并发送警报
- `checkMemoryUsage()`方法：检查内存使用率并发送警报
- `checkDiskUsage()`方法：使用配置的阈值检查磁盘使用率

### 📊 更新统计

- **新增功能**：4个（指标阈值配置、自动保存、测试邮件增强、yum仓库校验）
- **UI优化**：3个（通知设置、系统设置、环境检查）
- **Bug修复**：3个（邮件目录创建、变量作用域、操作日志保留）
- **代码优化**：多处（防抖机制、错误处理、日志记录）

### 🚀 升级指南

#### 升级步骤

1. **备份数据**
   ```bash
   # 备份数据库
   mysqldump -u root maildb > maildb_backup_$(date +%Y%m%d).sql
   mysqldump -u root mailapp > mailapp_backup_$(date +%Y%m%d).sql
   ```

2. **更新代码**
   ```bash
   cd /bash
   git pull origin main
   # 或手动更新文件
   ```

3. **重启服务**
   ```bash
   systemctl restart mail-ops-dispatcher
   ```

4. **验证功能**
   - 测试通知设置自动保存
   - 测试系统设置按钮自动保存
   - 测试邮件发送功能
   - 测试环境检查操作日志保留

#### 注意事项

- 本次更新主要是功能完善和Bug修复，不需要数据库迁移
- 通知设置和系统设置的自动保存功能需要前端重新构建（如果使用构建版本）
- yum仓库二次校验功能在重装系统时会自动生效

---

## 📋 历史版本记录

## 🎉 V3.2.0 (2025-11-20) - 草稿功能完善与邮件管理UI优化

### 🎊 版本亮点

**V3.2.0 是一个草稿功能完善与邮件管理UI优化版本，全面完善了草稿编辑功能，重新设计了移动和标签按钮UI，修复了附件发送功能，提升了邮件管理的用户体验和操作效率。**

#### 📝 草稿功能全面完善
- **一键编辑功能**：草稿箱中的草稿支持一键编辑，点击编辑按钮自动跳转到发送界面
- **草稿内容自动加载**：编辑草稿时自动加载收件人、抄送、主题、正文、附件等所有内容
- **附件恢复功能**：支持从Base64编码恢复附件为File对象，完整保留草稿附件
- **自动删除原草稿**：发送成功后自动删除原草稿，避免重复保存
- **优先级和重要性恢复**：编辑草稿时自动恢复邮件的优先级和重要性设置

#### 🎨 移动和标签按钮UI重新设计
- **现代化按钮设计**：使用悬停下拉菜单替代传统下拉框，提升用户体验
- **图标和动画效果**：添加文件夹图标和流畅的过渡动画，视觉效果更佳
- **智能移动逻辑**：根据当前文件夹智能显示可用的目标文件夹，避免不符合逻辑的操作
  - 收件箱 → 只能移动到：垃圾邮件、已删除
  - 已发送 → 只能移动到：垃圾邮件、已删除
  - 草稿箱 → 只能移动到：已删除（草稿应通过编辑发送）
  - 垃圾邮件 → 可以移动到：收件箱（恢复）、已删除
  - 已删除 → 可以移动到：收件箱（恢复）、垃圾邮件

#### 📎 附件发送功能修复
- **附件处理优化**：修复带附件邮件发送时的500错误，使用临时文件传递附件数据
- **Python转义修复**：修复附件存储时的Python代码转义问题，使用chr(92)避免bash heredoc转义问题
- **收件人不存在处理**：即使SMTP发送失败（收件人不存在），邮件也会保存到已发送文件夹

#### 🏷️ 标签管理功能增强
- **标签按钮美化**：重新设计标签按钮，使用紫色主题和颜色圆点标识
- **标签显示优化**：邮件详情页标签显示为可点击徽章，支持快速删除
- **悬停菜单优化**：标签下拉菜单支持滚动，适配大量标签场景

### 📋 详细更新内容

#### 📝 草稿编辑功能实现

**一键编辑功能**：

1. **草稿箱列表增强**
   - 在草稿箱列表中添加"编辑"按钮
   - 点击编辑按钮可跳转到发送界面并加载草稿内容

2. **编辑草稿函数实现**
   ```javascript
   async function editDraft(email: any) {
     // 获取完整的草稿详情（包括附件）
     const draftDetail = await fetch(`/api/mail/${email.id}`)
     
     // 加载草稿内容到表单
     to.value = draftDetail.to || ''
     cc.value = draftDetail.cc || ''
     subject.value = draftDetail.subject || ''
     body.value = draftDetail.body || draftDetail.html || ''
     
     // 从Base64恢复附件
     attachments.value = await Promise.all(
       draftDetail.attachments.map(att => 
         base64ToFile(att.content, att.name, att.type)
       )
     )
     
     // 切换到发送界面
     goto('compose')
   }
   ```

3. **附件恢复功能**
   - 实现 `base64ToFile` 函数，将Base64编码的附件恢复为File对象
   - 支持恢复附件名称、类型和内容

4. **自动删除原草稿**
   - 发送成功后自动删除原草稿
   - 如果当前在草稿箱视图，自动刷新列表

#### 🎨 移动和标签按钮UI重新设计

**移动按钮优化**：

1. **智能移动逻辑实现**
   ```javascript
   function getAvailableFolders(currentFolder: string, email?: any) {
     switch (currentFolder) {
       case 'inbox':
         // 收件箱可以移动到：垃圾邮件、已删除
         return ['spam', 'trash']
       case 'sent':
         // 已发送可以移动到：垃圾邮件、已删除
         return ['spam', 'trash']
       case 'drafts':
         // 草稿箱可以移动到：已删除
         return ['trash']
       case 'spam':
         // 垃圾邮件可以移动到：收件箱（恢复）、已删除
         return ['inbox', 'trash']
       case 'trash':
         // 已删除可以移动到：收件箱（恢复）、垃圾邮件
         return ['inbox', 'spam']
     }
   }
   ```

2. **UI设计改进**
   - 使用按钮样式替代下拉框
   - 悬停显示下拉菜单，减少点击操作
   - 添加文件夹图标，清晰标识文件夹类型
   - 添加过渡动画，提升交互体验

**标签按钮优化**：

1. **标签按钮美化**
   - 使用紫色主题配色
   - 标签显示颜色圆点
   - 悬停显示标签列表

2. **标签显示优化**
   - 邮件详情页标签显示为可点击徽章
   - 支持快速删除标签
   - 标签颜色动态显示

#### 📎 附件发送功能修复

**附件处理优化**：

1. **临时文件传递**
   ```javascript
   // 为每个存储操作创建临时文件
   const attachmentsFileInbox = `/tmp/attachments_${timestamp}_inbox.json`
   fs.writeFileSync(attachmentsFileInbox, attachmentsJson)
   
   // 传递临时文件路径而不是JSON字符串
   exec(`bash "${mailDbScript}" store ... "${attachmentsFileInbox}" ...`)
   ```

2. **Python转义修复**
   ```python
   # 使用chr(92)获取反斜杠字符，避免bash heredoc转义问题
   backslash = chr(92)
   filename_escaped = filename.replace(backslash, backslash + backslash).replace("'", "''")
   ```

3. **收件人不存在处理**
   - 即使SMTP发送失败，邮件也会保存到已发送文件夹
   - 返回友好的提示信息，告知用户邮件已保存但未成功投递

### 🔧 技术实现细节

#### 前端实现

**草稿编辑功能**：
- `editDraft` 函数：获取草稿详情并加载到表单
- `base64ToFile` 函数：从Base64恢复附件
- `editingDraftId` 状态：跟踪当前编辑的草稿ID
- `clearForm` 函数：清空编辑状态

**移动和标签按钮**：
- `getAvailableFolders` 函数：根据当前文件夹返回可用目标文件夹
- `getFolderIcon` 函数：获取文件夹图标路径
- 悬停下拉菜单：使用CSS hover和transition实现

#### 后端实现

**附件处理优化**：
- 临时文件创建：为每个存储操作创建独立的临时文件
- 临时文件清理：在每个exec回调中清理临时文件
- Python转义修复：使用chr(92)避免bash heredoc转义问题

**收件人不存在处理**：
- 错误类型检测：区分收件人不存在和其他错误
- 数据库存储：无论SMTP成功或失败，都存储到已发送文件夹
- 响应优化：返回友好的提示信息

### 📊 更新统计

- **新增功能**：3个（草稿编辑、智能移动逻辑、附件恢复）
- **UI优化**：2个（移动按钮、标签按钮）
- **Bug修复**：3个（附件发送500错误、Python转义问题、收件人不存在处理）
- **代码优化**：多处（临时文件管理、错误处理、状态管理）

### 🚀 升级指南

#### 升级步骤

1. **备份数据**
   ```bash
   # 备份数据库
   mysqldump -u root maildb > maildb_backup_$(date +%Y%m%d).sql
   mysqldump -u root mailapp > mailapp_backup_$(date +%Y%m%d).sql
   ```

2. **更新代码**
   ```bash
   cd /bash
   git pull origin main
   # 或手动更新文件
   ```

3. **重启服务**
   ```bash
   systemctl restart mail-ops-dispatcher
   ```

4. **验证功能**
   - 测试草稿编辑功能
   - 测试移动和标签按钮
   - 测试附件发送功能

#### 注意事项

- 本次更新主要是前端UI优化和功能完善，不需要数据库迁移
- 附件发送功能修复需要重启dispatcher服务
- 草稿编辑功能需要前端重新构建（如果使用构建版本）

---

## 📋 历史版本记录

## 🎉 V3.1.8 (2025-11-20) - 邮件发送功能完善与用户体验优化

### 🎊 版本亮点

**V3.1.8 是一个邮件发送功能完善与用户体验优化版本，全面修复了邮件发送、草稿保存和批量创建用户功能中的关键问题，确保邮件系统功能的完整性和可靠性。**

#### 📧 邮件发送功能全面修复
- **邮箱地址自动识别**：邮件发送时自动从数据库获取用户真实邮箱地址，不再使用硬编码的 `xm@localhost`
- **域名验证优化**：修复邮件发送时的域名验证逻辑，正确处理发件人和抄送收件人的域名验证
- **已发送文件夹查询修复**：修复已发送文件夹无法查询到邮件的问题，支持查询用户的所有可能邮箱地址
- **抄送域名验证**：添加抄送收件人的域名验证，确保所有收件人域名都在允许列表中

#### 💾 草稿保存功能完善
- **用户邮箱获取修复**：草稿保存时从数据库获取用户真实邮箱地址
- **附件处理优化**：使用临时文件传递附件数据，避免命令行参数过长和特殊字符问题
- **错误处理增强**：添加详细的日志输出和错误处理，确保草稿保存成功

#### 👥 批量创建用户功能优化
- **域名自动识别**：批量创建用户时自动从管理员邮箱或系统配置中提取域名
- **动态域名获取**：支持从管理员邮箱、域名列表、DNS配置中智能获取域名
- **用户体验提升**：创建的用户邮箱自动使用正确的域名格式

### 📋 详细更新内容

#### 🔧 邮件文件夹和详情API全面修复

**路由冲突问题修复**：

1. **问题分析**
   - Express路由按定义顺序匹配
   - `/api/mail/:id` 定义在 `/api/mail/folders` 之前
   - 请求 `/api/mail/folders` 被 `/api/mail/:id` 匹配（id="folders"）
   - 导致调用错误的 `detail "folders" "xm"` 命令

2. **修复方案**
   ```javascript
   // 移动参数路由到文件末尾
   app.get('/api/mail/:id', auth, (req, res) => {
     // 邮件详情处理逻辑
   });
   // 放在所有具体路由之后
   ```

**JSON查询过滤修复**：

1. **问题根源**
   - `get_folders()`、`get_labels()`、`get_folder_stats()` 使用 `grep -v "folders"` 过滤
   - 导致JSON数据被错误过滤，返回空结果

2. **修复方案**
   ```bash
   # 修改前（错误）
   | grep -v "folders" | grep -v "^$" | head -1
   
   # 修改后（正确）
   | tail -1
   ```

#### 📧 邮件详情显示问题彻底解决

**前端数据访问修复**：

1. **API响应结构**
   ```json
   {
     "success": true,
     "email": {
       "body": "邮件内容",
       "html": "",
       // ... 其他字段
     }
   }
   ```

2. **修复前的问题代码**
   ```javascript
   const emailDetail = await response.json()
   console.log('Email detail body:', emailDetail.body) // undefined
   ```

3. **修复后的正确代码**
   ```javascript
   const apiResponse = await response.json()
   const emailDetail = apiResponse.email || apiResponse
   console.log('Email detail body:', emailDetail.body) // "邮件内容"
   ```

#### ⚙️ 邮件存储和发送流程完整优化

**邮件目录自动创建完善**：

1. **问题分析**
   - DNS配置创建虚拟用户但不创建邮件目录
   - 测试邮件发送时Dovecot无法投递（User lookup failed）

2. **修复方案**
   ```javascript
   // 在test-email API中添加目录检查
   const mailDir = `/var/vmail/${domain}/${username}/Maildir`
   try {
     execSync(`mkdir -p ${mailDir}/new ${mailDir}/cur ${mailDir}/tmp`, { timeout: 5000 })
     execSync(`chown -R vmail:mail /var/vmail/${domain}`, { timeout: 5000 })
     execSync(`chmod -R 700 /var/vmail/${domain}`, { timeout: 5000 })
   } catch (dirError) {
     console.warn(`Failed to create mail directory for ${userEmail}:`, dirError.message)
   }
   ```

**存储命令参数优化**：

1. **HTML特殊字符问题**
   - 邮件存储命令包含HTML内容时会导致bash语法错误
   - 表现为邮件发送成功但不存储到数据库

2. **修复方案**
   ```javascript
   // 避免传递HTML内容到命令行
   const storeCommand = `bash "${mailDbScript}" store "${messageId}" "${fromAddr}" "${toAddr}" "${subjectText}" "${bodyText}" "" "inbox" "${sizeBytes}" "" "" "{}" "0" "0"`
   ```

#### 🗄️ 系统工具和脚本稳定性提升

**路径配置修复**：

1. **脚本路径错误**
   - 某些API使用 `path.join(__dirname, 'scripts', 'mail_db.sh')`
   - 实际路径应为 `path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')`

2. **修复方案**
   ```javascript
   // 修复前
   const mailDbScript = path.join(__dirname, 'scripts', 'mail_db.sh')
   
   // 修复后  
   const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
   ```

### 🔄 升级指南

#### 从 V3.1.7 升级到 V3.1.8

1. **备份当前系统（可选，但推荐）**
   ```bash
   # 备份数据库
   mysqldump -u root maildb > maildb_backup_$(date +%Y%m%d).sql
   mysqldump -u root mailapp > mailapp_backup_$(date +%Y%m%d).sql
   ```

2. **更新系统文件**
   ```bash
   # 更新代码后，重新编译前端（如果需要）
   cd /bash/frontend && npm run build
   
   # 重启dispatcher服务
   systemctl restart mail-ops-dispatcher
   ```

3. **验证邮件发送功能**
   ```bash
   # 发送一封测试邮件，检查：
   # 1. 邮件是否使用正确的发件人地址（如 xm@skills.com）
   # 2. 已发送文件夹是否能正确显示邮件
   # 3. 草稿保存功能是否正常工作
   ```

4. **验证批量创建用户功能**
   ```bash
   # 在前端批量创建用户，检查：
   # 1. 创建的邮箱地址是否使用正确的域名（如 user@skills.com）
   # 2. 而不是使用 localhost 域名（如 user@localhost）
   ```

5. **验证升级结果**
   - ✅ 邮件发送：使用数据库中的真实邮箱地址
   - ✅ 已发送文件夹：能正确查询到所有发送的邮件
   - ✅ 草稿保存：功能正常工作，附件正确保存
   - ✅ 批量创建用户：创建的邮箱地址使用正确的域名

#### 从 V3.1.6 升级到 V3.1.7

1. **备份当前系统（可选，但推荐）**
   ```bash
   # 备份数据库
   mysqldump -u root maildb > maildb_backup_$(date +%Y%m%d).sql
   mysqldump -u root mailapp > mailapp_backup_$(date +%Y%m%d).sql
   ```

2. **更新系统文件**
   ```bash
   # 更新代码后，重新执行启动脚本
   cd /bash && ./start.sh start
   ```

3. **验证数据库保护功能**
   ```bash
   # 检查日志，确认数据库保护功能生效
   # 应该看到类似以下日志：
   # [INFO] 检测到邮件数据库已存在且有数据，跳过数据库初始化以保留现有数据
   # [INFO] 检测到应用数据库已存在且有数据，跳过数据库初始化以保留现有数据
   ```

4. **验证系统通知功能**
   ```bash
   # 重启dispatcher服务
   systemctl restart mail-ops-dispatcher
   
   # 在前端发送测试邮件，验证system@localhost发送和黄色标签显示
   ```

5. **验证升级结果**
   - ✅ 数据库保护功能：重新执行 `./start.sh start` 时不会覆盖现有数据
   - ✅ 系统通知功能：测试邮件由 `system@localhost` 发送
   - ✅ 前端显示：系统通知邮件显示黄色标签和橙色背景
   - ✅ 系统监控：系统监控功能自动运行，达到阈值时发送通知

#### 从 V3.1.5 升级到 V3.1.6

1. **更新DNS配置脚本**
   ```bash
   # 脚本已自动更新，无需手动操作
   # 如需重新配置DNS，可运行：
   cd /bash && bash backend/scripts/dns_setup.sh configure-bind skills.com 192.168.0.107 xm@skills.com true true "8.8.8.8, 1.1.1.1"
   ```

2. **重新加载DNS配置**
   ```bash
   # 重新加载DNS配置
   rndc reload

   # 验证xm.skills.com解析
   nslookup xm.skills.com 127.0.0.1
   ```

3. **验证升级结果**
   - ✅ DNS解析正常：`xm.skills.com` 正确解析到服务器IP
   - ✅ 邮件系统功能完整：域名解析恢复正常

#### 从 V3.1.4 升级到 V3.1.5

1. **备份当前系统**
   ```bash
   # 备份数据库
   mysqldump -u root maildb > maildb_backup.sql
   mysqldump -u root mailapp > mailapp_backup.sql
   
   # 备份配置文件
   cp -r /bash /bash_backup
   ```

2. **更新系统文件**
   ```bash
   # 拉取最新代码
   cd /bash
   git pull origin main
   
   # 重启服务
   systemctl restart mail-ops-dispatcher
   systemctl restart httpd
   ```

3. **验证升级**
   ```bash
   # 测试邮件文件夹API
   curl -s "http://localhost:8081/api/mail/folders" -H "Authorization: Basic eG06eG02NjZA"
   
   # 测试邮件详情API
   curl -s "http://localhost:8081/api/mail/1" -H "Authorization: Basic eG06eG02NjZA"
   
   # 发送测试邮件验证完整流程
   curl -X POST "http://localhost:8081/api/notifications/test-email" \
     -H "Authorization: Basic eG06eG02NjZA" \
     -H "Content-Type: application/json" \
     -d '{"to": "xm@skills.com", "subject": "升级测试", "message": "V3.1.5升级测试邮件"}'
   ```

### 🐛 已知问题与修复

- ✅ **邮件文件夹API 500错误**：路由冲突导致，V3.1.5已修复
- ✅ **邮件详情显示为空**：前端数据访问错误，V3.1.5已修复  
- ✅ **测试邮件不显示在收件箱**：存储流程不完整，V3.1.5已修复
- ✅ **JSON查询返回空结果**：过滤逻辑错误，V3.1.5已修复

### 📊 兼容性说明

- **向后兼容**：✅ 完全兼容V3.1.4及之前版本
- **数据库兼容**：✅ 无数据库结构变更
- **API兼容**：✅ 保持现有API接口不变
- **前端兼容**：✅ 支持旧版本前端自动升级

---

## 🎉 历史版本 - V3.1.4 (2025-11-19) - 邮件显示问题深度修复与数据库连接稳定性优化

### 🎊 版本亮点

**V3.1.4 是一个邮件显示问题深度修复与数据库连接稳定性优化版本，主要聚焦于彻底解决邮件显示问题和数据库连接稳定性。**

#### 🔧 数据库连接问题深度修复
- **密码文件修复**：修复 `/etc/mail-ops/mail-db.pass` 密码文件格式问题，从Base64编码改为明文密码
- **数据库用户修复**：修复 `mail_db.sh` 中错误的数据库用户名 `maildbuser` → `mailuser`
- **权限配置修复**：确保数据库密码文件具有正确的权限设置（640）和所有者（root:xm）

#### 📧 邮件存储显示问题全面解决
- **邮件存储逻辑修复**：修复 `store_email` 函数中的整数表达式错误和MySQL查询格式问题
- **测试邮件API完善**：确保测试邮件正确发送到用户真实邮箱并存储到数据库
- **邮件查询优化**：修复邮件列表查询逻辑，确保收件箱能正确显示已接收邮件
- **收件人信息管理**：完善 `email_recipients` 表的收件人信息存储和管理

#### 🗄️ 数据库索引和表结构修复
- **索引创建修复**：修复 `start.sh` 中错误的索引创建语句，从 `folder` 列改为正确的 `folder_id` 列
- **表结构迁移**：确保数据库表结构从旧版（folder字段）正确迁移到新版（folder_id字段）
- **数据一致性保证**：完善数据迁移逻辑，确保旧数据和新数据结构的兼容性

#### ⚙️ 系统工具和脚本稳定性增强
- **脚本执行优化**：改进Bash脚本的错误处理和执行逻辑
- **日志记录完善**：增强系统操作日志的记录和错误诊断能力
- **配置同步优化**：确保系统设置、DNS配置和邮件配置之间的数据同步

### 📋 详细更新内容

#### 🔧 数据库连接问题深度修复

**密码文件格式修复**：

1. **密码文件问题诊断**
   - `/etc/mail-ops/mail-db.pass` 文件包含Base64编码内容
   - `mail_db.sh` 脚本期望明文密码格式
   - 导致数据库连接失败和邮件存储功能异常

2. **修复方案**
   ```bash
   # 修复密码文件内容
   echo "mailpass" > /etc/mail-ops/mail-db.pass
   
   # 设置正确的权限
   chmod 640 /etc/mail-ops/mail-db.pass
   chown root:xm /etc/mail-ops/mail-db.pass
   ```

**数据库用户名修复**：

1. **用户名配置错误**
   - `mail_db.sh` 中配置的数据库用户名为 `maildbuser`
   - 实际创建的数据库用户为 `mailuser`
   - 导致数据库连接权限错误

2. **修复方案**
   ```bash
   # mail_db.sh 中修改配置
   DB_USER="mailuser"  # 从 "maildbuser" 修正为 "mailuser"
   ```

#### 📧 邮件存储显示问题全面解决

**store_email 函数修复**：

1. **整数表达式错误**
   - 原始代码：`local exists=$(mysql_connect "SELECT COUNT(*) FROM emails WHERE message_id='$message_id'" | tail -1)`
   - 问题：`mysql_connect` 函数输出完整表格式，导致 `exists` 变量不是纯数字
   - 修复：使用 `-s -r` 参数获取纯数值输出

2. **修复后的代码**
   ```bash
   local exists=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT COUNT(*) FROM emails WHERE message_id='$message_id'" 2>/dev/null | tail -1)
   ```

**测试邮件API完善**：

1. **用户邮箱获取优化**
   - API现在从数据库动态获取用户的真实邮箱地址
   - 确保邮件发送到正确的邮箱（`xm@skills.com` 而不是前端传递的参数）

2. **邮件存储完整性**
   - 邮件正确存储到 `emails` 表
   - 收件人信息正确存储到 `email_recipients` 表
   - 支持收件箱查询的精确匹配

#### 🗄️ 数据库索引和表结构修复

**start.sh 索引创建修复**：

1. **索引创建错误**
   - 原始代码：`CREATE INDEX IF NOT EXISTS idx_emails_folder ON emails(folder);`
   - 问题：当前表结构使用 `folder_id` 字段，没有 `folder` 字段
   - 导致索引创建失败

2. **修复方案**
   ```sql
   CREATE INDEX IF NOT EXISTS idx_emails_folder_id ON emails(folder_id);
   ```

**表结构迁移保证**：

1. **数据迁移逻辑**
   - `mail_db.sh` 中的 `migrate_folder_data` 函数确保旧数据正确迁移
   - 从 `folder` 字段迁移到 `folder_id` 字段
   - 保持数据一致性和向后兼容性

#### ⚙️ 系统工具和脚本稳定性增强

**脚本执行优化**：

1. **错误处理改进**
   - 增强MySQL连接错误处理
   - 改进脚本执行结果判断逻辑

2. **日志记录完善**
   - 增加详细的调试日志
   - 优化错误信息输出格式

3. **配置同步优化**
   - 确保DNS配置、邮件配置和系统设置之间的数据同步
   - 修复配置不同步导致的问题

## 🎉 历史版本 - V3.1.3 (2025-11-19) - 系统稳定性与数据库检测工具完善

### 🎊 版本亮点

**V3.1.3 是一个系统稳定性与数据库检测工具完善版本，主要聚焦于数据库检测工具升级、服务安装稳定性修复和邮件系统功能完善。**

#### 📊 数据库检测工具全面升级
- **多数据库支持**：mail_CX.sh脚本支持同时检测maildb和mailapp两个数据库
- **美观报告格式**：Markdown格式输出，包含表结构、外键关系、示例数据和健康检查
- **智能权限处理**：自动识别数据库类型，使用正确的用户连接（maildb用mailuser，mailapp用root）
- **健康检查增强**：包含MySQL版本信息、连接状态、性能指标和智能建议
- **统计信息完善**：提供表数量、记录数、大小统计和索引信息

#### 🔧 服务安装稳定性修复
- **前端安装判断优化**：修复安装超时问题，增加等待时间和成功检测逻辑
- **安装状态准确性**：正确识别脚本执行成功，避免误报安装失败
- **错误处理改进**：增强超时处理，即使超时也检查最终执行结果

#### 📧 邮件系统功能完善
- **测试邮件修复**：修复测试邮件发送到用户真实邮箱，确保邮件能正确存储和显示
- **DNS配置优化**：DNS配置后管理员邮箱自动同步到所有相关数据库和配置
- **邮件显示问题解决**：修复收件箱为空的问题，确保邮件正确显示

#### 🛠️ 系统工具增强
- **脚本权限修复**：修复mail_CX.sh脚本的数据库连接权限问题
- **日志系统优化**：改进操作日志记录和错误处理
- **配置同步完善**：确保DNS配置、邮件配置和系统设置之间的数据一致性

### 📋 详细更新内容

#### 📊 数据库检测工具全面升级

**`mail_CX.sh` 脚本增强**：

1. **多数据库支持**
   - 支持同时检测 `maildb`（邮件数据库）和 `mailapp`（应用数据库）
   - 自动识别数据库类型和权限要求
   - 提供统一的检测和报告格式

2. **美观报告格式**
   - Markdown格式输出，支持结构化展示
   - 包含系统概览、数据库状态、详细统计信息
   - 提供表结构、外键关系、示例数据展示

3. **智能权限处理**
   - `maildb` 数据库使用 `mailuser` 用户连接
   - `mailapp` 数据库使用 `root` 用户连接
   - 自动处理权限问题，避免连接失败

4. **健康检查增强**
   - MySQL版本信息展示
   - 数据库连接状态检查
   - 性能指标监控（查询缓存、活跃连接）
   - 智能健康建议（空表检测、大表警告）

5. **统计信息完善**
   - 表数量统计
   - 记录数和大小统计
   - 索引信息展示
   - 外键关系分析

#### 🔧 服务安装稳定性修复

**`frontend/src/modules/Dashboard.vue` 前端优化**：

1. **安装判断逻辑优化**
   - 增加安装操作等待时间到2分钟
   - 优化轮询间隔为2秒，减少API调用频率
   - 增强成功/失败关键词检测

2. **超时处理改进**
   - 即使超时也进行最终结果检查
   - 避免误报安装失败
   - 提供更准确的安装状态反馈

#### 📧 邮件系统功能完善

**`backend/dispatcher/server.js` 测试邮件修复**：

1. **用户邮箱获取优化**
   - 从数据库获取用户的真实邮箱地址
   - 不再依赖前端传递的参数
   - 确保邮件发送到正确的地址

2. **邮件存储逻辑修复**
   - 使用真实邮箱地址创建虚拟用户
   - 正确存储邮件到数据库
   - 确保邮件能被前端正确查询和显示

**`backend/scripts/dns_setup.sh` DNS配置优化**：

1. **管理员邮箱同步**
   - DNS配置后自动更新数据库中的管理员邮箱
   - 同步更新maildb和mailapp两个数据库
   - 确保前端显示正确的管理员邮箱

#### 🛠️ 系统工具增强

**权限和配置修复**：

1. **脚本权限修复**
   - 修复mail_CX.sh数据库连接权限问题
   - 确保脚本能正确访问所有相关数据库

2. **日志系统优化**
   - 改进操作日志记录格式
   - 增强错误处理和记录

3. **配置同步完善**
   - 确保DNS配置、邮件配置和系统设置数据一致性
   - 修复配置不同步导致的问题

## 🎉 历史版本 - V3.1.2 (2025-11-19) - 管理员邮箱动态显示与DNS配置自动同步

### 🎊 版本亮点

**V3.1.2 是一个管理员邮箱动态显示与DNS配置自动同步版本，主要聚焦于管理员邮箱动态显示、DNS配置自动同步管理员邮箱和系统设置与数据库双向同步。**

#### 📧 管理员邮箱动态显示
- **管理员邮箱API端点**：新增 `/api/admin-email` API，从数据库动态获取管理员邮箱
- **前端动态显示**：Layout组件和Mail模块动态显示从数据库获取的管理员邮箱
- **邮件识别优化**：邮件列表中管理员邮件标识基于动态获取的邮箱地址，支持多域名配置
- **实时同步**：DNS配置成功后管理员邮箱自动更新，前端立即显示最新邮箱

#### 🔄 DNS配置自动同步管理员邮箱
- **自动邮箱更新**：DNS配置成功后自动将管理员邮箱更新为 `xm@域名` 格式
- **数据库同步**：DNS配置时自动同步更新数据库中的管理员邮箱
- **系统设置同步**：DNS配置时自动同步更新系统设置和通知设置中的管理员邮箱
- **mail_db.sh命令扩展**：新增 `update-admin-email` 命令，提供标准化的管理员邮箱更新接口

#### 🔧 系统设置与数据库双向同步
- **优先数据库读取**：系统设置加载时优先从数据库读取管理员邮箱，确保数据一致性
- **保存时同步**：系统设置保存时自动同步更新数据库中的管理员邮箱
- **多重同步保证**：系统设置文件、通知设置、数据库三重同步，确保所有地方的数据一致

### 📋 详细更新内容

#### 📧 管理员邮箱动态显示

**`backend/dispatcher/server.js` 后端API更新**：

1. **管理员邮箱API端点**
   - 新增 `/api/admin-email` GET端点，查询数据库中xm用户的邮箱地址
   - 返回格式：`{ success: true, email: 'xm@skills.com', username: 'xm', display: '系统管理员 (xm@skills.com)' }`
   - 查询失败时返回默认值 `xm@localhost`
   - 支持实时查询，确保前端显示最新的管理员邮箱

2. **系统设置加载优化**
   - 修改 `/api/system-settings` GET端点，优先从数据库读取管理员邮箱
   - 如果数据库中有值，覆盖配置文件中的管理员邮箱
   - 确保系统设置中的管理员邮箱始终与数据库保持一致

**`frontend/src/components/Layout.vue` 前端更新**：

1. **管理员邮箱动态显示**
   - 添加 `adminEmail` 和 `adminEmailDisplay` 响应式变量
   - 添加 `fetchAdminEmail()` 函数，从API获取管理员邮箱
   - 修改模板，将硬编码的"系统管理员"改为动态显示 `{{ adminEmailDisplay }}`
   - 组件挂载时自动获取管理员邮箱

2. **实时更新机制**
   - 页面加载时自动获取最新的管理员邮箱
   - 支持DNS配置后自动更新显示
   - 向后兼容，查询失败时使用默认值

**`frontend/src/modules/Mail.vue` 前端更新**：

1. **管理员邮件识别优化**
   - 添加 `adminEmail` 响应式变量和 `fetchAdminEmail()` 函数
   - 修改 `isAdminSender()` 函数，基于动态获取的邮箱地址识别管理员邮件
   - 支持多域名配置（localhost、skills.com等）
   - 保持向后兼容，支持旧的邮箱格式

2. **邮件列表标识**
   - 邮件列表中管理员发件人的邮件正确显示红色"系统管理员"标签
   - 邮件详情中管理员发件人正确识别
   - 实时更新，DNS配置后立即生效

#### 🔄 DNS配置自动同步管理员邮箱

**`backend/dispatcher/server.js` 后端API更新**：

1. **Bind DNS配置自动更新**
   - 在Bind DNS配置成功后，根据配置的域名自动生成管理员邮箱：`xm@域名`
   - 自动更新系统设置文件中的 `general.adminEmail` 和 `notifications.alertEmail`
   - 调用 `mail_db.sh update-admin-email` 命令更新数据库中的管理员邮箱
   - 确保DNS配置和管理员邮箱配置的一致性

2. **公网DNS配置自动更新**
   - 在公网DNS配置成功后，根据配置的域名自动生成管理员邮箱：`xm@域名`
   - 自动更新系统设置文件中的管理员邮箱
   - 同步更新数据库中的管理员邮箱
   - 确保所有配置的一致性

**`backend/scripts/mail_db.sh` 脚本更新**：

1. **update-admin-email命令**
   - 新增 `update_admin_email()` 函数，更新数据库中xm用户的邮箱地址
   - 添加邮箱格式验证，确保邮箱地址格式正确
   - 提供详细的日志记录和错误处理
   - 在main函数中添加 `update-admin-email` case处理

2. **命令使用**
   - 命令格式：`mail_db.sh update-admin-email <new_email>`
   - 示例：`mail_db.sh update-admin-email "xm@skills.com"`
   - 提供标准化的管理员邮箱更新接口，供其他脚本调用

#### 🔧 系统设置与数据库双向同步

**`backend/dispatcher/server.js` 后端API更新**：

1. **系统设置加载优化**
   - 修改 `/api/system-settings` GET端点，优先从数据库读取管理员邮箱
   - 如果数据库中有值，覆盖配置文件中的管理员邮箱
   - 如果数据库中没有值，使用配置文件中的值
   - 确保系统设置中的管理员邮箱始终是最新的

2. **系统设置保存优化**
   - 修改 `/api/system-settings` POST端点，保存时同步更新数据库
   - 如果保存的管理员邮箱有效，自动更新数据库中的xm用户邮箱
   - 确保系统设置文件和数据库中的数据保持一致
   - 提供详细的日志记录和错误处理

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/dispatcher/server.js
# - backend/scripts/mail_db.sh
# - frontend/src/components/Layout.vue
# - frontend/src/modules/Mail.vue
```

#### 3. 重启调度层服务

```bash
# 重启调度层服务以应用更改
systemctl restart mail-ops-dispatcher

# 检查服务状态
systemctl status mail-ops-dispatcher
```

#### 4. 验证更新

```bash
# 检查版本号
grep "SCRIPT_VERSION" /bash/start.sh

# 测试管理员邮箱API
curl -X GET http://localhost:3001/api/admin-email -H "Authorization: Basic eG06" | jq .

# 测试DNS配置自动更新管理员邮箱
# 在前端配置DNS，检查管理员邮箱是否自动更新为 xm@域名
```

### ⚠️ 注意事项

1. **管理员邮箱显示**：更新后，前端会动态显示从数据库获取的管理员邮箱，DNS配置后会自动更新
2. **DNS配置同步**：DNS配置成功后，管理员邮箱会自动更新为新域名格式，无需手动配置
3. **数据一致性**：系统设置文件和数据库中的管理员邮箱会自动保持同步，确保数据一致性

---

## 📋 历史版本记录

## 🎉 V3.1.1 (2025-11-19) - DNS配置状态检查与系统设置保存优化

### 🎊 版本亮点

**V3.1.1 是一个DNS配置状态检查与系统设置保存优化版本，主要聚焦于DNS配置状态检查修复、邮件发送功能完善、系统设置保存优化和DNS服务安装修复。**

#### 🌐 DNS配置状态检查修复
- **DNS配置状态字段补全**：修复DNS配置成功后未正确标记配置状态的问题，自动添加 `dns.configured` 和 `dns.type` 字段
- **Bind DNS配置状态更新**：Bind DNS配置成功后自动更新系统设置文件，标记DNS已配置
- **公网DNS配置状态更新**：公网DNS配置成功后自动更新系统设置文件，标记DNS已配置
- **配置状态检查优化**：改进DNS配置状态检查逻辑，确保前端正确显示DNS配置状态

#### 📧 邮件发送功能完善
- **邮件存储参数修复**：修复测试邮件发送后存储参数不匹配的问题，确保邮件正确存储到数据库
- **邮件列表查询优化**：修复邮件列表查询使用用户名而非邮箱地址的问题，使用用户真实邮箱地址查询
- **邮件查询逻辑优化**：优化邮件查询逻辑，支持完整邮箱地址的精确匹配，提高查询准确性

#### 🔧 系统设置保存优化
- **管理员邮箱保存修复**：修复前端管理员邮箱更新后丢失的问题，避免配置成功后重新加载覆盖数据
- **保存结果验证**：添加系统设置保存结果验证机制，确保数据正确保存
- **数据覆盖问题修复**：移除配置成功后的自动重新加载，避免覆盖刚刚保存的数据

#### 🛠️ DNS服务安装修复
- **错误处理优化**：优化DNS服务安装的错误处理，允许部分组件安装失败，确保安装过程更加稳定
- **安装验证增强**：添加DNS服务安装验证，检查是否至少安装了bind包
- **日志改进**：改进安装日志，即使部分组件安装失败也会记录警告并继续执行

### 📋 详细更新内容

#### 🌐 DNS配置状态检查修复

**`backend/dispatcher/server.js` 后端API更新**：

1. **Bind DNS配置状态更新**
   - 在Bind DNS配置成功后，自动更新系统设置文件
   - 设置 `dns.configured = true` 和 `dns.type = 'bind'`
   - 更新 `dns.bind` 配置项（domain、serverIp、adminEmail等）
   - 确保前端能正确识别DNS配置状态

2. **公网DNS配置状态更新**
   - 在公网DNS配置成功后，自动更新系统设置文件
   - 设置 `dns.configured = true` 和 `dns.type = 'public'`
   - 更新 `dns.public` 配置项（domain、serverIp等）
   - 确保前端能正确识别DNS配置状态

3. **配置状态检查逻辑优化**
   - 改进DNS配置状态检查逻辑，正确读取 `dns.configured` 和 `dns.type` 字段
   - 验证配置完整性（检查domain和serverIp是否有效）
   - 执行DNS解析测试验证配置是否正常工作

#### 📧 邮件发送功能完善

**`backend/dispatcher/server.js` 后端API更新**：

1. **邮件存储参数修复**
   - 修复 `mail_db.sh store` 调用时参数不匹配的问题
   - 更新 `mail_db.sh` 的 `store` case，正确传递所有13个参数给 `store_email` 函数
   - 确保测试邮件发送后能正确存储到数据库

2. **邮件列表查询优化**
   - 修复 `/api/mail/list` API直接使用用户名查询的问题
   - 添加用户邮箱地址查询逻辑，从 `mail_users` 表获取用户真实邮箱
   - 使用用户真实邮箱地址查询邮件，而不是用户名

3. **邮件查询逻辑优化**
   - 更新 `mail_db.sh` 的 `get_emails` 函数，支持完整邮箱地址的精确匹配
   - 优化收件箱和已发送邮件的查询逻辑
   - 提高邮件查询的准确性和性能

#### 🔧 系统设置保存优化

**`frontend/src/modules/Dashboard.vue` 前端更新**：

1. **管理员邮箱保存修复**
   - 移除配置成功后的自动重新加载系统设置
   - 避免 `loadSystemSettings()` 覆盖刚刚保存的数据
   - 改为直接验证保存结果，确保数据正确保存

2. **保存结果验证**
   - 添加系统设置保存结果验证机制
   - 验证服务器端数据是否正确保存
   - 提供明确的成功/失败反馈

3. **数据覆盖问题修复**
   - 修复配置成功后重新加载导致的数据覆盖问题
   - 保持本地状态与服务器端数据的一致性
   - 改进错误处理和用户反馈

#### 🛠️ DNS服务安装修复

**`backend/scripts/dns_setup.sh` 脚本更新**：

1. **错误处理优化**
   - 优化 `install_bind()` 函数的错误处理
   - 允许 `dnf update` 和 `dnf install` 失败，不影响后续执行
   - 添加错误捕获和警告日志

2. **安装验证增强**
   - 添加DNS服务安装验证，检查是否至少安装了bind包
   - 使用 `command -v named` 或 `rpm -q bind` 验证安装
   - 即使部分组件安装失败，也会继续执行

3. **日志改进**
   - 改进安装日志，记录详细的安装过程
   - 即使部分组件安装失败，也会记录警告并继续执行
   - 提供清晰的安装状态反馈

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/dispatcher/server.js
# - backend/scripts/mail_db.sh
# - backend/scripts/dns_setup.sh
# - frontend/src/modules/Dashboard.vue
```

#### 3. 修复DNS配置状态（如果需要）

如果您的DNS已配置但前端显示"未配置"，可以手动修复：

```bash
# 检查DNS配置
cat /bash/config/system-settings.json | jq '.dns'

# 如果缺少 configured 和 type 字段，手动添加：
# 对于Bind DNS：
jq '.dns.configured = true | .dns.type = "bind"' /bash/config/system-settings.json > /tmp/system-settings.json.tmp && mv /tmp/system-settings.json.tmp /bash/config/system-settings.json

# 对于公网DNS：
jq '.dns.configured = true | .dns.type = "public"' /bash/config/system-settings.json > /tmp/system-settings.json.tmp && mv /tmp/system-settings.json.tmp /bash/config/system-settings.json
```

#### 4. 重启调度层服务

```bash
# 重启调度层服务以应用更改
systemctl restart mail-ops-dispatcher

# 检查服务状态
systemctl status mail-ops-dispatcher
```

#### 5. 验证更新

```bash
# 检查版本号
grep "SCRIPT_VERSION" /bash/start.sh

# 测试DNS配置状态检查
curl -X GET http://localhost:3001/api/system-status -H "Authorization: Basic eG06" | jq '.dns'

# 测试邮件发送功能
# 在前端测试邮件通知功能，检查邮件是否能正确显示
```

### ⚠️ 注意事项

1. **DNS配置状态修复**：如果您的DNS已配置但前端显示"未配置"，需要手动修复系统设置文件中的DNS状态字段
2. **邮件查询优化**：更新后，邮件列表查询会使用用户真实邮箱地址，确保查询准确性
3. **系统设置保存**：更新后，管理员邮箱等系统设置保存后不会再丢失，配置更加可靠

---

## 📋 历史版本记录

## 🎉 V3.1.0 (2025-11-18) - 服务安装修复与系统设置权限优化

### 🎊 版本亮点

**V3.1.0 是一个服务安装修复与系统设置权限优化版本，主要聚焦于安全加固服务安装修复、系统设置保存权限优化和脚本健壮性提升。**

#### 🔧 安全加固服务安装修复
- **spam_filter.sh未绑定变量修复**：修复 `spam_filter.sh` 脚本中 `$2` 未绑定变量问题，使用 `${2:-}` 提供默认值
- **security.sh退出码修复**：确保 `security.sh` 脚本在所有操作完成后明确返回成功退出码（0）
- **错误处理优化**：改进错误处理逻辑，确保即使有警告也能正常完成安装

#### 🔐 系统设置保存权限优化
- **config目录权限自动修复**：保存系统设置时自动修复 `config` 目录的所有者为 `xm:xm`
- **文件权限自动修复**：保存系统设置时自动修复 `system-settings.json` 文件的所有者为 `xm:xm`，权限为 `644`
- **权限错误自动处理**：如果文件写入失败（权限问题），自动使用 `sudo` 删除旧文件后重新创建
- **错误处理增强**：添加详细的权限错误日志和友好的错误提示

#### 🛠️ 脚本健壮性提升
- **变量初始化优化**：确保所有脚本变量都有默认值，避免未绑定变量错误
- **退出码明确化**：所有脚本操作完成后明确返回成功或失败状态
- **权限检查增强**：改进权限检查和修复机制，确保服务正常运行

### 📋 详细更新内容

#### 🔧 安全加固服务安装修复

**`backend/scripts/spam_filter.sh` 脚本更新**：

1. **未绑定变量修复**
   - 问题：`spam_filter.sh` 脚本第484行使用了 `local email_file="$2"`，当调用 `spam_filter.sh config` 时没有传递第二个参数，由于脚本使用了 `set -u`，导致报错退出
   - 修复：将 `local email_file="$2"` 改为 `local email_file="${2:-}"`，即使没有第二个参数也不会报错
   - 影响：`config` action 现在可以正常执行，不再报未绑定变量错误

**`backend/scripts/security.sh` 脚本更新**：

1. **退出码修复**
   - 问题：`security.sh` 脚本没有明确返回成功退出码，虽然脚本执行完成，但可能因为某些警告导致退出码非零
   - 修复：在每个 case 分支的最后添加了 `exit 0`，确保脚本即使有警告也能返回成功状态
   - 影响：前端现在可以正确识别安全加固服务安装成功

#### 🔐 系统设置保存权限优化

**`backend/dispatcher/server.js` 后端API更新**：

1. **config目录权限自动修复**
   - 创建目录时设置权限为 `755`
   - 自动修复目录所有者为 `xm:xm`（使用 `chown` 或 `sudo chown`）
   - 确保调度层服务（以 `xm` 用户运行）可以访问配置目录

2. **文件权限自动修复**
   - 写入文件后自动修复文件所有者为 `xm:xm`
   - 设置文件权限为 `644`
   - 如果 `chown` 失败，尝试使用 `sudo chown`

3. **权限错误自动处理**
   - 如果文件写入失败（EACCES 或 EPERM 错误），自动使用 `sudo` 删除旧文件后重新创建
   - 确保即使文件属于 `root`，也能成功保存设置
   - 添加详细的错误日志和友好的错误提示

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/scripts/spam_filter.sh
# - backend/scripts/security.sh
# - backend/dispatcher/server.js
```

#### 3. 修复配置文件权限（如果需要）

```bash
# 修复config目录权限
chown -R xm:xm /bash/config
chmod -R 755 /bash/config

# 修复system-settings.json文件权限
chown xm:xm /bash/config/system-settings.json
chmod 644 /bash/config/system-settings.json
```

#### 4. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] 安全加固服务可以正常安装（不再报未绑定变量错误）
- [ ] 系统设置可以正常保存（不再报权限错误）
- [ ] config目录和文件的所有者都是 `xm`（`ls -la /bash/config`）
- [ ] 系统设置保存后文件权限正确（`ls -la /bash/config/system-settings.json`）
- [ ] 调度层服务日志中没有权限相关错误

**注意事项**：
- 如果config目录或文件属于root，系统会自动修复权限
- 如果自动修复失败，可以手动执行 `chown -R xm:xm /bash/config` 修复权限
- 安全加固服务安装时，即使有警告也会正常完成

---

## V3.0.8 (2025-11-17) - 通知邮件功能完善与Dovecot配置优化

### 🎊 版本亮点

**V3.0.8 是一个通知邮件功能完善与Dovecot配置优化版本，主要聚焦于通知邮件自动存储到数据库、收件人用户自动创建、Dovecot LMTP配置优化和邮件发送流程优化。**

#### 📧 通知邮件功能完善
- **邮件自动存储到数据库**：通知邮件发送成功后自动存储到数据库，前端可立即看到邮件
- **收件人用户自动创建**：发送邮件前自动检查并创建收件人用户（如果不存在），确保Postfix可以投递邮件
- **邮件目录自动创建**：自动创建Maildir目录结构并设置正确的权限
- **邮件存储机制优化**：测试邮件和系统通知邮件发送成功后都会自动存储到数据库

#### 🔧 Dovecot LMTP配置优化
- **LMTP Socket配置**：配置Dovecot LMTP socket在Postfix可以访问的位置（`/var/spool/postfix/private/dovecot-lmtp`）
- **Postfix virtual_mailbox_base配置**：添加 `virtual_mailbox_base` 配置，即使使用LMTP也需要此配置
- **权限配置优化**：确保LMTP socket文件有正确的权限（postfix用户和组，0600模式）
- **服务重启优化**：配置完成后自动重启Dovecot服务以应用新配置

#### 🔄 邮件发送流程优化
- **发送前检查**：发送邮件前检查Postfix服务状态
- **错误处理增强**：添加详细的错误日志和错误信息
- **超时处理**：添加30秒超时机制，防止邮件发送卡死
- **数据库同步**：邮件发送成功后立即同步到数据库，无需等待Maildir同步

### 📋 详细更新内容

#### 📧 通知邮件功能完善

**`backend/dispatcher/server.js` 后端API更新**：

1. **邮件发送前自动创建收件人用户**
   - 在 `POST /api/notifications/test-email` 端点中，发送邮件前检查收件人是否存在于 `virtual_users` 表
   - 如果域名不存在，自动创建域名
   - 如果用户不存在，自动创建用户（使用默认密码，仅用于接收系统通知）
   - 自动创建Maildir目录结构并设置正确的权限

2. **邮件发送成功后自动存储到数据库**
   - 在 `POST /api/notifications/test-email` 端点中，邮件发送成功后自动调用 `mail_db.sh store` 存储邮件
   - 在 `sendNotificationEmail()` 函数中，邮件发送成功后也自动存储到数据库
   - 确保前端可以立即看到发送的邮件

3. **邮件头信息构建**
   - 构建完整的邮件头信息（Message-ID、From、To、Subject、Date等）
   - 添加X-Mailer和X-Priority头信息
   - 确保邮件信息完整

**`backend/scripts/mail_setup.sh` 脚本更新**：

1. **configure_dovecot函数增强**
   - 配置Dovecot LMTP socket在Postfix可以访问的位置
   - 确保 `/var/spool/postfix/private/dovecot-lmtp` socket文件存在
   - 设置正确的权限（postfix用户和组，0600模式）

2. **configure_postfix函数增强**
   - 添加 `virtual_mailbox_base` 配置（即使使用LMTP也需要）
   - 添加 `virtual_minimum_uid`、`virtual_uid_maps`、`virtual_gid_maps` 配置
   - 确保Postfix配置完整

#### 🔧 Dovecot LMTP配置优化

**`backend/scripts/mail_setup.sh` 脚本更新**：

1. **LMTP Socket配置**
   - 在 `configure_dovecot()` 函数中添加LMTP socket配置
   - 配置socket路径为 `/var/spool/postfix/private/dovecot-lmtp`
   - 设置正确的用户、组和权限

2. **10-master.conf配置**
   - 检查 `10-master.conf` 文件是否存在
   - 如果不存在service lmtp块，添加新的配置块
   - 如果存在但未配置socket，在现有块中添加socket配置

3. **Postfix private目录**
   - 确保 `/var/spool/postfix/private` 目录存在
   - 设置正确的权限（postfix用户和组）

#### 🔄 邮件发送流程优化

**`backend/dispatcher/server.js` 后端API更新**：

1. **发送前检查**
   - 检查Postfix服务是否运行
   - 验证邮箱格式
   - 检查收件人用户是否存在（不存在则创建）

2. **错误处理增强**
   - 添加详细的错误日志（错误代码、响应码、错误消息等）
   - 提供更友好的错误提示
   - 记录错误到用户操作日志

3. **超时处理**
   - 添加30秒超时机制
   - 超时后返回友好的错误提示
   - 防止邮件发送卡死

4. **数据库同步**
   - 邮件发送成功后立即调用 `mail_db.sh store` 存储邮件
   - 确保邮件信息完整（包括message_id、from、to、subject、body、html等）
   - 前端可以立即看到发送的邮件

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/scripts/mail_setup.sh
# - backend/dispatcher/server.js
```

#### 3. 重新配置邮件系统

```bash
# 重新配置Dovecot和Postfix
cd /bash
bash backend/scripts/mail_setup.sh configure skills.com
```

#### 4. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher

# 重启Dovecot服务（如果需要）
systemctl restart dovecot

# 重启Postfix服务（如果需要）
systemctl restart postfix
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] Dovecot LMTP socket文件存在（`ls -la /var/spool/postfix/private/dovecot-lmtp`）
- [ ] Dovecot配置正确（`dovecot -n | grep -A 5 "service lmtp"`）
- [ ] Postfix配置包含virtual_mailbox_base（`postconf -n | grep virtual_mailbox_base`）
- [ ] 通知邮件发送成功后可以在前端立即看到
- [ ] 收件人用户自动创建功能正常工作
- [ ] 邮件目录自动创建功能正常工作

**注意事项**：
- 如果Dovecot LMTP socket不存在，需要运行 `mail_setup.sh configure <domain>` 重新配置
- 通知邮件发送成功后会自动存储到数据库，前端可以立即看到
- 如果收件人用户不存在，系统会自动创建，无需手动操作

---

## V3.0.7 (2025-11-17) - Postfix配置逻辑优化与脚本修复

### 🎊 版本亮点

**V3.0.7 是一个Postfix配置逻辑优化与脚本修复版本，主要聚焦于Postfix配置职责明确化、DNS配置后自动配置邮件系统、脚本语法错误修复和邮件警告邮箱测试模块完善。**

#### 🔧 Postfix配置逻辑优化
- **配置职责明确化**：`start.sh` 一键安装脚本不再直接配置Postfix，只负责安装包，配置由 `mail_setup.sh configure` 统一处理
- **DNS配置后自动配置邮件系统**：DNS配置完成后自动调用 `mail_setup.sh configure <domain>` 配置Postfix和Dovecot，包括域名设置
- **配置服务与DNS联动**：用户在前端配置邮件服务或DNS时，统一调用 `mail_setup.sh configure` 进行完整配置
- **Postfix配置冲突修复**：修复 `mail_db.sh` 中可能覆盖Postfix MySQL配置的问题，确保使用MySQL查询方式

#### 🐛 脚本语法错误修复
- **mail_setup.sh修复**：修复case语句中使用 `local` 关键字的语法错误（`local` 只能在函数内使用）
- **mail_db.sh修复**：修复 `update_postfix_domains()` 函数中多余的 `else`/`fi` 导致的语法错误
- **变量作用域修复**：修复case语句中的变量作用域问题，确保变量正确传递

#### 📧 邮件警告邮箱测试模块完善
- **notifications对象初始化**：在 `loadSystemSettings` 中确保 `notifications` 对象正确初始化
- **测试函数健壮性**：在 `testNotificationEmail` 函数中添加 `notifications` 对象存在性检查
- **数据同步优化**：确保通知设置数据正确加载和保存

#### 🔄 DNS配置流程优化
- **自动邮件系统配置**：DNS配置成功后，后端自动调用 `mail_setup.sh configure` 配置邮件系统
- **域名自动添加**：DNS配置完成后自动将域名添加到数据库并配置Postfix
- **配置一致性保证**：确保DNS配置和邮件系统配置保持一致

### 📋 详细更新内容

#### 🔧 Postfix配置逻辑优化

**`start.sh` 脚本更新**：

1. **移除直接Postfix配置**
   - 移除了安装Postfix后直接配置基本设置的代码
   - 只负责安装Postfix和Dovecot包，不进行配置
   - 配置由 `mail_setup.sh configure` 统一处理

2. **DNS配置后邮件系统配置**
   - DNS配置完成后调用 `mail_setup.sh configure <domain>` 配置邮件系统
   - 如果配置失败，只记录警告，提示用户在前端手动配置

**`backend/dispatcher/server.js` 后端API更新**：

1. **DNS配置后自动配置邮件系统**
   - 在 `POST /api/dns/configure` 端点中，DNS配置成功后自动调用 `mail_setup.sh configure <domain>`
   - 确保DNS配置完成后邮件系统也正确配置

**`backend/scripts/mail_setup.sh` 脚本更新**：

1. **configure函数完善**
   - 修复case语句中使用 `local` 关键字的语法错误
   - 修复变量作用域问题，使用普通变量而不是 `local`
   - 确保域名添加和Postfix配置正确执行

**`backend/scripts/mail_db.sh` 脚本更新**：

1. **update_postfix_domains函数修复**
   - 修复多余的 `else`/`fi` 导致的语法错误
   - 不再覆盖Postfix的MySQL配置，只创建文件作为备份
   - 确保Postfix使用MySQL查询方式获取域名列表

#### 🐛 脚本语法错误修复

**`backend/scripts/mail_setup.sh` 修复**：

1. **case语句中local关键字问题**
   - 问题：在case语句中使用 `local` 关键字导致语法错误
   - 修复：移除 `local` 关键字，使用普通变量
   - 影响：`configure` case中的变量定义

**`backend/scripts/mail_db.sh` 修复**：

1. **update_postfix_domains函数语法错误**
   - 问题：多余的 `else`/`fi` 导致语法错误
   - 修复：移除多余的 `else`/`fi`，保持代码结构正确
   - 影响：Postfix域名配置文件更新功能

#### 📧 邮件警告邮箱测试模块完善

**`frontend/src/components/Layout.vue` 组件更新**：

1. **loadSystemSettings函数增强**
   - 确保 `notifications` 对象正确初始化
   - 确保 `alertEmail` 字段存在

2. **testNotificationEmail函数增强**
   - 添加 `notifications` 对象存在性检查
   - 确保测试邮件功能健壮性

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/scripts/mail_setup.sh
# - backend/scripts/mail_db.sh
# - backend/dispatcher/server.js
# - frontend/src/components/Layout.vue
# - start.sh
```

#### 3. 重新配置邮件系统（如果需要）

```bash
# 如果Postfix配置不正确，运行以下命令重新配置
cd /bash
bash backend/scripts/mail_setup.sh configure skills.com
```

#### 4. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher

# 重启 Apache（如果需要）
systemctl restart httpd
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] Postfix配置使用MySQL查询方式（`postconf -n | grep virtual_mailbox_domains` 应显示 `mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf`）
- [ ] DNS配置完成后，邮件系统自动配置成功
- [ ] 邮件警告邮箱测试功能正常工作
- [ ] 通知设置可以正常保存和加载
- [ ] 脚本语法错误已修复，不再出现语法错误

**注意事项**：
- 如果Postfix配置不正确，需要运行 `mail_setup.sh configure <domain>` 重新配置
- DNS配置完成后会自动配置邮件系统，无需手动操作
- 邮件警告邮箱测试功能需要先设置警报邮箱地址

---

## V3.0.6 (2025-11-17) - 通知设置完善与邮件发送功能实现

### 🎊 版本亮点

**V3.0.6 是一个通知设置完善与邮件发送功能实现版本，主要聚焦于通知设置和性能设置功能增强、配置服务与通知设置联动、邮件发送功能实现和系统优化。**

#### 📧 通知设置与性能设置完善
- **通知设置功能增强**：添加安全警报、维护警报开关，完善通知设置UI
- **性能设置功能增强**：添加启用缓存开关，完善性能配置选项
- **测试邮件功能**：添加测试邮件发送按钮，可验证通知邮箱配置是否正确
- **设置保存优化**：通知设置和性能设置通过统一接口保存，确保数据一致性

#### 🔗 配置服务与通知设置联动
- **管理员邮箱自动同步**：配置服务的"系统基本信息"中设置管理员邮箱时，自动同步更新通知设置的警报邮箱
- **系统设置同步机制**：系统设置保存时自动同步管理员邮箱到通知设置，保持数据一致
- **设置预加载优化**：打开配置对话框前自动加载系统设置，确保显示最新值

#### 📮 邮件发送功能实现
- **Postfix SMTP集成**：后端使用Postfix SMTP发送通知邮件，不使用sendmail
- **邮件发送API**：创建 `/api/notifications/test-email` API端点，支持发送测试邮件和系统通知
- **系统通知函数**：实现 `sendNotificationEmail()` 函数，供系统内部调用发送各种类型的通知邮件
- **HTML邮件模板**：支持HTML格式的邮件内容，包含美观的邮件模板和邮件头信息

#### 🔧 DNS配置与系统优化
- **DNS配置执行顺序优化**：先创建zone文件，再启动服务，避免named-checkconf检查失败
- **系统设置保存修复**：修复系统设置保存失败问题，添加详细的错误日志和文件验证
- **Apache配置检查修复**：修复Apache配置警告检查中的整数表达式错误
- **Postfix配置优化**：在一键安装脚本中添加Postfix配置，确保允许本地发送邮件

### 📋 详细更新内容

#### 📧 通知设置与性能设置功能

**`Layout.vue` 前端组件更新**：

1. **通知设置UI增强**
   - 添加了安全警报开关（`securityAlerts`）
   - 添加了维护警报开关（`maintenanceAlerts`）
   - 添加了测试邮件按钮，可测试通知邮箱配置
   - 添加了测试结果提示显示（成功/失败）

2. **性能设置UI增强**
   - 添加了启用缓存开关（`enableCaching`）
   - 保留了最大连接数、连接超时、缓存大小、启用压缩等配置

3. **测试邮件发送功能**
   - 实现了 `testNotificationEmail()` 函数
   - 调用后端API发送测试邮件
   - 显示发送状态和结果

#### 🔗 配置服务与通知设置联动

**`Dashboard.vue` 组件更新**：

1. **管理员邮箱同步**
   - 在配置服务的"系统基本信息"配置成功后，自动同步更新通知设置的警报邮箱
   - 调用后端API保存通知设置同步

**`Layout.vue` 组件更新**：

1. **系统设置保存同步**
   - `saveSystemSettings()` 函数中，如果 `general.adminEmail` 存在，自动同步更新 `notifications.alertEmail`
   - 确保管理员邮箱和通知邮箱保持一致

#### 📮 邮件发送功能实现

**`server.js` 后端API更新**：

1. **测试邮件发送API**
   - 创建了 `POST /api/notifications/test-email` 端点
   - 验证邮箱格式和参数
   - 从系统设置中获取管理员邮箱作为发件人
   - 使用Postfix SMTP发送邮件
   - 支持HTML格式的邮件内容

2. **系统通知邮件函数**
   - 实现了 `sendNotificationEmail()` 函数
   - 检查通知设置是否启用
   - 根据通知类型（security、maintenance、system）检查是否启用
   - 支持系统内部调用发送各种类型的通知邮件

3. **邮件发送配置**
   - 使用Postfix SMTP（localhost:25）
   - 移除了SMTP认证（本地Postfix不需要）
   - 添加了超时处理（30秒）
   - 添加了详细的错误日志

#### 🔧 DNS配置优化

**`dns_setup.sh` 脚本更新**：

1. **执行顺序优化**
   - 调整了zone文件创建和服务启动的顺序
   - 先创建zone文件（正向和反向），再启动服务
   - 避免named-checkconf检查时找不到zone文件

2. **错误处理改进**
   - 添加了目录和权限检查
   - 添加了zone文件语法验证
   - 改进了错误日志输出

#### 🔧 系统设置保存修复

**`server.js` 后端API更新**：

1. **错误处理增强**
   - 添加了详细的日志输出
   - 添加了文件写入验证
   - 改进了错误消息

2. **applySystemSettings函数修复**
   - 移除了时区设置失败时抛出异常的代码
   - 时区设置失败只记录警告，不阻止整个保存过程

#### 🔧 Apache配置检查修复

**`start.sh` 脚本更新**：

1. **整数表达式错误修复**
   - 修复了Apache配置警告检查中的整数表达式错误
   - 添加了数字验证和默认值处理
   - 确保警告数量正确计算和显示

#### 🔧 Postfix配置优化

**`mail_setup.sh` 脚本更新**：

1. **允许本地发送邮件**
   - 添加了 `mynetworks` 配置
   - 添加了 `smtpd_recipient_restrictions` 配置
   - 添加了 `smtpd_sender_restrictions` 配置

**`start.sh` 脚本更新**：

1. **一键安装时自动配置**
   - 在安装Postfix后立即应用基本配置
   - 在备用配置中也添加了相同的配置
   - 确保一键安装时自动允许本地发送邮件

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/dispatcher/server.js
# - backend/scripts/dns_setup.sh
# - backend/scripts/mail_setup.sh
# - frontend/src/components/Layout.vue
# - frontend/src/modules/Dashboard.vue
# - start.sh
```

#### 3. 应用Postfix配置（如果需要）

```bash
# 如果Postfix配置未更新，运行以下命令
sudo postconf -e 'mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128'
sudo postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination'
sudo postconf -e 'smtpd_sender_restrictions = permit_mynetworks, permit_sasl_authenticated'
sudo systemctl reload postfix
```

#### 4. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher

# 重启 Apache（如果需要）
systemctl restart httpd
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] 通知设置中可以启用/禁用安全警报和维护警报
- [ ] 性能设置中可以启用/禁用缓存
- [ ] 测试邮件功能可以正常发送测试邮件
- [ ] 配置服务中设置管理员邮箱后，通知设置的警报邮箱自动同步
- [ ] 系统设置保存成功，不再出现"Failed to save system settings"错误
- [ ] DNS配置可以正常完成，不再出现zone文件检查失败
- [ ] Apache配置检查不再出现整数表达式错误
- [ ] Postfix配置允许本地发送邮件

**注意事项**：
- 通知设置和性能设置的更改需要点击"保存设置"按钮才会生效
- 测试邮件功能需要先设置警报邮箱地址
- 配置服务的管理员邮箱会自动同步到通知设置，无需手动设置
- Postfix配置已在一键安装脚本中自动应用，新安装的系统无需手动配置

---

## V3.0.5 (2025-11-14) - DNS域名管理与Postfix配置优化

### 🎊 版本亮点

**V3.0.5 是一个DNS域名管理与Postfix配置优化版本，主要聚焦于DNS域名管理完善、Postfix域名配置自动化、配置服务优化和邮件域名管理增强。**

#### 🔧 DNS域名管理完善
- **DNS配置的域名为默认域名**：DNS配置的域名自动设为默认域名，并在前端显示"默认域名"标签
- **DNS域名不可删除保护**：DNS配置的域名不能通过前端删除，防止误操作，如需更换域名需重新配置DNS
- **DNS重新配置自动清理**：重新配置DNS时，自动删除之前的DNS域名，避免域名列表冗余
- **域名列表智能标记**：域名列表自动识别DNS配置的域名，标记为默认且不可删除

#### 📧 Postfix域名配置自动化
- **Postfix配置文件自动生成**：添加/删除域名时，自动生成和更新 `/etc/postfix/virtual_mailbox_domains` 文件
- **Postfix配置自动同步**：域名变更时自动更新Postfix配置并重新加载服务，确保配置实时生效
- **权限检查与错误处理**：添加root权限检查，确保配置文件正确创建，即使Postfix服务未运行也不影响域名添加
- **数据库初始化时创建配置**：系统初始化时自动创建Postfix域名配置文件，确保系统可用性

#### 🎨 配置服务优化
- **管理员邮箱自动读取**：配置服务的"系统基本信息"中，管理员邮箱字段自动从系统设置中读取最新值
- **系统设置预加载**：打开配置对话框前自动加载系统设置，确保显示最新的配置值
- **设置同步优化**：系统设置加载时正确合并所有字段（general、mail、dns），保证数据完整性

#### 🗄️ 邮件域名管理增强
- **域名删除保护机制**：后端API检查删除的域名是否为DNS配置的域名，如果是则拒绝删除并提示用户
- **域名列表实时刷新**：添加/删除域名后自动刷新列表，确保前端显示与数据库一致
- **域名状态智能识别**：前端自动识别DNS配置的域名，禁用删除按钮并显示相应提示

### 📋 详细更新内容

#### 🔧 DNS域名管理功能

**`server.js` 后端API更新**：

1. **DNS配置域名自动管理**
   - `POST /api/dns/configure` 端点增强
   - DNS配置成功后，先检查是否有之前的DNS域名需要删除
   - 如果存在旧DNS域名且与新域名不同，自动删除旧域名
   - 然后添加新域名到数据库
   - 确保DNS域名列表始终保持最新

2. **域名列表标记DNS域名**
   - `GET /api/system-settings` 端点更新
   - 获取DNS配置的域名（`dns.bind.domain` 或 `dns.public.domain`）
   - 将匹配的域名标记为 `isDefault: true` 和 `isDnsDomain: true`
   - 如果没有DNS域名，则第一个域名为默认域名

3. **域名删除保护**
   - `DELETE /api/system/domains/:id` 端点增强
   - 删除前检查要删除的域名是否为DNS配置的域名
   - 如果是DNS配置的域名，返回错误："DNS配置的域名不能删除，如需更换域名请重新配置DNS"
   - 确保DNS配置的域名不会被误删

#### 📧 Postfix域名配置自动化

**`mail_db.sh` 脚本更新**：

1. **`update_postfix_domains()` 函数增强**
   - 添加root权限检查，确保可以创建 `/etc/postfix` 目录和文件
   - 确保 `/etc/postfix` 目录存在
   - 使用临时文件创建域名列表，然后移动到目标位置（避免并发写入问题）
   - 设置正确的文件权限（644）
   - 添加 `postconf` 命令检查
   - 即使没有域名也创建空文件，避免Postfix配置错误

2. **`add_domain()` 函数自动更新Postfix配置**
   - 添加域名成功后，自动调用 `update_postfix_domains()` 更新Postfix配置文件
   - 如果Postfix服务正在运行，自动重新加载配置
   - 添加了错误处理，即使Postfix重新加载失败也不影响域名添加

3. **`init_mail_db()` 函数初始化时创建配置文件**
   - 在数据库初始化完成后，自动调用 `update_postfix_domains()` 创建Postfix配置文件
   - 确保系统初始化时就有正确的配置文件

4. **日志函数添加**
   - 添加了 `log_info()`, `log_warning()`, `log_error()`, `log_success()` 函数
   - 统一日志格式，便于调试和排查问题

#### 🎨 前端功能更新

**`Layout.vue` 组件更新**：

1. **域名列表显示优化**
   - DNS配置的域名显示"默认域名"标签
   - 删除按钮对DNS域名禁用：`:disabled="domain.isDefault || domain.isDnsDomain"`
   - 提示信息："DNS配置的域名不能删除"

2. **域名删除错误处理**
   - 删除失败时显示后端返回的错误信息
   - 如果是因为DNS域名保护，显示相应提示

3. **域名列表标记DNS域名**
   - `loadSystemSettings()` 函数中，自动标记DNS配置的域名为默认域名
   - 确保DNS域名正确显示为默认域名

**`Dashboard.vue` 组件更新**：

1. **配置服务对话框优化**
   - `openConfigDialog()` 函数改为异步函数
   - 打开对话框前先调用 `await loadSystemSettings()` 确保系统设置已加载
   - 从 `systemSettings.value.general?.adminEmail` 读取管理员邮箱
   - 添加调试日志，方便排查问题

2. **系统设置加载优化**
   - `loadSystemSettings()` 函数增强
   - 确保正确合并 `general`、`mail` 和 `dns` 字段
   - 添加日志输出，显示加载的管理员邮箱值

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
cp /etc/postfix/virtual_mailbox_domains /tmp/virtual_mailbox_domains.backup 2>/dev/null || true
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/scripts/mail_db.sh
# - backend/dispatcher/server.js
# - frontend/src/components/Layout.vue
# - frontend/src/modules/Dashboard.vue
```

#### 3. 初始化Postfix配置文件（如果需要）

```bash
# 如果 /etc/postfix/virtual_mailbox_domains 不存在，运行以下命令初始化
bash /bash/backend/scripts/mail_db.sh list_domains
# 这会触发 update_postfix_domains() 函数创建配置文件
```

#### 4. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher

# 重启 Apache（如果需要）
systemctl restart httpd

# 重新加载Postfix配置（如果Postfix正在运行）
systemctl reload postfix
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] DNS配置的域名显示为默认域名
- [ ] DNS配置的域名不能删除（删除按钮禁用）
- [ ] 重新配置DNS时，旧DNS域名自动删除
- [ ] 添加/删除域名后，Postfix配置文件自动更新
- [ ] `/etc/postfix/virtual_mailbox_domains` 文件存在且包含所有域名
- [ ] 配置服务的"系统基本信息"中，管理员邮箱显示最新值
- [ ] 打开配置对话框时，管理员邮箱从系统设置正确读取
- [ ] 域名列表正确显示DNS配置的域名为默认域名

**注意事项**：
- DNS配置的域名会自动设为默认域名且不可删除
- 如需更换DNS域名，请重新配置DNS，系统会自动删除旧域名
- Postfix配置文件会在添加/删除域名时自动更新
- 配置服务的管理员邮箱会自动从系统设置读取，不会每次刷新都回到默认值

---

## V3.0.4 (2025-11-14) - DNS配置与系统设置优化

### 🎊 版本亮点

**V3.0.4 是一个DNS配置与系统设置优化版本，主要聚焦于DNS配置系统完善、邮件与通知设置联动、系统设置保存优化和用户体验提升。**

#### 🔧 DNS配置系统完善
- **DNS配置执行顺序优化**：先启动named服务，再创建zone文件并reload，避免服务未启动时的reload失败
- **DNS配置错误处理改进**：即使NetworkManager配置失败或DNS解析测试未通过，只要核心配置成功就返回成功状态
- **前端错误检测优化**：只检查OPERATION_END中的退出码，忽略警告信息中的"DNS配置失败"字符串，避免误判
- **DNS配置成功后自动添加域名**：DNS配置成功后，自动将DNS域名添加到邮件域名列表，无需手动添加

#### 📧 邮件与通知设置联动
- **邮件设置同步报警邮箱**：修改邮件设置时，自动同步更新系统设置的通知报警邮箱（`notifications.alertEmail`）
- **DNS域名自动添加到邮件域名**：DNS配置成功后，自动检查并添加域名到邮件域名管理列表

#### 🗄️ 系统设置保存优化
- **深度合并设置**：系统设置保存时使用深度合并，避免部分更新时覆盖其他设置
- **adminEmail默认值优化**：DNS配置和系统设置的adminEmail默认值从 `admin@域名` 改为 `xm@域名`
- **域名添加功能改进**：添加域名后增加验证逻辑，确保数据正确刷新和显示

### 📋 详细更新内容

#### 🔧 DNS配置脚本优化

**`dns_setup.sh` 脚本更新**：

1. **执行顺序优化**
   - 调整了 `configure-bind` 命令的执行顺序
   - 先启动named服务（如果未启动），再创建zone文件
   - 创建zone文件时检查服务是否运行，避免在服务未启动时尝试reload

2. **错误处理改进**
   - `create_forward_zone()` 和 `create_reverse_zone()` 函数中添加服务状态检查
   - 如果服务未运行，跳过reload（服务启动后会自动加载）
   - reload失败时尝试restart，而不是直接失败

3. **验证逻辑优化**
   - `force_update_system_dns()` 函数中，即使DNS解析测试失败也不返回失败状态
   - 因为配置已应用（服务已启动、配置文件已创建、系统DNS已更新）
   - 测试失败可能是网络延迟或DNS缓存导致的临时问题

#### 🎨 前端功能更新

**`Dashboard.vue` 组件更新**：

1. **错误检测逻辑优化**
   - 只检查 `OPERATION_END` 中的退出码
   - 忽略警告信息中的"DNS配置失败"字符串
   - 避免将警告误判为失败

**`Layout.vue` 组件更新**：

1. **`saveMailSettings()` 函数更新**
   - 保存邮件设置时，如果 `general.adminEmail` 存在，自动同步更新 `notifications.alertEmail`
   - 确保邮件设置和通知设置的报警邮箱保持一致

2. **`saveDnsConfig()` 函数更新**
   - DNS配置成功后，自动检查DNS域名是否已在邮件域名列表中
   - 如果不存在，自动调用添加域名API将DNS域名添加到邮件域名列表
   - 添加成功后重新加载系统设置以更新域名列表显示

3. **`addDomain()` 函数改进**
   - 修复了在清空 `newDomain` 后仍使用它的bug
   - 添加了域名添加后的验证逻辑
   - 如果域名未正确添加，会自动重新加载设置
   - 添加了更详细的日志输出，便于调试

#### 🔧 后端API更新

**`server.js` 更新**：

1. **深度合并函数**
   - 添加了 `deepMerge()` 函数用于深度合并对象
   - 添加了 `isObject()` 辅助函数

2. **系统设置保存逻辑优化**
   - 保存前先读取现有的 `system-settings.json`
   - 将新设置与现有设置进行深度合并
   - 保存合并后的完整设置，避免覆盖其他设置

3. **adminEmail默认值更新**
   - `dns_setup.sh` 中adminEmail默认值从 `admin@$domain` 改为 `xm@$domain`
   - 前端DNS配置时默认使用 `xm@域名` 格式

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/scripts/dns_setup.sh
# - backend/dispatcher/server.js
# - frontend/src/components/Layout.vue
# - frontend/src/modules/Dashboard.vue
```

#### 3. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher

# 重启 Apache（如果需要）
systemctl restart httpd
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] DNS配置时，即使有警告也能正确返回成功状态
- [ ] DNS配置成功后，域名自动添加到邮件域名列表
- [ ] 修改邮件设置时，报警邮箱自动同步更新
- [ ] 系统设置部分更新时，不会覆盖其他设置
- [ ] DNS配置时默认使用 `xm@域名` 格式
- [ ] 添加域名后，列表正确刷新显示新域名

**注意事项**：
- DNS配置时即使有警告（如NetworkManager配置失败），只要核心配置成功就会返回成功
- DNS配置成功后会自动添加域名到邮件域名列表，无需手动添加
- 邮件设置和通知设置的报警邮箱会自动同步，保持一致
- 系统设置保存时使用深度合并，不会丢失其他配置

---

## V3.0.3 (2025-11-13) - 域名管理与系统优化

### 🎊 版本亮点

**V3.0.3 是一个域名管理与系统优化版本，主要聚焦于邮件域名管理完善、系统优化与用户体验提升。**

#### 📧 邮件域名管理完善
- **localhost 域名默认支持**：系统初始化时自动将 `localhost` 添加到邮件域名列表
  - `db_setup.sh` 初始化时自动插入 localhost 域名
  - `mail_db.sh` 初始化时确保 localhost 域名存在
  - 解决使用 `xm@localhost` 发送邮件时的域名验证问题
- **域名管理数据库对接修复**：
  - 前端 `loadSystemSettings` 函数正确加载 `mail.domains` 字段
  - 添加/删除域名后自动重新从数据库加载最新列表
  - 确保前端显示的域名列表与数据库保持一致
- **域名列表自动刷新**：
  - 添加域名成功后自动刷新列表
  - 删除域名成功后自动刷新列表
  - 避免手动刷新页面，提升用户体验

#### 🔧 系统优化与修复
- **日志级别修复**：修复了"如果页面显示异常"提示的日志级别（从 ERROR 改为 WARN）
- **代码结构优化**：修复了 `start.sh` 中重复的 `case` 默认分支，优化了命令处理逻辑
- **域名查询优化**：`mail_db.sh list_domains` 函数移除日志输出，确保 JSON 格式纯净

### 📋 详细更新内容

#### 🗄️ 数据库初始化更新

**`db_setup.sh` 脚本更新**：

1. **`write_schema()` 函数更新**
   - 在创建 `virtual_domains` 表后，自动插入 `localhost` 域名
   - 使用 `INSERT IGNORE` 确保不会重复插入
   - 确保新安装的系统默认支持 localhost 域名

**`mail_db.sh` 脚本更新**：

1. **`init_mail_db()` 函数更新**
   - 在初始化完成后，确保 `localhost` 域名存在于 `virtual_domains` 表中
   - 使用 `INSERT IGNORE` 避免重复插入
   - 添加日志记录，便于追踪

2. **`list_domains()` 函数优化**
   - 移除了 `log` 函数调用，避免日志输出污染 JSON
   - 添加注释说明此函数只输出 JSON 格式
   - 确保后端 API 能正确解析域名列表

#### 🎨 前端功能更新

**`Layout.vue` 组件更新**：

1. **`loadSystemSettings()` 函数更新**
   - 确保 `mail.domains` 字段从数据库正确加载
   - 添加日志输出，便于调试域名加载问题
   - 使用 `data.settings.mail?.domains || []` 确保字段存在

2. **`addDomain()` 函数更新**
   - 添加域名成功后，调用 `loadSystemSettings()` 重新从数据库加载
   - 移除手动添加到本地列表的逻辑
   - 确保显示的是数据库中的最新数据

3. **`confirmDeleteDomain()` 函数更新**
   - 删除域名成功后，调用 `loadSystemSettings()` 重新从数据库加载
   - 移除手动从本地列表删除的逻辑
   - 确保显示的是数据库中的最新数据

#### 🔧 后端脚本更新

**`start.sh` 脚本更新**：

1. **日志级别修复**
   - 将"如果页面显示异常，请运行: ./start.sh check 进行诊断"的日志级别从 ERROR 改为 WARN
   - 更准确地反映消息的严重程度

2. **代码结构优化**
   - 修复了重复的 `case *)` 默认分支
   - 修复了 `logs` 命令分支位置错误的问题
   - 优化了命令处理逻辑，确保所有命令都能正确执行

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份数据库
mysqldump -u root maildb > /tmp/maildb_backup_$(date +%Y%m%d).sql

# 备份配置文件
cp /bash/config/system-settings.json /tmp/system-settings.json.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - backend/scripts/db_setup.sh
# - backend/scripts/mail_db.sh
# - frontend/src/components/Layout.vue
# - start.sh
```

#### 3. 确保 localhost 域名存在

```bash
# 方法1：重新运行数据库初始化（推荐）
bash backend/scripts/mail_db.sh init

# 方法2：手动添加 localhost 域名
mysql -u mailuser -pmailpass maildb -e "INSERT IGNORE INTO virtual_domains (name) VALUES ('localhost');"
```

#### 4. 重启服务

```bash
# 重启调度层服务
systemctl restart mail-ops-dispatcher

# 重启 Apache（如果需要）
systemctl restart httpd
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] localhost 域名存在于 `virtual_domains` 表中
- [ ] 使用 `xm@localhost` 发送邮件不再出现域名验证错误
- [ ] 系统设置页面能正确显示域名列表
- [ ] 添加域名后，列表自动刷新显示新域名
- [ ] 删除域名后，列表自动刷新，已删除的域名不再显示
- [ ] 日志级别显示正确（"如果页面显示异常"显示为 WARN 而非 ERROR）

**注意事项**：
- 如果系统已经安装，需要手动添加 localhost 域名或重新运行数据库初始化
- 域名管理操作后会自动刷新列表，无需手动刷新页面
- 所有域名数据都存储在数据库中，确保数据一致性

---

## V3.0.2 (2025-11-13) - 日志系统优化

### 🎊 版本亮点

**V3.0.2 是一个日志系统优化版本，主要聚焦于日志级别系统完善和日志输出统一化。**

#### 📊 日志级别系统完善
- **灵活的日志级别控制**：新增 `LOG_LEVEL` 环境变量支持（DEBUG、INFO、WARN、ERROR）
  - 默认级别：INFO（只显示 INFO、WARN、ERROR 级别日志）
  - DEBUG 级别：显示所有日志（包括调试信息）
  - WARN 级别：只显示警告和错误日志
  - ERROR 级别：只显示错误日志
- **日志级别函数**：新增专门的日志函数
  - `log_debug()` - DEBUG 级别（橘色显示）
  - `log_info()` - INFO 级别（蓝色显示）
  - `log_warn()` - WARN 级别（黄色显示）
  - `log_error()` - ERROR 级别（红色显示）
  - `log_success()` - SUCCESS 级别（绿色显示）
- **智能日志级别判断**：`log()` 函数根据消息内容自动判断日志级别
  - 包含"错误/失败/异常" → ERROR
  - 包含"警告/警示" → WARN
  - 包含"调试/详细" → DEBUG
  - 其他 → INFO（默认）

#### 🎨 日志输出统一化
- **子脚本日志统一处理**：`update_repos.sh` 的日志输出由 `start.sh` 统一处理
  - `update_repos.sh` 只输出纯文本消息（带级别标记：INFO:, SUCCESS:, WARNING:, ERROR:）
  - `start.sh` 捕获输出并统一添加时间戳、颜色和日志级别前缀
  - 确保所有日志格式一致，符合 `LOG_LEVEL` 过滤规则
- **日志颜色优化**：
  - `[DEBUG]` - 橘色
  - `[INFO]` - 蓝色
  - `[WARN]` - 黄色
  - `[ERROR]` - 红色
  - `[SUCCESS]` - 绿色
  - 时间戳统一为绿色

### 📋 详细更新内容

#### 🔧 start.sh 脚本更新

**日志级别系统**：

1. **`LOG_LEVEL` 变量**
   - 从 `LOG_LEVEL="DEBUG"` 改为 `LOG_LEVEL="${LOG_LEVEL:-INFO}"`
   - 默认级别为 INFO，可通过环境变量设置
   - 支持值：DEBUG、INFO、WARN、ERROR

2. **`should_log()` 函数（新增）**
   - 根据当前 `LOG_LEVEL` 判断是否输出日志
   - DEBUG 级别：输出所有日志
   - INFO 级别：输出 INFO、WARN、ERROR
   - WARN 级别：输出 WARN、ERROR
   - ERROR 级别：只输出 ERROR

3. **日志函数扩展**
   - `log_debug()` - DEBUG 级别日志（橘色）
   - `log_info()` - INFO 级别日志（蓝色）
   - `log_warn()` - WARN 级别日志（黄色）
   - `log_error()` - ERROR 级别日志（红色）
   - `log_success()` - SUCCESS 级别日志（绿色）

4. **`log()` 函数更新**
   - 根据消息内容自动判断日志级别
   - 包含"错误/失败/异常/ERROR" → 调用 `log_error()`
   - 包含"警告/警示/WARNING" → 调用 `log_warn()`
   - 包含"调试/DEBUG/详细" → 调用 `log_debug()`
   - 其他 → 调用 `log_info()`（默认）

5. **`format_log_message()` 函数更新**
   - 为所有日志级别添加颜色支持
   - `[DEBUG]` - 橘色（ORANGE）
   - `[INFO]` - 蓝色（BLUE）
   - `[WARN]` - 黄色（YELLOW）
   - `[ERROR]` - 红色（RED）
   - `[SUCCESS]` - 绿色（GREEN）

6. **`update_repos.sh` 调用更新**
   - 捕获脚本输出并解析日志级别标记
   - 根据标记调用相应的日志函数
   - 统一添加时间戳和颜色

#### 🔧 update_repos.sh 脚本更新

**日志函数简化**：

1. **移除颜色定义**
   - 删除所有颜色变量（RED、GREEN、YELLOW等）
   - 删除时间戳处理

2. **日志函数简化**
   - `log_info()` - 只输出 `INFO: 消息内容`
   - `log_success()` - 只输出 `SUCCESS: 消息内容`
   - `log_warning()` - 只输出 `WARNING: 消息内容`
   - `log_error()` - 只输出 `ERROR: 消息内容`
   - 所有日志输出到 stdout（包括错误）

3. **日志处理**
   - 由 `start.sh` 统一处理时间戳、颜色和日志级别前缀
   - 确保日志格式一致

### 🚀 升级步骤

#### 1. 备份当前配置

```bash
# 备份 start.sh
cp start.sh start.sh.backup
```

#### 2. 更新文件

```bash
# 拉取最新代码
git pull origin main

# 或手动更新以下文件：
# - start.sh
# - backend/scripts/update_repos.sh
```

#### 3. 验证日志级别

```bash
# 默认模式（INFO级别）
./start.sh start

# 调试模式（显示所有日志）
LOG_LEVEL=DEBUG ./start.sh start

# 仅错误模式
LOG_LEVEL=ERROR ./start.sh start
```

### ✅ 验证清单

升级完成后，请验证以下功能：

- [ ] 默认日志级别为 INFO，不显示 DEBUG 日志
- [ ] 设置 `LOG_LEVEL=DEBUG` 后显示所有日志
- [ ] `update_repos.sh` 的日志输出格式与 `start.sh` 一致
- [ ] 日志颜色正确显示（DEBUG橘色、INFO蓝色、WARN黄色、ERROR红色、SUCCESS绿色）
- [ ] 日志级别过滤正常工作

**注意事项**：
- 默认日志级别为 INFO，如需查看 DEBUG 日志，请设置 `LOG_LEVEL=DEBUG`
- `update_repos.sh` 的日志现在由 `start.sh` 统一处理，格式更加一致
- 所有日志都会写入 `/var/log/mail-ops/install.log`

---

## V3.0.1 (2025-11-13) - 数据库架构扩展与系统优化

### 🎊 版本亮点

**V3.0.1 是一个功能优化版本，主要聚焦于垃圾邮件过滤系统数据库化和DNS配置系统修复。**

#### 🗄️ 数据库架构扩展
- **9张表架构**：新增 `spam_filter_config` 表（垃圾邮件过滤配置表），从8张表扩展到9张表
- **配置类型支持**：`keyword_cn`（中文关键词）、`keyword_en`（英文关键词）、`domain`（域名黑名单）、`email`（邮箱黑名单）、`rule`（过滤规则）
- **JSON格式存储**：配置值以JSON格式存储，支持灵活配置管理
- **独立表结构**：无外键关联，便于配置管理和维护

#### 🛡️ 垃圾邮件过滤系统优化
- **配置数据库化**：
  - 删除 `spam_filter.conf` 配置文件
  - 配置存储在 `spam_filter_config` 表中
  - 支持通过前端界面和API进行配置管理
  - 自动初始化默认配置（中文/英文关键词、域名黑名单、邮箱黑名单、过滤规则）
- **脚本优化**：
  - `spam_filter.sh` 从数据库读取配置，支持动态更新
  - `mail_db.sh` 新增 `get-spam-config` 和 `update-spam-config` 命令
  - 支持配置迁移：如果存在旧的 `spam_filter.conf` 文件，自动迁移到数据库
- **API优化**：
  - `/api/spam-filter/config` (GET/POST) 从数据库读取和保存配置
  - 使用临时文件传递JSON数据，避免shell转义问题
  - 支持邮箱黑名单配置

#### 🔧 DNS配置系统修复
- **adminEmail自动同步**：
  - 前端自动使用 `general.adminEmail`（从数据库获取的xm用户邮箱）
  - 如果DNS配置中的adminEmail为空或为默认值（`admin@example.com`、`admin@skills.com`），自动使用系统管理员邮箱
  - 加载系统设置时自动同步adminEmail到DNS配置
- **NetworkManager配置容错**：
  - NetworkManager DNS配置失败不影响整体DNS配置成功
  - 确保 `resolv.conf` 配置成功（关键配置）
  - 即使NetworkManager配置失败，DNS服务仍可正常使用
- **配置验证增强**：
  - `configure_dns_pointing` 函数添加验证逻辑
  - 确保 `resolv.conf` 文件存在且包含必要的nameserver配置
  - 添加正确的返回码处理

### 📋 详细更新内容

#### 🗄️ 数据库表结构扩展

**新增表结构**：
- **`spam_filter_config`** - 垃圾邮件过滤配置表
  - 字段：`id`, `config_type`, `config_key`, `config_value` (TEXT, JSON格式), `is_active`, `created_at`, `updated_at`
  - 索引：`idx_spam_filter_config_type`, `idx_spam_filter_config_active`
  - 唯一键：`uk_config_type_key` (config_type, config_key)
  - 配置类型：`keyword_cn`, `keyword_en`, `domain`, `email`, `rule`
  - 默认配置键：`default`

**默认配置初始化**：
- 中文关键词：29个默认关键词（免费、赚钱、投资、理财等）
- 英文关键词：35个默认关键词（viagra、casino、lottery等）
- 域名黑名单：18个默认域名（spam.com、junk.com等）
- 邮箱黑名单：9个默认邮箱（noreply@spam.com等）
- 过滤规则：`min_body_lines=3`, `max_caps_ratio=0.7`, `max_exclamation=5`, `max_special_chars=10`

#### 🔧 后端脚本更新

**`mail_db.sh` 脚本扩展**：

1. **`init_mail_db` 函数**
   - 创建 `spam_filter_config` 表（第9张表）
   - 调用 `init_spam_filter_config()` 初始化默认配置
   - 调用 `migrate_spam_filter_config()` 迁移旧配置文件

2. **`init_spam_filter_config` 函数（新增）**
   - 插入默认中文关键词配置
   - 插入默认英文关键词配置
   - 插入默认域名黑名单配置
   - 插入默认邮箱黑名单配置
   - 插入默认过滤规则配置

3. **`get_spam_filter_config` 函数（新增）**
   - 从数据库读取所有垃圾邮件过滤配置
   - 返回JSON格式的配置对象
   - 包含：`keywords` (chinese/english), `domainBlacklist`, `emailBlacklist`, `rules`

4. **`update_spam_filter_config` 函数（新增）**
   - 更新指定类型的配置
   - 支持文件路径或JSON字符串输入
   - 验证JSON格式
   - 使用 `ON DUPLICATE KEY UPDATE` 实现更新或插入

5. **`migrate_spam_filter_config` 函数（新增）**
   - 检测是否存在旧的 `spam_filter.conf` 文件
   - 如果存在且数据库中没有配置，提示迁移
   - 删除旧配置文件

**`spam_filter.sh` 脚本更新**：

1. **`load_config_from_db` 函数（新增）**
   - 从数据库加载配置
   - 使用Python解析JSON并转换为bash数组
   - 如果数据库不可用，使用默认配置

2. **`add_keyword` 函数更新**
   - 保存关键词到数据库而非配置文件
   - 使用Python更新配置JSON
   - 调用 `mail_db.sh update-spam-config` 更新数据库

3. **`add_domain` 函数更新**
   - 保存域名到数据库而非配置文件
   - 使用Python更新配置JSON
   - 调用 `mail_db.sh update-spam-config` 更新数据库

4. **`add_email` 函数更新**
   - 保存邮箱到数据库而非配置文件
   - 使用Python更新配置JSON
   - 调用 `mail_db.sh update-spam-config` 更新数据库

5. **移除 `create_default_config` 函数**
   - 不再创建配置文件
   - 配置从数据库加载

**`dns_setup.sh` 脚本更新**：

1. **`force_update_system_dns` 函数更新**
   - NetworkManager配置失败时记录警告但继续执行
   - 确保 `resolv.conf` 配置成功（关键配置）
   - 即使NetworkManager配置失败，函数仍返回成功

2. **`configure_dns_pointing` 函数更新**
   - 添加验证逻辑：确保 `resolv.conf` 文件存在
   - 添加验证逻辑：确保包含必要的nameserver配置
   - 添加正确的返回码（成功返回0，失败返回1）

3. **bind配置流程更新**
   - 即使 `force_update_system_dns` 返回失败，也只记录警告
   - 不影响整体配置成功
   - 脚本最后确保以成功状态退出

#### 🎨 前端功能更新

**`Layout.vue` 组件更新**：

1. **`saveDnsConfig` 函数更新**
   - 自动使用 `general.adminEmail` 如果DNS配置中的adminEmail为空或为默认值
   - 同步更新 `dns.bind.adminEmail` 字段

2. **`loadSystemSettings` 函数更新**
   - 加载系统设置时自动同步 `general.adminEmail` 到 `dns.bind.adminEmail`
   - 如果 `dns.bind.adminEmail` 为空或为默认值，使用 `general.adminEmail`

3. **`saveSpamFilterConfig` 函数更新**
   - 确保包含 `emailBlacklist` 字段（即使为空数组）

#### 🔌 后端API更新

**`server.js` 更新**：

1. **`/api/spam-filter/config` (GET) 更新**
   - 从数据库读取配置（调用 `mail_db.sh get-spam-config`）
   - 不再从文件读取配置
   - 返回格式保持不变，确保前端兼容

2. **`/api/spam-filter/config` (POST) 更新**
   - 保存配置到数据库（调用 `mail_db.sh update-spam-config`）
   - 使用临时文件传递JSON数据，避免shell转义问题
   - 分别更新：中文关键词、英文关键词、域名黑名单、邮箱黑名单、过滤规则

### 🚀 升级步骤（从 V3.0.0 或更早版本）

```bash
# 1. 更新代码
cd /bash && git pull

# 2. 初始化/升级数据库（自动创建spam_filter_config表并初始化默认配置）
bash backend/scripts/mail_db.sh init

# 3. 重启调度层服务
systemctl restart mail-ops-dispatcher

# 4. 验证数据库结构
mysql -u mailuser -pmailpass maildb -e "SHOW TABLES;"
# 应该看到9张表：emails, email_attachments, email_recipients, email_folders, 
# email_labels, email_label_relations, email_metadata, mail_users, spam_filter_config

# 5. 验证垃圾邮件过滤配置
curl -u "xm:xm666@" http://localhost/api/spam-filter/config

# 6. 验证DNS配置（检查adminEmail是否正确）
curl -u "xm:xm666@" http://localhost/api/dns/status
```

**升级后验证清单**：
- [ ] 数据库表结构正确（9张表）
- [ ] `spam_filter_config` 表已创建并初始化默认配置
- [ ] 旧的 `spam_filter.conf` 文件已删除（如果存在）
- [ ] 垃圾邮件过滤配置API正常响应
- [ ] DNS配置中的adminEmail自动使用系统管理员邮箱
- [ ] NetworkManager配置失败不影响DNS服务

**注意事项**：
- 如果存在旧的 `spam_filter.conf` 文件，系统会自动迁移配置到数据库
- DNS配置时，adminEmail会自动使用系统管理员邮箱（从数据库获取）
- 即使NetworkManager配置失败，DNS服务仍可正常使用（通过resolv.conf配置）

---

## V3.0.0 (2025-11-13) - 大版本更新

### 🎊 版本亮点

**V3.0.0 是一个重大版本更新，带来了全面的邮件管理功能升级和数据库架构重构。**

#### 📊 数据库架构全面升级
- **8张表扩展架构**：从原有的5张表扩展到8张表，支持更丰富的邮件管理功能
- **向后兼容性**：自动迁移旧数据到新表结构，确保平滑升级
- **数据完整性**：外键约束、级联删除、索引优化

#### ✉️ 邮件功能全面增强
- **文件夹管理**：支持收件箱、已发送、草稿箱、垃圾邮件、已删除5个系统文件夹
- **标签系统**：支持多标签管理，标签带颜色显示
- **优先级和重要性**：支持高/普通/低优先级设置，支持重要性标记
- **多收件人支持**：完整的 to/cc/bcc 收件人管理
- **软删除机制**：删除邮件移动到已删除文件夹

#### 📝 写邮件功能增强
- **草稿保存**：支持手动保存草稿和自动保存（每30秒）
- **优先级选择**：发送邮件时可选择优先级
- **重要性标记**：发送邮件时可标记为重要

#### 🎯 邮件操作功能
- **移动到文件夹**：支持将邮件移动到任意文件夹
- **标签管理**：支持为邮件添加/删除标签
- **软删除**：删除邮件移动到已删除文件夹

### 📋 详细更新内容

#### 🗄️ 数据库表结构扩展

**新增表结构**：
1. **`email_attachments`** - 附件表
   - 独立存储邮件附件，支持多附件
   - 字段：`id`, `email_id`, `filename`, `content_type`, `size_bytes`, `content_base64`, `is_inline`
   - 外键关联：`email_id` → `emails.id` (ON DELETE CASCADE)

2. **`email_recipients`** - 收件人表
   - 存储邮件的所有收件人（to/cc/bcc）
   - 字段：`id`, `email_id`, `recipient_type` (to/cc/bcc), `email_address`
   - 外键关联：`email_id` → `emails.id` (ON DELETE CASCADE)

3. **`email_folders`** - 文件夹表
   - 系统文件夹和用户自定义文件夹
   - 字段：`id`, `name`, `display_name`, `folder_type` (system/user), `sort_order`, `is_active`
   - 默认文件夹：inbox(1), sent(2), drafts(3), trash(4), spam(5)

4. **`email_labels`** - 标签表
   - 系统标签和用户自定义标签
   - 字段：`id`, `name`, `display_name`, `color`, `is_system`
   - 默认标签：important, starred, work, personal

5. **`email_label_relations`** - 标签关联表
   - 邮件和标签的多对多关系
   - 字段：`id`, `email_id`, `label_id`
   - 外键关联：`email_id` → `emails.id`, `label_id` → `email_labels.id` (ON DELETE CASCADE)

6. **`email_metadata`** - 元数据表
   - 扩展邮件元数据信息
   - 字段：`id`, `email_id`, `reply_to`, `in_reply_to`, `thread_id`, `spam_score`, `virus_status`, `encryption_status`, `signature_status`
   - 外键关联：`email_id` → `emails.id` (ON DELETE CASCADE)

**`emails` 表字段扩展**：
- `folder_id` (INT) - 文件夹ID，替代原有的 `folder` (VARCHAR)
- `priority` (INT) - 优先级：0=普通，1=高，2=低
- `importance` (INT) - 重要性：0=普通，1=重要
- `is_deleted` (TINYINT) - 软删除标记：0=未删除，1=已删除

**数据迁移逻辑**：
- 自动检测旧表结构，迁移 `attachments` JSON 数据到 `email_attachments` 表
- 自动迁移 `folder` (VARCHAR) 数据到 `folder_id` (INT)
- 向后兼容：如果新表为空，从旧字段读取数据

#### 🔌 后端API扩展

**新增API端点**：

1. **`GET /api/mail/folders`**
   - 功能：获取所有文件夹列表
   - 返回：文件夹数组（id, name, display_name, folder_type, sort_order）

2. **`GET /api/mail/folders/:id/stats`**
   - 功能：获取指定文件夹的统计信息
   - 返回：统计对象（total, unread, read, size）

3. **`GET /api/mail/labels`**
   - 功能：获取所有标签列表
   - 返回：标签数组（id, name, display_name, color, is_system）

4. **`POST /api/mail/:id/labels`**
   - 功能：为邮件添加标签
   - 参数：`{ labelId: number }`
   - 返回：成功/失败状态

5. **`DELETE /api/mail/:id/labels/:labelId`**
   - 功能：移除邮件的标签
   - 返回：成功/失败状态

6. **`PUT /api/mail/:id/move`**
   - 功能：移动邮件到指定文件夹
   - 参数：`{ folder: string }`
   - 返回：成功/失败状态

**扩展的API端点**：

1. **`GET /api/mail/list`**
   - 新增返回字段：`labels`, `priority`, `importance`, `recipients` (to/cc/bcc数组)
   - 使用 JOIN 查询获取文件夹名称和标签信息

2. **`GET /api/mail/:id`**
   - 新增返回字段：`labels`, `priority`, `importance`, `recipients`, `metadata`
   - 附件始终返回数组格式
   - 收件人返回结构化对象（to/cc/bcc数组）

3. **`GET /api/mail/stats`**
   - 新增返回字段：`drafts`, `trash`, `spam` 文件夹统计
   - 返回所有5个文件夹的统计信息

4. **`POST /api/mail/send`**
   - 新增参数：`folder` (草稿保存), `priority`, `importance`
   - 如果 `folder='drafts'`，直接保存到草稿箱，不发送邮件
   - 优先级和重要性随邮件一起保存

#### 🎨 前端功能扩展

**写邮件功能增强**：

1. **优先级选择器**
   - 下拉选择：普通/高优先级/低优先级
   - 值：0=普通，1=高，2=低
   - 发送时随邮件一起提交

2. **重要性标记**
   - 复选框：标记为重要
   - 值：0=普通，1=重要
   - 带星标图标显示

3. **草稿保存**
   - 手动保存按钮："保存草稿"
   - 自动保存：每30秒自动保存一次（如果主题或内容不为空）
   - 保存提示：显示"草稿已自动保存"提示
   - 草稿保存到草稿箱文件夹

**文件夹导航栏扩展**：

1. **新增文件夹按钮**
   - 草稿箱：黄色主题，显示草稿数量
   - 垃圾邮件：红色主题，显示未读数量
   - 已删除：灰色主题，显示总数

2. **文件夹统计显示**
   - 每个文件夹按钮显示未读/总数
   - 实时更新统计信息

**邮件列表增强**：

1. **标签显示**
   - 邮件列表项显示所有标签
   - 标签带颜色徽章显示
   - 标签颜色可自定义

2. **优先级和重要性显示**
   - 高优先级：红色感叹号图标
   - 重要性：黄色星标图标
   - 图标和文字组合显示

3. **多收件人显示**
   - 显示主收件人
   - 如果有抄送，显示"抄送"标签
   - 支持显示多个收件人

4. **快速操作按钮**
   - 移动到文件夹下拉菜单
   - 添加标签下拉菜单
   - 软删除按钮

**邮件详情页增强**：

1. **多收件人完整显示**
   - 分别显示 to/cc/bcc 收件人列表
   - 支持多个收件人地址
   - 向后兼容：如果没有新格式，使用旧格式

2. **标签管理**
   - 显示当前邮件的所有标签
   - 标签可点击删除
   - 下拉菜单添加新标签

3. **优先级和重要性显示**
   - 在邮件详情页顶部显示
   - 带图标和文字说明

4. **元数据显示**
   - 显示垃圾邮件评分
   - 显示加密状态
   - 其他元数据信息

5. **操作按钮**
   - 移动到文件夹下拉菜单
   - 添加标签下拉菜单
   - 软删除按钮

**邮件操作功能**：

1. **移动到文件夹**
   - 支持移动到：收件箱、已发送、草稿箱、垃圾邮件、已删除
   - 移动后自动更新邮件列表和统计
   - 操作成功提示

2. **标签管理**
   - 添加标签：从标签列表选择添加
   - 删除标签：点击标签徽章删除
   - 实时更新邮件详情和列表

3. **软删除**
   - 删除邮件移动到已删除文件夹
   - 显示确认提示
   - 删除后自动更新列表和统计

#### 🔧 后端脚本更新

**`mail_db.sh` 脚本扩展**：

1. **`init_mail_db` 函数**
   - 创建8张新表（包含所有字段和索引）
   - 插入默认系统文件夹和标签
   - 自动检测并添加新字段到旧表（向后兼容）

2. **`store_email` 函数**
   - 支持 `priority` 和 `importance` 参数
   - 解析收件人字符串，插入到 `email_recipients` 表
   - 解析附件JSON，插入到 `email_attachments` 表
   - 使用 `folder_id` 替代 `folder` 字符串

3. **`get_emails` 函数**
   - 使用 JOIN 查询获取文件夹名称
   - 使用子查询获取标签列表
   - 使用子查询获取收件人信息
   - 返回优先级、重要性、标签、收件人信息

4. **`get_email_detail` 函数**
   - 查询邮件基本信息（包含优先级和重要性）
   - 查询附件列表（从 `email_attachments` 表）
   - 查询收件人列表（从 `email_recipients` 表）
   - 查询标签列表（从 `email_label_relations` 和 `email_labels` 表）
   - 查询元数据（从 `email_metadata` 表）
   - 合并所有数据返回完整邮件信息

5. **`get_mail_stats` 函数**
   - 返回所有5个文件夹的统计信息
   - 使用 `folder_id` 和 `email_recipients` 表进行准确统计

6. **新增函数**：
   - `get_folders()` - 获取文件夹列表
   - `get_folder_stats()` - 获取文件夹统计
   - `get_labels()` - 获取标签列表
   - `add_email_label()` - 为邮件添加标签
   - `remove_email_label()` - 移除邮件标签
   - `migrate_attachments_data()` - 迁移附件数据
   - `migrate_folder_data()` - 迁移文件夹数据

**`delete_email` 函数更新**：
- 改为软删除：设置 `is_deleted=1` 而非真正删除
- 保留数据以便恢复

**`move_email` 函数更新**：
- 使用 `folder_id` 更新邮件文件夹
- 支持文件夹名称和ID两种方式

#### 🛡️ 向后兼容性处理

**数据兼容性**：
- 自动检测旧表结构，迁移数据到新表
- 如果新表为空，从旧字段读取数据
- 所有新字段都有默认值

**API兼容性**：
- 保留原有的 `to` 和 `cc` 字段
- 新增 `recipients` 对象，包含 to/cc/bcc 数组
- 如果 `recipients` 为空，使用 `to` 和 `cc` 字段

**前端兼容性**：
- 所有新字段都有默认值处理
- 兼容旧数据格式
- 附件始终确保为数组格式

### 🚀 升级步骤（从 V2.9.7 或更早版本）

**⚠️ 重要提示**：V3.0.0 是大版本更新，涉及数据库结构变更，请务必在升级前备份数据库！

```bash
# 1. 备份数据库
mysqldump -u mailuser -pmailpass maildb > /backup/maildb_backup_$(date +%Y%m%d_%H%M%S).sql

# 2. 更新代码
cd /bash && git pull

# 3. 初始化/升级数据库（自动检测并创建新表，迁移旧数据）
bash backend/scripts/mail_db.sh init

# 4. 重启调度层服务
systemctl restart mail-ops-dispatcher

# 5. 验证数据库结构
mysql -u mailuser -pmailpass maildb -e "SHOW TABLES;"
# 应该看到8张表：emails, email_attachments, email_recipients, email_folders, 
# email_labels, email_label_relations, email_metadata, mail_users

# 6. 验证API功能
curl -u "xm:xm666@" http://localhost/api/mail/folders
curl -u "xm:xm666@" http://localhost/api/mail/labels
curl -u "xm:xm666@" http://localhost/api/mail/stats

# 7. 检查前端功能
# 访问邮件管理页面，验证：
# - 文件夹导航栏显示5个文件夹
# - 写邮件页面有优先级和重要性选项
# - 邮件列表显示标签、优先级、重要性
# - 邮件详情页显示完整信息
# - 邮件操作功能正常
```

**升级后验证清单**：
- [ ] 数据库表结构正确（8张表）
- [ ] 默认文件夹和标签已创建
- [ ] 旧邮件数据已迁移到新表结构
- [ ] API端点正常响应
- [ ] 前端功能正常显示
- [ ] 草稿保存功能正常
- [ ] 邮件操作功能正常（移动、标签、删除）

**回滚步骤**（如遇问题）：
```bash
# 1. 恢复数据库备份
mysql -u mailuser -pmailpass maildb < /backup/maildb_backup_YYYYMMDD_HHMMSS.sql

# 2. 回退代码
cd /bash && git checkout v2.9.7

# 3. 重启服务
systemctl restart mail-ops-dispatcher
```

---

## V2.9.7（2025-11-13）

### 🎯 版本亮点
- **仓库源更新脚本**：新增 `update_repos.sh` 自动配置阿里云镜像源，添加 Docker CE 和 Kubernetes 仓库。
- **脚本头部注释统一化**：为所有 `backend/scripts/` 下的 21 个脚本添加统一的头部注释格式。
- **安装流程优化**：`start.sh` 自动执行仓库源更新，提高安装成功率和速度。

### 📋 更新内容
- 新增 `update_repos.sh` 脚本：自动备份仓库配置、配置阿里云镜像源、添加 Docker CE 和 Kubernetes 仓库
- 为 21 个 `backend/scripts/` 脚本统一添加头部注释：脚本职责、用法说明、功能描述、依赖关系等
- `start.sh` 集成仓库源更新：在系统安装开始时自动执行仓库源配置

#### 📦 仓库源更新脚本（update_repos.sh）
- **功能描述**：自动配置 Rocky Linux 使用阿里云镜像源，添加 Docker CE 和 Kubernetes 仓库，提升国内下载速度。
- **技术实现**：
  ```bash
  # 备份现有仓库配置
  sudo cp -r /etc/yum.repos.d /etc/yum.repos.d.backup
  
  # 配置 Rocky Linux 使用阿里云镜像
  sed -e 's|^mirrorlist=|#mirrorlist=|g' \
      -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
      -i.bak /etc/yum.repos.d/[Rr]ocky*.repo
  
  # 添加 Docker CE 仓库（阿里云镜像）
  yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
  
  # 添加 Kubernetes 仓库
  cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
  [kubernetes]
  name=Kubernetes
  baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
  enabled=1
  gpgcheck=1
  gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
  exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
  EOF
  
  # 更新 DNF 缓存
  dnf makecache
  ```
- **优势**：
  - 提升国内用户下载速度
  - 自动备份原配置，支持回滚
  - 统一配置 Docker CE 和 Kubernetes 仓库
  - 减少安装失败率

#### 📝 脚本头部注释统一化
- **功能描述**：为所有 `backend/scripts/` 目录下的 21 个脚本添加统一的头部注释格式，包含脚本职责、用法说明、功能描述、依赖关系等。
- **注释格式**：
  ```bash
  #!/bin/bash
  #
  # 脚本名称: script_name.sh
  # 脚本职责: 脚本的主要功能和职责描述
  # 用法说明: 如何使用该脚本
  # 功能描述: 详细的功能说明
  # 依赖关系: 脚本依赖的其他脚本或工具
  # 注意事项: 使用时需要注意的事项
  # 创建日期: YYYY-MM-DD
  # 更新日期: YYYY-MM-DD
  ```
- **涵盖的脚本**：
  - `app_user.sh` - 应用用户管理
  - `backup.sh` - 系统备份
  - `cert_setup.sh` - SSL证书管理
  - `db_setup.sh` - 数据库初始化
  - `dispatcher.sh` - 调度层管理
  - `dns_setup.sh` - DNS配置
  - `log_viewer.sh` - 日志查看
  - `mail_db.sh` - 邮件数据库管理
  - `mail_init.sh` - 邮件系统初始化
  - `mail_log_viewer.sh` - 邮件日志查看
  - `mail_logger.sh` - 邮件日志记录
  - `mail_receiver.sh` - 邮件接收处理
  - `mail_service_logger.sh` - 邮件服务日志
  - `mail_setup.sh` - 邮件服务配置
  - `security.sh` - 安全配置
  - `spam_filter.sh` - 垃圾邮件过滤
  - `test_spam_filter.sh` - 垃圾邮件过滤测试
  - `update_repos.sh` - 仓库源更新
  - `user_manage.sh` - 用户管理
- **优势**：
  - 提高代码可维护性
  - 便于新开发者理解脚本功能
  - 统一文档格式，便于查阅
  - 明确脚本依赖关系

#### 🚀 安装流程优化
- **功能描述**：`start.sh` 在系统安装开始时自动执行仓库源更新，确保使用国内镜像源，提高安装成功率和速度。
- **技术实现**：
  ```bash
  # 在 start.sh 的 start 操作开始时调用
  if [ -f "$ROOT_DIR/backend/scripts/update_repos.sh" ]; then
      log_info "更新系统仓库源..."
      bash "$ROOT_DIR/backend/scripts/update_repos.sh" || {
          log_warning "仓库源更新失败，继续使用默认源"
      }
  fi
  ```
- **优势**：
  - 自动化配置，无需手动操作
  - 提升国内用户安装体验
  - 减少因网络问题导致的安装失败
  - 统一使用优化的仓库源

### 🚀 升级步骤（从 2.9.6 或更早）
```bash
cd /bash && git pull
# 重启调度层服务
systemctl restart mail-ops-dispatcher
# 首次安装时会自动执行仓库源更新，无需额外配置
# 如需手动执行仓库源更新：
bash backend/scripts/update_repos.sh
```

---

## V2.9.6（2025-10-28）

### 🎯 版本亮点
- **后端参数默认化修复**：`configure-bind` 未传 `adminEmail` 时默认 `xm@localhost`。
- **显式配置标记**：仅当 `dns.configured=true` 且 `dns.type` 为 `public|bind` 时返回对应类型；否则 `dnsType:null`。
- **脚本健壮性**：健康检查与持久化脚本改为非阻断，`systemctl` 操作加入 `timeout`，避免阻塞。
- **安装脚本优化**：`start.sh` 的 DNS 清理改为可选（`RESET_DNS_ON_START=1`），默认跳过。
- **Bind 配置落盘**：配置成功后写入 `dns.type=bind` 与 `dns.configured=true`。

### 📋 更新内容
- 调度层 `configure-bind` 参数映射补全，统一传递 `[domain, serverIp, adminEmail, enableRecursion, enableForwarding, upstreamDns]`
- `/api/dns/status` 返回逻辑与 `dns.configured/dns.type` 对齐，未配置时返回 `dnsType:null`
- `dns_setup.sh`：健康检查与 systemd 持久化改为非阻断，并加入超时保护
- `start.sh`：DNS 清理从"开机必做"改为"可选项"，避免误判公网

### 🚀 升级步骤（从 2.9.5 或更早）
```bash
cd /bash && git pull
systemctl restart mail-ops-dispatcher
# 若历史中写入过默认 public 值，建议清理后重启：
jq '.dns.public.domain="" | .dns.public.serverIp="" | .dns.bind.domain="" | .dns.bind.serverIp=""' \
  /bash/config/system-settings.json > /bash/config/system-settings.json.tmp && \
mv /bash/config/system-settings.json.tmp /bash/config/system-settings.json && \
systemctl restart mail-ops-dispatcher
```

---

## V2.9.5（2025-10-28）

### 🎯 版本亮点
- DNS 默认未配置（null）；仅在 `dns.configured=true` 且 `dns.type` 为 `public|bind` 时返回对应类型
- 前端首次引导：当 `dnsType === null` 时，提供“本地Bind / 公网DNS”选择并保存后复检
- 邮件页建议优化：`public` 模式不再要求 `named` 服务
- 初始化默认值清理：移除任何对 `dns.public.domain`、`dns.public.serverIp` 的默认填充，避免重装后误判

### 📋 更新内容
- `/api/dns/status` 新增 `dnsType:null` 状态
- 前端 DNS 类型自动检测与引导改造
- 文档与默认配置调整，避免重装后错误识别为公网DNS

#### 🔍 DNS类型自动识别（增强）
- **功能描述**：未配置时返回 `dnsType: null`；仅在满足严格条件时判定为 `public` 或 `bind`。
- **后端实现**：在 `backend/dispatcher/server.js` 中，按如下规则计算：
  - `public`：`dns.public.domain` 与 `dns.public.serverIp` 均非空，且 `dns.bind.domain` 为空；
  - `bind`：`dns.bind.domain` 非空；
  - `null`：其他情况（含配置缺失/不完整/初始化阶段）。
- **前端体验**：当 `dnsType === null` 时，显示"未配置DNS"的引导卡片，用户选择并保存后再次校验。

#### 🌐 公网IP获取优化（延续自 2.9.4）
- **功能描述**：优化公网DNS配置中的IP获取逻辑，增加更多IP获取服务，提升获取成功率和准确性。
- **技术实现**：
  ```bash
  # 优化后的IP获取服务列表
  local ip_services=(
      "https://ipinfo.io/ip"
      "https://ipv4.icanhazip.com"
      "https://api.ip.sb/ip"
      "https://ifconfig.me/ip"
      "https://checkip.amazonaws.com"
      "https://icanhazip.com"
      "https://api.ipify.org"
  )
  ```
- **改进内容**：
  - 增加超时时间：`--connect-timeout 10 --max-time 20`
  - 添加IP验证：检查是否为公网IP（非私有IP段）
  - 优化错误处理：更详细的错误信息和重试机制

#### 🚫 DNS配置重复提醒修复（延续自 2.9.4）
- **问题描述**：DNS配置过程中出现多次重复的提醒信息，影响用户体验。
- **修复内容**：
  - 移除输入框下方的重复提醒
  - 简化状态指示器信息
  - 统一成功提示消息
- **技术实现**：
  ```javascript
  // 简化后的提醒逻辑
  <span v-if="dnsSaving" class="text-purple-600 font-medium">正在应用DNS配置...</span>
  <span v-else>多个DNS服务器用逗号分隔</span>
  ```

#### 📁 Apache配置文件管理（延续自 2.9.4）
- **功能描述**：DNS配置时自动删除现有配置文件并重新创建，避免配置冲突和错误。
- **技术实现**：
  ```bash
  # 删除现有的域名配置文件（如果存在）
  local vhost_conf="/etc/httpd/conf.d/${domain}.conf"
  if [[ -f "$vhost_conf" ]]; then
      log_info "删除现有的虚拟主机配置文件: $vhost_conf"
      rm -f "$vhost_conf"
      log_success "现有配置文件已删除"
  fi
  ```
- **优势**：确保每次配置都是全新的，避免旧配置残留导致的问题。

#### 🔄 DNS服务器去重（延续自 2.9.4）
- **问题描述**：resolv.conf中可能出现重复的DNS服务器配置。
- **修复内容**：
  ```bash
  # 检查是否已存在，避免重复添加
  if ! grep -q "nameserver $dns_server" /etc/resolv.conf; then
      echo "nameserver $dns_server" >> /etc/resolv.conf
  fi
  ```
- **效果**：确保resolv.conf中每个DNS服务器只出现一次。

### 🚀 升级步骤（从 2.9.4 或更早）
```bash
cd /bash && git pull
systemctl restart mail-ops-dispatcher
# 若历史中写入过默认 public 值，建议清理后重启：
jq '.dns.public.domain="" | .dns.public.serverIp="" | .dns.bind.domain="" | .dns.bind.serverIp=""' \
  /bash/config/system-settings.json > /bash/config/system-settings.json.tmp && \
mv /bash/config/system-settings.json.tmp /bash/config/system-settings.json && \
systemctl restart mail-ops-dispatcher
```

---

## V2.9.4（2025-10-27）

### 🎯 版本亮点
- DNS 类型自动识别（bind/public），前端根据类型切换
- 公网IP获取优化：多源检测、超时控制、私网IP过滤
- DNS 提示去重：状态提示与成功消息统一
- Apache 配置文件管理：生成前删除旧 vhost，避免冲突
- resolv.conf 去重：防止重复 `nameserver`

### 📋 更新内容
- 增加外网 IP 检测服务与超时配置
- vhost 生成前清理旧配置，减少冲突
- DNS 去重与提示信息统一

### 🚀 升级步骤（从 2.9.3 或更早）
```bash
cd /bash && git pull
systemctl restart mail-ops-dispatcher httpd
# 验证 Apache 配置：
httpd -t
```

---

## V2.9.3（2025-10-27）

### 🎯 版本亮点
- DNS 配置与 Apache 深度集成：自动创建 vhost（含 `ServerAlias www.<domain>`）
- 健康检查增强：新增 `www` 子域 A 记录校验
- NetworkManager/IPv6 兼容：版本检测与失败降级

### 📋 更新内容
- 自动生成 `www` 别名与 hosts 更新
- Zone 与 vhost 语法/加载检查流程完善
- NetworkManager 配置容错与降级

### 🚀 升级步骤（从 2.9.2 或更早）
```bash
cd /bash && git pull
systemctl restart httpd
# 验证 zone 与 vhost：
named-checkconf && httpd -t
```
### 📋 更新内容

#### 🔍 DNS类型自动识别
- **功能描述**：系统设置中的DNS配置页面现在能够自动识别当前使用的DNS类型（本地Bind DNS或公网DNS）。
- **技术实现**：
  ```javascript
  // 检测当前DNS类型
  const detectDnsType = async () => {
    const response = await fetch('/api/dns/status')
    const data = await response.json()
    
    if (data.services?.named) {
      dnsType.value = 'bind'
    } else if (data.domain) {
      dnsType.value = 'public'
    }
  }
  ```
- **用户体验**：页面加载时自动检测DNS类型，无需手动选择，避免配置错误。

#### 🌐 公网IP获取优化
- **功能描述**：优化公网DNS配置中的IP获取逻辑，增加更多IP获取服务，提升获取成功率和准确性。
- **技术实现**：
  ```bash
  # 优化后的IP获取服务列表
  local ip_services=(
      "https://ipinfo.io/ip"
      "https://ipv4.icanhazip.com"
      "https://api.ip.sb/ip"
      "https://ifconfig.me/ip"
      "https://checkip.amazonaws.com"
      "https://icanhazip.com"
      "https://api.ipify.org"
  )
  ```
- **改进内容**：
  - 增加超时时间：`--connect-timeout 10 --max-time 20`
  - 添加IP验证：检查是否为公网IP（非私有IP段）
  - 优化错误处理：更详细的错误信息和重试机制

#### 🚫 DNS配置重复提醒修复
- **问题描述**：DNS配置过程中出现多次重复的提醒信息，影响用户体验。
- **修复内容**：
  - 移除输入框下方的重复提醒
  - 简化状态指示器信息
  - 统一成功提示消息
- **技术实现**：
  ```javascript
  // 简化后的提醒逻辑
  <span v-if="dnsSaving" class="text-purple-600 font-medium">正在应用DNS配置...</span>
  <span v-else>多个DNS服务器用逗号分隔</span>
  ```

#### 📁 Apache配置文件管理
- **功能描述**：DNS配置时自动删除现有配置文件并重新创建，避免配置冲突和错误。
- **技术实现**：
  ```bash
  # 删除现有的域名配置文件（如果存在）
  local vhost_conf="/etc/httpd/conf.d/${domain}.conf"
  if [[ -f "$vhost_conf" ]]; then
      log_info "删除现有的虚拟主机配置文件: $vhost_conf"
      rm -f "$vhost_conf"
      log_success "现有配置文件已删除"
  fi
  ```
- **优势**：确保每次配置都是全新的，避免旧配置残留导致的问题。

#### 🔄 DNS服务器去重
- **问题描述**：resolv.conf中可能出现重复的DNS服务器配置。
- **修复内容**：
  ```bash
  # 检查是否已存在，避免重复添加
  if ! grep -q "nameserver $dns_server" /etc/resolv.conf; then
      echo "nameserver $dns_server" >> /etc/resolv.conf
  fi
  ```
- **效果**：确保resolv.conf中每个DNS服务器只出现一次。

### 🚀 升级步骤

1. **备份当前配置**：
   ```bash
   cp /bash/config/system-settings.json /bash/config/system-settings.json.backup
   ```

2. **更新系统文件**：
   ```bash
   cd /bash
   git pull origin main
   ```

3. **重启服务**：
   ```bash
   systemctl restart mail-ops-dispatcher
   systemctl restart httpd
   ```

4. **验证功能**：
   - 打开系统设置 → DNS配置
   - 检查DNS类型是否自动识别
   - 测试公网DNS配置功能

### ⚠️ 注意事项

- **DNS类型检测**：系统会根据当前运行的服务自动识别DNS类型，无需手动设置。
- **配置文件清理**：DNS配置时会自动清理旧配置文件，请确保重要配置已备份。
- **公网IP获取**：如果网络环境限制，可能需要等待较长时间获取公网IP。

### 🐛 已知问题

- **IPv6 DNS配置**：在某些系统上IPv6 DNS配置可能失败，但不影响IPv4功能。
- **NetworkManager版本**：不同版本的NetworkManager可能存在兼容性问题。

### 📈 性能优化

- **DNS检测优化**：减少不必要的API调用，提升页面加载速度。
- **配置文件管理**：避免重复创建配置文件，减少磁盘I/O。
- **提醒信息优化**：简化状态提示，减少界面闪烁。

---

## V2.9.3 (2025-10-27)

### 🎯 版本亮点
- **DNS配置Apache集成**：在DNS配置中自动集成Apache虚拟主机配置，支持HTTP和HTTPS访问，确保域名配置的完整性。
- **www子域名支持**：完整支持www子域名，包括DNS记录、Apache虚拟主机配置、hosts文件更新和健康检查。
- **公网DNS配置选项**：在配置服务中新增公网DNS选项，支持获取公网域名并自动配置Apache虚拟主机。
- **DNS配置错误修复**：修复resolv.conf写入权限问题、NetworkManager配置错误、IPv6 DNS配置错误等，提升DNS配置稳定性。
- **DNS健康检查增强**：新增www子域A记录检查，提供更全面的DNS配置验证和健康度评估。
- **Apache配置自动化**：DNS配置完成后自动创建Apache虚拟主机，支持安全头设置和SSL配置。

### 📋 更新内容

#### 🌐 DNS配置Apache集成
- **功能描述**：在DNS配置过程中自动集成Apache虚拟主机配置，确保域名配置的完整性。
- **配置流程**：DNS配置完成后自动调用Apache配置，创建虚拟主机支持HTTP和HTTPS访问。
- **技术实现**：
  ```bash
  # 在Bind DNS配置中添加Apache配置调用
  update_apache_config "$domain" "$server_ip"
  ```
- **配置文件位置**：
  - 主配置：`/etc/httpd/conf/httpd.conf`
  - 虚拟主机：`/etc/httpd/conf.d/${domain}.conf`
  - 日志文件：`/var/log/httpd/${domain}_*.log`

#### 🌍 www子域名支持
- **功能描述**：完整支持www子域名，包括DNS记录、Apache配置、hosts文件更新和健康检查。
- **DNS记录**：自动创建`www IN A $server_ip`记录
- **Apache配置**：添加`ServerAlias www.$domain`支持
- **hosts文件**：更新`$server_ip $domain www.$domain`条目
- **健康检查**：新增www子域A记录测试
- **技术实现**：
  ```apache
  <VirtualHost *:80>
      ServerName $domain
      ServerAlias www.$domain
      DocumentRoot /var/www/html
  </VirtualHost>
  ```

#### 🔧 公网DNS配置选项
- **功能描述**：在配置服务中新增公网DNS选项，支持获取公网域名并自动配置Apache虚拟主机。
- **配置界面**：在DNS解析配置页面添加公网DNS选择选项
- **配置流程**：选择公网DNS → 输入域名 → 获取域名信息 → 配置Apache虚拟主机
- **API接口**：新增`/api/dns/public-configure`接口
- **技术实现**：
  ```javascript
  // 公网DNS配置API调用
  const publicDnsResponse = await fetch('/api/dns/public-configure', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
    },
    body: JSON.stringify({
      domain: configDomain.value.trim(),
      serverIp: serverIp
    })
  })
  ```

#### 🛠️ DNS配置错误修复
- **resolv.conf权限问题**：修复写入权限问题，添加不可变属性检查
- **NetworkManager配置错误**：修复IPv4和IPv6 DNS配置错误，添加错误处理
- **IPv6 DNS配置**：修复IPv6 DNS配置错误，添加IPv6支持检测
- **版本兼容性**：添加NetworkManager版本检查，避免版本不匹配警告
- **技术实现**：
  ```bash
  # 检查resolv.conf是否被设置为不可变
  if [[ -f /etc/resolv.conf ]] && lsattr /etc/resolv.conf 2>/dev/null | grep -q "i"; then
      log_info "检测到resolv.conf被设置为不可变，临时移除属性"
      chattr -i /etc/resolv.conf 2>/dev/null || true
  fi
  ```

#### 📊 DNS健康检查增强
- **功能描述**：新增www子域A记录检查，提供更全面的DNS配置验证和健康度评估。
- **检查项目**：MX记录、A记录、www子域A记录、PTR记录、SPF记录、DKIM记录、DMARC记录
- **健康度计算**：基于通过检查项目数量计算健康度百分比
- **技术实现**：
  ```bash
  # 检查www子域A记录
  local www_record_result=$(dig @$server_ip www.$domain A +short)
  if echo "$www_record_result" | grep -q "$server_ip"; then
      log_success "www子域A记录检查通过"
      passed_checks=$((passed_checks + 1))
  fi
  ```

#### 🔒 Apache配置自动化
- **功能描述**：DNS配置完成后自动创建Apache虚拟主机，支持安全头设置和SSL配置。
- **安全头设置**：
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: DENY
  - X-XSS-Protection: 1; mode=block
  - Strict-Transport-Security (HTTPS)
- **SSL配置**：支持HTTPS虚拟主机配置，包含SSL证书路径
- **日志配置**：分离HTTP和HTTPS访问日志和错误日志
- **技术实现**：
  ```apache
  # 安全头配置
  Header always set X-Content-Type-Options nosniff
  Header always set X-Frame-Options DENY
  Header always set X-XSS-Protection "1; mode=block"
  Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
  ```

### 🔄 升级步骤

#### 1. 备份当前系统
```bash
# 备份Apache配置
cp -r /etc/httpd/conf.d /backup/apache_conf_$(date +%Y%m%d)

# 备份DNS配置
cp -r /var/named /backup/named_$(date +%Y%m%d)
```

#### 2. 更新系统文件
```bash
# 更新DNS配置脚本
cp dns_setup.sh /bash/backend/scripts/

# 更新前端文件
cp -r frontend/* /var/www/html/
```

#### 3. 重启服务
```bash
# 重启Apache服务
systemctl restart httpd

# 重启DNS服务
systemctl restart named

# 重启调度服务
systemctl restart mail-ops-dispatcher
```

#### 4. 验证配置
```bash
# 检查Apache配置
httpd -t

# 检查DNS配置
named-checkconf

# 测试域名解析
nslookup your-domain.com
```

### ⚠️ 注意事项

1. **Apache依赖**：确保Apache已安装并运行
2. **权限设置**：确保脚本有足够权限修改Apache配置
3. **SSL证书**：HTTPS配置需要有效的SSL证书
4. **防火墙**：确保80和443端口已开放
5. **域名解析**：确保域名正确解析到服务器IP

### 🐛 已知问题

1. **NetworkManager版本不匹配**：某些系统可能出现nmcli和NetworkManager版本不匹配警告，不影响功能
2. **IPv6支持**：在IPv6不支持的系统上会跳过IPv6 DNS配置
3. **SSL证书**：HTTPS配置需要手动配置SSL证书

### 📈 性能优化

1. **DNS缓存**：配置DNS缓存提升解析速度
2. **Apache优化**：启用压缩和缓存模块
3. **日志轮转**：配置日志轮转避免磁盘空间不足

---

## V2.9.2 (2025-10-26)

### 📋 更新内容

#### 📄 用户分页功能完善
- **功能描述**：新增完整的用户列表分页功能，支持多种每页显示条数，提供页码导航和记录统计信息。
- **分页选项**：支持5/10/15/20/25/50条每页显示，用户可根据需要灵活调整。
- **页码导航**：提供上一页/下一页按钮和直接页码跳转功能，支持多页导航。
- **记录统计**：显示当前页范围和总记录数，如"显示第1-10条，共25条"。
- **技术实现**：
  ```javascript
  // 用户列表分页状态
  const currentPage = ref(1) // 当前页码
  const pageSize = ref(10) // 每页显示数量
  const totalUsers = ref(0) // 用户总数
  const totalPages = ref(0) // 总页数
  const paginatedUsers = ref<any[]>([]) // 分页后的用户列表
  
  // 分页计算属性
  const paginationInfo = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value + 1
    const end = Math.min(currentPage.value * pageSize.value, totalUsers.value)
    return { start, end, total: totalUsers.value, current: currentPage.value, totalPages: totalPages.value }
  })
  ```
- **分页组件**：
  ```html
  <!-- 分页组件 -->
  <div v-if="users.length > 0" class="mt-4 flex items-center justify-between">
    <div class="flex items-center space-x-2">
      <span class="text-sm text-gray-700">每页显示</span>
      <select v-model="pageSize" @change="changePageSize(pageSize)">
        <option value="5">5</option>
        <option value="10">10</option>
        <option value="15">15</option>
        <option value="20">20</option>
        <option value="25">25</option>
        <option value="50">50</option>
      </select>
      <span class="text-sm text-gray-700">条记录</span>
    </div>
    
    <div class="flex items-center space-x-2">
      <span class="text-sm text-gray-700">
        显示第 {{ paginationInfo.start }}-{{ paginationInfo.end }} 条，共 {{ paginationInfo.total }} 条
      </span>
    </div>
    
    <div v-if="totalPages > 1" class="flex items-center space-x-1">
      <!-- 页码导航按钮 -->
    </div>
  </div>
  ```

#### ⚙️ 用户分页设置系统集成
- **功能描述**：将用户分页大小设置从邮件设置移动到系统管理的常规设置中，提供更合理的设置位置。
- **设置位置**：系统管理 → 常规设置 → 用户分页大小（位于时区设置之前）
- **设置选项**：5/10/15/20/25/50条每页显示
- **技术实现**：
  ```javascript
  // 系统设置初始化
  const systemSettings = ref({
    general: {
      systemName: 'XM邮件管理系统',
      adminEmail: 'admin@example.com',
      timezone: 'Asia/Shanghai',
      language: 'zh-CN',
      autoBackup: true,
      backupInterval: 24,
      logRetention: 30,
      userPageSize: 10  // 新增用户分页大小设置
    }
  })
  
  // 从系统设置加载分页配置
  function loadPaginationSettings() {
    if (systemSettings.value.general?.userPageSize) {
      pageSize.value = systemSettings.value.general.userPageSize
    } else {
      const savedPageSize = localStorage.getItem('userPageSize')
      if (savedPageSize) {
        pageSize.value = parseInt(savedPageSize)
      }
    }
  }
  ```
- **后端API支持**：
  ```javascript
  // 默认设置包含用户分页配置
  systemSettings = {
    general: {
      systemName: 'XM邮件管理系统',
      adminEmail: 'admin@xmskills.com',
      timezone: 'Asia/Shanghai',
      language: 'zh-CN',
      autoBackup: true,
      backupInterval: 24,
      logRetention: 30,
      userPageSize: 10
    }
  }
  ```

#### 🔍 用户存在性检查修复
- **功能描述**：修复批量创建用户时的用户存在性检查逻辑，新增专门的用户存在性检查API。
- **问题修复**：原`checkUserExists`函数使用错误的API接口，现在使用专门的`check-user-exists` API。
- **技术实现**：
  ```javascript
  // 检查用户是否存在
  async function checkUserExists(username: string): Promise<boolean> {
    try {
      const response = await axios.post('/api/ops', {
        action: 'check-user-exists',
        params: { username: username }
      }, { headers: authHeader() })
      
      return response.data.success && response.data.exists
    } catch (error) {
      console.error(`检查用户 ${username} 是否存在失败:`, error)
      return false
    }
  }
  ```
- **后端脚本支持**：
  ```bash
  # app_user.sh 新增 check_user_exists 函数
  check_user_exists() {
    local username="$1"
    echo "检查用户是否存在: $username" >&1
    
    # 检查应用用户表中是否存在该用户名
    local app_user_exists
    app_user_exists=$(mysql -u root -e "USE mailapp; SELECT COUNT(*) FROM app_users WHERE username='$username';" 2>/dev/null | tail -1)
    
    # 检查邮件用户表中是否存在该用户名
    local mail_user_exists
    mail_user_exists=$(mysql -u mailuser -pmailpass maildb -e "SELECT COUNT(*) FROM mail_users WHERE username='$username';" 2>/dev/null | tail -1)
    
    # 如果任一表中存在该用户，则认为用户已存在
    if [[ "$app_user_exists" -gt 0 || "$mail_user_exists" -gt 0 ]]; then
      echo "用户已存在: $username" >&1
      echo "{\"success\": true, \"exists\": true}" >&1
      return 0
    else
      echo "用户不存在: $username" >&1
      echo "{\"success\": true, \"exists\": false}" >&1
      return 0
    fi
  }
  ```
- **API权限配置**：
  ```javascript
  // 在 ALLOWED_ACTIONS 中添加 check-user-exists
  const ALLOWED_ACTIONS = new Set([
    'check',
    'install',
    'configure',
    'restart',
    'status',
    'security-hardening',
    'db-init',
    'domain-add',
    'user-add',
    'user-del',
    'query-users',
    'app-init',
    'app-register',
    'app-login',
    'app-reset',
    'check-user-exists',  // 新增用户存在性检查
    'install-cert',
    'setup-logs',
    'full-backup',
    'setup-cron',
    'setup-backup-cron'
  ])
  ```

#### 📄 分页组件常驻显示
- **功能描述**：修复分页组件在调整每页显示条数时消失的问题，现在分页设置常驻显示。
- **显示逻辑优化**：
  ```html
  <!-- 修改前：只在多页时显示 -->
  <div v-if="totalPages > 1" class="mt-4 flex items-center justify-between">
  
  <!-- 修改后：有用户数据时显示 -->
  <div v-if="users.length > 0" class="mt-4 flex items-center justify-between">
  ```
- **智能显示逻辑**：
  ```html
  <!-- 页码按钮只在多页时显示 -->
  <div v-if="totalPages > 1" class="flex items-center space-x-1">
    <!-- 页码导航按钮 -->
  </div>
  
  <!-- 当只有一页时显示提示 -->
  <div v-else class="flex items-center">
    <span class="text-sm text-gray-500">所有用户已显示</span>
  </div>
  ```

#### 🗑️ 批量删除用户功能
- **功能描述**：新增批量删除用户功能，支持多选用户和批量删除操作。
- **功能特点**：
  - 支持多选用户（复选框选择）
  - 支持全选/取消全选
  - 管理员用户（xm）受保护，无法选择
  - 批量删除确认对话框
  - 详细的删除结果反馈
- **技术实现**：
  ```javascript
  // 批量删除用户状态
  const selectedUsers = ref<Set<string>>(new Set()) // 选中的用户ID集合
  const showBatchDeleteDialog = ref(false) // 批量删除对话框
  const batchDeleting = ref(false) // 批量删除进行中
  
  // 切换用户选择
  function toggleUserSelection(userId: string) {
    if (selectedUsers.value.has(userId)) {
      selectedUsers.value.delete(userId)
    } else {
      selectedUsers.value.add(userId)
    }
  }
  
  // 全选/取消全选
  function toggleSelectAllUsers() {
    if (selectedUsers.value.size === users.value.length) {
      selectedUsers.value.clear()
    } else {
      selectedUsers.value.clear()
      users.value.forEach(user => {
        if (user.username !== 'xm') { // 不选择管理员用户
          selectedUsers.value.add(user.id)
        }
      })
    }
  }
  ```
- **批量删除执行**：
  ```javascript
  async function executeBatchDelete() {
    if (batchDeleting.value) return
    
    batchDeleting.value = true
    
    try {
      const selectedUserIds = Array.from(selectedUsers.value)
      const selectedUserList = users.value.filter(user => selectedUserIds.includes(user.id))
      
      let successCount = 0
      let failedCount = 0
      
      for (const user of selectedUserList) {
        try {
          const response = await axios.post('/api/ops', {
            action: 'user-del',
            params: { email: user.email }
          }, { headers: authHeader() })
          
          if (response.data.success) {
            successCount++
          } else {
            failedCount++
          }
        } catch (error) {
          console.error(`删除用户 ${user.username} 失败:`, error)
          failedCount++
        }
      }
      
      // 刷新用户列表和显示结果
      await loadUsers()
      selectedUsers.value.clear()
      
      if (successCount > 0) {
        notice.value = `批量删除完成！成功删除 ${successCount} 个用户`
        if (failedCount > 0) {
          notice.value += `，${failedCount} 个用户删除失败`
        }
        noticeType.value = 'success'
      } else {
        notice.value = '批量删除失败，请检查用户权限'
        noticeType.value = 'error'
      }
      
    } catch (error) {
      console.error('批量删除用户失败:', error)
      notice.value = '批量删除失败：' + error.message
      noticeType.value = 'error'
    } finally {
      batchDeleting.value = false
      showBatchDeleteDialog.value = false
    }
  }
  ```

#### 🔧 系统设置API优化
- **功能描述**：优化系统设置API，支持用户分页配置的实时保存和加载。
- **API支持**：系统设置API现在包含`general.userPageSize`字段
- **数据同步**：前端分页组件与系统设置双向同步
- **持久化存储**：localStorage作为备用存储，确保设置不丢失

#### 👥 批量创建用户功能（V2.9.1功能保持）
- **功能描述**：新增批量创建用户功能，支持两种创建方式，大幅提升用户管理效率。
- **创建方式**：
  - **用户名列表**：支持逗号分割的用户名列表，如 `user1,user2,user3`
  - **批量创建**：支持用户名前缀+数量，自动添加序号，如 `user` → `user01, user02, user03`
- **技术实现**：
  ```javascript
  // 批量创建用户状态管理
  const showBatchCreateDialog = ref(false)
  const batchCreateMode = ref<'list' | 'count'>('list')
  const batchUsernameList = ref('')
  const batchUsernamePrefix = ref('')
  const batchUserCount = ref(1)
  const batchCreateResults = ref<Array<{username: string, email: string, password: string, success: boolean}>>([])
  
  // 批量创建执行逻辑
  async function executeBatchCreate() {
    let usernames: string[] = []
    if (batchCreateMode.value === 'list') {
      usernames = batchUsernameList.value.split(',').map(name => name.trim()).filter(name => name.length > 0)
    } else if (batchCreateMode.value === 'count') {
      for (let i = 1; i <= batchUserCount.value; i++) {
        const paddedNumber = i.toString().padStart(2, '0')
        usernames.push(`${batchUsernamePrefix.value}${paddedNumber}`)
      }
    }
  }
  ```

#### 🔧 批量创建域名修复
- **问题描述**：批量创建用户时，邮箱域名统一使用 `localhost`，而不是系统配置的域名。
- **解决方案**：
  - 添加系统设置加载功能 `loadSystemSettings()`
  - 实现动态域名获取 `getLocalDomain()`
  - 在页面加载时自动加载系统设置
- **技术实现**：
  ```javascript
  // 系统设置加载
  const loadSystemSettings = async () => {
    try {
      const response = await fetch('/api/system-settings', {
        headers: { 'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}` }
      })
      
      if (response.ok) {
        const data = await response.json()
        if (data.success) {
          systemSettings.value = {
            ...systemSettings.value,
            ...data.settings,
            mail: { ...systemSettings.value.mail, ...data.settings.mail }
          }
        }
      }
    } catch (error) {
      console.error('加载系统设置失败:', error)
    }
  }
  
  // 动态域名获取
  const getLocalDomain = () => {
    const domains = systemSettings.value.mail?.domains || []
    if (domains.length > 0) {
      return domains[0].name
    }
    return 'localhost'
  }
  ```

#### 🔐 批量创建认证修复
- **问题描述**：批量创建用户时出现401认证失败错误，API调用缺少认证头信息。
- **解决方案**：
  - 在API调用中添加 `authHeader()` 认证头
  - 确保所有API调用都包含正确的认证信息
- **技术实现**：
  ```javascript
  // 认证头函数
  function authHeader() {
    const token = sessionStorage.getItem('apiAuth') || ''
    return { Authorization: `Basic ${token}` }
  }
  
  // 修复后的API调用
  const response = await axios.post('/api/ops', {
    action: 'app-register',
    params: { username, email, password }
  }, { headers: authHeader() }) // 添加认证头
  ```

#### 📊 批量创建结果展示
- **功能描述**：新增详细的批量创建结果展示，显示每个用户的创建状态、邮箱地址和密码信息。
- **展示内容**：
  - 用户名和邮箱地址
  - 统一密码（默认：123123）
  - 创建成功/失败状态
  - 成功/失败统计
- **技术实现**：
  ```javascript
  // 创建结果展示
  <div v-if="batchCreateResults.length > 0" class="mt-6">
    <h4 class="text-sm font-medium text-gray-900 mb-3">创建结果</h4>
    <div class="bg-gray-50 rounded-lg p-4 max-h-64 overflow-y-auto">
      <div v-for="result in batchCreateResults" :key="result.username" 
           class="flex items-center justify-between py-2 border-b border-gray-200 last:border-b-0">
        <div class="flex-1">
          <div class="flex items-center space-x-2">
            <span class="font-medium">{{ result.username }}</span>
            <span class="text-gray-500">{{ result.email }}</span>
            <span class="text-gray-400">密码: {{ result.password }}</span>
          </div>
        </div>
        <div class="flex items-center">
          <svg v-if="result.success" class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
          <svg v-else class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </div>
      </div>
    </div>
  </div>
  ```

#### 🎨 用户管理界面优化
- **功能描述**：在用户管理界面新增"批量创建"按钮，提供便捷的批量用户创建入口。
- **界面优化**：
  - 新增"批量创建"按钮，位于用户管理操作区域
  - 现代化的批量创建对话框设计
  - 支持两种创建方式的直观选择
  - 实时创建结果展示
- **技术实现**：
  ```html
  <!-- 批量创建按钮 -->
  <button @click="() => { userLogger.logButtonClick('批量创建用户', '用户管理'); openBatchCreateDialog() }"
          class="inline-flex items-center px-3 py-1.5 text-sm font-medium text-purple-600 hover:text-purple-800 transition-all duration-200">
    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
    </svg>
    批量创建
  </button>
  ```

### 🔄 版本升级步骤

#### 1. 系统备份
```bash
# 备份系统配置
sudo cp -r /bash /bash_backup_$(date +%Y%m%d_%H%M%S)

# 备份数据库
mysqldump -u mailuser -pmailpass maildb > maildb_backup_$(date +%Y%m%d_%H%M%S).sql
mysqldump -u mailuser -pmailpass mailapp > mailapp_backup_$(date +%Y%m%d_%H%M%S).sql
```

#### 2. 前端更新
```bash
# 进入前端目录
cd /bash/frontend

# 更新前端代码
git pull origin main

# 重新构建前端
npm run build
```

#### 3. 后端更新
```bash
# 进入后端目录
cd /bash/backend

# 更新后端代码
git pull origin main

# 重启调度层服务
sudo systemctl restart mail-ops-dispatcher
```

#### 4. 功能验证
1. **登录系统**：验证用户登录功能正常
2. **批量创建测试**：
   - 测试用户名列表方式：`test1,test2,test3`
   - 测试批量创建方式：前缀 `user`，数量 `3`
3. **域名验证**：确认创建的邮箱使用正确域名
4. **结果展示**：验证创建结果正确显示

### ⚠️ 注意事项

1. **系统兼容性**：确保系统运行在 Rocky Linux 9 环境
2. **权限要求**：确保 `xm` 用户具有完整的 sudo 权限
3. **数据库备份**：升级前务必备份所有数据库
4. **服务重启**：更新后需要重启相关服务
5. **功能测试**：升级后需要全面测试批量创建功能

### 🐛 故障排除

#### 批量创建失败
- **检查认证**：确认用户已正确登录
- **检查权限**：确认用户具有管理员权限
- **检查API**：确认 `/api/ops` 接口正常
- **检查日志**：查看调度层服务日志

#### 域名显示错误
- **检查系统设置**：确认系统设置已正确加载
- **检查域名配置**：确认邮件域名已正确配置
- **检查API响应**：确认 `/api/system-settings` 返回正确数据

#### 创建结果不显示
- **检查前端状态**：确认 `batchCreateResults` 状态正确
- **检查API响应**：确认创建API返回正确结果
- **检查错误处理**：确认错误处理逻辑正确

### 📈 性能优化

1. **批量创建优化**：支持最多100个用户同时创建
2. **API调用优化**：使用认证头缓存，减少重复认证
3. **界面响应优化**：使用异步加载，避免界面阻塞
4. **错误处理优化**：提供详细的错误信息和用户友好的提示

### 🔒 安全考虑

1. **认证安全**：所有API调用都包含认证头信息
2. **权限控制**：只有管理员可以执行批量创建操作
3. **数据验证**：对用户名和邮箱进行格式验证
4. **操作审计**：所有批量创建操作都有日志记录

---

## 历史版本更新记录

## V2.9.1 (2025-10-26) - 批量创建用户功能和系统优化

### 🎯 版本亮点
- **批量创建用户功能**：新增批量创建用户功能，支持两种创建方式：1) 逗号分割的用户名列表 2) 用户名前缀+数量自动添加序号，大幅提升用户管理效率。
- **批量创建域名修复**：修复批量创建用户时邮箱域名使用localhost的问题，现在会正确使用系统配置的域名（如xmskills.com）。
- **系统设置动态加载**：实现系统设置的动态加载功能，确保批量创建用户时能获取到正确的域名配置。
- **批量创建认证修复**：修复批量创建用户时的API认证问题，确保所有API调用都包含正确的认证头信息。
- **批量创建结果展示**：新增详细的批量创建结果展示，显示每个用户的创建状态、邮箱地址和密码信息。
- **用户管理界面优化**：在用户管理界面新增"批量创建"按钮，提供便捷的批量用户创建入口。

### 📋 更新内容

#### 👥 批量创建用户功能
- **功能描述**：新增批量创建用户功能，支持两种创建方式，大幅提升用户管理效率。
- **创建方式**：
  - **用户名列表**：支持逗号分割的用户名列表，如 `user1,user2,user3`
  - **批量创建**：支持用户名前缀+数量，自动添加序号，如 `user` → `user01, user02, user03`
- **技术实现**：
  ```javascript
  // 批量创建用户状态管理
  const showBatchCreateDialog = ref(false)
  const batchCreateMode = ref<'list' | 'count'>('list')
  const batchUsernameList = ref('')
  const batchUsernamePrefix = ref('')
  const batchUserCount = ref(1)
  const batchCreateResults = ref<Array<{username: string, email: string, password: string, success: boolean, reason?: string}>>([])
  const batchCreating = ref(false)
  const batchPassword = ref('123123')
  
  // 执行批量创建用户
  async function executeBatchCreate() {
    if (batchCreating.value) return
    
    batchCreating.value = true
    batchCreateResults.value = []
    
    try {
      let usernames: string[] = []
      
      if (batchCreateMode.value === 'list') {
        // 解析逗号分割的用户名列表
        usernames = batchUsernameList.value
          .split(',')
          .map(name => name.trim())
          .filter(name => name.length > 0)
      } else if (batchCreateMode.value === 'count') {
        // 生成带序号的用户名
        usernames = []
        for (let i = 1; i <= batchUserCount.value; i++) {
          const paddedNumber = i.toString().padStart(2, '0')
          usernames.push(`${batchUsernamePrefix.value}${paddedNumber}`)
        }
      }
      
      const localDomain = getLocalDomain()
      const userPassword = batchPassword.value.trim() || '123123'
      
      // 批量创建用户
      for (const username of usernames) {
        try {
          const email = `${username}@${localDomain}`
          
          // 先检查用户是否已存在
          const userExists = await checkUserExists(username)
          if (userExists) {
            batchCreateResults.value.push({
              username: username,
              email: email,
              password: userPassword,
              success: false,
              reason: '用户已存在'
            })
            continue
          }
          
          // 调用添加用户API
          const response = await axios.post('/api/ops', {
            action: 'app-register',
            params: {
              username: username,
              email: email,
              password: userPassword
            }
          }, { headers: authHeader() })
          
          if (response.data.success) {
            batchCreateResults.value.push({
              username: username,
              email: email,
              password: userPassword,
              success: true
            })
          } else {
            batchCreateResults.value.push({
              username: username,
              email: email,
              password: userPassword,
              success: false,
              reason: '创建失败'
            })
          }
        } catch (error) {
          console.error(`创建用户 ${username} 失败:`, error)
          batchCreateResults.value.push({
            username: username,
            email: `${username}@${localDomain}`,
            password: userPassword,
            success: false,
            reason: 'API调用失败'
          })
        }
      }
      
      // 刷新用户列表和显示结果
      await loadUsers()
      
      const successCount = batchCreateResults.value.filter(r => r.success).length
      const existingCount = batchCreateResults.value.filter(r => !r.success && r.reason === '用户已存在').length
      const failedCount = batchCreateResults.value.filter(r => !r.success && r.reason !== '用户已存在').length
      const totalCount = batchCreateResults.value.length
      
      if (successCount > 0) {
        let message = `批量创建完成！成功创建 ${successCount}/${totalCount} 个用户，密码统一为：${userPassword}`
        if (existingCount > 0) {
          message += `，跳过 ${existingCount} 个已存在用户`
        }
        if (failedCount > 0) {
          message += `，${failedCount} 个用户创建失败`
        }
        notice.value = message
        noticeType.value = 'success'
      } else if (existingCount > 0) {
        notice.value = `所有用户都已存在，共跳过 ${existingCount} 个用户`
        noticeType.value = 'warning'
      } else {
        notice.value = '批量创建失败，请检查用户名格式和网络连接'
        noticeType.value = 'error'
      }
      
    } catch (error) {
      console.error('批量创建用户失败:', error)
      notice.value = '批量创建失败：' + error.message
      noticeType.value = 'error'
    } finally {
      batchCreating.value = false
    }
  }
  ```

#### 🔧 批量创建域名修复
- **问题描述**：修复批量创建用户时邮箱域名使用localhost的问题。
- **技术实现**：
  ```javascript
  // 获取本地域名
  const getLocalDomain = () => {
    // 尝试从系统设置获取域名
    const domains = systemSettings.value.mail?.domains || []
    if (domains.length > 0) {
      return domains[0].name
    }
    
    // 备用方案：使用默认域名
    return 'xmskills.com'
  }
  
  // 在批量创建时使用正确的域名
  const localDomain = getLocalDomain()
  const email = `${username}@${localDomain}`
  ```

#### 🔐 批量创建认证修复
- **问题描述**：修复批量创建用户时的API认证问题。
- **技术实现**：
  ```javascript
  // 确保所有API调用都包含认证头
  const response = await axios.post('/api/ops', {
    action: 'app-register',
    params: {
      username: username,
      email: email,
      password: userPassword
    }
  }, { headers: authHeader() }) // 添加认证头
  ```

#### 📊 批量创建结果展示
- **功能描述**：新增详细的批量创建结果展示，显示每个用户的创建状态、邮箱地址和密码信息。
- **技术实现**：
  ```html
  <!-- 批量创建结果展示 -->
  <div v-if="batchCreateResults.length > 0" class="mt-4 space-y-2">
    <h5 class="text-sm font-medium text-gray-900">创建结果</h5>
    <div class="space-y-2 max-h-48 overflow-y-auto">
      <div v-for="result in batchCreateResults" :key="result.username" 
           class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
        <div class="flex-1">
          <div class="flex items-center space-x-2">
            <span class="font-medium text-gray-900">{{ result.username }}</span>
            <span class="text-sm text-gray-500">{{ result.email }}</span>
          </div>
          <div class="text-sm text-gray-600">密码: {{ result.password }}</div>
        </div>
        <div class="flex items-center space-x-2">
          <span v-if="result.success" class="text-green-600 text-sm">✓ 成功</span>
          <span v-else class="text-red-600 text-sm">✗ {{ result.reason }}</span>
        </div>
      </div>
    </div>
  </div>
  ```

## V2.9.0 (2025-10-26) - DNS配置系统全面优化

### 📋 更新内容

#### 🌐 DNS配置系统全面优化
- **问题描述**：DNS配置中使用了硬编码的IP地址 `192.168.33.193`，无法自动获取真实的服务器IP地址，导致DNS配置不准确。
- **解决方案**：
  - 修复 `/api/system-status` API，添加服务器IP获取逻辑
  - 使用多种方法获取服务器IP：`hostname -I`、`ip route get`、`ip addr show`
  - 修改前端 `getServerIP()` 函数，移除硬编码默认值
  - 添加备用IP获取方法，从系统设置API获取IP
- **技术实现**：
  ```javascript
  // 后端API增强
  let serverIP = null
  try {
    const hostIp = execSync("hostname -I | awk '{print $1}'", { encoding: 'utf8', timeout: 3000 }).trim()
    if (hostIp && !hostIp.includes('127.0.0.1')) {
      serverIP = hostIp
    }
  } catch (_) {}
  
  // 前端IP获取优化
  async function getServerIP() {
    try {
      const response = await fetch('/api/system-status')
      const data = await response.json()
      if (data.success && data.data?.systemInfo?.serverIP) {
        return data.data.systemInfo.serverIP
      }
    } catch (error) {
      return await getServerIPFallback()
    }
  }
  ```

#### 🔍 DNS健康检查增强
- **问题描述**：DNS健康检查查询缓存的DNS记录，显示错误的IP地址，无法准确反映DNS配置状态。
- **解决方案**：
  - 修改DNS测试函数，明确查询本地Bind DNS服务器
  - 增强DNS健康检查，提供详细的调试信息
  - 添加DNS缓存清理和等待机制
- **技术实现**：
  ```bash
  # DNS测试函数修复
  local a_record=$(dig @127.0.0.1 +short A $domain)
  
  # DNS健康检查增强
  local a_record_result=$(dig @$server_ip $domain A +short)
  if echo "$a_record_result" | grep -q "$server_ip"; then
    log_success "A记录检查通过"
  else
    log_warning "A记录检查失败"
    log_info "A记录查询结果: $a_record_result"
    log_info "期望的IP: $server_ip"
  fi
  ```

#### 📁 DNS Zone文件管理优化
- **问题描述**：DNS zone文件创建后没有立即重新加载，导致新的IP地址无法立即生效。
- **解决方案**：
  - 在zone文件创建后立即重新加载DNS服务
  - DNS服务启动后强制重新加载所有zone文件
  - 使用 `systemctl reload named` 和 `rndc reload` 双重保障
- **技术实现**：
  ```bash
  # Zone文件创建后立即重新加载
  systemctl reload named 2>/dev/null || systemctl restart named
  
  # DNS服务启动后强制重新加载
  systemctl reload named
  sleep 2
  rndc reload 2>/dev/null || true
  ```

#### 👤 用户邮箱验证系统完善
- **问题描述**：当用户未在邮件系统中注册时，系统返回误导性的"域名 localhost 未在系统允许的邮件域名列表中"错误。
- **解决方案**：
  - 修复 `/api/user-email` API，当用户不存在时返回明确的错误信息
  - 修改前端 `getCurrentUserEmail()` 函数，提供更好的错误处理
  - 在邮件发送前验证用户邮箱是否获取成功
- **技术实现**：
  ```javascript
  // 后端API修复
  res.status(404).json({
    success: false,
    error: '用户邮箱未找到',
    message: '用户未在邮件系统中注册'
  })
  
  // 前端错误处理
  if (!userEmail) {
    notice.value = '无法获取用户邮箱地址，请确保您已在邮件系统中注册'
    noticeType.value = 'error'
    return
  }
  ```

#### 🎨 版权信息图标更新
- **问题描述**：所有页面的版权信息使用√图标，不够专业。
- **解决方案**：将所有页面的版权信息图标从√改为字母"C"。
- **技术实现**：
  ```html
  <svg class="w-4 h-4 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
    <path d="M10 2C5.58 2 2 5.58 2 10s3.58 8 8 8 8-3.58 8-8-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/>
    <text x="10" y="14" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" font-weight="bold">C</text>
  </svg>
  ```

#### 🛡️ 智能垃圾邮件过滤系统
- **问题描述**：系统缺乏有效的垃圾邮件过滤机制，无法阻止垃圾邮件和违禁内容的发送。
- **解决方案**：实现完整的垃圾邮件过滤系统，包括多维度检测和实时阻止功能。
- **技术实现**：
  - 关键词检测：支持中英文关键词匹配，可配置违禁词汇
  - 域名黑名单：检查发件人和收件人域名，阻止黑名单域名
  - 内容规则过滤：检测邮件内容特征，如行数、大写比例、特殊字符等
  - 垃圾邮件评分：根据违规类型计算评分，提供量化评估

##### 技术实现细节

**后端垃圾邮件检测API (backend/dispatcher/server.js)**：
```javascript
// 垃圾邮件检测函数
function checkSpamContent(subject, content, from, to, spamConfig) {
  const violations = []
  const detectedKeywords = []
  let spamScore = 0
  
  // 检查关键词
  const allKeywords = [...(spamConfig.keywords.chinese || []), ...(spamConfig.keywords.english || [])]
  const fullText = `${subject || ''} ${content || ''}`.toLowerCase()
  
  for (const keyword of allKeywords) {
    if (fullText.includes(keyword.toLowerCase())) {
      detectedKeywords.push(keyword)
      spamScore += 10
    }
  }
  
  // 检查域名黑名单
  const fromDomain = from ? from.split('@')[1] : ''
  const toDomain = to ? to.split('@')[1] : ''
  
  if (spamConfig.domainBlacklist.includes(fromDomain)) {
    violations.push({
      type: 'domain_blacklist',
      message: `发件人域名在黑名单中: ${fromDomain}`,
      domain: fromDomain
    })
    spamScore += 50
  }
  
  // 检查内容规则
  if (content) {
    const lines = content.split('\n').filter(line => line.trim().length > 0)
    
    // 检查最小行数
    if (lines.length < spamConfig.rules.minContentLines) {
      violations.push({
        type: 'content_rules',
        message: `邮件内容行数不足 (${lines.length}/${spamConfig.rules.minContentLines})`,
        current: lines.length,
        required: spamConfig.rules.minContentLines
      })
      spamScore += 5
    }
    
    // 检查大写字母比例、感叹号数量、特殊字符数量...
  }
  
  return {
    isSpam: violations.length > 0,
    spamScore,
    violations,
    detectedKeywords,
    summary: violations.length > 0 ? 
      `检测到 ${violations.length} 项违规，垃圾邮件评分: ${spamScore}` : 
      '邮件内容正常'
  }
}
```

**前端垃圾邮件过滤配置界面 (frontend/src/components/Layout.vue)**：
```vue
<!-- 垃圾邮件过滤配置对话框 -->
<div v-if="showSpamFilterDialog" class="fixed inset-0 z-50 overflow-y-auto">
  <!-- 关键词管理 -->
  <div class="bg-gradient-to-br from-orange-50 to-red-50 p-6 rounded-xl border border-orange-200">
    <h4 class="ml-3 text-lg font-semibold text-gray-900">关键词管理</h4>
    
    <!-- 添加关键词 -->
    <div class="flex items-center space-x-2">
      <input v-model="newSpamKeyword" type="text" placeholder="输入垃圾邮件关键词" class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500">
      <select v-model="newSpamKeywordLang" class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500">
        <option value="cn">中文</option>
        <option value="en">英文</option>
      </select>
      <button @click="addSpamKeyword" class="px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-700">添加</button>
    </div>
  </div>
  
  <!-- 域名黑名单管理 -->
  <div class="bg-gradient-to-br from-red-50 to-pink-50 p-6 rounded-xl border border-red-200">
    <h4 class="ml-3 text-lg font-semibold text-gray-900">域名黑名单</h4>
    
    <!-- 添加域名 -->
    <div class="flex items-center space-x-2">
      <input v-model="newSpamDomain" type="text" placeholder="输入垃圾邮件域名" class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500">
      <button @click="addSpamDomain" class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700">添加</button>
    </div>
  </div>
  
  <!-- 过滤规则配置 -->
  <div class="bg-gradient-to-br from-blue-50 to-cyan-50 p-6 rounded-xl border border-blue-200">
    <h4 class="ml-3 text-lg font-semibold text-gray-900">过滤规则配置</h4>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">最小邮件内容行数</label>
        <input v-model.number="spamFilterConfig.minBodyLines" type="number" min="1" max="10" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
      </div>
      
      <div>
        <label class="block text-sm font-medium text-gray-700 mb-1">大写字母比例阈值</label>
        <input v-model.number="spamFilterConfig.maxCapsRatio" type="number" min="0" max="1" step="0.1" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
      </div>
    </div>
  </div>
</div>
```

#### 🔒 域名管理功能完善
- **问题描述**：删除域名后，用户仍能使用该域名发送邮件，域名管理功能不完善。
- **解决方案**：实现域名删除时的Postfix配置自动更新和邮件发送时的域名验证。
- **技术实现**：
  - 域名删除时自动更新Postfix配置
  - 邮件发送时验证发件人和收件人域名
  - 提供详细的错误提示和用户反馈

**技术实现细节**：

**域名删除时Postfix配置更新 (backend/scripts/mail_db.sh)**：
```bash
# 删除域名
delete_domain() {
  local domain_id="$1"
  
  # 获取域名名称（用于Postfix配置更新）
  local domain_name=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "SELECT name FROM virtual_domains WHERE id='$domain_id';" 2>/dev/null)
  
  # 删除域名
  mysql_connect "DELETE FROM virtual_domains WHERE id='$domain_id';"
  
  if [[ $? -eq 0 ]]; then
    log "域名 $domain_id ($domain_name) 删除成功"
    
    # 更新Postfix配置
    if [[ -n "$domain_name" ]]; then
      log "更新Postfix配置，移除域名: $domain_name"
      
      # 重新生成virtual_mailbox_domains配置
      update_postfix_domains
      
      # 重新加载Postfix配置
      systemctl reload postfix
      
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

# 更新Postfix域名配置
update_postfix_domains() {
  log "更新Postfix域名配置"
  
  # 获取所有活跃域名
  local domains_query="SELECT name FROM virtual_domains ORDER BY name;"
  local domains=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$(cat "$DB_PASS_FILE")" "$DB_NAME" -s -r -e "$domains_query" 2>/dev/null)
  
  if [[ -n "$domains" ]]; then
    # 创建域名列表文件
    local domains_file="/etc/postfix/virtual_mailbox_domains"
    echo "# 邮件域名列表 - 自动生成于 $(date)" > "$domains_file"
    echo "$domains" | while read -r domain; do
      if [[ -n "$domain" ]]; then
        echo "$domain" >> "$domains_file"
        log "添加域名到Postfix配置: $domain"
      fi
    done
    
    # 更新Postfix主配置
    postconf -e "virtual_mailbox_domains = $domains_file"
    log "Postfix域名配置已更新"
  else
    log "警告: 没有找到任何域名，Postfix配置可能不完整"
  fi
}
```

**邮件发送域名验证 (backend/dispatcher/server.js)**：
```javascript
// 域名验证
try {
  // 验证发件人域名是否在允许列表中
  const fromDomain = from ? from.split('@')[1] : user.split('@')[1]
  const toDomain = to.split('@')[1]
  
  // 检查发件人域名
  const fromDomainCheck = execSync(`mysql -u mailuser -pmailpass maildb -s -r -e "SELECT COUNT(*) FROM virtual_domains WHERE name='${fromDomain}';"`, { encoding: 'utf8', timeout: 3000 }).trim()
  
  if (fromDomainCheck === '0') {
    const domainLogLine = `[${timestamp}] [DOMAIN_REJECTED] User: ${user}, From: ${from || user}, Domain: ${fromDomain}, Reason: 发件人域名不在允许列表中, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), domainLogLine)
    
    return res.status(400).json({
      success: false,
      error: '发件人域名不在允许列表中',
      domainCheck: {
        fromDomain: fromDomain,
        allowed: false,
        message: `域名 ${fromDomain} 未在系统允许的邮件域名列表中`
      }
    })
  }
  
  // 检查收件人域名
  const toDomainCheck = execSync(`mysql -u mailuser -pmailpass maildb -s -r -e "SELECT COUNT(*) FROM virtual_domains WHERE name='${toDomain}';"`, { encoding: 'utf8', timeout: 3000 }).trim()
  
  if (toDomainCheck === '0') {
    const domainLogLine = `[${timestamp}] [DOMAIN_REJECTED] User: ${user}, To: ${to}, Domain: ${toDomain}, Reason: 收件人域名不在允许列表中, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), domainLogLine)
    
    return res.status(400).json({
      success: false,
      error: '收件人域名不在允许列表中',
      domainCheck: {
        toDomain: toDomain,
        allowed: false,
        message: `域名 ${toDomain} 未在系统允许的邮件域名列表中`
      }
    })
  }
  
  console.log(`域名验证通过: 发件人域名 ${fromDomain}, 收件人域名 ${toDomain}`)
} catch (domainError) {
  console.error('域名验证失败:', domainError)
  // 如果域名验证失败，记录错误但继续发送邮件
  const errorLogLine = `[${timestamp}] [DOMAIN_CHECK_ERROR] User: ${user}, Error: ${domainError.message}, IP: ${clientIP}\n`
  fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), errorLogLine)
}
```

#### 💬 用户友好的错误提示
- **问题描述**：邮件发送失败时，用户收到的错误提示不够详细，无法了解具体的失败原因。
- **解决方案**：实现分类错误提示，区分域名验证错误、垃圾邮件检测错误和其他错误。
- **技术实现**：
  - 域名验证错误：显示具体的域名和允许列表信息
  - 垃圾邮件检测错误：显示违规详情和违禁关键词
  - 其他错误：显示通用错误信息

**前端错误处理优化 (frontend/src/modules/Mail.vue)**：
```javascript
// 处理不同类型的错误
if (data.domainCheck) {
  // 域名验证错误
  notice.value = `域名验证失败：${data.domainCheck.message}`
  noticeType.value = 'error'
  
  userLogger.logMailOperation('send_failed', {
    to: to.value,
    reason: 'domain_check_failed',
    domain: data.domainCheck.fromDomain || data.domainCheck.toDomain
  })
} else if (data.spamDetection) {
  // 垃圾邮件检测错误
  const violations = data.spamDetection.violations
  const keywords = data.spamDetection.detectedKeywords
  let violationMessages = violations.map(v => v.message).join('\n')
  let keywordMessage = keywords.length > 0 ? `\n检测到的违禁关键词: ${keywords.join(', ')}` : ''
  
  notice.value = `邮件被垃圾邮件过滤器阻止！\n\n违规详情:\n${violationMessages}${keywordMessage}\n\n垃圾邮件评分: ${data.spamDetection.spamScore}\n\n请修改邮件内容后重试。`
  noticeType.value = 'error'
  
  userLogger.logMailOperation('send_failed', {
    to: to.value,
    reason: 'spam_detected',
    spamScore: data.spamDetection.spamScore
  })
} else {
  // 其他错误
  notice.value = data.error || '邮件发送失败'
  noticeType.value = 'error'
  
  userLogger.logMailOperation('send_failed', {
    to: to.value,
    reason: data.error || 'unknown_error'
  })
}
```

### 🚀 升级步骤

#### 自动升级（推荐）
```bash
# 执行自动升级脚本
sudo bash /bash/start.sh upgrade
```

#### 手动升级
1. **备份当前配置**
   ```bash
   sudo cp -r /bash /bash_backup_$(date +%Y%m%d_%H%M%S)
   ```

2. **更新系统文件**
   ```bash
   # 更新后端文件
   sudo cp /bash/backend/dispatcher/server.js /bash/backend/dispatcher/server.js
   sudo cp /bash/backend/scripts/mail_db.sh /bash/backend/scripts/mail_db.sh
   
   # 更新前端文件
   sudo cp /bash/frontend/src/components/Layout.vue /bash/frontend/src/components/Layout.vue
   sudo cp /bash/frontend/src/modules/Mail.vue /bash/frontend/src/modules/Mail.vue
   ```

3. **重启服务**
   ```bash
   sudo systemctl restart mail-ops-dispatcher
   sudo systemctl restart httpd
   ```

### ⚠️ 注意事项

1. **垃圾邮件过滤配置**：升级后需要配置垃圾邮件过滤规则，建议先测试过滤功能。
2. **域名管理**：删除域名后会自动更新Postfix配置，请确保域名删除操作的正确性。
3. **配置文件权限**：确保垃圾邮件过滤配置文件有正确的权限设置。

### 🔍 验证升级

1. **检查垃圾邮件过滤功能**
   - 登录管理界面
   - 进入系统设置 → 垃圾邮件过滤
   - 配置关键词和过滤规则
   - 测试过滤功能

2. **检查域名管理功能**
   - 删除一个测试域名
   - 尝试使用该域名发送邮件
   - 验证是否被正确阻止

3. **检查邮件发送功能**
   - 发送正常邮件
   - 发送包含违禁关键词的邮件
   - 验证错误提示是否详细

---

## 历史版本更新记录

## V2.8.9 (2025-10-22) - 用户管理功能修复和API优化

### 🎯 版本亮点
- **用户管理功能修复**：修复了用户管理界面无法正确显示用户列表的问题。
- **API响应处理优化**：优化了后端API的响应处理逻辑，确保前端能正确解析用户数据。
- **前端数据解析增强**：增强了前端对用户数据的解析能力，支持更复杂的用户数据结构。
- **后端JSON解析改进**：改进了后端脚本的JSON输出格式，确保数据的一致性。
- **用户体验提升**：优化了用户管理界面的加载速度和显示效果。

### 📋 更新内容

#### 👥 用户管理功能修复
- **问题描述**：用户管理界面无法正确显示用户列表，用户数据解析失败。
- **技术实现**：
  ```javascript
  // 用户数据解析优化
  const parseUserData = (data) => {
    try {
      if (Array.isArray(data)) {
        return data.map(user => ({
          id: user.id || user.username,
          username: user.username,
          email: user.email,
          created_at: user.created_at,
          type: user.username === 'xm' ? '管理员' : '普通用户'
        }))
      }
      return []
    } catch (error) {
      console.error('用户数据解析失败:', error)
      return []
    }
  }
  ```

#### 🔧 API响应处理优化
- **功能描述**：优化了后端API的响应处理逻辑，确保数据格式的一致性。
- **技术实现**：
  ```javascript
  // 后端API响应优化
  app.post('/api/ops', auth, (req, res) => {
    // ... 处理逻辑 ...
    
    // 特殊处理：query-users操作
    if (action === 'query-users') {
      setTimeout(() => {
        try {
          const logFile = path.join(LOG_DIR, `${opId}.log`)
          if (fs.existsSync(logFile)) {
            const logContent = fs.readFileSync(logFile, 'utf8')
            const lines = logContent.split('\n')
            
            // 查找JSON数据行
            for (const line of lines) {
              const trimmedLine = line.trim()
              if ((trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) || 
                  (trimmedLine.startsWith('{') && trimmedLine.endsWith('}'))) {
                try {
                  const userData = JSON.parse(trimmedLine)
                  res.json({ success: true, users: userData })
                  return
                } catch (e) {
                  continue
                }
              }
            }
          }
          res.json({ success: true, opId })
        } catch (error) {
          console.error('Query-users response error:', error)
          res.json({ success: true, opId })
        }
      }, 1000)
    }
  })
  ```

## V2.8.8 (2025-10-22) - 系统设置自动探测和智能填充

### 🎯 版本亮点
- **系统设置自动探测**：实现了系统设置的自动探测功能，系统启动时自动获取服务器IP、域名、管理员邮箱等信息。
- **DNS配置智能填充**：DNS配置界面会自动填充检测到的服务器信息，减少手动配置的工作量。
- **管理员邮箱自动获取**：从数据库中自动获取管理员邮箱地址，无需手动设置。
- **服务器IP动态获取**：自动检测服务器的实际IP地址，避免硬编码IP地址的问题。
- **域名自动探测**：自动探测系统域名，提供更准确的DNS配置。

### 📋 更新内容

#### 🔍 系统设置自动探测
- **功能描述**：系统启动时自动探测服务器配置信息，减少手动配置的工作量。
- **技术实现**：
  ```javascript
  // 自动探测系统配置
  const autoDetectSystemConfig = async () => {
    try {
      // 获取服务器IP
      const serverIP = await getServerIP()
      
      // 获取管理员邮箱
      const adminEmail = await getAdminEmail()
      
      // 获取系统域名
      const systemDomain = await getSystemDomain()
      
      // 自动填充配置
      systemSettings.value.dns.bind.serverIp = serverIP
      systemSettings.value.general.adminEmail = adminEmail
      systemSettings.value.dns.bind.domain = systemDomain
      
    } catch (error) {
      console.error('自动探测系统配置失败:', error)
    }
  }
  ```

#### 🎯 DNS配置智能填充
- **功能描述**：DNS配置界面会自动填充检测到的服务器信息。
- **技术实现**：
  ```javascript
  // DNS配置智能填充
  const fillDnsConfig = () => {
    if (systemSettings.value.dns.bind.serverIp) {
      dnsSettings.value.serverIp = systemSettings.value.dns.bind.serverIp
    }
    
    if (systemSettings.value.dns.bind.adminEmail) {
      dnsSettings.value.adminEmail = systemSettings.value.dns.bind.adminEmail
    }
    
    if (systemSettings.value.dns.bind.domain) {
      dnsSettings.value.domain = systemSettings.value.dns.bind.domain
    }
  }
  ```

## V2.8.7 (2025-10-22) - 智能垃圾邮件过滤系统和域名管理完善

### 🎯 版本亮点
- **智能垃圾邮件过滤系统**：实现完整的垃圾邮件过滤功能，包括关键词检测、域名黑名单、内容规则过滤，支持中英文关键词管理和实时检测。
- **域名管理功能完善**：修复域名删除后邮件仍能发送的问题，实现域名删除时自动更新Postfix配置，确保域名管理的有效性。
- **邮件发送域名验证**：新增邮件发送时的域名验证机制，检查发件人和收件人域名是否在允许列表中，有效防止未授权域名的邮件发送。
- **垃圾邮件过滤配置管理**：提供完整的垃圾邮件过滤配置界面，支持关键词管理、域名黑名单配置、过滤规则设置和实时测试功能。
- **用户友好的错误提示**：优化邮件发送错误提示，区分域名验证错误、垃圾邮件检测错误和其他错误，提供详细的错误信息和修改建议。
- **Postfix配置自动同步**：实现域名变更时Postfix配置的自动更新和重载，确保邮件服务器配置的实时同步。

### 📋 更新内容

#### 🛡️ 智能垃圾邮件过滤系统
- **功能描述**：实现完整的垃圾邮件过滤功能，包括关键词检测、域名黑名单、内容规则过滤。
- **技术实现**：
  ```javascript
  // 垃圾邮件检测API
  app.post('/api/spam-filter/check', auth, (req, res) => {
    try {
      const { content, from, to } = req.body
      
      // 检查关键词
      const keywordResult = checkKeywords(content)
      if (keywordResult.isSpam) {
        return res.json({
          success: true,
          isSpam: true,
          reason: '检测到禁用关键词',
          details: keywordResult.details
        })
      }
      
      // 检查域名黑名单
      const domainResult = checkDomainBlacklist(from, to)
      if (domainResult.isSpam) {
        return res.json({
          success: true,
          isSpam: true,
          reason: '发件人或收件人域名在黑名单中',
          details: domainResult.details
        })
      }
      
      // 检查内容规则
      const contentResult = checkContentRules(content)
      if (contentResult.isSpam) {
        return res.json({
          success: true,
          isSpam: true,
          reason: '邮件内容不符合规则',
          details: contentResult.details
        })
      }
      
      res.json({ success: true, isSpam: false })
    } catch (error) {
      res.status(500).json({ success: false, error: error.message })
    }
  })
  ```

#### 🔧 域名管理功能完善
- **问题描述**：修复域名删除后邮件仍能发送的问题。
- **技术实现**：
  ```bash
  # 域名删除时更新Postfix配置
  delete_domain() {
    local domain="$1"
    
    # 从数据库删除域名
    mysql -u mailuser -pmailpass maildb -e "DELETE FROM virtual_domains WHERE name='$domain';"
    
    # 更新Postfix配置
    update_postfix_domains
    
    # 重新加载Postfix
    systemctl reload postfix
  }
  
  update_postfix_domains() {
    # 获取所有域名
    local domains=$(mysql -u mailuser -pmailpass maildb -s -e "SELECT name FROM virtual_domains;")
    
    # 更新Postfix配置
    echo "$domains" > /etc/postfix/virtual_mailbox_domains
    postmap /etc/postfix/virtual_mailbox_domains
  }
  ```

## V2.8.6 (2025-10-22) - DNS配置系统全面优化

### 🎯 版本亮点
- **DNS配置系统全面优化**：完全重构DNS配置系统，移除所有公网DNS配置选项，专注于本地Bind DNS服务器配置，提供更简洁和专业的DNS管理体验。
- **DNS配置实时同步修复**：修复了DNS配置修改后无法正确同步到系统的问题，现在DNS配置修改会立即生效并正确更新`/etc/resolv.conf`文件。
- **DNS健康度检测增强**：新增完整的DNS健康度检测系统，包括MX记录、A记录、PTR记录、SPF记录、DKIM记录、DMARC记录的全面检测和健康度评分。
- **DNS配置持久化**：实现DNS配置的持久化存储，防止NetworkManager自动覆盖DNS设置，确保DNS配置的稳定性。
- **DNS解析测试优化**：优化DNS解析测试功能，修复了dig命令语法错误和resolv.conf解析失败的问题，提供准确的DNS状态检测。
- **用户操作日志增强**：大幅增强用户操作日志系统，新增日志分类、操作类型过滤、详细操作记录和可视化日志展示功能。

## V2.8.5 (2025-10-21) - 用户删除功能完善

### 🎯 版本亮点
- **用户删除功能完善**：修复了用户删除操作只删除`mailapp`数据库用户而不删除`maildb`数据库用户的问题，现在删除用户会同时清理两个数据库中的用户记录。
- **删除确认弹窗优化**：替换原生简陋的`confirm`弹窗为现代化美观的自定义弹窗，提供更好的用户体验和操作安全性。
- **数据库同步删除**：用户删除时自动同步删除`maildb.mail_users`表中的用户记录，确保数据一致性。
- **邮件记录清理**：删除用户时自动清理该用户的所有邮件记录，包括收件箱和发件箱中的邮件。
- **删除操作安全性**：新增删除确认弹窗，显示用户详细信息，提供重要提醒，防止误删操作。

### 📋 更新内容

#### 👥 用户删除功能完善
- **问题描述**：用户删除操作只删除`mailapp`数据库用户而不删除`maildb`数据库用户，导致数据不一致。
- **技术实现**：
  ```bash
  # app_user.sh 中的 delete_user 函数
  delete_user() {
    local username="$1"
    
    # 删除应用用户
    mysql_q "DELETE FROM app_users WHERE username='$username';"
    
    # 同时删除邮件用户
    mysql -u mailuser -pmailpass maildb -e "DELETE FROM mail_users WHERE username='$username';"
    
    # 清理邮件记录
    mysql -u mailuser -pmailpass maildb -e "DELETE FROM emails WHERE sender='$username' OR recipient='$username';"
  }
  ```

#### 🎨 删除确认弹窗优化
- **功能描述**：替换原生简陋的`confirm`弹窗为现代化美观的自定义弹窗。
- **技术实现**：
  ```html
  <!-- 删除确认弹窗 -->
  <div v-if="showDeleteConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
      <div class="flex items-center mb-4">
        <div class="flex-shrink-0 w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
          <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-lg font-medium text-gray-900">确认删除用户</h3>
        </div>
      </div>
      
      <div class="mb-4">
        <p class="text-sm text-gray-500">您确定要删除用户 <span class="font-medium text-gray-900">{{ userToDelete.username }}</span> 吗？</p>
        <p class="text-sm text-gray-500 mt-1">此操作将永久删除该用户及其所有邮件记录，且无法撤销。</p>
      </div>
      
      <div class="flex justify-end space-x-3">
        <button @click="showDeleteConfirm = false" 
                class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
          取消
        </button>
        <button @click="confirmDeleteUser" 
                :disabled="deletingUser"
                class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed">
          <span v-if="deletingUser">删除中...</span>
          <span v-else>确认删除</span>
        </button>
      </div>
    </div>
  </div>
  ```

## V2.8.4 (2025-10-21) - 邮件发送发件人地址修复

### 🎯 版本亮点
- **邮件发送发件人地址修复**：修复了邮件发送时发件人地址不正确的问题，现在系统会使用用户的真实邮箱地址作为发件人。
- **前端动态邮箱获取**：实现了前端动态获取用户邮箱地址的功能，确保发件人地址的准确性。
- **后端用户邮箱查询API**：新增了专门的用户邮箱查询API，支持从`maildb`数据库获取用户的真实邮箱地址。
- **邮件发送逻辑优化**：优化了邮件发送的整体逻辑，确保发件人地址的正确性和一致性。
- **数据库同步验证**：实现了发件人地址与数据库的同步验证，确保邮件发送的准确性。

### 📋 更新内容

#### 📧 邮件发送发件人地址修复
- **问题描述**：修复了邮件发送时发件人地址显示为`test2@xmskills.com`而不是`test2@test.com`的问题。
- **技术实现**：
  ```javascript
  // 前端动态获取用户邮箱
  async function getCurrentUserEmail() {
    try {
      const response = await axios.get('/api/user-email', {
        headers: authHeader()
      })
      
      if (response.data.success) {
        return response.data.email
      } else {
        return null
      }
    } catch (error) {
      console.error('获取用户邮箱失败:', error)
      return null
    }
  }
  
  // 邮件发送时使用真实邮箱
  async function sendEmail() {
    const userEmail = await getCurrentUserEmail()
    if (!userEmail) {
      notice.value = '无法获取用户邮箱地址，请确保您已在邮件系统中注册'
      noticeType.value = 'error'
      return
    }
    
    // 使用真实邮箱作为发件人
    const mailOptions = {
      from: userEmail,
      to: to.value,
      subject: subject.value,
      text: body.value
    }
  }
  ```

## V2.8.3 (2025-10-21) - DNS配置实时同步功能

### 🎯 版本亮点
- **DNS配置实时同步**：实现了DNS配置的前后端实时同步功能，用户在前端修改任何DNS配置字段时，都会立即同步到后端并应用到系统中。
- **前端Bind DNS配置参数实时保存**：优化了前端DNS配置界面，所有DNS参数修改都会立即保存到后端。
- **配置状态指示器**：新增了DNS配置状态的实时指示器，显示配置保存和应用的进度。
- **移除公网DNS配置选项**：简化了DNS配置界面，移除了公网DNS配置选项，专注于本地Bind DNS服务器配置。
- **优化DNS配置用户体验**：提供了更直观的DNS配置体验，包括实时状态反馈和配置验证。

### 📋 更新内容

#### 🔄 DNS配置实时同步
- **功能描述**：实现了DNS配置的前后端实时同步功能，用户修改配置后立即生效。
- **技术实现**：
  ```javascript
  // 前端DNS配置实时保存
  const saveDnsSettings = async () => {
    try {
      dnsSaving.value = true
      
      const response = await axios.post('/api/dns/configure', {
        domain: dnsSettings.value.domain,
        serverIp: dnsSettings.value.serverIp,
        adminEmail: dnsSettings.value.adminEmail,
        enableRecursion: dnsSettings.value.enableRecursion,
        enableForwarding: dnsSettings.value.enableForwarding,
        upstreamDns: dnsSettings.value.upstreamDns
      }, { headers: authHeader() })
      
      if (response.data.success) {
        notice.value = 'DNS配置已保存并应用'
        noticeType.value = 'success'
      }
    } catch (error) {
      notice.value = 'DNS配置保存失败：' + error.message
      noticeType.value = 'error'
    } finally {
      dnsSaving.value = false
    }
  }
  ```

## V2.8.2 (2025-10-21) - 域名管理功能完善

### 🎯 版本亮点
- **域名管理功能完善**：修复了域名列表从数据库正确加载的问题，确保前端显示的域名与数据库保持同步。
- **删除确认弹窗优化**：替换原生简陋的`confirm`弹窗为现代化美观的自定义弹窗，提供更好的用户体验。
- **后端脚本路径修复**：修复了后端服务器中`mail_db.sh`脚本路径错误的问题，确保域名管理API能正确调用后端脚本。
- **域名删除功能增强**：完善了域名删除的后端处理逻辑，确保删除操作能正确执行并同步到数据库。
- **UI/UX体验提升**：优化了删除确认弹窗的视觉设计，包含警告图标、域名高亮显示、重要提醒和加载状态等现代化元素。

### 📋 更新内容

#### 🌐 域名管理功能完善
- **问题描述**：修复了域名列表从数据库正确加载的问题，确保前端显示的域名与数据库保持同步。
- **技术实现**：
  ```javascript
  // 前端域名列表加载
  const loadDomains = async () => {
    try {
      const response = await axios.get('/api/system-settings', {
        headers: authHeader()
      })
      
      if (response.data.success) {
        const domains = response.data.settings.mail.domains || []
        systemSettings.value.mail.domains = domains
      }
    } catch (error) {
      console.error('加载域名列表失败:', error)
    }
  }
  ```

#### 🎨 删除确认弹窗优化
- **功能描述**：替换原生简陋的`confirm`弹窗为现代化美观的自定义弹窗。
- **技术实现**：
  ```html
  <!-- 域名删除确认弹窗 -->
  <div v-if="showDeleteDomainConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
    <div class="bg-white rounded-lg p-6 max-w-md w-full mx-4">
      <div class="flex items-center mb-4">
        <div class="flex-shrink-0 w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
          <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
        </div>
        <div class="ml-3">
          <h3 class="text-lg font-medium text-gray-900">确认删除域名</h3>
        </div>
      </div>
      
      <div class="mb-4">
        <p class="text-sm text-gray-500">您确定要删除域名 <span class="font-medium text-gray-900">{{ domainToDelete.name }}</span> 吗？</p>
        <p class="text-sm text-gray-500 mt-1">此操作将永久删除该域名，且无法撤销。</p>
      </div>
      
      <div class="flex justify-end space-x-3">
        <button @click="showDeleteDomainConfirm = false" 
                class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50">
          取消
        </button>
        <button @click="confirmDeleteDomain" 
                :disabled="deletingDomain"
                class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-md hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed">
          <span v-if="deletingDomain">删除中...</span>
          <span v-else>确认删除</span>
        </button>
      </div>
    </div>
  </div>
  ```

### 📋 更新内容

#### 🌐 DNS配置系统全面优化
- **问题描述**：DNS配置系统存在多个问题，包括公网DNS配置选项冗余、DNS配置无法正确同步到系统、resolv.conf文件格式错误等。
- **解决方案**：完全重构DNS配置系统，移除所有公网DNS配置选项，专注于本地Bind DNS服务器配置，修复DNS配置同步问题。
- **技术实现**：
  - 移除前端所有公网DNS相关UI元素和配置选项
  - 修复后端DNS配置脚本的参数传递和格式处理
  - 实现DNS配置的实时同步和持久化存储
  - 优化DNS健康度检测和解析测试功能

##### 技术实现细节

**前端修改 (frontend/src/components/Layout.vue)**：
```vue
// 移除公网DNS配置选项，只保留Bind DNS配置
const systemSettings = ref({
  dns: {
    bind: {
      domain: '',
      serverIp: '',
      adminEmail: '',
      enableRecursion: true,
      enableForwarding: true,
      upstreamDns: '8.8.8.8, 1.1.1.1'
    }
  }
})

// DNS配置实时保存
const saveDnsConfig = async () => {
  // 验证Bind配置
  if (!systemSettings.value.dns.bind.domain || 
      !systemSettings.value.dns.bind.serverIp || 
      !systemSettings.value.dns.bind.adminEmail) {
    settingsError.value = '请填写完整的Bind DNS配置信息'
    return
  }
  
  // 调用DNS配置API
  const dnsResponse = await fetch('/api/dns/configure', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
    },
    body: JSON.stringify({
      domain: systemSettings.value.dns.bind.domain,
      serverIp: systemSettings.value.dns.bind.serverIp,
      adminEmail: systemSettings.value.dns.bind.adminEmail,
      enableRecursion: systemSettings.value.dns.bind.enableRecursion,
      enableForwarding: systemSettings.value.dns.bind.enableForwarding,
      upstreamDns: systemSettings.value.dns.bind.upstreamDns
    })
  })
}
```

**后端修改 (backend/scripts/dns_setup.sh)**：
```bash
# 修复DNS配置脚本的参数传递和格式处理
configure_dns_pointing() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    
    log_info "配置DNS指向本地Bind DNS服务器..."
    
    # 移除resolv.conf的只读属性
    chattr -i /etc/resolv.conf 2>/dev/null || true
    
    # 创建新的resolv.conf配置
    cat > /etc/resolv.conf << EOF
# 本地Bind DNS服务器配置
nameserver $server_ip
nameserver 127.0.0.1
# 用户设置的上游DNS服务器
EOF
    
    # 添加上游DNS服务器
    if [[ -n "$upstream_dns" ]]; then
        # 使用数组来处理，避免子shell问题
        IFS=',' read -ra DNS_SERVERS <<< "$upstream_dns"
        for dns_server in "${DNS_SERVERS[@]}"; do
            # 清理空格和分号
            dns_server=$(echo "$dns_server" | sed 's/[; ]//g')
            if [[ -n "$dns_server" ]]; then
                echo "nameserver $dns_server" >> /etc/resolv.conf
            fi
        done
    fi
    
    log_success "DNS指向配置完成"
}
```

#### 📊 DNS健康度检测增强
- **新增功能**：实现完整的DNS健康度检测系统，包括MX记录、A记录、PTR记录、SPF记录、DKIM记录、DMARC记录的全面检测。
- **健康度评分**：根据检测结果计算DNS健康度百分比，提供直观的健康状态评估。
- **可视化展示**：在前端显示DNS健康度状态，包括健康度百分比、记录统计和详细状态信息。

**技术实现**：
```bash
# DNS健康检查函数
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
    
    # 检查A记录、PTR记录、SPF记录、DKIM记录、DMARC记录...
    
    # 计算健康度
    local health_percentage=$((passed_checks * 100 / total_checks))
    
    log_info "DNS健康检查完成: $passed_checks/$total_checks 项通过"
    log_info "DNS健康度: $health_percentage%"
    
    return $health_percentage
}
```

#### 🔧 DNS配置持久化
- **问题描述**：NetworkManager会自动覆盖手动修改的`/etc/resolv.conf`文件，导致DNS配置无法持久化。
- **解决方案**：实现DNS配置的持久化存储，包括NetworkManager配置、resolv.conf保护和DNS配置监控服务。

**技术实现**：
```bash
# 配置NetworkManager DNS设置
configure_networkmanager_dns() {
    local domain=$1
    local server_ip=$2
    local upstream_dns=$3
    
    # 创建NetworkManager DNS配置文件
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
}
```

#### 📝 用户操作日志增强
- **新增功能**：大幅增强用户操作日志系统，新增日志分类、操作类型过滤、详细操作记录和可视化日志展示功能。
- **日志分类**：支持按操作类型（用户操作、邮件操作、DNS配置、系统设置等）和操作分类（常规操作、邮件操作、DNS配置、系统设置、用户管理、安全操作、备份恢复、监控日志）进行过滤。
- **可视化展示**：提供丰富的日志展示界面，包括颜色编码、图标显示、分类标签等。

**技术实现**：
```javascript
// 后端日志记录增强
const logLine = `[${timestamp}] [USER_LOG] User: ${user}, Action: ${logEntry.action}, Category: ${logEntry.category || 'general'}, Details: ${JSON.stringify(logEntry.details || {})}, IP: ${clientIP}, UserAgent: ${req.headers['user-agent'] || 'unknown'}\n`
fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)

// 前端日志过滤和展示
const logCategories = ref([
  { value: '', label: '所有分类' },
  { value: 'general', label: '常规操作' },
  { value: 'mail', label: '邮件操作' },
  { value: 'dns', label: 'DNS配置' },
  { value: 'system', label: '系统设置' },
  { value: 'user', label: '用户管理' },
  { value: 'security', label: '安全操作' },
  { value: 'backup', label: '备份恢复' },
  { value: 'monitoring', label: '监控日志' }
])
```

### 🚀 升级步骤

#### 自动升级（推荐）
```bash
# 执行自动升级脚本
sudo bash /bash/start.sh upgrade
```

#### 手动升级
1. **备份当前配置**
   ```bash
   sudo cp -r /bash /bash_backup_$(date +%Y%m%d_%H%M%S)
   ```

2. **更新系统文件**
   ```bash
   # 更新DNS配置脚本
   sudo cp /bash/backend/scripts/dns_setup.sh /bash/backend/scripts/dns_setup.sh
   
   # 更新前端文件
   sudo cp /bash/frontend/src/components/Layout.vue /bash/frontend/src/components/Layout.vue
   sudo cp /bash/frontend/src/modules/Dashboard.vue /bash/frontend/src/modules/Dashboard.vue
   ```

3. **重启服务**
   ```bash
   sudo systemctl restart mail-ops-dispatcher
   sudo systemctl restart httpd
   ```

### ⚠️ 注意事项

1. **DNS配置备份**：升级前请备份当前DNS配置，升级后可能需要重新配置DNS设置。
2. **NetworkManager配置**：升级后NetworkManager可能会重置DNS配置，需要重新应用DNS设置。
3. **日志文件权限**：确保日志文件目录有正确的权限设置，避免日志记录失败。

### 🔍 验证升级

1. **检查DNS配置**
   ```bash
   # 检查resolv.conf文件格式
   cat /etc/resolv.conf
   
   # 测试DNS解析
   nslookup skills.com
   ```

2. **检查DNS健康度**
   - 登录管理界面
   - 进入系统设置 → DNS配置
   - 查看DNS健康度显示

3. **检查日志功能**
   - 进入日志查看器
   - 测试日志分类和过滤功能
   - 验证日志记录是否正常

---

## 历史版本更新记录

### V2.8.5 (2025-10-21) - 用户删除功能完善

### 🎯 版本亮点
- **用户删除功能完善**：修复了用户删除操作只删除`mailapp`数据库用户而不删除`maildb`数据库用户的问题，现在删除用户会同时清理两个数据库中的用户记录。
- **删除确认弹窗优化**：替换原生简陋的`confirm`弹窗为现代化美观的自定义弹窗，提供更好的用户体验和操作安全性。
- **数据库同步删除**：用户删除时自动同步删除`maildb.mail_users`表中的用户记录，确保数据一致性。
- **邮件记录清理**：删除用户时自动清理该用户的所有邮件记录，包括收件箱和发件箱中的邮件。
- **删除操作安全性**：新增删除确认弹窗，显示用户详细信息，提供重要提醒，防止误删操作。

### 📋 更新内容

#### 🔄 用户删除功能完善
- **问题描述**：修复了用户删除操作只删除`mailapp`数据库用户而不删除`maildb`数据库用户的问题，导致删除用户后邮件系统中仍然存在该用户。
- **数据库同步删除**：用户删除时自动同步删除`maildb.mail_users`表中的用户记录，确保数据一致性。
- **邮件记录清理**：删除用户时自动清理该用户的所有邮件记录，包括收件箱和发件箱中的邮件。
- **删除操作安全性**：新增删除确认弹窗，显示用户详细信息，提供重要提醒，防止误删操作。

##### 技术实现细节

**后端修改 (backend/scripts/app_user.sh)**：
```bash
delete_app_user() {
  local email="$1"
  echo "删除应用用户: $email" >&1
  
  # 检查用户是否存在
  local user_exists
  user_exists=$(mysql -u root -e "USE mailapp; SELECT COUNT(*) FROM app_users WHERE email='$email';" 2>/dev/null | tail -1)
  
  if [[ "$user_exists" -eq 0 ]]; then
    echo "用户不存在: $email" >&1
    return 1
  fi
  
  # 获取用户名，用于删除maildb中的用户
  local username
  username=$(mysql -u root -e "USE mailapp; SELECT username FROM app_users WHERE email='$email';" 2>/dev/null | tail -1)
  
  # 删除mailapp数据库中的用户
  mysql -u root -e "USE mailapp; DELETE FROM app_users WHERE email='$email';" 2>/dev/null
  
  if [[ $? -eq 0 ]]; then
    echo "应用用户已删除: $email" >&1
    
    # 同时删除maildb数据库中的用户
    if [[ -n "$username" ]]; then
      echo "同步删除邮件系统用户: $username" >&1
      mysql -u mailuser -pmailpass maildb -e "DELETE FROM mail_users WHERE username='$username';" 2>/dev/null || {
        echo "警告: 无法删除邮件系统用户 $username" >&2
      }
      
      # 删除用户的邮件记录
      echo "删除用户邮件记录: $username" >&1
      mysql -u mailuser -pmailpass maildb -e "DELETE FROM emails WHERE from_addr LIKE '%$username%' OR to_addr LIKE '%$username%';" 2>/dev/null || {
        echo "警告: 无法删除用户邮件记录" >&2
      }
    fi
    
    echo "用户完全删除成功: $email" >&1
  else
    echo "删除用户失败: $email" >&1
    return 1
  fi
}
```

**前端修改 (frontend/src/modules/Dashboard.vue)**：
```javascript
// 删除用户确认弹窗状态
const showDeleteUserConfirm = ref(false)
const userToDelete = ref<{username: string, email: string} | null>(null)

// 显示删除用户确认弹窗
function showDeleteUserDialog(username: string, userEmail: string) {
  userToDelete.value = { username, email: userEmail }
  showDeleteUserConfirm.value = true
}

// 取消删除用户
function cancelDeleteUser() {
  showDeleteUserConfirm.value = false
  userToDelete.value = null
}

// 确认删除用户
async function confirmDeleteUser() {
  if (!userToDelete.value) return
  
  const { username, email } = userToDelete.value
  console.log('用户确认删除，开始执行删除操作')
  
  showDeleteUserConfirm.value = false
  userToDelete.value = null
  
  // 执行删除操作...
}
```

**删除确认弹窗HTML模板**：
```html
<!-- 删除用户确认弹窗 -->
<div v-if="showDeleteUserConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="cancelDeleteUser">
  <div class="bg-white rounded-xl shadow-2xl max-w-md w-full mx-4 transform transition-all duration-300 scale-100" @click.stop>
    <!-- 弹窗头部 -->
    <div class="flex items-center justify-between p-6 border-b border-gray-200">
      <div class="flex items-center space-x-3">
        <div class="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
          <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
        </div>
        <div>
          <h3 class="text-lg font-semibold text-gray-900">删除用户确认</h3>
          <p class="text-sm text-gray-500">此操作不可撤销</p>
        </div>
      </div>
    </div>

    <!-- 弹窗内容 -->
    <div class="p-6">
      <div class="mb-4">
        <p class="text-gray-700 mb-2">您确定要删除以下用户吗？</p>
        <div class="bg-red-50 border border-red-200 rounded-lg p-3">
          <div class="flex items-center space-x-2">
            <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
            </svg>
            <div>
              <span class="font-medium text-red-800">{{ userToDelete?.username }}</span>
              <span class="text-red-600 ml-2">({{ userToDelete?.email }})</span>
            </div>
          </div>
        </div>
      </div>
      
      <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-4">
        <div class="flex items-start space-x-2">
          <svg class="w-5 h-5 text-yellow-600 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
          <div>
            <p class="text-sm text-yellow-800 font-medium">重要提醒</p>
            <p class="text-sm text-yellow-700 mt-1">删除后该用户的所有邮件数据将被永久删除，无法恢复。</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 弹窗底部按钮 -->
    <div class="flex items-center justify-end space-x-3 p-6 bg-gray-50 rounded-b-xl">
      <button @click="cancelDeleteUser" 
              class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors duration-200">
        取消
      </button>
      <button @click="confirmDeleteUser" 
              :disabled="loading"
              class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200">
        <svg v-if="loading" class="w-4 h-4 mr-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
        </svg>
        <svg v-else class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
        </svg>
        {{ loading ? '删除中...' : '确认删除' }}
      </button>
    </div>
  </div>
</div>
```

**问题解决流程**：
1. **问题识别**：用户删除操作只删除`mailapp.app_users`表中的用户，但`maildb.mail_users`表中的用户记录仍然存在
2. **根本原因**：`delete_app_user`函数只处理了`mailapp`数据库，没有同步删除`maildb`数据库中的用户记录
3. **解决方案**：修改删除函数，同时删除两个数据库中的用户记录和邮件记录
4. **用户体验优化**：添加现代化删除确认弹窗，提供更好的操作安全性

#### 🔄 邮件发送发件人地址修复
- **问题描述**：修复了邮件发送时发件人地址不正确的问题，之前`test2`用户发送邮件时显示为`test2@xmskills.com`而不是`test2@test.com`。
- **前端修复**：将`getCurrentUserEmail`函数改为异步函数，通过API从后端获取用户的真实邮箱地址。
- **后端API**：新增`/api/user-email`端点，支持查询当前登录用户在`maildb.mail_users`表中的真实邮箱地址。
- **邮件发送逻辑**：邮件发送时前端会先获取用户的真实邮箱地址，然后传递给后端，确保发件人地址的准确性。
- **数据库同步**：确保用户注册时同步到`maildb`数据库的邮箱地址能够正确用于邮件发送。

##### 技术实现细节

**前端修改 (frontend/src/modules/Mail.vue)**：
```javascript
// 获取当前用户的完整邮箱地址 - 改为异步函数
const getCurrentUserEmail = async () => {
  const username = currentUser.value
  if (!username) return 'unknown@localhost'
  
  // 管理员使用localhost
  if (username === 'xm') {
    return 'xm@localhost'
  } else {
    // 其他用户从后端获取真实邮箱地址
    try {
      const response = await fetch('/api/user-email', {
        method: 'GET',
        headers: {
          'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
        }
      })
      
      if (response.ok) {
        const data = await response.json()
        if (data.success && data.email) {
          return data.email
        }
      }
    } catch (error) {
      console.error('获取用户邮箱失败:', error)
    }
    
    // 如果获取失败，使用默认值
    return `${username}@localhost`
  }
}

// 发送邮件函数修改
async function sendEmail() {
  // ... 其他代码 ...
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const userEmail = await getCurrentUserEmail() // 异步获取用户邮箱
    const response = await fetch('/api/mail/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        to: to.value,
        cc: cc.value || (selectedCCUsers.value.length > 0 ? selectedCCUsers.value.map(user => user.email).join(', ') : ''),
        subject: subject.value,
        body: body.value,
        from: userEmail, // 使用获取到的真实邮箱地址
        attachments: await Promise.all(attachments.value.map(async file => ({
          name: file.name,
          size: file.size,
          type: file.type,
          content: await fileToBase64(file)
        })))
      })
    })
    // ... 其他代码 ...
  }
}
```

**后端API新增 (backend/dispatcher/server.js)**：
```javascript
// 获取用户邮箱地址
app.get('/api/user-email', auth, (req, res) => {
  try {
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 查询用户的真实邮箱地址
    try {
      const userEmailResult = execSync(`mysql -u mailuser -pmailpass maildb -s -r -e "SELECT email FROM mail_users WHERE username='${user}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      console.log(`查询用户 ${user} 邮箱结果: "${userEmailResult}"`)
      
      // 过滤掉表头，只取最后一行
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      
      if (email && email.includes('@')) {
        res.json({
          success: true,
          email: email
        })
      } else {
        // 如果查询失败，返回默认值
        const defaultEmail = user === 'xm' ? 'xm@localhost' : `${user}@localhost`
        res.json({
          success: true,
          email: defaultEmail
        })
      }
    } catch (error) {
      console.log('查询用户邮箱失败:', error.message)
      // 如果查询失败，返回默认值
      const defaultEmail = user === 'xm' ? 'xm@localhost' : `${user}@localhost`
      res.json({
        success: true,
        email: defaultEmail
      })
    }
  } catch (error) {
    console.error('获取用户邮箱失败:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get user email',
      message: error.message
    })
  }
})
```

**问题解决流程**：
1. **问题识别**：用户发送邮件时发件人地址显示为`test2@xmskills.com`而不是`test2@test.com`
2. **根本原因**：前端`getCurrentUserEmail`函数硬编码使用`xmskills.com`域名，没有从数据库获取用户的真实邮箱地址
3. **解决方案**：前端改为异步获取用户邮箱，后端新增API端点查询用户真实邮箱
4. **验证结果**：邮件发送时使用正确的发件人地址`test2@test.com`

#### 🔄 DNS配置实时同步功能
- **实时保存触发**：为所有DNS配置字段添加了`@change="saveDnsConfig"`事件监听，实现修改即保存的功能。
- **状态指示器**：新增DNS配置保存状态指示器，包含保存中状态（旋转图标）、已保存状态（绿色勾号）和自动隐藏功能。
- **后端同步处理**：DNS配置修改后自动调用后端`/api/dns/configure` API，实时同步配置到系统。
- **配置应用**：自动调用`dns_setup.sh`脚本，更新`/etc/named.conf`配置文件并重启Bind DNS服务。

#### 🎨 前端DNS配置界面优化
- **实时保存触发**：域名、服务器IP、管理员邮箱、递归查询开关、转发开关和上游DNS服务器都支持实时保存。
- **状态反馈**：添加了保存中、已保存等状态指示器，提供清晰的用户反馈。
- **用户体验**：DNS配置修改无需手动保存，修改即生效，提供更流畅的配置管理体验。

#### 🔧 后端DNS配置处理
- **API端点优化**：优化了`/api/dns/configure` API的参数处理和验证逻辑。
- **脚本执行**：DNS配置修改后自动调用`dns_setup.sh bind`脚本，实时应用配置。
- **服务管理**：自动重启Bind DNS服务，确保配置立即生效。







## V2.8.0 (2025-10-17)

### 🎯 版本亮点
- **用户管理功能修复**：修复了用户管理页面无法显示用户列表的问题，优化了前后端数据交互逻辑。
- **API响应处理优化**：改进了`query-users`操作的API响应处理，支持直接返回用户数据，减少不必要的轮询操作。
- **前端数据解析增强**：优化了前端用户数据的解析和显示逻辑，确保用户列表能够正确加载和显示。
- **后端JSON解析改进**：修复了后端脚本输出JSON数据的解析问题，确保用户数据能够正确传递给前端。
- **用户体验提升**：用户管理页面现在能够正确显示所有注册用户，包括用户名、邮箱、注册时间和用户类型。
### 📋 更新内容

#### 👥 用户管理功能修复
- **问题修复**：修复了用户管理页面无法显示用户列表的问题，现在能够正确显示所有注册用户。
- **数据交互优化**：优化了前后端数据交互逻辑，确保用户数据能够正确传递和显示。
- **API调用改进**：改进了用户查询API的调用方式，提高了数据获取的可靠性。

#### 🔧 API响应处理优化
- **直接数据返回**：改进了`query-users`操作的API响应处理，支持直接返回用户数据。
- **减少轮询操作**：优化了数据获取机制，减少了不必要的轮询操作。
- **响应时间优化**：提高了API响应速度，改善了用户体验。

#### 🎨 前端数据解析增强
- **数据解析优化**：优化了前端用户数据的解析和显示逻辑，确保用户列表能够正确加载。
- **错误处理改进**：改进了错误处理机制，提供更好的用户体验。
- **数据同步**：确保用户数据能够正确同步到前端界面。

#### 🔧 后端JSON解析改进
- **脚本输出优化**：修复了后端脚本输出JSON数据的解析问题。
- **数据传递**：确保用户数据能够正确传递给前端。
- **格式统一**：统一了JSON数据格式，确保前后端数据一致性。

## V2.7.5 (2025-10-17) - 独立垃圾邮件过滤系统

### 🎯 版本亮点
- **独立垃圾邮件过滤系统**：创建了完全独立的垃圾邮件过滤脚本，不依赖外部软件包，支持前后端调用
- **垃圾邮件过滤配置界面**：在系统设置中添加了完整的垃圾邮件过滤配置界面，支持关键词、域名和规则管理
- **智能过滤规则**：支持中英文关键词过滤、域名黑名单、内容长度检测、大写比例分析等多种过滤机制
- **过滤系统测试功能**：提供完整的测试套件，支持10种不同场景的垃圾邮件检测验证
- **动态配置管理**：支持运行时添加/删除过滤规则，无需重启服务即可生效
- **过滤统计监控**：提供详细的过滤统计信息和日志记录，便于系统监控和维护

### 📋 更新内容

#### 🛡️ 独立垃圾邮件过滤系统
- **功能描述**：创建了完全独立的垃圾邮件过滤脚本，不依赖外部软件包，支持前后端调用
- **技术实现**：
  ```bash
  # 垃圾邮件过滤脚本
  #!/bin/bash
  
  # 检查关键词
  check_keywords() {
    local content="$1"
    local keywords_file="/etc/mail/spam-filter/keywords.txt"
    
    if [[ -f "$keywords_file" ]]; then
      while IFS= read -r keyword; do
        if [[ "$content" == *"$keyword"* ]]; then
          echo "检测到禁用关键词: $keyword"
          return 1
        fi
      done < "$keywords_file"
    fi
    return 0
  }
  
  # 检查域名黑名单
  check_domain_blacklist() {
    local from="$1"
    local to="$2"
    local blacklist_file="/etc/mail/spam-filter/domain-blacklist.txt"
    
    if [[ -f "$blacklist_file" ]]; then
      while IFS= read -r domain; do
        if [[ "$from" == *"$domain"* ]] || [[ "$to" == *"$domain"* ]]; then
          echo "检测到黑名单域名: $domain"
          return 1
        fi
      done < "$blacklist_file"
    fi
    return 0
  }
  ```

## V2.7.4 (2025-10-16)

### 🎯 版本亮点
- **系统稳定性提升**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **用户体验优化**：优化了用户界面和交互体验，提供更流畅的操作体验。
- **性能改进**：改进了系统性能，提高了响应速度和处理效率。
- **错误处理增强**：增强了错误处理机制，提供更好的错误提示和恢复能力。

### 📋 更新内容

#### 🔧 系统稳定性提升
- **稳定性修复**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **错误处理改进**：改进了错误处理机制，提供更好的错误提示和恢复能力。
- **性能优化**：优化了系统性能，提高了响应速度和处理效率。
## V2.7.3 (2025-10-16)

### 🎯 版本亮点
- **系统稳定性提升**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **用户体验优化**：优化了用户界面和交互体验，提供更流畅的操作体验。
- **性能改进**：改进了系统性能，提高了响应速度和处理效率。
- **错误处理增强**：增强了错误处理机制，提供更好的错误提示和恢复能力。

### 📋 更新内容

#### 🔧 系统稳定性提升
- **稳定性修复**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **错误处理改进**：改进了错误处理机制，提供更好的错误提示和恢复能力。
- **性能优化**：优化了系统性能，提高了响应速度和处理效率。

## V2.7.2 (2025-10-16)

### 🎯 版本亮点
- **系统稳定性提升**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **用户体验优化**：优化了用户界面和交互体验，提供更流畅的操作体验。
- **性能改进**：改进了系统性能，提高了响应速度和处理效率。
- **错误处理增强**：增强了错误处理机制，提供更好的错误提示和恢复能力。

### 📋 更新内容

#### 🔧 系统稳定性提升
- **稳定性修复**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **错误处理改进**：改进了错误处理机制，提供更好的错误提示和恢复能力。
- **性能优化**：优化了系统性能，提高了响应速度和处理效率。

## V2.7.1 (2025-10-16)

### 🎯 版本亮点
- **系统稳定性提升**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **用户体验优化**：优化了用户界面和交互体验，提供更流畅的操作体验。
- **性能改进**：改进了系统性能，提高了响应速度和处理效率。
- **错误处理增强**：增强了错误处理机制，提供更好的错误提示和恢复能力。

### 📋 更新内容

#### 🔧 系统稳定性提升
- **稳定性修复**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **错误处理改进**：改进了错误处理机制，提供更好的错误提示和恢复能力。
- **性能优化**：优化了系统性能，提高了响应速度和处理效率。

## V2.7.0 (2025-10-16)

### 🎯 版本亮点
- **邮件列表排序优化**：修复邮件列表显示顺序问题，确保邮件按时间降序排列，最新邮件显示在最上面。
- **时间解析修复**：修复邮件列表时间解析错误，解决字段映射问题，确保邮件时间正确显示。
- **前端排序逻辑**：在前端`loadEmails`函数中添加排序逻辑，使用`Array.sort()`方法按邮件日期降序排序。

### 📋 更新内容

#### 📧 邮件列表排序优化
- **问题修复**：修复邮件列表显示顺序问题，确保邮件按时间降序排列。
- **前端排序**：在`frontend/src/modules/Mail.vue`的`loadEmails`函数中添加排序逻辑。
- **排序算法**：使用`Array.sort()`方法按邮件日期降序排序，确保最新邮件显示在最上面。
- **用户体验**：提升邮件列表的用户体验，让用户能够快速找到最新邮件。

#### 🔧 时间解析修复
- **字段映射修复**：修复邮件列表时间解析错误，解决字段映射问题。
- **数据库查询优化**：重构`mysql_query_json`函数，使用`JSON_ARRAYAGG`直接返回JSON格式。
- **时间显示**：确保邮件时间正确显示，避免时间解析错误。

## V2.6.1 (2025-10-15)

### 🎯 版本亮点
- **系统稳定性提升**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **用户体验优化**：优化了用户界面和交互体验，提供更流畅的操作体验。
- **性能改进**：改进了系统性能，提高了响应速度和处理效率。
- **错误处理增强**：增强了错误处理机制，提供更好的错误提示和恢复能力。

### 📋 更新内容

#### 🔧 系统稳定性提升
- **稳定性修复**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **错误处理改进**：改进了错误处理机制，提供更好的错误提示和恢复能力。
- **性能优化**：优化了系统性能，提高了响应速度和处理效率。

## V2.6.0 (2025-10-15)

### 🎯 版本亮点
- **系统稳定性提升**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **用户体验优化**：优化了用户界面和交互体验，提供更流畅的操作体验。
- **性能改进**：改进了系统性能，提高了响应速度和处理效率。
- **错误处理增强**：增强了错误处理机制，提供更好的错误提示和恢复能力。

### 📋 更新内容

#### 🔧 系统稳定性提升
- **稳定性修复**：修复了多个系统稳定性问题，提高了整体系统可靠性。
- **错误处理改进**：改进了错误处理机制，提供更好的错误提示和恢复能力。
- **性能优化**：优化了系统性能，提高了响应速度和处理效率。

## V2.5.6 详细更新内容

### 新增功能

#### 1. 邮件系统服务状态检查
- **API端点**：`/api/mail/service-status`
- **检查项目**：
  - Postfix邮件发送服务状态
  - Dovecot邮件接收服务状态
  - Bind DNS域名解析服务状态
  - MariaDB数据库服务状态

## V2.5.6 详细更新内容

### 新增功能

#### 1. 邮件系统服务状态检查
- **API端点**：`/api/mail/service-status`
- **检查项目**：
  - Postfix邮件发送服务状态
  - Dovecot邮件接收服务状态
  - Bind DNS域名解析服务状态
  - MariaDB数据库服务状态

## 总结

本文档详细记录了XM邮件管理系统的所有更新操作、版本升级步骤和系统维护指南。从V2.9.2到V2.5.6，每个版本都包含了详细的功能更新、技术实现和用户体验改进。

### 主要版本亮点

- **V2.9.2**：用户分页功能完善、批量删除用户功能
- **V2.9.1**：批量创建用户功能和系统优化
- **V2.9.0**：DNS配置系统全面优化
- **V2.8.x系列**：用户管理功能修复、垃圾邮件过滤系统、域名管理完善
- **V2.7.x系列**：系统稳定性提升、邮件列表排序优化
- **V2.6.x系列**：系统稳定性提升、用户体验优化
- **V2.5.6**：邮件系统服务状态检查、用户选择器集成

### 技术架构

系统采用前后端分离架构：
- **前端**：Vue 3 + TypeScript + Tailwind CSS
- **后端**：Node.js + Express.js
- **数据库**：MariaDB/MySQL
- **邮件服务**：Postfix + Dovecot
- **DNS服务**：Bind DNS

### 维护建议

1. **定期备份**：建议定期备份数据库和配置文件
2. **日志监控**：关注系统日志，及时发现和解决问题
3. **版本升级**：按照版本升级指南进行系统升级
4. **安全更新**：及时更新系统安全补丁

---

*本文档最后更新时间：2025-10-26*
  - 结果统计：显示通过/失败测试数量
  - 快速测试：支持快速测试模式
- **技术实现**：
  - 自动化测试框架
  - 多场景测试用例
  - 结果统计和报告
  - 测试数据管理
- **测试覆盖**：
  - 正常邮件通过测试
  - 垃圾邮件拦截测试
  - 边界条件测试
  - 性能压力测试

#### ⚙️ 动态配置管理
- **功能描述**：支持运行时添加/删除过滤规则，无需重启服务即可生效
- **实现内容**：
  - 动态关键词管理：运行时添加/删除关键词
  - 动态域名管理：运行时更新域名黑名单
  - 配置热更新：无需重启服务
  - 配置持久化：自动保存到配置文件
- **技术实现**：
  - 配置文件动态更新
  - 内存配置同步
  - 配置验证机制
  - 回滚机制支持
- **管理功能**：
  - 实时配置更新
  - 配置备份恢复
  - 配置版本管理
  - 配置审计日志

#### 📊 过滤统计监控
- **功能描述**：提供详细的过滤统计信息和日志记录，便于系统监控和维护
- **实现内容**：
  - 过滤统计：总检查数、垃圾邮件数、正常邮件数
  - 日志记录：详细的过滤日志和调试信息
  - 性能监控：过滤性能统计
  - 趋势分析：过滤效果趋势分析
- **技术实现**：
  - 统计数据库存储
  - 日志文件管理
  - 性能指标收集
  - 数据可视化展示
- **监控功能**：
  - 实时过滤统计
  - 历史数据分析
  - 性能指标监控
  - 异常告警机制

## V2.7.4 (2025-10-16)

### 🎯 版本亮点
- **邮件系统安全漏洞修复**：修复了严重的邮件系统安全漏洞，现在只有配置的域名才能接收邮件，其他域名将被拒绝
- **域名管理功能**：在系统设置中添加了完整的域名管理功能，管理员可以添加、删除和管理邮件域名
- **Postfix安全配置强化**：添加了严格的收件人限制规则，包括域名验证和用户验证
- **邮件内容显示优化**：修复了邮件详情页面内容显示不全的问题，支持长文本的完整显示和滚动浏览
- **已发送页面UI统一**：将已发送页面的UI与收件箱保持一致，发送查看改为浅灰色，未查看的改为深绿色
- **数据库安全集成**：域名管理功能与MySQL virtual_domains表完全集成，确保数据一致性

### 📋 更新内容

#### 🔒 邮件系统安全漏洞修复
- **功能描述**：修复了严重的邮件系统安全漏洞，现在只有配置的域名才能接收邮件，其他域名将被拒绝
- **实现内容**：
  - 添加了virtual_domains表配置，限制只有授权的域名能接收邮件
  - 配置了Postfix的严格收件人限制规则
  - 添加了域名验证和用户验证机制
  - 修复了邮件系统完全开放的安全风险
- **技术实现**：
  - 在virtual_domains表中添加了xmskills.com域名
  - 配置了smtpd_recipient_restrictions规则
  - 添加了reject_unknown_recipient_domain限制
  - 重启Postfix服务应用新配置
- **安全提升**：
  - 只有配置的域名才能接收邮件
  - 未知域名和用户将被自动拒绝
  - 防止了邮件系统的安全漏洞

#### 🌐 域名管理功能
- **功能描述**：在系统设置中添加了完整的域名管理功能，管理员可以添加、删除和管理邮件域名
- **实现内容**：
  - 前端域名管理界面：添加域名表单、域名列表显示、删除操作
  - 后端API端点：GET/POST/DELETE /api/system/domains
  - 数据库集成：与MySQL virtual_domains表完全集成
  - 安全验证：域名格式验证、重复检查、用户使用检查
- **技术实现**：
  - 前端：Vue 3响应式域名管理界面
  - 后端：Node.js API + mail_db.sh脚本
  - 数据库：MySQL virtual_domains表操作
  - 安全：域名格式验证和用户使用检查
- **用户体验**：
  - 管理员可以轻松管理邮件域名
  - 实时添加和删除域名
  - 默认域名保护机制
  - 操作成功/失败的实时反馈

#### 📧 邮件内容显示优化
- **功能描述**：修复了邮件详情页面内容显示不全的问题，支持长文本的完整显示和滚动浏览
- **实现内容**：
  - 修复了长文本截断问题
  - 添加了强制换行和溢出处理
  - 扩大了模态框宽度（从max-w-5xl到max-w-6xl）
  - 添加了内容区域滚动支持
- **技术实现**：
  - CSS样式：break-all、overflow-wrap-anywhere、whitespace-pre-wrap
  - 内联样式：word-break: break-all、overflow-wrap: anywhere
  - 容器优化：max-h-96 overflow-y-auto
  - 布局改进：min-w-0确保容器正确收缩
- **用户体验**：
  - 所有邮件内容都能完整显示
  - 长内容支持滚动查看
  - 保持原始文本格式
  - 响应式设计适配不同屏幕

#### 🎨 已发送页面UI统一
- **功能描述**：将已发送页面的UI与收件箱保持一致，发送查看改为浅灰色，未查看的改为深绿色
- **实现内容**：
  - 统一了已发送和收件箱的视觉设计
  - 未查看邮件：深绿色文字、粗体、大字体、浅绿色背景
  - 已查看邮件：浅灰色文字、普通字体、小字体、浅灰色背景
  - 添加了绿色主题的视觉指示器和状态标签
- **技术实现**：
  - 使用相同的isUnread(email)函数判断状态
  - 绿色主题样式：text-green-900、bg-green-50、border-green-600
  - 状态标签：未查看/已查看标签显示
  - 点击标记已读功能
- **用户体验**：
  - 已发送和收件箱界面完全一致
  - 清晰的状态区分和视觉反馈
  - 流畅的交互体验

#### 🛡️ Postfix安全配置强化
- **功能描述**：添加了严格的收件人限制规则，包括域名验证和用户验证
- **实现内容**：
  - 配置了smtpd_recipient_restrictions规则
  - 添加了reject_non_fqdn_recipient限制
  - 添加了reject_unknown_recipient_domain限制
  - 重启Postfix服务应用新配置
- **技术实现**：
  - Postfix配置：permit_mynetworks, permit_sasl_authenticated, reject_non_fqdn_recipient, reject_unknown_recipient_domain, permit
  - 数据库验证：virtual_domains和virtual_users表查询
  - 服务重启：systemctl restart postfix
- **安全提升**：
  - 严格的域名白名单机制
  - 自动拒绝未知域名和用户
  - 防止邮件系统被滥用

## V2.7.3 (2025-10-16)

### 🎯 版本亮点
- **智能分页功能**：为收件箱和已发送邮件添加了完整的分页功能，默认每页显示8条邮件，支持系统设置中调整
- **分页设置集成**：在系统设置中添加了邮件分页大小配置，支持5-25条/页的灵活调整
- **邮件已读状态优化**：修复了未读/已读邮件的视觉对比问题，未读邮件显示为深蓝色，已读邮件显示为浅灰色
- **点击立即标记已读**：点击邮件后立即标记为已读状态，无需手动刷新，提供流畅的用户体验
- **分页导航组件**：提供上一页/下一页按钮和页码导航，支持快速跳转到指定页面
- **性能优化**：前端分页减少DOM渲染，提升大量邮件的浏览性能

### 📋 更新内容

#### 📄 智能分页功能
- **功能描述**：为收件箱和已发送邮件添加了完整的分页功能，默认每页显示8条邮件
- **实现内容**：
  - 前端分页计算：总页数、当前页范围、分页数据切片
  - 分页导航组件：上一页/下一页按钮、页码按钮、分页信息显示
  - 响应式分页：根据邮件总数自动计算分页信息
  - 性能优化：只渲染当前页的邮件，减少DOM渲染
- **技术实现**：
  - 添加了`currentPage`、`pageSize`、`totalEmails`等响应式变量
  - 实现了`totalPages`、`startIndex`、`endIndex`、`paginatedEmails`计算属性
  - 添加了`goToPage`、`resetPagination`等分页方法
  - 使用`localStorage`保存分页设置
- **用户体验**：
  - 用户可以快速浏览大量邮件
  - 分页信息清晰显示当前页范围和总数
  - 支持快速跳转到指定页面

#### ⚙️ 分页设置集成
- **功能描述**：在系统设置中添加了邮件分页大小配置，支持5-25条/页的灵活调整
- **实现内容**：
  - 系统设置界面：邮件设置 → 邮件分页大小选择器
  - 可选选项：5、8、10、15、20、25条/页
  - 设置持久化：保存到localStorage，页面刷新后保持
  - 实时生效：设置保存后立即应用到邮件列表
- **技术实现**：
  - 在`Layout.vue`中添加了分页大小选择器
  - 在`systemSettings.mail`中添加了`pageSize`字段
  - 设置保存时自动更新localStorage
  - Mail.vue组件挂载时自动加载设置
- **用户体验**：
  - 管理员可以根据需要调整每页显示的邮件数量
  - 设置立即生效，无需重启服务
  - 支持不同用户的不同分页偏好

#### 📧 邮件已读状态优化
- **功能描述**：修复了未读/已读邮件的视觉对比问题，未读邮件显示为深蓝色，已读邮件显示为浅灰色
- **实现内容**：
  - 未读邮件：深蓝色文字（text-blue-900）、粗体、大字体、浅蓝色背景
  - 已读邮件：浅灰色文字（text-gray-400）、普通字体、小字体、浅灰色背景
  - 视觉指示器：未读邮件右上角蓝色脉动圆点、"新邮件"标签
  - 智能判断：使用`isUnread(email)`函数正确处理字符串和数字格式的read状态
- **技术实现**：
  - 修复了`!email.read`判断逻辑，使用`isUnread(email)`函数
  - 更新了所有样式绑定，确保正确的视觉对比
  - 添加了背景色和边框的区分
- **用户体验**：
  - 用户可以一眼区分未读和已读邮件
  - 未读邮件非常醒目，已读邮件相对低调
  - 清晰的视觉层次和状态指示

#### ⚡ 点击立即标记已读
- **功能描述**：点击邮件后立即标记为已读状态，无需手动刷新，提供流畅的用户体验
- **实现内容**：
  - 点击邮件时自动调用标记已读API
  - 立即更新本地状态，无需等待后端响应
  - 重新计算未读邮件数量
  - 视觉状态立即更新为已读样式
- **技术实现**：
  - 修复了`openEmail`函数中的未读判断逻辑
  - 调用`PUT /api/mail/:id/read` API标记为已读
  - 后端调用`mail_db.sh mark_read`更新数据库
  - 前端立即更新`email.read`状态和未读计数
- **用户体验**：
  - 点击邮件后立即看到状态变化
  - 无需手动刷新页面
  - 流畅的交互体验

## V2.7.2 (2025-10-16)

### 🎯 版本亮点
- **邮件UI大幅优化**：重新设计了收件箱的未读邮件和已读邮件视觉对比，让用户能够一眼区分邮件状态
- **未读邮件突出显示**：未读邮件使用白色背景、蓝色边框、粗体文字和脉动指示器，非常醒目
- **已读邮件低调显示**：已读邮件使用灰色背景和普通文字，保持界面简洁
- **调试信息切换功能**：为邮件详情页面添加了调试信息的显示/隐藏按钮，开发者可以按需查看
- **视觉层次优化**：通过颜色、字体、阴影等元素建立清晰的视觉层次，提升用户体验
- **交互反馈增强**：优化了悬停效果和选中状态，提供更好的交互反馈

### 📋 更新内容

#### 🎨 邮件UI大幅优化
- **功能描述**：重新设计了收件箱的未读邮件和已读邮件视觉对比，让用户能够一眼区分邮件状态
- **实现内容**：
  - 未读邮件：白色背景、蓝色左边框、粗体黑色文字、脉动指示器、"新邮件"标签
  - 已读邮件：灰色背景、灰色左边框、普通灰色文字、无特殊指示器
  - 选中状态：渐变背景突出显示（收件箱蓝色，已发送绿色）
  - 悬停效果：未读邮件渐变蓝色背景，已读邮件简单灰色悬停
- **技术实现**：
  - 使用Tailwind CSS的动态类绑定实现条件样式
  - 添加了`showDebugInfo`响应式变量控制调试信息显示
  - 优化了邮件列表的布局和间距
  - 实现了视觉层次和交互反馈
- **用户体验**：
  - 用户可以一眼区分未读和已读邮件
  - 未读邮件非常醒目，已读邮件相对低调
  - 清晰的视觉层次和交互反馈

#### 🔧 调试信息切换功能
- **功能描述**：为邮件详情页面添加了调试信息的显示/隐藏按钮，开发者可以按需查看
- **实现内容**：
  - 默认隐藏调试信息，保持界面简洁
  - 点击按钮可以切换调试信息的显示状态
  - 调试信息格式化显示，便于开发者查看
- **技术实现**：
  - 添加了`showDebugInfo`响应式变量
  - 使用`v-if="showDebugInfo"`条件渲染
  - 按钮文本动态切换："显示调试" ↔ "隐藏调试"
  - 使用`JSON.stringify(selectedEmail.attachments, null, 2)`格式化显示
- **用户体验**：
  - 保持界面简洁，调试信息按需显示
  - 开发者可以方便地查看附件数据
  - 调试信息格式化显示，更易读

## V2.7.1 (2025-10-16)

### 🎯 版本亮点
- **智能时间显示功能**：为邮件发送添加了实时时间显示，包括已用时间、预计剩余时间和总预计时间
- **动态时间估算**：根据文件大小智能估算发送时间，大文件自动给予更长的预计时间
- **实时进度反馈**：每秒更新已用时间，根据当前进度动态调整预计剩余时间
- **用户体验优化**：用户现在可以清楚地看到邮件发送进度和时间信息，特别是发送大文件时
- **时间格式化显示**：支持中文时间格式显示（秒/分钟/小时），提供更友好的用户体验

### 📋 更新内容

#### ⏰ 智能时间显示功能
- **功能描述**：为邮件发送添加了实时时间显示，包括已用时间、预计剩余时间和总预计时间
- **实现内容**：
  - 实时显示已用时间，每秒更新一次
  - 根据当前进度动态计算预计剩余时间
  - 显示总预计时间，让用户了解整个发送过程
  - 支持中文时间格式显示（秒/分钟/小时）
- **技术实现**：
  - 添加了`elapsedTime`、`estimatedTime`、`startTime`等响应式变量
  - 实现了`formatTime`函数，支持时间格式化显示
  - 添加了实时时间更新器，每秒更新已用时间
  - 根据文件大小智能估算基础时间
  - 根据当前进度动态调整预计剩余时间
- **用户体验**：
  - 用户可以清楚地看到邮件发送进度和时间信息
  - 特别是发送大文件时，用户不会因为不知道进度而焦虑
  - 时间显示更加友好和直观

#### 🚀 大文件发送优化
- **功能描述**：优化了大文件发送的用户体验，添加了智能时间估算和进度反馈
- **实现内容**：
  - 根据文件大小动态调整超时时间（5秒-15分钟）
  - 智能进度条，大文件进度更新更慢更平滑
  - 文件大小限制：单文件最大10MB，总大小不超过50MB
  - 超出限制时友好提示
- **技术实现**：
  - 修改了`backend/dispatcher/server.js`中的超时设置
  - 添加了文件大小检测和动态超时调整
  - 优化了前端进度条显示逻辑
  - 添加了文件大小限制和提示功能

#### 📎 附件功能完善
- **功能描述**：完善了邮件附件功能，包括上传、存储、显示和下载
- **实现内容**：
  - 支持多种文件格式：PDF, DOC, TXT, 图片, 压缩包等
  - 附件Base64编码存储，确保数据完整性
  - 附件信息完整显示：文件名、大小、类型
  - 支持附件下载功能
  - 附件大小限制和验证
- **技术实现**：
  - 前端：`fileToBase64`函数将文件转换为Base64格式
  - 后端：`mail_db.sh`正确处理JSON格式的附件数据
  - 数据库：`attachments`字段存储JSON格式的附件信息
  - 显示：邮件详情页面完整显示附件列表
- **用户体验**：
  - 拖拽上传和点击上传两种方式
  - 实时显示已选择的文件信息
  - 文件大小和类型验证
  - 附件下载功能完整可用

## V2.7.0 (2025-10-16)

### 🎯 版本亮点
- **邮件附件功能完全修复**：彻底修复了邮件附件上传、存储和显示功能，解决了JSON格式解析问题
- **数据库存储优化**：修复了附件数据在数据库中的存储格式，确保JSON数据完整性
- **Shell参数传递优化**：使用临时文件传递附件数据，避免shell参数解析导致的JSON格式破坏
- **附件显示完善**：前端正确显示附件信息，包括文件名、大小和下载功能
- **邮件详情增强**：邮件详情页面完整显示附件列表，支持附件下载功能
- **系统稳定性提升**：修复了多个邮件存储和显示相关的bug，提升了系统整体稳定性

### 📋 更新内容

#### 📎 邮件附件功能完全修复
- **功能描述**：彻底修复了邮件附件上传、存储和显示功能，解决了JSON格式解析问题
- **实现内容**：
  - 修复了附件数据在数据库中的存储格式，确保JSON数据完整性
  - 使用临时文件传递附件数据，避免shell参数解析导致的JSON格式破坏
  - 前端正确显示附件信息，包括文件名、大小和下载功能
  - 邮件详情页面完整显示附件列表，支持附件下载功能
- **技术实现**：
  - 修改了`mail_db.sh`中的转义逻辑，对于JSON数据只转义单引号，不转义双引号
  - 添加了JSON验证逻辑，确保只有有效的JSON数据才会被存储
  - 修改了SQL语句，避免MySQL自动转义JSON数据
  - 使用临时文件传递附件数据，避免shell参数解析问题
- **影响范围**：邮件附件功能、数据库存储、前端显示
- **修复问题**：
  - 附件数据JSON格式被破坏的问题
  - 前端无法显示附件的问题
  - 附件下载功能失效的问题

#### 📧 邮件已读/未读视觉对比
- **功能描述**：为邮件列表添加了清晰的已读/未读视觉对比，用户可以一目了然地识别邮件状态
- **实现内容**：
  - 未读邮件：白色背景，左侧蓝色边框，深色文字，加粗主题，蓝色圆点指示器
  - 已读邮件：浅灰色背景，浅色文字，普通字体，无指示器
  - 选中邮件：浅蓝色背景，左侧深蓝色边框，保持文字颜色
- **技术实现**：
  - 使用Vue的条件类绑定实现动态样式
  - 通过Tailwind CSS实现颜色和字体粗细的对比
  - 添加了平滑的过渡动画效果
- **影响范围**：邮件列表界面、用户体验

#### 📎 附件功能完善
- **问题描述**：修复了附件上传、存储和下载功能的问题
- **修复内容**：
  - 修复了前端附件数据格式，添加了Base64内容编码
  - 完善了后端附件处理逻辑，支持JSON字符串直接传递
  - 优化了附件显示和下载功能
- **技术实现**：
  - 添加了`fileToBase64`函数处理文件转换
  - 修复了`mail_db.sh`中的附件处理逻辑
  - 优化了附件存储和检索机制
- **影响范围**：附件功能、邮件存储

#### 🎨 视觉层次优化
- **功能描述**：通过颜色深浅和字体粗细建立清晰的视觉层次，提升用户体验
- **实现内容**：
  - 发件人/收件人：未读深色，已读浅色
  - 邮件主题：未读加粗深色，已读普通浅色
  - 时间显示：未读中等灰色，已读浅灰色
  - 背景颜色：未读白色，已读浅灰色
- **技术实现**：
  - 使用Vue的条件类绑定实现动态样式
  - 通过Tailwind CSS的颜色系统建立层次
  - 添加了字体粗细的对比
- **影响范围**：邮件列表界面、视觉体验

#### ⚡ 交互反馈增强
- **功能描述**：优化了悬停效果和选中状态，提供更好的交互反馈
- **实现内容**：
  - 未读邮件悬停：浅蓝色背景
  - 已读邮件悬停：稍深的灰色背景
  - 选中状态：浅蓝色背景，左侧深蓝色边框
  - 平滑过渡动画
- **技术实现**：
  - 使用Tailwind CSS的hover和transition类
  - 添加了duration-200的过渡效果
  - 优化了选中状态的视觉反馈
- **影响范围**：用户交互、界面反馈

#### 🔄 界面一致性
- **功能描述**：收件箱和已发送邮件使用统一的视觉设计，确保界面一致性
- **实现内容**：
  - 收件箱和已发送邮件使用相同的样式规则
  - 统一的颜色方案和字体样式
  - 一致的交互效果和动画
- **技术实现**：
  - 将样式规则应用到两个邮件列表
  - 使用相同的条件类绑定逻辑
  - 保持代码的一致性和可维护性
- **影响范围**：界面一致性、用户体验

#### 🔧 邮件详情显示修复
- **问题描述**：修复了邮件详情页面无法显示邮件正文和附件的问题
- **修复内容**：
  - 修复了前端邮件详情获取逻辑，现在会调用完整的邮件详情API
  - 优化了API响应格式，直接返回邮件对象而不是包装对象
  - 添加了邮件内容加载状态提示，提升用户体验
- **技术实现**：
  - 修改了`openEmail`函数，添加了完整的邮件详情获取逻辑
  - 优化了后端`/api/mail/:id`端点的响应格式
  - 添加了邮件内容加载状态和错误处理
- **影响范围**：邮件详情显示、用户体验

#### 🎨 页面布局优化
- **功能描述**：完善了邮件详情模态框的布局设计，实现更好的居中显示效果
- **实现内容**：
  - 扩大了邮件详情模态框的宽度（从max-w-4xl到max-w-5xl）
  - 优化了邮件正文显示区域，添加了背景色和边框
  - 改进了附件显示区域的视觉效果
- **技术实现**：
  - 使用Tailwind CSS优化了模态框布局
  - 添加了渐变背景和阴影效果
  - 改进了整体视觉效果和用户体验
- **影响范围**：邮件详情界面、用户体验

#### 📎 附件功能完善
- **问题描述**：修复了附件上传、存储和下载功能的问题
- **修复内容**：
  - 修复了邮件发送时的附件处理逻辑
  - 完善了附件存储到数据库的功能
  - 优化了附件显示和下载功能
- **技术实现**：
  - 在`mailOptions`中添加了附件数组处理
  - 修复了附件JSON序列化和存储逻辑
  - 优化了前端附件显示和下载功能
- **影响范围**：附件功能、邮件存储

#### 📧 抄送功能完善
- **问题描述**：修复了抄送信息的显示和存储问题
- **修复内容**：
  - 修复了已发送邮件中抄送信息的显示问题
  - 完善了抄送邮件的存储逻辑
  - 优化了抄送信息的数据库存储
- **技术实现**：
  - 修复了已发送邮件的存储参数顺序
  - 添加了抄送字段到数据库表结构
  - 优化了抄送信息的JSON格式化
- **影响范围**：抄送功能、邮件存储

#### ⚡ API响应优化
- **功能描述**：优化了邮件详情API的响应格式，提升了前端数据处理效率
- **实现内容**：
  - 简化了API响应结构，直接返回邮件对象
  - 优化了字段映射，确保前端能正确获取所有邮件信息
  - 改进了错误处理机制
- **技术实现**：
  - 修改了后端API响应格式
  - 优化了前端数据处理逻辑
  - 添加了更好的错误处理
- **影响范围**：API性能、前端处理效率

#### 🚀 用户体验提升
- **功能描述**：改进了邮件详情加载状态显示和错误处理机制
- **实现内容**：
  - 添加了邮件内容加载状态提示
  - 优化了错误处理和用户反馈
  - 改进了整体用户体验
- **技术实现**：
  - 添加了加载状态显示
  - 优化了错误处理逻辑
  - 改进了用户界面反馈
- **影响范围**：用户体验、界面交互

### 📋 更新内容

#### 📎 邮件附件功能
- **功能描述**：为邮件系统添加了完整的附件上传和管理功能
- **实现内容**：
  - 前端添加了现代化的文件上传区域，支持拖拽上传
  - 支持多种文件格式：PDF, DOC, TXT, 图片, 压缩包等
  - 显示已选择文件的列表，包括文件名和大小
  - 支持多文件选择和文件删除功能
- **技术实现**：
  - 前端使用HTML5 File API处理文件选择
  - 添加了文件大小格式化函数
  - 实现了文件预览和删除功能
- **影响范围**：前端邮件编写界面、用户体验
- **测试结果**：用户可以方便地上传和管理邮件附件

#### 📧 抄送功能
- **功能描述**：添加了邮件抄送(CC)功能，支持向多个收件人发送邮件
- **实现内容**：
  - 前端添加了抄送输入框，支持邮件地址验证
  - 后端API支持抄送字段处理
  - 数据库存储抄送信息
  - 抄送邮件正确存储到相关用户的收件箱
- **技术实现**：
  - 前端添加了抄送输入框和验证
  - 后端修改了邮件发送API，支持抄送字段
  - 数据库表添加了cc_addr字段
  - 邮件存储逻辑支持抄送用户
- **影响范围**：前端邮件界面、后端API、数据库结构
- **测试结果**：抄送功能正常工作，抄送用户能收到邮件

#### 🎨 附件显示优化
- **功能描述**：在邮件详情中显示附件信息，包括文件名、大小和下载功能
- **实现内容**：
  - 邮件详情页面显示附件列表
  - 显示附件文件名、大小和类型图标
  - 提供附件下载按钮（预留功能）
  - 美观的附件显示区域设计
- **技术实现**：
  - 前端解析附件JSON数据
  - 使用文件图标和大小格式化
  - 响应式布局适配不同屏幕
- **影响范围**：邮件详情显示、用户体验
- **测试结果**：附件信息正确显示，界面美观

#### 🗄️ 数据库结构升级
- **功能描述**：为邮件表添加了抄送字段，支持更完整的邮件信息存储
- **实现内容**：
  - 在emails表中添加了cc_addr字段
  - 修改了store_email函数支持抄送参数
  - 更新了邮件查询语句包含抄送信息
  - 修改了邮件详情查询包含抄送和附件信息
- **技术实现**：
  - MySQL ALTER TABLE添加cc_addr字段
  - 修改INSERT语句包含抄送字段
  - 更新SELECT查询包含抄送信息
- **影响范围**：数据库结构、邮件存储逻辑
- **测试结果**：抄送信息正确存储和查询

#### 🎯 前端界面增强
- **功能描述**：优化了写邮件界面，添加了现代化的文件上传区域和抄送输入框
- **实现内容**：
  - 重新设计了写邮件界面布局
  - 添加了现代化的文件上传区域，支持拖拽
  - 添加了抄送输入框，支持邮件地址验证
  - 优化了表单验证和用户体验
- **技术实现**：
  - 使用Tailwind CSS设计现代化界面
  - HTML5 File API处理文件上传
  - Vue.js响应式数据绑定
- **影响范围**：前端用户界面、用户体验
- **测试结果**：界面美观，功能完整

#### 🔄 邮件存储逻辑
- **功能描述**：完善了邮件存储逻辑，确保抄送邮件正确存储到相关用户的收件箱
- **实现内容**：
  - 修改了邮件发送API支持抄送和附件
  - 更新了邮件存储逻辑，支持抄送用户
  - 添加了抄送邮件的独立存储
  - 完善了邮件查询逻辑
- **技术实现**：
  - 后端API处理抄送和附件参数
  - 数据库存储逻辑支持多收件人
  - 邮件查询支持抄送信息显示
- **影响范围**：后端API、数据库操作、邮件逻辑
- **测试结果**：抄送邮件正确存储和显示

## 历史版本 - V2.6.2 (2025-10-15)

### 🎯 版本亮点
- **邮件页面布局优化**：将邮件页面改为使用Layout组件，确保版权信息正确居中且在页面底部
- **邮件主题动画背景**：为邮件页面添加了独特的动画背景，与Dashboard页面形成差异化
- **导航栏动画效果**：邮件页面现在使用统一的Layout组件，提供流畅的侧边栏展开/收起动画
- **代码结构优化**：移除了重复的导航栏和版权信息代码，提高了代码的可维护性
- **用户体验提升**：邮件页面现在与Dashboard页面使用相同的布局结构，确保界面一致性

### 📋 更新内容

#### 🎨 邮件页面布局优化
- **问题描述**：邮件页面的版权信息没有像Dashboard页面那样优化，左侧导航栏开启时版权信息不居中且未在最下面
- **修复内容**：
  - 将邮件页面改为使用`<Layout>`组件，与Dashboard页面保持一致
  - 移除了重复的导航栏和版权信息代码
  - 确保版权信息正确居中且在页面底部
- **影响范围**：前端邮件页面、布局结构、用户体验
- **测试结果**：邮件页面现在与Dashboard页面使用相同的布局结构，版权信息正确居中

#### ✨ 邮件主题动画背景
- **问题描述**：邮件页面缺少独特的动画背景效果，与Dashboard页面没有差异化
- **修复内容**：
  - 添加了邮件主题的动画背景，包含浮动邮件图标、装饰线条、粒子效果
  - 设计了多种动画效果：浮动、漂移、旋转、脉冲等
  - 使用邮件主题的蓝色、紫色、青色系色彩搭配
- **影响范围**：前端邮件页面视觉效果、用户体验
- **测试结果**：邮件页面现在有了独特的精美动画背景，与Dashboard页面形成差异化

#### 🔧 代码结构优化
- **问题描述**：邮件页面包含重复的导航栏和版权信息代码，代码冗余
- **修复内容**：
  - 移除了邮件页面中重复的侧边栏导航代码
  - 移除了重复的版权信息代码
  - 移除了不再需要的`sidebarVisible`、`toggleSidebar`等变量和函数
- **影响范围**：代码可维护性、代码结构
- **测试结果**：代码结构更加清晰，减少了重复代码

#### 🎭 导航栏动画效果
- **问题描述**：邮件页面的导航栏缺少动画效果，用户体验不够流畅
- **修复内容**：
  - 邮件页面现在使用统一的Layout组件
  - 导航栏动画效果由Layout组件提供，包括侧边栏的展开/收起动画
  - 确保所有页面的导航栏动画效果一致
- **影响范围**：前端导航栏、用户体验、界面一致性
- **测试结果**：邮件页面的导航栏现在有流畅的动画效果，与Dashboard页面一致

## V2.6.1 (2025-10-15)

### 🎯 版本亮点
- **邮件查询逻辑修复**：修复了邮件查询的用户隔离问题，确保用户只能看到发送给自己的邮件
- **邮件计数一致性**：修复了邮件统计API和邮件列表API的数据不一致问题，确保前端显示准确
- **未读邮件计数优化**：修复了收件箱未读邮件计数的闪烁问题，添加加载状态避免1秒闪烁
- **版权信息统一**：为邮件页面添加了与其他页面一致的版权信息，提升品牌形象
- **用户体验改进**：优化了邮件系统的整体用户体验，确保数据准确性和界面一致性

### 📋 更新内容

#### 🔧 邮件查询逻辑修复
- **问题描述**：用户发送邮件给其他用户后，发送人也能在收件箱中看到这封邮件
- **修复内容**：
  - 修改了`backend/scripts/mail_db.sh`中的`get_emails`函数查询条件
  - 收件箱查询：`to_addr = '$user' OR to_addr LIKE '%@$user' OR to_addr LIKE '$user@%'`
  - 已发送查询：`from_addr = '$user' OR from_addr LIKE '%@$user' OR from_addr LIKE '$user@%'`
- **影响范围**：邮件列表API、邮件统计API
- **测试结果**：用户隔离逻辑完全正确，每个用户只能看到发送给自己的邮件

#### 📊 邮件计数一致性修复
- **问题描述**：前端显示邮件统计和实际邮件列表数据不一致
- **修复内容**：
  - 修改了`get_mail_stats`函数中的收件箱和已发送统计查询条件
  - 确保统计API和列表API使用相同的查询逻辑
- **影响范围**：邮件统计API、前端邮件统计显示
- **测试结果**：统计API和列表API数据完全一致

#### ⚡ 未读邮件计数优化
- **问题描述**：收件箱未读邮件计数在加载时有1秒闪烁
- **修复内容**：
  - 添加了`unreadCountLoading`状态管理
  - 在加载时隐藏未读计数，加载完成后延迟100ms显示
  - 修改了模板显示逻辑：`!unreadCountLoading && unreadCount > 0`
- **影响范围**：前端邮件页面、用户体验
- **测试结果**：消除了闪烁问题，用户体验更加流畅

#### 🎨 版权信息统一
- **问题描述**：邮件页面缺少版权信息，与其他页面不一致
- **修复内容**：
  - 为邮件页面添加了与其他页面一致的版权信息
  - 包含XM品牌标识、年份信息、平台描述和版本信息
- **影响范围**：前端邮件页面、品牌形象
- **测试结果**：邮件页面现在与其他页面保持一致的版权信息

## V2.6.0 (2025-10-15)

### 🎯 版本亮点
- **邮件系统完全修复**：修复了所有邮件发送和接收功能，确保邮件系统完全正常工作
- **API路由优化**：修复了邮件统计API的路由冲突问题，确保所有API端点正常工作
- **JSON解析完善**：修复了邮件统计和列表查询的JSON解析错误，支持NULL值处理
- **Postfix MySQL支持**：在安装脚本中添加了postfix-mysql包，支持MySQL虚拟邮箱配置
- **DNS配置增强**：在DNS配置时自动设置系统主机名为mail.域名格式
- **邮件统计功能**：完善了邮件统计API，正确显示收件箱和发件箱的邮件数量和大小
- **错误处理优化**：改进了所有API的错误处理逻辑，提供更准确的错误信息
- **日志输出修复**：修复了脚本日志输出干扰JSON格式的问题

### 📋 更新内容

#### V2.6.0 核心修复
1. **邮件发送功能修复**
   - 修复了Postfix SASL认证问题，禁用SASL认证避免连接失败
   - 安装了postfix-mysql包，支持MySQL虚拟邮箱配置
   - 修复了nodemailer的SSL证书验证问题

2. **API路由问题修复**
   - 修复了`/api/mail/stats`被`/api/mail/:id`路由拦截的问题
   - 调整了路由定义顺序，确保统计API正常工作
   - 修复了邮件统计API返回404错误的问题

3. **JSON解析错误修复**
   - 修复了邮件统计脚本中的NULL值处理问题
   - 添加了NULL值到0的转换逻辑
   - 修复了脚本日志输出干扰JSON格式的问题

4. **DNS配置增强**
   - 在DNS配置时自动设置系统主机名为mail.域名格式
   - 确保邮件服务器主机名与域名一致
   - 优化了邮件系统配置顺序

5. **安装脚本完善**
   - 在start.sh中添加了postfix-mysql包安装
   - 在mail_setup.sh中添加了postfix-mysql包安装
   - 确保前端安装邮件服务时包含MySQL支持

## 历史版本 - V2.5.10 (2025-10-15)

### 🎯 版本亮点
- **数据库连接优化**：修复了MySQL数据库连接问题，确保邮件数据库用户正确创建和权限配置
- **SSL证书处理**：修复了邮件发送时的SSL证书验证问题，支持自签名证书环境
- **JSON解析修复**：修复了邮件列表查询的JSON解析错误，确保前端能正确显示邮件数据
- **错误处理增强**：添加了数据库用户创建的重试机制和验证逻辑，提高系统稳定性
- **安装流程优化**：完善了安装脚本中的数据库初始化流程，确保邮件系统能正常启动
- **完成状态显示**：添加了检查完成后的成功状态提示，提供清晰的用户反馈
- **调试信息完善**：增加了详细的调试日志，便于问题定位和系统维护
- **邮件系统服务状态检查**：在邮件页面添加智能服务状态检查，确保用户在使用邮件功能前完成系统配置
- **DNS解析验证**：自动检查mail域名解析配置，确保DNS服务正常工作
- **服务状态可视化**：使用颜色编码显示各服务状态（Postfix、Dovecot、Bind DNS、MariaDB）
- **智能提醒系统**：未配置时显示详细的配置指导和操作建议
- **用户流程优化**：引导用户按照正确的顺序完成系统配置
- **动态版本号获取**：前端自动从start.sh获取版本信息，无需手动更新版本号
- **版本API接口**：新增`/api/version`接口，实时读取start.sh中的版本信息
- **版本管理器**：前端版本管理器支持缓存机制，减少API调用频率
- **自动版本同步**：执行`./start.sh start`后自动同步前端版本信息
- **版权信息完善**：所有页面底部显示动态版本号，提升品牌形象
- **智能日志颜色处理**：优化日志函数，当日志消息包含"无警告"时，时间戳和"警告"字眼保持绿色，避免误标红
- **日志显示优化**：修复了字符串替换的链式语法问题，确保日志输出格式正确，避免出现异常字符
- **用户体验提升**：改进了日志的可读性，正确区分真正的警告信息和"无警告"状态
- **SSL证书申请功能**：完整的CA服务器创建与证书颁发功能，支持自签名CA根证书生成、服务器证书申请、Apache SSL配置
- **证书管理界面**：新增证书申请对话框，支持自定义证书信息、有效期设置、主题备用名称（SAN）配置
- **Apache SSL集成**：自动配置Apache SSL虚拟主机，支持HTTPS重定向、证书文件管理、权限设置
- **系统证书信任**：自动更新系统证书信任库，确保浏览器无证书警告
- **DNS配置提示**：提供DNS配置建议，支持公网IP自动检测和DNS解析配置

### 🔧 技术实现
- **环境检查弹窗实现**：在`frontend/src/modules/Dashboard.vue`中将环境检查按钮改为弹窗模式，避免页面刷新问题
- **状态管理优化**：简化环境检查函数，只执行一次环境检查，避免双重调用导致的状态冲突
- **轮询错误处理**：在`call()`函数的轮询过程中添加try-catch，防止未捕获的异常导致页面刷新
- **完成状态检测**：在`fetchLog()`函数中添加`=== 环境检查完成 ===`的检测，确保正确识别完成状态
- **成功状态显示**：在弹窗中添加绿色成功提示框，显示"环境检查完成！系统状态良好"
- **按钮状态管理**：根据检查状态动态显示按钮文本（检查中/重新检查/开始检查）
- **调试信息增强**：在关键函数中添加详细的console.log，便于问题定位和系统维护
- **服务状态检查API**：在`backend/dispatcher/server.js`中新增`/api/mail/service-status`接口，检查Postfix、Dovecot、Bind DNS、MariaDB服务状态
- **DNS解析验证**：自动检查mail域名解析配置，使用nslookup验证DNS解析
- **服务状态可视化**：前端使用颜色编码（绿色=正常，红色=异常）显示各服务状态
- **智能提醒系统**：根据服务状态生成具体的配置建议和操作指导
- **用户流程优化**：页面加载时自动检查服务状态，未配置时显示警告界面
- **版本API接口**：在`backend/dispatcher/server.js`中新增`/api/version`接口，使用正则表达式读取start.sh中的版本信息
- **版本管理器**：创建`frontend/src/utils/versionManager.ts`单例类，支持缓存机制和错误处理
- **动态版本显示**：前端所有页面使用Vue响应式数据绑定显示动态版本号
- **版本同步机制**：在start.sh中添加`sync_frontend_version`函数，支持重试机制和服务检查
- **智能颜色判断**：使用正则表达式 `无.*警告` 检测"无警告"模式，动态调整时间戳和文本颜色
- **条件颜色处理**：分别处理"无警告"和普通警告情况，确保颜色显示正确
- **字符串替换优化**：修复了链式替换语法错误，使用分步处理避免异常字符
- **日志函数修复**：修复了bash正则表达式语法错误，使用正确的括号语法 `(错误|失败|异常|警告)`
- **语法检查**：确保所有日志函数在bash环境下语法正确
- **CA根证书管理**：自动创建CA根证书，有效期10年，支持证书索引和序列号管理
- **服务器证书生成**：支持4096位RSA密钥、SHA256签名、SAN扩展配置
- **OpenSSL配置**：自动配置OpenSSL参数，支持证书扩展和签名算法
- **Apache虚拟主机**：自动创建SSL虚拟主机配置，支持HTTPS重定向
- **系统集成**：自动更新证书信任库，配置DNS解析建议

### 📋 更新内容
1. **环境检查弹窗优化**
   - 将环境检查按钮改为弹窗模式，避免页面刷新问题
   - 添加环境检查弹窗HTML结构，包含加载状态、错误信息、日志显示区域
   - 实现`openEnvironmentCheckDialog()`和`closeEnvironmentCheckDialog()`函数
   - 添加成功状态显示，检查完成后显示绿色提示框
   - 优化按钮状态管理，根据检查状态动态显示按钮文本

2. **状态管理改进**
   - 简化`callEnvironmentCheck()`函数，只执行一次环境检查
   - 移除双重调用逻辑，避免状态冲突
   - 优化状态重置逻辑，确保每次检查都有清晰的状态

3. **错误处理增强**
   - 在`call()`函数的轮询过程中添加try-catch错误处理
   - 防止轮询过程中的未捕获异常导致页面刷新
   - 改进`fetchLog()`函数的错误处理，添加401认证错误的特殊处理

4. **完成状态显示**
   - 在`fetchLog()`函数中添加`=== 环境检查完成 ===`的检测
   - 当检测到完成标记时，设置`status.value = 'success'`
   - 在弹窗中添加绿色成功提示框，显示"环境检查完成！系统状态良好"

5. **调试信息完善**
   - 在`callEnvironmentCheck()`函数中添加详细的调试日志
   - 在`fetchLog()`函数中添加轮询过程的调试信息
   - 便于问题定位和系统维护

6. **邮件系统服务状态检查**
   - 新增`/api/mail/service-status`接口，检查所有邮件相关服务状态
   - 自动检查Postfix、Dovecot、Bind DNS、MariaDB服务运行状态
   - 验证DNS解析配置，确保mail域名能正确解析
   - 检查邮件数据库状态，确保数据库正常工作
   - 生成详细的配置建议和操作指导

2. **智能提醒系统**
   - 邮件页面加载时自动检查服务状态
   - 未配置时显示醒目的警告界面
   - 使用颜色编码直观显示各服务状态
   - 提供"重新检查"和"前往系统配置"按钮
   - 根据服务状态生成具体的解决建议

3. **用户流程优化**
   - 引导用户按照正确顺序完成系统配置
   - 只有在系统完全配置后才允许使用邮件功能
   - 提供一键跳转到系统配置页面的功能
   - 支持实时重新检查服务状态

4. **动态版本号获取系统**
   - 新增`/api/version`接口，实时读取start.sh中的`SCRIPT_VERSION`变量
   - 创建前端版本管理器，支持5分钟缓存机制，减少API调用频率
   - 所有前端页面（Layout、Login、Register、Reset）支持动态版本号显示
   - 版本信息显示在页面底部的版权信息中

2. **版本同步机制**
   - 在start.sh中添加`sync_frontend_version`函数
   - 执行`./start.sh start`后自动同步前端版本信息
   - 支持最多5次重试机制，确保版本同步成功
   - 检查调度层服务状态，确保API可用性

3. **版权信息完善**
   - 所有页面底部添加统一的版权信息格式
   - 版权信息包含版权图标、年份、平台描述和动态版本号
   - 使用响应式设计，在不同屏幕尺寸下正确显示
   - 采用毛玻璃效果，与整体设计风格保持一致

4. **智能日志颜色处理**
   - 新增"无警告"检测逻辑，使用正则表达式 `无.*警告` 识别
   - 当日志消息包含"无警告"时，时间戳保持绿色，避免误标红
   - 当日志消息包含"无警告"时，"警告"字眼不标红，保持正常显示
   - 修复了字符串替换的链式语法问题，避免出现异常字符

5. **日志函数优化**
   - 修复了start.sh中log()函数的正则表达式语法错误
   - 将 `错误|失败|异常|警告` 改为 `(错误|失败|异常|警告)`
   - 简化了字符串替换操作，提高代码可维护性
   - 确保所有日志函数在bash环境下语法正确

6. **SSL证书申请功能**
   - 新增证书申请对话框，支持域名、证书信息、有效期设置
   - 支持主题备用名称（SAN）配置，包括通配符域名和IP地址
   - 自动创建CA根证书（如果不存在）
   - 生成服务器证书和私钥，支持自定义证书信息

7. **Apache SSL集成**
   - 自动配置Apache SSL虚拟主机
   - 支持HTTPS重定向和SSL证书配置
   - 自动设置证书文件权限
   - 重启Apache服务使配置生效

8. **系统证书信任**
   - 自动更新系统证书信任库
   - 复制CA根证书到系统信任目录
   - 确保浏览器无证书警告

9. **DNS配置提示**
   - 自动检测服务器公网IP
   - 提供DNS配置建议
   - 支持多种IP检测服务

10. **证书文件管理**
    - 自动创建证书目录结构
    - 设置正确的文件权限
    - 提供证书文件位置信息

## 历史版本 - V2.5.3 (2025-10-13)

### 🎯 版本亮点
- **智能日志颜色处理**：优化日志函数，当日志消息包含"无警告"时，时间戳和"警告"字眼保持绿色，避免误标红
- **日志显示优化**：修复了字符串替换的链式语法问题，确保日志输出格式正确，避免出现异常字符
- **用户体验提升**：改进了日志的可读性，正确区分真正的警告信息和"无警告"状态

### 🔧 技术实现
- **智能颜色判断**：使用正则表达式 `无.*警告` 检测"无警告"模式，动态调整时间戳和文本颜色
- **条件颜色处理**：分别处理"无警告"和普通警告情况，确保颜色显示正确
- **字符串替换优化**：修复了链式替换语法错误，使用分步处理避免异常字符
- **日志函数修复**：修复了bash正则表达式语法错误，使用正确的括号语法 `(错误|失败|异常|警告)`
- **语法检查**：确保所有日志函数在bash环境下语法正确

### 📋 更新内容
1. **智能日志颜色处理**
   - 新增"无警告"检测逻辑，使用正则表达式 `无.*警告` 识别
   - 当日志消息包含"无警告"时，时间戳保持绿色，避免误标红
   - 当日志消息包含"无警告"时，"警告"字眼不标红，保持正常显示
   - 修复了字符串替换的链式语法问题，避免出现异常字符

2. **日志函数优化**
   - 修复了start.sh中log()函数的正则表达式语法错误
   - 将 `错误|失败|异常|警告` 改为 `(错误|失败|异常|警告)`
   - 简化了字符串替换操作，提高代码可维护性
   - 确保所有日志函数在bash环境下语法正确

---

## 历史版本 - V2.5.2 (2025-10-13)

### 🎯 版本亮点
- **日志函数优化**：修复了start.sh中日志函数的正则表达式语法问题，确保日志输出格式正确
- **代码质量提升**：优化了日志处理逻辑，简化了字符串替换操作，提高了代码可维护性
- **系统稳定性**：修复了潜在的语法错误，确保脚本在各种环境下都能正常运行

### 🔧 技术实现
- **日志函数修复**：修复了bash正则表达式语法错误，使用正确的括号语法 `(错误|失败|异常|警告)`
- **字符串替换优化**：简化了复杂的字符串替换操作，提高代码可读性和维护性
- **语法检查**：确保所有日志函数在bash环境下语法正确

### 📋 更新内容
1. **日志函数优化**
   - 修复了start.sh中log()函数的正则表达式语法错误
   - 将 `错误|失败|异常|警告` 改为 `(错误|失败|异常|警告)`
   - 简化了字符串替换操作，提高代码可维护性
   - 确保所有日志函数在bash环境下语法正确

---

## 历史版本 - V2.5.1 (2025-10-13)

### 🎯 版本亮点
- **SSL证书申请功能**：完整的CA服务器创建与证书颁发功能，支持自签名CA根证书生成、服务器证书申请、Apache SSL配置
- **证书管理界面**：新增证书申请对话框，支持自定义证书信息、有效期设置、主题备用名称（SAN）配置
- **Apache SSL集成**：自动配置Apache SSL虚拟主机，支持HTTPS重定向、证书文件管理、权限设置
- **系统证书信任**：自动更新系统证书信任库，确保浏览器无证书警告
- **DNS配置提示**：提供DNS配置建议，支持公网IP自动检测和DNS解析配置

### 🔧 技术实现
- **CA根证书管理**：自动创建CA根证书，有效期10年，支持证书索引和序列号管理
- **服务器证书生成**：支持4096位RSA密钥、SHA256签名、SAN扩展配置
- **OpenSSL配置**：自动配置OpenSSL参数，支持证书扩展和签名算法
- **Apache虚拟主机**：自动创建SSL虚拟主机配置，支持HTTPS重定向
- **系统集成**：自动更新证书信任库，配置DNS解析建议

### 📋 更新内容
1. **SSL证书申请功能**
   - 新增证书申请对话框，支持域名、证书信息、有效期设置
   - 支持主题备用名称（SAN）配置，包括通配符域名和IP地址
   - 自动创建CA根证书（如果不存在）
   - 生成服务器证书和私钥，支持自定义证书信息

2. **Apache SSL集成**
   - 自动配置Apache SSL虚拟主机
   - 支持HTTPS重定向和SSL证书配置
   - 自动设置证书文件权限
   - 重启Apache服务使配置生效

3. **系统证书信任**
   - 自动更新系统证书信任库
   - 复制CA根证书到系统信任目录
   - 确保浏览器无证书警告

4. **DNS配置提示**
   - 自动检测服务器公网IP
   - 提供DNS配置建议
   - 支持多种IP检测服务

5. **证书文件管理**
   - 自动创建证书目录结构
   - 设置正确的文件权限
   - 提供证书文件位置信息

---

## 历史版本 - V2.5.0 (2025-10-13)

### 🎯 版本亮点
- **界面重组优化**：重新组织Dashboard界面，将健康检查功能合并到环境检查中，删除查询用户按钮，优化服务管理按钮布局
- **DNSPod集成完善**：完善DNSPod DNS配置功能，支持DNSPod Token认证方式，简化前端界面，仅保留Token输入框
- **定时备份修复**：修复定时备份cron任务创建问题，确保cron任务正确创建和生效，增强备份任务管理
- **腾讯云API 3.0支持**：实现腾讯云API 3.0签名算法，支持复杂的TC3-HMAC-SHA256认证方式，提供完整的API集成
- **公网IP自动识别**：实现多阶段公网IP自动检测机制，支持多个IP检测服务，确保DNS配置使用正确的公网IP

### 🔧 技术实现
- **界面重组**：合并健康检查到环境检查，优化按钮布局和功能分组
- **DNSPod Token认证**：简化认证方式，仅使用Token进行API调用
- **Cron任务修复**：修复变量替换问题，确保cron任务正确创建
- **腾讯云API 3.0**：实现完整的TC3-HMAC-SHA256签名算法
- **IP检测机制**：多阶段IP检测，支持多个外部服务

### 📋 更新内容
1. **界面重组优化**
   - 将健康检查功能合并到环境检查中，一次点击完成两项检查
   - 删除查询用户按钮，简化界面操作
   - 将服务管理和服务状态按钮移动到系统管理区域
   - 优化按钮布局，按照操作流程排列

2. **DNSPod集成完善**
   - 删除腾讯云API 3.0复杂认证方式，专注于DNSPod Token
   - 简化前端界面，删除API ID输入框，仅保留Token输入框
   - 优化Token验证逻辑，提供详细的错误诊断信息
   - 增强API调用稳定性，改进错误处理机制

3. **定时备份修复**
   - 修复cron任务创建中的变量替换问题
   - 使用echo命令替代heredoc，确保变量正确替换
   - 添加cron服务重启机制，确保新任务生效
   - 增强cron任务验证和状态显示

4. **腾讯云API 3.0支持**
   - 实现完整的TC3-HMAC-SHA256签名算法
   - 支持复杂的密钥派生和签名计算
   - 提供详细的API调用调试信息
   - 建议使用DNSPod Token方式，简化认证流程

5. **公网IP自动识别**
   - 实现多阶段IP检测机制：ifconfig.me、ipinfo.io、icanhazip.com
   - 添加本地IP检测作为备用方案
   - 提供IP检测失败时的回退机制
   - 确保DNS配置使用正确的公网IP

## 历史版本 - V2.4.3 (2025-10-12)

### 🎯 版本亮点
- **服务管理功能**：新增服务管理对话框，支持服务的重启和关闭操作，提供统一的服务管理界面，支持选择性操作多个服务
- **弹窗响应式优化**：全面优化所有弹窗的响应式设计，确保在小屏幕设备上也能正常使用，解决按钮无法点击的问题
- **移动端适配**：优化小屏幕设备的用户体验，支持垂直按钮布局、内容滚动和粘性按钮区域
- **服务状态实时监控**：新增服务状态对话框，支持实时显示所有系统服务的运行状态，每3秒自动刷新，提供实时的系统监控体验
- **智能状态指示器**：服务状态采用颜色编码显示（绿色运行中、红色失败、灰色已停止、黄色未知），直观展示系统健康状态

### 🔧 技术实现
- **服务管理界面**：统一的服务管理对话框，支持重启和关闭两种操作类型
- **响应式弹窗设计**：使用Tailwind CSS响应式类，支持移动端和桌面端适配
- **粘性按钮区域**：使用CSS sticky定位，确保按钮区域始终可见
- **移动端优化**：小屏幕下按钮垂直排列，大屏幕下水平排列
- **滚动优化**：自定义滚动条样式，提升用户体验

### 📋 更新内容
1. **服务管理功能**
   - 新增服务管理对话框，替代原有的重启服务功能
   - 支持操作类型选择：重启服务（绿色按钮）vs 关闭服务（红色按钮）
   - 支持选择性操作：邮件、数据库、DNS、安全、调度层服务
   - 动态按钮文字：根据操作类型显示"开始重启"或"开始关闭"
   - 智能按钮颜色：重启操作为橙色，关闭操作为红色

2. **后端API扩展**
   - 新增停止服务API端点：stop-mail、stop-database、stop-dns、stop-security、stop-dispatcher
   - 更新ALLOWED_ACTIONS集合，包含所有停止服务操作
   - 扩展switch case语句，为每个停止操作添加脚本映射
   - 在各个脚本中添加停止服务功能

3. **弹窗响应式优化**
   - 为所有弹窗添加padding和最大高度限制
   - 设置max-h-[90vh]防止弹窗超出屏幕高度
   - 添加overflow-y-auto支持内容滚动
   - 优化按钮区域布局，支持移动端垂直排列

4. **移动端适配优化**
   - 小屏幕下按钮垂直排列，避免重叠
   - 使用sticky定位确保按钮区域始终可见
   - 主要操作按钮在小屏幕上优先显示
   - 添加触摸友好的按钮间距

5. **自定义CSS样式**
   - 添加响应式媒体查询，优化小屏幕显示
   - 自定义滚动条样式，提升视觉体验
   - 优化弹窗边距和间距，确保内容可读性
   - 添加高度适配，超小屏幕下弹窗顶部对齐

### 🚀 新增功能
- **服务管理对话框**：完整的服务管理界面，支持重启和关闭操作
- **响应式弹窗系统**：所有弹窗都经过响应式优化
- **移动端适配**：专门针对小屏幕设备的优化
- **粘性按钮区域**：确保按钮始终可见和可点击
- **自定义滚动条**：美观的滚动条样式

### 🔧 技术细节
- **前端界面**：Vue 3 + TypeScript + Tailwind CSS
- **响应式设计**：使用Tailwind CSS响应式类
- **CSS优化**：自定义样式和媒体查询
- **用户体验**：移动端和桌面端统一体验
- **可访问性**：支持键盘导航和屏幕阅读器

### 📊 性能优化
- **响应式布局**：根据屏幕大小自动调整布局
- **滚动优化**：长内容支持平滑滚动
- **按钮优化**：确保按钮区域始终可见
- **触摸优化**：移动端触摸体验优化

### 🛠️ 升级说明
- **服务管理**：新增统一的服务管理界面，支持重启和关闭操作
- **移动端体验**：全面优化小屏幕设备的使用体验
- **弹窗优化**：所有弹窗都经过响应式优化，确保在各种设备上都能正常使用
- **用户体验**：提升整体用户界面的可用性和可访问性

### 🐛 问题修复
- **小屏幕按钮问题**：修复小屏幕设备上按钮无法点击的问题
- **弹窗显示问题**：优化弹窗在小屏幕上的显示效果
- **移动端适配**：解决移动端设备上的布局问题
- **按钮可见性**：确保按钮区域在所有设备上都可见

---

## 历史版本 - V2.4.2 (2025-10-12)

### 🎯 版本亮点
- **安全服务重启修复**：修复安全服务重启功能，确保防火墙正确启动并配置必要的邮件服务端口规则，解决服务状态显示不匹配问题
- **防火墙状态优化**：增强防火墙状态检查，区分禁用和停止状态，提供准确的服务状态显示
- **服务状态实时监控**：新增服务状态对话框，支持实时显示所有系统服务的运行状态，每3秒自动刷新，提供实时的系统监控体验
- **智能状态指示器**：服务状态采用颜色编码显示（绿色运行中、红色失败、灰色已停止、黄色未知），直观展示系统健康状态
- **系统信息展示**：实时显示系统时间、负载、内存使用、磁盘使用等关键系统信息，提供全面的系统概览

### 🔧 技术实现
- **安全服务重启机制**：重新启用防火墙、启动服务、配置规则、重启其他安全服务的完整流程
- **防火墙规则配置**：自动开放SMTP、IMAP、POP3、HTTP、HTTPS、DNS等必要端口
- **状态检查优化**：区分systemctl is-active和is-enabled状态，提供准确的服务状态判断
- **实时刷新机制**：使用setInterval实现每3秒自动刷新服务状态，仅在对话框打开时执行
- **智能状态管理**：区分首次加载和自动刷新，优化加载状态显示

### 📋 更新内容
1. **安全服务重启修复**
   - 修复防火墙重启功能，确保从禁用状态正确启动
   - 重新启用防火墙服务：`systemctl enable firewalld`
   - 启动防火墙服务：`systemctl start firewalld`
   - 重启防火墙服务：`systemctl restart firewalld`
   - 配置防火墙规则：开放邮件、Web、DNS等必要端口

2. **防火墙规则配置**
   - 开放SMTP端口：25/tcp（邮件发送）
   - 开放IMAP端口：143/tcp（邮件接收）
   - 开放POP3端口：110/tcp（邮件接收）
   - 开放HTTP端口：80/tcp（Web服务）
   - 开放HTTPS端口：443/tcp（安全Web服务）
   - 开放DNS端口：53/tcp,udp（域名解析）
   - 自动重载防火墙规则：`firewall-cmd --reload`

3. **防火墙状态检查优化**
   - 检查防火墙启用状态：`systemctl is-enabled firewalld`
   - 区分禁用和停止状态：禁用时显示为"已停止"
   - 准确状态显示：根据启用状态和运行状态综合判断
   - 详细日志输出：记录防火墙状态检查过程

4. **服务状态实时监控**
   - 新增服务状态对话框界面，支持实时显示所有系统服务状态
   - 每3秒自动刷新服务状态，无需手动操作
   - 支持9个主要服务的状态监控：邮件、数据库、DNS、安全、调度层、Web服务
   - 实时显示服务运行状态、最后检查时间、原始状态信息

5. **智能状态指示器**
   - 颜色编码状态显示：绿色（运行中）、红色（失败）、灰色（已停止）、黄色（未知）
   - 服务状态卡片设计，按服务类别分组显示
   - 实时状态指示器，显示"实时更新"状态
   - 服务组件详情，显示具体服务的运行状态

### 🚀 新增功能
- **安全服务重启修复**：完整的防火墙启动和配置流程
- **防火墙规则自动配置**：智能开放必要端口
- **服务状态实时监控**：完整的系统服务状态监控界面
- **实时刷新机制**：3秒间隔的自动状态更新
- **状态指示器**：直观的颜色编码状态显示

### 🔧 技术细节
- **前端界面**：Vue 3 + TypeScript + Tailwind CSS
- **安全服务管理**：systemctl + firewall-cmd命令集成
- **实时刷新**：setInterval定时器 + 条件刷新机制
- **状态管理**：Vue 3响应式状态管理
- **API集成**：RESTful API + 认证机制

### 📊 性能优化
- **资源管理**：条件刷新机制，只在需要时执行API调用
- **界面优化**：智能加载状态，避免不必要的界面闪烁
- **内存管理**：自动清理定时器，防止内存泄漏
- **用户体验**：实时状态更新，提供流畅的监控体验

### 🛠️ 升级说明
- **安全服务**：修复防火墙重启功能，确保安全服务正确启动和配置
- **服务监控**：新增服务状态实时监控功能，提供全面的系统健康状态展示
- **用户体验**：优化界面交互，提供实时更新的系统监控体验
- **性能优化**：智能资源管理，确保系统稳定性和响应性

### 🐛 问题修复
- **安全服务重启问题**：修复防火墙重启后仍显示为关闭状态的问题
- **服务状态不匹配**：解决服务状态显示与实际运行状态不一致的问题
- **防火墙规则缺失**：自动配置必要的邮件服务端口规则
- **状态检查不准确**：增强防火墙状态检查，区分禁用和停止状态

---

## 历史版本 - V2.4.1 (2025-10-12)

### 🎯 版本亮点
- **服务状态实时监控**：新增服务状态对话框，支持实时显示所有系统服务的运行状态，每3秒自动刷新，提供实时的系统监控体验
- **智能状态指示器**：服务状态采用颜色编码显示（绿色运行中、红色失败、灰色已停止、黄色未知），直观展示系统健康状态
- **系统信息展示**：实时显示系统时间、负载、内存使用、磁盘使用等关键系统信息，提供全面的系统概览
- **性能优化**：智能加载状态管理，自动刷新时不显示加载动画，避免界面闪烁，提升用户体验
- **内存管理**：组件卸载时自动清理定时器，防止内存泄漏，确保系统稳定性

### 🔧 技术实现
- **实时刷新机制**：使用setInterval实现每3秒自动刷新服务状态，仅在对话框打开时执行
- **智能状态管理**：区分首次加载和自动刷新，优化加载状态显示
- **状态指示器**：Vue 3响应式状态管理，实时更新服务状态显示
- **系统信息API**：增强后端API，支持获取系统负载、内存、磁盘使用情况
- **内存管理**：onUnmounted生命周期钩子，确保组件卸载时清理定时器

### 📋 更新内容
1. **服务状态实时监控**
   - 新增服务状态对话框界面，支持实时显示所有系统服务状态
   - 每3秒自动刷新服务状态，无需手动操作
   - 支持9个主要服务的状态监控：邮件、数据库、DNS、安全、调度层、Web服务
   - 实时显示服务运行状态、最后检查时间、原始状态信息

2. **智能状态指示器**
   - 颜色编码状态显示：绿色（运行中）、红色（失败）、灰色（已停止）、黄色（未知）
   - 服务状态卡片设计，按服务类别分组显示
   - 实时状态指示器，显示"实时更新"状态
   - 服务组件详情，显示具体服务的运行状态

3. **系统信息展示**
   - 实时显示系统时间戳
   - 系统负载平均值显示
   - 内存使用情况（已用/总量）
   - 磁盘使用百分比
   - 系统信息卡片布局，清晰展示关键指标

4. **性能优化**
   - 智能加载状态管理：首次打开显示加载动画，自动刷新时静默更新
   - 条件刷新机制：只在对话框打开时进行自动刷新，节省系统资源
   - 内存管理优化：组件卸载时自动清理定时器，防止内存泄漏
   - 响应式状态更新：Vue 3响应式系统，确保状态变化实时反映到界面

5. **用户体验优化**
   - 实时更新指示器：标题栏显示"实时更新"状态和脉冲动画
   - 手动刷新功能：支持点击"刷新状态"按钮立即更新
   - 错误处理增强：API调用失败时显示默认状态，避免界面空白
   - 调试信息完善：控制台输出详细的API调用和状态更新日志

### 🚀 新增功能
- **服务状态对话框**：完整的系统服务状态监控界面
- **实时刷新机制**：3秒间隔的自动状态更新
- **状态指示器**：直观的颜色编码状态显示
- **系统信息展示**：关键系统指标的实时显示
- **手动刷新功能**：支持用户主动刷新服务状态

### 🔧 技术细节
- **前端界面**：Vue 3 + TypeScript + Tailwind CSS
- **实时刷新**：setInterval定时器 + 条件刷新机制
- **状态管理**：Vue 3响应式状态管理
- **API集成**：RESTful API + 认证机制
- **内存管理**：onUnmounted生命周期钩子

### 📊 性能优化
- **资源管理**：条件刷新机制，只在需要时执行API调用
- **界面优化**：智能加载状态，避免不必要的界面闪烁
- **内存管理**：自动清理定时器，防止内存泄漏
- **用户体验**：实时状态更新，提供流畅的监控体验

### 🛠️ 升级说明
- **服务监控**：新增服务状态实时监控功能，提供全面的系统健康状态展示
- **用户体验**：优化界面交互，提供实时更新的系统监控体验
- **性能优化**：智能资源管理，确保系统稳定性和响应性
- **功能完善**：增强系统管理功能，提供更便捷的运维体验

---

## 历史版本 - V2.4.0 (2025-10-12)

### 🎯 版本亮点
- **定时备份弹窗功能**：新增用户友好的定时备份配置界面，支持自定义备份间隔和内容选择
- **智能备份策略**：支持选择性备份数据库、配置文件、邮件目录，可根据实际需求灵活配置
- **自动备份清理**：支持设置备份文件保留时间，自动清理过期备份文件，有效管理存储空间
- **服务重启功能**：新增服务重启弹窗，支持选择性重启邮件、数据库、DNS、安全、调度层等服务
- **备份状态监控**：增强备份功能的状态检查和日志输出，提供详细的备份执行信息

### 🔧 技术实现
- **定时备份弹窗**：完整的Vue 3对话框界面，包含备份间隔设置、内容选择、保留时间配置
- **智能备份策略**：动态生成备份脚本，根据用户选择执行不同的备份操作
- **Cron表达式计算**：根据备份间隔自动计算cron时间表达式
- **服务重启API**：新增restart-mail、restart-database、restart-dns、restart-security、restart-dispatcher端点
- **备份脚本优化**：增强backup.sh脚本，添加setup_backup_cron函数和条件备份逻辑

### 📋 更新内容
1. **定时备份弹窗功能**
   - 新增用户友好的定时备份配置界面
   - 支持1、3、7、30天预设选项和自定义天数设置
   - 提供备份内容选择：数据库、配置文件、邮件目录
   - 支持设置备份文件保留时间（1-365天）
   - 实时显示备份配置结果和状态信息

2. **智能备份策略**
   - 支持选择性备份数据库（MariaDB）
   - 支持选择性备份配置文件（Postfix、Dovecot、Apache等）
   - 支持选择性备份邮件目录（/var/vmail）
   - 根据用户选择动态生成备份脚本
   - 智能检查服务状态，跳过不存在的目录

3. **自动备份清理**
   - 支持设置备份文件保留时间
   - 自动清理超过保留时间的备份文件
   - 有效管理存储空间，防止磁盘空间不足
   - 提供备份文件统计信息

4. **服务重启功能**
   - 新增服务重启弹窗界面
   - 支持选择性重启邮件服务（Postfix + Dovecot）
   - 支持选择性重启数据库服务（MariaDB）
   - 支持选择性重启DNS服务（Bind）
   - 支持选择性重启安全服务（防火墙、反垃圾邮件等）
   - 支持选择性重启调度层服务（API调度器）

5. **备份状态监控**
   - 增强备份功能的状态检查
   - 提供详细的备份执行日志
   - 显示备份文件数量和目录大小
   - 提供备份结果汇总信息

### 🚀 新增功能
- **定时备份弹窗**：完整的备份配置界面，支持灵活设置备份策略
- **服务重启弹窗**：便捷的系统服务管理功能
- **智能备份脚本**：动态生成的自定义备份脚本
- **备份状态检查**：check-status操作，查看备份目录状态
- **Cron任务管理**：自动创建和管理定时备份任务

### 🔧 技术细节
- **前端界面**：Vue 3 + TypeScript + Tailwind CSS
- **后端API**：Node.js + Express调度层
- **备份脚本**：Bash脚本动态生成
- **Cron管理**：自动计算和执行定时任务
- **状态监控**：实时备份状态检查和日志输出

### 📊 性能优化
- **存储管理**：自动清理过期备份文件，优化存储空间使用
- **备份效率**：选择性备份减少不必要的存储占用
- **用户体验**：直观的弹窗界面，简化备份配置流程
- **系统管理**：便捷的服务重启功能，提高运维效率

### 🛠️ 升级说明
- **备份功能**：新增定时备份弹窗，支持灵活配置备份策略
- **服务管理**：新增服务重启功能，支持选择性重启系统服务
- **存储优化**：自动备份清理功能，有效管理存储空间
- **用户体验**：优化备份配置流程，提供更友好的操作界面

---

## 历史版本 - V2.3.6 (2025-10-12)

### 🎯 版本亮点
- **DNS配置简化**：移除DNS配置中的DKIM密钥生成功能，简化DNS配置流程，专注于核心DNS解析功能
- **调度层依赖安装优化**：大幅优化调度层依赖安装逻辑，增加网络检查、镜像切换、依赖验证等机制
- **服务启动自动修复**：增强调度层服务启动失败时的自动诊断和修复功能
- **脚本执行优化**：修复start.sh脚本中的return语句错误，优化前端依赖安装超时处理
- **系统安装流程完善**：统一安装流程，删除多余的修复脚本，专注于完善start.sh脚本本身

### 🔧 技术实现
- **DNS配置简化**：移除DKIM密钥生成函数和相关配置，专注于A、MX、SPF、DMARC记录
- **依赖安装优化**：增加网络连接检查、npm镜像切换、超时时间延长、备用安装方案
- **自动修复机制**：服务启动失败时自动重新安装依赖、验证关键依赖、修复权限问题
- **脚本错误修复**：修复非函数上下文中的return语句错误，改为exit语句
- **安装流程统一**：删除多余的修复脚本，将所有修复逻辑集成到start.sh中

### 📋 更新内容
1. **DNS配置简化**
   - 移除DNS配置中的DKIM密钥生成功能
   - 删除generate_dkim_key()函数和相关调用
   - 简化DNS配置流程，专注于核心DNS解析功能
   - 提高DNS配置效率和稳定性

2. **调度层依赖安装优化**
   - 增加网络连接检查，自动切换npm镜像源
   - 延长依赖安装超时时间（从180秒到300秒）
   - 添加依赖安装后的验证机制
   - 支持yarn作为备用安装方案
   - 自动设置正确的文件权限

3. **服务启动自动修复**
   - 增强调度层服务启动失败时的诊断功能
   - 自动重新安装调度层依赖
   - 验证所有关键依赖（express、morgan、uuid、basic-auth、nodemailer）
   - 自动修复文件权限问题
   - 服务重启后验证状态

4. **脚本执行优化**
   - 修复start.sh脚本中的return语句错误
   - 优化前端依赖安装超时处理
   - 增加详细的安装日志和错误信息
   - 提升整体安装稳定性

5. **系统安装流程完善**
   - 删除多余的修复脚本（fix_installation_issues.sh等）
   - 将所有修复逻辑集成到start.sh脚本中
   - 统一安装流程，确保重装时一次性成功
   - 简化系统维护和故障排除

### 🚀 升级步骤
1. **备份系统**：执行系统备份操作
2. **更新代码**：拉取最新代码到系统
3. **运行安装**：执行./start.sh start进行安装
4. **验证功能**：测试DNS配置和邮件服务功能
5. **检查日志**：确认系统运行正常

### ⚠️ 注意事项
- DNS配置不再包含DKIM功能，专注于核心DNS解析
- 调度层依赖安装现在更加稳定和可靠
- 系统安装流程已统一，无需额外的修复脚本
- 所有修复逻辑已集成到start.sh脚本中

## 目录

- [快速更新指南](#快速更新指南)
- [版本升级步骤](#版本升级步骤)
- [系统维护操作](#系统维护操作)
- [配置文件更新](#配置文件更新)
- [版本历史记录](#版本历史记录)
- [故障排除](#故障排除)

## 快速更新指南

### 1. 系统更新检查

```bash
# 检查当前系统状态
sudo dnf update -y
sudo systemctl status httpd mariadb postfix dovecot
```

### 2. 备份重要数据

```bash
# 备份数据库
mysqldump -u root -p mail_ops > backup_$(date +%Y%m%d).sql

# 备份配置文件
tar -czf config_backup_$(date +%Y%m%d).tar.gz /etc/postfix /etc/dovecot /etc/httpd
```

### 3. 执行更新

```bash
# 停止服务
sudo systemctl stop httpd mariadb postfix dovecot

# 执行更新脚本
./start.sh start

# 重启服务
sudo systemctl start httpd mariadb postfix dovecot
```

## 版本升级步骤

### V2.3.3 升级指南

#### 新功能特性
- **安装服务操作日志完善**：完善了安装服务功能，在操作日志最后显示详细的安装结果汇总
- **DNSPod支持集成**：添加了DNSPod (腾讯云) DNS服务商支持
- **公网DNS配置增强**：支持多种DNS服务商，提供统一的配置界面
- **安装结果跟踪优化**：实现每个服务安装状态的实时跟踪
- **用户体验提升**：使用友好的服务显示名称和状态图标

#### 升级步骤

1. **备份当前系统**
```bash
# 创建备份目录
mkdir -p /backup/$(date +%Y%m%d)
cd /backup/$(date +%Y%m%d)

# 备份数据库
mysqldump -u root -p mail_ops > mail_ops_backup.sql

# 备份配置文件
cp -r /etc/postfix /etc/dovecot /etc/httpd /etc/mariadb ./
```

2. **更新系统组件**
```bash
# 更新系统包
sudo dnf update -y

# 更新Node.js依赖
cd /bash/backend/dispatcher
npm update
```

3. **执行升级脚本**
```bash
# 执行系统升级
cd /bash
./start.sh start
```

4. **验证新功能**
- 测试安装服务功能
- 验证DNSPod DNS配置
- 检查操作日志显示

### V2.3.2 升级指南

#### 关键修复
- **DNS配置失败问题修复**：彻底修复了DNS配置一直显示"失败"的问题
- **脚本错误处理优化**：提高脚本的健壮性和容错能力
- **防火墙配置容错处理**：添加防火墙状态检查
- **配置文件检查优化**：named-checkconf命令失败时不再导致脚本退出
- **sudoers语法错误修复**：修复了sudoers配置中的语法错误
- **重复日志输出修复**：修复了start.sh脚本中重复输出日志路径的问题
- **安装服务操作日志修复**：修复了安装服务功能中操作日志不显示的问题

#### 升级步骤

1. **停止相关服务**
```bash
sudo systemctl stop httpd mariadb postfix dovecot
```

2. **更新脚本文件**
```bash
# 更新DNS配置脚本
cp backend/scripts/dns_setup.sh /bash/backend/scripts/

# 更新调度器配置
cp backend/dispatcher/server.js /bash/backend/dispatcher/
```

3. **修复sudoers配置**
```bash
# 检查sudoers配置
sudo visudo -c

# 如果发现错误，修复配置
sudo nano /etc/sudoers.d/mailops
```

4. **重启服务**
```bash
sudo systemctl start httpd mariadb postfix dovecot
```

### V2.3.1 升级指南

#### 新功能特性
- **DNS配置服务修复**：修复了配置服务弹窗中DNS选择功能
- **后端action处理完善**：添加了configure-bind和configure-public action的处理逻辑
- **DNS脚本参数优化**：dns_setup.sh脚本现在支持configure-bind和configure-public参数格式
- **智能参数处理**：configure模式自动获取服务器IP地址，设置默认管理员邮箱

#### 升级步骤

1. **更新后端API**
```bash
# 更新server.js
cp backend/dispatcher/server.js /bash/backend/dispatcher/

# 重启调度器服务
sudo systemctl restart mail-ops-dispatcher
```

2. **更新DNS脚本**
```bash
# 更新DNS配置脚本
cp backend/scripts/dns_setup.sh /bash/backend/scripts/

# 设置执行权限
chmod +x /bash/backend/scripts/dns_setup.sh
```

3. **更新前端界面**
```bash
# 重新构建前端
cd frontend
npm run build

# 部署前端文件
sudo cp -r dist/* /var/www/mail-frontend/
```

## 系统维护操作

### 定期维护任务

#### 1. 系统更新
```bash
# 更新系统包
sudo dnf update -y

# 更新安全补丁
sudo dnf upgrade --security -y
```

#### 2. 服务状态检查
```bash
# 检查所有服务状态
sudo systemctl status httpd mariadb postfix dovecot mail-ops-dispatcher

# 检查服务日志
sudo journalctl -u httpd -f
sudo journalctl -u mariadb -f
sudo journalctl -u postfix -f
sudo journalctl -u dovecot -f
```

#### 3. 数据库维护
```bash
# 优化数据库
mysql -u root -p -e "OPTIMIZE TABLE mail_ops.virtual_domains, mail_ops.virtual_users, mail_ops.virtual_aliases;"

# 检查数据库大小
mysql -u root -p -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"
```

#### 4. 日志清理
```bash
# 清理旧日志文件
find /var/log/mail-ops -name "*.log" -mtime +30 -delete

# 清理系统日志
sudo journalctl --vacuum-time=30d
```

### 性能优化

#### 1. 邮件队列管理
```bash
# 检查邮件队列
postqueue -p

# 清理邮件队列
postqueue -f

# 删除特定邮件
postsuper -d ALL
```

#### 2. 磁盘空间管理
```bash
# 检查磁盘使用情况
df -h

# 清理临时文件
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# 清理邮件日志
sudo find /var/log -name "*.log" -mtime +7 -delete
```

## 配置文件更新

### 核心配置文件

#### 1. Postfix配置
```bash
# 主配置文件
/etc/postfix/main.cf

# 更新后重启服务
sudo systemctl restart postfix
```

#### 2. Dovecot配置
```bash
# 主配置文件
/etc/dovecot/dovecot.conf

# 更新后重启服务
sudo systemctl restart dovecot
```

#### 3. Apache配置
```bash
# 虚拟主机配置
/etc/httpd/conf.d/mailmgmt.conf

# 更新后重启服务
sudo systemctl restart httpd
```

#### 4. MariaDB配置
```bash
# 主配置文件
/etc/my.cnf.d/mariadb-server.cnf

# 更新后重启服务
sudo systemctl restart mariadb
```

### 权限配置更新

#### 1. Sudoers配置
```bash
# 编辑sudoers配置
sudo visudo -f /etc/sudoers.d/mailops

# 检查配置语法
sudo visudo -c
```

#### 2. 文件权限
```bash
# 设置脚本执行权限
chmod +x /bash/backend/scripts/*.sh

# 设置日志目录权限
sudo chown -R xm:xm /var/log/mail-ops
sudo chmod -R 755 /var/log/mail-ops
```

## 版本历史记录

### V4.6.3 (2026-01-26) - SSL证书上传自动化与用户体验优化

#### 新功能特性
- **证书上传自动化流程**：检测证书名称为域名格式时自动配置Apache SSL，自动保存域名-证书关联到SSL域名列表，自动调用cert_setup.sh配置Apache并重启服务，配置完成后提供2-3分钟生效提示
- **自动构建前端**：证书上传成功后自动触发前端构建（调用start.sh rebuild），使用异步spawn执行不阻塞API响应，构建过程在后台进行有5分钟超时保护，构建结果记录到日志中
- **对话框内提示显示**：在SSL管理对话框右上角添加通知消息区域，支持success、error、warning、info四种类型，消息可手动关闭，显示时间智能调整

#### 功能完善
- **完整的用户提示**：显示成功上传的证书数量，显示自动配置Apache的证书数量，提示"Apache配置需要2-3分钟生效，请稍后访问HTTPS页面验证"，失败情况显示详细错误信息

#### 技术改进
- **后端响应优化**：添加apacheConfiguredCount字段到响应中，优化响应消息格式明确说明Apache配置状态，即使有部分失败只要至少有一个成功也会返回合理响应
- **前端响应处理优化**：修复响应检查逻辑确保成功消息正确显示，使用后端返回的消息包含完整的配置信息，延长提示显示时间确保用户能看到完整信息

### V4.6.1 (2026-01-23) - 备份功能整合与证书上传体验优化

#### 新功能特性
- **备份功能整合**：将"完整备份"和"定时备份"两个独立按钮整合到统一的"备份功能"按钮，创建备份管理对话框（完整备份和定时备份两个标签页），优化用户体验，备份功能更加集中和统一
- **证书上传体验优化**：移除"添加证书"按钮，改为直接拖拽上传，支持多文件同时上传，自动识别同一域名的证书文件（.key、_public.crt、_chain.crt），按域名自动分组，自动填充证书名称
- **Chain证书保护**：证书链文件不会绑定到域名，前端和后端双重过滤，确保chain证书不会被误绑定，证书链文件保存为`.chain.crt`格式

#### 功能完善
- **HTTP跳转HTTPS功能完善**：完善mod_rewrite模块自动启用检查，添加Apache配置语法验证（每个配置文件生成后验证，重启前全局验证），增强服务重启后的状态验证和端口监听检查，优化错误处理和日志输出

#### 技术改进
- **前端优化**：备份管理对话框实现，拖拽上传功能实现，智能文件识别算法（域名提取、文件类型判断），Chain证书过滤计算属性
- **后端优化**：证书列表API排除chain证书，批量上传API支持证书链文件，HTTP跳转功能增强（配置验证、状态检查）

### V4.6.0 (2026-01-23) - SSL管理功能重构与域名-证书关联管理

#### 新功能特性
- **SSL管理功能重构**：SSL配置从系统设置移除，统一到Dashboard管理，添加"管理SSL"按钮，创建完整的SSL管理对话框（域名管理、证书管理、上传证书三个标签页）
- **域名与证书关联管理**：证书上传仅处理文件，使用证书名称标识，支持域名-证书手动关联，支持多域名使用同一证书，实现证书共享和复用
- **HTTP自动跳转HTTPS功能**：添加HTTP跳转HTTPS按钮（仅在SSL启用后显示），配置需要2-3分钟生效提示，支持为所有配置的域名自动创建HTTP跳转配置

#### 问题修复
- **cert_setup.sh语法错误修复**：修复heredoc代码块闭合问题，优化configure_apache_ssl函数以支持证书名称参数
- **证书上传API修复**：修复证书上传API以使用certName而不是domain，改进错误处理和临时文件清理
- **域名-证书关联配置读取优化**：改进域名-证书关联配置的读取逻辑（支持jq和grep两种方式），提升系统稳定性

#### 技术改进
- **SSL管理统一入口**：所有SSL相关功能统一到Dashboard管理，提升用户体验和管理效率
- **证书管理灵活性提升**：证书和域名可以独立管理，支持证书复用，提高管理效率
- **配置管理优化**：添加域名-证书关联配置管理（config/ssl-domain-cert.json），实现配置持久化

#### 升级说明
- **自动迁移**：升级后SSL管理功能自动迁移到Dashboard，无需手动配置
- **向后兼容**：完全兼容之前版本的SSL配置，升级过程不影响现有功能
- **验证方法**：
  - 访问Dashboard，点击"管理SSL"按钮
  - 测试SSL管理功能（上传证书、添加域名、关联证书）
  - 测试HTTP跳转HTTPS功能

### V4.5.3 (2026-01-20) - 邮件详情API问题修复

#### 问题修复
- **邮件详情权限检查修复**：分离权限检查逻辑，区分已发送文件夹和收件箱，修复SQL字段名错误（`er_user.email_address` → `email_address`）
- **Python脚本语法错误修复**：修复嵌套try语句的缩进错误，确保JSON数据正确合并和返回
- **邮件内容显示优化**：添加错误状态显示，区分权限错误和内容为空，优化错误提示信息

#### 技术改进
- **权限检查逻辑优化**：先检查邮件是否存在，再检查权限，最后查询详情，添加详细的权限检查日志
- **错误处理优化**：正确处理404和500错误，实现回退机制，显示友好的错误提示

### V4.5.2 (2026-01-20) - 问题修复与系统优化

#### 问题修复
- **备案号显示问题修复**：修复注册和忘记密码页面备案号不显示的问题，在onMounted中添加loadIcpSettings()调用
- **系统设置保存优化**：改进重装时配置保护机制，在重装开始前强制备份现有配置文件，重装完成后自动恢复

#### 用户体验优化
- **删除重新部署提示**：删除备案号设置中关于重新部署前端的提示框，简化用户操作流程

### V3.1.8 (2025-11-20) - 邮件发送功能完善与用户体验优化

#### 新功能特性
- **邮件发送邮箱地址自动识别**：邮件发送时自动从数据库获取用户真实邮箱地址，确保使用正确的邮箱格式（如 `xm@skills.com` 而不是 `xm@localhost`）
- **抄送域名验证**：添加抄送收件人的域名验证功能，确保所有收件人域名都在系统允许列表中
- **批量创建用户域名自动识别**：批量创建用户时自动从管理员邮箱、域名列表或DNS配置中提取域名，创建的用户邮箱自动使用正确的域名格式

#### 问题修复
- **邮件发送500错误修复**：修复邮件发送时因域名验证失败导致的500错误，正确处理发件人邮箱地址提取和域名验证
- **已发送文件夹查询失败**：修复已发送文件夹无法查询到邮件的问题，支持查询用户的所有可能邮箱地址（包括 `xm@localhost` 和 `xm@skills.com`）
- **草稿保存功能失败**：修复草稿保存功能无法正常工作的问题，包括用户邮箱地址获取、附件数据处理和错误处理
- **批量创建用户域名识别**：修复批量创建用户时邮箱地址显示为 `user@localhost` 的问题，自动识别并使用正确的域名
- **前端用户邮箱硬编码**：修复前端 `getCurrentUserEmail` 函数对管理员 `xm` 硬编码返回 `xm@localhost` 的问题，改为从数据库获取真实邮箱地址

#### 技术改进
- **邮箱地址获取优化**：后端邮件发送和草稿保存时优先从数据库获取用户真实邮箱地址，而不是使用前端传递的可能错误的地址
- **域名验证逻辑完善**：改进域名验证逻辑，先获取用户真实邮箱地址再提取域名，避免因用户名不包含 `@` 导致的错误
- **已发送文件夹查询优化**：改进已发送文件夹的查询逻辑，自动查询用户的所有可能邮箱地址（数据库中的真实邮箱和localhost邮箱），确保能查询到所有发送的邮件
- **附件数据处理优化**：草稿保存时使用临时文件传递附件数据，避免命令行参数过长和特殊字符问题
- **错误处理和日志增强**：添加详细的日志输出和错误处理，便于问题诊断和故障排除

#### 升级说明
- **自动修复**：升级后邮件发送和草稿保存功能会自动使用数据库中的真实邮箱地址，无需手动配置
- **向后兼容**：已发送文件夹查询支持查询用户的所有可能邮箱地址，包括旧邮件（使用 `xm@localhost`）和新邮件（使用真实邮箱地址）
- **兼容性**：完全兼容之前版本，升级过程不影响现有功能和数据
- **验证方法**：
  - 发送邮件后检查邮件是否使用正确的发件人地址（如 `xm@skills.com`）
  - 检查已发送文件夹是否能正确显示所有发送的邮件
  - 测试草稿保存功能是否正常工作
  - 测试批量创建用户功能，验证创建的邮箱地址是否使用正确的域名

### V3.1.7 (2025-11-20) - 系统通知模块与数据库保护功能完善

#### 新功能特性
- **系统通知模块完整实现**：实现完整的系统通知机制，`system@localhost` 作为专用发件人，支持系统监控自动通知
- **前端系统通知标签**：系统通知邮件显示黄色标签和橙色背景，与红色系统管理员标签明显区分
- **系统监控功能**：自动监控磁盘使用率（80%警告，90%告警）和关键服务状态（postfix、dovecot、named、mariadb），每5分钟检查一次
- **数据库初始化保护**：检查数据库是否存在且有数据，避免覆盖现有数据，只在数据库不存在或为空时执行初始化

#### 问题修复
- **邮件详情页面系统通知标签**：修复邮件详情页面中 `system@localhost` 被错误标记为"系统管理员"的问题，正确显示为黄色"系统通知"标签
- **测试邮件发件人修复**：修复测试邮件API使用 `xm@localhost` 发送的问题，改为强制使用 `system@localhost`
- **数据库检测工具修复**：修复 `mail_CX.sh` 脚本中的数据库用户配置错误（maildbuser → mailuser），确保数据库检测功能正常
- **数据库初始化语法错误**：修复 `start.sh` 中数据库初始化部分的语法错误（if/fi 嵌套顺序问题）

#### 技术改进
- **系统监控自动化**：实现 `SystemMonitor` 类，自动监控系统状态并发送通知邮件
- **数据库存在性检查**：实现 `check_maildb_exists()` 和 `check_mailapp_exists()` 函数，智能判断数据库状态
- **前端标签识别优化**：优化 `isSystemNotification()` 和 `isAdminSender()` 函数，确保正确识别系统通知和管理员邮件
- **数据保护机制**：在数据库初始化前检查数据存在性，避免误删用户数据

#### 升级说明
- **自动功能**：系统监控功能在服务启动后30秒自动开始运行，无需手动配置
- **数据保护**：重新执行 `./start.sh start` 时，如果数据库已存在且有数据，会自动跳过初始化，保留所有现有数据
- **兼容性**：完全兼容之前版本，升级过程不影响现有功能和数据
- **验证方法**：升级后可通过发送测试邮件验证系统通知功能，检查邮件列表和详情页面是否正确显示黄色系统通知标签

### V3.1.6 (2025-11-20) - DNS配置完整性修复

#### 问题修复
- **DNS zone文件xm记录缺失**：修复DNS zone文件中缺少 `xm.skills.com` A记录的问题，导致用户邮件域名无法正确解析
- **DNS配置脚本不完整**：完善 `dns_setup.sh` 脚本，在自动生成zone文件时包含xm用户的A记录
- **本地DNS解析功能恢复**：确保 `xm.skills.com` 正确解析到服务器IP地址，恢复邮件系统的域名解析功能

#### 技术改进
- **DNS配置自动化**：在DNS配置过程中自动生成所有必要的A记录，包括xm用户记录
- **配置一致性保证**：确保DNS配置脚本与实际zone文件内容保持同步，避免手动配置遗漏
- **解析验证机制**：通过本地DNS服务器验证域名解析功能，确保配置生效

#### 升级说明
- **自动修复**：运行DNS配置脚本会自动包含xm记录，无需手动干预
- **兼容性**：完全兼容之前版本，升级过程不影响现有功能
- **验证方法**：升级后可通过 `nslookup xm.skills.com 127.0.0.1` 验证解析是否正确

### V3.1.5 (2025-11-20) - 邮件系统完整性修复与前端显示问题深度解决

#### 问题修复
- **邮件文件夹API 500错误修复**：解决 `/api/mail/folders` 返回500错误的路由冲突问题，重新排列Express路由确保参数路由不与具体路由冲突
- **邮件详情显示问题彻底解决**：修复邮件详情API响应数据结构访问问题（`apiResponse.email`），确保邮件正文和HTML内容正确显示在前端界面
- **JSON查询过滤修复**：修复 `get_folders`、`get_labels` 和 `get_folder_stats` 函数的JSON数据过滤逻辑，从 `grep -v "result"` 改为 `tail -1`
- **邮件存储流程优化**：完善测试邮件API的邮件目录创建逻辑，确保Dovecot能正确投递邮件，修复邮件存储命令中的特殊字符处理
- **数据库连接稳定性优化**：修复数据库连接问题，确保邮件存储和显示流程的完整性，修正邮件相关API中错误的脚本路径配置
- **前端数据访问逻辑完善**：添加详细的控制台日志和调试信息，便于问题诊断和故障排除

#### 技术改进
- **API路由顺序优化**：重新排列Express路由，将 `/api/mail/:id` 路由移至最后，避免与 `/api/mail/folders` 等具体路由冲突
- **JSON数据处理完善**：统一使用 `tail -1` 获取MySQL查询的JSON结果，确保数据完整性
- **邮件目录自动管理**：在测试邮件API中添加 `mkdir -p`、`chown` 和 `chmod` 命令，确保Maildir结构正确创建
- **错误处理增强**：改进API错误处理和日志记录，提供更详细的错误信息和调试支持
- **数据一致性保证**：确保邮件发送、存储和显示流程的完整性和可靠性

#### 升级说明
- **自动修复**：更新脚本后API路由和数据处理逻辑自动修复，无需手动干预
- **向后兼容**：完全兼容V3.1.4及之前版本，升级过程不影响现有功能
- **验证方法**：升级后可通过前端界面验证邮件列表显示、详情查看和文件夹功能是否正常

### V2.8.7 (2025-10-22) - 智能垃圾邮件过滤系统和域名管理完善版

#### 新功能特性
- **智能垃圾邮件过滤系统**：实现完整的垃圾邮件过滤功能，包括关键词检测、域名黑名单、内容规则过滤，支持中英文关键词管理和实时检测。
- **域名管理功能完善**：修复域名删除后邮件仍能发送的问题，实现域名删除时自动更新Postfix配置，确保域名管理的有效性。
- **邮件发送域名验证**：新增邮件发送时的域名验证机制，检查发件人和收件人域名是否在允许列表中，有效防止未授权域名的邮件发送。
- **垃圾邮件过滤配置管理**：提供完整的垃圾邮件过滤配置界面，支持关键词管理、域名黑名单配置、过滤规则设置和实时测试功能。
- **用户友好的错误提示**：优化邮件发送错误提示，区分域名验证错误、垃圾邮件检测错误和其他错误，提供详细的错误信息和修改建议。
- **Postfix配置自动同步**：实现域名变更时Postfix配置的自动更新和重载，确保邮件服务器配置的实时同步。

#### 技术实现
- **后端垃圾邮件检测API**：实现`checkSpamContent`函数，支持关键词检测、域名黑名单检查、内容规则过滤和垃圾邮件评分。
- **前端垃圾邮件过滤配置界面**：提供关键词管理、域名黑名单管理、过滤规则配置和实时测试功能。
- **域名删除时Postfix配置更新**：实现`update_postfix_domains`函数，自动更新Postfix的`virtual_mailbox_domains`配置。
- **邮件发送域名验证**：在邮件发送API中增加域名验证逻辑，检查发件人和收件人域名是否在允许列表中。
- **分类错误提示**：前端根据不同的错误类型显示相应的错误信息和修改建议。

## V2.8.8 (2025-10-22) - 系统设置自动探测和智能填充

### 🎯 版本亮点
- **系统设置自动探测**：实现了系统设置的自动探测功能，系统启动时自动获取服务器IP、域名、管理员邮箱等信息。
- **DNS配置智能填充**：DNS配置界面会自动填充检测到的服务器信息，减少手动配置的工作量。
- **管理员邮箱自动获取**：从数据库中自动获取管理员邮箱地址，无需手动设置。
- **服务器IP动态获取**：自动检测服务器的实际IP地址，避免硬编码IP地址的问题。
- **域名自动探测**：自动探测系统域名，提供更准确的DNS配置。

### 📋 更新内容

#### 🔍 系统设置自动探测
- **功能描述**：系统启动时自动探测服务器配置信息，减少手动配置的工作量。
- **技术实现**：
  ```javascript
  // 自动探测系统配置
  const autoDetectSystemConfig = async () => {
    try {
      // 获取服务器IP
      const serverIP = await getServerIP()
      
      // 获取管理员邮箱
      const adminEmail = await getAdminEmail()
      
      // 获取系统域名
      const systemDomain = await getSystemDomain()
      
      // 自动填充配置
      systemSettings.value.dns.bind.serverIp = serverIP
      systemSettings.value.general.adminEmail = adminEmail
      systemSettings.value.dns.bind.domain = systemDomain
      
    } catch (error) {
      console.error('自动探测系统配置失败:', error)
    }
  }
  ```

#### 🎯 DNS配置智能填充
- **功能描述**：DNS配置界面会自动填充检测到的服务器信息。
- **技术实现**：
  ```javascript
  // DNS配置智能填充
  const fillDnsConfig = () => {
    if (systemSettings.value.dns.bind.serverIp) {
      dnsSettings.value.serverIp = systemSettings.value.dns.bind.serverIp
    }
    
    if (systemSettings.value.dns.bind.adminEmail) {
      dnsSettings.value.adminEmail = systemSettings.value.dns.bind.adminEmail
    }
    
    if (systemSettings.value.dns.bind.domain) {
      dnsSettings.value.domain = systemSettings.value.dns.bind.domain
    }
  }
  ```

## V2.8.9 (2025-10-22) - 用户管理功能修复和API优化

### 🎯 版本亮点
- **用户管理功能修复**：修复了用户管理界面无法正确显示用户列表的问题。
- **API响应处理优化**：优化了后端API的响应处理逻辑，确保前端能正确解析用户数据。
- **前端数据解析增强**：增强了前端对用户数据的解析能力，支持更复杂的用户数据结构。
- **后端JSON解析改进**：改进了后端脚本的JSON输出格式，确保数据的一致性。
- **用户体验提升**：优化了用户管理界面的加载速度和显示效果。

### 📋 更新内容

#### 👥 用户管理功能修复
- **问题描述**：用户管理界面无法正确显示用户列表，用户数据解析失败。
- **技术实现**：
  ```javascript
  // 用户数据解析优化
  const parseUserData = (data) => {
    try {
      if (Array.isArray(data)) {
        return data.map(user => ({
          id: user.id || user.username,
          username: user.username,
          email: user.email,
          created_at: user.created_at,
          type: user.username === 'xm' ? '管理员' : '普通用户'
        }))
      }
      return []
    } catch (error) {
      console.error('用户数据解析失败:', error)
      return []
    }
  }
  ```

#### 🔧 API响应处理优化
- **功能描述**：优化了后端API的响应处理逻辑，确保数据格式的一致性。
- **技术实现**：
  ```javascript
  // 后端API响应优化
  app.post('/api/ops', auth, (req, res) => {
    // ... 处理逻辑 ...
    
    // 特殊处理：query-users操作
    if (action === 'query-users') {
      setTimeout(() => {
        try {
          const logFile = path.join(LOG_DIR, `${opId}.log`)
          if (fs.existsSync(logFile)) {
            const logContent = fs.readFileSync(logFile, 'utf8')
            const lines = logContent.split('\n')
            
            // 查找JSON数据行
            for (const line of lines) {
              const trimmedLine = line.trim()
              if ((trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) || 
                  (trimmedLine.startsWith('{') && trimmedLine.endsWith('}'))) {
                try {
                  const userData = JSON.parse(trimmedLine)
                  res.json({ success: true, users: userData })
                  return
                } catch (e) {
                  continue
                }
              }
            }
          }
          res.json({ success: true, opId })
        } catch (error) {
          console.error('Query-users response error:', error)
          res.json({ success: true, opId })
        }
      }, 1000)
    }
  })
  ```

## V2.9.1 (2025-10-26) - 批量创建用户功能和系统优化

### 🎯 版本亮点
- **批量创建用户功能**：新增批量创建用户功能，支持两种创建方式：1) 逗号分割的用户名列表 2) 用户名前缀+数量自动添加序号，大幅提升用户管理效率。
- **批量创建域名修复**：修复批量创建用户时邮箱域名使用localhost的问题，现在会正确使用系统配置的域名（如xmskills.com）。
- **系统设置动态加载**：实现系统设置的动态加载功能，确保批量创建用户时能获取到正确的域名配置。
- **批量创建认证修复**：修复批量创建用户时的API认证问题，确保所有API调用都包含正确的认证头信息。
- **批量创建结果展示**：新增详细的批量创建结果展示，显示每个用户的创建状态、邮箱地址和密码信息。
- **用户管理界面优化**：在用户管理界面新增"批量创建"按钮，提供便捷的批量用户创建入口。

### 📋 更新内容

#### 👥 批量创建用户功能
- **功能描述**：新增批量创建用户功能，支持两种创建方式，大幅提升用户管理效率。
- **创建方式**：
  - **用户名列表**：支持逗号分割的用户名列表，如 `user1,user2,user3`
  - **批量创建**：支持用户名前缀+数量，自动添加序号，如 `user` → `user01, user02, user03`
- **技术实现**：
  ```javascript
  // 批量创建用户状态管理
  const showBatchCreateDialog = ref(false)
  const batchCreateMode = ref<'list' | 'count'>('list')
  const batchUsernameList = ref('')
  const batchUsernamePrefix = ref('')
  const batchUserCount = ref(1)
  const batchCreateResults = ref<Array<{username: string, email: string, password: string, success: boolean, reason?: string}>>([])
  const batchCreating = ref(false)
  const batchPassword = ref('123123')
  
  // 执行批量创建用户
  async function executeBatchCreate() {
    if (batchCreating.value) return
    
    batchCreating.value = true
    batchCreateResults.value = []
    
    try {
      let usernames: string[] = []
      
      if (batchCreateMode.value === 'list') {
        // 解析逗号分割的用户名列表
        usernames = batchUsernameList.value
          .split(',')
          .map(name => name.trim())
          .filter(name => name.length > 0)
      } else if (batchCreateMode.value === 'count') {
        // 生成带序号的用户名
        usernames = []
        for (let i = 1; i <= batchUserCount.value; i++) {
          const paddedNumber = i.toString().padStart(2, '0')
          usernames.push(`${batchUsernamePrefix.value}${paddedNumber}`)
        }
      }
      
      const localDomain = getLocalDomain()
      const userPassword = batchPassword.value.trim() || '123123'
      
      // 批量创建用户
      for (const username of usernames) {
        try {
          const email = `${username}@${localDomain}`
          
          // 先检查用户是否已存在
          const userExists = await checkUserExists(username)
          if (userExists) {
            batchCreateResults.value.push({
              username: username,
              email: email,
              password: userPassword,
              success: false,
              reason: '用户已存在'
            })
            continue
          }
          
          // 调用添加用户API
          const response = await axios.post('/api/ops', {
            action: 'app-register',
            params: {
              username: username,
              email: email,
              password: userPassword
            }
          }, { headers: authHeader() })
          
          if (response.data.success) {
            batchCreateResults.value.push({
              username: username,
              email: email,
              password: userPassword,
              success: true
            })
          } else {
            batchCreateResults.value.push({
              username: username,
              email: email,
              password: userPassword,
              success: false,
              reason: '创建失败'
            })
          }
        } catch (error) {
          console.error(`创建用户 ${username} 失败:`, error)
          batchCreateResults.value.push({
            username: username,
            email: `${username}@${localDomain}`,
            password: userPassword,
            success: false,
            reason: 'API调用失败'
          })
        }
      }
      
      // 刷新用户列表和显示结果
      await loadUsers()
      
      const successCount = batchCreateResults.value.filter(r => r.success).length
      const existingCount = batchCreateResults.value.filter(r => !r.success && r.reason === '用户已存在').length
      const failedCount = batchCreateResults.value.filter(r => !r.success && r.reason !== '用户已存在').length
      const totalCount = batchCreateResults.value.length
      
      if (successCount > 0) {
        let message = `批量创建完成！成功创建 ${successCount}/${totalCount} 个用户，密码统一为：${userPassword}`
        if (existingCount > 0) {
          message += `，跳过 ${existingCount} 个已存在用户`
        }
        if (failedCount > 0) {
          message += `，${failedCount} 个用户创建失败`
        }
        notice.value = message
        noticeType.value = 'success'
      } else if (existingCount > 0) {
        notice.value = `所有用户都已存在，共跳过 ${existingCount} 个用户`
        noticeType.value = 'warning'
      } else {
        notice.value = '批量创建失败，请检查用户名格式和网络连接'
        noticeType.value = 'error'
      }
      
    } catch (error) {
      console.error('批量创建用户失败:', error)
      notice.value = '批量创建失败：' + error.message
      noticeType.value = 'error'
    } finally {
      batchCreating.value = false
    }
  }
  ```

#### 🔧 批量创建域名修复
- **问题描述**：修复批量创建用户时邮箱域名使用localhost的问题。
- **技术实现**：
  ```javascript
  // 获取本地域名
  const getLocalDomain = () => {
    // 尝试从系统设置获取域名
    const domains = systemSettings.value.mail?.domains || []
    if (domains.length > 0) {
      return domains[0].name
    }
    
    // 备用方案：使用默认域名
    return 'xmskills.com'
  }
  
  // 在批量创建时使用正确的域名
  const localDomain = getLocalDomain()
  const email = `${username}@${localDomain}`
  ```

#### 🔐 批量创建认证修复
- **问题描述**：修复批量创建用户时的API认证问题。
- **技术实现**：
  ```javascript
  // 确保所有API调用都包含认证头
  const response = await axios.post('/api/ops', {
    action: 'app-register',
    params: {
      username: username,
      email: email,
      password: userPassword
    }
  }, { headers: authHeader() }) // 添加认证头
  ```

#### 📊 批量创建结果展示
- **功能描述**：新增详细的批量创建结果展示，显示每个用户的创建状态、邮箱地址和密码信息。
- **技术实现**：
  ```html
  <!-- 批量创建结果展示 -->
  <div v-if="batchCreateResults.length > 0" class="mt-4 space-y-2">
    <h5 class="text-sm font-medium text-gray-900">创建结果</h5>
    <div class="space-y-2 max-h-48 overflow-y-auto">
      <div v-for="result in batchCreateResults" :key="result.username" 
           class="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
        <div class="flex-1">
          <div class="flex items-center space-x-2">
            <span class="font-medium text-gray-900">{{ result.username }}</span>
            <span class="text-sm text-gray-500">{{ result.email }}</span>
          </div>
          <div class="text-sm text-gray-600">密码: {{ result.password }}</div>
        </div>
        <div class="flex items-center space-x-2">
          <span v-if="result.success" class="text-green-600 text-sm">✓ 成功</span>
          <span v-else class="text-red-600 text-sm">✗ {{ result.reason }}</span>
        </div>
      </div>
    </div>
  </div>
  ```

### V2.8.6 (2025-10-22) - DNS配置系统全面优化版

#### 新功能特性
- **DNS配置系统全面优化**：完全重构DNS配置系统，移除所有公网DNS配置选项，专注于本地Bind DNS服务器配置，提供更简洁和专业的DNS管理体验。
- **DNS配置实时同步修复**：修复了DNS配置修改后无法正确同步到系统的问题，现在DNS配置修改会立即生效并正确更新`/etc/resolv.conf`文件。
- **DNS健康度检测增强**：新增完整的DNS健康度检测系统，包括MX记录、A记录、PTR记录、SPF记录、DKIM记录、DMARC记录的全面检测和健康度评分。
- **DNS配置持久化**：实现DNS配置的持久化存储，防止NetworkManager自动覆盖DNS设置，确保DNS配置的稳定性。
- **DNS解析测试优化**：优化DNS解析测试功能，修复了dig命令语法错误和resolv.conf解析失败的问题，提供准确的DNS状态检测。
- **用户操作日志增强**：大幅增强用户操作日志系统，新增日志分类、操作类型过滤、详细操作记录和可视化日志展示功能。

### V2.8.5 (2025-10-21) - 用户删除功能完善版

#### 新功能特性
- **用户删除功能完善**：修复了用户删除操作只删除`mailapp`数据库用户而不删除`maildb`数据库用户的问题，现在删除用户会同时清理两个数据库中的用户记录。
- **删除确认弹窗优化**：替换原生简陋的`confirm`弹窗为现代化美观的自定义弹窗，提供更好的用户体验和操作安全性。
- **数据库同步删除**：用户删除时自动同步删除`maildb.mail_users`表中的用户记录，确保数据一致性。
- **邮件记录清理**：删除用户时自动清理该用户的所有邮件记录，防止数据冗余。
- **删除操作安全性提升**：增加删除确认机制，防止误删操作。

### V2.3.6 (2025-10-12) - DNS配置简化和系统安装流程完善版

#### 新功能特性
- **DNS配置简化**：移除DNS配置中的DKIM密钥生成功能，简化DNS配置流程，专注于核心DNS解析功能，提高配置效率和稳定性
- **调度层依赖安装优化**：大幅优化调度层依赖安装逻辑，增加网络检查、镜像切换、依赖验证等机制，确保依赖安装成功率
- **服务启动自动修复**：增强调度层服务启动失败时的自动诊断和修复功能，包括依赖重新安装、权限修复、服务重启等
- **脚本执行优化**：修复start.sh脚本中的return语句错误，优化前端依赖安装超时处理，提升整体安装稳定性
- **系统安装流程完善**：统一安装流程，删除多余的修复脚本，专注于完善start.sh脚本本身，确保重装时一次性成功

#### 技术实现细节
- **DNS配置简化**：移除DKIM密钥生成函数和相关配置，专注于A、MX、SPF、DMARC记录
- **依赖安装优化**：增加网络连接检查、npm镜像切换、超时时间延长、备用安装方案
- **自动修复机制**：服务启动失败时自动重新安装依赖、验证关键依赖、修复权限问题
- **脚本错误修复**：修复非函数上下文中的return语句错误，改为exit语句
- **安装流程统一**：删除多余的修复脚本，将所有修复逻辑集成到start.sh中

#### 修复的问题
- **DNS配置复杂性问题**：移除DKIM密钥生成功能，简化DNS配置流程
- **调度层依赖安装失败**：优化依赖安装逻辑，增加网络检查和镜像切换
- **服务启动失败问题**：增强自动诊断和修复功能，确保服务能够正常启动
- **脚本执行错误**：修复return语句错误，优化前端依赖安装超时处理
- **安装流程分散问题**：统一安装流程，删除多余的修复脚本

#### 升级说明
- **DNS配置**：DNS配置不再包含DKIM功能，专注于核心DNS解析
- **依赖安装**：调度层依赖安装现在更加稳定和可靠
- **安装流程**：系统安装流程已统一，无需额外的修复脚本
- **脚本优化**：所有修复逻辑已集成到start.sh脚本中

### V2.3.5 (2025-10-11) - DNS配置服务完善和邮件服务安装修复版

#### 新功能特性
- **DNS配置服务完善**：新增完整的DNS配置功能，支持本地Bind DNS服务器和公网DNS配置，包括正向解析、反向解析、MX记录等完整DNS记录配置
- **邮件服务安装修复**：修复了邮件服务安装失败的问题，通过优化脚本执行逻辑和错误处理机制，确保邮件服务能够正确安装和启动
- **操作日志对话框优化**：新增独立的操作日志对话框，提供更好的用户体验，支持实时日志显示和操作状态跟踪
- **配置服务弹窗优化**：配置服务弹窗现在采用与安装服务相同的逻辑，点击后立即关闭弹窗并显示操作日志对话框
- **DKIM功能支持**：集成DKIM密钥生成功能，提升邮件安全性和投递率，支持邮件身份验证和完整性保护

#### 技术实现细节
- **DNS配置功能**：支持Bind DNS服务器配置，包括正向解析、反向解析、MX记录等
- **邮件服务修复**：优化mail_setup.sh脚本执行逻辑，添加错误处理机制
- **操作日志优化**：新增独立的操作日志对话框HTML结构
- **弹窗逻辑统一**：配置服务弹窗采用与安装服务相同的立即关闭逻辑
- **DKIM集成**：集成DKIM密钥生成功能，支持邮件身份验证

#### 修复的问题
- **邮件服务安装失败**：修复了mail_setup.sh脚本的set -euo pipefail问题，确保脚本在命令失败时继续执行
- **操作日志不显示**：新增独立的操作日志对话框HTML结构，解决操作日志不显示的问题
- **配置服务弹窗行为不一致**：统一配置服务弹窗和安装服务弹窗的行为逻辑
- **DNS配置功能缺失**：新增完整的DNS配置功能，支持本地和公网DNS配置

#### 升级说明
- **前端更新**：需要重新构建前端以应用操作日志对话框的HTML结构
- **后端更新**：需要更新mail_setup.sh脚本以修复邮件服务安装问题
- **DNS配置**：新增DNS配置功能，支持Bind DNS服务器和公网DNS配置
- **DKIM功能**：集成DKIM密钥生成功能，需要OpenDKIM软件包支持

### V2.3.4 (2025-10-11) - 安装服务弹窗自动关闭修复和操作日志显示优化版

#### 新功能特性
- **安装服务弹窗自动关闭修复**：修复了安装服务弹窗无法自动关闭的问题，现在点击"开始安装"后弹窗会自动关闭，提供更好的用户体验
- **操作日志显示优化**：修复了安装服务时操作日志不显示的问题，现在会正确显示操作ID和详细的安装进度信息
- **轮询机制优化**：解决了安装服务过程中页面自动刷新多次的问题，通过统一轮询机制避免了重复的API请求和页面刷新
- **安装服务执行优化**：修复了安装服务卡在"正在执行"状态的问题，通过改进的监控机制确保安装过程能够正常完成
- **用户体验提升**：安装服务功能现在提供完整的操作反馈，包括进度显示、结果汇总和自动弹窗关闭

#### 技术实现细节
- **弹窗关闭机制**：修复了`closeInstallDialog`函数的调用逻辑，确保弹窗能够正确关闭
- **操作日志显示**：添加了`opId`设置，确保操作日志对话框能够正确显示
- **轮询机制统一**：创建了`callWithoutPolling`函数，避免多重轮询导致的页面刷新问题
- **监控机制改进**：改进了脚本执行监控机制，最多等待30秒，每1秒检查一次状态
- **调试信息增强**：添加了详细的调试信息，帮助诊断和解决问题

#### 修复的问题
- 安装服务弹窗无法自动关闭
- 操作日志不显示具体信息
- 页面自动刷新多次
- 安装服务卡在"正在执行"状态
- 用户体验不佳

### V2.3.3 (2025-10-11) - 安装服务操作日志完善和DNSPod支持版

#### 新功能特性
- **安装服务操作日志完善**：完善了安装服务功能，在操作日志最后显示详细的安装结果汇总
- **DNSPod支持集成**：添加了DNSPod (腾讯云) DNS服务商支持
- **公网DNS配置增强**：支持多种DNS服务商，提供统一的配置界面
- **安装结果跟踪优化**：实现每个服务安装状态的实时跟踪
- **用户体验提升**：使用友好的服务显示名称和状态图标

#### 技术实现
- **前端安装结果收集**：实现安装结果跟踪，收集每个服务的成功/失败状态
- **后端API优化**：添加脚本执行结果记录，跟踪退出码和时间戳
- **DNSPod API集成**：实现完整的DNSPod API调用，支持自动配置DNS记录
- **公网DNS配置界面**：完善前端DNS提供商选择界面，添加DNSPod参数输入
- **安装结果汇总**：实现安装结果汇总生成，在操作日志中显示详细统计

### V2.3.2 (2025-10-11) - 系统稳定性和用户体验优化版

#### 关键修复
- **DNS配置失败问题修复**：彻底修复了DNS配置一直显示"失败"的问题
- **脚本错误处理优化**：提高脚本的健壮性和容错能力
- **防火墙配置容错处理**：添加防火墙状态检查
- **配置文件检查优化**：named-checkconf命令失败时不再导致脚本退出
- **sudoers语法错误修复**：修复了sudoers配置中的语法错误
- **重复日志输出修复**：修复了start.sh脚本中重复输出日志路径的问题
- **安装服务操作日志修复**：修复了安装服务功能中操作日志不显示的问题

### V2.3.1 (2025-10-11) - DNS配置服务修复版

#### 新功能特性
- **DNS配置服务修复**：修复了配置服务弹窗中DNS选择功能的"操作失败 invalid action"错误
- **后端action处理完善**：在server.js中添加了configure-bind和configure-public action的处理逻辑
- **DNS脚本参数优化**：dns_setup.sh脚本现在支持configure-bind和configure-public参数格式
- **智能参数处理**：configure模式自动获取服务器IP地址，设置默认管理员邮箱

### V2.3.0 (2025-10-11) - 用户权限识别修复版

#### 关键修复
- **用户权限识别修复**：修复了所有用户都被识别为xm管理员的严重安全问题
- **登录认证优化**：使用用户输入的用户名和密码创建认证令牌
- **权限控制增强**：普通用户和管理员功能完全隔离
- **安全隔离完善**：不同用户只能访问其权限范围内的功能

### V2.2.7 (2025-10-10) - DNS配置管理与自动化部署

#### 新功能特性
- **DNS配置管理**：添加了DNS配置管理功能，支持本地DNS和公网DNS配置
- **自动化部署**：完善了自动化部署流程，支持一键配置DNS服务
- **配置向导**：提供了友好的DNS配置向导界面

### V2.2.6 (2025-10-10) - DNS解析状态监控与邮件功能完善

#### 功能增强
- **DNS解析监控**：添加了DNS解析状态监控功能
- **邮件功能完善**：完善了邮件发送和接收功能
- **状态检测**：增强了系统状态检测能力

### V2.2.5 (2025-10-10) - 系统状态监控信息大幅增强

#### 监控功能
- **系统状态监控**：大幅增强了系统状态监控信息
- **资源监控**：添加了详细的系统资源监控
- **性能指标**：提供了完整的系统性能指标

### V2.2.4 (2025-10-10) - 导航栏闪烁修复与服务状态检测增强

#### 界面修复
- **导航栏修复**：修复了导航栏闪烁问题
- **服务状态检测**：增强了服务状态检测功能
- **用户体验**：改善了用户界面体验

### V2.2.3 (2025-10-10) - 日志系统详细记录与智能解析 + 豪华系统设置

#### 日志系统
- **详细记录**：实现了详细的日志记录系统
- **智能解析**：添加了日志智能解析功能
- **豪华设置**：提供了豪华的系统设置界面

### V2.2.2 (2025-10-10) - 智能补全功能全面优化

#### 智能功能
- **智能补全**：全面优化了智能补全功能
- **用户体验**：提升了用户操作体验
- **功能完善**：完善了各种智能功能

### V2.2.1 (2025-10-10) - 系统管理功能全面升级

#### 管理功能
- **系统管理**：全面升级了系统管理功能
- **用户管理**：完善了用户管理功能
- **权限控制**：增强了权限控制系统

### V2.2.0 (2025-10-10) - 网络优化与安全审计增强

#### 网络与安全
- **网络优化**：优化了网络配置和性能
- **安全审计**：增强了安全审计功能
- **系统稳定性**：提升了系统整体稳定性

### V2.1.3 (2025-10-09) - 用户界面优化与交互体验提升

#### 界面优化
- **用户界面**：优化了用户界面设计
- **交互体验**：提升了用户交互体验
- **响应式设计**：改善了响应式布局

### V2.1.2 (2025-10-09) - 用户管理功能完善与调试系统增强

#### 用户管理
- **用户管理**：完善了用户管理功能
- **调试系统**：增强了调试系统功能
- **错误处理**：改善了错误处理机制

### V2.1.1 (2025-10-09) - 脚本输出优化与用户体验提升

#### 脚本优化
- **脚本输出**：优化了脚本输出格式
- **用户体验**：提升了用户体验
- **日志记录**：改善了日志记录系统

### V2.1.0 (2025-10-09) - 构建系统优化与稳定性提升

#### 构建系统
- **构建优化**：优化了构建系统
- **稳定性提升**：提升了系统稳定性
- **部署改进**：改善了部署流程

### V2.0.2 (2025-10-09) - 前端界面美化与动画系统

#### 界面美化
- **界面美化**：美化了前端界面
- **动画系统**：添加了流畅的动画效果
- **用户体验**：提升了用户体验

### V2.0.1 (2025-10-08) - 用户日志记录系统

#### 日志系统
- **用户日志**：实现了用户日志记录系统
- **操作跟踪**：添加了操作跟踪功能
- **审计功能**：增强了审计功能

### V2.0.0 (2025-10-08) - 系统稳定版

#### 重大更新
- **系统稳定性**：经过大量测试和优化，系统已达到生产环境稳定状态
- **用户体验**：全面优化用户界面和操作流程，提供流畅的管理体验
- **功能完善**：所有核心功能已完善，支持完整的邮件服务管理

#### 核心功能
- **智能用户管理**：支持用户创建、更新、密码重置，支持重复运行安装脚本
- **调度器优化**：修复输出重复问题，提供清晰的操作日志
- **数据库管理**：自动初始化数据库，支持用户和域管理
- **前端界面**：Vue 3 管理界面，支持管理员和普通用户分流
- **帮助系统**：完善的帮助命令和用户指南

### V1.x 版本历史（已整合到 V2.0.0）

#### 主要版本里程碑
- **v1.9.x**：系统稳定性和用户体验优化
- **v1.8.x**：调度层与数据库集成
- **v1.7.x**：前端超时和完成检测优化
- **v1.6.x**：登录认证和权限修复
- **v1.5.x**：账户密码统一管理
- **v1.4.x**：xm 用户管理与权限优化
- **v1.3.x**：权限管理与脚本统一优化
- **v1.2.x**：系统稳定性优化
- **v1.1.x**：基础功能完善
- **v1.0.0**：初始版本发布

#### 关键修复和改进
- ✅ 修复双重认证问题
- ✅ 优化脚本执行顺序
- ✅ 增强 MariaDB 安装和初始化
- ✅ 完善帮助命令系统
- ✅ 实现智能用户管理
- ✅ 修复输出重复问题
- ✅ 优化前端用户体验
- ✅ 增强系统安全性
- ✅ 完善错误处理机制
- ✅ 实现执行时间统计

### V1.9.16 (2025-10-08) - 调度器输出重复问题根本修复

#### 问题根因
- **调度器重复处理**：`backend/dispatcher/server.js` 中的 `runScript` 函数存在输出重复处理问题
- **双重管道**：脚本输出被同时通过 `pipe()` 和 `data` 事件处理器写入，导致输出重复
- **前端显示重复**：所有通过调度器执行的脚本都会显示两遍输出

#### 修复内容
- **移除重复处理**：删除 `child.stdout.on('data')` 和 `child.stderr.on('data')` 事件处理器
- **保留管道处理**：只使用 `child.stdout.pipe(out)` 和 `child.stderr.pipe(out)` 进行输出处理
- **避免重复写入**：确保每个输出只被写入一次到日志文件

### V1.9.15 (2025-10-08) - 脚本输出重复问题彻底修复

#### 问题修复
- **输出重复问题**：彻底修复 `mail_setup.sh` 脚本中所有剩余的 `>&1` 重定向导致的输出重复问题
- **完整清理**：移除所有不必要的 `>&1` 重定向，包括 `health_check` 函数中的输出
- **用户体验改善**：前端操作现在只显示一次输出，不再有重复信息

### V1.9.14 (2025-10-08) - 智能用户管理功能

#### 新功能与改进
- **智能用户管理**：新增 `app_user.sh update` 命令，支持检查用户是否存在，存在则更新密码，不存在则创建
- **重复运行支持**：`start.sh` 现在可以安全地重复运行，自动处理 `xm` 用户的创建和更新
- **密码重置保障**：确保 `xm` 用户密码始终为 `xm666@`，支持重新安装和修复

### V1.9.13 (2025-10-08) - 数据库重复键错误修复

#### 问题修复
- **重复键错误**：修复 `ERROR 1062 (23000): Duplicate entry 'xm' for key 'username'` 错误
- **脚本语法错误**：修复 `start.sh` 中 `local` 关键字在函数外使用的语法错误
- **用户注册逻辑**：改进 `app_user.sh` 中的用户注册逻辑，先检查用户是否存在再插入

### V1.9.12 (2025-10-08) - 脚本输出重复问题修复

#### 修复内容
- **输出重复问题**：修复 `mail_setup.sh` 脚本中的输出重复问题
- **重定向优化**：优化脚本中的输出重定向，避免重复显示
- **用户体验**：改善前端操作的用户体验

### V1.9.11 (2025-10-08) - Apache 配置优化

#### 配置优化
- **Apache配置**：优化了Apache配置文件
- **性能提升**：提升了Web服务器性能
- **稳定性增强**：增强了系统稳定性

### V1.9.10 (2025-10-08) - 脚本执行顺序修复

#### 执行顺序
- **脚本顺序**：修复了脚本执行顺序问题
- **依赖关系**：优化了脚本间的依赖关系
- **执行效率**：提升了脚本执行效率

### V1.9.9 (2025-10-08) - MariaDB 安装与初始化增强

#### 数据库增强
- **MariaDB安装**：增强了MariaDB的安装过程
- **数据库初始化**：完善了数据库初始化流程
- **数据完整性**：确保了数据的完整性

### V1.9.8 (2025-10-08) - 帮助命令完善与用户体验优化

#### 帮助系统
- **帮助命令**：完善了帮助命令系统
- **用户指南**：提供了详细的用户指南
- **用户体验**：优化了用户体验

### V1.9.7 (2025-10-08) - MySQL 客户端安装与数据库初始化修复

#### 数据库修复
- **MySQL客户端**：修复了MySQL客户端安装问题
- **数据库初始化**：修复了数据库初始化问题
- **连接问题**：解决了数据库连接问题

### V1.9.6 (2025-10-07) - 数据库初始化增强与登录修复

#### 数据库增强
- **初始化增强**：增强了数据库初始化功能
- **登录修复**：修复了用户登录问题
- **权限管理**：完善了权限管理系统

### V1.9.5 (2025-10-07) - 执行时间统计与性能监控

#### 性能监控
- **执行时间统计**：添加了执行时间统计功能
- **性能监控**：实现了性能监控系统
- **优化建议**：提供了性能优化建议

### V1.9.4 (2025-10-07) - 用户管理优化与调试增强

#### 用户管理
- **用户管理优化**：优化了用户管理功能
- **调试增强**：增强了调试功能
- **错误处理**：改善了错误处理机制

### V1.9.3 (2025-10-07) - 配置向导、严格登录与安全加固

#### 安全加固
- **配置向导**：添加了配置向导功能
- **严格登录**：实现了严格的登录验证
- **安全加固**：增强了系统安全性

### V1.9.2 (2025-10-06) - 应用库初始化职责调整与前端文案同步

#### 职责调整
- **应用库初始化**：调整了应用库初始化职责
- **前端文案**：同步了前端文案
- **功能完善**：完善了相关功能

### V1.9.1 (2025-10-06) - 邮件面板路由与稳定性

#### 邮件面板
- **路由修复**：修复了邮件面板路由问题
- **稳定性提升**：提升了系统稳定性
- **功能完善**：完善了邮件面板功能

### V1.8.0 (2025-10-06) - 调度层与数据库初始化集成

#### 系统集成
- **调度层集成**：集成了调度层功能
- **数据库初始化**：完善了数据库初始化
- **系统架构**：优化了系统架构

### V1.7.0 (2025-10-06) - 前端超时与完成检测优化

#### 前端优化
- **超时处理**：优化了前端超时处理
- **完成检测**：完善了完成检测功能
- **用户体验**：提升了用户体验

### V1.6.0 (2025-10-06) - 登录认证与权限修复

#### 认证修复
- **登录认证**：修复了登录认证问题
- **权限修复**：修复了权限控制问题
- **安全增强**：增强了系统安全性

### V1.5.0 (2025-10-06) - 账户密码统一管理

#### 密码管理
- **密码统一**：实现了账户密码统一管理
- **安全增强**：增强了密码安全性
- **管理便利**：提升了密码管理便利性

### V1.4.0 (2025-10-06) - xm 用户管理与权限优化

#### 用户管理
- **xm用户管理**：完善了xm用户管理功能
- **权限优化**：优化了权限控制系统
- **安全提升**：提升了系统安全性

### V1.3.0 (2025-10-06) - 权限管理与脚本统一优化

#### 权限管理
- **权限管理**：完善了权限管理系统
- **脚本统一**：统一了脚本管理
- **功能优化**：优化了相关功能

### V1.2.0 (2025-10-06) - 系统稳定性优化

#### 稳定性优化
- **系统稳定性**：优化了系统稳定性
- **错误处理**：改善了错误处理机制
- **性能提升**：提升了系统性能

### V1.1.0 (2025-10-05) - 基础功能完善

#### 基础功能
- **基础功能**：完善了基础功能
- **系统架构**：建立了系统架构
- **核心功能**：实现了核心功能

### V1.0.0 (2025-10-05) - 初始版本

#### 初始发布
- **初始版本**：发布了初始版本
- **基础架构**：建立了基础架构
- **核心功能**：实现了核心功能

## 故障排除

### 常见问题解决

#### 1. 服务启动失败
```bash
# 检查服务状态
sudo systemctl status httpd mariadb postfix dovecot

# 查看错误日志
sudo journalctl -u service_name -f

# 重启服务
sudo systemctl restart service_name
```

#### 2. 数据库连接问题
```bash
# 检查数据库状态
sudo systemctl status mariadb

# 测试数据库连接
mysql -u root -p -e "SHOW DATABASES;"

# 重启数据库服务
sudo systemctl restart mariadb
```

#### 3. 邮件发送问题
```bash
# 检查邮件队列
postqueue -p

# 查看邮件日志
sudo tail -f /var/log/maillog

# 测试邮件发送
echo "Test email" | mail -s "Test" admin@localhost
```

#### 4. 前端访问问题
```bash
# 检查Apache状态
sudo systemctl status httpd

# 检查虚拟主机配置
sudo apachectl configtest

# 重启Apache
sudo systemctl restart httpd
```

### 日志分析

#### 1. 系统日志
```bash
# 查看系统日志
sudo journalctl -f

# 查看特定服务日志
sudo journalctl -u service_name -f
```

#### 2. 邮件日志
```bash
# 查看邮件日志
sudo tail -f /var/log/maillog

# 查看Postfix日志
sudo tail -f /var/log/mail.log
```

#### 3. 应用日志
```bash
# 查看应用日志
tail -f /var/log/mail-ops/install.log
tail -f /var/log/mail-ops/operations.log
tail -f /var/log/mail-ops/system.log
```

## V2.5.6 详细更新内容

### 新增功能

#### 1. 邮件系统服务状态检查
- **API端点**：`/api/mail/service-status`
- **检查项目**：
  - Postfix邮件发送服务状态
  - Dovecot邮件接收服务状态
  - Bind DNS域名解析服务状态
  - MariaDB数据库服务状态
  - DNS解析配置验证
  - 邮件数据库状态检查

#### 2. 智能提醒系统
- **自动检查**：邮件页面加载时自动检查服务状态
- **可视化显示**：使用颜色编码显示服务状态（绿色=正常，红色=异常）
- **详细建议**：根据服务状态生成具体的配置建议和操作指导
- **操作按钮**：提供"重新检查"和"前往系统配置"按钮

#### 3. 用户流程优化
- **配置引导**：引导用户按照正确顺序完成系统配置
- **功能限制**：只有在系统完全配置后才允许使用邮件功能
- **实时检查**：支持实时重新检查服务状态
- **一键跳转**：提供一键跳转到系统配置页面的功能

### 技术实现

#### 后端API增强
```javascript
// 新增服务状态检查API
app.get('/api/mail/service-status', auth, (req, res) => {
  // 检查所有邮件相关服务状态
  // 验证DNS解析配置
  // 检查邮件数据库状态
  // 生成配置建议
})
```

#### 前端界面改进
```vue
// 服务状态检查逻辑
async function checkServiceStatus() {
  // 调用服务状态API
  // 更新服务状态显示
  // 显示警告界面（如需要）
}

// 服务状态可视化
<div class="service-status">
  <div class="status-item" :class="serviceStatus.services.postfix ? 'running' : 'stopped'">
    Postfix (邮件发送服务)
  </div>
  <!-- 其他服务状态显示 -->
</div>
```

### 使用说明

#### 1. 服务状态检查
- 访问邮件页面时自动检查服务状态
- 如果服务未配置，显示详细的配置指导
- 点击"重新检查"按钮可实时更新状态

#### 2. 配置指导
- 根据服务状态显示具体的配置建议
- 提供一键跳转到系统配置页面
- 支持分步骤完成系统配置

#### 3. 故障排除
- 查看服务状态颜色编码
- 根据建议完成相应配置
- 使用"重新检查"验证配置结果

## 联系支持

如果在更新过程中遇到问题，请：

1. 检查系统日志文件
2. 查看错误信息
3. 参考故障排除部分
4. 联系系统管理员

---

**注意**：在执行任何更新操作之前，请务必备份重要数据和配置文件。
