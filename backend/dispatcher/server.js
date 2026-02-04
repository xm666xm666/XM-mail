import express from 'express'
import morgan from 'morgan'
import basicAuth from 'basic-auth'
import { spawn, spawnSync, execSync, exec } from 'child_process'
import { promisify } from 'util'
import { v4 as uuidv4 } from 'uuid'
import path from 'path'
import fs from 'fs'
import { fileURLToPath } from 'url'
import nodemailer from 'nodemailer'
import crypto from 'crypto'
import multer from 'multer'

// 将 exec 转换为 Promise
const execAsync = promisify(exec)

// 异步执行命令的辅助函数（带超时和错误处理）
async function execCommandAsync(command, timeout = 3000) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error(`Command timeout after ${timeout}ms`))
    }, timeout)
    
    exec(command, { encoding: 'utf8', maxBuffer: 1024 * 1024 }, (error, stdout, stderr) => {
      clearTimeout(timer)
      if (error) {
        reject(error)
      } else {
        resolve(stdout.trim())
      }
    })
  })
}

import http from 'http'
import { WebSocketServer } from 'ws'

// ESM 下构造 __dirname/__filename，确保 systemd 下路径解析稳定
const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()

// WebSocket 路径检查中间件 - 必须在其他中间件之前
// 注意：WebSocket 升级请求应该触发 upgrade 事件，而不是通过 Express 路由处理
// 但如果请求到达了 Express（说明 Apache 代理有问题），我们需要处理它
app.use((req, res, next) => {
  // 如果是 WebSocket 路径，检查是否是升级请求
  if (req.path === '/api/terminal/ws') {
    console.log(`[TERMINAL_WS] Express middleware intercepted: ${req.path}, upgrade: ${req.headers.upgrade}`)
    console.log(`[TERMINAL_WS] Connection header: ${req.headers.connection}`)
    console.log(`[TERMINAL_WS] All headers:`, JSON.stringify(req.headers, null, 2))
    
    // 如果不是 WebSocket 升级请求，返回错误
    if (!req.headers.upgrade || req.headers.upgrade.toLowerCase() !== 'websocket') {
      console.log(`[TERMINAL_WS] Not a WebSocket upgrade request, returning 426`)
      return res.status(426).json({
        error: 'Upgrade Required',
        message: 'This endpoint requires WebSocket protocol upgrade'
      })
    }
    
    // 如果是 WebSocket 升级请求，但不应该到达这里
    // 说明 Apache 代理配置有问题
    console.log(`[TERMINAL_WS] WARNING: WebSocket upgrade request reached Express middleware!`)
    console.log(`[TERMINAL_WS] This should be handled by server.on('upgrade') event`)
    return res.status(500).json({
      error: 'WebSocket configuration error',
      message: 'WebSocket upgrade request should be handled by HTTP server upgrade event'
    })
  }
  next()
})

// 增加body大小限制以支持大附件上传
// Base64编码后约为原文件的1.33倍，50MB附件约66MB，加上邮件正文等，设置为100MB以确保安全
app.use(express.json({ limit: '100mb' }))
app.use(express.urlencoded({ extended: true, limit: '100mb' }))
app.use(morgan('combined'))

// 配置Express信任代理，以正确获取真实IP
app.set('trust proxy', true)

// CORS中间件 - 处理跨域请求（特别是HTTP到HTTPS重定向的情况）
app.use((req, res, next) => {
  // 获取请求的Origin
  const origin = req.headers.origin || req.headers.referer?.replace(/\/$/, '') || '*'
  
  // 设置CORS头
  res.header('Access-Control-Allow-Origin', origin)
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS, PATCH')
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, X-Auth-Token')
  res.header('Access-Control-Allow-Credentials', 'true')
  res.header('Access-Control-Max-Age', '86400') // 24小时
  
  // 处理预检请求（OPTIONS）
  if (req.method === 'OPTIONS') {
    return res.status(200).end()
  }
  
  next()
})

// 垃圾邮件检测函数
function checkSpamContent(subject, content, from, to, spamConfig) {
  const violations = []
  const detectedKeywords = []
  let spamScore = 0
  
  // 检查是否为答复邮件（Subject以"Re:"或"RE:"开头）
  const isReplyEmail = subject && (subject.trim().toLowerCase().startsWith('re:') || subject.trim().toUpperCase().startsWith('RE:'))
  
  // 检查关键词（所有邮件都检查关键词）
  const allKeywords = [...(spamConfig.keywords.chinese || []), ...(spamConfig.keywords.english || [])]
  const fullText = `${subject || ''} ${content || ''}`.toLowerCase()
  
  for (const keyword of allKeywords) {
    if (fullText.includes(keyword.toLowerCase())) {
      detectedKeywords.push(keyword)
      spamScore += 10
    }
  }
  
  if (detectedKeywords.length > 0) {
    violations.push({
      type: 'keywords',
      message: `检测到违禁关键词: ${detectedKeywords.join(', ')}`,
      keywords: detectedKeywords
    })
  }
  
  // 检查域名黑名单（所有邮件都检查域名黑名单）
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
  
  if (spamConfig.domainBlacklist.includes(toDomain)) {
    violations.push({
      type: 'domain_blacklist',
      message: `收件人域名在黑名单中: ${toDomain}`,
      domain: toDomain
    })
    spamScore += 30
  }
  
  // 答复邮件跳过内容规则检查（行数、大写比例、感叹号、特殊字符等）
  // 只检查关键词和域名黑名单
  if (isReplyEmail) {
    console.log(`[垃圾邮件检测] 检测到答复邮件，跳过内容规则检查: subject=${subject}`)
    return {
      isSpam: violations.length > 0,
      spamScore,
      violations,
      detectedKeywords,
      summary: violations.length > 0 ? 
        `检测到 ${violations.length} 项违规（仅关键词/域名检查），垃圾邮件评分: ${spamScore}` : 
        '邮件内容正常（答复邮件，已跳过内容规则检查）'
    }
  }
  
  // 检查内容规则（仅对非答复邮件）
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
    
    // 检查大写字母比例
    const uppercaseCount = (content.match(/[A-Z]/g) || []).length
    const totalLetters = (content.match(/[a-zA-Z]/g) || []).length
    const uppercaseRatio = totalLetters > 0 ? uppercaseCount / totalLetters : 0
    
    if (uppercaseRatio > spamConfig.rules.uppercaseRatio) {
      violations.push({
        type: 'content_rules',
        message: `大写字母比例过高 (${(uppercaseRatio * 100).toFixed(1)}%/${(spamConfig.rules.uppercaseRatio * 100).toFixed(1)}%)`,
        current: uppercaseRatio,
        threshold: spamConfig.rules.uppercaseRatio
      })
      spamScore += 15
    }
    
    // 检查感叹号数量
    const exclamationCount = (content.match(/!/g) || []).length
    if (exclamationCount > spamConfig.rules.maxExclamationMarks) {
      violations.push({
        type: 'content_rules',
        message: `感叹号数量过多 (${exclamationCount}/${spamConfig.rules.maxExclamationMarks})`,
        current: exclamationCount,
        max: spamConfig.rules.maxExclamationMarks
      })
      spamScore += 10
    }
    
    // 检查特殊字符数量
    const specialCharCount = (content.match(/[!@#$%^&*()_+={}[\]|\\:";'<>?,./]/g) || []).length
    if (specialCharCount > spamConfig.rules.maxSpecialChars) {
      violations.push({
        type: 'content_rules',
        message: `特殊字符数量过多 (${specialCharCount}/${spamConfig.rules.maxSpecialChars})`,
        current: specialCharCount,
        max: spamConfig.rules.maxSpecialChars
      })
      spamScore += 8
    }
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

// 获取真实客户端IP地址的函数
function getRealClientIP(req) {
  // 按优先级检查各种可能的IP头
  const ipHeaders = [
    'x-forwarded-for',     // 负载均衡器/代理
    'x-real-ip',           // Nginx代理
    'x-client-ip',         // 其他代理
    'cf-connecting-ip',    // Cloudflare
    'x-cluster-client-ip', // 集群
    'x-forwarded',         // 其他转发
    'forwarded-for',       // 其他转发
    'forwarded'            // RFC 7239
  ]
  
  // 检查每个可能的IP头
  for (const header of ipHeaders) {
    const value = req.headers[header]
    if (value) {
      // x-forwarded-for 可能包含多个IP，取第一个（原始客户端IP）
      const ip = value.split(',')[0].trim()
      if (ip && ip !== 'unknown' && ip !== '::1' && ip !== '127.0.0.1') {
        return ip
      }
    }
  }
  
  // 如果代理头都没有，使用Express的req.ip
  if (req.ip && req.ip !== '::1' && req.ip !== '127.0.0.1') {
    return req.ip
  }
  
  // 最后回退到连接地址
  return req.connection?.remoteAddress || req.socket?.remoteAddress || 'unknown'
}

// Resolve paths relative to the dispatcher file location to be systemd-safe
const DISPATCHER_DIR = __dirname
const ROOT_DIR = path.resolve(DISPATCHER_DIR, '..', '..')
const BACKEND_DIR = path.resolve(DISPATCHER_DIR, '..')

// 读取端口配置
function getPortConfig() {
  // 环境变量优先级最高
  if (process.env.PORT) {
    const envPort = parseInt(process.env.PORT, 10)
    if (!isNaN(envPort)) {
      console.log(`[PORT_CONFIG] 使用环境变量端口: ${envPort}`)
      return envPort
    }
  }
  
  const portConfigFile = path.join(ROOT_DIR, 'config', 'port-config.json')
  let apiPort = 8081 // 默认端口
  
  try {
    if (fs.existsSync(portConfigFile)) {
      const portConfig = JSON.parse(fs.readFileSync(portConfigFile, 'utf8'))
      if (portConfig.api && portConfig.api.port) {
        apiPort = parseInt(portConfig.api.port, 10)
        if (!isNaN(apiPort)) {
          console.log(`[PORT_CONFIG] 从配置文件读取端口: ${apiPort} (文件: ${portConfigFile})`)
          return apiPort
        }
      }
    } else {
      console.warn(`[PORT_CONFIG] 端口配置文件不存在: ${portConfigFile}，使用默认端口 8081`)
    }
  } catch (error) {
    console.warn(`[PORT_CONFIG] 读取端口配置失败，使用默认端口 8081:`, error.message)
  }
  
  console.log(`[PORT_CONFIG] 使用默认端口: ${apiPort}`)
  return apiPort
}

const PORT = getPortConfig()
const SCRIPTS_DIR = process.env.SCRIPTS_DIR || path.join(ROOT_DIR, 'backend', 'scripts')
const LOG_DIR = process.env.LOG_DIR || '/var/log/mail-ops'
const APP_DB_PASS_FILE = '/etc/mail-ops/app-db.pass'
const MAIL_DB_PASS_FILE = '/etc/mail-ops/mail-db.pass'

// 读取应用数据库密码
function getAppDbPassword() {
  try {
    if (fs.existsSync(APP_DB_PASS_FILE)) {
      return fs.readFileSync(APP_DB_PASS_FILE, 'utf8').trim()
    }
  } catch (error) {
    console.error('Failed to read app-db.pass file:', error.message)
  }
  // 如果文件不存在或读取失败，使用默认值
  return process.env.APP_DB_PASS || 'mailapppass'
}

// 读取邮件数据库密码
function getMailDbPassword() {
  try {
    if (fs.existsSync(MAIL_DB_PASS_FILE)) {
      return fs.readFileSync(MAIL_DB_PASS_FILE, 'utf8').trim()
    }
  } catch (error) {
    console.error('Failed to read mail-db.pass file:', error.message)
  }
  // 如果文件不存在或读取失败，使用默认值（向后兼容）
  return process.env.MAIL_DB_PASS || 'mailpass'
}

// 构建maildb数据库MySQL命令的辅助函数
function buildMailDbQuery(query) {
  const mailDbPass = getMailDbPassword()
  const escapedPass = mailDbPass.replace(/"/g, '\\"').replace(/\$/g, '\\$')
  return `mysql -u mailuser -p"${escapedPass}" maildb -e "${query}"`
}

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
  'app-update',
  'check-user-exists',
  'fix-email-domains',
  'install-cert',
  'enable-ssl',
  'enable-http-redirect',
  'setup-logs',
  'full-backup',
  'setup-cron',
  'setup-backup-cron',
  'health',
  'configure-bind',
  'configure-public',
  'install-mail',
  'install-database',
  'install-dns',
  'install-security',
  'restart-mail',
  'restart-database',
  'restart-dns',
  'restart-security',
  'restart-dispatcher',
  'stop-mail',
  'stop-database',
  'stop-dns',
  'stop-security',
  'stop-dispatcher'
])

fs.mkdirSync(LOG_DIR, { recursive: true })

function ensureLogDirWritable() {
  try {
    // quick write test
    const testFile = path.join(LOG_DIR, '.write-test')
    fs.writeFileSync(testFile, 'ok')
    fs.unlinkSync(testFile)
    return true
  } catch (e) {
    // attempt self-heal via sudo (NOPASSWD expected for xm)
    try {
      const cmd = `mkdir -p '${LOG_DIR}' && chown -R xm:xm '${LOG_DIR}' && chmod 775 '${LOG_DIR}'`
      spawnSync('sudo', ['bash', '-lc', cmd], { stdio: 'ignore' })
    } catch {}
    try {
      const testFile = path.join(LOG_DIR, '.write-test')
      fs.writeFileSync(testFile, 'ok')
      fs.unlinkSync(testFile)
      return true
    } catch (e2) {
      return false
    }
  }
}

// 从请求中获取用户名
function getUsernameFromRequest(req) {
  if (req.headers.authorization) {
    try {
      const authHeader = req.headers.authorization
      if (authHeader.startsWith('Basic ')) {
        const encoded = authHeader.substring(6)
        const decoded = Buffer.from(encoded, 'base64').toString()
        return decoded.split(':')[0] || 'unknown'
      }
    } catch (e) {
      console.error('Error parsing authorization header:', e)
    }
  }
  return 'unknown'
}

// 从用户名获取用户ID（从app_users表）
function getUserIdFromUsername(username, callback) {
  if (!username || username === 'unknown') {
    return callback(null, null)
  }
  
  // 查询app_users表获取用户ID
  const dbPass = getAppDbPassword()
  const escapedUsername = username.replace(/'/g, "''")
  const query = `mysql -u mailappuser --password="${dbPass.replace(/"/g, '\\"')}" mailapp -s -r -e "SELECT id FROM app_users WHERE username='${escapedUsername}' OR email='${escapedUsername}' LIMIT 1;" 2>&1 | tail -1`
  
  exec(query, (error, stdout, stderr) => {
    if (error) {
      console.error('Error getting user ID:', error)
      return callback(null, null)
    }
    
    const userId = stdout.trim()
    if (userId && !isNaN(parseInt(userId))) {
      callback(null, parseInt(userId))
    } else {
      callback(null, null)
    }
  })
}

// 从用户名获取mail_users表的用户ID（用于邮件系统）
function getMailUserIdFromUsername(username, callback) {
  if (!username || username === 'unknown') {
    return callback(null, null)
  }
  
  // 查询mail_users表获取用户ID（根据用户名或邮箱）
  const escapedUsername = username.replace(/'/g, "''")
  const mailDbPass = getMailDbPassword()
  const query = `mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM mail_users WHERE username='${escapedUsername}' OR email='${escapedUsername}' LIMIT 1;" 2>&1 | tail -1`
  
  exec(query, (error, stdout, stderr) => {
    if (error) {
      console.error('Error getting mail user ID:', error)
      // 如果用户不存在，尝试创建
      return createMailUserFromUsername(username, callback)
    }
    
    const userId = stdout.trim()
    if (userId && !isNaN(parseInt(userId))) {
      callback(null, parseInt(userId))
    } else {
      // 如果用户不存在，尝试创建
      createMailUserFromUsername(username, callback)
    }
  })
}

// 从用户名创建mail_users表用户（如果不存在）
function createMailUserFromUsername(username, callback) {
  if (!username || username === 'unknown') {
    return callback(null, null)
  }
  
  // 获取用户邮箱（从app_users表）
  getUserIdFromUsername(username, (err, appUserId) => {
    if (err || !appUserId) {
      return callback(null, null)
    }
    
    // 查询app_users表获取邮箱
    const dbPass = getAppDbPassword()
    const escapedUsername = username.replace(/'/g, "''")
    const emailQuery = `mysql -u mailappuser --password="${dbPass.replace(/"/g, '\\"')}" mailapp -s -r -e "SELECT email FROM app_users WHERE username='${escapedUsername}' OR email='${escapedUsername}' LIMIT 1;" 2>&1 | tail -1`
    
    exec(emailQuery, (error, stdout, stderr) => {
      if (error) {
        console.error('Error getting user email:', error)
        return callback(null, null)
      }
      
      const email = stdout.trim() || `${username}@localhost`
      
      // 创建mail_users表用户
      const escapedEmail = email.replace(/'/g, "''")
      const mailDbPass = getMailDbPassword()
      const createQuery = `mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "INSERT INTO mail_users (username, email, display_name) VALUES ('${escapedUsername}', '${escapedEmail}', '${escapedUsername}') ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id); SELECT LAST_INSERT_ID() as id;" 2>&1 | tail -1`
      
      exec(createQuery, (createError, createStdout, createStderr) => {
        if (createError) {
          console.error('Error creating mail user:', createError)
          return callback(null, null)
        }
        
        const userId = createStdout.trim()
        if (userId && !isNaN(parseInt(userId))) {
          callback(null, parseInt(userId))
        } else {
          // 如果创建失败，再次查询
          const retryQuery = `mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM mail_users WHERE username='${escapedUsername}' OR email='${escapedEmail}' LIMIT 1;" 2>&1 | tail -1`
          exec(retryQuery, (retryError, retryStdout, retryStderr) => {
            if (retryError) {
              return callback(null, null)
            }
            const retryUserId = retryStdout.trim()
            if (retryUserId && !isNaN(parseInt(retryUserId))) {
              callback(null, parseInt(retryUserId))
            } else {
              callback(null, null)
            }
          })
        }
      })
    })
  })
}

function auth(req, res, next) {
  const credentials = basicAuth(req)
  if (!credentials) {
    return res.status(401).json({ error: 'unauthorized' })
  }
  
  // 获取客户端IP
  const clientIP = getRealClientIP(req)
  
  // 检查登录失败次数限制（仅对登录操作）
  if (req.body && req.body.action === 'app-login') {
    const maxAttempts = getMaxLoginAttempts()
    const attemptData = loginAttempts.get(clientIP) || { count: 0, lastAttempt: 0, lockedUntil: 0 }
    const now = Date.now()
    
    // 如果账户被锁定
    if (attemptData.lockedUntil && now < attemptData.lockedUntil) {
      const remainingMinutes = Math.ceil((attemptData.lockedUntil - now) / 60000)
      return res.status(429).json({ 
        success: false, 
        error: `登录失败次数过多，账户已被锁定，请${remainingMinutes}分钟后再试` 
      })
    }
  }
  
  // 验证用户是否存在于数据库中（包括xm用户）
  // xm用户也存储在app_users表中，通过数据库验证
  try {
    const appUserScript = path.join(ROOT_DIR, 'backend', 'scripts', 'app_user.sh')
    const result = execSync(`cd "${ROOT_DIR}" && ./backend/scripts/app_user.sh login "${credentials.name}" "${credentials.pass}"`, { 
      encoding: 'utf8', 
      timeout: 5000,
      stdio: 'pipe'
    })
    
    if (result.includes('{"ok":true}')) {
      // 登录成功，清除失败记录
      if (req.body && req.body.action === 'app-login') {
        loginAttempts.delete(clientIP)
      }
      // 登录成功，继续处理请求
      next()
    } else {
      // 登录失败，记录失败次数（仅对登录操作）
      if (req.body && req.body.action === 'app-login') {
        const maxAttempts = getMaxLoginAttempts()
        const attemptData = loginAttempts.get(clientIP) || { count: 0, lastAttempt: 0, lockedUntil: 0 }
        const now = Date.now()
        const newCount = attemptData.count + 1
        loginAttempts.set(clientIP, {
          count: newCount,
          lastAttempt: now,
          lockedUntil: newCount >= maxAttempts ? now + 15 * 60 * 1000 : 0 // 达到最大尝试次数后锁定15分钟
        })
        
        // 如果达到锁定阈值，返回锁定信息
        if (newCount >= maxAttempts) {
          return res.status(429).json({ 
            success: false, 
            error: `登录失败次数过多，账户已被锁定15分钟，请稍后再试` 
          })
        }
      }
      // 登录失败
      return res.status(401).json({ error: 'unauthorized' })
    }
    
  } catch (error) {
    console.error('Auth error:', error)
    // 登录失败，记录失败次数（仅对登录操作）
    if (req.body && req.body.action === 'app-login') {
      const maxAttempts = getMaxLoginAttempts()
      const attemptData = loginAttempts.get(clientIP) || { count: 0, lastAttempt: 0, lockedUntil: 0 }
      const now = Date.now()
      const newCount = attemptData.count + 1
      loginAttempts.set(clientIP, {
        count: newCount,
        lastAttempt: now,
        lockedUntil: newCount >= maxAttempts ? now + 15 * 60 * 1000 : 0 // 达到最大尝试次数后锁定15分钟
      })
      
      // 如果达到锁定阈值，返回锁定信息
      if (newCount >= maxAttempts) {
        return res.status(429).json({ 
          success: false, 
          error: `登录失败次数过多，账户已被锁定15分钟，请稍后再试` 
        })
      }
    }
    return res.status(401).json({ error: 'unauthorized' })
  }
}

// 深度合并对象函数
function deepMerge(target, source) {
  // 如果 target 或 source 为空/undefined，直接返回另一个
  if (!target || typeof target !== 'object') {
    return source || {}
  }
  if (!source || typeof source !== 'object') {
    return target || {}
  }
  
  // 如果 source 是数组，直接返回 source（数组不合并）
  if (Array.isArray(source)) {
    return source
  }
  
  // 如果 target 是数组但 source 不是，返回 source
  if (Array.isArray(target)) {
    return source
  }
  
  const output = Object.assign({}, target)
  
  if (isObject(target) && isObject(source)) {
    Object.keys(source).forEach(key => {
      const sourceValue = source[key]
      const targetValue = target[key]
      
      // 如果 source 的值是 null，直接设置为 null
      if (sourceValue === null) {
        output[key] = null
      }
      // 如果 source 的值是数组，直接覆盖
      else if (Array.isArray(sourceValue)) {
        output[key] = sourceValue
      }
      // 如果 source 的值是对象且 target 也有对应的对象值，递归合并
      else if (isObject(sourceValue) && isObject(targetValue)) {
        output[key] = deepMerge(targetValue, sourceValue)
      }
      // 否则直接覆盖（但保留空字符串的情况，不覆盖为undefined）
      else {
        // 如果sourceValue是空字符串，且targetValue有值，则保留targetValue
        if (sourceValue === '' && targetValue !== undefined && targetValue !== null && targetValue !== '') {
          output[key] = targetValue
        } else {
        output[key] = sourceValue
        }
      }
    })
    
    // 对于target中存在但source中不存在的键，保留target的值
    // 这对于DNS配置等字段很重要
    Object.keys(target).forEach(key => {
      if (!(key in source)) {
        output[key] = target[key]
      }
    })
  }
  
  return output
}

// 检查是否为对象
function isObject(item) {
  return item && typeof item === 'object' && !Array.isArray(item)
}

function runScript(scriptName, args = []) {
  const opId = uuidv4()
  const outFile = path.join(LOG_DIR, `${opId}.log`)
  // ensure log dir is writable; if not, try to self-heal
  const writable = ensureLogDirWritable()
  const out = fs.createWriteStream(outFile)
  const scriptPath = path.join(SCRIPTS_DIR, scriptName)
  
  // 根据脚本和操作类型确定超时时间（毫秒）
  // 对于可能涉及系统更新的操作，设置更长的超时时间
  let timeoutMs = 600000 // 默认10分钟
  const firstArg = args[0] || ''
  
  // 可能涉及系统更新的操作，设置30分钟超时
  if (scriptName === 'dns_setup.sh' && (firstArg === 'configure-bind' || firstArg === 'install')) {
    timeoutMs = 1800000 // 30分钟
  } else if (scriptName === 'mail_setup.sh' && firstArg === 'install') {
    timeoutMs = 1800000 // 30分钟
  } else if (scriptName === 'security.sh' && firstArg === 'harden') {
    timeoutMs = 180000 // 3分钟（安全加固操作应快速完成）
  } else if (scriptName === 'db_setup.sh' && firstArg === 'init') {
    timeoutMs = 1200000 // 20分钟
  }
  
  // 记录操作开始
  const timestamp = new Date().toISOString()
  const logEntry = `[${timestamp}] [OPERATION_START] Script: ${scriptName}, Args: ${JSON.stringify(args)}, OpID: ${opId}, Timeout: ${timeoutMs}ms\n`
  out.write(logEntry)
  // 也记录到 operations.log，便于排障
  try {
    fs.appendFileSync(path.join(LOG_DIR, 'operations.log'), logEntry)
  } catch {}
  if (!writable) {
    try {
      out.write(`[${timestamp}] [WARNING] LOG_DIR not writable initially, attempted self-heal.\n`)
    } catch {}
  }
  
  // 检查脚本是否存在
  if (!fs.existsSync(scriptPath)) {
    const errorMsg = `[${timestamp}] [ERROR] Script not found: ${scriptPath}\n`
    out.write(errorMsg)
    out.write(`[${timestamp}] [DEBUG] Current working directory: ${process.cwd()}\n`)
    out.write(`[${timestamp}] [DEBUG] Scripts directory: ${SCRIPTS_DIR}\n`)
    try {
      out.write(`[${timestamp}] [DEBUG] Files in scripts directory: ${fs.readdirSync(SCRIPTS_DIR).join(', ')}\n`)
    } catch (e) {
      out.write(`[${timestamp}] [DEBUG] Cannot read scripts directory: ${e.message}\n`)
    }
    out.end()
    return { opId, child: null, outFile }
  }
  
  // 检查脚本权限
  try {
    const stats = fs.statSync(scriptPath)
    out.write(`[${timestamp}] [DEBUG] Script permissions: ${stats.mode.toString(8)}\n`)
    out.write(`[${timestamp}] [DEBUG] Script is executable: ${stats.mode & parseInt('111', 8) ? 'Yes' : 'No'}\n`)
  } catch (statErr) {
    out.write(`[${timestamp}] [DEBUG] Cannot stat script: ${statErr.message}\n`)
  }
  
  // 检查 sudo 是否可用（使用 spawnSync，避免 ESM 下 require 未定义）
  let useSudo = false
  try {
    const whichSudo = spawnSync('bash', ['-lc', 'command -v sudo'], { stdio: 'ignore' })
    if (whichSudo.status === 0) {
      const sudoTest = spawnSync('sudo', ['-n', 'true'], { stdio: 'ignore' })
      useSudo = sudoTest.status === 0
      out.write(`[${timestamp}] [DEBUG] sudo ${useSudo ? 'available' : 'present but requires password'}\n`)
    } else {
      out.write(`[${timestamp}] [DEBUG] sudo not found in PATH\n`)
    }
  } catch (sudoErr) {
    useSudo = false
    out.write(`[${timestamp}] [WARNING] sudo check failed, running script directly\n`)
    out.write(`[${timestamp}] [DEBUG] sudo test error: ${sudoErr?.message || sudoErr}\n`)
  }
  
  const command = useSudo ? 'sudo' : 'bash'
  const args_array = useSudo ? ['-n', scriptPath, ...args] : [scriptPath, ...args]
  
  // 立即写入一些调试信息
  out.write(`[${timestamp}] [DEBUG] Starting script: ${scriptPath}\n`)
  out.write(`[${timestamp}] [DEBUG] Working directory: ${DISPATCHER_DIR}\n`)
  out.write(`[${timestamp}] [DEBUG] Command: ${command}\n`)
  out.write(`[${timestamp}] [DEBUG] Args: ${JSON.stringify(args_array)}\n`)
  out.write(`[${timestamp}] [DEBUG] Timeout: ${timeoutMs}ms (${Math.floor(timeoutMs / 60000)} minutes)\n`)
  
  const child = spawn(command, args_array, { 
    stdio: ['ignore', 'pipe', 'pipe'],
    cwd: DISPATCHER_DIR,
    env: { ...process.env, PYTHONUNBUFFERED: '1' }
  })
  
  // 设置超时定时器
  let timeoutHandle = null
  let isTimedOut = false
  
  if (timeoutMs > 0) {
    timeoutHandle = setTimeout(() => {
      if (!child.killed && child.exitCode === null) {
        isTimedOut = true
        const timeoutTime = new Date().toISOString()
        const timeoutMsg = `[${timeoutTime}] [ERROR] Script execution timeout after ${Math.floor(timeoutMs / 60000)} minutes\n`
        out.write(timeoutMsg)
        out.write(`[${timeoutTime}] [WARNING] 脚本执行超时，正在终止进程...\n`)
        
        // 尝试优雅终止
        try {
          child.kill('SIGTERM')
          // 如果5秒后还没退出，强制终止
          setTimeout(() => {
            if (!child.killed && child.exitCode === null) {
              try {
                child.kill('SIGKILL')
                out.write(`[${timeoutTime}] [WARNING] 进程已被强制终止\n`)
              } catch (killErr) {
                out.write(`[${timeoutTime}] [ERROR] 强制终止失败: ${killErr.message}\n`)
              }
            }
          }, 5000)
        } catch (killErr) {
          out.write(`[${timeoutTime}] [ERROR] 终止进程失败: ${killErr.message}\n`)
        }
        
        try { fs.appendFileSync(path.join(LOG_DIR, 'operations.log'), timeoutMsg) } catch {}
      }
    }, timeoutMs)
  }
  
  child.stdout.pipe(out, { end: false })
  child.stderr.pipe(out, { end: false })
  
  child.on('error', (err) => {
    const errorTime = new Date().toISOString()
    const errorLog = `[${errorTime}] [ERROR] Script execution failed: ${err.message}\n`
    out.write(errorLog)
    
    // 清除超时定时器
    if (timeoutHandle) {
      clearTimeout(timeoutHandle)
      timeoutHandle = null
    }
    
    // 检查脚本权限
    try {
      const stats = fs.statSync(scriptPath)
      out.write(`[${errorTime}] [DEBUG] Script permissions: ${stats.mode.toString(8)}\n`)
      out.write(`[${errorTime}] [DEBUG] Script is executable: ${stats.mode & parseInt('111', 8) ? 'Yes' : 'No'}\n`)
    } catch (statErr) {
      out.write(`[${errorTime}] [DEBUG] Cannot stat script: ${statErr.message}\n`)
    }
    
    // 如果是 sudo 相关错误，提供解决建议
    if (err.message.includes('sudo') || err.message.includes('ENOENT')) {
      out.write(`[${errorTime}] [SUGGESTION] Try running: sudo yum install sudo -y\n`)
      out.write(`[${errorTime}] [SUGGESTION] Or run the script directly: bash ${scriptPath} ${args.join(' ')}\n`)
      out.write(`[${errorTime}] [SUGGESTION] Check script permissions: chmod +x ${scriptPath}\n`)
    }
  })
  
  child.on('close', (code) => {
    // 清除超时定时器
    if (timeoutHandle) {
      clearTimeout(timeoutHandle)
      timeoutHandle = null
    }
    
    const endTime = new Date().toISOString()
    const exitCode = isTimedOut ? 124 : code // 124 是 timeout 命令的标准退出码
    const endLog = `[${endTime}] [OPERATION_END] Exit code: ${exitCode}, OpID: ${opId}${isTimedOut ? ' (TIMEOUT)' : ''}\n`
    out.write(endLog)
    
    if (isTimedOut) {
      out.write(`[${endTime}] [WARNING] ⚠️ 脚本执行超时（${Math.floor(timeoutMs / 60000)}分钟），请检查系统状态\n`)
      out.write(`[${endTime}] [INFO] 提示: 如果系统正在更新软件包，这是正常的，请稍后重试\n`)
    }
    
    // 特殊处理：如果是query-users操作，解析输出并返回JSON格式
    if (scriptName === 'app_user.sh' && args[0] === 'query-users') {
      try {
        const logContent = fs.readFileSync(outFile, 'utf8')
        const lines = logContent.split('\n')
        
        console.log('Query-users log content:', logContent)
        
        // 查找JSON输出行
        for (const line of lines) {
          const trimmedLine = line.trim()
          console.log('Checking line:', trimmedLine)
          // 查找JSON数组格式的行
          if ((trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) || 
              (trimmedLine.startsWith('{') && trimmedLine.endsWith('}'))) {
            try {
              console.log('Found JSON line:', trimmedLine)
              const users = JSON.parse(trimmedLine)
              console.log('Parsed users:', users)
              out.write(`[${endTime}] [JSON_OUTPUT] ${JSON.stringify({ success: true, users })}\n`)
              break
            } catch (e) {
              console.log('JSON parse error:', e.message)
              // 不是有效的JSON，继续查找
            }
          }
        }
      } catch (e) {
        console.log('Query-users error:', e.message)
        out.write(`[${endTime}] [ERROR] Failed to parse users JSON: ${e.message}\n`)
      }
    }
    
    try { fs.appendFileSync(path.join(LOG_DIR, 'operations.log'), endLog) } catch {}
    out.end()
  })
  
  return { opId, child, outFile }
}

app.post('/api/ops', auth, (req, res) => {
  const { action, params, ...directParams } = req.body || {}
  // 如果params存在，使用params；否则使用直接参数
  const finalParams = params || directParams
  
  // 处理query-user-profile操作
  if (action === 'query-user-profile') {
    try {
      const username = finalParams?.username
      if (!username) {
        return res.status(400).json({
          success: false,
          error: '缺少用户名参数'
        })
      }
      
      // 转义用户名中的单引号，防止SQL注入
      const escapedUsername = username.replace(/'/g, "''")
      
      // 查询用户信息
      const dbPass = getAppDbPassword()
      // 使用环境变量传递密码，避免shell特殊字符问题
      const query = `mysql -u mailappuser --password="${dbPass.replace(/"/g, '\\"')}" mailapp -s -r -e "SELECT username, email, avatar FROM app_users WHERE username='${escapedUsername}' OR email='${escapedUsername}' LIMIT 1;" 2>&1`
      
      let result
      try {
        result = execSync(query, { 
          encoding: 'utf8', 
          timeout: 5000, 
          stdio: ['pipe', 'pipe', 'pipe'],
          env: { ...process.env, MYSQL_PWD: dbPass }
        }).trim()
      } catch (execError) {
        const errorOutput = execError.stderr?.toString() || execError.stdout?.toString() || ''
        console.error('Database query error:', execError.message)
        console.error('Error output:', errorOutput)
        console.error('Query:', query.replace(dbPass, '***'))
        console.error('Username:', username)
        console.error('Escaped username:', escapedUsername)
        
        // 提供更详细的错误信息
        let errorMessage = '数据库查询失败'
        if (errorOutput.includes('Access denied')) {
          errorMessage = '数据库访问被拒绝，请检查用户名和密码'
        } else if (errorOutput.includes('Unknown database')) {
          errorMessage = '数据库不存在'
        } else if (errorOutput.includes('Can\'t connect')) {
          errorMessage = '无法连接到数据库服务器'
        } else if (errorOutput) {
          errorMessage = `数据库错误: ${errorOutput.substring(0, 200)}`
        } else {
          errorMessage = execError.message || '无法连接到数据库'
        }
        
        return res.status(500).json({
          success: false,
          error: '数据库查询失败',
          message: errorMessage
        })
      }
      
      if (result) {
        const parts = result.split('\t')
        const user = {
          username: parts[0] || username,
          email: parts[1] || '',
          avatar: parts[2] || ''
        }
        
        // 处理avatar字段：过滤NULL、空字符串和无效值
        let avatarValue = user.avatar || ''
        // 去除可能的NULL字符串（MySQL可能返回字符串"NULL"）
        if (avatarValue.toUpperCase() === 'NULL' || avatarValue.trim() === '' || avatarValue.trim() === 'null') {
          avatarValue = ''
        }
        
        // 如果头像存在，转换为完整URL
        if (avatarValue && avatarValue.trim()) {
          let avatarUrl = avatarValue.trim()
          // 确保URL格式正确
          if (!avatarUrl.startsWith('http') && !avatarUrl.startsWith('/')) {
            avatarUrl = '/' + avatarUrl
          }
          user.avatar = avatarUrl
        } else {
          user.avatar = ''
        }
        
        return res.json({
          success: true,
          user: user
        })
      } else {
        return res.json({
          success: false,
          error: '用户不存在'
        })
      }
    } catch (error) {
      console.error('Query user profile error:', error)
      return res.status(500).json({
        success: false,
        error: '查询用户资料失败',
        message: error.message || '未知错误'
      })
    }
  }
  
  // 添加详细的调试信息
  console.log('=== API请求调试信息 ===')
  console.log('请求体:', JSON.stringify(req.body, null, 2))
  console.log('Action:', action)
  console.log('Params:', params)
  console.log('DirectParams:', directParams)
  console.log('FinalParams:', finalParams)
  console.log('========================')
  const user = req.headers.authorization ? 
    Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 
    'unknown'
  const timestamp = new Date().toISOString()
  const clientIP = getRealClientIP(req)
  
  // 记录用户操作
  const operationLog = `[${timestamp}] [USER_OPERATION] User: ${user}, Action: ${action}, Params: ${JSON.stringify(finalParams)}, IP: ${clientIP}\n`
  try {
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), operationLog)
  } catch (err) {
    console.error('Failed to write user operations log:', err.message)
    // 继续执行，不因为日志写入失败而中断
  }
  
  if (!ALLOWED_ACTIONS.has(action)) {
    const errorLog = `[${timestamp}] [ERROR] Invalid action: ${action} by user: ${user}\n`
    try {
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLog)
    } catch (err) {
      console.error('Failed to write error log:', err.message)
    }
    return res.status(400).json({ error: 'invalid action' })
  }
  let scriptName
  let args = []
  switch (action) {
    case 'check':
      scriptName = 'mail_setup.sh'; args = ['check']; break
    case 'install':
      scriptName = 'mail_setup.sh'; args = ['install']; break
    case 'configure':
      scriptName = 'mail_setup.sh'; args = ['configure', finalParams?.domain]; break
    case 'restart':
      scriptName = 'mail_setup.sh'; args = ['restart']; break
    case 'status':
      scriptName = 'mail_setup.sh'; args = ['status']; break
    case 'security-hardening':
      scriptName = 'security.sh'; args = ['harden']; break
    case 'db-init':
      scriptName = 'db_setup.sh'; args = ['init']; break
    case 'domain-add':
      scriptName = 'user_manage.sh'; args = ['domain-add', finalParams?.domain]; break
    case 'user-add':
      scriptName = 'user_manage.sh'; args = ['user-add', finalParams?.email, finalParams?.password]; break
    case 'user-del':
      console.log('处理user-del操作，参数:', finalParams)
      scriptName = 'app_user.sh'; args = ['delete-user', finalParams?.email]; 
      console.log('user-del脚本参数:', args)
      break
    case 'query-users':
      scriptName = 'app_user.sh'; args = ['query-users']; break
    case 'app-init':
      scriptName = 'app_user.sh'; args = ['query-users']; break
    case 'app-register':
      // 验证密码
      if (finalParams?.password) {
        const passwordValidation = validatePassword(finalParams.password)
        if (!passwordValidation.valid) {
          return res.status(400).json({ 
            success: false, 
            error: passwordValidation.error 
          })
        }
      }
      
      // 验证验证码（如果提供了验证码，则验证；管理员批量创建时可能不提供验证码，已通过auth中间件认证）
      if (finalParams?.captchaId && finalParams?.captchaAnswer !== undefined && finalParams?.captchaAnswer !== null && finalParams?.captchaAnswer !== '') {
        // 如果提供了验证码，则进行验证（普通用户注册场景）
        const registerCaptcha = captchaStore.get(finalParams.captchaId)
        if (!registerCaptcha || Date.now() > registerCaptcha.expiresAt) {
          return res.status(400).json({ success: false, error: '验证码无效或已过期，请刷新验证码' })
        }
        const registerUserAnswer = parseInt(String(finalParams.captchaAnswer).trim(), 10)
        if (isNaN(registerUserAnswer) || registerUserAnswer !== registerCaptcha.answer) {
          return res.status(400).json({ success: false, error: '验证码错误，请重新输入' })
        }
        // 验证成功后删除验证码（一次性使用）
        captchaStore.delete(finalParams.captchaId)
      }
      // 如果没有提供验证码，但已通过auth中间件认证，则允许继续（管理员批量创建场景）
      scriptName = 'app_user.sh'; args = ['register', finalParams?.username, finalParams?.email, finalParams?.password]; break
    case 'app-login':
      // 获取客户端IP
      const clientIP = getRealClientIP(req)
      
      // 检查登录失败次数限制
      const attemptData = loginAttempts.get(clientIP) || { count: 0, lastAttempt: 0, lockedUntil: 0 }
      const now = Date.now()
      
      // 如果账户被锁定
      if (attemptData.lockedUntil && now < attemptData.lockedUntil) {
        const remainingMinutes = Math.ceil((attemptData.lockedUntil - now) / 60000)
        return res.status(429).json({ 
          success: false, 
          error: `登录失败次数过多，账户已被锁定，请${remainingMinutes}分钟后再试` 
        })
      }
      
      // 如果锁定已过期，重置计数
      if (attemptData.lockedUntil && now >= attemptData.lockedUntil) {
        loginAttempts.delete(clientIP)
      }
      
      // 验证验证码
      const maxAttempts = getMaxLoginAttempts()
      if (!finalParams?.captchaId || finalParams?.captchaAnswer === undefined || finalParams?.captchaAnswer === null || finalParams?.captchaAnswer === '') {
        return res.status(400).json({ success: false, error: '请完成验证码验证' })
      }
      const loginCaptcha = captchaStore.get(finalParams.captchaId)
      if (!loginCaptcha || Date.now() > loginCaptcha.expiresAt) {
        // 验证码错误也算一次失败尝试
        loginAttempts.set(clientIP, {
          count: attemptData.count + 1,
          lastAttempt: now,
          lockedUntil: attemptData.count + 1 >= maxAttempts ? now + 15 * 60 * 1000 : 0 // 达到最大尝试次数后锁定15分钟
        })
        return res.status(400).json({ success: false, error: '验证码无效或已过期，请刷新验证码' })
      }
      const loginUserAnswer = parseInt(String(finalParams.captchaAnswer).trim(), 10)
      if (isNaN(loginUserAnswer) || loginUserAnswer !== loginCaptcha.answer) {
        // 验证码错误也算一次失败尝试
        loginAttempts.set(clientIP, {
          count: attemptData.count + 1,
          lastAttempt: now,
          lockedUntil: attemptData.count + 1 >= maxAttempts ? now + 15 * 60 * 1000 : 0 // 达到最大尝试次数后锁定15分钟
        })
        return res.status(400).json({ success: false, error: '验证码错误，请重新输入' })
      }
      // 验证成功后删除验证码（一次性使用）
      captchaStore.delete(finalParams.captchaId)
      
      // 注意：实际的登录验证在auth中间件中进行
      // 如果登录失败，auth中间件会返回401，我们需要在这里记录失败次数
      // 但由于auth中间件在case之前执行，我们需要在auth中间件中处理失败记录
      // 这里先设置一个标记，表示验证码已通过
      scriptName = 'app_user.sh'; args = ['login', finalParams?.username, finalParams?.password]; break
    case 'app-reset':
      // 验证密码
      const resetPassword = finalParams?.password || finalParams?.newpass
      if (resetPassword) {
        const passwordValidation = validatePassword(resetPassword)
        if (!passwordValidation.valid) {
          return res.status(400).json({ 
            success: false, 
            error: passwordValidation.error 
          })
        }
      }
      
      // 验证验证码
      if (!finalParams?.captchaId || finalParams?.captchaAnswer === undefined || finalParams?.captchaAnswer === null || finalParams?.captchaAnswer === '') {
        return res.status(400).json({ success: false, error: '请完成验证码验证' })
      }
      const resetCaptcha = captchaStore.get(finalParams.captchaId)
      if (!resetCaptcha || Date.now() > resetCaptcha.expiresAt) {
        return res.status(400).json({ success: false, error: '验证码无效或已过期，请刷新验证码' })
      }
      const resetUserAnswer = parseInt(String(finalParams.captchaAnswer).trim(), 10)
      if (isNaN(resetUserAnswer) || resetUserAnswer !== resetCaptcha.answer) {
        return res.status(400).json({ success: false, error: '验证码错误，请重新输入' })
      }
      // 验证成功后删除验证码（一次性使用）
      captchaStore.delete(finalParams.captchaId)
      scriptName = 'app_user.sh'; args = ['reset', finalParams?.username, resetPassword]; break
    case 'app-update':
      // 处理密码参数：如果是 null/undefined/空字符串，不传递密码参数
      const passwordParam = (finalParams?.password && finalParams.password !== 'null' && finalParams.password !== 'undefined') ? finalParams.password : ''
      
      // 如果提供了密码，验证密码
      if (passwordParam) {
        const passwordValidation = validatePassword(passwordParam)
        if (!passwordValidation.valid) {
          return res.status(400).json({ 
            success: false, 
            error: passwordValidation.error 
          })
        }
      }
      
      const avatarParam = (finalParams?.avatar && finalParams.avatar !== 'null' && finalParams.avatar !== 'undefined') ? finalParams.avatar : ''
      scriptName = 'app_user.sh'; args = ['update', finalParams?.original_username || finalParams?.username, finalParams?.new_username || '', finalParams?.email || '', passwordParam, avatarParam]; break
    case 'check-user-exists':
      scriptName = 'app_user.sh'; args = ['check-user-exists', finalParams?.username]; break
    case 'fix-email-domains':
      scriptName = 'app_user.sh'; args = ['fix-email-domains', finalParams?.target_domain]; break
    case 'install-cert':
      // 处理证书申请参数
      const certParams = finalParams?.params || finalParams
      scriptName = 'cert_setup.sh'; args = [
        'install', 
        certParams?.domain,
        certParams?.country,
        certParams?.state,
        certParams?.city,
        certParams?.organization,
        certParams?.unit,
        certParams?.commonName,
        certParams?.email,
        certParams?.validity,
        certParams?.san,
        certParams?.caCountry,
        certParams?.caState,
        certParams?.caCity,
        certParams?.caOrganization,
        certParams?.caUnit,
        certParams?.caCommonName,
        certParams?.caEmail,
        certParams?.caValidity
      ]; break
    case 'enable-ssl':
      scriptName = 'cert_setup.sh'; args = [
        'enable-ssl',
        finalParams?.domain || ''
      ]; break
    case 'enable-http-redirect':
      scriptName = 'cert_setup.sh'; args = [
        'enable-http-redirect',
        finalParams?.domain || ''
      ]; break
    case 'setup-logs':
      scriptName = 'monitoring.sh'; args = ['setup-logs']; break
    case 'full-backup':
      scriptName = 'backup.sh'; args = ['full-backup']; break
    case 'setup-cron':
      scriptName = 'backup.sh'; args = ['setup-cron']; break
    case 'setup-backup-cron':
      // 处理参数传递问题：前端传递的是 { action, params: { interval, database, ... } }
      const backupParams = finalParams?.params || finalParams
      scriptName = 'backup.sh'; args = [
        'setup-backup-cron', 
        backupParams?.interval, 
        backupParams?.database, 
        backupParams?.config, 
        backupParams?.maildir, 
        backupParams?.retention,
        backupParams?.customTime,
        backupParams?.customHour,
        backupParams?.customMinute,
        backupParams?.customSecond
      ]; break
    case 'health':
      scriptName = 'mail_setup.sh'; args = ['health']; break
    case 'configure-bind':
      scriptName = 'dns_setup.sh';
      args = [
        'configure-bind',
        finalParams?.domain,
        finalParams?.serverIp || finalParams?.server_ip,
        (finalParams?.adminEmail || 'xm@localhost'),
        (typeof finalParams?.enableRecursion === 'boolean' ? finalParams.enableRecursion : true),
        (typeof finalParams?.enableForwarding === 'boolean' ? finalParams.enableForwarding : true),
        (finalParams?.upstreamDns || '8.8.8.8, 1.1.1.1')
      ];
      break
    case 'configure-public':
      scriptName = 'dns_setup.sh'; 
      args = [
        'configure-public', 
        finalParams?.domain,
        finalParams?.provider || 'manual',
        finalParams?.api_token || '',
        finalParams?.aws_access_key || '',
        finalParams?.aws_secret_key || '',
        finalParams?.google_api_key || '',
        finalParams?.azure_client_id || '',
        finalParams?.azure_client_secret || '',
        finalParams?.dnspod_api_id || '',
        finalParams?.dnspod_api_token || ''
      ]; 
      break
    case 'install-mail':
      scriptName = 'mail_setup.sh'; args = ['install']; break
    case 'install-database':
      scriptName = 'db_setup.sh'; args = ['init']; break
    case 'install-dns':
      scriptName = 'dns_setup.sh'; args = ['install']; break
    case 'install-security':
      scriptName = 'security.sh'; args = ['harden']; break
    case 'restart-mail':
      scriptName = 'mail_setup.sh'; args = ['restart-mail']; break
    case 'restart-database':
      scriptName = 'db_setup.sh'; args = ['restart']; break
    case 'restart-dns':
      scriptName = 'dns_setup.sh'; args = ['restart']; break
    case 'restart-security':
      scriptName = 'security.sh'; args = ['restart']; break
    case 'restart-dispatcher':
      scriptName = 'dispatcher.sh'; args = ['restart']; break
    case 'stop-mail':
      scriptName = 'mail_setup.sh'; args = ['stop-mail']; break
    case 'stop-database':
      scriptName = 'db_setup.sh'; args = ['stop']; break
    case 'stop-dns':
      scriptName = 'dns_setup.sh'; args = ['stop']; break
    case 'stop-security':
      scriptName = 'security.sh'; args = ['stop']; break
    case 'stop-dispatcher':
      scriptName = 'dispatcher.sh'; args = ['stop']; break
  }
  
  // 添加调试信息
  console.log('Processing action:', action)
  console.log('Script name:', scriptName)
  console.log('Args:', args)
  console.log('Final params:', finalParams)
  
  // 参数校验：放宽为仅校验 undefined/null，且对 install-cert 仅要求 domain
  const isMissing = (v) => v === undefined || v === null
  if (action === 'install-cert') {
    const certParams = finalParams?.params || finalParams
    if (isMissing(certParams?.domain)) {
      console.log('Missing required param for install-cert: domain')
      return res.status(400).json({ error: 'missing domain' })
    }
    // 其余参数允许为空字符串，由后端脚本使用默认值
  } else if (action === 'enable-ssl') {
    if (isMissing(finalParams?.domain)) {
      console.log('Missing required param for enable-ssl: domain')
      return res.status(400).json({ error: 'missing domain' })
    }
  } else if (action === 'enable-http-redirect') {
    // enable-http-redirect不需要必需参数，域名可选
  } else if (action === 'app-update') {
    // app-update 需要 original_username 或 username 参数，其他参数都是可选的
    const username = finalParams?.original_username || finalParams?.username
    if (isMissing(username)) {
      console.log('Missing required param for app-update: original_username or username')
      return res.status(400).json({ error: 'missing username' })
    }
  } else if (!['configure-bind', 'configure-public'].includes(action)) {
    if (args.some(isMissing)) {
      console.log('Missing params detected (undefined/null), returning 400')
      return res.status(400).json({ error: 'missing params' })
    }
  }
  // 如果是启用HTTP跳转操作，先创建状态文件标记用户已启用
  if (action === 'enable-http-redirect') {
    try {
      const configDir = path.join(ROOT_DIR, 'config')
      if (!fs.existsSync(configDir)) {
        fs.mkdirSync(configDir, { recursive: true, mode: 0o755 })
      }
      const httpRedirectStateFile = path.join(configDir, 'http-redirect-enabled.json')
      fs.writeFileSync(httpRedirectStateFile, JSON.stringify({ enabled: true, enabledAt: new Date().toISOString() }, null, 2), 'utf8')
      // 设置文件权限
      try {
        fs.chmodSync(httpRedirectStateFile, 0o755)
        execSync(`chown xm:xm "${httpRedirectStateFile}"`, { timeout: 3000 })
      } catch (permError) {
        try {
          execSync(`sudo chown xm:xm "${httpRedirectStateFile}"`, { timeout: 3000 })
          execSync(`sudo chmod 755 "${httpRedirectStateFile}"`, { timeout: 3000 })
        } catch (sudoError) {
          console.warn('设置HTTP跳转状态文件权限失败:', sudoError.message)
        }
      }
      console.log('[HTTP跳转] 已创建HTTP跳转启用状态文件')
    } catch (stateError) {
      console.warn('[HTTP跳转] 创建状态文件失败:', stateError.message)
      // 状态文件创建失败不应该阻止脚本执行
    }
  }
  
  const { opId, child } = runScript(scriptName, args)
  child.on('close', (code) => {
    // 记录脚本执行结果
    const logFile = path.join(LOG_DIR, `${opId}.log`)
    const result = {
      opId,
      exitCode: code,
      success: code === 0,
      timestamp: new Date().toISOString()
    }
    
    // 将结果写入日志文件
    fs.appendFileSync(logFile, `\n[SCRIPT_RESULT] ${JSON.stringify(result)}\n`)
  })
  
  // 特殊处理：如果是query-users操作，需要等待脚本完成并返回用户数据
  if (action === 'query-users') {
    // 等待脚本完成
    setTimeout(() => {
      try {
        const logFile = path.join(LOG_DIR, `${opId}.log`)
        if (fs.existsSync(logFile)) {
          const logContent = fs.readFileSync(logFile, 'utf8')
          const lines = logContent.split('\n')
          
          // 查找JSON数据行
          for (const line of lines) {
            const trimmedLine = line.trim()
            // 查找JSON数组格式的行
            if ((trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) || 
                (trimmedLine.startsWith('{') && trimmedLine.endsWith('}'))) {
              try {
                const userData = JSON.parse(trimmedLine)
                res.json({ success: true, users: userData })
                return
              } catch (e) {
                // 不是有效的JSON，继续查找
                continue
              }
            }
          }
        }
        // 如果没有找到用户数据，返回默认响应
        res.json({ success: true, opId })
      } catch (error) {
        console.error('Query-users response error:', error)
        res.json({ success: true, opId })
      }
    }, 1000) // 等待1秒让脚本完成
  } else if (action === 'check-user-exists') {
    // 特殊处理：检查用户是否存在操作
    setTimeout(() => {
      try {
        const logFile = path.join(LOG_DIR, `${opId}.log`)
        if (fs.existsSync(logFile)) {
          const logContent = fs.readFileSync(logFile, 'utf8')
          const lines = logContent.split('\n')
          
          // 查找JSON数据行
          for (const line of lines) {
            const trimmedLine = line.trim()
            // 查找JSON对象格式的行
            if (trimmedLine.startsWith('{') && trimmedLine.endsWith('}')) {
              try {
                const result = JSON.parse(trimmedLine)
                res.json(result)
                return
              } catch (e) {
                // 不是有效的JSON，继续查找
                continue
              }
            }
          }
        }
        // 如果没有找到结果，返回默认响应
        res.json({ success: true, exists: false })
      } catch (error) {
        console.error('Check-user-exists response error:', error)
        res.json({ success: true, exists: false })
      }
    }, 1000) // 等待1秒让脚本完成
  } else {
    res.json({ success: true, opId })
  }
})

app.get('/api/ops/:id/log', auth, (req, res) => {
  const opFile = path.join(LOG_DIR, `${req.params.id}.log`)
  res.setHeader('Content-Type', 'text/plain; charset=utf-8')
  if (fs.existsSync(opFile)) {
    return fs.createReadStream(opFile).pipe(res)
  }
  // 兼容回退：如果单独日志不存在，则从 operations.log 中筛选该 OpID 的内容
  const opsFile = path.join(LOG_DIR, 'operations.log')
  if (fs.existsSync(opsFile)) {
    try {
      const content = fs.readFileSync(opsFile, 'utf8')
      const id = req.params.id
      const lines = content.split('\n').filter(l => l.includes(id))
      if (lines.length > 0) {
        return res.end(lines.join('\n'))
      }
    } catch {}
  }
  return res.status(404).json({ error: 'not found' })
})

// 用户日志API端点
app.post('/api/user-logs', auth, (req, res) => {
  const user = req.headers.authorization ? 
    Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 
    'unknown'
  const timestamp = new Date().toISOString()
  const clientIP = getRealClientIP(req)
  
  try {
    const { logs } = req.body || {}
    if (!Array.isArray(logs)) {
      return res.status(400).json({ error: 'logs must be an array' })
    }
    
    // 记录每个用户日志条目
    logs.forEach(logEntry => {
      const logLine = `[${timestamp}] [USER_LOG] User: ${user}, Action: ${logEntry.action}, Category: ${logEntry.category || 'general'}, Details: ${JSON.stringify(logEntry.details || {})}, IP: ${clientIP}, UserAgent: ${req.headers['user-agent'] || 'unknown'}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    })
    
    res.json({ success: true, processed: logs.length })
  } catch (err) {
    console.error('Failed to write user logs:', err.message)
    res.status(500).json({ error: 'failed to write logs' })
  }
})

// 邮件操作日志API端点
app.post('/api/mail-logs', auth, (req, res) => {
  const user = req.headers.authorization ? 
    Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 
    'unknown'
  const timestamp = new Date().toISOString()
  const clientIP = getRealClientIP(req)
  
  try {
    const { operation, details } = req.body || {}
    
    // 记录邮件操作（加密敏感信息）
    const sanitizedDetails = { ...details }
    if (sanitizedDetails.to) {
      sanitizedDetails.to = sanitizedDetails.to.replace(/(.{2}).*(@.*)/, '$1***$2')
    }
    if (sanitizedDetails.from) {
      sanitizedDetails.from = sanitizedDetails.from.replace(/(.{2}).*(@.*)/, '$1***$2')
    }
    if (sanitizedDetails.subject) {
      sanitizedDetails.subject = sanitizedDetails.subject.substring(0, 20) + '...'
    }
    if (sanitizedDetails.body) {
      sanitizedDetails.bodyLength = sanitizedDetails.body.length
      delete sanitizedDetails.body
    }
    
    const logLine = `[${timestamp}] [MAIL_OPERATION] User: ${user}, Operation: ${operation}, Category: mail, Details: ${JSON.stringify(sanitizedDetails)}, IP: ${clientIP}, UserAgent: ${req.headers['user-agent'] || 'unknown'}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    res.json({ success: true })
  } catch (err) {
    console.error('Failed to write mail log:', err.message)
    res.status(500).json({ error: 'failed to write mail log' })
  }
})

// 测试终端连接
app.get('/api/terminal/test', auth, (req, res) => {
  console.log('Terminal test endpoint called')
  res.json({ 
    success: true, 
    message: 'Terminal API is working',
    timestamp: new Date().toISOString()
  })
})

// 测试简单命令执行
app.post('/api/terminal/test', auth, (req, res) => {
  console.log('Terminal test POST endpoint called')
  try {
    const output = execSync('echo "test"', { encoding: 'utf8' })
    res.json({
      success: true,
      output: output,
      message: 'Test command executed successfully'
    })
  } catch (error) {
    console.error('Test command error:', error)
    res.json({
      success: false,
      output: error.message,
      message: 'Test command failed'
    })
  }
})

// 测试API端点
app.get('/api/test-status', auth, (req, res) => {
  try {
    console.log('Test API called')
    res.json({
      success: true,
      message: 'Test API working',
      timestamp: new Date().toISOString(),
      services: {
        test: {
          status: 'running',
          lastCheck: new Date().toISOString()
        }
      }
    })
  } catch (error) {
    console.error('Test API error:', error)
    res.status(500).json({ error: 'Test API failed' })
  }
})

// 验证码存储（使用内存存储，生产环境建议使用Redis）
const captchaStore = new Map()

// 登录失败记录（用于防止暴力破解）
const loginAttempts = new Map() // key: IP地址, value: { count: 失败次数, lastAttempt: 最后尝试时间, lockedUntil: 锁定到期时间 }

// 获取系统设置中的最大登录尝试次数
function getMaxLoginAttempts() {
  try {
    const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
    if (fs.existsSync(settingsFile)) {
      const settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
      const maxAttempts = settings.security?.maxLoginAttempts
      if (maxAttempts && maxAttempts >= 3 && maxAttempts <= 20) {
        return maxAttempts
      }
    }
  } catch (error) {
    console.warn('读取最大登录尝试次数失败，使用默认值:', error.message)
  }
  return 5 // 默认值
}

// 获取系统设置中的密码最小长度
function getPasswordMinLength() {
  try {
    const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
    if (fs.existsSync(settingsFile)) {
      const settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
      const minLength = settings.security?.passwordMinLength
      if (minLength && minLength >= 6 && minLength <= 32) {
        return minLength
      }
    }
  } catch (error) {
    console.warn('读取密码最小长度失败，使用默认值:', error.message)
  }
  return 8 // 默认值
}

// 获取系统设置中是否要求特殊字符
function getRequireSpecialChars() {
  try {
    const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
    if (fs.existsSync(settingsFile)) {
      const settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
      return settings.security?.requireSpecialChars === true
    }
  } catch (error) {
    console.warn('读取特殊字符要求失败，使用默认值:', error.message)
  }
  return false // 默认不要求
}

// 验证密码是否符合要求
function validatePassword(password) {
  if (!password || typeof password !== 'string') {
    return { valid: false, error: '密码不能为空' }
  }
  
  const minLength = getPasswordMinLength()
  const requireSpecialChars = getRequireSpecialChars()
  
  // 验证密码长度
  if (password.length < minLength) {
    return { valid: false, error: `密码长度至少需要${minLength}个字符` }
  }
  
  // 如果要求特殊字符，验证密码复杂度
  if (requireSpecialChars) {
    const hasUpperCase = /[A-Z]/.test(password)
    const hasLowerCase = /[a-z]/.test(password)
    const hasNumber = /[0-9]/.test(password)
    const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)
    
    if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
      return { 
        valid: false, 
        error: '密码必须包含大小写字母、数字和特殊字符' 
      }
    }
  }
  
  return { valid: true }
}

// 清理过期登录失败记录
setInterval(() => {
  const now = Date.now()
  for (const [ip, data] of loginAttempts.entries()) {
    // 如果锁定已过期，重置失败次数
    if (data.lockedUntil && now > data.lockedUntil) {
      loginAttempts.delete(ip)
    }
    // 如果最后一次尝试超过15分钟，清除记录
    else if (data.lastAttempt && now - data.lastAttempt > 15 * 60 * 1000) {
      loginAttempts.delete(ip)
    }
  }
}, 60 * 1000) // 每分钟清理一次

// 验证码生成API（无需认证）
app.get('/api/captcha/generate', (req, res) => {
  try {
    // 生成随机数学题
    const num1 = Math.floor(Math.random() * 20) + 1
    const num2 = Math.floor(Math.random() * 20) + 1
    const operators = ['+', '-', '×']
    const operator = operators[Math.floor(Math.random() * operators.length)]
    
    let answer
    let question
    switch (operator) {
      case '+':
        answer = num1 + num2
        question = `${num1} + ${num2}`
        break
      case '-':
        // 确保结果为正数
        const maxNum = Math.max(num1, num2)
        const minNum = Math.min(num1, num2)
        answer = maxNum - minNum
        question = `${maxNum} - ${minNum}`
        break
      case '×':
        // 使用较小的数字避免结果过大
        const small1 = Math.floor(Math.random() * 10) + 1
        const small2 = Math.floor(Math.random() * 10) + 1
        answer = small1 * small2
        question = `${small1} × ${small2}`
        break
    }
    
    // 生成唯一ID
    const captchaId = crypto.randomBytes(16).toString('hex')
    const expiresAt = Date.now() + 5 * 60 * 1000 // 5分钟过期
    
    // 存储验证码答案
    captchaStore.set(captchaId, {
      answer,
      expiresAt
    })
    
    // 清理过期验证码
    setTimeout(() => {
      captchaStore.delete(captchaId)
    }, 5 * 60 * 1000)
    
    res.json({
      success: true,
      captchaId,
      question,
      expiresIn: 300 // 5分钟
    })
  } catch (error) {
    console.error('生成验证码失败:', error)
    res.status(500).json({ success: false, error: '生成验证码失败' })
  }
})

// 获取版本信息API（公开接口，无需认证）
// 下载CA根证书
app.get('/api/cert/ca-cert', (req, res) => {
  try {
    const caCertPath = '/etc/pki/CA/cacert.pem'
    
    if (!fs.existsSync(caCertPath)) {
      return res.status(404).json({
        success: false,
        error: 'CA根证书不存在，请先申请SSL证书'
      })
    }
    
    // 设置响应头，让浏览器下载文件
    res.setHeader('Content-Type', 'application/x-x509-ca-cert')
    res.setHeader('Content-Disposition', 'attachment; filename="cacert.pem"')
    
    // 读取并发送证书文件
    const certContent = fs.readFileSync(caCertPath, 'utf8')
    res.send(certContent)
    
    console.log('CA根证书下载成功')
  } catch (error) {
    console.error('下载CA根证书失败:', error)
    res.status(500).json({
      success: false,
      error: '下载CA根证书失败',
      message: error.message
    })
  }
})

// 检查证书是否存在（增强版：包含证书验证和过期检查）
app.get('/api/cert/check', auth, (req, res) => {
  try {
    const domain = req.query.domain
    if (!domain) {
      return res.status(400).json({
        success: false,
        error: '缺少域名参数'
      })
    }
    
    // 验证域名格式
    const domainRegex = /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i
    if (!domainRegex.test(domain)) {
      return res.status(400).json({
        success: false,
        error: '域名格式无效'
      })
    }
    
    const certFile = `/etc/pki/tls/${domain}.crt`
    const keyFile = `/etc/pki/tls/${domain}.key`
    const caCertFile = '/etc/pki/CA/cacert.pem'
    
    const certExists = fs.existsSync(certFile)
    const keyExists = fs.existsSync(keyFile)
    const caCertExists = fs.existsSync(caCertFile)
    
    let certValid = false
    let certExpiresAt = null
    let certIssuer = null
    let certSubject = null
    let daysUntilExpiry = null
    
    // 如果证书存在，尝试解析证书信息
    if (certExists) {
      try {
        // 使用openssl命令解析证书
        const certInfo = execSync(`openssl x509 -in "${certFile}" -noout -dates -subject -issuer 2>/dev/null`, { 
          encoding: 'utf8',
          timeout: 3000
        })
        
        // 解析证书信息
        const notAfterMatch = certInfo.match(/notAfter=(.+)/i)
        if (notAfterMatch) {
          certExpiresAt = new Date(notAfterMatch[1].trim())
          const now = new Date()
          daysUntilExpiry = Math.floor((certExpiresAt.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
          
          if (daysUntilExpiry > 0) {
            certValid = true
          }
        }
        
        const subjectMatch = certInfo.match(/subject=(.+)/i)
        if (subjectMatch) {
          certSubject = subjectMatch[1].trim()
        }
        
        const issuerMatch = certInfo.match(/issuer=(.+)/i)
        if (issuerMatch) {
          certIssuer = issuerMatch[1].trim()
        }
      } catch (parseError) {
        console.warn('解析证书信息失败:', parseError)
        // 即使解析失败，如果文件存在，也认为证书存在
        certValid = certExists && keyExists
      }
    }
    
    const allExists = certExists && keyExists && caCertExists
    
    // 生成详细的状态消息
    let message = ''
    if (!allExists) {
      const missing = []
      if (!certExists) missing.push('证书文件')
      if (!keyExists) missing.push('私钥文件')
      if (!caCertExists) missing.push('CA根证书')
      message = `缺少以下文件：${missing.join('、')}，请先申请或上传证书`
    } else if (!certValid && certExpiresAt) {
      message = `证书已过期（过期时间：${certExpiresAt.toLocaleDateString('zh-CN')}），请更新证书`
    } else if (daysUntilExpiry !== null && daysUntilExpiry <= 30) {
      message = `证书将在 ${daysUntilExpiry} 天后过期，建议及时更新`
    } else {
      message = '证书文件已存在且有效，可以启用SSL'
    }
    
    res.json({
      success: true,
      domain: domain,
      certExists: certExists,
      keyExists: keyExists,
      caCertExists: caCertExists,
      allExists: allExists,
      certValid: certValid,
      certExpiresAt: certExpiresAt ? certExpiresAt.toISOString() : null,
      daysUntilExpiry: daysUntilExpiry,
      certIssuer: certIssuer,
      certSubject: certSubject,
      message: message
    })
  } catch (error) {
    console.error('检查证书失败:', error)
    res.status(500).json({
      success: false,
      error: '检查证书失败',
      message: (error && error.message) ? error.message : '未知错误'
    })
  }
})

// 备份状态查询API
app.get('/api/backup/status', auth, (req, res) => {
  try {
    const backupDir = '/var/backups/mail'
    const status = {
      status: 'idle',
      message: '备份系统就绪',
      lastBackup: null,
      backups: []
    }
    
    if (fs.existsSync(backupDir)) {
      const files = fs.readdirSync(backupDir).filter(f => f.endsWith('.gz'))
      if (files.length > 0) {
        // 获取最新的备份文件
        const backupFiles = files.map(file => {
          const filePath = path.join(backupDir, file)
          const stats = fs.statSync(filePath)
          return {
            file: file,
            size: formatFileSize(stats.size),
            date: stats.mtime.toISOString()
          }
        }).sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime())
        
        status.lastBackup = backupFiles[0].date
        status.backups = backupFiles.slice(0, 10) // 返回最近10个备份
      }
    }
    
    res.json({
      success: true,
      status: status
    })
  } catch (error) {
    console.error('查询备份状态失败:', error)
    res.status(500).json({
      success: false,
      error: '查询备份状态失败',
      message: error.message
    })
  }
})

// 格式化文件大小
function formatFileSize(bytes) {
  if (bytes === 0) return '0 B'
  const k = 1024
  const sizes = ['B', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]
}

// SSL域名列表API（支持域名-证书关联）
app.get('/api/cert/domains', auth, (req, res) => {
  try {
    const certDir = '/etc/pki/tls'
    const domains = []
    const domainCertMap = {}
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        const config = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
        Object.assign(domainCertMap, config)
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    if (fs.existsSync(certDir)) {
      const files = fs.readdirSync(certDir)
      const domainSet = new Set()
      
      // 查找所有证书文件（排除chain证书，它们会自动关联到主域名）
      const chainCertMap = {} // 存储chain证书到主域名的映射
      files.forEach(file => {
        if (file.endsWith('.crt')) {
          const certName = file.replace('.crt', '')
          // 检测chain证书（以.chain结尾）
          if (certName.endsWith('.chain')) {
            // 提取主域名（去掉.chain后缀）
            const mainDomain = certName.replace(/\.chain$/, '')
            chainCertMap[mainDomain] = certName
          } else {
            // 普通证书，添加到域名集合
            domainSet.add(certName)
          }
        }
      })
      
      // 从配置文件中读取域名列表（可能包含未创建证书的域名）
      Object.keys(domainCertMap).forEach(domain => {
        domainSet.add(domain)
      })
      
      // 检查每个域名的证书状态
      domainSet.forEach(domain => {
        const certName = domainCertMap[domain] || domain
        const certFile = path.join(certDir, `${certName}.crt`)
        const keyFile = path.join(certDir, `${certName}.key`)
        const certExists = fs.existsSync(certFile)
        const keyExists = fs.existsSync(keyFile)
        
        // 检查是否存在对应的chain证书
        const chainCertName = chainCertMap[domain] || chainCertMap[certName]
        const chainCertFile = chainCertName ? path.join(certDir, `${chainCertName}.crt`) : null
        const chainCertExists = chainCertFile && fs.existsSync(chainCertFile)
        
        let expiresAt = null
        if (certExists) {
          try {
            const certInfo = execSync(`openssl x509 -in "${certFile}" -noout -dates 2>/dev/null`, { 
              encoding: 'utf8',
              timeout: 3000
            })
            const match = certInfo.match(/notAfter=(.+)/i)
            if (match) {
              expiresAt = new Date(match[1].trim()).toLocaleDateString('zh-CN')
            }
          } catch (e) {
            console.error(`解析证书 ${domain} 失败:`, e)
          }
        }
        
        // 如果存在chain证书但未关联，自动关联
        if (chainCertExists && !domainCertMap[domain]) {
          // chain证书会自动关联到主域名，不需要单独显示
          // 但我们需要确保主域名存在
          if (!domainCertMap[domain] && certExists && keyExists) {
            // 主域名证书存在，自动添加到配置中
            domainCertMap[domain] = certName
            // 保存配置（异步，不阻塞响应）
            setImmediate(() => {
              try {
                const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
                const configDir = path.dirname(domainCertConfigFile)
                if (!fs.existsSync(configDir)) {
                  fs.mkdirSync(configDir, { recursive: true })
                }
                fs.writeFileSync(domainCertConfigFile, JSON.stringify(domainCertMap, null, 2), 'utf8')
                console.log(`[SSL域名列表] 自动关联chain证书到域名: ${domain} -> ${certName} (chain: ${chainCertName})`)
              } catch (e) {
                console.error(`[SSL域名列表] 自动关联chain证书失败:`, e)
              }
            })
          }
        }
        
        domains.push({
          name: domain,
          certName: certName !== domain ? certName : null,
          certExists: certExists && keyExists,
          expiresAt: expiresAt,
          hasChainCert: chainCertExists,
          chainCertName: chainCertName || null
        })
      })
    }
    
    res.json({
      success: true,
      domains: domains
    })
  } catch (error) {
    console.error('获取SSL域名列表失败:', error)
    res.status(500).json({
      success: false,
      error: '获取SSL域名列表失败',
      message: error.message
    })
  }
})

// 添加SSL域名API（支持域名-证书关联）
app.post('/api/cert/domains', auth, (req, res) => {
  try {
    const { domain, certName } = req.body
    
    if (!domain || typeof domain !== 'string') {
      return res.status(400).json({
        success: false,
        error: '域名参数无效'
      })
    }
    
    // 验证域名格式
    const domainRegex = /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i
    if (!domainRegex.test(domain)) {
      return res.status(400).json({
        success: false,
        error: '域名格式无效'
      })
    }
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let domainCertMap = {}
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    // 确定使用的证书名称（如果指定了certName，使用指定的；否则使用域名）
    const actualCertName = certName && certName.trim() ? certName.trim() : domain
    
    // 检查证书是否存在
    const certFile = `/etc/pki/tls/${actualCertName}.crt`
    const keyFile = `/etc/pki/tls/${actualCertName}.key`
    
    if (!fs.existsSync(certFile) || !fs.existsSync(keyFile)) {
      return res.status(400).json({
        success: false,
        error: `证书文件不存在: ${actualCertName}.crt 或 ${actualCertName}.key`
      })
    }
    
    // 添加域名-证书关联
    domainCertMap[domain] = actualCertName
    
    // 保存配置
    const configDir = path.dirname(domainCertConfigFile)
    if (!fs.existsSync(configDir)) {
      fs.mkdirSync(configDir, { recursive: true })
    }
    fs.writeFileSync(domainCertConfigFile, JSON.stringify(domainCertMap, null, 2), 'utf8')
    
    res.json({
      success: true,
      message: 'SSL域名已添加',
      domain: domain,
      certName: actualCertName
    })
  } catch (error) {
    console.error('添加SSL域名失败:', error)
    res.status(500).json({
      success: false,
      error: '添加SSL域名失败',
      message: error.message
    })
  }
})

// 删除SSL域名API（仅删除关联，不删除证书文件）
app.delete('/api/cert/domains/:domain', auth, (req, res) => {
  try {
    const domain = req.params.domain
    
    if (!domain) {
      return res.status(400).json({
        success: false,
        error: '域名参数无效'
      })
    }
    
    let deletedFiles = []
    let deletedFromConfig = false
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let domainCertMap = {}
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    // 删除域名关联配置（如果存在）
    if (domainCertMap[domain]) {
      delete domainCertMap[domain]
      deletedFromConfig = true
      
      // 保存配置
      try {
        fs.writeFileSync(domainCertConfigFile, JSON.stringify(domainCertMap, null, 2), 'utf8')
        console.log(`[删除域名] 已从配置文件中删除域名: ${domain}`)
      } catch (e) {
        console.error(`[删除域名] 保存配置文件失败:`, e)
      }
    }
    
    // 删除Apache配置文件（无论配置文件中是否有记录）
    const apacheConfDir = '/etc/httpd/conf.d'
    const sslConfFile = path.join(apacheConfDir, `${domain}_ssl.conf`)
    const httpConfFile = path.join(apacheConfDir, `${domain}_http.conf`)
    // 也检查旧格式的配置文件（如 skills.com.conf）
    const oldConfFile = path.join(apacheConfDir, `${domain}.conf`)
    
    // 删除SSL配置文件
    if (fs.existsSync(sslConfFile)) {
      try {
        fs.unlinkSync(sslConfFile)
        deletedFiles.push(sslConfFile)
        console.log(`[删除域名] 已删除SSL配置文件: ${sslConfFile}`)
      } catch (e) {
        console.error(`[删除域名] 删除SSL配置文件失败: ${sslConfFile}`, e)
      }
    }
    
    // 删除HTTP配置文件
    if (fs.existsSync(httpConfFile)) {
      try {
        fs.unlinkSync(httpConfFile)
        deletedFiles.push(httpConfFile)
        console.log(`[删除域名] 已删除HTTP配置文件: ${httpConfFile}`)
      } catch (e) {
        console.error(`[删除域名] 删除HTTP配置文件失败: ${httpConfFile}`, e)
      }
    }
    
    // 删除旧格式的配置文件（如果存在且包含该域名）
    if (fs.existsSync(oldConfFile)) {
      try {
        const content = fs.readFileSync(oldConfFile, 'utf8')
        // 检查是否包含该域名的ServerName或ServerAlias
        if (content.includes(`ServerName ${domain}`) || content.includes(`ServerAlias ${domain}`) || 
            content.includes(`ServerName www.${domain}`) || content.includes(`ServerAlias www.${domain}`)) {
          fs.unlinkSync(oldConfFile)
          deletedFiles.push(oldConfFile)
          console.log(`[删除域名] 已删除旧格式配置文件: ${oldConfFile}`)
        }
      } catch (e) {
        console.error(`[删除域名] 检查/删除旧格式配置文件失败: ${oldConfFile}`, e)
      }
    }
    
    // 如果既没有配置文件记录，也没有Apache配置文件，返回404
    if (!deletedFromConfig && deletedFiles.length === 0) {
      return res.status(404).json({
        success: false,
        error: '未找到该域名的配置'
      })
    }
    
    // 验证Apache配置语法
    let apacheConfigValid = true
    try {
      const { execSync } = require('child_process')
      execSync('httpd -t', { stdio: 'pipe', timeout: 5000 })
    } catch (e) {
      apacheConfigValid = false
      console.error('[删除域名] Apache配置语法检查失败:', e.message)
    }
    
    // 如果删除了配置文件，建议重启Apache
    if (deletedFiles.length > 0 && apacheConfigValid) {
      try {
        const { execSync } = require('child_process')
        // 尝试使用sudo重启，如果失败则直接重启
        try {
          execSync('sudo systemctl restart httpd', { stdio: 'pipe', timeout: 10000 })
        } catch (sudoError) {
          execSync('systemctl restart httpd', { stdio: 'pipe', timeout: 10000 })
        }
        console.log('[删除域名] Apache服务已重启')
      } catch (restartError) {
        console.warn('[删除域名] Apache服务重启失败，请手动重启:', restartError.message)
      }
    }
    
    res.json({
      success: true,
      message: 'SSL域名已删除',
      deletedFromConfig: deletedFromConfig,
      deletedFiles: deletedFiles,
      apacheRestarted: deletedFiles.length > 0 && apacheConfigValid
    })
  } catch (error) {
    console.error('删除SSL域名失败:', error)
    res.status(500).json({
      success: false,
      error: '删除SSL域名失败',
      message: error.message
    })
  }
})

// 更新域名证书关联API
app.put('/api/cert/domains/:domain/cert', auth, (req, res) => {
  try {
    const domain = req.params.domain
    const { certName } = req.body
    
    if (!domain) {
      return res.status(400).json({
        success: false,
        error: '域名参数无效'
      })
    }
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let domainCertMap = {}
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    // 确定使用的证书名称
    const actualCertName = certName && certName.trim() ? certName.trim() : domain
    
    // 检查证书是否存在
    const certFile = `/etc/pki/tls/${actualCertName}.crt`
    const keyFile = `/etc/pki/tls/${actualCertName}.key`
    
    if (!fs.existsSync(certFile) || !fs.existsSync(keyFile)) {
      return res.status(400).json({
        success: false,
        error: `证书文件不存在: ${actualCertName}.crt 或 ${actualCertName}.key`
      })
    }
    
    // 更新域名-证书关联
    domainCertMap[domain] = actualCertName
    
    // 保存配置
    const configDir = path.dirname(domainCertConfigFile)
    if (!fs.existsSync(configDir)) {
      fs.mkdirSync(configDir, { recursive: true })
    }
    fs.writeFileSync(domainCertConfigFile, JSON.stringify(domainCertMap, null, 2), 'utf8')
    
    res.json({
      success: true,
      message: '证书关联已更新',
      domain: domain,
      certName: actualCertName
    })
  } catch (error) {
    console.error('更新证书关联失败:', error)
    res.status(500).json({
      success: false,
      error: '更新证书关联失败',
      message: error.message
    })
  }
})

// 证书列表API
// 检查域名的Apache SSL配置状态
app.get('/api/cert/domains/:domain/ssl-status', auth, (req, res) => {
  try {
    const domain = req.params.domain
    
    if (!domain) {
      return res.status(400).json({
        success: false,
        error: '域名参数无效'
      })
    }
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let domainCertMap = {}
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    const certName = domainCertMap[domain] || domain
    const certFile = `/etc/pki/tls/${certName}.crt`
    const keyFile = `/etc/pki/tls/${certName}.key`
    
    // 检查证书文件是否存在
    if (!fs.existsSync(certFile) || !fs.existsSync(keyFile)) {
      return res.json({
        success: true,
        configured: false,
        reason: '证书文件不存在'
      })
    }
    
    // 检查Apache SSL VirtualHost配置文件是否存在
    const sslConfFile = `/etc/httpd/conf.d/${domain}_ssl.conf`
    const sslConfigured = fs.existsSync(sslConfFile)
    
    // 如果配置文件存在，检查内容是否有效
    let isValid = false
    if (sslConfigured) {
      try {
        const confContent = fs.readFileSync(sslConfFile, 'utf8')
        // 检查是否包含SSL配置和正确的证书路径
        isValid = confContent.includes('SSLEngine on') && 
                  confContent.includes(`SSLCertificateFile /etc/pki/tls/${certName}.crt`) &&
                  confContent.includes(`SSLCertificateKeyFile /etc/pki/tls/${certName}.key`)
      } catch (e) {
        console.error(`读取SSL配置文件失败: ${sslConfFile}`, e)
      }
    }
    
    res.json({
      success: true,
      configured: isValid,
      certName: certName,
      certFile: certFile,
      keyFile: keyFile,
      configFile: sslConfFile
    })
  } catch (error) {
    console.error('检查SSL配置状态失败:', error)
    res.status(500).json({
      success: false,
      error: '检查SSL配置状态失败',
      message: error.message
    })
  }
})

// 启用域名的Apache SSL配置
app.post('/api/cert/domains/:domain/enable-ssl', auth, (req, res) => {
  try {
    const domain = req.params.domain
    
    if (!domain) {
      return res.status(400).json({
        success: false,
        error: '域名参数无效'
      })
    }
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let domainCertMap = {}
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    let certName = domainCertMap[domain] || domain
    let certFile = `/etc/pki/tls/${certName}.crt`
    let keyFile = `/etc/pki/tls/${certName}.key`
    
    // 如果证书文件不存在，尝试查找www.前缀或去掉www.前缀的证书
    if (!fs.existsSync(certFile) || !fs.existsSync(keyFile)) {
      // 如果域名是www.开头，尝试查找去掉www.的证书
      if (domain.startsWith('www.')) {
        const baseDomain = domain.replace(/^www\./, '')
        const baseCertFile = `/etc/pki/tls/${baseDomain}.crt`
        const baseKeyFile = `/etc/pki/tls/${baseDomain}.key`
        
        if (fs.existsSync(baseCertFile) && fs.existsSync(baseKeyFile)) {
          certName = baseDomain
          certFile = baseCertFile
          keyFile = baseKeyFile
          console.log(`[启用SSL] 找到基础域名证书: ${baseDomain}`)
        }
      } else {
        // 如果域名不是www.开头，尝试查找www.前缀的证书
        const wwwDomain = `www.${domain}`
        const wwwCertFile = `/etc/pki/tls/${wwwDomain}.crt`
        const wwwKeyFile = `/etc/pki/tls/${wwwDomain}.key`
        
        if (fs.existsSync(wwwCertFile) && fs.existsSync(wwwKeyFile)) {
          certName = wwwDomain
          certFile = wwwCertFile
          keyFile = wwwKeyFile
          console.log(`[启用SSL] 找到www.前缀证书: ${wwwDomain}`)
        }
      }
    }
    
    // 再次检查证书文件是否存在
    if (!fs.existsSync(certFile) || !fs.existsSync(keyFile)) {
      console.error(`[启用SSL] 证书文件不存在: certFile=${certFile}, keyFile=${keyFile}`)
      return res.status(400).json({
        success: false,
        error: '证书文件不存在，请先上传证书',
        details: `期望的证书文件: ${certFile}, 私钥文件: ${keyFile}`
      })
    }
    
    console.log(`[启用SSL] 使用证书: certName=${certName}, domain=${domain}`)
    
    // 调用cert_setup.sh配置Apache
    const scriptPath = path.join(ROOT_DIR, 'backend', 'scripts', 'cert_setup.sh')
    
    if (!fs.existsSync(scriptPath)) {
      return res.status(500).json({
        success: false,
        error: 'cert_setup.sh脚本不存在'
      })
    }
    
    // 确保脚本有执行权限
    try {
      fs.chmodSync(scriptPath, 0o755)
    } catch (chmodError) {
      console.warn('设置脚本执行权限失败:', chmodError.message)
    }
    
    // 执行Apache配置命令（使用域名，而不是certName，因为脚本内部会查找证书）
    // 注意：脚本会从配置文件中查找certName，所以传递domain参数
    let enableSslCommand = `sudo bash "${scriptPath}" enable-ssl "${domain}"`
    let output = ''
    let errorOutput = ''
    
    try {
      console.log(`[启用SSL] 开始执行Apache配置命令（使用sudo）: ${enableSslCommand}`)
      console.log(`[启用SSL] 域名: ${domain}, 证书名称: ${certName}`)
      output = execSync(enableSslCommand, {
        timeout: 120000,
        stdio: ['pipe', 'pipe', 'pipe'],
        encoding: 'utf8',
        cwd: ROOT_DIR,
        env: { ...process.env, PATH: process.env.PATH }
      })
      
      // 检查输出中是否包含错误信息
      const outputStr = output.toString()
      if (outputStr.includes('[ERROR]') || outputStr.includes('失败') || outputStr.includes('错误') || outputStr.includes('不存在')) {
        console.error(`[启用SSL] Apache配置输出包含错误:`, outputStr.substring(0, 2000))
        throw new Error(`Apache配置失败: ${outputStr.substring(0, 500)}`)
      }
      
      console.log(`[启用SSL] Apache配置成功（使用sudo）`)
      if (output) {
        console.log(`[启用SSL] Apache配置输出:`, outputStr.substring(0, 2000))
      }
      
      res.json({
        success: true,
        message: 'Apache SSL配置成功，服务已重启。配置需要2-3分钟生效，请稍后访问HTTPS页面验证。'
      })
    } catch (sudoError) {
      const sudoErrorOutput = sudoError.stderr?.toString() || sudoError.stdout?.toString() || sudoError.message
      console.warn(`[启用SSL] sudo执行失败，尝试不使用sudo:`, sudoErrorOutput.substring(0, 500))
      enableSslCommand = `bash "${scriptPath}" enable-ssl "${domain}"`
      
      try {
        console.log(`[启用SSL] 开始执行Apache配置命令（不使用sudo）: ${enableSslCommand}`)
        output = execSync(enableSslCommand, {
          timeout: 120000,
          stdio: ['pipe', 'pipe', 'pipe'],
          encoding: 'utf8',
          cwd: ROOT_DIR,
          env: { ...process.env, PATH: process.env.PATH }
        })
        
        // 检查输出中是否包含错误信息
        const outputStr = output.toString()
        if (outputStr.includes('[ERROR]') || outputStr.includes('失败') || outputStr.includes('错误') || outputStr.includes('不存在')) {
          console.error(`[启用SSL] Apache配置输出包含错误:`, outputStr.substring(0, 2000))
          throw new Error(`Apache配置失败: ${outputStr.substring(0, 500)}`)
        }
        
        console.log(`[启用SSL] Apache配置成功（不使用sudo）`)
        if (output) {
          console.log(`[启用SSL] Apache配置输出:`, outputStr.substring(0, 2000))
        }
        
        res.json({
          success: true,
          message: 'Apache SSL配置成功，服务已重启。配置需要2-3分钟生效，请稍后访问HTTPS页面验证。'
        })
      } catch (nonSudoError) {
        const errorOutput = nonSudoError.stderr?.toString() || nonSudoError.stdout?.toString() || nonSudoError.message
        const exitCode = nonSudoError.status || nonSudoError.code || 'unknown'
        const fullError = `[启用SSL] Apache配置失败\n域名: ${domain}\n证书名称: ${certName}\n退出码: ${exitCode}\n错误输出:\n${errorOutput}`
        
        console.error(fullError.substring(0, 5000))
        console.error(`[启用SSL] 完整错误堆栈:`, nonSudoError.stack)
        
        // 尝试检查Apache配置语法
        try {
          const apacheTest = execSync('httpd -t 2>&1', { timeout: 5000, encoding: 'utf8' })
          console.error(`[启用SSL] Apache配置语法检查:`, apacheTest.substring(0, 500))
        } catch (apacheTestError) {
          console.error(`[启用SSL] Apache配置语法检查失败:`, apacheTestError.message)
        }
        
        // 尝试检查Apache服务状态
        try {
          const apacheStatus = execSync('systemctl status httpd --no-pager -l 2>&1', { timeout: 5000, encoding: 'utf8' })
          console.error(`[启用SSL] Apache服务状态:`, apacheStatus.substring(0, 500))
        } catch (statusError) {
          console.error(`[启用SSL] 无法获取Apache服务状态:`, statusError.message)
        }
        
        res.status(500).json({
          success: false,
          error: 'Apache配置失败',
          message: `配置失败: ${errorOutput.substring(0, 300)} (退出码: ${exitCode})`,
          details: errorOutput.substring(0, 2000),
          domain: domain,
          certName: certName
        })
      }
    }
  } catch (error) {
    const fullError = `[启用SSL] 启用SSL配置失败\n错误: ${error.message}\n堆栈: ${error.stack}`
    console.error(fullError)
    console.error(`[启用SSL] 错误对象:`, JSON.stringify(error, Object.getOwnPropertyNames(error), 2))
    
    res.status(500).json({
      success: false,
      error: '启用SSL配置失败',
      message: error.message,
      details: error.stack?.substring(0, 500) || '无详细错误信息'
    })
  }
})

// 禁用域名的Apache SSL配置（删除SSL VirtualHost配置文件并重启Apache）
app.post('/api/cert/domains/:domain/disable-ssl', auth, (req, res) => {
  try {
    const domain = req.params.domain
    
    if (!domain) {
      return res.status(400).json({
        success: false,
        error: '域名参数无效'
      })
    }
    
    const sslConfFile = `/etc/httpd/conf.d/${domain}_ssl.conf`
    const httpConfFile = `/etc/httpd/conf.d/${domain}_http.conf`
    const deletedFiles = []
    
    // 使用 sudo rm -f 删除 Apache 配置文件（/etc/httpd/conf.d 需 root 权限）
    const rmCmd = `rm -f "${sslConfFile}" "${httpConfFile}"`
    try {
      execSync(`sudo ${rmCmd}`, { timeout: 10000, encoding: 'utf8' })
      deletedFiles.push(sslConfFile, httpConfFile)
      console.log(`[禁用SSL] 已删除配置文件: ${sslConfFile}, ${httpConfFile}`)
    } catch (rmErr) {
      try {
        execSync(rmCmd, { timeout: 10000, encoding: 'utf8' })
        deletedFiles.push(sslConfFile, httpConfFile)
        console.log(`[禁用SSL] 已删除配置文件（无 sudo）`)
      } catch (e) {
        // 若仍失败，尝试直接 fs 删除（当前进程为 root 时有效）
        if (fs.existsSync(sslConfFile)) {
          try { fs.unlinkSync(sslConfFile); deletedFiles.push(sslConfFile); console.log(`[禁用SSL] 已删除: ${sslConfFile}`) } catch (e2) { console.error(`[禁用SSL] 删除失败: ${sslConfFile}`, e2.message) }
        }
        if (fs.existsSync(httpConfFile)) {
          try { fs.unlinkSync(httpConfFile); deletedFiles.push(httpConfFile); console.log(`[禁用SSL] 已删除: ${httpConfFile}`) } catch (e2) { console.error(`[禁用SSL] 删除失败: ${httpConfFile}`, e2.message) }
        }
      }
    }
    
    // 从其他 *_ssl.conf 中移除本域名的 ServerAlias（避免通过 www/根域 互为主别名时仍能访问 HTTPS）
    const apacheConfDir = '/etc/httpd/conf.d'
    let sslConfList = []
    try {
      sslConfList = fs.readdirSync(apacheConfDir).filter(f => f.endsWith('_ssl.conf'))
    } catch (e) {
      try {
        const out = execSync('sudo ls /etc/httpd/conf.d/*_ssl.conf 2>/dev/null || true', { encoding: 'utf8' })
        sslConfList = out.trim().split(/\s+/).filter(Boolean).map(f => path.basename(f))
      } catch (e2) {
        console.warn('[禁用SSL] 无法列举 _ssl.conf:', e2.message)
      }
    }
    const domainEscapedForRegex = domain.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    for (const name of sslConfList) {
      if (name === `${domain}_ssl.conf`) continue
      const serverAliasDomainRe = new RegExp(`^\\s*ServerAlias\\s+${domainEscapedForRegex}\\s*$`, 'gm')
      const confPath = path.join(apacheConfDir, name)
      let content = ''
      try {
        content = execSync(`sudo cat "${confPath}"`, { timeout: 5000, encoding: 'utf8' })
      } catch (catErr) {
        try {
          content = fs.readFileSync(confPath, 'utf8')
        } catch {
          continue
        }
      }
      if (!serverAliasDomainRe.test(content)) continue
      const newContent = content.replace(serverAliasDomainRe, '').replace(/\n\s*\n\s*\n/g, '\n\n')
      if (newContent === content) continue
      const tmpPath = path.join(ROOT_DIR, 'config', `.${name}.tmp`)
      fs.writeFileSync(tmpPath, newContent, 'utf8')
      try {
        execSync(`sudo cp "${tmpPath}" "${confPath}"`, { timeout: 5000, encoding: 'utf8' })
        console.log(`[禁用SSL] 已从 ${name} 移除 ServerAlias ${domain}`)
      } catch (cpErr) {
        try {
          execSync(`cp "${tmpPath}" "${confPath}"`, { timeout: 5000, encoding: 'utf8' })
          console.log(`[禁用SSL] 已从 ${name} 移除 ServerAlias ${domain}（无 sudo）`)
        } catch (e2) {
          console.warn(`[禁用SSL] 写回 ${name} 失败:`, e2.message)
        }
      }
      try { fs.unlinkSync(tmpPath) } catch (_) {}
    }
    
    // 从 ssl-domain-cert.json 中移除该域名，保持 UI 状态一致
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        let domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
        if (Object.prototype.hasOwnProperty.call(domainCertMap, domain)) {
          delete domainCertMap[domain]
          fs.writeFileSync(domainCertConfigFile, JSON.stringify(domainCertMap, null, 2), 'utf8')
          console.log(`[禁用SSL] 已从 ssl-domain-cert.json 移除域名: ${domain}`)
        }
      } catch (e) {
        console.warn('[禁用SSL] 更新 ssl-domain-cert.json 失败:', e.message)
      }
    }
    
    // 检查Apache配置语法
    try {
      execSync('sudo httpd -t', { timeout: 5000, encoding: 'utf8' })
      console.log('[禁用SSL] Apache配置语法检查通过')
    } catch (configTestError) {
      // 如果sudo失败，尝试不使用sudo
      try {
        execSync('httpd -t', { timeout: 5000, encoding: 'utf8' })
        console.log('[禁用SSL] Apache配置语法检查通过（不使用sudo）')
      } catch (nonSudoError) {
        console.error('[禁用SSL] Apache配置语法检查失败:', nonSudoError.message)
        return res.status(500).json({
          success: false,
          error: 'Apache配置语法错误',
          message: '删除配置文件后Apache配置语法检查失败，请手动检查配置'
        })
      }
    }
    
    // 重启Apache服务
    try {
      execSync('sudo systemctl restart httpd', { timeout: 30000, encoding: 'utf8' })
      console.log('[禁用SSL] Apache服务重启成功')
      
      res.json({
        success: true,
        message: 'SSL配置已禁用，Apache服务已重启',
        deletedFiles: deletedFiles
      })
    } catch (restartError) {
      // 如果sudo失败，尝试不使用sudo
      try {
        execSync('systemctl restart httpd', { timeout: 30000, encoding: 'utf8' })
        console.log('[禁用SSL] Apache服务重启成功（不使用sudo）')
        
        res.json({
          success: true,
          message: 'SSL配置已禁用，Apache服务已重启',
          deletedFiles: deletedFiles
        })
      } catch (nonSudoRestartError) {
        console.error('[禁用SSL] Apache服务重启失败:', nonSudoRestartError.message)
        res.status(500).json({
          success: false,
          error: 'Apache服务重启失败',
          message: nonSudoRestartError.message,
          deletedFiles: deletedFiles,
          warning: '配置文件已删除，但Apache服务重启失败，请手动重启'
        })
      }
    }
  } catch (error) {
    console.error('禁用SSL配置失败:', error)
    res.status(500).json({
      success: false,
      error: '禁用SSL配置失败',
      message: error.message
    })
  }
})

// 获取证书详细信息
app.get('/api/cert/:certName/details', auth, (req, res) => {
  try {
    const certName = req.params.certName
    
    if (!certName) {
      return res.status(400).json({
        success: false,
        error: '证书名称参数无效'
      })
    }
    
    const certFile = `/etc/pki/tls/${certName}.crt`
    const keyFile = `/etc/pki/tls/${certName}.key`
    const chainFile = `/etc/pki/tls/${certName}.chain.crt`
    
    if (!fs.existsSync(certFile)) {
      return res.status(404).json({
        success: false,
        error: '证书文件不存在'
      })
    }
    
    let certInfo = {
      name: certName,
      certFile: certFile,
      keyFile: fs.existsSync(keyFile) ? keyFile : null,
      chainFile: fs.existsSync(chainFile) ? chainFile : null,
      certExists: true,
      keyExists: fs.existsSync(keyFile),
      chainExists: fs.existsSync(chainFile)
    }
    
    // 读取证书详细信息
    try {
      const certDetails = execSync(`openssl x509 -in "${certFile}" -noout -text 2>/dev/null`, {
        encoding: 'utf8',
        timeout: 5000
      })
      
      const dates = execSync(`openssl x509 -in "${certFile}" -noout -dates 2>/dev/null`, {
        encoding: 'utf8',
        timeout: 3000
      })
      
      const subject = execSync(`openssl x509 -in "${certFile}" -noout -subject 2>/dev/null`, {
        encoding: 'utf8',
        timeout: 3000
      })
      
      const issuer = execSync(`openssl x509 -in "${certFile}" -noout -issuer 2>/dev/null`, {
        encoding: 'utf8',
        timeout: 3000
      })
      
      const serial = execSync(`openssl x509 -in "${certFile}" -noout -serial 2>/dev/null`, {
        encoding: 'utf8',
        timeout: 3000
      })
      
      const fingerprint = execSync(`openssl x509 -in "${certFile}" -noout -fingerprint -sha256 2>/dev/null`, {
        encoding: 'utf8',
        timeout: 3000
      })
      
      // 解析日期
      const notBeforeMatch = dates.match(/notBefore=(.+)/i)
      const notAfterMatch = dates.match(/notAfter=(.+)/i)
      
      // 解析主题和颁发者
      const subjectMatch = subject.match(/subject=(.+)/i)
      const issuerMatch = issuer.match(/issuer=(.+)/i)
      
      // 解析序列号
      const serialMatch = serial.match(/serial=(.+)/i)
      
      // 解析指纹
      const fingerprintMatch = fingerprint.match(/SHA256 Fingerprint=(.+)/i)
      
      // 提取SAN（Subject Alternative Names）
      let sanList = []
      const sanMatch = certDetails.match(/Subject Alternative Name:\s*(.+)/i)
      if (sanMatch) {
        const sanText = sanMatch[1]
        // 提取DNS和IP条目
        const dnsMatches = sanText.matchAll(/DNS:([^,\s]+)/gi)
        const ipMatches = sanText.matchAll(/IP Address:([^,\s]+)/gi)
        for (const match of dnsMatches) {
          sanList.push({ type: 'DNS', value: match[1] })
        }
        for (const match of ipMatches) {
          sanList.push({ type: 'IP', value: match[1] })
        }
      }
      
      certInfo = {
        ...certInfo,
        details: certDetails,
        notBefore: notBeforeMatch ? notBeforeMatch[1].trim() : null,
        notAfter: notAfterMatch ? notAfterMatch[1].trim() : null,
        expiresAt: notAfterMatch ? new Date(notAfterMatch[1].trim()).toLocaleDateString('zh-CN') : null,
        subject: subjectMatch ? subjectMatch[1].trim() : null,
        issuer: issuerMatch ? issuerMatch[1].trim() : null,
        serial: serialMatch ? serialMatch[1].trim() : null,
        fingerprint: fingerprintMatch ? fingerprintMatch[1].trim() : null,
        san: sanList,
        isValid: notAfterMatch ? new Date(notAfterMatch[1].trim()) > new Date() : false
      }
    } catch (e) {
      console.error(`解析证书 ${certName} 详细信息失败:`, e)
      // 即使解析失败，也返回基本信息
    }
    
    // 检查证书是否被域名使用
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let usedByDomains = []
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        const domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
        Object.keys(domainCertMap).forEach(domain => {
          if (domainCertMap[domain] === certName) {
            usedByDomains.push(domain)
          }
        })
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    certInfo.usedByDomains = usedByDomains
    
    res.json({
      success: true,
      certificate: certInfo
    })
  } catch (error) {
    console.error('获取证书详细信息失败:', error)
    res.status(500).json({
      success: false,
      error: '获取证书详细信息失败',
      message: error.message
    })
  }
})

// 删除证书
app.delete('/api/cert/:certName', auth, (req, res) => {
  try {
    const certName = req.params.certName
    
    if (!certName) {
      return res.status(400).json({
        success: false,
        error: '证书名称参数无效'
      })
    }
    
    // 检查证书是否被域名使用
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    let usedByDomains = []
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        const domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
        Object.keys(domainCertMap).forEach(domain => {
          if (domainCertMap[domain] === certName) {
            usedByDomains.push(domain)
          }
        })
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    if (usedByDomains.length > 0) {
      return res.status(400).json({
        success: false,
        error: '证书正在被使用，无法删除',
        message: `证书被以下域名使用: ${usedByDomains.join(', ')}。请先解除域名关联后再删除证书。`,
        usedByDomains: usedByDomains
      })
    }
    
    // 删除证书文件
    const certFile = `/etc/pki/tls/${certName}.crt`
    const keyFile = `/etc/pki/tls/${certName}.key`
    const chainFile = `/etc/pki/tls/${certName}.chain.crt`
    
    let deletedFiles = []
    let errors = []
    
    if (fs.existsSync(certFile)) {
      try {
        fs.unlinkSync(certFile)
        deletedFiles.push(certFile)
        console.log(`[删除证书] 已删除证书文件: ${certFile}`)
      } catch (e) {
        errors.push(`删除证书文件失败: ${e.message}`)
        console.error(`[删除证书] 删除证书文件失败: ${certFile}`, e)
      }
    }
    
    if (fs.existsSync(keyFile)) {
      try {
        fs.unlinkSync(keyFile)
        deletedFiles.push(keyFile)
        console.log(`[删除证书] 已删除私钥文件: ${keyFile}`)
      } catch (e) {
        errors.push(`删除私钥文件失败: ${e.message}`)
        console.error(`[删除证书] 删除私钥文件失败: ${keyFile}`, e)
      }
    }
    
    if (fs.existsSync(chainFile)) {
      try {
        fs.unlinkSync(chainFile)
        deletedFiles.push(chainFile)
        console.log(`[删除证书] 已删除证书链文件: ${chainFile}`)
      } catch (e) {
        errors.push(`删除证书链文件失败: ${e.message}`)
        console.error(`[删除证书] 删除证书链文件失败: ${chainFile}`, e)
      }
    }
    
    if (deletedFiles.length === 0) {
      return res.status(404).json({
        success: false,
        error: '证书文件不存在'
      })
    }
    
    if (errors.length > 0) {
      return res.status(500).json({
        success: false,
        error: '部分文件删除失败',
        message: errors.join('; '),
        deletedFiles: deletedFiles
      })
    }
    
    res.json({
      success: true,
      message: '证书已删除',
      deletedFiles: deletedFiles
    })
  } catch (error) {
    console.error('删除证书失败:', error)
    res.status(500).json({
      success: false,
      error: '删除证书失败',
      message: error.message
    })
  }
})

app.get('/api/cert/list', auth, (req, res) => {
  try {
    const certDir = '/etc/pki/tls'
    const certificates = []
    const domainCertMap = {}
    
    // 读取域名-证书关联配置
    const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
    if (fs.existsSync(domainCertConfigFile)) {
      try {
        const config = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
        Object.assign(domainCertMap, config)
      } catch (e) {
        console.warn('读取域名-证书关联配置失败:', e)
      }
    }
    
    if (fs.existsSync(certDir)) {
      const files = fs.readdirSync(certDir)
      const certSet = new Set()
      
      // 查找所有证书文件（排除chain证书）
      files.forEach(file => {
        if (file.endsWith('.crt')) {
          const certName = file.replace('.crt', '')
          // 排除chain证书（包含chain、ca-bundle、intermediate等关键词）
          const lowerName = certName.toLowerCase()
          if (!lowerName.includes('chain') && 
              !lowerName.includes('ca-bundle') && 
              !lowerName.includes('intermediate') &&
              !lowerName.endsWith('_chain') &&
              !lowerName.endsWith('-chain')) {
            certSet.add(certName)
          }
        }
      })
      
      // 检查每个证书的状态
      certSet.forEach(certName => {
        const certFile = path.join(certDir, `${certName}.crt`)
        const keyFile = path.join(certDir, `${certName}.key`)
        
        let expiresAt = null
        let domains = []
        
        if (fs.existsSync(certFile)) {
          try {
            const certInfo = execSync(`openssl x509 -in "${certFile}" -noout -dates 2>/dev/null`, { 
              encoding: 'utf8',
              timeout: 3000
            })
            const match = certInfo.match(/notAfter=(.+)/i)
            if (match) {
              expiresAt = new Date(match[1].trim()).toLocaleDateString('zh-CN')
            }
          } catch (e) {
            console.error(`解析证书 ${certName} 失败:`, e)
          }
        }
        
        // 查找使用此证书的域名
        Object.keys(domainCertMap).forEach(domain => {
          if (domainCertMap[domain] === certName) {
            domains.push(domain)
          }
        })
        
        certificates.push({
          name: certName,
          expiresAt: expiresAt,
          domains: domains
        })
      })
    }
    
    res.json({
      success: true,
      certificates: certificates
    })
  } catch (error) {
    console.error('获取证书列表失败:', error)
    res.status(500).json({
      success: false,
      error: '获取证书列表失败',
      message: error.message
    })
  }
})

// 辅助：从配置内容中判断是否包含有效的 HTTP->HTTPS 跳转块，并提取域名
function parseHttpRedirectConfig(content, fileNameForDomain) {
  if (!content || typeof content !== 'string') return []
  const lines = content.replace(/\r\n/g, '\n').split('\n')
  const hasRewriteEngine = lines.some(l => /^\s*RewriteEngine\s+On\s*$/im.test(l.trim()))
  const hasRewriteCond = lines.some(l => /RewriteCond\s+%\{HTTPS\}\s+off/i.test(l))
  const hasRewriteRule = lines.some(l => /RewriteRule\s+.*https:\/\//i.test(l))
  if (!hasRewriteEngine || !hasRewriteCond || !hasRewriteRule) return []
  const domains = []
  if (fileNameForDomain) {
    const m = fileNameForDomain.match(/^(.+)_http\.conf$/)
    if (m && m[1] && /^[a-zA-Z0-9.-]+$/.test(m[1].trim())) domains.push(m[1].trim())
  }
  for (const line of lines) {
    const t = line.trim()
    if (t.startsWith('#') || !t) continue
    const sn = t.match(/^ServerName\s+([^\s#]+)/i)
    if (sn && sn[1] && /^[a-zA-Z0-9.-]+$/.test(sn[1].trim()) && !domains.includes(sn[1].trim())) domains.push(sn[1].trim())
  }
  return domains
}

// SSL状态检查API
// 检查HTTP跳转HTTPS配置状态
app.get('/api/cert/http-redirect-status', auth, (req, res) => {
  try {
    const apacheConfDir = '/etc/httpd/conf.d'
    const configDir = path.join(ROOT_DIR, 'config')
    const httpRedirectStateFile = path.join(configDir, 'http-redirect-enabled.json')
    
    // 检查用户是否明确启用了HTTP跳转（通过状态文件）
    let userEnabledHttpRedirect = false
    if (fs.existsSync(httpRedirectStateFile)) {
      try {
        const stateData = JSON.parse(fs.readFileSync(httpRedirectStateFile, 'utf8'))
        userEnabledHttpRedirect = stateData.enabled === true
      } catch (e) {
        console.warn('[HTTP跳转状态检查] 读取状态文件失败:', e.message)
      }
    }
    
    let httpRedirectEnabled = false
    const configuredDomains = []
    
    // 只有在用户明确启用的情况下，才检查配置文件
    if (userEnabledHttpRedirect) {
      let files = []
      try {
        if (fs.existsSync(apacheConfDir)) files = fs.readdirSync(apacheConfDir).filter(f => f.endsWith('_http.conf'))
      } catch (e) {
        console.warn('[HTTP跳转状态检查] readdir conf.d 失败:', e.message)
      }
      // 使用 fs 读取并解析每个 *_http.conf
      for (const file of files) {
        const filePath = path.join(apacheConfDir, file)
        try {
          const content = fs.readFileSync(filePath, 'utf8')
          const domains = parseHttpRedirectConfig(content, file)
          domains.forEach(d => { if (d && !configuredDomains.includes(d)) configuredDomains.push(d) })
          if (domains.length > 0) httpRedirectEnabled = true
        } catch (e) {
          console.warn(`[HTTP跳转状态检查] 读取 ${file} 失败:`, e.message)
        }
      }
      // 若状态文件存在但 fs 未读到任何有效配置（如无权限），用 sudo 再试一次
      if (configuredDomains.length === 0) {
        try {
          const listOut = execSync('sudo ls /etc/httpd/conf.d/*_http.conf 2>/dev/null || true', { encoding: 'utf8', timeout: 5000 })
          const paths = listOut.trim().split(/\n/).map(p => p.trim()).filter(Boolean)
          for (const p of paths) {
            const name = path.basename(p)
            const content = execSync(`sudo cat "${p}"`, { encoding: 'utf8', timeout: 5000 })
            const domains = parseHttpRedirectConfig(content, name)
            domains.forEach(d => { if (d && !configuredDomains.includes(d)) configuredDomains.push(d) })
            if (domains.length > 0) httpRedirectEnabled = true
          }
        } catch (e) {
          console.warn('[HTTP跳转状态检查] sudo 列举/读取 _http.conf 失败:', e.message)
        }
      }
      // 若仍无 *_http.conf 有效配置，检查 mailmgmt.conf / mail-ops.conf 中是否有跳转块（与启用时可能写入的默认 vhost 一致）
      if (configuredDomains.length === 0) {
        for (const confName of ['mailmgmt.conf', 'mail-ops.conf']) {
          const confPath = `/etc/httpd/conf.d/${confName}`
          let content = ''
          try {
            content = fs.readFileSync(confPath, 'utf8')
          } catch {
            try {
              content = execSync(`sudo cat "${confPath}"`, { encoding: 'utf8', timeout: 5000 })
            } catch {
              continue
            }
          }
          const domains = parseHttpRedirectConfig(content, null)
          if (domains.length > 0 || (content.includes('RewriteEngine') && content.includes('%{HTTPS}') && content.includes('https://'))) {
            configuredDomains.push('default')
            httpRedirectEnabled = true
            break
          }
        }
      }
    }
    
    const validDomains = configuredDomains.filter(d => d && d.match(/^[a-zA-Z0-9.-]+$/))
    httpRedirectEnabled = userEnabledHttpRedirect && validDomains.length > 0
    
    // 额外验证：检查Apache配置语法是否正确
    let apacheConfigValid = false
    let apacheConfigError = null
    if (httpRedirectEnabled) {
      try {
        const { execSync } = require('child_process')
        // 尝试使用sudo执行，如果失败则直接执行
        let httpdTestOutput = ''
        try {
          httpdTestOutput = execSync('sudo httpd -t', { 
            stdio: ['pipe', 'pipe', 'pipe'], 
            encoding: 'utf8',
            timeout: 5000 
          })
        } catch (sudoError) {
          // 如果sudo失败，尝试直接执行
          try {
            httpdTestOutput = execSync('httpd -t', { 
              stdio: ['pipe', 'pipe', 'pipe'], 
              encoding: 'utf8',
              timeout: 5000 
            })
          } catch (nonSudoError) {
            throw nonSudoError
          }
        }
        
        // 检查输出中是否包含"Syntax OK"
        if (httpdTestOutput && (httpdTestOutput.includes('Syntax OK') || httpdTestOutput.trim() === '')) {
          apacheConfigValid = true
        } else {
          apacheConfigError = httpdTestOutput || '未知错误'
          console.warn('[HTTP跳转状态检查] Apache配置语法检查失败，输出:', httpdTestOutput)
        }
      } catch (e) {
        apacheConfigError = e.message || e.toString()
        console.warn('[HTTP跳转状态检查] Apache配置语法检查失败:', apacheConfigError)
        // 如果配置语法检查失败，但仍然有有效的配置文件，仍然认为已配置
        // 因为配置可能已经生效，只是语法检查命令执行失败
        apacheConfigValid = false
      }
    }
    
    // 最终状态：用户明确启用且配置文件存在且有有效域名
    const finalEnabled = userEnabledHttpRedirect && httpRedirectEnabled && validDomains.length > 0
    
    console.log(`[HTTP跳转状态检查] 用户启用状态: ${userEnabledHttpRedirect}, 配置文件存在: ${httpRedirectEnabled}, Apache语法检查: ${apacheConfigValid}, 有效域名数: ${validDomains.length}, 最终状态: ${finalEnabled}, 域名列表: [${validDomains.join(', ')}]`)
    if (apacheConfigError) {
      console.log(`[HTTP跳转状态检查] Apache语法检查错误: ${apacheConfigError}`)
    }
    
    res.json({
      success: true,
      enabled: finalEnabled,
      configuredDomains: validDomains,
      configFilesExist: httpRedirectEnabled,
      apacheConfigValid: apacheConfigValid,
      apacheConfigError: apacheConfigError || null
    })
  } catch (error) {
    console.error('检查HTTP跳转状态失败:', error)
    res.status(500).json({
      success: false,
      error: '检查HTTP跳转状态失败',
      message: error.message
    })
  }
})

// 禁用HTTP跳转HTTPS（删除HTTP跳转配置与状态文件并重启Apache）
app.post('/api/cert/disable-http-redirect', auth, (req, res) => {
  try {
    const apacheConfDir = '/etc/httpd/conf.d'
    const configDir = path.join(ROOT_DIR, 'config')
    const httpRedirectStateFile = path.join(configDir, 'http-redirect-enabled.json')
    
    // 删除状态文件，标记为禁用（config 目录通常为应用可写）
    if (fs.existsSync(httpRedirectStateFile)) {
      try {
        fs.unlinkSync(httpRedirectStateFile)
        console.log('[禁用HTTP跳转] 已删除HTTP跳转状态文件')
      } catch (e) {
        console.warn('[禁用HTTP跳转] 删除状态文件失败:', e.message)
      }
    }
    
    // 使用 sudo rm -f 删除所有 *_http.conf（/etc/httpd/conf.d 需 root 权限）
    const deletedFiles = []
    if (fs.existsSync(apacheConfDir)) {
      const files = fs.readdirSync(apacheConfDir).filter(f => f.endsWith('_http.conf'))
      files.forEach(f => deletedFiles.push(f))
    }
    try {
      execSync('sudo rm -f /etc/httpd/conf.d/*_http.conf', { timeout: 10000, encoding: 'utf8' })
      console.log('[禁用HTTP跳转] 已删除所有 *_http.conf 配置文件')
    } catch (rmErr) {
      try {
        execSync('rm -f /etc/httpd/conf.d/*_http.conf', { timeout: 10000, encoding: 'utf8' })
        console.log('[禁用HTTP跳转] 已删除 *_http.conf（无 sudo）')
      } catch (e) {
        console.warn('[禁用HTTP跳转] 删除 *_http.conf 失败:', e.message)
      }
    }
    
    // 移除默认 HTTP 虚拟主机中的 HTTPS 跳转块（enable-ssl 时 cert_setup.sh 会写入 mailmgmt.conf，仅删 *_http.conf 不够）
    const httpsRedirectBlockRe = /\s*#\s*自动跳转到HTTPS[^\n]*\n\s*RewriteEngine On\s*\n\s*RewriteCond\s+%\{HTTPS\}\s+off\s*\n\s*RewriteRule\s+[^\n]+https:[^\n]+\[R=301,L\]\s*\n?/g
    const httpsRedirectCommentRe = /\s*#\s*HTTPS重定向\s*\n\s*RewriteEngine On\s*\n\s*RewriteCond\s+%\{HTTPS\}\s+off\s*\n\s*RewriteRule\s+[^\n]+https:[^\n]+\[L,R=301\]\s*\n?/g
    const confFilesToClean = ['/etc/httpd/conf.d/mailmgmt.conf', '/etc/httpd/conf.d/mail-ops.conf']
    for (const confPath of confFilesToClean) {
      httpsRedirectBlockRe.lastIndex = 0
      httpsRedirectCommentRe.lastIndex = 0
      try {
        let content = ''
        try {
          content = execSync(`sudo cat "${confPath}"`, { timeout: 5000, encoding: 'utf8' })
        } catch (catErr) {
          try {
            content = fs.readFileSync(confPath, 'utf8')
          } catch {
            continue
          }
        }
        const baseName = path.basename(confPath)
        let newContent = content.replace(httpsRedirectBlockRe, '').replace(httpsRedirectCommentRe, '')
        if (newContent === content) continue
        httpsRedirectBlockRe.lastIndex = 0
        httpsRedirectCommentRe.lastIndex = 0
        const tmpPath = path.join(ROOT_DIR, 'config', `.${baseName}.tmp`)
        fs.writeFileSync(tmpPath, newContent, 'utf8')
        try {
          execSync(`sudo cp "${tmpPath}" "${confPath}"`, { timeout: 5000, encoding: 'utf8' })
          console.log(`[禁用HTTP跳转] 已从 ${baseName} 移除 HTTPS 跳转块`)
        } catch (cpErr) {
          try {
            execSync(`cp "${tmpPath}" "${confPath}"`, { timeout: 5000, encoding: 'utf8' })
            console.log(`[禁用HTTP跳转] 已从 ${baseName} 移除 HTTPS 跳转块（无 sudo）`)
          } catch (e2) {
            console.warn(`[禁用HTTP跳转] 写回 ${baseName} 失败:`, e2.message)
          }
        }
        fs.unlinkSync(tmpPath)
      } catch (e) {
        console.warn(`[禁用HTTP跳转] 处理 ${confPath} 失败:`, e.message)
      }
    }
    
    // 验证Apache配置语法
    let apacheConfigValid = false
    let apacheConfigError = null
    try {
      let httpdTestOutput = ''
      try {
        httpdTestOutput = execSync('sudo httpd -t', { stdio: ['pipe', 'pipe', 'pipe'], encoding: 'utf8', timeout: 5000 })
      } catch (sudoError) {
        try {
          httpdTestOutput = execSync('httpd -t', { stdio: ['pipe', 'pipe', 'pipe'], encoding: 'utf8', timeout: 5000 })
        } catch (nonSudoError) {
          throw nonSudoError
        }
      }
      if (httpdTestOutput && (httpdTestOutput.includes('Syntax OK') || String(httpdTestOutput).trim() === '')) {
        apacheConfigValid = true
      } else {
        apacheConfigError = httpdTestOutput || '未知错误'
      }
    } catch (e) {
      apacheConfigError = e.message || e.toString()
      console.warn('[禁用HTTP跳转] Apache配置语法检查失败:', apacheConfigError)
    }
    
    // 重启Apache服务（先 sudo，失败则无 sudo）
    let restartSuccess = false
    try {
      execSync('sudo systemctl restart httpd', { timeout: 30000, encoding: 'utf8' })
      restartSuccess = true
      console.log('[禁用HTTP跳转] Apache服务重启成功')
    } catch (restartError) {
      try {
        execSync('systemctl restart httpd', { timeout: 30000, encoding: 'utf8' })
        restartSuccess = true
        console.log('[禁用HTTP跳转] Apache服务重启成功（无 sudo）')
      } catch (e) {
        console.warn('[禁用HTTP跳转] Apache服务重启失败:', e.message)
      }
    }
    
    res.json({
      success: true,
      message: 'HTTP跳转HTTPS已禁用',
      deletedFiles,
      apacheConfigValid,
      apacheConfigError,
      restartSuccess
    })
  } catch (error) {
    console.error('禁用HTTP跳转失败:', error)
    res.status(500).json({
      success: false,
      error: '禁用HTTP跳转失败',
      message: error.message
    })
  }
})

app.get('/api/cert/ssl-status', auth, (req, res) => {
  try {
    // 检查Apache SSL配置
    const apacheConfDir = '/etc/httpd/conf.d'
    let sslEnabled = false
    
    if (fs.existsSync(apacheConfDir)) {
      const files = fs.readdirSync(apacheConfDir)
      // 检查是否有SSL虚拟主机配置
      sslEnabled = files.some(file => {
        if (file.endsWith('_ssl.conf') || file.includes('ssl')) {
          const content = fs.readFileSync(path.join(apacheConfDir, file), 'utf8')
          return content.includes('SSLEngine on')
        }
        return false
      })
    }
    
    res.json({
      success: true,
      enabled: sslEnabled
    })
  } catch (error) {
    console.error('检查SSL状态失败:', error)
    res.status(500).json({
      success: false,
      error: '检查SSL状态失败',
      message: error.message
    })
  }
})

// 配置multer用于文件上传
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadDir = '/tmp/cert-uploads'
    if (!fs.existsSync(uploadDir)) {
      fs.mkdirSync(uploadDir, { recursive: true })
    }
    cb(null, uploadDir)
  },
  filename: function (req, file, cb) {
    // 支持批量上传：字段名可能是 cert_0, key_0, chain_0 等格式
    // 也支持单个上传：字段名是 cert, key
    let certName = 'unknown'
    let index = null
    
    // 检查是否是批量上传格式（如 cert_0, key_1）
    const fieldMatch = file.fieldname.match(/^(\w+)_(\d+)$/)
    if (fieldMatch) {
      // 批量上传格式
      index = parseInt(fieldMatch[2])
      certName = req.body[`certName_${index}`] || 'unknown'
    } else {
      // 单个上传格式
      certName = req.body.certName || 'unknown'
    }
    
    const ext = path.extname(file.originalname)
    let fieldName = 'crt'
    
    // 根据字段名确定文件类型
    if (file.fieldname.startsWith('cert') || file.fieldname === 'cert') {
      fieldName = 'crt'
    } else if (file.fieldname.startsWith('key') || file.fieldname === 'key') {
      fieldName = 'key'
    } else if (file.fieldname.startsWith('chain') || file.fieldname === 'chain') {
      fieldName = 'chain'
    }
    
    // 生成唯一文件名：certName_index_fieldName.ext
    // 例如：www.xm666.fun_0_crt.crt, www.xm666.fun_0_key.key
    const uniqueId = index !== null ? `_${index}` : ''
    const filename = `${certName}${uniqueId}_${fieldName}${ext}`
    
    cb(null, filename)
  }
})

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB限制
  },
  fileFilter: function (req, file, cb) {
    // 对于批量上传，字段名可能是 cert_0, key_0, chain_0 等格式
    // 对于单个上传，字段名是 cert, key
    const fieldname = file.fieldname || ''
    
    // 验证文件类型
    if (fieldname.startsWith('cert') || fieldname === 'cert') {
      // 证书文件：.crt, .pem, .cer
      const allowedExts = ['.crt', '.pem', '.cer']
      const ext = path.extname(file.originalname).toLowerCase()
      if (allowedExts.includes(ext)) {
        cb(null, true)
      } else {
        cb(new Error('证书文件格式无效，仅支持 .crt, .pem, .cer 格式'))
      }
    } else if (fieldname.startsWith('key') || fieldname === 'key') {
      // 私钥文件：.key, .pem
      const allowedExts = ['.key', '.pem']
      const ext = path.extname(file.originalname).toLowerCase()
      if (allowedExts.includes(ext)) {
        cb(null, true)
      } else {
        cb(new Error('私钥文件格式无效，仅支持 .key, .pem 格式'))
      }
    } else if (fieldname.startsWith('chain') || fieldname === 'chain') {
      // 证书链文件：.crt, .pem, .cer
      const allowedExts = ['.crt', '.pem', '.cer']
      const ext = path.extname(file.originalname).toLowerCase()
      if (allowedExts.includes(ext)) {
        cb(null, true)
      } else {
        cb(new Error('证书链文件格式无效，仅支持 .crt, .pem, .cer 格式'))
      }
    } else {
      // 其他字段名允许通过（可能是批量上传的其他字段）
      console.log('[fileFilter] 允许未知字段名:', fieldname, '文件名:', file.originalname)
      cb(null, true)
    }
  }
})

// 证书上传API（使用multer处理文件上传，仅处理文件，不关联域名）
app.post('/api/cert/upload', auth, upload.fields([
  { name: 'cert', maxCount: 1 },
  { name: 'key', maxCount: 1 }
]), async (req, res) => {
  try {
    const certName = req.body.certName
    
    if (!certName || typeof certName !== 'string' || !certName.trim()) {
      return res.status(400).json({
        success: false,
        error: '证书名称参数无效'
      })
    }
    
    // 验证证书名称格式（允许字母、数字、连字符、下划线）
    const certNameRegex = /^[a-z0-9_-]+$/i
    if (!certNameRegex.test(certName.trim())) {
      return res.status(400).json({
        success: false,
        error: '证书名称格式无效，只能包含字母、数字、连字符和下划线'
      })
    }
    
    const files = req.files
    
    if (!files || !files.cert || !files.key || !Array.isArray(files.cert) || !Array.isArray(files.key)) {
      return res.status(400).json({
        success: false,
        error: '请上传证书文件和私钥文件'
      })
    }
    
    const certFile = files.cert[0]
    const keyFile = files.key[0]
    
    const targetCertPath = `/etc/pki/tls/${certName.trim()}.crt`
    const targetKeyPath = `/etc/pki/tls/${certName.trim()}.key`
    
    // 检查是否已存在
    if (fs.existsSync(targetCertPath) || fs.existsSync(targetKeyPath)) {
      // 清理上传的临时文件
      if (certFile && certFile.path && fs.existsSync(certFile.path)) fs.unlinkSync(certFile.path)
      if (keyFile && keyFile.path && fs.existsSync(keyFile.path)) fs.unlinkSync(keyFile.path)
      return res.status(400).json({
        success: false,
        error: `证书 ${certName.trim()} 已存在，请使用不同的证书名称或先删除现有证书`
      })
    }
    
    // 确保目标目录存在
    const targetDir = '/etc/pki/tls'
    if (!fs.existsSync(targetDir)) {
      fs.mkdirSync(targetDir, { recursive: true })
    }
    
    // 验证证书和私钥内容
    try {
      const certContent = fs.readFileSync(certFile.path, 'utf8')
      const keyContent = fs.readFileSync(keyFile.path, 'utf8')
      
      // 基本验证：检查是否包含证书和私钥的典型标识
      if (!certContent.includes('BEGIN CERTIFICATE') && !certContent.includes('BEGIN CERT')) {
        throw new Error('证书文件格式无效')
      }
      
      if (!keyContent.includes('BEGIN') || (!keyContent.includes('PRIVATE KEY') && !keyContent.includes('RSA PRIVATE KEY'))) {
        throw new Error('私钥文件格式无效')
      }
      
      // 复制文件到目标位置（使用sudo以确保权限）
      try {
        execSync(`sudo cp "${certFile.path}" "${targetCertPath}"`, { timeout: 5000 })
        execSync(`sudo cp "${keyFile.path}" "${targetKeyPath}"`, { timeout: 5000 })
        execSync(`sudo chmod 644 "${targetCertPath}"`, { timeout: 3000 })
        execSync(`sudo chmod 600 "${targetKeyPath}"`, { timeout: 3000 })
      } catch (sudoError) {
        // 如果sudo失败，尝试直接复制（可能需要手动设置权限）
        fs.copyFileSync(certFile.path, targetCertPath)
        fs.copyFileSync(keyFile.path, targetKeyPath)
        fs.chmodSync(targetCertPath, 0o644)
        fs.chmodSync(targetKeyPath, 0o600)
      }
      
      // 清理临时文件
      fs.unlinkSync(certFile.path)
      fs.unlinkSync(keyFile.path)
      
      res.json({
        success: true,
        message: '证书上传成功',
        certName: certName.trim()
      })
    } catch (validationError) {
      // 清理临时文件
      if (certFile && certFile.path && fs.existsSync(certFile.path)) fs.unlinkSync(certFile.path)
      if (keyFile && keyFile.path && fs.existsSync(keyFile.path)) fs.unlinkSync(keyFile.path)
      
      return res.status(400).json({
        success: false,
        error: '证书或私钥文件验证失败: ' + (validationError.message || '未知错误')
      })
    }
  } catch (error) {
    console.error('证书上传失败:', error)
    
    // 清理临时文件
    if (req.files) {
      const files = req.files
      if (files.cert && Array.isArray(files.cert) && files.cert[0] && files.cert[0].path && fs.existsSync(files.cert[0].path)) {
        fs.unlinkSync(files.cert[0].path)
      }
      if (files.key && Array.isArray(files.key) && files.key[0] && files.key[0].path && fs.existsSync(files.key[0].path)) {
        fs.unlinkSync(files.key[0].path)
      }
    }
    
    res.status(500).json({
      success: false,
      error: '证书上传失败',
      message: (error && error.message) ? error.message : '未知错误'
    })
  }
})

// 批量上传证书API
app.post('/api/cert/batch-upload', auth, upload.any(), async (req, res) => {
  console.log('[批量上传] ========== 开始处理批量上传请求 ==========')
  try {
    console.log('[批量上传] 收到请求')
    console.log('[批量上传] req.body:', JSON.stringify(req.body, null, 2))
    console.log('[批量上传] req.body keys:', Object.keys(req.body))
    console.log('[批量上传] 文件数量:', req.files ? req.files.length : 0)
    if (req.files && req.files.length > 0) {
      console.log('[批量上传] 文件列表:', req.files.map(f => ({ fieldname: f.fieldname, originalname: f.originalname, path: f.path })))
    } else {
      console.log('[批量上传] 警告: req.files为空或未定义')
    }
    
    const count = parseInt(req.body.count) || 0
    
    if (!count || count <= 0) {
      console.error('[批量上传] 证书数量参数无效:', count)
      return res.status(400).json({
        success: false,
        error: '证书数量参数无效'
      })
    }
    
    const results = []
    
    // multer.any()返回的文件可能是数组或对象，需要统一处理
    let files = []
    if (req.files) {
      if (Array.isArray(req.files)) {
        files = req.files
      } else if (typeof req.files === 'object') {
        // 如果是对象，将所有值展平为数组
        files = Object.values(req.files).flat().filter(f => f && typeof f === 'object')
      }
    }
    
    console.log('[批量上传] req.files类型:', typeof req.files)
    console.log('[批量上传] req.files是否为数组:', Array.isArray(req.files))
    console.log('[批量上传] 处理后的文件数组长度:', files.length)
    console.log('[批量上传] 处理后的文件列表:', files.map(f => ({ fieldname: f.fieldname, originalname: f.originalname, path: f.path })))
    
    // 确保目标目录存在
    const targetDir = '/etc/pki/tls'
    try {
      if (!fs.existsSync(targetDir)) {
        fs.mkdirSync(targetDir, { recursive: true })
        console.log('[批量上传] 创建目标目录:', targetDir)
      }
    } catch (dirError) {
      console.error('[批量上传] 创建目标目录失败:', dirError.message)
      throw new Error('无法创建证书目录: ' + dirError.message)
    }
    
    // 处理每个证书
    for (let i = 0; i < count; i++) {
      try {
        // 使用简化的字段名格式：certName_0, certName_1, ...
        const certName = req.body[`certName_${i}`]
        
        console.log(`[批量上传] 证书 ${i}: certName =`, certName)
        console.log(`[批量上传] 证书 ${i}: req.body keys =`, Object.keys(req.body).filter(k => k.includes(`${i}`)))
        
        if (!certName || typeof certName !== 'string' || !certName.trim()) {
          console.error(`[批量上传] 证书 ${i} 名称参数无效:`, certName)
          results.push({
            index: i,
            success: false,
            certName: certName || `证书${i + 1}`,
            error: '证书名称参数无效'
          })
          continue
        }
        
        // 验证证书名称格式（允许域名格式，包含点号）
        const trimmedCertName = certName.trim()
        // 允许字母、数字、连字符、下划线和点号，但不能以点号开头或结尾
        const certNameRegex = /^[a-z0-9_-]+(\.[a-z0-9_-]+)*$/i
        if (!certNameRegex.test(trimmedCertName)) {
          console.error(`[批量上传] 证书 ${i} 名称格式验证失败:`, trimmedCertName)
          results.push({
            index: i,
            success: false,
            certName: trimmedCertName,
            error: '证书名称格式无效，应为有效的域名格式（如：example.com 或 www.example.com）'
          })
          continue
        }
        
        // 查找对应的文件（使用简化的字段名格式）
        const certFile = files.find(f => f.fieldname === `cert_${i}`)
        const keyFile = files.find(f => f.fieldname === `key_${i}`)
        const chainFile = files.find(f => f.fieldname === `chain_${i}`)
        
        console.log(`[批量上传] 证书 ${i}: certFile =`, certFile ? certFile.originalname : '未找到')
        console.log(`[批量上传] 证书 ${i}: keyFile =`, keyFile ? keyFile.originalname : '未找到')
        console.log(`[批量上传] 证书 ${i}: chainFile =`, chainFile ? chainFile.originalname : '未找到')
        
        if (!certFile || !keyFile) {
          console.error(`[批量上传] 证书 ${i} 缺少必需文件`)
          results.push({
            index: i,
            success: false,
            certName: certName.trim(),
            error: '缺少证书文件或私钥文件'
          })
          // 清理已上传的文件
          if (certFile && certFile.path && fs.existsSync(certFile.path)) fs.unlinkSync(certFile.path)
          if (keyFile && keyFile.path && fs.existsSync(keyFile.path)) fs.unlinkSync(keyFile.path)
          if (chainFile && chainFile.path && fs.existsSync(chainFile.path)) fs.unlinkSync(chainFile.path)
          continue
        }
        
        const targetCertPath = `/etc/pki/tls/${trimmedCertName}.crt`
        const targetKeyPath = `/etc/pki/tls/${trimmedCertName}.key`
        // chain证书保存为 certName.chain.crt 格式（如果上传了chain文件）
        const targetChainPath = chainFile ? `/etc/pki/tls/${trimmedCertName}.chain.crt` : null
        
        // 检查是否已存在
        if (fs.existsSync(targetCertPath) || fs.existsSync(targetKeyPath)) {
          results.push({
            index: i,
            success: false,
            certName: certName.trim(),
            error: `证书 ${certName.trim()} 已存在，请使用不同的证书名称或先删除现有证书`
          })
          // 清理已上传的文件
          if (certFile && certFile.path && fs.existsSync(certFile.path)) fs.unlinkSync(certFile.path)
          if (keyFile && keyFile.path && fs.existsSync(keyFile.path)) fs.unlinkSync(keyFile.path)
          if (chainFile && chainFile.path && fs.existsSync(chainFile.path)) fs.unlinkSync(chainFile.path)
          continue
        }
        
        // 验证证书和私钥内容
        try {
          // 检查文件路径是否存在
          console.log(`[批量上传] 证书 ${i}: 检查文件路径`)
          console.log(`[批量上传] 证书 ${i}: certFile对象:`, JSON.stringify({
            fieldname: certFile.fieldname,
            originalname: certFile.originalname,
            path: certFile.path,
            size: certFile.size
          }, null, 2))
          console.log(`[批量上传] 证书 ${i}: keyFile对象:`, JSON.stringify({
            fieldname: keyFile.fieldname,
            originalname: keyFile.originalname,
            path: keyFile.path,
            size: keyFile.size
          }, null, 2))
          
          if (!certFile.path) {
            throw new Error(`证书文件路径为空: certFile.path = ${certFile.path}`)
          }
          if (!fs.existsSync(certFile.path)) {
            console.error(`[批量上传] 证书 ${i}: 证书文件不存在: ${certFile.path}`)
            // 尝试列出临时目录的内容
            const tmpDir = path.dirname(certFile.path)
            if (fs.existsSync(tmpDir)) {
              const files = fs.readdirSync(tmpDir)
              console.error(`[批量上传] 证书 ${i}: 临时目录内容:`, files)
            } else {
              console.error(`[批量上传] 证书 ${i}: 临时目录不存在: ${tmpDir}`)
            }
            throw new Error(`证书文件路径无效: ${certFile.path}`)
          }
          if (!keyFile.path) {
            throw new Error(`私钥文件路径为空: keyFile.path = ${keyFile.path}`)
          }
          if (!fs.existsSync(keyFile.path)) {
            console.error(`[批量上传] 证书 ${i}: 私钥文件不存在: ${keyFile.path}`)
            throw new Error(`私钥文件路径无效: ${keyFile.path}`)
          }
        
          console.log(`[批量上传] 证书 ${i}: 文件路径验证通过 - certFile.path = ${certFile.path}, keyFile.path = ${keyFile.path}`)
          
          const certContent = fs.readFileSync(certFile.path, 'utf8')
          const keyContent = fs.readFileSync(keyFile.path, 'utf8')
          
          // 基本验证：检查是否包含证书和私钥的典型标识
          if (!certContent.includes('BEGIN CERTIFICATE') && !certContent.includes('BEGIN CERT')) {
            throw new Error('证书文件格式无效')
          }
          
          if (!keyContent.includes('BEGIN') || (!keyContent.includes('PRIVATE KEY') && !keyContent.includes('RSA PRIVATE KEY'))) {
            throw new Error('私钥文件格式无效')
          }
          
          // 验证证书链文件（如果提供）
          if (chainFile) {
            if (!chainFile.path || !fs.existsSync(chainFile.path)) {
              console.warn(`[批量上传] 证书 ${i}: 证书链文件路径无效，跳过`)
            } else {
              const chainContent = fs.readFileSync(chainFile.path, 'utf8')
              if (!chainContent.includes('BEGIN CERTIFICATE') && !chainContent.includes('BEGIN CERT')) {
                throw new Error('证书链文件格式无效')
              }
            }
          }
          
          console.log(`[批量上传] 证书 ${i}: 文件验证通过，开始复制到目标位置`)
          
          // 复制文件到目标位置（使用sudo以确保权限）
          try {
            execSync(`sudo cp "${certFile.path}" "${targetCertPath}"`, { timeout: 5000 })
            execSync(`sudo cp "${keyFile.path}" "${targetKeyPath}"`, { timeout: 5000 })
            execSync(`sudo chmod 644 "${targetCertPath}"`, { timeout: 3000 })
            execSync(`sudo chmod 600 "${targetKeyPath}"`, { timeout: 3000 })
            
            if (chainFile && chainFile.path && fs.existsSync(chainFile.path) && targetChainPath) {
              execSync(`sudo cp "${chainFile.path}" "${targetChainPath}"`, { timeout: 5000 })
              execSync(`sudo chmod 644 "${targetChainPath}"`, { timeout: 3000 })
            }
            
            console.log(`[批量上传] 证书 ${i}: 文件复制成功（使用sudo）`)
          } catch (sudoError) {
            console.warn(`[批量上传] 证书 ${i}: sudo复制失败，尝试直接复制:`, sudoError.message)
            // 如果sudo失败，尝试直接复制（可能需要手动设置权限）
            fs.copyFileSync(certFile.path, targetCertPath)
            fs.copyFileSync(keyFile.path, targetKeyPath)
            fs.chmodSync(targetCertPath, 0o644)
            fs.chmodSync(targetKeyPath, 0o600)
            
            if (chainFile && chainFile.path && fs.existsSync(chainFile.path) && targetChainPath) {
              fs.copyFileSync(chainFile.path, targetChainPath)
              fs.chmodSync(targetChainPath, 0o644)
            }
            
            console.log(`[批量上传] 证书 ${i}: 文件复制成功（直接复制）`)
          }
          
          // 清理临时文件
          try {
            if (certFile.path && fs.existsSync(certFile.path)) {
              fs.unlinkSync(certFile.path)
            }
            if (keyFile.path && fs.existsSync(keyFile.path)) {
              fs.unlinkSync(keyFile.path)
            }
            if (chainFile && chainFile.path && fs.existsSync(chainFile.path)) {
              fs.unlinkSync(chainFile.path)
            }
          } catch (cleanupError) {
            console.warn(`[批量上传] 证书 ${i}: 清理临时文件失败:`, cleanupError.message)
          }
          
          // 检查证书名称是否是域名格式，如果是，自动配置Apache并添加到SSL域名列表
          // trimmedCertName已在上面声明，这里直接使用
          const isDomainFormat = /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i.test(trimmedCertName)
          
          let apacheConfigMessage = ''
          let apacheConfigured = false
          if (isDomainFormat) {
            try {
              console.log(`[批量上传] 证书 ${i}: 检测到域名格式，开始自动配置Apache和添加SSL域名: ${trimmedCertName}`)
              
              // 验证证书文件是否已正确复制到目标位置
              const targetCertPath = `/etc/pki/tls/${trimmedCertName}.crt`
              const targetKeyPath = `/etc/pki/tls/${trimmedCertName}.key`
              
              if (!fs.existsSync(targetCertPath) || !fs.existsSync(targetKeyPath)) {
                console.error(`[批量上传] 证书 ${i}: 证书文件未找到，无法配置Apache`)
                console.error(`[批量上传] 证书 ${i}: 期望的证书文件: ${targetCertPath}`)
                console.error(`[批量上传] 证书 ${i}: 期望的私钥文件: ${targetKeyPath}`)
                apacheConfigMessage = '，证书文件未找到，无法配置Apache'
              } else {
                console.log(`[批量上传] 证书 ${i}: 证书文件已确认存在，开始配置Apache`)
                
                // 先保存域名-证书关联（这会自动添加到SSL域名列表）
                const domainCertConfigFile = path.join(ROOT_DIR, 'config', 'ssl-domain-cert.json')
                let domainCertMap = {}
                if (fs.existsSync(domainCertConfigFile)) {
                  try {
                    domainCertMap = JSON.parse(fs.readFileSync(domainCertConfigFile, 'utf8'))
                  } catch (e) {
                    console.warn('[批量上传] 读取域名-证书关联配置失败:', e)
                  }
                }
                domainCertMap[trimmedCertName] = trimmedCertName
                
                // 如果上传了chain证书，确保chain证书文件存在时自动关联
                if (chainFile && chainFile.path && fs.existsSync(chainFile.path)) {
                  const chainCertPath = `/etc/pki/tls/${trimmedCertName}.chain.crt`
                  if (fs.existsSync(chainCertPath)) {
                    console.log(`[批量上传] 证书 ${i}: 检测到chain证书文件，已自动关联: ${trimmedCertName}.chain.crt -> ${trimmedCertName}`)
                  }
                }
                
                const configDir = path.dirname(domainCertConfigFile)
                if (!fs.existsSync(configDir)) {
                  fs.mkdirSync(configDir, { recursive: true })
                }
                fs.writeFileSync(domainCertConfigFile, JSON.stringify(domainCertMap, null, 2), 'utf8')
                console.log(`[批量上传] 证书 ${i}: 域名-证书关联已保存: ${trimmedCertName} -> ${trimmedCertName}`)
                
                // 确保文件写入完成（同步fsync）
                try {
                  const fd = fs.openSync(domainCertConfigFile, 'r+')
                  fs.fsyncSync(fd)
                  fs.closeSync(fd)
                } catch (syncError) {
                  console.warn(`[批量上传] 证书 ${i}: 文件同步失败:`, syncError.message)
                }
                
                // 调用cert_setup.sh配置Apache（这会重启Apache）
                const scriptPath = path.join(ROOT_DIR, 'backend', 'scripts', 'cert_setup.sh')
                
                // 验证脚本文件是否存在
                if (!fs.existsSync(scriptPath)) {
                  console.error(`[批量上传] 证书 ${i}: cert_setup.sh脚本不存在: ${scriptPath}`)
                  apacheConfigMessage = '，cert_setup.sh脚本不存在，无法配置Apache'
                } else {
                  // 确保脚本有执行权限
                  try {
                    fs.chmodSync(scriptPath, 0o755)
                    console.log(`[批量上传] 证书 ${i}: 脚本执行权限已设置`)
                  } catch (chmodError) {
                    console.warn(`[批量上传] 证书 ${i}: 设置脚本执行权限失败:`, chmodError.message)
                  }
                  
                  // 先尝试使用sudo执行（因为需要修改Apache配置和重启服务）
                  // enable-ssl命令需要域名参数，trimmedCertName就是域名格式的证书名称
                  let enableSslCommand = `sudo bash "${scriptPath}" enable-ssl "${trimmedCertName}"`
                  let useSudo = true
                  
                  try {
                    console.log(`[批量上传] 证书 ${i}: 开始执行Apache配置命令（使用sudo）: ${enableSslCommand}`)
                    console.log(`[批量上传] 证书 ${i}: 工作目录: ${ROOT_DIR}`)
                    console.log(`[批量上传] 证书 ${i}: 脚本路径: ${scriptPath}`)
                    console.log(`[批量上传] 证书 ${i}: 证书文件路径: ${targetCertPath}`)
                    console.log(`[批量上传] 证书 ${i}: 私钥文件路径: ${targetKeyPath}`)
                    
                    const output = execSync(enableSslCommand, { 
                      timeout: 120000, // 120秒超时（Apache配置可能需要较长时间）
                      stdio: ['pipe', 'pipe', 'pipe'],
                      encoding: 'utf8',
                      env: { ...process.env, PATH: process.env.PATH },
                      cwd: ROOT_DIR // 设置工作目录
                    })
                    
                    // 检查输出中是否包含错误信息
                    const outputStr = output.toString()
                    if (outputStr.includes('[ERROR]') || outputStr.includes('失败') || outputStr.includes('错误')) {
                      console.error(`[批量上传] 证书 ${i}: Apache配置输出包含错误:`, outputStr.substring(0, 2000))
                      apacheConfigMessage = '，Apache配置可能失败，请检查日志'
                    } else if (outputStr.includes('[SUCCESS]') || outputStr.includes('成功') || outputStr.includes('完成')) {
                      apacheConfigMessage = '，Apache已自动配置并重启'
                      apacheConfigured = true
                      console.log(`[批量上传] 证书 ${i}: Apache配置成功（使用sudo）`)
                    } else {
                      // 如果没有明确的成功/失败标记，检查Apache服务状态
                      try {
                        const apacheStatus = execSync('systemctl is-active httpd 2>&1', { timeout: 5000, encoding: 'utf8' })
                        if (apacheStatus.trim() === 'active') {
                          apacheConfigMessage = '，Apache已自动配置并重启'
                          apacheConfigured = true
                          console.log(`[批量上传] 证书 ${i}: Apache配置成功（使用sudo，服务运行正常）`)
                        } else {
                          apacheConfigMessage = '，Apache配置可能失败，请检查服务状态'
                          console.warn(`[批量上传] 证书 ${i}: Apache服务状态异常:`, apacheStatus.trim())
                        }
                      } catch (statusCheckError) {
                        apacheConfigMessage = '，Apache配置可能失败，请检查服务状态'
                        console.warn(`[批量上传] 证书 ${i}: 无法检查Apache服务状态:`, statusCheckError.message)
                      }
                    }
                    
                    if (output) {
                      console.log(`[批量上传] 证书 ${i}: Apache配置输出:`, outputStr.substring(0, 2000)) // 记录前2000字符
                    }
                  } catch (sudoError) {
                    console.warn(`[批量上传] 证书 ${i}: sudo执行失败，尝试不使用sudo:`, sudoError.message)
                    console.error(`[批量上传] 证书 ${i}: sudo错误详情:`, sudoError.stderr?.toString()?.substring(0, 1000) || sudoError.message)
                    
                    // 如果sudo失败，尝试不使用sudo（可能当前用户已经有权限）
                    enableSslCommand = `bash "${scriptPath}" enable-ssl "${trimmedCertName}"`
                    useSudo = false
                    
                    try {
                      console.log(`[批量上传] 证书 ${i}: 开始执行Apache配置命令（不使用sudo）: ${enableSslCommand}`)
                      console.log(`[批量上传] 证书 ${i}: 工作目录: ${ROOT_DIR}`)
                      const output = execSync(enableSslCommand, { 
                        timeout: 120000,
                        stdio: ['pipe', 'pipe', 'pipe'],
                        encoding: 'utf8',
                        env: { ...process.env, PATH: process.env.PATH },
                        cwd: ROOT_DIR // 设置工作目录
                      })
                      
                      // 检查输出中是否包含错误信息
                      const outputStr = output.toString()
                      if (outputStr.includes('[ERROR]') || outputStr.includes('失败') || outputStr.includes('错误')) {
                        console.error(`[批量上传] 证书 ${i}: Apache配置输出包含错误:`, outputStr.substring(0, 2000))
                        apacheConfigMessage = '，Apache配置可能失败，请检查日志'
                      } else if (outputStr.includes('[SUCCESS]') || outputStr.includes('成功') || outputStr.includes('完成')) {
                        apacheConfigMessage = '，Apache已自动配置并重启'
                        apacheConfigured = true
                        console.log(`[批量上传] 证书 ${i}: Apache配置成功（不使用sudo）`)
                      } else {
                        // 如果没有明确的成功/失败标记，检查Apache服务状态
                        try {
                          const apacheStatus = execSync('systemctl is-active httpd 2>&1', { timeout: 5000, encoding: 'utf8' })
                          if (apacheStatus.trim() === 'active') {
                            apacheConfigMessage = '，Apache已自动配置并重启'
                            apacheConfigured = true
                            console.log(`[批量上传] 证书 ${i}: Apache配置成功（不使用sudo，服务运行正常）`)
                          } else {
                            apacheConfigMessage = '，Apache配置可能失败，请检查服务状态'
                            console.warn(`[批量上传] 证书 ${i}: Apache服务状态异常:`, apacheStatus.trim())
                          }
                        } catch (statusCheckError) {
                          apacheConfigMessage = '，Apache配置可能失败，请检查服务状态'
                          console.warn(`[批量上传] 证书 ${i}: 无法检查Apache服务状态:`, statusCheckError.message)
                        }
                      }
                      
                      if (output) {
                        console.log(`[批量上传] 证书 ${i}: Apache配置输出:`, outputStr.substring(0, 2000))
                      }
                    } catch (nonSudoError) {
                      // 获取详细的错误信息
                      const errorOutput = nonSudoError.stderr?.toString() || nonSudoError.stdout?.toString() || nonSudoError.message
                      const exitCode = nonSudoError.status || nonSudoError.code || 'unknown'
                      const fullError = `命令: ${enableSslCommand}\n错误: ${errorOutput}\n退出码: ${exitCode}`
                      console.error(`[批量上传] 证书 ${i}: Apache配置失败:`, fullError.substring(0, 3000))
                      
                      // 构建更详细的错误消息
                      let errorMsg = 'Apache配置失败'
                      if (errorOutput) {
                        // 提取关键错误信息（前200字符）
                        const shortError = errorOutput.substring(0, 200).replace(/\n/g, ' ')
                        errorMsg += `: ${shortError}`
                      }
                      if (exitCode !== 'unknown') {
                        errorMsg += ` (退出码: ${exitCode})`
                      }
                      apacheConfigMessage = `，${errorMsg}，请手动配置或检查日志`
                      
                      // 尝试检查Apache服务状态和配置语法
                      try {
                        const apacheStatus = execSync('systemctl status httpd --no-pager -l 2>&1 || service httpd status 2>&1', { 
                          timeout: 5000,
                          encoding: 'utf8'
                        })
                        console.log(`[批量上传] 证书 ${i}: Apache服务状态:`, apacheStatus.substring(0, 500))
                        
                        // 检查Apache配置语法
                        try {
                          const configTest = execSync('httpd -t 2>&1', { timeout: 5000, encoding: 'utf8' })
                          console.log(`[批量上传] 证书 ${i}: Apache配置语法检查:`, configTest.substring(0, 500))
                        } catch (configTestError) {
                          console.error(`[批量上传] 证书 ${i}: Apache配置语法检查失败:`, configTestError.message)
                        }
                      } catch (statusError) {
                        console.warn(`[批量上传] 证书 ${i}: 无法获取Apache服务状态:`, statusError.message)
                      }
                    }
                  }
                }
              }
            } catch (configError) {
              console.error(`[批量上传] 证书 ${i}: 配置Apache时发生错误:`, configError.message)
              console.error(`[批量上传] 证书 ${i}: 错误堆栈:`, configError.stack)
              apacheConfigMessage = '，Apache配置失败，请手动配置'
            }
          }
          
          results.push({
            index: i,
            success: true,
            certName: trimmedCertName,
            message: '证书上传成功' + (chainFile ? '（包含证书链）' : '') + apacheConfigMessage,
            apacheConfigured: apacheConfigured
          })
          
          console.log(`[批量上传] 证书 ${i}: 上传成功`)
        } catch (validationError) {
          console.error(`[批量上传] 证书 ${i}: 验证或处理失败:`, validationError)
          console.error(`[批量上传] 证书 ${i}: 错误堆栈:`, validationError.stack)
          
          // 清理临时文件
          try {
            if (certFile && certFile.path && fs.existsSync(certFile.path)) {
              fs.unlinkSync(certFile.path)
            }
            if (keyFile && keyFile.path && fs.existsSync(keyFile.path)) {
              fs.unlinkSync(keyFile.path)
            }
            if (chainFile && chainFile.path && fs.existsSync(chainFile.path)) {
              fs.unlinkSync(chainFile.path)
            }
          } catch (cleanupError) {
            console.error(`[批量上传] 证书 ${i}: 清理临时文件失败:`, cleanupError.message)
          }
          
          results.push({
            index: i,
            success: false,
            certName: certName ? certName.trim() : `证书${i + 1}`,
            error: '证书或私钥文件验证失败: ' + (validationError.message || '未知错误')
          })
        }
      } catch (loopError) {
        // 捕获循环中的任何其他错误
        console.error(`[批量上传] 证书 ${i}: 处理过程中发生未预期的错误:`, loopError)
        console.error(`[批量上传] 证书 ${i}: 错误堆栈:`, loopError.stack)
        const errorCertName = req.body[`certName_${i}`] || `证书${i + 1}`
        results.push({
          index: i,
          success: false,
          certName: typeof errorCertName === 'string' ? errorCertName.trim() : `证书${i + 1}`,
          error: '处理证书时发生错误: ' + (loopError.message || '未知错误')
        })
      }
    }
    
    const successCount = results.filter(r => r.success).length
    const failCount = results.length - successCount
    const apacheConfiguredCount = results.filter(r => r.success && r.apacheConfigured).length
    
    console.log('[批量上传] ========== 处理完成 ==========')
    console.log('[批量上传] 成功:', successCount, '失败:', failCount, 'Apache已配置:', apacheConfiguredCount)
    console.log('[批量上传] 结果详情:', JSON.stringify(results.map(r => ({
      index: r.index,
      success: r.success,
      certName: r.certName,
      apacheConfigured: r.apacheConfigured || false,
      message: r.message || r.error
    })), null, 2))
    
    // 构建响应消息
    let responseMessage = `成功上传 ${successCount} 个证书`
    if (apacheConfiguredCount > 0) {
      responseMessage += `，其中 ${apacheConfiguredCount} 个已自动配置Apache并重启服务。配置需要2-3分钟生效，请稍后访问HTTPS页面验证。`
    } else if (successCount > 0) {
      // 检查是否有域名格式的证书但没有配置Apache
      const domainFormatCerts = results.filter(r => r.success && /^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$/i.test(r.certName || ''))
      if (domainFormatCerts.length > 0) {
        responseMessage += '。注意：检测到域名格式证书，但Apache自动配置未成功，请手动配置SSL。'
      }
    }
    if (failCount > 0) {
      responseMessage += `，失败 ${failCount} 个`
    }
    
    // 如果有成功的上传，异步触发前端自动构建
    if (successCount > 0) {
      // 异步执行前端构建，不阻塞响应
      setImmediate(() => {
        try {
          console.log('[批量上传] 开始自动构建前端...')
          const startScriptPath = path.join(ROOT_DIR, 'start.sh')
          if (fs.existsSync(startScriptPath)) {
            // 使用spawn异步执行，不阻塞响应（spawn已在顶部导入）
            const buildProcess = spawn('bash', [startScriptPath, 'rebuild'], {
              cwd: ROOT_DIR,
              stdio: ['ignore', 'pipe', 'pipe']
            })
            
            let stdout = ''
            let stderr = ''
            
            buildProcess.stdout.on('data', (data) => {
              stdout += data.toString()
            })
            
            buildProcess.stderr.on('data', (data) => {
              stderr += data.toString()
            })
            
            // 设置超时（10分钟，前端构建可能需要较长时间）
            const buildTimeout = setTimeout(() => {
              if (!buildProcess.killed) {
                console.warn('[批量上传] 前端构建超时（10分钟），终止进程')
                console.warn('[批量上传] 构建输出预览:', stdout.substring(0, 1000))
                console.warn('[批量上传] 构建错误预览:', stderr.substring(0, 1000))
                buildProcess.kill('SIGTERM')
                // 如果SIGTERM无效，使用SIGKILL
                setTimeout(() => {
                  if (!buildProcess.killed) {
                    buildProcess.kill('SIGKILL')
                  }
                }, 5000)
              }
            }, 600000) // 10分钟超时
            
            buildProcess.on('close', (code, signal) => {
              // 清理超时定时器
              clearTimeout(buildTimeout)
              
              if (code === 0) {
                console.log('[批量上传] 前端自动构建成功')
                if (stdout) {
                  console.log('[批量上传] 构建输出:', stdout.substring(0, 1000))
                }
              } else {
                console.error('[批量上传] 前端自动构建失败，退出码:', code, '信号:', signal || 'none')
                if (stderr) {
                  console.error('[批量上传] 构建错误输出:', stderr.substring(0, 1000))
                }
                if (stdout) {
                  console.error('[批量上传] 构建标准输出:', stdout.substring(0, 1000))
                }
              }
            })
            
            buildProcess.on('error', (error) => {
              // 清理超时定时器
              clearTimeout(buildTimeout)
              console.error('[批量上传] 前端构建进程启动失败:', error.message)
              console.error('[批量上传] 错误堆栈:', error.stack)
            })
          } else {
            console.warn('[批量上传] start.sh不存在，跳过前端自动构建')
          }
        } catch (buildError) {
          console.error('[批量上传] 触发前端构建时发生错误:', buildError.message)
        }
      })
    }
    
    res.json({
      success: failCount === 0,
      message: responseMessage,
      results: results,
      apacheConfiguredCount: apacheConfiguredCount
    })
  } catch (error) {
    console.error('[批量上传] ========== 批量证书上传失败 ==========')
    console.error('[批量上传] 错误类型:', error.constructor.name)
    console.error('[批量上传] 错误消息:', error.message)
    console.error('[批量上传] 错误堆栈:', error.stack)
    console.error('[批量上传] 请求body:', JSON.stringify(req.body, null, 2))
    console.error('[批量上传] 请求body类型:', typeof req.body)
    console.error('[批量上传] 请求files:', req.files ? req.files.map(f => ({ fieldname: f.fieldname, originalname: f.originalname, path: f.path })) : '无文件')
    console.error('[批量上传] req.files类型:', typeof req.files)
    console.error('[批量上传] req.files是否为数组:', Array.isArray(req.files))
    
    // 清理所有临时文件
    let filesToCleanup = []
    if (req.files) {
      if (Array.isArray(req.files)) {
        filesToCleanup = req.files
      } else if (typeof req.files === 'object') {
        filesToCleanup = Object.values(req.files).flat().filter(f => f && typeof f === 'object')
      }
    }
    
    filesToCleanup.forEach(file => {
      if (file && file.path && fs.existsSync(file.path)) {
        try {
          fs.unlinkSync(file.path)
          console.log('[批量上传] 已清理临时文件:', file.path)
        } catch (e) {
          console.error('[批量上传] 清理临时文件失败:', e.message)
        }
      }
    })
    
    res.status(500).json({
      success: false,
      error: '批量证书上传失败',
      message: (error && error.message) ? error.message : '未知错误',
      details: process.env.NODE_ENV === 'development' ? error.stack : undefined
    })
  }
})

// 获取更新日志API端点
app.get('/api/changelog', (req, res) => {
  try {
    const readmePath = path.join(ROOT_DIR, 'README.md')
    
    if (!fs.existsSync(readmePath)) {
      return res.status(404).json({
        success: false,
        error: 'README.md not found'
      })
    }
    
    const readmeContent = fs.readFileSync(readmePath, 'utf8')
    
    // 解析版本历史部分（从"## 版本历史"开始到"### 版本历史说明"之前）
    // 匹配表格分隔符行之后的所有内容
    const versionHistoryMatch = readmeContent.match(/## 版本历史[\s\S]*?### 最新版本概览[\s\S]*?\|[-\s\|]+\|\s*\n\s*([\s\S]*?)(?=### 版本历史说明|## |$)/)
    if (!versionHistoryMatch) {
      return res.json({
        success: true,
        versions: [],
        latestVersion: null,
        total: 0
      })
    }
    
    const versionTableSection = versionHistoryMatch[1]
    
    // 提取版本表格行
    // 匹配两种格式：
    // 1. | **V4.1.3** 🎉 | 2026-01-14 | **标题**：描述内容 |
    // 2. | **V2.9.7** | 2025-11-13 | 描述内容（无标题）|
    // 注意：emoji字符需要特殊处理，使用 [\u{1F300}-\u{1F9FF}] 或更通用的方式
    const versionTableRegex = /\|\s*\*\*([^*\s]+)\*\*\s*(?:[\u{1F300}-\u{1F9FF}\s]*)?\|\s*(\d{4}-\d{2}-\d{2})\s*\|\s*(?:\*\*([^*]+)\*\*[：:]\s*)?([^|]+)/gu
    const versions = []
    let match
    
    // 使用更简单的方式：先移除emoji再匹配
    // 匹配所有以 | 开头且包含 **V 的行（版本表格行）
    const allLines = versionTableSection.split('\n')
    const lines = allLines.filter(line => {
      const trimmed = line.trim()
      // 匹配表格行：trim后以 | 开头，包含 **V，不是分隔行
      // 注意：允许行首有空格，trim后再检查
      // 如果trim后不是以 | 开头，但包含 **V 模式，也认为是版本行（处理行首空格的情况）
      // 修复：如果行首有空格导致 | 不在行首，但包含 **V 和 |，也认为是版本行
      const hasVersionPattern = trimmed.includes('**V')
      const hasPipe = trimmed.includes('|')
      const isSeparator = /^\|[\s\-:]+\|/.test(trimmed)
      // 检查是否是版本行：包含 **V，有 |，不是分隔行，且（以 | 开头 或 包含 | **V 模式 或 行首有空格但包含 **V 和 |）
      const isVersionLine = hasVersionPattern && hasPipe && !isSeparator && (
        trimmed.startsWith('|') || 
        trimmed.match(/\|\s*\*\*V/) ||
        (trimmed.match(/\*\*V[\d.]+/) && trimmed.match(/\|\s*\d{4}-\d{2}-\d{2}/))
      )
      return isVersionLine
    })
    
    
    for (const line of lines) {
      // 先trim，移除行首行尾空格（包括制表符等）
      let cleanLine = line.trim()
      
      // 如果trim后不是以 | 开头，但包含 | **V 模式，在前面添加 |
      // 这种情况是行首有空格，trim后 | 被移除了
      if (!cleanLine.startsWith('|') && cleanLine.includes('|') && cleanLine.includes('**V')) {
        cleanLine = '|' + cleanLine
      }
      
      // 如果仍然不是以 | 开头，跳过这一行
      if (!cleanLine.startsWith('|')) {
        continue
      }
      
      // 移除所有emoji字符（包括 🎉 等）
      // 使用更广泛的emoji范围，包括所有常见的emoji
      cleanLine = cleanLine.replace(/[\u{1F300}-\u{1F9FF}]/gu, '') // 补充符号和象形文字
      cleanLine = cleanLine.replace(/[\u{2600}-\u{26FF}]/gu, '') // 杂项符号
      cleanLine = cleanLine.replace(/[\u{2700}-\u{27BF}]/gu, '') // 装饰符号
      cleanLine = cleanLine.replace(/[\u{FE00}-\u{FE0F}]/gu, '') // 变体选择器
      cleanLine = cleanLine.replace(/[\u{200D}]/gu, '') // 零宽连接符
      cleanLine = cleanLine.trim()
      
      // 匹配版本号、日期、标题和描述
      const lineMatch = cleanLine.match(/\|\s*\*\*([^*\s]+)\*\*\s*\|\s*(\d{4}-\d{2}-\d{2})\s*\|\s*(?:\*\*([^*]+)\*\*[：:]\s*)?([^|]+)/)
      
      if (lineMatch) {
        const version = lineMatch[1].trim()
        const date = lineMatch[2].trim()
        const title = lineMatch[3] ? lineMatch[3].trim() : ''
        const description = lineMatch[4].trim()
        
        versions.push({
          version,
          date,
          title: title || description.split('、')[0] || description.substring(0, 30) + '...', // 如果没有标题，使用描述的第一部分或前30个字符
          description
        })
      }
    }
    
    // 确保版本按时间倒序排列（最新的在前）
    // 排序规则：1. 按日期倒序（最新的在前） 2. 如果日期相同，按版本号倒序（V4.1.3 > V4.1.2）
    versions.sort((a, b) => {
      const dateA = new Date(a.date)
      const dateB = new Date(b.date)
      
      // 首先按日期排序（倒序：最新的在前）
      if (dateB.getTime() !== dateA.getTime()) {
        return dateB.getTime() - dateA.getTime()
      }
      
      // 如果日期相同，按版本号倒序（V4.1.3 > V4.1.2 > V4.1.1）
      // 提取版本号数字部分进行比较
      const versionA = a.version.replace(/[^\d.]/g, '').split('.').map(Number)
      const versionB = b.version.replace(/[^\d.]/g, '').split('.').map(Number)
      
      // 比较主版本号、次版本号、修订号
      for (let i = 0; i < Math.max(versionA.length, versionB.length); i++) {
        const numA = versionA[i] || 0
        const numB = versionB[i] || 0
        if (numB !== numA) {
          return numB - numA // 倒序：大的在前
        }
      }
      
      // 如果版本号完全相同，按字符串倒序
      return b.version.localeCompare(a.version)
    })
    
    // 提取最新版本信息（从版本列表的第一个版本获取，因为列表是按时间倒序排列的）
    const latestVersion = versions.length > 0 ? {
      version: versions[0].version,
      date: versions[0].date,
      title: versions[0].title,
      description: versions[0].description
    } : null
    
    
    res.json({
      success: true,
      versions,
      latestVersion,
      total: versions.length
    })
  } catch (error) {
    console.error('Failed to read changelog:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to read changelog',
      message: error.message
    })
  }
})

app.get('/api/version', (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    
    console.log(`[${timestamp}] [API] 版本信息请求 - IP: ${clientIP}`)
    
    // 读取start.sh文件获取版本信息
    const startScriptPath = path.join(ROOT_DIR, 'start.sh')
    let version = '3.4.1' // 默认版本
    
    if (fs.existsSync(startScriptPath)) {
      try {
        const startScriptContent = fs.readFileSync(startScriptPath, 'utf8')
        const versionMatch = startScriptContent.match(/SCRIPT_VERSION="([^"]+)"/)
        if (versionMatch) {
          version = versionMatch[1]
        }
      } catch (error) {
        console.error('读取start.sh版本信息失败:', error)
      }
    }
    
    res.json({
      success: true,
      version: version,
      timestamp: timestamp,
      clientIP: clientIP
    })
  } catch (error) {
    console.error('版本信息API错误:', error)
    res.status(500).json({ 
      success: false, 
      error: 'Internal server error',
      message: error.message 
    })
  }
})

// 系统状态API端点（异步版本，避免阻塞）
app.get('/api/system-status', auth, async (req, res) => {
  // 设置请求超时（30秒）
  const requestTimeout = setTimeout(() => {
    if (!res.headersSent) {
      res.status(504).json({
        success: false,
        error: 'Request timeout',
        message: '系统状态查询超时，请稍后重试'
      })
    }
  }, 30000)
  
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    
    // 获取系统信息
    const systemInfo = {
      timestamp: timestamp,
      uptime: process.uptime(),
      platform: process.platform,
      nodeVersion: process.version,
      memory: process.memoryUsage(),
      cpu: process.cpuUsage()
    }
    
    // 获取更详细的系统信息
    try {
      // 系统版本信息
      const osRelease = execSync("cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '\"'", { encoding: 'utf8', timeout: 3000 })
      systemInfo.osVersion = osRelease.trim()
      
      // 内核版本
      const kernelVersion = execSync("uname -r", { encoding: 'utf8', timeout: 3000 })
      systemInfo.kernelVersion = kernelVersion.trim()
      
      // 主机名
      const hostname = execSync("hostname", { encoding: 'utf8', timeout: 3000 })
      systemInfo.hostname = hostname.trim()
      
      // 系统架构
      const arch = execSync("uname -m", { encoding: 'utf8', timeout: 3000 })
      systemInfo.architecture = arch.trim()
      
      // 时区信息
      const timezone = execSync("timedatectl show --property=Timezone --value", { encoding: 'utf8', timeout: 3000 })
      systemInfo.timezone = timezone.trim()
      
      // 系统启动时间
      const bootTime = execSync("uptime -s", { encoding: 'utf8', timeout: 3000 })
      systemInfo.bootTime = bootTime.trim()
      
      // 当前用户
      const currentUser = execSync("whoami", { encoding: 'utf8', timeout: 3000 })
      systemInfo.currentUser = currentUser.trim()
      
      // 系统负载详情
      const loadAvg = execSync("uptime | awk -F'load average:' '{print $2}'", { encoding: 'utf8', timeout: 3000 })
      systemInfo.loadAverage = loadAvg.trim()
      
      // 内存使用情况
      const memoryInfo = execSync("free -h | grep '^Mem:' | awk '{print $3\"/\"$2\" (\"$5\")\"}'", { encoding: 'utf8', timeout: 3000 })
      systemInfo.memoryUsage = memoryInfo.trim()
      
      // 磁盘使用情况
      const diskUsage = execSync("df -h / | tail -1 | awk '{print $5}'", { encoding: 'utf8', timeout: 3000 })
      systemInfo.diskUsage = diskUsage.trim()
      
      // 获取服务器IP地址
      let serverIP = null
      try {
        // 方法1：获取主网卡IP（排除回环地址）
        const hostIp = execSync("hostname -I | awk '{print $1}'", { encoding: 'utf8', timeout: 3000 }).trim()
        if (hostIp && !hostIp.includes('127.0.0.1')) {
          serverIP = hostIp
        }
      } catch (_) {}
      
      // 方法2：通过路由获取外网IP
      if (!serverIP) {
        try {
          const routeIp = execSync("ip route get 1.1.1.1 | awk '{print $7; exit}'", { encoding: 'utf8', timeout: 3000 }).trim()
          if (routeIp && !routeIp.includes('127.0.0.1')) {
            serverIP = routeIp
          }
        } catch (_) {}
      }
      
      // 方法3：从网络接口获取
      if (!serverIP) {
        try {
          const ifaceIp = execSync("ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1", { encoding: 'utf8', timeout: 3000 }).trim()
          if (ifaceIp) {
            serverIP = ifaceIp
          }
        } catch (_) {}
      }
      
      // 将服务器IP添加到systemInfo中
      if (serverIP) {
        systemInfo.serverIP = serverIP
      }
      
    } catch (error) {
      console.error('Failed to get detailed system info:', error)
      systemInfo.error = 'Failed to get detailed system info'
    }
    
    // 获取服务状态（并行执行，避免阻塞）
    const services = {}
    const serviceCommands = {
      'postfix': 'systemctl is-active postfix',
      'dovecot': 'systemctl is-active dovecot',
      'httpd': 'systemctl is-active httpd',
      'mariadb': 'systemctl is-active mariadb',
      'named': 'systemctl is-active named',
      'firewalld': 'systemctl is-active firewalld',
      'dispatcher': 'systemctl is-active mail-ops-dispatcher'
    }
    
    console.log('Checking services:', Object.keys(serviceCommands))
    
    // 并行检查所有服务状态
    const servicePromises = Object.entries(serviceCommands).map(async ([service, command]) => {
      try {
        const status = await execCommandAsync(command, 3000)
        
        let serviceStatus = 'error'
        if (status === 'active') {
          serviceStatus = 'running'
        } else if (status === 'inactive') {
          serviceStatus = 'stopped'
        } else if (status === 'failed') {
          serviceStatus = 'error'
        }
        
        // 特殊处理防火墙状态
        if (service === 'firewalld') {
          try {
            const isEnabled = await execCommandAsync('systemctl is-enabled firewalld', 2000)
            if (isEnabled === 'disabled') {
              serviceStatus = 'stopped'
            }
          } catch (enableErr) {
            // 忽略错误
          }
        }
        
        return {
          service,
          status: serviceStatus,
          lastCheck: timestamp,
          rawStatus: status
        }
      } catch (error) {
        // 尝试备用方法
        try {
          const altCommand = `systemctl show ${service.split('-')[0]} --property=ActiveState --value`
          const altStatus = await execCommandAsync(altCommand, 2000)
          let serviceStatus = 'error'
          if (altStatus === 'active') {
            serviceStatus = 'running'
          } else if (altStatus === 'inactive') {
            serviceStatus = 'stopped'
          }
          return {
            service,
            status: serviceStatus,
            lastCheck: timestamp,
            rawStatus: altStatus
          }
        } catch (altError) {
          return {
            service,
            status: 'unknown',
            lastCheck: timestamp,
            error: error.message,
            rawStatus: 'error'
          }
        }
      }
    })
    
    // 等待所有服务检查完成
    const serviceResults = await Promise.allSettled(servicePromises)
    serviceResults.forEach((result, index) => {
      const serviceName = Object.keys(serviceCommands)[index]
      if (result.status === 'fulfilled') {
        services[serviceName] = result.value
      } else {
        services[serviceName] = {
          status: 'unknown',
          lastCheck: timestamp,
          error: result.reason?.message || 'Unknown error',
          rawStatus: 'error'
        }
      }
    })
    
    // 获取DNS解析状态
    let dnsStatus = {}
    try {
      // 获取配置的域名
      let configuredDomain = null
      let configuredHostname = null
      
      // 首先尝试从Postfix配置获取
      try {
        const domainCheck = execSync("grep -E '^myhostname|^mydomain' /etc/postfix/main.cf 2>/dev/null | head -2", { encoding: 'utf8', timeout: 3000 })
        const domainLines = domainCheck.trim().split('\n')
        
        for (const line of domainLines) {
          if (line.includes('myhostname')) {
            configuredHostname = line.split('=')[1]?.trim()
          } else if (line.includes('mydomain')) {
            configuredDomain = line.split('=')[1]?.trim()
          }
        }
      } catch (error) {
        console.log('Postfix config check failed, trying alternative methods')
      }
      
      // 如果Postfix配置中没有，尝试从hostname获取
      if (!configuredHostname) {
        try {
          configuredHostname = execSync("hostname -f", { encoding: 'utf8', timeout: 3000 }).trim()
        } catch (error) {
          console.log('hostname -f failed, trying hostname')
          try {
            configuredHostname = execSync("hostname", { encoding: 'utf8', timeout: 3000 }).trim()
          } catch (error2) {
            console.log('hostname command failed')
          }
        }
      }
      
      // 从hostname提取域名
      if (!configuredDomain && configuredHostname) {
        const parts = configuredHostname.split('.')
        if (parts.length > 1) {
          configuredDomain = parts.slice(1).join('.')
        }
      }
      
      // 如果还是没有域名，尝试从数据库获取
      if (!configuredDomain) {
        try {
          const mailDbPass = getMailDbPassword()
          const dbDomain = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -e "SELECT name FROM virtual_domains LIMIT 1;" 2>/dev/null | tail -1`, { encoding: 'utf8', timeout: 3000 })
          if (dbDomain.trim() && dbDomain.trim() !== 'name') {
            configuredDomain = dbDomain.trim()
          }
        } catch (error) {
          console.log('Database domain check failed')
        }
      }
      
      // 根据 DNS 类型选择解析服务器，公网 DNS 时用配置的域名/主机名；无 dns 配置时根据 named 是否运行推断
      let dnsResolver = '127.0.0.1'
      let inferredPublicDns = false
      try {
        const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
        if (fs.existsSync(settingsFile)) {
          const systemSettings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
          const dnsType = systemSettings.dns?.type
          const hasPublicDomain = systemSettings.dns?.public?.domain && systemSettings.dns.public.domain.trim() !== ''
          const hasBindDomain = systemSettings.dns?.bind?.domain && systemSettings.dns.bind.domain.trim() !== ''
          if (dnsType === 'public' || (hasPublicDomain && dnsType !== 'bind')) {
            dnsResolver = '8.8.8.8' // 公网解析时使用公网 DNS 查询
            if (hasPublicDomain) {
              configuredDomain = systemSettings.dns.public.domain.trim()
              configuredHostname = (systemSettings.dns.public.hostname && systemSettings.dns.public.hostname.trim()) || `mail.${configuredDomain}`
            }
          } else if (configuredDomain && !hasBindDomain && !hasPublicDomain) {
            // 配置文件无 dns 或未配置域名：若 named 未运行则按公网 DNS 处理（兼容重装/仅配 Postfix 场景）
            const namedRunning = services.named?.status === 'running'
            if (!namedRunning) {
              dnsResolver = '8.8.8.8'
              inferredPublicDns = true
            }
          }
        } else if (configuredDomain && services.named?.status !== 'running') {
          dnsResolver = '8.8.8.8'
          inferredPublicDns = true
        }
      } catch (e) {
        // 读取失败时保持默认 127.0.0.1
      }
      
      dnsStatus.configuredDomain = configuredDomain
      dnsStatus.configuredHostname = configuredHostname
      
      // 检查DNS解析（并行执行，避免阻塞）
      if (configuredDomain) {
        // 并行执行所有DNS查询（限制超时时间）
        const dnsQueries = await Promise.allSettled([
          execCommandAsync(`dig @${dnsResolver} +short MX ${configuredDomain} | head -1`, 3000).catch(() => ''),
          execCommandAsync(`dig @${dnsResolver} +short A ${configuredDomain}`, 3000).catch(() => ''),
          execCommandAsync(`dig @${dnsResolver} +short TXT ${configuredDomain} | grep -i spf`, 3000).catch(() => ''),
          execCommandAsync(`dig @${dnsResolver} +short TXT default._domainkey.${configuredDomain}`, 3000).catch(() => ''),
          execCommandAsync(`dig @${dnsResolver} +short TXT _dmarc.${configuredDomain}`, 3000).catch(() => '')
        ])
        
        // MX记录
        const mxRecord = dnsQueries[0].status === 'fulfilled' ? dnsQueries[0].value : ''
        dnsStatus.mxRecord = mxRecord || 'Not found'
        dnsStatus.mxStatus = mxRecord ? 'configured' : 'missing'
        
        // A记录
        const aRecord = dnsQueries[1].status === 'fulfilled' ? dnsQueries[1].value : ''
        dnsStatus.aRecord = aRecord || 'Not found'
        dnsStatus.aStatus = aRecord ? 'configured' : 'missing'
        
        // PTR记录（需要先获取A记录）
        if (aRecord) {
          try {
            const ptrRecord = await execCommandAsync(`dig @${dnsResolver} +short -x ${aRecord}`, 3000)
            dnsStatus.ptrRecord = ptrRecord || 'Not found'
            dnsStatus.ptrStatus = ptrRecord ? 'configured' : 'missing'
          } catch (ptrError) {
            dnsStatus.ptrRecord = 'Error checking'
            dnsStatus.ptrStatus = 'error'
          }
        } else {
          dnsStatus.ptrRecord = 'Not found'
          dnsStatus.ptrStatus = 'missing'
        }
        
        // SPF记录
        const spfRecord = dnsQueries[2].status === 'fulfilled' ? dnsQueries[2].value : ''
        dnsStatus.spfRecord = spfRecord || 'Not found'
        dnsStatus.spfStatus = spfRecord ? 'configured' : 'missing'
        
        // DKIM记录
        const dkimRecord = dnsQueries[3].status === 'fulfilled' ? dnsQueries[3].value : ''
        dnsStatus.dkimRecord = dkimRecord || 'Not found'
        dnsStatus.dkimStatus = dkimRecord ? 'configured' : 'missing'
        
        // DMARC记录
        const dmarcRecord = dnsQueries[4].status === 'fulfilled' ? dnsQueries[4].value : ''
        dnsStatus.dmarcRecord = dmarcRecord || 'Not found'
        dnsStatus.dmarcStatus = dmarcRecord ? 'configured' : 'missing'
        
        // 计算DNS健康度
        const dnsChecks = [dnsStatus.mxStatus, dnsStatus.aStatus, dnsStatus.ptrStatus, dnsStatus.spfStatus, dnsStatus.dkimStatus, dnsStatus.dmarcStatus]
        const configuredCount = dnsChecks.filter(status => status === 'configured').length
        const errorCount = dnsChecks.filter(status => status === 'error').length
        const missingCount = dnsChecks.filter(status => status === 'missing').length
        
        dnsStatus.healthScore = Math.round((configuredCount / dnsChecks.length) * 100)
        dnsStatus.summary = {
          total: dnsChecks.length,
          configured: configuredCount,
          missing: missingCount,
          errors: errorCount
        }
        
        // 生成DNS状态报告
        if (dnsStatus.healthScore >= 80) {
          dnsStatus.overallStatus = 'excellent'
        } else if (dnsStatus.healthScore >= 60) {
          dnsStatus.overallStatus = 'good'
        } else if (dnsStatus.healthScore >= 40) {
          dnsStatus.overallStatus = 'fair'
        } else {
          dnsStatus.overallStatus = 'poor'
        }
        
      } else {
        dnsStatus.overallStatus = 'not_configured'
        dnsStatus.healthScore = 0
        dnsStatus.summary = { total: 0, configured: 0, missing: 0, errors: 0 }
      }
      
      // 检查系统设置文件，判断DNS是否已配置
      try {
        const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
        if (fs.existsSync(settingsFile)) {
          const systemSettings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
          const isConfigured = systemSettings.dns?.configured === true
          const dnsType = systemSettings.dns?.type
          
          // 检查是否有实际的DNS配置（即使没有configured标记）
          const hasBindDomain = systemSettings.dns?.bind?.domain && systemSettings.dns.bind.domain.trim() !== ''
          const hasPublicDomain = systemSettings.dns?.public?.domain && systemSettings.dns.public.domain.trim() !== ''
          // 对于公网DNS，只要域名存在就认为已配置（serverIp可能为空或0.0.0.0，这不影响公网DNS的使用）
          const isPublicDnsConfigured = hasPublicDomain
          
          // 如果配置文件中标记为已配置，且类型正确，则设置dns_configured
          if (isConfigured && (dnsType === 'bind' || dnsType === 'public')) {
            if ((dnsType === 'bind' && hasBindDomain) || (dnsType === 'public' && isPublicDnsConfigured)) {
              dnsStatus.dns_configured = true
              dnsStatus.dns_type = dnsType
            } else {
              dnsStatus.dns_configured = false
            }
          } else if (hasBindDomain || isPublicDnsConfigured) {
            // 如果没有configured标记，但检测到有实际的DNS配置，也认为已配置（兼容旧配置）
            if (hasBindDomain) {
              dnsStatus.dns_configured = true
              dnsStatus.dns_type = 'bind'
            } else if (isPublicDnsConfigured) {
              dnsStatus.dns_configured = true
              dnsStatus.dns_type = 'public'
            } else {
              dnsStatus.dns_configured = false
            }
            console.log('检测到DNS配置但缺少configured标记，自动识别为已配置:', dnsStatus.dns_type)
          } else if (configuredDomain && inferredPublicDns) {
            // 无 dns 配置但根据 named 未运行推断为公网 DNS（如重装后仅 Postfix 域名、未写 system-settings）
            dnsStatus.dns_configured = true
            dnsStatus.dns_type = 'public'
          } else {
            dnsStatus.dns_configured = false
          }
        } else {
          // 如果配置文件不存在，但有域名，按推断或默认 bind（兼容旧配置）
          dnsStatus.dns_configured = !!configuredDomain
          if (configuredDomain) {
            dnsStatus.dns_type = inferredPublicDns ? 'public' : 'bind'
          }
        }
      } catch (settingsError) {
        console.warn('读取DNS配置状态失败:', settingsError.message)
        // 如果读取失败，但有域名，也认为已配置（兼容旧配置）
        dnsStatus.dns_configured = !!configuredDomain
        if (configuredDomain) {
          dnsStatus.dns_type = inferredPublicDns ? 'public' : 'bind'
        }
      }
      
    } catch (dnsError) {
      console.error('Failed to check DNS status:', dnsError)
      dnsStatus.error = 'Failed to check DNS status'
      dnsStatus.overallStatus = 'error'
      dnsStatus.healthScore = 0
      dnsStatus.dns_configured = false
    }

    // 获取系统资源使用情况
    let systemResources = {}
    try {
      // CPU使用率
      const cpuInfo = execSync("top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | awk -F'%' '{print $1}'", { encoding: 'utf8', timeout: 5000 })
      systemResources.cpu = parseFloat(cpuInfo.trim()) || 0
      
      // 内存使用率
      const memInfo = execSync("free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'", { encoding: 'utf8', timeout: 5000 })
      systemResources.memory = parseFloat(memInfo.trim()) || 0
      
      // 磁盘使用率
      const diskInfo = execSync("df -h / | awk 'NR==2{printf \"%.1f\", $5}' | sed 's/%//'", { encoding: 'utf8', timeout: 5000 })
      systemResources.disk = parseFloat(diskInfo.trim()) || 0
      
      // 负载平均值
      const loadAvg = execSync("uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'", { encoding: 'utf8', timeout: 5000 })
      systemResources.loadAverage = parseFloat(loadAvg.trim()) || 0
      
      // 获取更详细的资源信息
      try {
        // 内存详细信息
        const memDetails = execSync("free -h", { encoding: 'utf8', timeout: 3000 })
        const memLines = memDetails.trim().split('\n')
        if (memLines.length >= 2) {
          const memData = memLines[1].split(/\s+/)
          systemResources.memoryDetails = {
            total: memData[1],
            used: memData[2],
            free: memData[3],
            shared: memData[4],
            cache: memData[5],
            available: memData[6]
          }
        }
        
        // 磁盘详细信息
        const diskDetails = execSync("df -h", { encoding: 'utf8', timeout: 3000 })
        systemResources.diskDetails = diskDetails.trim()
        
        // CPU详细信息
        const cpuDetails = execSync("lscpu | grep -E 'Model name|CPU\\(s\\)|Thread\\(s\\) per core|Core\\(s\\) per socket|Socket\\(s\\)'", { encoding: 'utf8', timeout: 3000 })
        systemResources.cpuDetails = cpuDetails.trim()
        
        // 网络接口信息
        const networkInfo = execSync("ip addr show | grep -E 'inet |UP|DOWN'", { encoding: 'utf8', timeout: 3000 })
        systemResources.networkInterfaces = networkInfo.trim()
        
        // 系统温度（如果可用）
        try {
          const tempInfo = execSync("sensors | grep -E 'Core|temp' | head -5", { encoding: 'utf8', timeout: 2000 })
          systemResources.temperature = tempInfo.trim()
        } catch (tempError) {
          systemResources.temperature = 'Temperature sensors not available'
        }
        
        // 系统进程信息
        const topProcesses = execSync("ps aux --sort=-%cpu | head -6", { encoding: 'utf8', timeout: 3000 })
        systemResources.topProcesses = topProcesses.trim()
        
        // 系统交换空间
        const swapInfo = execSync("swapon --show", { encoding: 'utf8', timeout: 3000 })
        systemResources.swapInfo = swapInfo.trim() || 'No swap configured'
        
        // 系统文件系统信息
        const mountInfo = execSync("mount | grep -E 'ext4|xfs|btrfs' | head -5", { encoding: 'utf8', timeout: 3000 })
        systemResources.mountInfo = mountInfo.trim()
        
      } catch (detailError) {
        console.error('Failed to get detailed resource info:', detailError)
        systemResources.detailError = 'Failed to get detailed resource info'
      }
      
    } catch (error) {
      console.error('Failed to get system resources:', error)
      systemResources = {
        cpu: 0,
        memory: 0,
        disk: 0,
        loadAverage: 0,
        error: 'Failed to get system resources'
      }
    }
    
    // 获取网络连接数
    let networkConnections = 0
    try {
      const netstatResult = execSync("netstat -an | wc -l", { encoding: 'utf8', timeout: 5000 })
      networkConnections = parseInt(netstatResult.trim()) || 0
    } catch (error) {
      console.error('Failed to get network connections:', error)
    }
    
    // 获取进程数
    let processCount = 0
    try {
      const psResult = execSync("ps aux | wc -l", { encoding: 'utf8', timeout: 5000 })
      processCount = parseInt(psResult.trim()) || 0
    } catch (error) {
      console.error('Failed to get process count:', error)
    }
    
    // 计算邮件服务组合状态
    const mailServiceStatus = (services.postfix?.status === 'running' && services.dovecot?.status === 'running') ? 'running' : 'stopped'
    
    const response = {
      success: true,
      data: {
        systemInfo,
        services: {
          ...services,
          mail: {
            status: mailServiceStatus,
            lastCheck: timestamp,
            components: {
              postfix: services.postfix?.status || 'unknown',
              dovecot: services.dovecot?.status || 'unknown'
            }
          }
        },
        resources: systemResources,
        dns: dnsStatus,
        network: {
          connections: networkConnections
        },
        processes: {
          count: processCount
        },
        lastUpdate: timestamp
      }
    }
    
    // 记录系统状态查询
    const logLine = `[${timestamp}] [SYSTEM_STATUS] User: ${req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    clearTimeout(requestTimeout)
    res.json(response)
    
  } catch (error) {
    clearTimeout(requestTimeout)
    console.error('Failed to get system status:', error)
    if (!res.headersSent) {
      res.status(500).json({
        success: false,
        error: 'Failed to get system status',
        message: error.message
      })
    }
  }
})

// DNS配置API端点
// 配置DNS
app.post('/api/dns/configure', auth, (req, res) => {
  try {
    const { 
      domain, 
      serverIp, 
      adminEmail, 
      enableRecursion, 
      enableForwarding, 
      upstreamDns
    } = req.body
    
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录DNS配置操作
    const logLine = `[${timestamp}] [DNS_CONFIG] User: ${user}, Domain: ${domain}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 执行DNS配置
    const { opId, child } = runScript('dns_setup.sh', [
      'configure-bind',
      domain,
      serverIp,
      adminEmail,
      enableRecursion || 'true',
      enableForwarding || 'true',
      upstreamDns || '8.8.8.8, 1.1.1.1'
    ])
    
    // DNS配置脚本执行完成后，自动将域名添加到数据库
    child.on('close', (code) => {
      if (code === 0) {
        // DNS配置成功，更新系统设置文件标记DNS已配置
        try {
          const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
          let settings = {}
          if (fs.existsSync(settingsFile)) {
            settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
          }

          // 确保dns对象存在
          if (!settings.dns) settings.dns = {}

          // 设置DNS配置状态
          settings.dns.configured = true
          settings.dns.type = 'bind'

          // 更新bind配置
          if (!settings.dns.bind) settings.dns.bind = {}
          settings.dns.bind.domain = domain
          settings.dns.bind.serverIp = serverIp
          settings.dns.bind.adminEmail = adminEmail
          settings.dns.bind.enableRecursion = enableRecursion === 'true'
          settings.dns.bind.enableForwarding = enableForwarding === 'true'
          settings.dns.bind.upstreamDns = upstreamDns

          // 根据配置的域名自动生成管理员邮箱
          const adminEmailForDomain = `xm@${domain}`

          // 同步DNS管理员邮箱到系统设置的general.adminEmail
          if (!settings.general) settings.general = {}
          settings.general.adminEmail = adminEmailForDomain

          // 同步到通知设置的警报邮箱
          if (!settings.notifications) settings.notifications = {}
          settings.notifications.alertEmail = adminEmailForDomain

          // 保存设置
          fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2))
          // 设置文件权限为 755 (rwxr-xr-x)
          try {
            fs.chmodSync(settingsFile, 0o755)
            console.log('DNS配置后系统设置文件权限已设置为755')
          } catch (chmodError) {
            try {
              execSync(`sudo chmod 755 "${settingsFile}"`, { timeout: 3000 })
              console.log('DNS配置后系统设置文件权限已设置为755（使用sudo）')
            } catch (sudoError) {
              console.warn('设置DNS配置后系统设置文件权限失败:', sudoError.message)
            }
          }
          console.log('DNS配置状态已更新到系统设置文件，管理员邮箱已自动设置为:', adminEmailForDomain)

          // 同步更新数据库中的用户邮箱
          try {
            // 使用mail_db.sh的update-admin-email命令更新管理员邮箱
            execSync(`${ROOT_DIR}/backend/scripts/mail_db.sh update-admin-email "${adminEmailForDomain}"`, { timeout: 5000 })
            console.log(`数据库中的xm用户邮箱已更新为新域名格式: xm -> ${adminEmailForDomain}`)
          } catch (dbUpdateError) {
            console.warn('更新数据库xm用户邮箱失败:', dbUpdateError.message)
          }
        } catch (settingsError) {
          console.warn('更新DNS配置状态失败:', settingsError.message)
        }

        // DNS配置成功，先删除之前的DNS域名（如果有），然后添加新域名
        console.log('DNS配置成功，处理域名添加到数据库:', domain)
        const mailDbScript = path.join(__dirname, '..', 'scripts', 'mail_db.sh')
        
        // 先检查是否有之前的DNS域名需要删除
        const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
        let previousDnsDomain = null
        if (fs.existsSync(settingsFile)) {
          try {
            const settingsData = fs.readFileSync(settingsFile, 'utf8')
            const settings = JSON.parse(settingsData)
            previousDnsDomain = settings.dns?.bind?.domain
            console.log('之前的DNS域名:', previousDnsDomain)
          } catch (err) {
            console.warn('读取系统设置失败:', err.message)
          }
        }
        
        // 如果之前的DNS域名存在且与新域名不同，删除旧域名
        if (previousDnsDomain && previousDnsDomain !== domain && previousDnsDomain !== 'localhost') {
          console.log('删除之前的DNS域名:', previousDnsDomain)
          // 先查询域名ID
          exec(`bash "${mailDbScript}" list_domains`, (listError, listStdout) => {
            if (!listError && listStdout) {
              try {
                const domains = JSON.parse(listStdout.toString())
                const oldDomain = domains.find(d => d.name === previousDnsDomain)
                if (oldDomain) {
                  console.log('找到旧DNS域名ID:', oldDomain.id)
                  // 删除旧域名
                  exec(`bash "${mailDbScript}" delete_domain "${oldDomain.id}"`, (deleteError) => {
                    if (deleteError) {
                      console.warn('删除旧DNS域名失败:', deleteError.message)
                    } else {
                      console.log('旧DNS域名已删除:', previousDnsDomain)
                    }
                    // 继续添加新域名
                    addNewDnsDomain()
                  })
                } else {
                  // 没找到旧域名，直接添加新域名
                  addNewDnsDomain()
                }
              } catch (parseError) {
                console.warn('解析域名列表失败:', parseError.message)
                addNewDnsDomain()
              }
            } else {
              // 查询失败，直接添加新域名
              addNewDnsDomain()
            }
          })
        } else {
          // 没有旧域名或域名相同，直接添加新域名
          addNewDnsDomain()
        }
        
        function addNewDnsDomain() {
          // 1. 先确保 localhost 域名存在（使用 INSERT IGNORE，不会重复添加）
          console.log('DNS配置成功后，确保 localhost 域名存在于数据库...')
          exec(`bash "${mailDbScript}" add_domain "localhost"`, (localhostError, localhostStdout, localhostStderr) => {
            if (localhostError) {
              const localhostOutput = localhostStdout ? localhostStdout.toString() : ''
              if (localhostOutput.includes('已存在')) {
                console.log('localhost 域名已存在于数据库中')
              } else {
                console.warn('自动添加 localhost 域名失败（不影响DNS配置）:', localhostError.message)
              }
            } else {
              const localhostOutput = localhostStdout ? localhostStdout.toString() : ''
              if (localhostOutput.includes('域名添加成功')) {
                console.log('localhost 域名已自动添加到数据库')
              } else if (localhostOutput.includes('已存在')) {
                console.log('localhost 域名已存在于数据库中')
              }
            }
            
            // 2. 添加用户输入的域名（如果不存在）
            console.log(`DNS配置成功后，添加用户输入的域名: ${domain}`)
            exec(`bash "${mailDbScript}" add_domain "${domain}"`, (error, stdout, stderr) => {
              if (error) {
                console.warn('DNS配置成功后自动添加域名失败:', error.message)
              } else {
                const stdoutStr = stdout ? stdout.toString() : ''
                if (stdoutStr.includes('域名添加成功')) {
                  console.log('DNS域名已自动添加到数据库:', domain)
                } else if (stdoutStr.includes('已存在')) {
                  console.log('DNS域名已存在于数据库中:', domain)
                } else {
                  console.warn('域名添加结果未知:', stdoutStr)
                }
                
                // DNS配置完成后，自动配置邮件系统（包括Postfix和Dovecot）
                const mailSetupScript = path.join(__dirname, '..', 'scripts', 'mail_setup.sh')
                console.log('DNS配置完成，开始配置邮件系统:', domain)
                exec(`bash "${mailSetupScript}" configure "${domain}"`, (mailError, mailStdout, mailStderr) => {
                  if (mailError) {
                    console.warn('DNS配置完成后自动配置邮件系统失败:', mailError.message)
                  } else {
                    console.log('邮件系统配置成功:', mailStdout ? mailStdout.toString() : '')
                  }
                })
              }
            })
          })
        }
      }
    })
    
    res.json({
      success: true,
      opId: opId,
      message: 'DNS配置已开始执行'
    })
    
  } catch (error) {
    console.error('DNS configuration error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to configure DNS',
      message: error.message
    })
  }
})

// 公网DNS配置API端点
app.post('/api/dns/public-configure', auth, (req, res) => {
  try {
    const { domain, serverIp } = req.body
    
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录公网DNS配置操作
    const logLine = `[${timestamp}] [PUBLIC_DNS_CONFIG] User: ${user}, Domain: ${domain}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 执行公网DNS配置
    const { opId, child } = runScript('dns_setup.sh', [
      'configure-public',
      domain,
      serverIp
    ])

    // 公网DNS配置脚本执行完成后，更新系统设置状态
    child.on('close', (code) => {
      if (code === 0) {
        // 公网DNS配置成功，更新系统设置文件标记DNS已配置
        try {
          const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
          let settings = {}
          if (fs.existsSync(settingsFile)) {
            settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
          }

          // 确保dns对象存在
          if (!settings.dns) settings.dns = {}

          // 设置DNS配置状态
          settings.dns.configured = true
          settings.dns.type = 'public'

          // 更新public配置
          if (!settings.dns.public) settings.dns.public = {}
          settings.dns.public.domain = domain
          settings.dns.public.serverIp = serverIp

          // 根据配置的域名自动生成管理员邮箱
          const adminEmailForDomain = `xm@${domain}`

          // 更新系统设置中的管理员邮箱
          if (!settings.general) settings.general = {}
          settings.general.adminEmail = adminEmailForDomain

          // 同步到通知设置的警报邮箱
          if (!settings.notifications) settings.notifications = {}
          settings.notifications.alertEmail = adminEmailForDomain

          // 保存设置
          fs.writeFileSync(settingsFile, JSON.stringify(settings, null, 2))
          // 设置文件权限为 755 (rwxr-xr-x)
          try {
            fs.chmodSync(settingsFile, 0o755)
            console.log('公网DNS配置后系统设置文件权限已设置为755')
          } catch (chmodError) {
            try {
              execSync(`sudo chmod 755 "${settingsFile}"`, { timeout: 3000 })
              console.log('公网DNS配置后系统设置文件权限已设置为755（使用sudo）')
            } catch (sudoError) {
              console.warn('设置公网DNS配置后系统设置文件权限失败:', sudoError.message)
            }
          }
          console.log('公网DNS配置状态已更新到系统设置文件，管理员邮箱已自动设置为:', adminEmailForDomain)

          // 同步更新数据库中的用户邮箱
          try {
            // 使用mail_db.sh的update-admin-email命令更新管理员邮箱
            execSync(`${ROOT_DIR}/backend/scripts/mail_db.sh update-admin-email "${adminEmailForDomain}"`, { timeout: 5000 })
            console.log(`数据库中的xm用户邮箱已更新为新域名格式: xm -> ${adminEmailForDomain}`)
          } catch (dbUpdateError) {
            console.warn('更新数据库xm用户邮箱失败:', dbUpdateError.message)
          }
        } catch (settingsError) {
          console.warn('更新公网DNS配置状态失败:', settingsError.message)
        }
      }
    })

    res.json({
      success: true,
      opId: opId,
      message: '公网DNS配置已开始执行'
    })
    
  } catch (error) {
    console.error('Public DNS configuration error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to configure public DNS',
      message: error.message
    })
  }
})

// 获取用户邮箱地址
app.get('/api/user-email', auth, (req, res) => {
  try {
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 查询用户的真实邮箱地址
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${user}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
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
        // 如果查询失败，返回错误，不要返回localhost域名
        console.log(`用户 ${user} 在maildb中不存在`)
        res.status(404).json({
          success: false,
          error: '用户邮箱未找到',
          message: '用户未在邮件系统中注册'
        })
        return
      }
    } catch (error) {
      console.log('查询用户邮箱失败:', error.message)
      // 如果查询失败，返回错误
      res.status(500).json({
        success: false,
        error: '查询用户邮箱失败',
        message: error.message
      })
      return
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

// 获取管理员邮箱API端点
app.get('/api/admin-email', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'

    // 记录管理员邮箱查询
    const logLine = `[${timestamp}] [ADMIN_EMAIL_GET] User: ${user}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)

    // 查询管理员（xm用户）的邮箱地址
    try {
      const mailDbPass = getMailDbPassword()
      const adminEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='xm' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      console.log(`查询管理员邮箱结果: "${adminEmailResult}"`)

      // 过滤掉表头，只取最后一行
      const lines = adminEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]

      if (email && email.includes('@')) {
        res.json({
          success: true,
          email: email,
          username: 'xm',
          display: `系统管理员 (${email})`
        })
      } else {
        // 如果查询失败，返回默认值
        console.log('管理员邮箱查询失败，使用默认值')
        res.json({
          success: true,
          email: 'xm@localhost',
          username: 'xm',
          display: '系统管理员 (xm@localhost)'
        })
      }
    } catch (dbError) {
      console.log('查询管理员邮箱失败:', dbError.message)
      // 返回默认值
      res.json({
        success: true,
        email: 'xm@localhost',
        username: 'xm',
        display: '系统管理员 (xm@localhost)'
      })
    }
  } catch (error) {
    console.error('获取管理员邮箱失败:', error)
    res.status(500).json({
      success: false,
      error: '获取管理员邮箱失败',
      message: error.message
    })
  }
})

// 备案号API端点（公开访问，无需认证）
app.get('/api/icp-info', (req, res) => {
  try {
    // 从配置文件读取备案号设置
    const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
    if (fs.existsSync(settingsFile)) {
      const settingsData = fs.readFileSync(settingsFile, 'utf8')
      const settings = JSON.parse(settingsData)
      
      if (settings.general && settings.general.icp) {
        return res.json({
          success: true,
          icp: {
            enabled: settings.general.icp.enabled || false,
            number: settings.general.icp.number || '',
            url: settings.general.icp.url || 'https://beian.miit.gov.cn/'
          }
        })
      }
    }
    
    // 如果没有配置，返回默认值
    res.json({
      success: true,
      icp: {
        enabled: false,
        number: '',
        url: 'https://beian.miit.gov.cn/'
      }
    })
  } catch (error) {
    console.error('获取备案号信息失败:', error)
    res.json({
      success: true,
      icp: {
        enabled: false,
        number: '',
        url: 'https://beian.miit.gov.cn/'
      }
    })
  }
})

// 系统设置API端点
// 获取系统设置
app.get('/api/system-settings', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录系统设置查询
    const logLine = `[${timestamp}] [SYSTEM_SETTINGS_GET] User: ${user}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    // 从配置文件或数据库读取系统设置
    let systemSettings = {}
    
    try {
      // 优先查找最新的时间戳备份文件
      const configDir = path.join(ROOT_DIR, 'config')
      let settingsFile = path.join(configDir, 'system-settings.json')
      
      // 查找所有时间戳备份文件（包括正确格式和错误格式）
      let latestBackup = null
      if (fs.existsSync(configDir)) {
        try {
          const files = fs.readdirSync(configDir)
          
          // 处理错误格式的备份文件（system-settings.json.backup.YYYYMMDD_HHMMSS）
          const wrongFormatFiles = files.filter(file => 
            file.startsWith('system-settings.json.backup.') && 
            /^\d{8}_\d{6}$/.test(file.replace('system-settings.json.backup.', ''))
          )
          
          for (const wrongFile of wrongFormatFiles) {
            try {
              const wrongFilePath = path.join(configDir, wrongFile)
              const timestamp = wrongFile.replace('system-settings.json.backup.', '')
              const correctFileName = `system-settings.json-${timestamp}.backup`
              const correctFilePath = path.join(configDir, correctFileName)
              
              if (fs.existsSync(correctFilePath)) {
                // 如果正确格式的文件已存在，删除错误格式的文件
                fs.unlinkSync(wrongFilePath)
                console.log('已删除错误格式的备份文件（正确格式已存在）:', wrongFile)
              } else {
                // 重命名错误格式的文件
                fs.renameSync(wrongFilePath, correctFilePath)
                console.log('已重命名错误格式的备份文件:', wrongFile, '->', correctFileName)
              }
            } catch (renameError) {
              console.warn('处理错误格式备份文件失败:', wrongFile, renameError.message)
            }
          }
          
          // 查找所有正确格式的时间戳备份文件
          const backupFiles = files
            .filter(file => file.startsWith('system-settings.json-') && file.endsWith('.backup'))
            .map(file => {
              try {
                const filePath = path.join(configDir, file)
                return {
                  name: file,
                  path: filePath,
                  mtime: fs.statSync(filePath).mtime.getTime()
                }
              } catch (err) {
                console.warn('无法读取备份文件信息:', file, err.message)
                return null
              }
            })
            .filter(file => file !== null)
            .sort((a, b) => b.mtime - a.mtime) // 按修改时间降序排序
          
          if (backupFiles.length > 0) {
            latestBackup = backupFiles[0].path
            console.log('找到最新的时间戳备份文件:', latestBackup)
          }
        } catch (err) {
          console.warn('读取配置目录失败:', err.message)
        }
      }
      
      // 如果找到最新的备份文件，优先使用备份文件
      if (latestBackup && fs.existsSync(latestBackup)) {
        settingsFile = latestBackup
        console.log('使用最新的时间戳备份文件加载系统设置:', latestBackup)
      } else {
        // 如果没有时间戳备份文件，尝试使用旧格式备份文件
        const oldBackupFile = path.join(configDir, 'system-settings.json.backup')
        if (fs.existsSync(oldBackupFile)) {
          settingsFile = oldBackupFile
          console.log('使用旧格式备份文件加载系统设置:', oldBackupFile)
        } else {
          console.log('未找到备份文件，使用主配置文件:', settingsFile)
        }
      }
      
      // 尝试从配置文件或备份文件读取
      if (fs.existsSync(settingsFile)) {
        // 设置文件权限为 755 (rwxr-xr-x)
        try {
          fs.chmodSync(settingsFile, 0o755)
          console.log('系统设置文件权限已设置为755')
        } catch (chmodError) {
          try {
            execSync(`sudo chmod 755 "${settingsFile}"`, { timeout: 3000 })
            console.log('系统设置文件权限已设置为755（使用sudo）')
          } catch (sudoError) {
            console.warn('设置系统设置文件权限失败:', sudoError.message)
          }
        }
        
        const settingsData = fs.readFileSync(settingsFile, 'utf8')
        systemSettings = JSON.parse(settingsData)
        console.log('从配置文件加载系统设置，adminEmail:', systemSettings.general?.adminEmail, '来源:', settingsFile)
        // 如果配置文件存在，直接使用配置文件中的值，不再从数据库查询覆盖
        // 确保general对象存在
        if (!systemSettings.general) systemSettings.general = {}
        if (!systemSettings.notifications) systemSettings.notifications = {}
        // 确保security对象存在，特别是requireSpecialChars默认为false
        if (!systemSettings.security) systemSettings.security = {}
        // 如果requireSpecialChars不存在或为undefined/null，默认为false（关闭）
        if (systemSettings.security.requireSpecialChars === undefined || systemSettings.security.requireSpecialChars === null) {
          systemSettings.security.requireSpecialChars = false
        }

        // 优先从数据库读取管理员邮箱，如果数据库中有值则覆盖配置文件
        try {
          const mailDbPass = getMailDbPassword()
          const xmEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='xm' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
          const lines = xmEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
          const dbAdminEmail = lines[lines.length - 1]

          if (dbAdminEmail && dbAdminEmail.includes('@')) {
            systemSettings.general.adminEmail = dbAdminEmail
            systemSettings.notifications.alertEmail = dbAdminEmail
            console.log('使用数据库中的管理员邮箱:', dbAdminEmail)
          } else if (systemSettings.general.adminEmail) {
            if (!systemSettings.notifications.alertEmail) {
              systemSettings.notifications.alertEmail = systemSettings.general.adminEmail
            }
            console.log('使用配置文件中的管理员邮箱:', systemSettings.general.adminEmail)
          }
        } catch (dbError) {
          console.warn('从数据库读取管理员邮箱失败，使用配置文件:', dbError.message)
          if (systemSettings.general.adminEmail) {
            if (!systemSettings.notifications.alertEmail) {
              systemSettings.notifications.alertEmail = systemSettings.general.adminEmail
            }
            console.log('使用配置文件中的管理员邮箱:', systemSettings.general.adminEmail)
          }
        }
      } else {
        // 如果配置文件不存在，返回默认设置
        systemSettings = {
          general: {
            systemName: 'XM邮件管理系统',
            adminEmail: 'xm@localhost',
            timezone: 'Asia/Shanghai',
            language: 'zh-CN',
            autoBackup: true,
            backupInterval: 24,
            logRetention: 30,
            userPageSize: 10
          },
          security: {
            enableSSL: true,
            forceHTTPS: true,
            sessionTimeout: 30,
            maxLoginAttempts: 5,
            passwordMinLength: 8,
            requireSpecialChars: false  // 默认关闭
          },
          mail: {
            maxMailboxSize: 1024,
            maxMessageSize: 25,
            enableSpamFilter: true,
            enableVirusScan: true,
            quarantineDays: 7,
            autoDeleteSpam: false,
            pageSize: 8,
            domains: [
              { id: 1, name: 'xmskills.com', isDefault: true }
            ]
          },
          notifications: {
            emailAlerts: true,
            systemAlerts: true,
            securityAlerts: true,
            maintenanceAlerts: true,
            alertEmail: 'xm@localhost'
          },
          performance: {
            maxConnections: 1000,
            connectionTimeout: 30,
            enableCompression: true,
            cacheSize: 256,
            enableCaching: true
          },
          broadcast: {
            message: '欢迎使用XM邮件管理系统，请您在使用过程中遵守服务规范，与我们携手共建清朗网络空间。'
          }
        }

        // 基于当前系统自动探测并填充合理默认值（域名/主机名）
        console.log('开始自动探测系统配置...')
        
        // 获取当前系统时区
        try {
          const currentTimezone = execSync('timedatectl show --property=Timezone --value', { encoding: 'utf8', timeout: 3000 }).trim()
          if (currentTimezone && systemSettings.general) {
            systemSettings.general.timezone = currentTimezone
            console.log('当前系统时区:', currentTimezone)
          }
        } catch (error) {
          console.warn('获取系统时区失败:', error.message)
        }
        
        // 从数据库获取管理员邮箱（配置文件不存在时）
        try {
          console.log('配置文件不存在，从数据库查询xm用户邮箱...')
          let xmEmail = ''
          
          // 优先从应用数据库（app_users表）获取xm用户的邮箱
          try {
            const appEmail = execSync("mysql -u root mailapp -e \"SELECT email FROM app_users WHERE username='xm' LIMIT 1;\" 2>/dev/null | tail -1", { encoding: 'utf8', timeout: 3000 }).trim()
            if (appEmail && appEmail !== 'email' && appEmail.includes('@') && appEmail !== 'NULL') {
              xmEmail = appEmail
              console.log('从应用数据库查询到的xm邮箱:', xmEmail)
            }
          } catch (appError) {
            console.log('从应用数据库查询失败，尝试从邮件数据库查询:', appError.message)
          }
          
          // 如果应用数据库中没有，尝试从邮件数据库获取
          if (!xmEmail) {
            try {
              const mailDbPass = getMailDbPassword()
              const mailEmail = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -e "SELECT email FROM mail_users WHERE username='xm' LIMIT 1;" 2>/dev/null | tail -1`, { encoding: 'utf8', timeout: 3000 }).trim()
              if (mailEmail && mailEmail !== 'email' && mailEmail.includes('@') && mailEmail !== 'NULL') {
                xmEmail = mailEmail
                console.log('从邮件数据库查询到的xm邮箱:', xmEmail)
              }
            } catch (mailError) {
              console.log('从邮件数据库查询失败:', mailError.message)
            }
          }
          
          if (xmEmail && xmEmail !== 'email' && xmEmail.includes('@') && xmEmail !== 'NULL') {
            // 使用数据库中的邮箱
            systemSettings.general.adminEmail = xmEmail
            systemSettings.notifications.alertEmail = xmEmail
            if (!systemSettings.dns) systemSettings.dns = { bind: {}, public: {} }
            if (!systemSettings.dns.bind) systemSettings.dns.bind = {}
            if (!systemSettings.dns.public) systemSettings.dns.public = {}
            systemSettings.dns.bind.adminEmail = xmEmail
            systemSettings.dns.public.adminEmail = xmEmail
            console.log('从数据库设置管理员邮箱为:', xmEmail)
          } else {
            console.log('数据库中没有找到有效的xm用户邮箱，使用默认值 xm@localhost')
          }
        } catch (error) {
          console.log('查询数据库失败，使用默认管理员邮箱:', error.message)
        }
        
        try {
          let configuredHostname = null
          let configuredDomain = null
          try {
            // 优先读取 Postfix 配置（若已配置）
            const domainCheck = execSync("grep -E '^myhostname|^mydomain' /etc/postfix/main.cf 2>/dev/null | head -2", { encoding: 'utf8', timeout: 3000 })
            const domainLines = domainCheck.trim().split('\n').filter(Boolean)
            for (const line of domainLines) {
              if (line.includes('myhostname')) {
                const val = line.split('=')[1]
                if (val) configuredHostname = val.trim()
              } else if (line.includes('mydomain')) {
                const val = line.split('=')[1]
                if (val) configuredDomain = val.trim()
              }
            }
          } catch (_) {
            // 忽略错误，使用 hostname 兜底
          }

          if (!configuredHostname) {
            try {
              configuredHostname = execSync('hostname -f', { encoding: 'utf8', timeout: 3000 }).trim()
            } catch (_) {
              try {
                configuredHostname = execSync('hostname', { encoding: 'utf8', timeout: 3000 }).trim()
              } catch (_) {}
            }
          }

          if (!configuredDomain && configuredHostname) {
            const parts = configuredHostname.split('.')
            if (parts.length > 1) configuredDomain = parts.slice(1).join('.')
          }

          // 若仍未获取到域名，尝试从数据库 virtual_domains 表读取
          if (!configuredDomain) {
            try {
              const mailDbPass = getMailDbPassword()
              const dbDomain = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -e "SELECT name FROM virtual_domains LIMIT 1;" 2>/dev/null | tail -1`, { encoding: 'utf8', timeout: 3000 }).trim()
              if (dbDomain && dbDomain !== 'name') configuredDomain = dbDomain
            } catch (_) {}
          }

          // 将探测到的域名回填到默认系统设置
          if (configuredDomain) {
            // 设置 DNS -> bind.domain
            if (!systemSettings.dns) systemSettings.dns = { bind: {}, public: {} }
            if (!systemSettings.dns.bind) systemSettings.dns.bind = {}
            if (!systemSettings.dns.public) systemSettings.dns.public = {}
            systemSettings.dns.bind.domain = systemSettings.dns.bind.domain || configuredDomain

            // 检测并保留现有的管理员邮箱配置
            // 如果配置文件中已有非默认值的管理员邮箱，则保留它（不修改）
            // 只有在配置文件中没有adminEmail或值为默认值'xm@localhost'时，才从数据库查询
            const currentAdminEmail = systemSettings.general?.adminEmail || ''
            const isDefaultEmail = !currentAdminEmail || currentAdminEmail === 'xm@localhost'
            
            // 如果配置文件中有非默认值的管理员邮箱，保留它
            if (!isDefaultEmail) {
              console.log('检测到配置文件中有管理员邮箱配置，保留现有配置:', currentAdminEmail)
              // 确保DNS配置中的adminEmail也同步
              if (!systemSettings.dns) systemSettings.dns = { bind: {}, public: {} }
              if (!systemSettings.dns.bind) systemSettings.dns.bind = {}
              if (!systemSettings.dns.public) systemSettings.dns.public = {}
              if (!systemSettings.dns.bind.adminEmail || systemSettings.dns.bind.adminEmail === 'xm@localhost') {
                systemSettings.dns.bind.adminEmail = currentAdminEmail
              }
              if (!systemSettings.dns.public.adminEmail || systemSettings.dns.public.adminEmail === 'xm@localhost') {
                systemSettings.dns.public.adminEmail = currentAdminEmail
              }
            if (!systemSettings.notifications) systemSettings.notifications = {}
              if (!systemSettings.notifications.alertEmail || systemSettings.notifications.alertEmail === 'xm@localhost') {
                systemSettings.notifications.alertEmail = currentAdminEmail
              }
            } else {
              // 只有在配置文件中没有adminEmail或值为默认值时，才从数据库查询
              try {
                // 优先从应用数据库（app_users表）获取xm用户的邮箱
                console.log('配置文件中没有管理员邮箱或为默认值，查询数据库中的xm用户邮箱...')
                let xmEmail = ''
                
                // 先尝试从应用数据库获取
                try {
                  const appEmail = execSync("mysql -u root mailapp -e \"SELECT email FROM app_users WHERE username='xm' LIMIT 1;\" 2>/dev/null | tail -1", { encoding: 'utf8', timeout: 3000 }).trim()
                  if (appEmail && appEmail !== 'email' && appEmail.includes('@') && appEmail !== 'NULL') {
                    xmEmail = appEmail
                    console.log('从应用数据库查询到的xm邮箱:', xmEmail)
                  }
                } catch (appError) {
                  console.log('从应用数据库查询失败，尝试从邮件数据库查询:', appError.message)
                }
                
                // 如果应用数据库中没有，尝试从邮件数据库获取
                if (!xmEmail) {
                  try {
                    const mailDbPass = getMailDbPassword()
              const mailEmail = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -e "SELECT email FROM mail_users WHERE username='xm' LIMIT 1;" 2>/dev/null | tail -1`, { encoding: 'utf8', timeout: 3000 }).trim()
                    if (mailEmail && mailEmail !== 'email' && mailEmail.includes('@') && mailEmail !== 'NULL') {
                      xmEmail = mailEmail
                      console.log('从邮件数据库查询到的xm邮箱:', xmEmail)
                    }
                  } catch (mailError) {
                    console.log('从邮件数据库查询失败:', mailError.message)
                  }
                }
                
                if (xmEmail && xmEmail !== 'email' && xmEmail.includes('@') && xmEmail !== 'NULL') {
                  // 更新配置文件中的管理员邮箱（仅在内存中，不写回文件）
                  systemSettings.general.adminEmail = xmEmail
                  systemSettings.notifications.alertEmail = xmEmail
                  if (!systemSettings.dns) systemSettings.dns = { bind: {}, public: {} }
                  if (!systemSettings.dns.bind) systemSettings.dns.bind = {}
                  if (!systemSettings.dns.public) systemSettings.dns.public = {}
                  systemSettings.dns.bind.adminEmail = xmEmail
                  systemSettings.dns.public.adminEmail = xmEmail
                  console.log('从数据库设置管理员邮箱为:', xmEmail)
                  console.log('从数据库设置警报邮箱为:', xmEmail)
                } else {
                  // 如果数据库中没有xm用户或邮箱无效，使用默认值（但不写回配置文件）
                  if (!systemSettings.general.adminEmail) {
                    systemSettings.general.adminEmail = 'xm@localhost'
                  }
                  if (!systemSettings.notifications.alertEmail) {
                    systemSettings.notifications.alertEmail = systemSettings.general.adminEmail
                  }
                  if (!systemSettings.dns) systemSettings.dns = { bind: {}, public: {} }
                  if (!systemSettings.dns.bind) systemSettings.dns.bind = {}
                  if (!systemSettings.dns.public) systemSettings.dns.public = {}
                  if (!systemSettings.dns.bind.adminEmail) {
                    systemSettings.dns.bind.adminEmail = systemSettings.general.adminEmail
                  }
                  if (!systemSettings.dns.public.adminEmail) {
                    systemSettings.dns.public.adminEmail = systemSettings.general.adminEmail
                  }
                  console.log('使用默认管理员邮箱:', systemSettings.general.adminEmail)
                }
              } catch (error) {
                // 如果数据库查询失败，使用配置文件中的值或默认值
                console.log('数据库查询失败，使用配置文件中的值或默认值:', error.message)
                if (!systemSettings.general.adminEmail) {
                  systemSettings.general.adminEmail = 'xm@localhost'
                }
                if (!systemSettings.notifications.alertEmail) {
                  systemSettings.notifications.alertEmail = systemSettings.general.adminEmail
                }
                if (!systemSettings.dns) systemSettings.dns = { bind: {}, public: {} }
                if (!systemSettings.dns.bind) systemSettings.dns.bind = {}
                if (!systemSettings.dns.public) systemSettings.dns.public = {}
                if (!systemSettings.dns.bind.adminEmail) {
                  systemSettings.dns.bind.adminEmail = systemSettings.general.adminEmail
                }
                if (!systemSettings.dns.public.adminEmail) {
                  systemSettings.dns.public.adminEmail = systemSettings.general.adminEmail
                }
              }
            }

            // 从数据库加载域名列表
            if (!systemSettings.mail) systemSettings.mail = {}
            try {
              console.log('从数据库加载域名列表...')
              const mailDbScript = path.join(__dirname, '..', 'scripts', 'mail_db.sh')
              const domainsResult = execSync(`bash "${mailDbScript}" list_domains`, { encoding: 'utf8' })
              console.log('域名查询结果:', domainsResult)
              
              if (domainsResult && domainsResult.trim() !== '[]') {
                const domains = JSON.parse(domainsResult)
                systemSettings.mail.domains = domains.map((domain, index) => ({
                  id: parseInt(domain.id),
                  name: domain.name,
                  isDefault: index === 0 // 第一个域名为默认域名
                }))
                console.log('加载的域名列表:', systemSettings.mail.domains)
              } else {
                // 如果没有域名，使用探测到的域名作为默认
                systemSettings.mail.domains = [ { id: 1, name: configuredDomain, isDefault: true } ]
              }
            } catch (error) {
              console.log('从数据库加载域名失败:', error.message)
              // 如果数据库查询失败，使用探测到的域名
              systemSettings.mail.domains = [ { id: 1, name: configuredDomain, isDefault: true } ]
            }
          }

          // 从 /etc/resolv.conf 提取 DNS 信息，填充 bind.serverIp 与 upstreamDns
          try {
            console.log('读取 /etc/resolv.conf...')
            const resolv = fs.readFileSync('/etc/resolv.conf', 'utf8')
            console.log('resolv.conf 内容:', resolv)
            const lines = resolv.split('\n')
            const nameservers = lines
              .map(l => l.trim())
              .filter(l => l.startsWith('nameserver'))
              .map(l => l.split(/\s+/)[1])
              .filter(Boolean)

            console.log('解析到的nameservers:', nameservers)

            const isLoopback = ip => ip === '127.0.0.1' || ip === '::1'
            const isPrivate = ip => /^(10\.|192\.168\.|172\.(1[6-9]|2[0-9]|3[0-1])\.)/.test(ip)

            const privateNs = nameservers.filter(ip => isPrivate(ip) && !isLoopback(ip))
            const publicNs = nameservers.filter(ip => !isPrivate(ip) && !isLoopback(ip))
            
            console.log('私有DNS:', privateNs)
            console.log('公共DNS:', publicNs)

            if (!systemSettings.dns) systemSettings.dns = { bind: {} }
            if (!systemSettings.dns.bind) systemSettings.dns.bind = {}

            // 动态获取当前服务器IP地址（优先获取主网卡IP）
            try {
              // 方法1：获取主网卡IP（排除回环地址）
              let currentServerIp = null
              try {
                const hostIp = execSync("hostname -I | awk '{print $1}'", { encoding: 'utf8', timeout: 3000 }).trim()
                if (hostIp && !hostIp.includes('127.0.0.1')) {
                  currentServerIp = hostIp
                }
              } catch (_) {}
              
              // 方法2：通过路由获取外网IP
              if (!currentServerIp) {
                try {
                  const routeIp = execSync("ip route get 1.1.1.1 | awk '{print $7; exit}'", { encoding: 'utf8', timeout: 3000 }).trim()
                  if (routeIp && !routeIp.includes('127.0.0.1')) {
                    currentServerIp = routeIp
                  }
                } catch (_) {}
              }
              
              // 方法3：从网络接口获取
              if (!currentServerIp) {
                try {
                  const ifaceIp = execSync("ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1", { encoding: 'utf8', timeout: 3000 }).trim()
                  if (ifaceIp) {
                    currentServerIp = ifaceIp
                  }
                } catch (_) {}
              }
              
              // 如果获取到当前IP，则更新设置
              if (currentServerIp) {
                systemSettings.dns.bind.serverIp = currentServerIp
              }
            } catch (_) {
              // 如果所有方法都失败，保持默认值
            }

            // 上游DNS取公共DNS列表（从resolv.conf读取所有公共DNS）
            if (publicNs.length > 0) {
              systemSettings.dns.bind.upstreamDns = publicNs.join(', ')
              console.log('设置上游DNS为:', systemSettings.dns.bind.upstreamDns)
            } else {
              // 如果没有公共DNS，使用默认值
              systemSettings.dns.bind.upstreamDns = '8.8.8.8, 8.8.4.4'
              console.log('使用默认上游DNS:', systemSettings.dns.bind.upstreamDns)
            }
          } catch (_) {
            // 没有 resolv.conf 或解析失败则忽略，保留默认值
          }
        } catch (autoErr) {
          console.warn('Auto-detect defaults for system settings failed:', autoErr?.message)
        }
      }
    } catch (error) {
      console.error('Failed to load system settings:', error)
      systemSettings = {}
    }
    
    // 无论配置文件是否存在，都从数据库重新加载域名列表（确保数据最新）
    if (!systemSettings.mail) systemSettings.mail = {}
    try {
      console.log('从数据库重新加载域名列表（确保数据最新）...')
      const mailDbScript = path.join(__dirname, '..', 'scripts', 'mail_db.sh')
      const domainsResult = execSync(`bash "${mailDbScript}" list_domains`, { encoding: 'utf8', timeout: 5000 })
      console.log('域名查询结果:', domainsResult)
      
      if (domainsResult && domainsResult.trim() !== '[]') {
        const domains = JSON.parse(domainsResult)
        // 获取DNS配置的域名（优先使用配置文件中的值）
        const dnsDomain = systemSettings.dns?.bind?.domain || systemSettings.dns?.public?.domain
        
        systemSettings.mail.domains = domains.map((domain) => {
          const isDnsDomain = dnsDomain && domain.name.toLowerCase() === dnsDomain.toLowerCase()
          return {
            id: parseInt(domain.id),
            name: domain.name,
            isDefault: isDnsDomain, // DNS配置的域名为默认域名
            isDnsDomain: isDnsDomain // 标记为DNS配置的域名
          }
        })
        
        // 如果没有DNS域名，则第一个域名为默认域名
        if (!dnsDomain && domains.length > 0) {
          systemSettings.mail.domains[0].isDefault = true
        }
        
        console.log('重新加载的域名列表:', systemSettings.mail.domains)
      } else if (!systemSettings.mail.domains) {
        // 如果没有域名且配置文件中也没有，设置为空数组
        systemSettings.mail.domains = []
      }
    } catch (error) {
      console.log('从数据库重新加载域名失败（使用现有配置）:', error.message)
      // 如果重新加载失败，保留现有的域名列表或设置为空数组
      if (!systemSettings.mail.domains) {
        systemSettings.mail.domains = []
      }
    }
    
    // 确保广播消息存在，如果不存在或为空则使用默认值
    if (!systemSettings.broadcast) {
      systemSettings.broadcast = {}
    }
    if (!systemSettings.broadcast.message || systemSettings.broadcast.message.trim() === '') {
      const defaultBroadcastMessage = '欢迎使用XM邮件管理系统，请您在使用过程中遵守服务规范，与我们携手共建清朗网络空间。'
      systemSettings.broadcast.message = defaultBroadcastMessage
      console.log('广播消息为空，使用默认值:', defaultBroadcastMessage)
      
      // 如果配置文件存在，自动保存默认广播消息到配置文件
      const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
      if (fs.existsSync(settingsFile)) {
        try {
          const configDir = path.join(ROOT_DIR, 'config')
          const updatedSettings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
          updatedSettings.broadcast = { message: defaultBroadcastMessage }
          fs.writeFileSync(settingsFile, JSON.stringify(updatedSettings, null, 2))
          console.log('默认广播消息已保存到配置文件')
        } catch (saveError) {
          console.warn('保存默认广播消息到配置文件失败:', saveError.message)
        }
      }
    }
    
    // DNS 配置已移除，不再返回给前端（主配置、备份、默认值均不包含 dns）
    delete systemSettings.dns

    res.json({
      success: true,
      settings: systemSettings,
      timestamp: timestamp
    })
    
  } catch (error) {
    console.error('System settings get error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get system settings',
      message: error.message
    })
  }
})

// 保存系统设置
app.post('/api/system-settings', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    const { settings } = req.body
    
    // 记录系统设置保存操作
    try {
      const logLine = `[${timestamp}] [SYSTEM_SETTINGS_SAVE] User: ${user}, IP: ${clientIP}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    } catch (logError) {
      // 日志写入失败不应该阻止设置保存
      console.warn('Failed to write operation log:', logError.message)
    }
    
    // 验证设置数据
    if (!settings || typeof settings !== 'object') {
      return res.status(400).json({
        success: false,
        error: 'Invalid settings data'
      })
    }
    
    // 确保配置目录存在
    const configDir = path.join(ROOT_DIR, 'config')
    if (!fs.existsSync(configDir)) {
      fs.mkdirSync(configDir, { recursive: true, mode: 0o755 })
      console.log('Config directory created')
    }
    
    // 尝试修复配置目录权限，确保 xm 用户可以访问
    try {
      execSync(`chown -R xm:xm "${configDir}"`, { timeout: 3000 })
      console.log('Config directory ownership fixed to xm:xm')
    } catch (chownError) {
      // 如果 chown 失败，尝试使用 sudo
      try {
        execSync(`sudo chown -R xm:xm "${configDir}"`, { timeout: 3000 })
        console.log('Config directory ownership fixed to xm:xm (using sudo)')
      } catch (sudoError) {
        console.warn('Failed to fix config directory ownership:', sudoError.message)
      }
    }
    
    // 保存设置到配置文件（合并现有设置，避免覆盖）
    const settingsFile = path.join(configDir, 'system-settings.json')
    let existingSettings = {}
    
    // 如果配置文件存在，先读取现有设置
    if (fs.existsSync(settingsFile)) {
      try {
        const existingData = fs.readFileSync(settingsFile, 'utf8')
        existingSettings = JSON.parse(existingData)
      } catch (readError) {
        console.warn('Failed to read existing settings file:', readError)
        // 如果读取失败，使用空对象
        existingSettings = {}
      }
    }
    
    // 保护现有的管理员邮箱配置（如果已存在非默认值，则保留）
    const existingAdminEmail = existingSettings?.general?.adminEmail || ''
    const newAdminEmail = settings?.general?.adminEmail || ''
    const isExistingDefault = !existingAdminEmail || existingAdminEmail === 'xm@localhost'
    const isNewDefault = !newAdminEmail || newAdminEmail === 'xm@localhost'
    
    // 如果现有配置中有非默认值的管理员邮箱，且新配置是默认值，则保留现有配置
    if (!isExistingDefault && isNewDefault) {
      console.log('检测到现有配置中有非默认值的管理员邮箱，保留现有配置:', existingAdminEmail)
      // 保护现有配置，不覆盖
      if (!settings.general) settings.general = {}
      settings.general.adminEmail = existingAdminEmail
      
      if (existingSettings?.notifications?.alertEmail && existingSettings.notifications.alertEmail !== 'xm@localhost') {
        if (!settings.notifications) settings.notifications = {}
        settings.notifications.alertEmail = existingSettings.notifications.alertEmail
      }
    }
    
    // 深度合并设置（新设置覆盖现有设置）
    console.log('Merging settings...')
    console.log('Existing settings:', JSON.stringify(existingSettings, null, 2))
    console.log('New settings:', JSON.stringify(settings, null, 2))
    
    let mergedSettings
    try {
      mergedSettings = deepMerge(existingSettings, settings)
      
      // 再次确保管理员邮箱不被覆盖（如果现有配置中有非默认值）
      if (!isExistingDefault) {
        mergedSettings.general = mergedSettings.general || {}
        mergedSettings.general.adminEmail = existingAdminEmail
        console.log('保护管理员邮箱配置，使用现有值:', existingAdminEmail)
      }
      
      console.log('Merged settings:', JSON.stringify(mergedSettings, null, 2))
      
      // 删除备份相关字段（备份功能已移至Dashboard）
      if (mergedSettings.general) {
        delete mergedSettings.general.autoBackup
        delete mergedSettings.general.backupInterval
      }
      // DNS 配置已移除，不再写入主配置与时间戳备份
      delete mergedSettings.dns
    } catch (mergeError) {
      console.error('Failed to merge settings:', mergeError)
      console.error('Merge error stack:', mergeError.stack)
      throw new Error(`Failed to merge settings: ${mergeError.message}`)
    }
    
    // 保存合并后的设置
    try {
      console.log('Writing settings to file:', settingsFile)
      console.log('Config directory exists:', fs.existsSync(configDir))
      console.log('Config directory is writable:', fs.accessSync ? 'checking...' : 'unknown')
      
      // 确保目录存在且可写
      if (!fs.existsSync(configDir)) {
        fs.mkdirSync(configDir, { recursive: true, mode: 0o755 })
        console.log('Config directory created')
      }
      
      const settingsJson = JSON.stringify(mergedSettings, null, 2)
      console.log('Settings JSON length:', settingsJson.length)
      
      // 如果文件存在且属于 root，先尝试删除（使用 sudo）
      if (fs.existsSync(settingsFile)) {
        try {
          const stats = fs.statSync(settingsFile)
          // 检查文件所有者（需要 root 权限才能获取）
          // 如果写入失败，会在 catch 中处理
        } catch (statError) {
          console.warn('Failed to stat settings file:', statError.message)
        }
      }
      
      // 尝试写入文件
      try {
        fs.writeFileSync(settingsFile, settingsJson, 'utf8')
        console.log('Settings file written successfully')
      } catch (writeError) {
        // 如果写入失败（可能是权限问题），尝试使用 sudo 删除文件后重新创建
        if (writeError.code === 'EACCES' || writeError.code === 'EPERM') {
          console.warn('File write failed due to permissions, attempting to fix...')
          try {
            // 使用 sudo 删除文件
            execSync(`sudo rm -f "${settingsFile}"`, { timeout: 3000 })
            console.log('Old settings file removed (using sudo)')
            // 重新写入文件
            fs.writeFileSync(settingsFile, settingsJson, 'utf8')
            console.log('Settings file written successfully after removing old file')
          } catch (sudoError) {
            console.error('Failed to remove old file and write new one:', sudoError.message)
            throw writeError // 抛出原始错误
          }
        } else {
          throw writeError
        }
      }
      
      // 修复文件权限，确保 xm 用户可以读写
      try {
        // 尝试使用 chown 修复权限（如果当前用户是 xm）
        try {
          execSync(`chown xm:xm "${settingsFile}"`, { timeout: 3000 })
          console.log('Settings file ownership fixed to xm:xm')
        } catch (chownError) {
          // 如果 chown 失败，尝试使用 sudo（如果 xm 用户有 sudo 权限）
          try {
            execSync(`sudo chown xm:xm "${settingsFile}"`, { timeout: 3000 })
            console.log('Settings file ownership fixed to xm:xm (using sudo)')
          } catch (sudoError) {
            console.warn('Failed to fix file ownership, but file was written successfully')
            console.warn('Chown error:', chownError.message)
            console.warn('Sudo chown error:', sudoError.message)
          }
        }
        // 设置文件权限为 755 (rwxr-xr-x)
        try {
          fs.chmodSync(settingsFile, 0o755)
          console.log('Settings file permissions set to 755')
        } catch (chmodError) {
          console.warn('Failed to set file permissions:', chmodError.message)
        }
      } catch (permError) {
        console.warn('Failed to fix file permissions:', permError.message)
      }
      
      // 创建时间戳备份文件（每次保存时都创建新的备份）
      try {
        // 生成时间戳格式：YYYYMMDD_HHMMSS（与start.sh中的格式一致）
        const now = new Date()
        const year = now.getFullYear()
        const month = String(now.getMonth() + 1).padStart(2, '0')
        const day = String(now.getDate()).padStart(2, '0')
        const hours = String(now.getHours()).padStart(2, '0')
        const minutes = String(now.getMinutes()).padStart(2, '0')
        const seconds = String(now.getSeconds()).padStart(2, '0')
        const timestamp = `${year}${month}${day}_${hours}${minutes}${seconds}` // 格式：20260128_102312
        
        const backupFile = path.join(configDir, `system-settings.json-${timestamp}.backup`)
        
        // 复制主配置文件到时间戳备份文件
        fs.writeFileSync(backupFile, settingsJson, 'utf8')
        console.log('时间戳备份文件已创建:', backupFile)
        
        // 设置备份文件权限为 755 (rwxr-xr-x)
        try {
          execSync(`chown xm:xm "${backupFile}"`, { timeout: 3000 })
          fs.chmodSync(backupFile, 0o755)
          console.log('时间戳备份文件权限已设置为755')
        } catch (backupPermError) {
          try {
            execSync(`sudo chown xm:xm "${backupFile}"`, { timeout: 3000 })
            execSync(`sudo chmod 755 "${backupFile}"`, { timeout: 3000 })
            console.log('时间戳备份文件权限已设置为755（使用sudo）')
          } catch (sudoBackupError) {
            console.warn('设置备份文件权限失败:', sudoBackupError.message)
          }
        }
      } catch (backupError) {
        console.warn('创建时间戳备份文件失败:', backupError.message)
        // 备份失败不应该阻止主文件保存成功
      }
      
      // 清理旧的时间戳备份文件，只保留最新的3个
      try {
        const files = fs.readdirSync(configDir)
        
        // 首先处理错误格式的备份文件（system-settings.json.backup.YYYYMMDD_HHMMSS）
        // 将它们重命名为正确格式（system-settings.json-YYYYMMDD_HHMMSS.backup）
        const wrongFormatFiles = files.filter(file => 
          file.startsWith('system-settings.json.backup.') && 
          /^\d{8}_\d{6}$/.test(file.replace('system-settings.json.backup.', ''))
        )
        
        for (const wrongFile of wrongFormatFiles) {
          try {
            const wrongFilePath = path.join(configDir, wrongFile)
            // 提取时间戳部分
            const timestamp = wrongFile.replace('system-settings.json.backup.', '')
            // 重命名为正确格式
            const correctFileName = `system-settings.json-${timestamp}.backup`
            const correctFilePath = path.join(configDir, correctFileName)
            
            // 如果正确格式的文件已存在，删除错误格式的文件
            if (fs.existsSync(correctFilePath)) {
              fs.unlinkSync(wrongFilePath)
              console.log('已删除错误格式的备份文件（正确格式已存在）:', wrongFile)
            } else {
              // 重命名错误格式的文件
              fs.renameSync(wrongFilePath, correctFilePath)
              console.log('已重命名错误格式的备份文件:', wrongFile, '->', correctFileName)
            }
          } catch (renameError) {
            console.warn('处理错误格式备份文件失败:', wrongFile, renameError.message)
            // 如果重命名失败，尝试删除错误格式的文件
            try {
              fs.unlinkSync(path.join(configDir, wrongFile))
              console.log('已删除错误格式的备份文件:', wrongFile)
            } catch (deleteError) {
              console.warn('删除错误格式备份文件失败:', wrongFile, deleteError.message)
            }
          }
        }
        
        // 查找所有正确格式的时间戳备份文件
        const backupFiles = files
          .filter(file => file.startsWith('system-settings.json-') && file.endsWith('.backup'))
          .map(file => {
            try {
              const filePath = path.join(configDir, file)
              return {
                name: file,
                path: filePath,
                mtime: fs.statSync(filePath).mtime.getTime()
              }
            } catch (err) {
              console.warn('无法读取备份文件信息:', file, err.message)
              return null
            }
          })
          .filter(file => file !== null)
          .sort((a, b) => b.mtime - a.mtime) // 按修改时间降序排序
        
        // 如果备份文件数量大于3个，删除最老的
        if (backupFiles.length > 3) {
          const filesToDelete = backupFiles.slice(3) // 保留最新的3个，删除其余的
          console.log(`发现 ${backupFiles.length} 个备份文件，保留最新的3个，删除 ${filesToDelete.length} 个旧备份`)
          
          for (const fileToDelete of filesToDelete) {
            try {
              fs.unlinkSync(fileToDelete.path)
              console.log('已删除旧备份文件:', fileToDelete.name)
            } catch (deleteError) {
              console.warn('删除旧备份文件失败:', fileToDelete.name, deleteError.message)
              // 尝试使用sudo删除
              try {
                execSync(`sudo rm -f "${fileToDelete.path}"`, { timeout: 3000 })
                console.log('已删除旧备份文件（使用sudo）:', fileToDelete.name)
              } catch (sudoDeleteError) {
                console.warn('使用sudo删除旧备份文件也失败:', fileToDelete.name, sudoDeleteError.message)
              }
            }
          }
        } else {
          console.log(`当前有 ${backupFiles.length} 个备份文件，无需清理`)
        }
      } catch (cleanupError) {
        console.warn('清理旧备份文件失败:', cleanupError.message)
        // 清理失败不应该阻止主文件保存成功
      }
      
      // 验证文件是否写入成功
      if (!fs.existsSync(settingsFile)) {
        throw new Error('Settings file was not created after write')
      }
      
      // 验证文件内容
      const verifyContent = fs.readFileSync(settingsFile, 'utf8')
      if (!verifyContent || verifyContent.trim().length === 0) {
        throw new Error('Settings file is empty after write')
      }
      
      const verifySettings = JSON.parse(verifyContent)
      console.log('Settings file verified successfully')
    } catch (writeError) {
      console.error('Failed to write settings file:', writeError)
      console.error('Write error stack:', writeError.stack)
      console.error('Write error code:', writeError.code)
      console.error('Write error path:', writeError.path)
      throw new Error(`Failed to write settings file: ${writeError.message}`)
    }
    
    // 同步管理员邮箱到数据库（如果有更新）
    if (settings.general && settings.general.adminEmail) {
      try {
        const adminEmail = settings.general.adminEmail.trim()
        if (adminEmail && adminEmail.includes('@')) {
          // 更新数据库中的xm用户邮箱
          const mailDbPass = getMailDbPassword()
          execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -e "UPDATE mail_users SET email='${adminEmail}' WHERE username='xm';"`, { timeout: 5000 })
          console.log('管理员邮箱已同步到数据库:', adminEmail)
        }
      } catch (dbUpdateError) {
        console.warn('同步管理员邮箱到数据库失败:', dbUpdateError.message)
        // 不抛出异常，因为设置已经保存到文件
      }
    }

    // 应用系统设置（如果需要）
    try {
      console.log('Applying system settings...')
      applySystemSettings(settings)
      console.log('System settings applied successfully')
    } catch (applyError) {
      console.warn('Failed to apply some system settings:', applyError)
      // 不抛出异常，因为设置已经保存到文件
    }
    
    res.json({
      success: true,
      message: '系统设置已保存',
      timestamp: new Date().toISOString()
    })
    
  } catch (error) {
    console.error('System settings save error:', error)
    console.error('Error stack:', error.stack)
    console.error('Error name:', error.name)
    console.error('Error code:', error.code)
    
    // 将错误也记录到日志文件
    try {
      const errorLogLine = `[${new Date().toISOString()}] [SYSTEM_SETTINGS_SAVE_ERROR] User: ${user || 'unknown'}, Error: ${error.message}, Stack: ${error.stack}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLogLine)
    } catch (logError) {
      console.error('Failed to write error log:', logError.message)
    }
    
    res.status(500).json({
      success: false,
      error: 'Failed to save system settings',
      message: error.message
    })
  }
})

// 已删除通知邮件API - /api/notifications/test-email
// 已删除测试系统通知API - /api/notifications/test-system-alert
// 已删除发送系统通知邮件函数 - sendNotificationEmail

// 头像上传目录
const AVATAR_DIR = path.join(ROOT_DIR, 'uploads', 'avatars')

// 确保头像上传目录存在，处理权限问题
function ensureAvatarDir() {
  try {
    // 先检查目录是否存在
    if (!fs.existsSync(AVATAR_DIR)) {
      // 尝试直接创建
      try {
        fs.mkdirSync(AVATAR_DIR, { recursive: true, mode: 0o755 })
        console.log('Avatar directory created:', AVATAR_DIR)
      } catch (mkdirError) {
        // 如果直接创建失败，尝试使用sudo创建（xm用户应该有sudo权限）
        console.warn('Failed to create avatar directory directly, trying with sudo...')
        try {
          // 先创建父目录
          const parentDir = path.dirname(AVATAR_DIR)
          if (!fs.existsSync(parentDir)) {
            try {
              execSync(`sudo mkdir -p "${parentDir}"`, { timeout: 5000 })
              execSync(`sudo chmod 755 "${parentDir}"`, { timeout: 5000 })
              execSync(`sudo chown xm:xm "${parentDir}"`, { timeout: 5000 })
            } catch (parentError) {
              // 如果sudo也失败，尝试不使用sudo（可能父目录已存在）
              try {
                execSync(`mkdir -p "${parentDir}"`, { timeout: 5000 })
              } catch (e) {
                // 忽略错误，继续
              }
            }
          }
          // 创建avatars目录
          try {
            execSync(`sudo mkdir -p "${AVATAR_DIR}"`, { timeout: 5000 })
            execSync(`sudo chmod 755 "${AVATAR_DIR}"`, { timeout: 5000 })
            execSync(`sudo chown xm:xm "${AVATAR_DIR}"`, { timeout: 5000 })
            console.log('Avatar directory created with sudo:', AVATAR_DIR)
          } catch (sudoError) {
            // 如果sudo失败，尝试不使用sudo
            try {
              execSync(`mkdir -p "${AVATAR_DIR}"`, { timeout: 5000 })
              execSync(`chmod 755 "${AVATAR_DIR}"`, { timeout: 5000 })
              console.log('Avatar directory created without sudo:', AVATAR_DIR)
            } catch (noSudoError) {
              console.error('Failed to create avatar directory:', noSudoError.message)
              console.warn('Avatar upload may fail. Please create the directory manually as root:')
              console.warn(`  sudo mkdir -p ${AVATAR_DIR}`)
              console.warn(`  sudo chmod 755 ${AVATAR_DIR}`)
              console.warn(`  sudo chown xm:xm ${AVATAR_DIR}`)
            }
          }
        } catch (shellError) {
          console.error('Failed to create avatar directory:', shellError.message)
          console.warn('Please create the directory manually as root:')
          console.warn(`  sudo mkdir -p ${AVATAR_DIR}`)
          console.warn(`  sudo chmod 755 ${AVATAR_DIR}`)
          console.warn(`  sudo chown xm:xm ${AVATAR_DIR}`)
        }
      }
    } else {
      console.log('Avatar directory already exists:', AVATAR_DIR)
    }
    
    // 验证目录是否可写
    try {
      fs.accessSync(AVATAR_DIR, fs.constants.W_OK)
      console.log('Avatar directory is writable')
    } catch (accessError) {
      console.warn('Avatar directory exists but is not writable. Attempting to fix permissions...')
      try {
        // 尝试使用sudo修复权限
        try {
          execSync(`sudo chmod 755 "${AVATAR_DIR}"`, { timeout: 5000 })
          execSync(`sudo chown xm:xm "${AVATAR_DIR}"`, { timeout: 5000 })
          console.log('Avatar directory permissions fixed with sudo')
        } catch (sudoError) {
          // 如果sudo失败，尝试不使用sudo
          try {
            execSync(`chmod 755 "${AVATAR_DIR}"`, { timeout: 5000 })
            console.log('Avatar directory permissions fixed')
          } catch (chmodError) {
            console.error('Failed to fix avatar directory permissions:', chmodError.message)
            console.warn('Please fix permissions manually as root:')
            console.warn(`  sudo chmod 755 ${AVATAR_DIR}`)
            console.warn(`  sudo chown xm:xm ${AVATAR_DIR}`)
          }
        }
      } catch (error) {
        console.error('Error fixing permissions:', error.message)
      }
    }
  } catch (error) {
    console.error('Error ensuring avatar directory:', error.message)
    console.warn('Avatar upload functionality may not work properly')
    console.warn('Please create the directory manually as root:')
    console.warn(`  sudo mkdir -p ${AVATAR_DIR}`)
    console.warn(`  sudo chmod 755 ${AVATAR_DIR}`)
    console.warn(`  sudo chown xm:xm ${AVATAR_DIR}`)
  }
}

// 初始化头像目录
ensureAvatarDir()

// 静态文件服务 - 提供头像访问
app.use('/uploads', express.static(path.join(ROOT_DIR, 'uploads')))

// 头像上传API - 使用base64编码方式（简化实现）
app.post('/api/upload-avatar', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    const { avatar, username: uploadUsername } = req.body
    
    if (!avatar) {
      return res.status(400).json({
        success: false,
        error: '未找到上传的头像数据'
      })
    }
    
    // 解析base64图片数据
    const base64Data = avatar.replace(/^data:image\/\w+;base64,/, '')
    const buffer = Buffer.from(base64Data, 'base64')
    
    // 验证文件大小（最大5MB）
    if (buffer.length > 5 * 1024 * 1024) {
      return res.status(400).json({
        success: false,
        error: '图片大小不能超过 5MB'
      })
    }
    
    // 从base64数据中提取文件类型
    const matches = avatar.match(/^data:image\/(\w+);base64,/)
    const ext = matches ? matches[1] : 'png'
    const validExts = ['jpeg', 'jpg', 'png', 'gif', 'webp']
    if (!validExts.includes(ext.toLowerCase())) {
      return res.status(400).json({
        success: false,
        error: '不支持的图片格式，请上传 JPG、PNG、GIF 或 WebP 格式的图片'
      })
    }
    
    // 生成唯一文件名
    const uniqueName = `${uploadUsername || user}_${Date.now()}.${ext}`
    const filePath = path.join(AVATAR_DIR, uniqueName)
    
    // 确保目录存在
    if (!fs.existsSync(AVATAR_DIR)) {
      ensureAvatarDir()
    }
    
    // 验证目录可写
    try {
      fs.accessSync(AVATAR_DIR, fs.constants.W_OK)
    } catch (accessError) {
      console.error('Avatar directory is not writable:', accessError.message)
      return res.status(500).json({
        success: false,
        error: '头像上传目录不可写，请检查目录权限'
      })
    }
    
    // 保存文件
    try {
      fs.writeFileSync(filePath, buffer)
    } catch (writeError) {
      console.error('Failed to write avatar file:', writeError)
      return res.status(500).json({
        success: false,
        error: '文件保存失败，请检查目录权限'
      })
    }
    
    // 文件保存成功，返回URL
    const avatarUrl = `/uploads/avatars/${uniqueName}`
    
    // 更新数据库中的头像字段
    const targetUsername = uploadUsername || user
    const dbPass = getAppDbPassword()
    const escapedUsername = targetUsername.replace(/'/g, "''")
    const escapedAvatarUrl = avatarUrl.replace(/'/g, "''")
    const updateQuery = `mysql -u mailappuser --password="${dbPass.replace(/"/g, '\\"')}" mailapp -e "UPDATE app_users SET avatar='${escapedAvatarUrl}' WHERE username='${escapedUsername}';" 2>&1`
    try {
      execSync(updateQuery, { timeout: 5000 })
      
      // 记录操作日志
      const logLine = `[${timestamp}] [AVATAR_UPLOAD] User: ${user}, Avatar: ${avatarUrl}, IP: ${clientIP}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
      
      res.json({
        success: true,
        avatarUrl: avatarUrl
      })
    } catch (dbError) {
      console.error('Failed to update avatar in database:', dbError)
      // 即使数据库更新失败，也返回成功（文件已保存）
      res.json({
        success: true,
        avatarUrl: avatarUrl,
        warning: '头像已上传，但数据库更新可能失败'
      })
    }
  } catch (error) {
    console.error('Avatar upload error:', error)
    res.status(500).json({
      success: false,
      error: '头像上传失败',
      message: error.message
    })
  }
})

// 通知邮件测试API（已移动到正确位置，此处保留注释避免路由冲突）
// 注意：时区API在下面定义（第3716行）

// 测试系统通知API
app.post('/api/notifications/test-system-alert', auth, async (req, res) => {
  try {
    const { type = 'system', subject, message, to } = req.body
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'

    if (!subject || !message) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: subject and message'
      })
    }
    
    // 如果没有提供收件人，使用管理员邮箱
    let recipientEmail = to
    if (!recipientEmail) {
      // 从系统设置获取管理员邮箱
      try {
        const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
        if (fs.existsSync(settingsFile)) {
          const settingsData = fs.readFileSync(settingsFile, 'utf8')
          const settings = JSON.parse(settingsData)
          recipientEmail = settings.general?.adminEmail || 'xm@localhost'
        } else {
          recipientEmail = 'xm@localhost'
        }
      } catch (e) {
        recipientEmail = 'xm@localhost'
      }
    }
    
    // 验证邮箱格式
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(recipientEmail)) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email address format'
      })
    }
    
    // 记录通知邮件发送操作
    const logLine = `[${timestamp}] [NOTIFICATION_TEST_EMAIL] User: ${user}, Recipient: ${recipientEmail}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    // 解析收件人邮箱地址
    const emailParts = recipientEmail.split('@')
    if (emailParts.length !== 2) {
      return res.status(400).json({
        success: false,
        error: 'Invalid email format',
        message: '邮箱地址格式无效'
      })
    }
    
    const domain = emailParts[1]
    const username = emailParts[0]
    
    // 确保收件人邮箱存在于虚拟用户表中（Postfix需要）
    try {
      // 检查域名是否存在
      const domainCheck = execSync(
        `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name='${domain}' LIMIT 1;" 2>/dev/null || echo ""`,
        { encoding: 'utf8', timeout: 5000 }
      ).trim()
      
      let domainId = domainCheck
      
      // 如果域名不存在，创建它
      if (!domainId) {
        console.log(`Domain ${domain} not found, creating...`)
        execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -e "INSERT INTO virtual_domains (name) VALUES ('${domain}');" 2>/dev/null`,
          { timeout: 5000 }
        )
        domainId = execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name='${domain}' LIMIT 1;" 2>/dev/null`,
          { encoding: 'utf8', timeout: 5000 }
        ).trim()
        console.log(`Domain ${domain} created with ID: ${domainId}`)
      }
      
      // 检查用户是否存在
      const userCheck = execSync(
        `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_users WHERE email='${recipientEmail}' LIMIT 1;" 2>/dev/null || echo ""`,
        { encoding: 'utf8', timeout: 5000 }
      ).trim()

      // 如果用户不存在，创建它（使用默认密码，仅用于接收系统通知）
      if (!userCheck) {
        console.log(`User ${recipientEmail} not found, creating...`)
        // 生成一个默认密码（SHA512-CRYPT格式，仅用于接收邮件，不能用于登录）
        const defaultPassword = '$6$rounds=5000$defaultsalt$' + crypto.randomBytes(16).toString('hex')
        execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -e "INSERT INTO virtual_users (domain_id, email, password, active) VALUES (${domainId}, '${recipientEmail}', '${defaultPassword}', 1);" 2>/dev/null`,
          { timeout: 5000 }
        )
        console.log(`User ${recipientEmail} created for receiving system notifications`)
      }

      // 确保邮件目录存在（无论用户是否刚创建，都要检查并创建目录）
      console.log(`Ensuring mail directory exists for ${recipientEmail}`)
      const mailDir = `/var/vmail/${domain}/${username}/Maildir`
      const mailDirParent = `/var/vmail/${domain}/${username}`
      try {
        // 先创建父目录
        execSync(`mkdir -p ${mailDirParent}`, { timeout: 5000 })
        // 创建Maildir及其子目录
        execSync(`mkdir -p ${mailDir}/new ${mailDir}/cur ${mailDir}/tmp`, { timeout: 5000 })
        // 设置权限：父目录权限
        execSync(`chown -R vmail:mail ${mailDirParent}`, { timeout: 5000 })
        execSync(`chmod 700 ${mailDirParent}`, { timeout: 5000 })
        // Maildir目录权限
        execSync(`chmod 700 ${mailDir}`, { timeout: 5000 })
        execSync(`chmod 700 ${mailDir}/new ${mailDir}/cur ${mailDir}/tmp`, { timeout: 5000 })
        console.log(`Mail directory created/verified for ${recipientEmail}: ${mailDir}`)
      } catch (dirError) {
        console.error(`Failed to create mail directory for ${recipientEmail}:`, dirError.message)
        console.error(`Directory path: ${mailDir}`)
        // 记录详细错误到日志
        const errorLogLine = `[${new Date().toISOString()}] [MAIL_DIR_ERROR] Recipient: ${recipientEmail}, Dir: ${mailDir}, Error: ${dirError.message}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLogLine)
        // 不阻止邮件发送，但记录错误
      }
    } catch (dbError) {
      console.warn('Failed to ensure recipient exists in database:', dbError.message)
      // 继续尝试发送，如果失败会有更明确的错误信息
    }
    
    // 测试邮件必须使用 system@localhost 作为发件人
    const fromEmail = 'system@localhost'
    
    // 获取实时系统指标数据
    let systemMetrics = {}
    try {
      // CPU使用率
      try {
        const cpuInfo = execSync("top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'", { encoding: 'utf8', timeout: 5000 })
        systemMetrics.cpu = parseFloat(cpuInfo.trim()) || 0
      } catch (e) {
        systemMetrics.cpu = 0
      }
      
      // 内存使用率
      try {
        const memInfo = execSync("free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'", { encoding: 'utf8', timeout: 5000 })
        systemMetrics.memory = parseFloat(memInfo.trim()) || 0
      } catch (e) {
        systemMetrics.memory = 0
      }
      
      // 磁盘使用率
      try {
        const diskInfo = execSync("df -h / | tail -1 | awk '{print $5}' | sed 's/%//'", { encoding: 'utf8', timeout: 5000 })
        systemMetrics.disk = parseInt(diskInfo.trim()) || 0
      } catch (e) {
        systemMetrics.disk = 0
      }
      
      // 负载平均值
      try {
        const loadAvg = execSync("uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//'", { encoding: 'utf8', timeout: 5000 })
        systemMetrics.loadAverage = parseFloat(loadAvg.trim()) || 0
      } catch (e) {
        systemMetrics.loadAverage = 0
      }
      
      // 系统运行时间
      try {
        const uptime = execSync("uptime -p", { encoding: 'utf8', timeout: 3000 })
        systemMetrics.uptime = uptime.trim()
      } catch (e) {
        systemMetrics.uptime = '未知'
      }
      
      // 主机名
      try {
        const hostname = execSync("hostname", { encoding: 'utf8', timeout: 3000 })
        systemMetrics.hostname = hostname.trim()
      } catch (e) {
        systemMetrics.hostname = '未知'
      }
    } catch (metricsError) {
      console.warn('获取系统指标失败:', metricsError.message)
      systemMetrics = {
        cpu: 0,
        memory: 0,
        disk: 0,
        loadAverage: 0,
        uptime: '未知',
        hostname: '未知'
      }
    }
    
    // 获取通知阈值配置
    let thresholds = {
      cpu: { warning: 80, critical: 90 },
      memory: { warning: 80, critical: 90 },
      disk: { warning: 80, critical: 90 }
    }
    try {
      const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
      if (fs.existsSync(settingsFile)) {
        const settingsData = fs.readFileSync(settingsFile, 'utf8')
        const settings = JSON.parse(settingsData)
        if (settings.notifications && settings.notifications.thresholds) {
          thresholds = settings.notifications.thresholds
        }
      }
    } catch (e) {
      console.warn('读取阈值配置失败:', e.message)
    }
    
    // 使用Postfix SMTP发送邮件
    const transporter = nodemailer.createTransport({
      host: 'localhost',
      port: 25,
      secure: false,
      ignoreTLS: true,
      // 本地Postfix通常不需要认证
      auth: false
    })
    
    // 构建邮件内容，包含实时系统指标
    const getStatusColor = (value, warning, critical) => {
      if (value >= critical) return '#ef4444' // 红色
      if (value >= warning) return '#f59e0b' // 橙色
      return '#10b981' // 绿色
    }
    
    const cpuColor = getStatusColor(systemMetrics.cpu, thresholds.cpu.warning, thresholds.cpu.critical)
    const memoryColor = getStatusColor(systemMetrics.memory, thresholds.memory.warning, thresholds.memory.critical)
    const diskColor = getStatusColor(systemMetrics.disk, thresholds.disk.warning, thresholds.disk.critical)
    
    const htmlMessage = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; color: white; border-radius: 8px 8px 0 0;">
          <h2 style="margin: 0;">${subject}</h2>
        </div>
        <div style="background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px;">
          <p style="color: #374151; line-height: 1.6; margin: 0 0 20px 0;">${message.replace(/\n/g, '<br>')}</p>
          
          <!-- 系统指标数据 -->
          <div style="margin-top: 30px; padding: 20px; background: white; border-radius: 8px; border: 1px solid #e5e7eb;">
            <h3 style="color: #111827; font-size: 18px; margin: 0 0 20px 0; border-bottom: 2px solid #667eea; padding-bottom: 10px;">📊 实时系统指标</h3>
            
            <div style="margin-bottom: 15px;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                <span style="color: #6b7280; font-size: 14px;">CPU使用率</span>
                <span style="color: ${cpuColor}; font-weight: bold; font-size: 16px;">${systemMetrics.cpu.toFixed(1)}%</span>
              </div>
              <div style="background: #e5e7eb; height: 8px; border-radius: 4px; overflow: hidden;">
                <div style="background: ${cpuColor}; height: 100%; width: ${Math.min(systemMetrics.cpu, 100)}%; transition: width 0.3s;"></div>
              </div>
              <div style="margin-top: 5px; font-size: 12px; color: #9ca3af;">
                警告阈值: ${thresholds.cpu.warning}% | 严重阈值: ${thresholds.cpu.critical}%
              </div>
            </div>
            
            <div style="margin-bottom: 15px;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                <span style="color: #6b7280; font-size: 14px;">内存使用率</span>
                <span style="color: ${memoryColor}; font-weight: bold; font-size: 16px;">${systemMetrics.memory.toFixed(1)}%</span>
              </div>
              <div style="background: #e5e7eb; height: 8px; border-radius: 4px; overflow: hidden;">
                <div style="background: ${memoryColor}; height: 100%; width: ${Math.min(systemMetrics.memory, 100)}%; transition: width 0.3s;"></div>
              </div>
              <div style="margin-top: 5px; font-size: 12px; color: #9ca3af;">
                警告阈值: ${thresholds.memory.warning}% | 严重阈值: ${thresholds.memory.critical}%
              </div>
            </div>
            
            <div style="margin-bottom: 15px;">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 5px;">
                <span style="color: #6b7280; font-size: 14px;">磁盘使用率</span>
                <span style="color: ${diskColor}; font-weight: bold; font-size: 16px;">${systemMetrics.disk}%</span>
              </div>
              <div style="background: #e5e7eb; height: 8px; border-radius: 4px; overflow: hidden;">
                <div style="background: ${diskColor}; height: 100%; width: ${Math.min(systemMetrics.disk, 100)}%; transition: width 0.3s;"></div>
              </div>
              <div style="margin-top: 5px; font-size: 12px; color: #9ca3af;">
                警告阈值: ${thresholds.disk.warning}% | 严重阈值: ${thresholds.disk.critical}%
              </div>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-top: 20px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
              <div>
                <span style="color: #9ca3af; font-size: 12px;">系统负载</span>
                <div style="color: #111827; font-size: 16px; font-weight: bold; margin-top: 5px;">${systemMetrics.loadAverage.toFixed(2)}</div>
              </div>
              <div>
                <span style="color: #9ca3af; font-size: 12px;">运行时间</span>
                <div style="color: #111827; font-size: 16px; font-weight: bold; margin-top: 5px;">${systemMetrics.uptime}</div>
              </div>
            </div>
            
            <div style="margin-top: 15px; padding-top: 15px; border-top: 1px solid #e5e7eb;">
              <span style="color: #9ca3af; font-size: 12px;">主机名</span>
              <div style="color: #111827; font-size: 14px; font-weight: bold; margin-top: 5px;">${systemMetrics.hostname}</div>
            </div>
          </div>
          
          <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
            <p style="color: #6b7280; font-size: 12px; margin: 0;">此邮件由 XM邮件管理系统自动发送</p>
            <p style="color: #6b7280; font-size: 12px; margin: 5px 0 0 0;">发送时间: ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}</p>
          </div>
        </div>
      </div>
    `
    
    // 构建纯文本版本（包含系统指标）
    const textMessage = `${message}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 实时系统指标
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

CPU使用率: ${systemMetrics.cpu.toFixed(1)}% (警告阈值: ${thresholds.cpu.warning}%, 严重阈值: ${thresholds.cpu.critical}%)
内存使用率: ${systemMetrics.memory.toFixed(1)}% (警告阈值: ${thresholds.memory.warning}%, 严重阈值: ${thresholds.memory.critical}%)
磁盘使用率: ${systemMetrics.disk}% (警告阈值: ${thresholds.disk.warning}%, 严重阈值: ${thresholds.disk.critical}%)
系统负载: ${systemMetrics.loadAverage.toFixed(2)}
运行时间: ${systemMetrics.uptime}
主机名: ${systemMetrics.hostname}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
发送时间: ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}
此邮件由 XM邮件管理系统自动发送
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`
    
    // 邮件选项
    // 确保发件人地址格式正确
    const mailOptions = {
      from: `"XM邮件管理系统" <${fromEmail}>`,
      to: recipientEmail, // 使用前端传递的收件人地址
      subject: subject,
      text: textMessage,
      html: htmlMessage,
      // 添加额外的邮件头
      headers: {
        'X-Mailer': 'XM邮件管理系统',
        'X-Priority': '3'
      }
    }
    
    // 发送邮件
    console.log('Sending notification test email:', { from: mailOptions.from, to: mailOptions.to, subject: mailOptions.subject })
    
    // 检查Postfix服务是否运行
    let postfixRunning = false
    try {
      const postfixStatus = execSync('systemctl is-active --quiet postfix && echo "running" || echo "stopped"', { encoding: 'utf8', timeout: 3000 }).trim()
      console.log('Postfix service status:', postfixStatus)
      postfixRunning = (postfixStatus === 'running')
      if (!postfixRunning) {
        console.warn('Postfix service is not running')
        // 记录到日志
        const errorLogLine = `[${new Date().toISOString()}] [POSTFIX_NOT_RUNNING] Postfix服务未运行，无法发送邮件\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLogLine)
      }
    } catch (checkError) {
      console.warn('Failed to check Postfix status:', checkError.message)
    }
    
    // 验证邮件目录是否存在（domain和username已在上面定义）
    if (domain && username) {
      const mailDirCheck = `/var/vmail/${domain}/${username}/Maildir`
      try {
        if (!fs.existsSync(mailDirCheck)) {
          console.error(`邮件目录不存在: ${mailDirCheck}`)
          const errorLogLine = `[${new Date().toISOString()}] [MAIL_DIR_MISSING] 邮件目录不存在: ${mailDirCheck}\n`
          fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLogLine)
          
          // 尝试创建目录
          console.log(`尝试创建邮件目录: ${mailDirCheck}`)
          execSync(`mkdir -p ${mailDirCheck}/new ${mailDirCheck}/cur ${mailDirCheck}/tmp`, { timeout: 5000 })
          execSync(`chown -R vmail:mail /var/vmail/${domain}/${username}`, { timeout: 5000 })
          execSync(`chmod -R 700 /var/vmail/${domain}/${username}`, { timeout: 5000 })
          console.log(`邮件目录创建成功: ${mailDirCheck}`)
        } else {
          console.log(`邮件目录存在: ${mailDirCheck}`)
        }
      } catch (dirCheckError) {
        console.error(`检查/创建邮件目录失败: ${dirCheckError.message}`)
        const errorLogLine = `[${new Date().toISOString()}] [MAIL_DIR_ERROR] 邮件目录检查失败: ${dirCheckError.message}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLogLine)
      }
    }
    
    // 如果Postfix未运行，直接返回错误
    if (!postfixRunning) {
      clearTimeout(timeout)
      if (!res.headersSent) {
        return res.status(500).json({
          success: false,
          error: 'Postfix service is not running',
          message: 'Postfix服务未运行，请先启动Postfix服务：systemctl start postfix'
        })
      }
      return
    }
    
    // 设置超时处理
    const timeout = setTimeout(() => {
      console.error('Notification email send timeout')
      if (!res.headersSent) {
        res.status(500).json({
          success: false,
          error: 'Failed to send notification email',
          message: '邮件发送超时，请检查Postfix服务状态和邮件队列'
        })
      }
    }, 30000) // 30秒超时
    
    transporter.sendMail(mailOptions, (error, info) => {
      clearTimeout(timeout)
      if (error) {
        console.error('Notification email send error:', error)
        console.error('Error details:', {
          code: error.code,
          command: error.command,
          response: error.response,
          responseCode: error.responseCode,
          errno: error.errno,
          syscall: error.syscall,
          address: error.address,
          port: error.port
        })
        
        // 将错误记录到日志文件
        try {
          const errorLogLine = `[${new Date().toISOString()}] [NOTIFICATION_EMAIL_ERROR] User: ${user}, Recipient: ${recipientEmail}, Error: ${error.message}, Code: ${error.code}, Response: ${error.response}\n`
          fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLogLine)
        } catch (logError) {
          console.error('Failed to write error log:', logError.message)
        }
        
        if (!res.headersSent) {
          // 提供更详细的错误信息
          let errorMessage = error.message || '邮件发送失败，请检查Postfix配置'
          if (error.code === 'ECONNREFUSED') {
            errorMessage = '无法连接到Postfix服务（端口25），请检查Postfix服务是否运行'
          } else if (error.code === 'ETIMEDOUT') {
            errorMessage = '连接Postfix服务超时，请检查Postfix服务状态'
          } else if (error.responseCode === 550) {
            errorMessage = 'Postfix拒绝发送邮件，请检查发件人地址是否在虚拟域中'
          } else if (error.responseCode === 554) {
            errorMessage = 'Postfix拒绝发送邮件，可能是收件人地址无效或不在虚拟域中'
          }
          
          res.status(500).json({
            success: false,
            error: 'Failed to send notification email',
            message: errorMessage
          })
        }
      } else {
        console.log('Notification email sent successfully:', info.messageId)
        
        // 将邮件存储到数据库，以便前端可以立即看到
        try {
          const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
          const messageId = info.messageId || `<${Date.now()}-${Math.random().toString(36).substring(7)}@mail-system>`
          // 确保使用 system@localhost 作为发件人地址
          const fromAddr = 'system@localhost'
          const toAddr = recipientEmail // 使用前端传递的收件人地址
          const subjectText = mailOptions.subject
          const bodyText = mailOptions.text
          const htmlBody = mailOptions.html
          const sizeBytes = Buffer.byteLength(bodyText, 'utf8')
          
          // 构建邮件头信息
          const headers = JSON.stringify({
            'Message-ID': messageId,
            'From': mailOptions.from,
            'To': toAddr,
            'Subject': subjectText,
            'Date': new Date().toUTCString(),
            'X-Mailer': 'XM邮件管理系统',
            'X-Priority': '3'
          })
          
          // 调用 mail_db.sh store 存储邮件（简化处理，避免特殊字符）
          console.log('Attempting to store notification email to database...')
          const storeCommand = `bash "${mailDbScript}" store "${messageId}" "${fromAddr}" "${toAddr}" "${subjectText}" "${bodyText}" "" "inbox" "${sizeBytes}" "" "" "{}" "0" "0"`
          console.log('Store command:', storeCommand)
          execSync(storeCommand, { timeout: 10000, stdio: 'inherit' })
          console.log('Notification email stored to database:', messageId)
        } catch (storeError) {
          console.warn('Failed to store notification email to database:', storeError.message)
          // 不阻止响应，因为邮件已经发送成功
        }
        
        if (!res.headersSent) {
          res.json({
            success: true,
            messageId: info.messageId,
            message: '通知邮件发送成功'
          })
        }
      }
    })
    
  } catch (error) {
    console.error('Notification email API error:', error)
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error.message
    })
  }
})

// 测试系统通知API
app.post('/api/notifications/test-system-alert', auth, async (req, res) => {
  try {
    const { type = 'system', subject, message } = req.body

    if (!subject || !message) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: subject and message'
      })
    }

    const success = await sendNotificationEmail(type, subject, message, {
      priority: 'medium',
      test: true
    })

    res.json({
      success: true,
      message: success ? '系统通知邮件发送成功' : '系统通知邮件发送失败或已禁用',
      sent: success
    })

  } catch (error) {
    console.error('Test system alert error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to send test system alert',
      message: error.message
    })
  }
})

// 发送系统通知邮件（供系统内部调用）
function sendNotificationEmail(type, subject, message, options = {}) {
  return new Promise((resolve, reject) => {
    try {
      // 读取系统设置
      const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
      if (!fs.existsSync(settingsFile)) {
        console.warn('System settings file not found, skipping notification email')
        resolve(false)
        return
      }
      
      const settingsData = fs.readFileSync(settingsFile, 'utf8')
      const settings = JSON.parse(settingsData)
      
      // 检查通知设置
      if (!settings.notifications || !settings.notifications.emailAlerts) {
        console.log('Email alerts disabled, skipping notification email')
        resolve(false)
        return
      }
      
      // 检查特定类型的通知是否启用
      const notificationTypeMap = {
        'security': 'securityAlerts',
        'maintenance': 'maintenanceAlerts',
        'system': 'systemAlerts'
      }
      
      const notificationKey = notificationTypeMap[type] || 'systemAlerts'
      if (settings.notifications[notificationKey] === false) {
        console.log(`${type} alerts disabled, skipping notification email`)
        resolve(false)
        return
      }
      
      // 获取收件人邮箱
      const toEmail = options.to || settings.notifications.alertEmail || settings.general?.adminEmail
      if (!toEmail) {
        console.warn('No alert email configured, skipping notification email')
        resolve(false)
        return
      }
      
      // 确保收件人邮箱存在于虚拟用户表中（Postfix需要）
      try {
        const emailParts = toEmail.split('@')
        const domain = emailParts[1]
        const username = emailParts[0]
        
        // 检查域名是否存在
        const domainCheck = execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name='${domain}' LIMIT 1;" 2>/dev/null || echo ""`,
          { encoding: 'utf8', timeout: 5000 }
        ).trim()
        
        let domainId = domainCheck
        
        // 如果域名不存在，创建它
        if (!domainId) {
          console.log(`Domain ${domain} not found, creating...`)
          execSync(
            `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -e "INSERT INTO virtual_domains (name) VALUES ('${domain}');" 2>/dev/null`,
            { timeout: 5000 }
          )
          domainId = execSync(
            `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name='${domain}' LIMIT 1;" 2>/dev/null`,
            { encoding: 'utf8', timeout: 5000 }
          ).trim()
          console.log(`Domain ${domain} created with ID: ${domainId}`)
        }
        
        // 检查用户是否存在
        const userCheck = execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_users WHERE email='${toEmail}' LIMIT 1;" 2>/dev/null || echo ""`,
          { encoding: 'utf8', timeout: 5000 }
        ).trim()
        
        // 如果用户不存在，创建它（使用默认密码，仅用于接收系统通知）
        if (!userCheck) {
          console.log(`User ${toEmail} not found, creating...`)
          // 生成一个默认密码（SHA512-CRYPT格式，仅用于接收邮件，不能用于登录）
          const defaultPassword = '$6$rounds=5000$defaultsalt$' + crypto.randomBytes(16).toString('hex')
          execSync(
            `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -e "INSERT INTO virtual_users (domain_id, email, password, active) VALUES (${domainId}, '${toEmail}', '${defaultPassword}', 1);" 2>/dev/null`,
            { timeout: 5000 }
          )
          console.log(`User ${toEmail} created for receiving system notifications`)
          
          // 确保邮件目录存在
          const mailDir = `/var/vmail/${domain}/${username}/Maildir`
          try {
            execSync(`mkdir -p ${mailDir}/new ${mailDir}/cur ${mailDir}/tmp`, { timeout: 5000 })
            execSync(`chown -R vmail:mail /var/vmail/${domain}`, { timeout: 5000 })
            execSync(`chmod -R 700 /var/vmail/${domain}`, { timeout: 5000 })
          } catch (dirError) {
            console.warn(`Failed to create mail directory for ${toEmail}:`, dirError.message)
          }
        }
      } catch (dbError) {
        console.warn('Failed to ensure recipient exists in database:', dbError.message)
        // 继续尝试发送，如果失败会有更明确的错误信息
      }
      
      // 获取发件人邮箱
      const fromEmail = settings.general?.adminEmail || settings.notifications.alertEmail || 'system@localhost'
      
      // 使用Postfix SMTP发送邮件
      const transporter = nodemailer.createTransport({
        host: 'localhost',
        port: 25,
        secure: false,
        ignoreTLS: true,
        // 本地Postfix通常不需要认证
        auth: false
      })
      
      // 构建邮件内容
      const htmlMessage = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; color: white; border-radius: 8px 8px 0 0;">
            <h2 style="margin: 0;">${subject}</h2>
          </div>
          <div style="background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px;">
            <p style="color: #374151; line-height: 1.6; margin: 0 0 20px 0;">${message.replace(/\n/g, '<br>')}</p>
            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #e5e7eb;">
              <p style="color: #6b7280; font-size: 12px; margin: 0;">此邮件由 XM邮件管理系统自动发送</p>
              <p style="color: #6b7280; font-size: 12px; margin: 5px 0 0 0;">发送时间: ${new Date().toLocaleString('zh-CN', { timeZone: 'Asia/Shanghai' })}</p>
            </div>
          </div>
        </div>
      `
      
      // 邮件选项
      // 确保发件人地址格式正确
      const mailOptions = {
        from: `"XM邮件管理系统" <${fromEmail}>`,
        to: toEmail,
        subject: subject,
        text: message,
        html: htmlMessage,
        // 添加额外的邮件头
        headers: {
          'X-Mailer': 'XM邮件管理系统',
          'X-Priority': '3'
        }
      }
      
      // 发送邮件
      const timeout = setTimeout(() => {
        console.error('Notification email send timeout')
        reject(new Error('邮件发送超时'))
      }, 30000) // 30秒超时
      
      transporter.sendMail(mailOptions, (error, info) => {
        clearTimeout(timeout)
        if (error) {
          console.error('Notification email send error:', error)
          console.error('Error details:', {
            code: error.code,
            command: error.command,
            response: error.response,
            responseCode: error.responseCode
          })
          reject(error)
        } else {
          console.log('Notification email sent successfully:', info.messageId)
          
          // 将邮件存储到数据库，以便前端可以立即看到
          try {
            const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
            const messageId = info.messageId || `<${Date.now()}-${Math.random().toString(36).substring(7)}@mail-system>`
            const fromAddr = mailOptions.from.replace(/^.*<(.+)>.*$/, '$1').replace(/^"(.+)"\s*<(.+)>.*$/, '$2')
            const toAddr = toEmail
            const subjectText = mailOptions.subject
            const bodyText = mailOptions.text
            const htmlBody = mailOptions.html
            const sizeBytes = Buffer.byteLength(bodyText, 'utf8')
            
            // 构建邮件头信息
            const headers = JSON.stringify({
              'Message-ID': messageId,
              'From': mailOptions.from,
              'To': toAddr,
              'Subject': subjectText,
              'Date': new Date().toUTCString(),
              'X-Mailer': 'XM邮件管理系统',
              'X-Priority': '3'
            })
            
            // 调用 mail_db.sh store 存储邮件
            execSync(
              `bash "${mailDbScript}" store "${messageId}" "${fromAddr}" "${toAddr}" "${subjectText}" "${bodyText}" "${htmlBody}" "inbox" "${sizeBytes}" "" "" "${headers}" "0" "0"`,
              { timeout: 10000, stdio: 'ignore' }
            )
            console.log('Notification email stored to database:', messageId)
          } catch (storeError) {
            console.warn('Failed to store notification email to database:', storeError.message)
            // 不阻止响应，因为邮件已经发送成功
          }
          
          resolve(true)
        }
      })
      
    } catch (error) {
      console.error('Send notification email error:', error)
      reject(error)
    }
  })
}

// 获取可用时区列表
app.get('/api/timezones', auth, (req, res) => {
  // 默认时区列表（作为后备方案）
  const defaultTimezones = {
    'Asia': ['Asia/Shanghai', 'Asia/Tokyo', 'Asia/Hong_Kong', 'Asia/Singapore', 'Asia/Seoul', 'Asia/Dubai', 'Asia/Kolkata'],
    'Europe': ['Europe/London', 'Europe/Paris', 'Europe/Berlin', 'Europe/Moscow', 'Europe/Rome', 'Europe/Madrid'],
    'America': ['America/New_York', 'America/Chicago', 'America/Denver', 'America/Los_Angeles', 'America/Toronto', 'America/Sao_Paulo'],
    'Australia': ['Australia/Sydney', 'Australia/Melbourne', 'Australia/Perth'],
    'UTC': ['UTC']
  }
  
  try {
    let timestamp = new Date().toISOString()
    let clientIP = 'unknown'
    let user = 'unknown'
    
    try {
      timestamp = new Date().toISOString()
      clientIP = getRealClientIP(req)
      try {
        if (req.headers.authorization) {
          user = Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0]
        }
      } catch (authError) {
        console.warn('Failed to parse authorization header:', authError.message)
      }
    
      // 记录时区查询操作（失败不影响主流程）
      try {
    const logLine = `[${timestamp}] [TIMEZONES_GET] User: ${user}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
      } catch (logError) {
        console.warn('Failed to write timezone log:', logError.message)
      }
    } catch (initError) {
      console.warn('Failed to initialize timezone request:', initError.message)
    }
    
    // 获取可用时区列表
  let timezones = []
  try {
    const timezonesOutput = execSync('timedatectl list-timezones', { 
      encoding: 'utf8', 
      timeout: 10000,
      maxBuffer: 1024 * 1024 // 1MB buffer for large timezone lists
    }).trim()
    timezones = timezonesOutput ? timezonesOutput.split('\n').filter(tz => tz && tz.trim()) : []
  } catch (cmdError) {
    console.error('Failed to execute timedatectl list-timezones:', cmdError.message || cmdError)
    // 如果命令失败，使用默认时区列表
    timezones = Object.values(defaultTimezones).flat()
  }
  
  // 如果时区列表为空，使用默认列表
  if (timezones.length === 0) {
    console.warn('Timezone list is empty, using default timezones')
    timezones = Object.values(defaultTimezones).flat()
  }
    
    // 按地区分组时区
    const timezoneGroups = {}
  try {
    timezones.forEach(tz => {
      const trimmedTz = tz.trim()
      if (!trimmedTz) return
      
      const parts = trimmedTz.split('/')
      if (parts.length >= 2) {
        const region = parts[0]
        if (!timezoneGroups[region]) {
          timezoneGroups[region] = []
        }
        if (!timezoneGroups[region].includes(trimmedTz)) {
          timezoneGroups[region].push(trimmedTz)
      }
      } else if (trimmedTz === 'UTC') {
        // 处理 UTC 时区
        if (!timezoneGroups['UTC']) {
          timezoneGroups['UTC'] = []
        }
        if (!timezoneGroups['UTC'].includes('UTC')) {
          timezoneGroups['UTC'].push('UTC')
        }
      }
    })
  } catch (groupError) {
    console.error('Failed to group timezones:', groupError.message)
    // 如果分组失败，使用默认分组
    Object.assign(timezoneGroups, defaultTimezones)
  }
  
  // 确保至少有一些时区
  if (Object.keys(timezoneGroups).length === 0) {
    console.warn('No timezone groups found, using default timezones')
    Object.assign(timezoneGroups, defaultTimezones)
  }
    
    // 获取当前时区（实时获取系统当前时区）
  let currentTimezone = 'Asia/Shanghai'
  try {
    const currentTzOutput = execSync('timedatectl show --property=Timezone --value', { 
      encoding: 'utf8', 
      timeout: 3000 
    }).trim()
    if (currentTzOutput) {
      currentTimezone = currentTzOutput
    }
  } catch (cmdError) {
    console.warn('Failed to get current timezone:', cmdError.message || cmdError)
    // 如果获取失败，使用默认值
    currentTimezone = 'Asia/Shanghai'
  }
  
    console.log('Current system timezone:', currentTimezone)
  console.log('Timezone groups count:', Object.keys(timezoneGroups).length)
  console.log('Total timezones:', Object.values(timezoneGroups).reduce((sum, arr) => sum + arr.length, 0))
    
    // 确保返回成功响应
    try {
    res.json({
      success: true,
      timezones: timezoneGroups,
      currentTimezone: currentTimezone,
      timestamp: timestamp
    })
    } catch (jsonError) {
      console.error('Failed to send JSON response:', jsonError.message)
      // 如果 JSON 发送失败，尝试发送基本响应
      try {
        res.status(200).json({
          success: true,
          timezones: defaultTimezones,
          currentTimezone: 'Asia/Shanghai',
          timestamp: timestamp
        })
      } catch (fallbackError) {
        console.error('Failed to send fallback response:', fallbackError.message)
        // 最后的保障：发送最简单的响应
        if (!res.headersSent) {
          res.status(200).send(JSON.stringify({
            success: true,
            timezones: defaultTimezones,
            currentTimezone: 'Asia/Shanghai'
          }))
        }
      }
    }
  } catch (error) {
    // 最后的错误处理保障
    console.error('Get timezones error (outer catch):', error)
    try {
      if (!res.headersSent) {
        res.status(200).json({
          success: true,
          timezones: defaultTimezones,
          currentTimezone: 'Asia/Shanghai',
          timestamp: new Date().toISOString(),
          error: 'Some operations failed, but returning default timezones',
      message: error.message
    })
      }
    } catch (finalError) {
      console.error('Failed to send error response:', finalError.message)
      // 如果连错误响应都发送不了，至少尝试发送状态码
      if (!res.headersSent) {
        res.status(500).send('Internal Server Error')
      }
    }
  }
})

// 应用系统设置的辅助函数
function applySystemSettings(settings) {
  try {
    // 应用时区设置
    if (settings.general && settings.general.timezone) {
      try {
        console.log(`Attempting to set timezone to: ${settings.general.timezone}`)
        // 使用 sudo 以确保在服务用户下也能成功
        execSync(`sudo timedatectl set-timezone ${settings.general.timezone}`, { timeout: 8000 })
        console.log(`Timezone set to: ${settings.general.timezone}`)
        
        // 等待一下让系统生效
        setTimeout(() => {
          try {
            // 验证时区设置是否成功
            const currentTimezone = execSync('timedatectl show --property=Timezone --value', { encoding: 'utf8', timeout: 3000 }).trim()
            if (currentTimezone === settings.general.timezone) {
              console.log('Timezone successfully updated to:', currentTimezone)
            } else {
              console.warn(`Timezone update failed. Expected: ${settings.general.timezone}, Current: ${currentTimezone}`)
            }
          } catch (verifyError) {
            console.warn('Failed to verify timezone:', verifyError.message)
          }
        }, 1000)
      } catch (error) {
        // 时区设置失败不应该阻止整个保存过程
        console.warn('Failed to set timezone:', error.message)
        // 不再抛出异常，只记录警告
      }
    }
    
    // 应用邮件设置
    if (settings.mail) {
      let postfixUpdated = false
      
      // 更新Postfix配置
      if (settings.mail.maxMessageSize) {
        try {
          execSync(`sudo postconf -e "message_size_limit = ${settings.mail.maxMessageSize * 1024 * 1024}"`, { timeout: 8000 })
          console.log(`Message size limit set to: ${settings.mail.maxMessageSize}MB`)
          postfixUpdated = true
        } catch (error) {
          console.warn('Failed to set message size limit:', error.message)
        }
      }
      
      // 更新邮箱大小限制
      if (settings.mail.maxMailboxSize) {
        try {
          execSync(`sudo postconf -e "mailbox_size_limit = ${settings.mail.maxMailboxSize * 1024 * 1024}"`, { timeout: 8000 })
          console.log(`Mailbox size limit set to: ${settings.mail.maxMailboxSize}MB`)
          postfixUpdated = true
        } catch (error) {
          console.warn('Failed to set mailbox size limit:', error.message)
        }
      }
      
      // 如果Postfix配置有更新，重新加载服务
      if (postfixUpdated) {
        try {
          execSync('sudo systemctl reload postfix', { timeout: 8000 })
          console.log('Postfix configuration reloaded successfully')
          try {
            const applied = execSync('postconf -n | grep -E "message_size_limit|mailbox_size_limit"', { encoding: 'utf8', timeout: 5000 })
            console.log('Postfix limits after apply:\n' + applied)
          } catch (readErr) {
            console.warn('Unable to read back Postfix limits:', readErr.message)
          }
        } catch (error) {
          console.warn('Failed to reload Postfix:', error.message)
        }
      }
    }
    
    // 应用安全设置
    if (settings.security) {
      // 更新会话超时设置
      if (settings.security.sessionTimeout) {
        try {
          // 更新Apache配置中的会话超时
          const apacheConfig = '/etc/httpd/conf.d/mail-ops.conf'
          if (fs.existsSync(apacheConfig)) {
            let configContent = fs.readFileSync(apacheConfig, 'utf8')
            
            // 更新或添加会话超时配置
            const sessionTimeoutMinutes = settings.security.sessionTimeout
            const sessionTimeoutSeconds = sessionTimeoutMinutes * 60
            
            // 更新或添加 Timeout 指令
            if (configContent.includes('Timeout')) {
              configContent = configContent.replace(/Timeout\s+\d+/, `Timeout ${sessionTimeoutSeconds}`)
            } else {
              configContent += `\nTimeout ${sessionTimeoutSeconds}\n`
            }
            
            // 更新或添加会话超时配置
            if (configContent.includes('SessionTimeout')) {
              configContent = configContent.replace(/SessionTimeout\s+\d+/, `SessionTimeout ${sessionTimeoutSeconds}`)
            } else {
              configContent += `\nSessionTimeout ${sessionTimeoutSeconds}\n`
            }
            
            fs.writeFileSync(apacheConfig, configContent)
            console.log(`Session timeout set to: ${sessionTimeoutMinutes} minutes`)
          }
        } catch (error) {
          console.warn('Failed to set session timeout:', error.message)
        }
      }
      
      // 更新SSL/HTTPS设置
      if (settings.security && (settings.security.enableSSL !== undefined || settings.security.forceHTTPS !== undefined)) {
        try {
          const apacheConfig = '/etc/httpd/conf.d/mail-ops.conf'
          if (fs.existsSync(apacheConfig)) {
            // 先保存原始配置内容，以便测试失败时恢复
            const originalContent = fs.readFileSync(apacheConfig, 'utf8')
            let configContent = originalContent
            
            // 读取当前系统设置以获取完整的安全配置
            const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
            let currentSettings = {}
            if (fs.existsSync(settingsFile)) {
              try {
                currentSettings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'))
              } catch (e) {
                console.warn('Failed to read current settings:', e.message)
              }
            }
            
            // 确定是否启用HTTPS重定向
            // 注意：HTTP跳转HTTPS应该由用户通过前端"启用HTTP跳转HTTPS"按钮来配置
            // 这里不再根据forceHTTPS自动配置HTTP跳转，避免默认开启
            // HTTP跳转配置应该通过 cert_setup.sh enable-http-redirect 脚本来完成
            // 因此这里禁用自动应用HTTP跳转的逻辑
            const enableSSL = settings.security.enableSSL !== undefined 
              ? settings.security.enableSSL 
              : (currentSettings.security?.enableSSL !== undefined ? currentSettings.security.enableSSL : true)
            const forceHTTPS = settings.security.forceHTTPS !== undefined 
              ? settings.security.forceHTTPS 
              : (currentSettings.security?.forceHTTPS !== undefined ? currentSettings.security.forceHTTPS : false)
            
            // 不再自动应用HTTP跳转，由用户通过前端按钮手动启用
            // const shouldRedirect = enableSSL && forceHTTPS
            const shouldRedirect = false  // 禁用自动应用HTTP跳转
            
            if (shouldRedirect) {
              // 启用SSL重定向
              // 先移除旧的HTTPS重定向规则（如果存在），但保留LocationMatch中的RewriteEngine
              configContent = configContent.replace(/\s*# HTTPS重定向\s*\n/gi, '')
              configContent = configContent.replace(/\s*RewriteCond %{HTTPS} off\s*\n/gi, '')
              configContent = configContent.replace(/\s*RewriteRule \^\(\.\*\)\$ https:\/\/%{HTTP_HOST}%{REQUEST_URI} \[L,R=301\]\s*\n/gi, '')
              
              // 在VirtualHost开始处添加HTTPS重定向规则（在LocationMatch之前）
              if (configContent.includes('<VirtualHost *:80>')) {
                // 在VirtualHost标签后、第一个Location或Directory之前添加
                if (!configContent.includes('RewriteCond %{HTTPS} off')) {
                  configContent = configContent.replace(
                    /(<VirtualHost \*:80>\s*\n)/,
                    '$1    # HTTPS重定向\n    RewriteEngine On\n    RewriteCond %{HTTPS} off\n    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n\n'
                  )
                }
              } else {
                // 如果没有找到VirtualHost块，在文件开头添加
                configContent = '# HTTPS重定向\nRewriteEngine On\nRewriteCond %{HTTPS} off\nRewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]\n\n' + configContent
              }
              
              console.log('HTTPS redirect enabled (SSL enabled and forceHTTPS enabled)')
            } else {
              // 禁用SSL重定向 - 只移除HTTPS相关的重定向规则，保留LocationMatch中的RewriteEngine
              configContent = configContent.replace(/\s*# HTTPS重定向\s*\n/gi, '')
              configContent = configContent.replace(/\s*RewriteCond %{HTTPS} off\s*\n/gi, '')
              configContent = configContent.replace(/\s*RewriteRule \^\(\.\*\)\$ https:\/\/%{HTTP_HOST}%{REQUEST_URI} \[L,R=301\]\s*\n/gi, '')
              // 注意：不删除所有RewriteEngine On，因为LocationMatch中可能还需要它
              // 只删除单独出现的RewriteEngine On（后面没有其他规则，且是HTTPS重定向相关的）
              configContent = configContent.replace(/\s*RewriteEngine On\s*\n\s*RewriteCond %{HTTPS} off\s*\n/gi, '')
              console.log('HTTPS redirect disabled')
            }
            
            // 测试Apache配置
            try {
              // 先写入临时文件测试
              const tempConfig = apacheConfig + '.tmp'
              fs.writeFileSync(tempConfig, configContent)
              execSync('httpd -t', { timeout: 5000 })
              // 测试通过，写入正式文件
              fs.writeFileSync(apacheConfig, configContent)
              fs.unlinkSync(tempConfig)
              console.log('Apache configuration test passed and updated')
            } catch (testError) {
              // 如果测试失败，恢复原配置
              if (fs.existsSync(apacheConfig + '.tmp')) {
                fs.unlinkSync(apacheConfig + '.tmp')
              }
              fs.writeFileSync(apacheConfig, originalContent)
              console.warn('Apache configuration test failed, restored original config:', testError.message)
              throw new Error('Apache configuration test failed: ' + testError.message)
            }
          }
        } catch (error) {
          console.warn('Failed to configure SSL/HTTPS settings:', error.message)
        }
      }
      
      // 更新密码策略设置
      if (settings.security.passwordMinLength) {
        try {
          // 更新系统密码策略
          const pamConfig = '/etc/security/pwquality.conf'
          if (fs.existsSync(pamConfig)) {
            let configContent = fs.readFileSync(pamConfig, 'utf8')
            
            // 更新最小密码长度
            if (configContent.includes('minlen')) {
              configContent = configContent.replace(/minlen\s*=\s*\d+/, `minlen = ${settings.security.passwordMinLength}`)
            } else {
              configContent += `\nminlen = ${settings.security.passwordMinLength}\n`
            }
            
            // 更新特殊字符要求
            if (settings.security.requireSpecialChars) {
              // 启用特殊字符要求：设置dcredit、ucredit、lcredit、ocredit为-1（要求至少1个）
              if (configContent.includes('dcredit')) {
                configContent = configContent.replace(/dcredit\s*=\s*[-\d]+/, 'dcredit = -1')
              } else {
                configContent += '\ndcredit = -1\n'
              }
              if (configContent.includes('ucredit')) {
                configContent = configContent.replace(/ucredit\s*=\s*[-\d]+/, 'ucredit = -1')
              } else {
                configContent += '\nucredit = -1\n'
              }
              if (configContent.includes('lcredit')) {
                configContent = configContent.replace(/lcredit\s*=\s*[-\d]+/, 'lcredit = -1')
              } else {
                configContent += '\nlcredit = -1\n'
              }
              if (configContent.includes('ocredit')) {
                configContent = configContent.replace(/ocredit\s*=\s*[-\d]+/, 'ocredit = -1')
              } else {
                configContent += '\nocredit = -1\n'
              }
            } else {
              // 关闭特殊字符要求：移除或设置为0（不要求）
              if (configContent.includes('dcredit')) {
                configContent = configContent.replace(/dcredit\s*=\s*[-\d]+/, 'dcredit = 0')
              }
              if (configContent.includes('ucredit')) {
                configContent = configContent.replace(/ucredit\s*=\s*[-\d]+/, 'ucredit = 0')
              }
              if (configContent.includes('lcredit')) {
                configContent = configContent.replace(/lcredit\s*=\s*[-\d]+/, 'lcredit = 0')
              }
              if (configContent.includes('ocredit')) {
                configContent = configContent.replace(/ocredit\s*=\s*[-\d]+/, 'ocredit = 0')
              }
            }
            
            fs.writeFileSync(pamConfig, configContent)
            console.log(`Password policy updated: min length ${settings.security.passwordMinLength}`)
          }
        } catch (error) {
          console.warn('Failed to update password policy:', error.message)
        }
      }
      
      // 更新登录尝试限制
      if (settings.security.maxLoginAttempts) {
        try {
          // 更新PAM配置以限制登录尝试
          const pamConfig = '/etc/pam.d/httpd'
          if (fs.existsSync(pamConfig)) {
            let configContent = fs.readFileSync(pamConfig, 'utf8')
            
            // 添加或更新登录尝试限制
            const maxAttempts = settings.security.maxLoginAttempts
            if (configContent.includes('pam_tally2')) {
              configContent = configContent.replace(/pam_tally2.*deny=\d+/, `pam_tally2 deny=${maxAttempts}`)
            } else {
              configContent += `\nauth required pam_tally2 deny=${maxAttempts} onerr=fail unlock_time=600\n`
            }
            
            fs.writeFileSync(pamConfig, configContent)
            console.log(`Login attempt limit set to: ${maxAttempts}`)
          }
        } catch (error) {
          console.warn('Failed to update login attempt limit:', error.message)
        }
      }
    }
    
    // 重启相关服务以应用设置
    try {
      execSync('systemctl reload postfix', { timeout: 10000 })
      console.log('Postfix configuration reloaded')
    } catch (error) {
      console.warn('Failed to reload Postfix:', error.message)
    }
    
    // 重启Apache以应用安全设置
    try {
      execSync('systemctl reload httpd', { timeout: 10000 })
      console.log('Apache configuration reloaded')
    } catch (error) {
      console.warn('Failed to reload Apache:', error.message)
    }
    
    // 如果修改了PAM配置，重启相关服务
    if (settings.security && (settings.security.passwordMinLength || settings.security.maxLoginAttempts)) {
      try {
        execSync('systemctl restart httpd', { timeout: 15000 })
        console.log('Apache restarted to apply security settings')
      } catch (error) {
        console.warn('Failed to restart Apache for security settings:', error.message)
      }
    }
    
  } catch (error) {
    console.error('Error applying system settings:', error)
    throw error
  }
}

// 获取DNS配置状态
app.get('/api/dns/status', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录DNS状态查询
    const logLine = `[${timestamp}] [DNS_STATUS] User: ${user}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 检查Bind服务状态
    let bindStatus = 'not_installed'
    try {
      const bindCheck = execSync('systemctl is-active named', { encoding: 'utf8', timeout: 3000 })
      bindStatus = bindCheck.trim() === 'active' ? 'running' : 'stopped'
    } catch (error) {
      // Bind未安装或未运行
    }
    
    // 检查DNS配置类型和解析
    let dnsResolution = {}
    let dnsType = null // 未配置默认值
    let domain = null
    
    try {
      // 获取配置的域名
      domain = req.query.domain
      if (!domain) {
        try {
          // 从系统设置获取域名
          const systemSettings = JSON.parse(fs.readFileSync(path.join(ROOT_DIR, 'config', 'system-settings.json'), 'utf8'))
          const configured = systemSettings.dns?.configured === true
          const configuredType = systemSettings.dns?.type
          
          // 检查是否有实际的DNS配置（即使没有configured标记）
            const hasPublicDomain = systemSettings.dns?.public?.domain && systemSettings.dns.public.domain.trim() !== ''
            const hasBindDomain = systemSettings.dns?.bind?.domain && systemSettings.dns.bind.domain.trim() !== ''
          // 对于公网DNS，只要域名存在就认为已配置（serverIp可能为空或0.0.0.0，这不影响公网DNS的使用）
          const hasPublicServerIp = systemSettings.dns?.public?.serverIp && systemSettings.dns.public.serverIp.trim() !== '' && systemSettings.dns.public.serverIp !== '0.0.0.0'
          // 公网DNS只需要域名即可，serverIp是可选的
          const isPublicDnsConfigured = hasPublicDomain
          
          // 优先使用配置文件中明确标记的类型，但优先检查bind配置（bind优先级高于public）
          if (configured && (configuredType === 'public' || configuredType === 'bind')) {
            // 如果配置文件中标记为已配置，且类型正确
            // 优先使用bind配置（即使配置文件中标记为public，如果有bind配置也优先使用bind）
            if (hasBindDomain) {
              dnsType = 'bind'
              domain = systemSettings.dns.bind.domain
              console.log('检测到Bind DNS配置，优先使用Bind类型:', domain)
            } else if (configuredType === 'public' && isPublicDnsConfigured) {
              dnsType = 'public'
              domain = systemSettings.dns.public.domain
              console.log('使用配置文件中的公网DNS类型:', domain)
            } else if (configuredType === 'bind' && hasBindDomain) {
              dnsType = 'bind'
              domain = systemSettings.dns.bind.domain
              console.log('使用配置文件中的Bind DNS类型:', domain)
            } else {
              dnsType = null
              domain = null
            }
          } else if (hasBindDomain || isPublicDnsConfigured) {
            // 如果没有configured标记，但检测到有实际的DNS配置，也认为已配置（兼容旧配置）
            // 优先使用bind配置
            if (hasBindDomain) {
              dnsType = 'bind'
              domain = systemSettings.dns.bind.domain
              console.log('检测到Bind DNS配置但缺少configured标记，自动识别为已配置:', dnsType, domain)
            } else if (isPublicDnsConfigured) {
              dnsType = 'public'
              domain = systemSettings.dns.public.domain
              console.log('检测到公网DNS配置但缺少configured标记，自动识别为已配置:', dnsType, domain)
            } else {
              dnsType = null
              domain = null
            }
          } else {
            dnsType = null
            domain = null
          }
        } catch (error) {
          domain = null
        }
      }
      
      if (domain) {
        // 根据DNS类型选择检查方式
        if (dnsType === 'public') {
          // 公网DNS：使用公共DNS服务器检查
          const aRecord = execSync(`dig @8.8.8.8 +short A ${domain}`, { encoding: 'utf8', timeout: 5000 })
          const mxRecord = execSync(`dig @8.8.8.8 +short MX ${domain}`, { encoding: 'utf8', timeout: 5000 })
          const mailARecord = execSync(`dig @8.8.8.8 +short A mail.${domain}`, { encoding: 'utf8', timeout: 5000 })
          
          dnsResolution = {
            domain: domain,
            aRecord: aRecord.trim() || 'Not found',
            mxRecord: mxRecord.trim() || 'Not found',
            mailARecord: mailARecord.trim() || 'Not found',
            status: (aRecord.trim() && mxRecord.trim()) ? 'resolved' : 'failed',
            type: 'public'
          }
        } else {
          // 本地DNS：优先使用本地DNS服务器
          let aRecord, mxRecord, mailARecord
          
          if (bindStatus === 'running') {
            // Bind运行中，使用本地DNS
            aRecord = execSync(`dig @127.0.0.1 +short A ${domain}`, { encoding: 'utf8', timeout: 5000 })
            mxRecord = execSync(`dig @127.0.0.1 +short MX ${domain}`, { encoding: 'utf8', timeout: 5000 })
            mailARecord = execSync(`dig @127.0.0.1 +short A mail.${domain}`, { encoding: 'utf8', timeout: 5000 })
          } else {
            // Bind未运行，使用公共DNS
            aRecord = execSync(`dig @8.8.8.8 +short A ${domain}`, { encoding: 'utf8', timeout: 5000 })
            mxRecord = execSync(`dig @8.8.8.8 +short MX ${domain}`, { encoding: 'utf8', timeout: 5000 })
            mailARecord = execSync(`dig @8.8.8.8 +short A mail.${domain}`, { encoding: 'utf8', timeout: 5000 })
          }
          
          dnsResolution = {
            domain: domain,
            aRecord: aRecord.trim() || 'Not found',
            mxRecord: mxRecord.trim() || 'Not found',
            mailARecord: mailARecord.trim() || 'Not found',
            status: (aRecord.trim() && mxRecord.trim()) ? 'resolved' : 'failed',
            type: bindStatus === 'running' ? 'bind' : 'public'
          }
        }
      }
    } catch (error) {
      dnsResolution = {
        domain: domain || 'unknown',
        aRecord: 'Error',
        mxRecord: 'Error',
        mailARecord: 'Error',
        status: 'error',
        type: dnsType
      }
    }
    
    res.json({
      success: true,
      services: {
        named: bindStatus === 'running'
      },
      domain: domain,
      dnsType: dnsType,
      bindStatus: bindStatus,
      dnsResolution: dnsResolution,
      timestamp: timestamp
    })
    
  } catch (error) {
    console.error('DNS status error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get DNS status',
      message: error.message
    })
  }
})

// 邮件相关API端点
// 测试邮件发送功能
app.get('/api/mail/test', auth, (req, res) => {
  try {
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    res.json({
      success: true,
      message: 'Mail API is working',
      user: user,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    })
  }
})

// 发送邮件
app.post('/api/mail/send', auth, (req, res) => {
  try {
    const { to, cc, subject, body, from, attachments, folder } = req.body
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 添加详细的请求日志用于调试
    console.log(`[MAIL_SEND_REQUEST] User: ${user}, To: ${to}, Subject: ${subject}, BodyLength: ${body ? body.length : 0}, Attachments: ${attachments ? attachments.length : 0}, Folder: ${folder || 'none'}, From: ${from || 'not provided'}`)
    console.log(`[MAIL_SEND_REQUEST] Body preview: ${body ? body.substring(0, 100) : 'null/undefined'}`)
    
    // 验证附件大小（Base64编码后的大小）
    if (attachments && attachments.length > 0) {
      const MAX_SINGLE_FILE_SIZE = 10 * 1024 * 1024 // 10MB单文件限制（原始大小）
      const MAX_TOTAL_SIZE = 50 * 1024 * 1024 // 50MB总大小限制（原始大小）
      
      let totalSize = 0
      const oversizedFiles = []
      
      for (const att of attachments) {
        let fileSize = 0
        if (att.content) {
          // Base64编码后大小约为原始的1.33倍，所以解码后的大小 = content.length * 0.75
          fileSize = att.content.length * 0.75
        } else if (att.size) {
          fileSize = att.size
        }
        
        totalSize += fileSize
        
        if (fileSize > MAX_SINGLE_FILE_SIZE) {
          oversizedFiles.push({
            name: att.name || '未知文件',
            size: (fileSize / 1024 / 1024).toFixed(2) + 'MB'
          })
        }
      }
      
      if (oversizedFiles.length > 0) {
        console.error(`[MAIL_SEND_ERROR] 附件大小超限: ${oversizedFiles.map(f => `${f.name}(${f.size})`).join(', ')}`)
        return res.status(400).json({
          success: false,
          error: '附件大小超限',
          message: `以下文件超过10MB限制: ${oversizedFiles.map(f => f.name).join(', ')}`,
          details: {
            oversizedFiles: oversizedFiles,
            maxSingleFileSize: '10MB'
          }
        })
      }
      
      if (totalSize > MAX_TOTAL_SIZE) {
        console.error(`[MAIL_SEND_ERROR] 附件总大小超限: ${(totalSize / 1024 / 1024).toFixed(2)}MB`)
        return res.status(400).json({
          success: false,
          error: '附件总大小超限',
          message: `附件总大小为 ${(totalSize / 1024 / 1024).toFixed(2)}MB，超过50MB限制，请分批发送`,
          details: {
            totalSize: (totalSize / 1024 / 1024).toFixed(2) + 'MB',
            maxTotalSize: '50MB'
          }
        })
      }
      
      console.log(`[MAIL_SEND_REQUEST] 附件大小验证通过: 总大小=${(totalSize / 1024 / 1024).toFixed(2)}MB, 文件数=${attachments.length}`)
    }
    
    // 验证邮件参数（如果是草稿，允许to为空）
    const isDraft = folder === 'drafts'
    if (!isDraft && (!to || !subject || !body)) {
      console.error(`[MAIL_SEND_ERROR] Missing required fields - To: ${to ? 'provided' : 'missing'}, Subject: ${subject ? 'provided' : 'missing'}, Body: ${body ? 'provided' : 'missing'}`)
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: to, subject, body',
        details: {
          to: to ? 'provided' : 'missing',
          subject: subject ? 'provided' : 'missing',
          body: body ? 'provided' : 'missing'
        }
      })
    }
    
    // 如果是草稿，至少需要subject或body
    if (isDraft && !subject && !body) {
      return res.status(400).json({
        success: false,
        error: 'Draft must have at least subject or body'
      })
    }
    
    // 如果是草稿，直接保存到草稿箱，不发送邮件
    if (isDraft) {
      let attachmentsFile = '' // 在try块外声明，以便在catch块中访问
      try {
        const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
        
        // 获取用户的真实邮箱地址
        let userEmail = from || `${user}@localhost`
        if (!from) {
          try {
            console.log(`正在查询用户 ${user} 的邮箱地址用于保存草稿...`)
            const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${user}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
            const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
            const email = lines[lines.length - 1]
            if (email && email.includes('@')) {
              userEmail = email
              console.log(`使用用户邮箱保存草稿: ${userEmail}`)
            } else {
              console.log(`使用默认邮箱保存草稿: ${userEmail}`)
            }
          } catch (emailError) {
            console.warn('无法获取用户邮箱，使用默认值:', emailError.message)
          }
        } else {
          console.log(`使用提供的发件人地址保存草稿: ${userEmail}`)
        }
        
        const messageId = `draft-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
        const bodySize = Buffer.byteLength(body || '', 'utf8')
        const ccValue = cc && cc.trim() ? cc.trim() : ''
        
        // 处理附件 - 使用临时文件避免命令行参数过长或特殊字符问题
        if (attachments && attachments.length > 0) {
          try {
            const attachmentsJson = JSON.stringify(attachments)
            const tempFile = `/tmp/draft_attachments_${Date.now()}_${Math.random().toString(36).substr(2, 9)}.json`
            fs.writeFileSync(tempFile, attachmentsJson, 'utf8')
            attachmentsFile = tempFile
            console.log('附件数据已写入临时文件:', tempFile)
          } catch (jsonError) {
            console.error('Failed to stringify attachments:', jsonError)
            attachmentsFile = ''
          }
        }
        
        // 存储草稿到草稿箱
        const targetFolder = folder || 'drafts'
        
        console.log('Saving draft:', { messageId, userEmail, to: to || '', subject: subject || '(无主题)', targetFolder, hasAttachments: !!attachmentsFile })
        
        // 转义特殊字符，避免shell注入
        const safeMessageId = messageId.replace(/"/g, '\\"')
        const safeUserEmail = userEmail.replace(/"/g, '\\"')
        const safeTo = (to || '').replace(/"/g, '\\"')
        const safeSubject = (subject || '(无主题)').replace(/"/g, '\\"').replace(/\$/g, '\\$')
        const safeBody = (body || '').replace(/"/g, '\\"').replace(/\$/g, '\\$')
        const safeHtmlBody = (body || '').replace(/\n/g, '<br>').replace(/"/g, '\\"').replace(/\$/g, '\\$')
        const safeCcValue = ccValue.replace(/"/g, '\\"')
        
        // 如果附件文件存在，传递给脚本；否则传递空字符串
        const attachmentsParam = attachmentsFile || ''
        
        exec(`bash "${mailDbScript}" store "${safeMessageId}" "${safeUserEmail}" "${safeTo}" "${safeSubject}" "${safeBody}" "${safeHtmlBody}" "${targetFolder}" "${bodySize}" "${safeCcValue}" "${attachmentsParam}" "{}" "0" "0"`, (storeError, stdout, stderr) => {
          // 清理临时文件（如果存在）
          if (attachmentsFile && fs.existsSync(attachmentsFile)) {
            try {
              fs.unlinkSync(attachmentsFile)
              console.log('临时附件文件已清理:', attachmentsFile)
            } catch (cleanupError) {
              console.warn('清理临时文件失败:', cleanupError.message)
            }
          }
          
          if (storeError) {
            console.error('Failed to store draft:', storeError)
            console.error('stderr:', stderr)
            console.error('stdout:', stdout)
            return res.status(500).json({
              success: false,
              error: 'Failed to save draft',
              message: storeError.message || '草稿保存失败，请检查日志'
            })
          } else {
            console.log('Draft saved successfully:', { messageId, userEmail, targetFolder })
            return res.json({
              success: true,
              messageId: messageId,
              message: 'Draft saved successfully'
            })
          }
        })
        return // 草稿保存完成，不继续执行发送逻辑
      } catch (error) {
        // 清理临时文件（如果存在）
        if (attachmentsFile && fs.existsSync(attachmentsFile)) {
          try {
            fs.unlinkSync(attachmentsFile)
            console.log('临时附件文件已清理（错误处理）:', attachmentsFile)
          } catch (cleanupError) {
            console.warn('清理临时文件失败:', cleanupError.message)
          }
        }
        
        console.error('Draft save error:', error)
        return res.status(500).json({
          success: false,
          error: 'Failed to save draft',
          message: error.message || '草稿保存时发生错误'
        })
      }
    }
    
    // 域名验证（仅对发送的邮件）
    try {
      // 获取发件人的真实邮箱地址
      let fromEmail = from
      if (!fromEmail) {
        try {
          const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${user}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
          const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
          const email = lines[lines.length - 1]
          if (email && email.includes('@')) {
            fromEmail = email
          } else {
            fromEmail = `${user}@localhost`
          }
        } catch (emailError) {
          console.warn('无法获取用户邮箱，使用默认值:', emailError.message)
          fromEmail = `${user}@localhost`
        }
      }
      
      // 验证发件人域名是否在允许列表中
      const fromDomain = fromEmail.split('@')[1]
      if (!fromDomain) {
        throw new Error(`无法从发件人地址提取域名: ${fromEmail}`)
      }
      
      // 检查发件人域名
      const mailDbPass = getMailDbPassword()
      const fromDomainCheck = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT COUNT(*) FROM virtual_domains WHERE name='${fromDomain}';"`, { encoding: 'utf8', timeout: 3000 }).trim()
      
      if (fromDomainCheck === '0') {
        const domainLogLine = `[${timestamp}] [DOMAIN_REJECTED] User: ${user}, From: ${fromEmail}, Domain: ${fromDomain}, Reason: 发件人域名不在允许列表中, IP: ${clientIP}\n`
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
      
      // 检查收件人域名（主收件人）
      const toDomain = to.split('@')[1]
      if (!toDomain) {
        throw new Error(`无法从收件人地址提取域名: ${to}`)
      }
      
      const toDomainCheck = execSync(`mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT COUNT(*) FROM virtual_domains WHERE name='${toDomain}';"`, { encoding: 'utf8', timeout: 3000 }).trim()
      
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
      
      // 检查抄送收件人域名（如果有）
      if (cc && cc.trim()) {
        const ccEmails = cc.split(',').map(email => email.trim()).filter(email => email.length > 0)
        for (const ccEmail of ccEmails) {
          const ccDomain = ccEmail.split('@')[1]
          if (!ccDomain) {
            console.warn(`无法从抄送地址提取域名: ${ccEmail}`)
            continue
          }
          
          const ccDomainCheck = execSync(`mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT COUNT(*) FROM virtual_domains WHERE name='${ccDomain}';"`, { encoding: 'utf8', timeout: 3000 }).trim()
          
          if (ccDomainCheck === '0') {
            const domainLogLine = `[${timestamp}] [DOMAIN_REJECTED] User: ${user}, CC: ${ccEmail}, Domain: ${ccDomain}, Reason: 抄送收件人域名不在允许列表中, IP: ${clientIP}\n`
            fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), domainLogLine)
            
            return res.status(400).json({
              success: false,
              error: '抄送收件人域名不在允许列表中',
              domainCheck: {
                ccDomain: ccDomain,
                ccEmail: ccEmail,
                allowed: false,
                message: `抄送收件人域名 ${ccDomain} 未在系统允许的邮件域名列表中`
              }
            })
          }
        }
      }
      
      console.log(`域名验证通过: 发件人域名 ${fromDomain}, 收件人域名 ${toDomain}${cc ? `, 抄送域名已验证` : ''}`)
    } catch (domainError) {
      console.error('域名验证失败:', domainError)
      // 如果域名验证失败，记录错误但继续发送邮件
      const errorLogLine = `[${timestamp}] [DOMAIN_CHECK_ERROR] User: ${user}, Error: ${domainError.message}, IP: ${clientIP}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), errorLogLine)
    }
    
    // 确保收件人存在于virtual_users表中（Postfix需要）
    // 主收件人必须同步检查（否则Postfix会拒绝），抄送人可以异步检查
    try {
      // 快速检查主收件人是否存在（同步，但只查询一次）
      const toUserCheck = execSync(
        `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_users WHERE email='${to}' LIMIT 1;" 2>/dev/null || echo ""`,
        { encoding: 'utf8', timeout: 2000 }
      ).trim()
      
      if (!toUserCheck) {
        // 主收件人不存在，快速创建（同步，但只执行必要的操作）
        const toEmailParts = to.split('@')
        const toEmailDomain = toEmailParts[1]
        const toEmailUsername = toEmailParts[0]
        
        // 获取或创建域名ID（合并查询）
        let toDomainId = execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name='${toEmailDomain}' LIMIT 1;" 2>/dev/null || echo ""`,
          { encoding: 'utf8', timeout: 2000 }
        ).trim()
        
        if (!toDomainId) {
          execSync(
            `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -e "INSERT INTO virtual_domains (name) VALUES ('${toEmailDomain}'); SELECT id FROM virtual_domains WHERE name='${toEmailDomain}' LIMIT 1;" 2>/dev/null`,
            { timeout: 2000 }
          )
          toDomainId = execSync(
            `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name='${toEmailDomain}' LIMIT 1;" 2>/dev/null`,
            { encoding: 'utf8', timeout: 2000 }
          ).trim()
        }
        
        // 快速创建用户（不查询密码，直接生成）
        const userPassword = '$6$rounds=5000$defaultsalt$' + crypto.randomBytes(16).toString('hex')
        execSync(
          `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -e "INSERT INTO virtual_users (domain_id, email, password, active) VALUES (${toDomainId}, '${to}', '${userPassword}', 1);" 2>/dev/null`,
          { timeout: 2000 }
        )
        console.log(`主收件人 ${to} 已快速创建`)
        
        // 目录创建异步执行
        const mailDir = `/var/vmail/${toEmailDomain}/${toEmailUsername}/Maildir`
        exec(`mkdir -p ${mailDir}/new ${mailDir}/cur ${mailDir}/tmp && chown -R vmail:mail /var/vmail/${toEmailDomain}/${toEmailUsername} && chmod 700 /var/vmail/${toEmailDomain}/${toEmailUsername} ${mailDir}`, { timeout: 5000 }, () => {})
      }
      
      // 抄送收件人异步检查（不阻塞请求）
      if (cc && cc.trim()) {
        const ccEmails = cc.split(',').map(email => email.trim()).filter(email => email.length > 0)
        const mailDbPass = getMailDbPassword().replace(/'/g, "'\\''").replace(/\$/g, '\\$')
        // 异步处理抄送人，不阻塞请求
        exec(`bash -c 'MAIL_DB_PASS="${mailDbPass}"
for email in ${ccEmails.map(e => `"${e}"`).join(' ')}; do
          domain=$(echo "$email" | cut -d@ -f2)
          username=$(echo "$email" | cut -d@ -f1)
          user_exists=$(mysql -u mailuser -p"$MAIL_DB_PASS" maildb -s -r -e "SELECT id FROM virtual_users WHERE email=\"$email\" LIMIT 1;" 2>/dev/null || echo "")
          if [ -z "$user_exists" ]; then
            domain_id=$(mysql -u mailuser -p"$MAIL_DB_PASS" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name=\"$domain\" LIMIT 1;" 2>/dev/null || echo "")
            if [ -z "$domain_id" ]; then
              mysql -u mailuser -p"$MAIL_DB_PASS" maildb -e "INSERT INTO virtual_domains (name) VALUES (\"$domain\");" 2>/dev/null
              domain_id=$(mysql -u mailuser -p"$MAIL_DB_PASS" maildb -s -r -e "SELECT id FROM virtual_domains WHERE name=\"$domain\" LIMIT 1;" 2>/dev/null)
            fi
            password="\\\$6\\\$rounds=5000\\\$defaultsalt\\\$\$(openssl rand -hex 16)"
            mysql -u mailuser -p"$MAIL_DB_PASS" maildb -e "INSERT INTO virtual_users (domain_id, email, password, active) VALUES ($domain_id, \"$email\", \"$password\", 1);" 2>/dev/null
            mail_dir="/var/vmail/$domain/$username/Maildir"
            mkdir -p "$mail_dir/new" "$mail_dir/cur" "$mail_dir/tmp" 2>/dev/null
            chown -R vmail:mail "/var/vmail/$domain/$username" 2>/dev/null
            chmod 700 "/var/vmail/$domain/$username" "$mail_dir" 2>/dev/null
          fi
        done'`, { timeout: 10000 }, () => {})
      }
    } catch (virtualUserError) {
      console.error('确保收件人存在于virtual_users表失败:', virtualUserError)
      // 记录错误但继续发送邮件
      const errorLogLine = `[${timestamp}] [VIRTUAL_USER_CHECK_ERROR] User: ${user}, Error: ${virtualUserError.message}, IP: ${clientIP}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), errorLogLine)
    }
    
    // 垃圾邮件检测（从数据库加载配置）
    let isSpamDetected = false
    let spamResult = null
    try {
      // 从数据库加载垃圾邮件过滤配置
      const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
      let spamConfig = {
        keywords: { chinese: [], english: [] },
        domainBlacklist: [],
        emailBlacklist: [],
        rules: { minContentLines: 0, uppercaseRatio: 0.8, maxExclamationMarks: 6, maxSpecialChars: 8 }
      }
      
        try {
        const configResult = execSync(`bash "${mailDbScript}" get-spam-config`, { encoding: 'utf8', timeout: 5000 })
        if (configResult && configResult.trim()) {
          spamConfig = JSON.parse(configResult.trim())
          console.log('邮件发送时从数据库加载垃圾邮件过滤配置:', {
            keywords_cn: spamConfig.keywords?.chinese?.length || 0,
            keywords_en: spamConfig.keywords?.english?.length || 0,
            domains: spamConfig.domainBlacklist?.length || 0,
            rules: spamConfig.rules
          })
      } else {
          console.log('数据库中没有垃圾邮件过滤配置，使用默认配置')
      }
      } catch (dbError) {
        console.warn('从数据库加载垃圾邮件过滤配置失败，使用默认配置:', dbError.message)
        // 使用默认配置继续
      }
      
      spamResult = checkSpamContent(subject, body, from || user, to, spamConfig)
      
      if (spamResult.isSpam) {
        isSpamDetected = true
        // 记录垃圾邮件检测日志
        const spamLogLine = `[${timestamp}] [SPAM_DETECTED] User: ${user}, To: ${to}, Subject: ${subject}, Violations: ${spamResult.violations.length}, Score: ${spamResult.spamScore}, IP: ${clientIP}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), spamLogLine)
        console.log('检测到垃圾邮件，将自动存储到垃圾邮箱:', {
          violations: spamResult.violations.length,
          score: spamResult.spamScore,
          keywords: spamResult.detectedKeywords
        })
        // 不阻止发送，而是标记为垃圾邮件，后续存储到垃圾邮箱
      }
    } catch (spamError) {
      console.error('垃圾邮件检测失败:', spamError)
      // 如果检测失败，继续发送邮件，但记录错误
      const errorLogLine = `[${timestamp}] [SPAM_CHECK_ERROR] User: ${user}, Error: ${spamError.message}, IP: ${clientIP}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), errorLogLine)
    }
    
    // 记录邮件发送操作
    const ccInfo = cc ? `, CC: ${cc}` : ''
    const attachmentInfo = attachments && attachments.length > 0 ? `, Attachments: ${attachments.length}` : ''
    const logLine = `[${timestamp}] [MAIL_SEND] User: ${user}, To: ${to}${ccInfo}, Subject: ${subject}, BodyLength: ${body.length}${attachmentInfo}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 使用sendmail发送邮件
    // 创建SMTP传输器（优化超时设置，加快响应速度）
    const transporter = nodemailer.createTransport({
      host: 'localhost',
      port: 25,
      secure: false,
      tls: {
        rejectUnauthorized: false // 禁用SSL证书验证
      },
      auth: {
        user: from || user,
        pass: 'dummy' // 使用系统认证
      },
      // 优化连接和发送超时设置，避免长时间等待
      connectionTimeout: 5000, // 连接超时5秒
      greetingTimeout: 5000, // 问候超时5秒
      socketTimeout: 30000, // Socket超时30秒
      // 对于本地Postfix，可以设置更短的超时
      pool: false, // 不使用连接池，避免连接复用问题
      maxConnections: 1,
      maxMessages: 1
    })
    
    // 处理附件
    let attachmentsArray = []
    if (attachments && attachments.length > 0) {
      attachmentsArray = attachments.map(attachment => ({
        filename: attachment.name,
        content: attachment.content,
        contentType: attachment.type
      }))
    }
    
    // 获取用户的真实邮箱地址（优先从数据库获取，而不是使用前端传递的from）
    let userEmail = `${user}@localhost` // 默认值
    try {
      console.log(`正在查询用户 ${user} 的邮箱地址...`)
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${user}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      console.log(`查询结果: "${userEmailResult}"`)
      // 过滤掉表头，只取最后一行
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
        console.log(`使用数据库中的用户邮箱: ${userEmail}`)
      } else {
        console.log(`数据库中没有找到用户邮箱，使用默认值: ${userEmail}`)
      }
    } catch (error) {
      console.log('无法获取用户邮箱，使用默认值:', error.message)
    }
    
    // 如果前端传递了from且与数据库中的邮箱不同，记录警告
    if (from && from !== userEmail && from !== `${user}@localhost`) {
      console.warn(`前端传递的发件人地址 ${from} 与数据库中的邮箱 ${userEmail} 不同，将使用数据库中的邮箱`)
    }
    
    // 确保 userEmail 被正确设置
    // 优先使用从数据库获取的真实邮箱地址，而不是前端传递的from
    // 这样可以确保使用正确的邮箱地址（如xm@skills.com而不是xm@localhost）
    const finalFromEmail = userEmail || from || `${user}@localhost`
    console.log(`最终使用的发件人地址: ${finalFromEmail} (userEmail: ${userEmail}, from: ${from})`)
    
    // 邮件选项
    const mailOptions = {
      from: finalFromEmail,
      to: to,
      cc: cc || undefined,
      subject: subject,
      text: body,
      html: body.replace(/\n/g, '<br>'),
      attachments: attachmentsArray
    }
    
    // 发送邮件
    console.log('Attempting to send email:', { from: mailOptions.from, to: mailOptions.to, cc: mailOptions.cc, subject: mailOptions.subject })
    
    // 设置超时处理（根据附件大小动态调整，但设置合理的上限）
    const hasAttachments = attachments && attachments.length > 0
    let timeoutDuration = 30000 // 默认30秒（减少默认超时时间）
    
    if (hasAttachments) {
      // 计算总附件大小
      const totalSize = attachments.reduce((sum, att) => {
        // 如果是Base64编码，计算原始大小
        if (att.content) {
          return sum + (att.content.length * 0.75) // Base64编码后大小约为原始的1.33倍
        }
        return sum + (att.size || 0)
      }, 0)
      
      // 根据文件大小动态调整超时时间（支持大附件，增加超时上限）
      if (totalSize > 30 * 1024 * 1024) { // 大于30MB
        timeoutDuration = 600000 // 10分钟
      } else if (totalSize > 20 * 1024 * 1024) { // 大于20MB
        timeoutDuration = 480000 // 8分钟
      } else if (totalSize > 10 * 1024 * 1024) { // 大于10MB
        timeoutDuration = 360000 // 6分钟
      } else if (totalSize > 5 * 1024 * 1024) { // 大于5MB
        timeoutDuration = 240000 // 4分钟
      } else if (totalSize > 1024 * 1024) { // 大于1MB
        timeoutDuration = 180000 // 3分钟
      } else if (totalSize > 500 * 1024) { // 大于500KB
        timeoutDuration = 120000 // 2分钟
      } else {
        timeoutDuration = 60000 // 1分钟
      }
      
      console.log(`Attachment size: ${(totalSize / 1024).toFixed(2)}KB, timeout: ${timeoutDuration / 1000}s`)
    }
    let responseSent = false // 防止重复响应
    const timeout = setTimeout(() => {
      if (responseSent) return // 如果响应已发送，不再处理超时
      responseSent = true
      console.error('Mail send timeout')
      res.status(500).json({
        success: false,
        error: 'Mail send timeout',
        message: '邮件发送超时，请检查附件大小或网络连接'
      })
    }, timeoutDuration)
    
    // 准备数据库存储所需的变量（在回调外部定义，以便错误处理也能访问）
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    const fromAddr = finalFromEmail || userEmail || from || `${user}@localhost`
    const bodySize = Buffer.byteLength(body, 'utf8')
    const ccValue = cc && cc.trim() ? cc.trim() : ''
    
    // 保存垃圾邮件检测结果（在闭包中使用）
    const spamDetectionResult = spamResult
    const spamDetected = isSpamDetected
    
    // 处理附件存储 - 为每个存储操作创建临时文件（在回调外部定义）
    let attachmentsJson = ''
    let attachmentsFileInbox = ''
    let attachmentsFileCc = ''
    let attachmentsFileSent = ''
    
    if (attachments && attachments.length > 0) {
      attachmentsJson = JSON.stringify(attachments)
      const baseTempFile = `/tmp/attachments_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      
      // 为收件箱创建临时文件
      attachmentsFileInbox = `${baseTempFile}_inbox.json`
      fs.writeFileSync(attachmentsFileInbox, attachmentsJson)
      
      // 为抄送创建临时文件（如果需要）
      if (ccValue) {
        attachmentsFileCc = `${baseTempFile}_cc.json`
        fs.writeFileSync(attachmentsFileCc, attachmentsJson)
      }
      
      // 为已发送文件夹创建临时文件
      attachmentsFileSent = `${baseTempFile}_sent.json`
      fs.writeFileSync(attachmentsFileSent, attachmentsJson)
    }
    
    // 存储邮件到数据库的辅助函数
    const storeMailToDatabase = (messageId, isError = false, errorObj = null) => {
      console.log(`[存储邮件] 开始存储邮件到数据库: messageId=${messageId}, isError=${isError}, isSpam=${spamDetected}`)
      console.log(`[存储邮件] 参数: fromAddr=${fromAddr}, to=${to}, subject=${subject}, bodySize=${bodySize}`)
      console.log(`[存储邮件] body字段长度: ${body ? body.length : 0}, body前100字符: ${body ? body.substring(0, 100) : 'null'}`)
      // 记录到日志文件
      const spamInfo = spamDetected ? `, isSpam=true, score=${spamDetectionResult?.spamScore || 0}` : ''
      const startLog = `[${new Date().toISOString()}] [MAIL_STORE_START] messageId=${messageId}, fromAddr=${fromAddr}, to=${to}, subject=${subject}, isError=${isError}${spamInfo}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), startLog)
      
      // 转义特殊字符，避免shell注入和命令执行错误
      // 使用单引号包裹，内部单引号用 '\'' 转义
      const escapeShellArg = (str) => {
        if (!str) return "''"
        // 将字符串转换为单引号包裹的形式，内部单引号用 '\'' 转义
        // 这样可以安全地传递包含特殊字符的字符串
        const escaped = String(str).replace(/'/g, "'\\''")
        return "'" + escaped + "'"
      }
      
      // 对于body字段，使用临时文件方式传递，避免命令行长度限制和特殊字符问题
      const writeBodyToTempFile = (content, prefix) => {
        const tempFile = path.join(LOG_DIR, `${prefix}_${Date.now()}_${Math.random().toString(36).substring(7)}.tmp`)
        try {
          fs.writeFileSync(tempFile, content, 'utf8')
          return tempFile
        } catch (error) {
          console.error(`[存储邮件] 写入临时文件失败: ${error.message}`)
          return null
        }
      }
      
      // 存储到收件人的收件箱
      // 即使SMTP发送失败（如抄送地址错误），也应该存储到主收件人的收件箱
      // 只有当明确是主收件人地址错误时才不存储
      let shouldStoreToInbox = true
      if (isError && errorObj && errorObj.response && to) {
        // 检查错误信息中是否包含主收件人地址，如果包含说明主收件人不存在
        const errorResponse = String(errorObj.response)
        if (errorResponse.includes(`<${to}>`)) {
          shouldStoreToInbox = false
          console.log(`[存储邮件] 主收件人地址不存在，跳过收件箱存储: ${to}`)
        }
      }
      
      // 为每个存储操作创建独立的临时文件，避免并发删除问题
      // 注意：不再共享临时文件，因为mail_db.sh会在读取后立即删除文件
      
      if (shouldStoreToInbox) {
        const attachmentsParamInbox = attachmentsFileInbox || ''
        // 使用唯一的messageId后缀，避免与已发送文件夹的messageId冲突
        const inboxMessageId = `${messageId}_inbox`
        const safeInboxMessageId = escapeShellArg(inboxMessageId)
        const safeFromAddr = escapeShellArg(fromAddr)
        const safeTo = escapeShellArg(to)
        const safeSubject = escapeShellArg(subject)
        
        // 为收件箱存储创建独立的临时文件
        const inboxBodyTempFile = writeBodyToTempFile(body, 'body_inbox')
        const inboxHtmlBodyTempFile = writeBodyToTempFile(body.replace(/\n/g, '<br>'), 'html_inbox')
        
        // 使用临时文件传递body，避免命令行长度限制和特殊字符问题
        const safeBody = inboxBodyTempFile ? escapeShellArg(inboxBodyTempFile) : escapeShellArg(body)
        const safeHtmlBody = inboxHtmlBodyTempFile ? escapeShellArg(inboxHtmlBodyTempFile) : escapeShellArg(body.replace(/\n/g, '<br>'))
        
        const safeCcValue = escapeShellArg(ccValue)
        const safeAttachmentsParamInbox = attachmentsParamInbox ? escapeShellArg(attachmentsParamInbox) : ''
        
        // 如果检测到垃圾邮件，存储到垃圾邮箱而不是收件箱
        const targetFolder = spamDetected ? 'spam' : 'inbox'
        const inboxCommand = `bash "${mailDbScript}" store ${safeInboxMessageId} ${safeFromAddr} ${safeTo} ${safeSubject} ${safeBody} ${safeHtmlBody} "${targetFolder}" "${bodySize}" ${safeCcValue} ${safeAttachmentsParamInbox} "{}" "0" "0"`
        console.log(`[存储邮件] 执行${targetFolder === 'spam' ? '垃圾邮箱' : '收件箱'}存储命令: ${inboxCommand.substring(0, 200)}...`)
        console.log(`[存储邮件] body临时文件: ${inboxBodyTempFile}, html临时文件: ${inboxHtmlBodyTempFile}`)
        if (spamDetected) {
          console.log(`[存储邮件] 检测到垃圾邮件，存储到垃圾邮箱: violations=${spamDetectionResult?.violations?.length || 0}, score=${spamDetectionResult?.spamScore || 0}`)
        }
        
        exec(inboxCommand, { maxBuffer: 10 * 1024 * 1024 }, (storeError, stdout, stderr) => {
          // 清理临时文件（如果存在）
          if (attachmentsFileInbox && fs.existsSync(attachmentsFileInbox)) {
            try {
              fs.unlinkSync(attachmentsFileInbox)
            } catch (cleanupError) {
              console.warn('清理收件箱临时文件失败:', cleanupError.message)
            }
          }
          
          if (storeError) {
            console.error(`[存储邮件] 收件箱存储失败: ${storeError.message}`)
            console.error(`[存储邮件] stderr: ${stderr}`)
            console.error(`[存储邮件] stdout: ${stdout}`)
            // 记录到日志文件
            const errorLog = `[${new Date().toISOString()}] [MAIL_STORE_ERROR] Failed to store inbox mail: ${storeError.message}\nCommand: ${inboxCommand}\nStderr: ${stderr}\nStdout: ${stdout}\n`
            fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), errorLog)
          } else {
            const folderName = spamDetected ? '垃圾邮箱' : '收件箱'
            console.log(`[存储邮件] ${folderName}存储成功: recipient=${to}, messageId=${inboxMessageId}`)
            if (stdout) console.log(`[存储邮件] stdout: ${stdout}`)
            // 记录成功日志到文件
            const successLog = `[${new Date().toISOString()}] [MAIL_STORE_SUCCESS] Stored ${targetFolder} mail: recipient=${to}, messageId=${inboxMessageId}, isSpam=${spamDetected}\n`
            fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), successLog)
          }
        })
        
        // 如果有抄送，为每个抄送收件人单独存储邮件
        if (ccValue) {
          const attachmentsParamCc = attachmentsFileCc || ''
          const safeAttachmentsParamCc = attachmentsParamCc ? escapeShellArg(attachmentsParamCc) : ''
          
          // 解析抄送地址列表
          const ccAddresses = ccValue.split(',').map(addr => addr.trim()).filter(addr => addr.length > 0)
          
          // 为每个抄送收件人单独存储
          ccAddresses.forEach((ccAddr, index) => {
            const ccMessageId = `${messageId}_cc_${index}`
            const safeCcMessageId = escapeShellArg(ccMessageId)
            const safeCcAddr = escapeShellArg(ccAddr)
            
            // 为抄送邮件也创建临时文件（复用收件箱的临时文件）
            // 为每个抄送收件人创建独立的临时文件
            const ccBodyTempFile = writeBodyToTempFile(body, `body_cc_${index}`)
            const ccHtmlBodyTempFile = writeBodyToTempFile(body.replace(/\n/g, '<br>'), `html_cc_${index}`)
            const ccSafeBody = ccBodyTempFile ? escapeShellArg(ccBodyTempFile) : escapeShellArg(body)
            const ccSafeHtmlBody = ccHtmlBodyTempFile ? escapeShellArg(ccHtmlBodyTempFile) : escapeShellArg(body.replace(/\n/g, '<br>'))
            
            // 对于抄送收件人，to应该是主收件人，cc应该是所有抄送地址（包括自己）
            // 这样抄送收件人看到的邮件信息才是正确的
            const ccCommand = `bash "${mailDbScript}" store ${safeCcMessageId} ${safeFromAddr} ${safeTo} ${safeSubject} ${ccSafeBody} ${ccSafeHtmlBody} "inbox" "${bodySize}" ${safeCcValue} ${safeAttachmentsParamCc} "{}" "0" "0"`
            console.log(`[存储邮件] 执行抄送存储命令 (收件人: ${ccAddr}): ${ccCommand.substring(0, 200)}...`)
            
            exec(ccCommand, { maxBuffer: 10 * 1024 * 1024 }, (storeError, stdout, stderr) => {
              if (storeError) {
                console.error(`[存储邮件] 抄送存储失败 (收件人: ${ccAddr}): ${storeError.message}`)
                console.error(`[存储邮件] stderr: ${stderr}`)
                console.error(`[存储邮件] stdout: ${stdout}`)
              } else {
                console.log(`[存储邮件] 抄送存储成功: recipient=${ccAddr}, messageId=${ccMessageId}`)
              }
            })
          })
          
          // 所有抄送邮件存储完成后，清理临时文件
          if (attachmentsFileCc && fs.existsSync(attachmentsFileCc)) {
            // 延迟清理，确保所有存储操作都完成
            setTimeout(() => {
              try {
                fs.unlinkSync(attachmentsFileCc)
              } catch (cleanupError) {
                console.warn('清理抄送临时文件失败:', cleanupError.message)
              }
            }, 5000) // 5秒后清理
          }
        }
      }
      
      // 无论SMTP成功或失败，都存储到发送人的已发送文件夹（如果检测到垃圾邮件，也存储到垃圾邮箱）
      const attachmentsParamSent = attachmentsFileSent || ''
      const sentMessageId = `${messageId}_sent`
      const safeSentMessageId = escapeShellArg(sentMessageId)
      const safeFromAddrSent = escapeShellArg(fromAddr)
      const safeToSent = escapeShellArg(to)
      const safeSubjectSent = escapeShellArg(subject)
      
      // 使用临时文件传递body（复用收件箱的临时文件或创建新的）
      // 为已发送文件夹创建独立的临时文件
      const sentBodyTempFile = writeBodyToTempFile(body, 'body_sent')
      const sentHtmlBodyTempFile = writeBodyToTempFile(body.replace(/\n/g, '<br>'), 'html_sent')
      const safeBodySent = sentBodyTempFile ? escapeShellArg(sentBodyTempFile) : escapeShellArg(body)
      const safeHtmlBodySent = sentHtmlBodyTempFile ? escapeShellArg(sentHtmlBodyTempFile) : escapeShellArg(body.replace(/\n/g, '<br>'))
      
      const safeCcValueSent = escapeShellArg(ccValue)
      const safeAttachmentsParamSent = attachmentsParamSent ? escapeShellArg(attachmentsParamSent) : ''
      
      // 存储到已发送文件夹
      const sentCommand = `bash "${mailDbScript}" store ${safeSentMessageId} ${safeFromAddrSent} ${safeToSent} ${safeSubjectSent} ${safeBodySent} ${safeHtmlBodySent} "sent" "${bodySize}" ${safeCcValueSent} ${safeAttachmentsParamSent} "{}" "0" "0"`
      console.log(`[存储邮件] 已发送body临时文件: ${sentBodyTempFile}, html临时文件: ${sentHtmlBodyTempFile}`)
      console.log(`[存储邮件] 执行已发送存储命令: ${sentCommand.substring(0, 200)}...`)
      
      // 如果检测到垃圾邮件，也存储到发送人的垃圾邮箱
      if (spamDetected) {
        const spamMessageId = `${messageId}_spam_sent`
        const safeSpamMessageId = escapeShellArg(spamMessageId)
        // 为垃圾邮箱创建独立的临时文件（不复用已发送的临时文件）
        const spamBodyTempFile = writeBodyToTempFile(body, 'body_spam_sent')
        const spamHtmlBodyTempFile = writeBodyToTempFile(body.replace(/\n/g, '<br>'), 'html_spam_sent')
        const safeSpamBodySent = spamBodyTempFile ? escapeShellArg(spamBodyTempFile) : escapeShellArg(body)
        const safeSpamHtmlBodySent = spamHtmlBodyTempFile ? escapeShellArg(spamHtmlBodyTempFile) : escapeShellArg(body.replace(/\n/g, '<br>'))
        const spamCommand = `bash "${mailDbScript}" store ${safeSpamMessageId} ${safeFromAddrSent} ${safeToSent} ${safeSubjectSent} ${safeSpamBodySent} ${safeSpamHtmlBodySent} "spam" "${bodySize}" ${safeCcValueSent} ${safeAttachmentsParamSent} "{}" "0" "0"`
        console.log(`[存储邮件] 执行发送人垃圾邮箱存储命令: ${spamCommand.substring(0, 200)}...`)
        
        exec(spamCommand, { maxBuffer: 10 * 1024 * 1024 }, (storeError, stdout, stderr) => {
          if (storeError) {
            console.error(`[存储邮件] 发送人垃圾邮箱存储失败: ${storeError.message}`)
          } else {
            console.log(`[存储邮件] 发送人垃圾邮箱存储成功: messageId=${spamMessageId}`)
          }
        })
      }
      
      exec(sentCommand, { maxBuffer: 10 * 1024 * 1024 }, (storeError, stdout, stderr) => {
        // 清理临时文件（如果存在）
        if (attachmentsFileSent && fs.existsSync(attachmentsFileSent)) {
          try {
            fs.unlinkSync(attachmentsFileSent)
          } catch (cleanupError) {
            console.warn('清理已发送临时文件失败:', cleanupError.message)
          }
        }
        
        if (storeError) {
          console.error(`[存储邮件] 已发送文件夹存储失败: ${storeError.message}`)
          console.error(`[存储邮件] stderr: ${stderr}`)
          console.error(`[存储邮件] stdout: ${stdout}`)
          // 记录到日志文件
          const errorLog = `[${new Date().toISOString()}] [MAIL_STORE_ERROR] Failed to store sent mail: ${storeError.message}\nCommand: ${sentCommand}\nStderr: ${stderr}\nStdout: ${stdout}\n`
          fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), errorLog)
        } else {
          console.log(`[存储邮件] 已发送文件夹存储成功: messageId=${sentMessageId}`)
          if (stdout) console.log(`[存储邮件] stdout: ${stdout}`)
        }
      })
    }
    
    transporter.sendMail(mailOptions, (error, info) => {
      clearTimeout(timeout) // 清除超时定时器
      if (responseSent) return // 如果响应已发送（超时），不再处理回调
      
      const messageId = info?.messageId || `msg-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
      
      if (error) {
        console.error('Mail send error:', error)
        
        // 检查是否是收件人不存在错误
        const isRecipientError = error.code === 'EENVELOPE' || 
                                 (error.responseCode === 550 && error.response && error.response.includes('User unknown'))
        
        // 无论什么错误，都存储到已发送文件夹
        // 传递错误对象以便在storeMailToDatabase中判断是否存储到收件箱
        storeMailToDatabase(messageId, true, error)
        
        if (isRecipientError) {
          // 收件人不存在，返回警告但邮件已保存
          responseSent = true
          res.status(200).json({
            success: true,
            messageId: messageId,
            message: '邮件已保存到已发送文件夹，但收件人地址不存在，邮件未成功投递',
            warning: '收件人地址不存在',
            error: error.message,
            stored: true
          })
        } else {
          // 其他错误
          responseSent = true
          res.status(500).json({
            success: false,
            error: 'Failed to send email',
            message: error.message,
            stored: true // 邮件已保存到已发送文件夹
          })
        }
      } else {
        console.log('Mail sent successfully:', info.messageId)
        console.log('准备存储邮件到数据库，参数:', { messageId, fromAddr, to, subject, bodySize, isSpam: spamDetected })
        
        // 记录发送成功日志
        const spamInfo = spamDetected ? `, SpamDetected: true, Score: ${spamDetectionResult?.spamScore || 0}, Violations: ${spamDetectionResult?.violations?.length || 0}` : ''
        const sendLog = `[${new Date().toISOString()}] [MAIL_SEND_SUCCESS] User: ${user}, To: ${to}, CC: ${ccValue || ''}, Subject: ${subject}, MessageId: ${messageId}${spamInfo}, IP: ${clientIP}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), sendLog)
        
        // 将发送的邮件存储到数据库（异步，不阻塞响应）
        // 注意：spamDetected 和 spamDetectionResult 已在闭包中定义
        storeMailToDatabase(messageId, false)
        
        console.log('Mail send completed successfully:', { messageId: info.messageId, fromAddr, to, subject, isSpam: spamDetected })
        responseSent = true
        res.json({
          success: true,
          messageId: info.messageId,
          message: spamDetected ? '邮件已发送，但检测到垃圾邮件内容，已自动移动到垃圾邮箱' : 'Email sent successfully',
          spamDetection: spamDetected ? {
            isSpam: true,
            violations: spamDetectionResult.violations,
            detectedKeywords: spamDetectionResult.detectedKeywords,
            summary: spamDetectionResult.summary,
            spamScore: spamDetectionResult.spamScore
          } : null
        })
      }
    })
    
  } catch (error) {
    console.error('Mail send error:', error)
    res.status(500).json({
      success: false,
      error: 'Internal server error',
      message: error.message
    })
  }
})

// 获取邮件列表
app.get('/api/mail/list', auth, (req, res) => {
  try {
    const { folder = 'inbox', limit = 50, offset = 0 } = req.query
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const username = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'

    // 获取用户的真实邮箱地址
    let userEmail = username
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${username}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
      }
    } catch (emailError) {
      console.warn('Failed to get user email for mail list, using username:', emailError.message)
    }

    // 记录邮件列表查询
    const logLine = `[${timestamp}] [MAIL_LIST] User: ${username}, Email: ${userEmail}, Folder: ${folder}, Limit: ${limit}, Offset: ${offset}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)

    // 使用真实邮件数据库
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')

    exec(`bash "${mailDbScript}" list "${userEmail}" "${folder}" "${limit}" "${offset}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail list error:', error)
        // 如果数据库查询失败，返回空列表而不是错误
        res.json({
          success: true,
          emails: [],
          total: 0,
          folder: folder
        })
        return
      }
      
      try {
        const emails = JSON.parse(stdout)
        res.json({
          success: true,
          emails: emails,
          total: emails.length,
          folder: folder
        })
      } catch (parseError) {
        console.error('Mail list parse error:', parseError)
        res.json({
          success: true,
          emails: [],
          total: 0,
          folder: folder
        })
      }
    })
    
  } catch (error) {
    console.error('Mail list error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get mail list',
      message: error.message
    })
  }
})

// 搜索邮件
app.get('/api/mail/search', auth, (req, res) => {
  try {
    const { q = '', folder = 'all', limit = 100, offset = 0 } = req.query
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const username = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'

    // 获取用户的真实邮箱地址
    let userEmail = username
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${username}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
      }
    } catch (emailError) {
      console.warn('Failed to get user email for mail search, using username:', emailError.message)
    }

    // 记录邮件搜索
    const logLine = `[${timestamp}] [MAIL_SEARCH] User: ${username}, Email: ${userEmail}, Query: ${q}, Folder: ${folder}, Limit: ${limit}, Offset: ${offset}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)

    // 使用真实邮件数据库
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')

    exec(`bash "${mailDbScript}" search "${userEmail}" "${q}" "${folder}" "${limit}" "${offset}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail search error:', error)
        res.json({
          success: true,
          emails: [],
          total: 0,
          folder: folder
        })
        return
      }
      
      try {
        const emails = JSON.parse(stdout)
        res.json({
          success: true,
          emails: emails,
          total: emails.length,
          folder: folder
        })
      } catch (parseError) {
        console.error('Mail search parse error:', parseError)
        res.json({
          success: true,
          emails: [],
          total: 0,
          folder: folder
        })
      }
    })
  } catch (error) {
    console.error('Mail search error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to search emails',
      message: error.message
    })
  }
})

// 检查邮件服务状态
app.get('/api/mail/service-status', auth, (req, res) => {
  try {
    console.log('Starting mail service status check...')
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    console.log('Service status check - User:', user, 'IP:', clientIP)
    
    // 记录服务状态检查（容错，不影响接口返回）
    try {
      const logDir = LOG_DIR || path.join(process.cwd(), '..', '..', 'logs')
      fs.mkdirSync(logDir, { recursive: true })
      const logLine = `[${timestamp}] [MAIL_SERVICE_STATUS] User: ${user}, IP: ${clientIP}\n`
      fs.appendFileSync(path.join(logDir, 'mail-operations.log'), logLine)
    } catch (logErr) {
      console.warn('mail service-status logging skipped:', logErr?.message || logErr)
    }
    
    
    // 检查邮件服务状态（基于退出码判断，更稳健）
    const checkServices = () => {
      return new Promise((resolve) => {
        const services = {
          postfix: false,
          dovecot: false,
          named: false,
          mariadb: false
        }

        // 依次检查，每项使用 --quiet 只看退出码
        exec('systemctl is-active --quiet postfix', (err1) => {
          services.postfix = !err1

          exec('systemctl is-active --quiet dovecot', (err2) => {
            services.dovecot = !err2

            // Bind 可能为 named 或 bind9，先检查 named
            exec('systemctl is-active --quiet named', (err3) => {
              if (!err3) {
                services.named = true
                nextMaria()
              } else {
                exec('systemctl is-active --quiet bind9', (err3b) => {
                  services.named = !err3b
                  nextMaria()
                })
              }
            })

            function nextMaria() {
              // MariaDB 可能为 mariadb 或 mysqld
              exec('systemctl is-active --quiet mariadb', (err4) => {
                if (!err4) {
                  services.mariadb = true
                  resolve(services)
                } else {
                  exec('systemctl is-active --quiet mysqld', (err4b) => {
                    services.mariadb = !err4b
                    resolve(services)
                  })
                }
              })
            }
          })
        })
      })
    }
    
    // 检查DNS解析（支持公网DNS和本地Bind）
    const checkDNSResolution = () => {
      return new Promise((resolve) => {
        let domain = null
        let dnsType = null
        
        function getDomainFromSystem(cb) {
          exec("grep -E '^myhostname|^mydomain' /etc/postfix/main.cf 2>/dev/null | head -2", (e1, out1) => {
            let d = null
            if (!e1 && out1) {
              const lines = out1.trim().split('\n')
              for (const line of lines) {
                if (line.includes('mydomain=')) d = line.split('=')[1]?.trim()
                else if (line.includes('myhostname=') && !d) {
                  const h = line.split('=')[1]?.trim()
                  if (h && h.includes('.')) d = h.split('.').slice(1).join('.')
                }
              }
            }
            if (d) return cb(null, d)
            exec('hostname -f', (e2, out2) => {
              if (e2) return cb(e2, null)
              const h = (out2 || '').trim()
              d = h.includes('.') ? h.split('.').slice(1).join('.') : null
              cb(null, d || null)
            })
          })
        }
        
        function checkDomainResolution(domain, type) {
          const mailDomain = domain
          if (type === 'public') {
            const cmdPublic = `nslookup ${mailDomain} 8.8.8.8`
            exec(cmdPublic, (err, out) => {
              const configured = !err && /Address:\s*[0-9a-fA-F:\.]+/m.test(out || '')
              resolve({ dns_configured: configured, domain, mail_domain: mailDomain, dns_type: 'public' })
            })
          } else {
            exec('systemctl is-active --quiet named', (bindErr) => {
              const tryLocal = !bindErr
              const cmdLocal = `nslookup ${mailDomain} 127.0.0.1`
              const cmdPublic = `nslookup ${mailDomain} 8.8.8.8`
              const execNs = (cmdA, fallback, cb) => {
                exec(cmdA, (errA, outA) => {
                  const okA = !errA && /Address:\s*[0-9a-fA-F:\.]+/m.test(outA || '')
                  if (okA) return cb(true)
                  exec(fallback, (errB, outB) => {
                    const okB = !errB && /Address:\s*[0-9a-fA-F:\.]+/m.test(outB || '')
                    cb(okB)
                  })
                })
              }
              if (tryLocal) {
                execNs(cmdLocal, cmdPublic, (configured) => resolve({ dns_configured: configured, domain, mail_domain: mailDomain, dns_type: 'bind' }))
              } else {
                execNs(cmdPublic, cmdLocal, (configured) => resolve({ dns_configured: configured, domain, mail_domain: mailDomain, dns_type: 'public' }))
              }
            })
          }
        }
        
        try {
          const systemSettings = JSON.parse(fs.readFileSync(path.join(ROOT_DIR, 'config', 'system-settings.json'), 'utf8'))
          const configured = systemSettings.dns?.configured === true
          const configuredType = systemSettings.dns?.type
          
          // 检查是否有实际的DNS配置（即使没有configured标记）
            const hasPublicDomain = systemSettings.dns?.public?.domain && systemSettings.dns.public.domain.trim() !== ''
            const hasBindDomain = systemSettings.dns?.bind?.domain && systemSettings.dns.bind.domain.trim() !== ''
          // 对于公网DNS，只要域名存在就认为已配置（serverIp可能为空或0.0.0.0，这不影响公网DNS的使用）
          const hasPublicServerIp = systemSettings.dns?.public?.serverIp && systemSettings.dns.public.serverIp.trim() !== '' && systemSettings.dns.public.serverIp !== '0.0.0.0'
          // 公网DNS只需要域名即可，serverIp是可选的
          const isPublicDnsConfigured = hasPublicDomain
            
          if (configured && (configuredType === 'public' || configuredType === 'bind')) {
            // 如果配置文件中标记为已配置，且类型正确
            if (configuredType === 'public' && isPublicDnsConfigured && !hasBindDomain) {
              dnsType = 'public'
              domain = systemSettings.dns.public.domain
            } else if (configuredType === 'bind' && hasBindDomain) {
              dnsType = 'bind'
              domain = systemSettings.dns.bind.domain
            } else {
              dnsType = null
              domain = null
            }
          } else if (hasBindDomain || isPublicDnsConfigured) {
            // 如果没有configured标记，但检测到有实际的DNS配置，也认为已配置（兼容旧配置）
            if (hasBindDomain) {
              dnsType = 'bind'
              domain = systemSettings.dns.bind.domain
            } else if (isPublicDnsConfigured) {
              dnsType = 'public'
              domain = systemSettings.dns.public.domain
            } else {
              dnsType = null
              domain = null
            }
            console.log('检测到DNS配置但缺少configured标记，自动识别为已配置:', dnsType, domain)
          } else {
            dnsType = null
            domain = null
          }
        } catch (error) {
          // 如果无法读取系统设置，从本机获取域名并推断公网/本地
          getDomainFromSystem((err, sysDomain) => {
            if (err || !sysDomain) {
              return resolve({ dns_configured: false, domain: null, mail_domain: null, dns_type: 'bind' })
            }
            domain = sysDomain
            exec('systemctl is-active --quiet named', (namedErr) => {
              const inferredType = namedErr ? 'public' : 'bind'
              checkDomainResolution(domain, inferredType)
            })
          })
          return
        }
        
        if (!domain) {
          // 无 system-settings 中的 dns 时，从本机获取域名并推断公网/本地（与 system-status 一致）
          getDomainFromSystem((err, sysDomain) => {
            if (err || !sysDomain) {
              return resolve({ dns_configured: false, domain: null, mail_domain: null, dns_type: dnsType || 'bind' })
            }
            domain = sysDomain
            exec('systemctl is-active --quiet named', (namedErr) => {
              const namedRunning = !namedErr
              const inferredType = namedRunning ? 'bind' : 'public'
              checkDomainResolution(domain, inferredType)
            })
          })
          return
        }
        
        checkDomainResolution(domain, dnsType)
      })
    }
    
    // 检查邮件数据库
    const checkMailDatabase = () => {
      return new Promise((resolve) => {
        try {
          const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
          exec(`bash "${mailDbScript}" stats "${user}"`, (error, stdout) => {
            const db_configured = !error
            resolve({ db_configured })
          })
        } catch (e) {
          resolve({ db_configured: false })
        }
      })
    }
    
    // 从系统设置读取 DNS 类型（用于 DNS 检查失败时的 fallback，与系统状态监控口径一致）
    function getDnsTypeFromSettings() {
      try {
        const systemSettings = JSON.parse(fs.readFileSync(path.join(ROOT_DIR, 'config', 'system-settings.json'), 'utf8'))
        const hasPublic = systemSettings.dns?.public?.domain && systemSettings.dns.public.domain.trim() !== ''
        const hasBind = systemSettings.dns?.bind?.domain && systemSettings.dns.bind.domain.trim() !== ''
        if (systemSettings.dns?.type === 'public' && hasPublic) return { dns_type: 'public', domain: systemSettings.dns.public.domain }
        if (systemSettings.dns?.type === 'bind' && hasBind) return { dns_type: 'bind', domain: systemSettings.dns.bind.domain }
        if (hasPublic && !hasBind) return { dns_type: 'public', domain: systemSettings.dns.public.domain }
        if (hasBind) return { dns_type: 'bind', domain: systemSettings.dns.bind.domain }
      } catch (e) { /* ignore */ }
      return { dns_type: 'bind', domain: null }
    }

    // 执行所有检查（容错：任一失败不至于500）
    Promise.allSettled([checkServices(), checkDNSResolution(), checkMailDatabase()])
      .then((results) => {
        const services = results[0].status === 'fulfilled' ? results[0].value : { postfix: false, dovecot: false, named: false, mariadb: false }
        let dns = results[1].status === 'fulfilled' ? results[1].value : { dns_configured: false, domain: null, mail_domain: null }
        // DNS 检查未返回或失败时，从系统设置补全 dns_type/domain，使公网用户不误判为需 Bind
        if (dns.dns_type == null) {
          const fromSettings = getDnsTypeFromSettings()
          dns = { ...dns, dns_type: fromSettings.dns_type, domain: dns.domain || fromSettings.domain, mail_domain: dns.mail_domain || fromSettings.domain }
        }
        const db = results[2].status === 'fulfilled' ? results[2].value : { db_configured: false }

        // 统一与 /api/system-status 的前端展示口径
        const systemServices = {
          postfix: services.postfix ? 'running' : 'stopped',
          dovecot: services.dovecot ? 'running' : 'stopped',
          mariadb: services.mariadb ? 'running' : 'stopped',
          named: services.named ? 'running' : 'stopped'
        }

        // 根据DNS类型判断服务要求
        const isPublicDns = dns.dns_type === 'public'
        const requiredServices = isPublicDns 
          ? [services.postfix, services.dovecot, services.mariadb] // 公网DNS不需要Bind服务
          : [services.postfix, services.dovecot, services.named, services.mariadb] // 本地DNS需要Bind服务
        
        const allServicesRunning = requiredServices.every(status => status === true)
        const mailSystemReady = allServicesRunning && dns.dns_configured && db.db_configured
        
        res.json({
          success: true,
          services: services,
          system_services: systemServices,
          dns: dns,
          database: db,
          mail_system_ready: mailSystemReady,
          recommendations: generateRecommendations(services, dns, db)
        })
      })
      .catch((error) => {
        console.error('Service status check error (unhandled):', error)
        const fallbackDns = { dns_configured: false, domain: null, mail_domain: null, ...getDnsTypeFromSettings() }
        res.json({
          success: true,
          services: { postfix: false, dovecot: false, named: false, mariadb: false },
          system_services: { postfix: 'stopped', dovecot: 'stopped', mariadb: 'stopped', named: 'stopped' },
          dns: fallbackDns,
          database: { db_configured: false },
          mail_system_ready: false,
          recommendations: generateRecommendations({ postfix: false, dovecot: false, named: false, mariadb: false }, fallbackDns, { db_configured: false })
        })
      })
    
  } catch (error) {
    console.error('Service status check error:', error)
    console.error('Error stack:', error.stack)
    res.status(500).json({
      success: false,
      error: 'Failed to check service status',
      message: error.message
    })
  }
})

// 获取邮件统计
app.get('/api/mail/stats', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const username = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 获取用户的真实邮箱地址（与mark_read API保持一致）
    let userEmail = username
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${username}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
      }
    } catch (emailError) {
      console.warn('Failed to get user email for stats, using username:', emailError.message)
    }
    
    // 记录邮件统计查询
    const logLine = `[${timestamp}] [MAIL_STATS] User: ${username}, Email: ${userEmail}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 使用真实邮件数据库获取统计
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    console.log('Mail stats - Script path:', mailDbScript)
    console.log('Mail stats - User:', username, 'Email:', userEmail)
    
    // 调用mail_db.sh获取统计信息（传递完整邮箱地址，与mark_read保持一致）
    exec(`bash "${mailDbScript}" stats "${userEmail}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail stats error:', error)
        console.error('Mail stats stderr:', stderr)
        res.status(500).json({
          success: false,
          error: 'Failed to get mail stats',
          message: error.message
        })
        return
      }
      
      try {
        const stats = JSON.parse(stdout)
        res.json({
          success: true,
          stats: stats
        })
      } catch (parseError) {
        console.error('Mail stats parse error:', parseError)
        console.error('Mail stats stdout:', stdout)
        res.status(500).json({
          success: false,
          error: 'Failed to parse mail stats',
          message: parseError.message
        })
      }
    })
    
  } catch (error) {
    console.error('Mail stats error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get mail stats',
      message: error.message
    })
  }
})

// 获取邮件详情 - 已移至文件末尾以避免路由冲突
/*
app.get('/api/mail/:id', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const username = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 获取用户的真实邮箱地址（与mark_read API保持一致）
    let userEmail = username
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${username}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
      }
    } catch (emailError) {
      console.warn('Failed to get user email for detail, using username:', emailError.message)
    }
    
    // 记录邮件详情查询
    const logLine = `[${timestamp}] [MAIL_READ] User: ${username}, Email: ${userEmail}, MailID: ${id}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 使用真实邮件数据库
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    // 调用mail_db.sh获取邮件详情（传递完整邮箱地址，与mark_read保持一致）
    exec(`bash "${mailDbScript}" detail "${id}" "${userEmail}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail detail error:', error)
        console.error('Mail detail stderr:', stderr)
        console.error('Mail detail stdout:', stdout)
        res.status(500).json({
          success: false,
          error: 'Mail detail script error',
          message: error.message,
          stderr: stderr,
          stdout: stdout
        })
        return
      }
      
      try {
        // 直接使用正则表达式提取JSON，避免换行符问题
        const jsonMatch = stdout.match(/\[.*\]/s)
        if (!jsonMatch) {
          throw new Error('No JSON array found in output')
        }
        const cleanStdout = jsonMatch[0]
        console.log('Extracted JSON:', cleanStdout)
        const emailData = JSON.parse(cleanStdout)
        if (emailData.length === 0) {
          res.status(404).json({
            success: false,
            error: 'Mail not found',
            message: 'The requested mail could not be found'
          })
          return
        }
        
        const email = emailData[0]
        const attachments = email.attachments && email.attachments !== '[]' && email.attachments !== '' ? (() => {
          try {
            const parsed = JSON.parse(email.attachments)
            console.log('Parsed attachments:', parsed)
            return parsed
          } catch (e) {
            console.error('Failed to parse attachments:', email.attachments)
            return []
          }
        })() : []
        
        console.log('Final attachments:', attachments)
        
        // 处理收件人（新格式）
        const recipients = email.recipients || { to: [], cc: [], bcc: [] }
        // 向后兼容：如果没有recipients，使用to和cc字段
        if (!recipients.to || recipients.to.length === 0) {
          if (email.to) {
            recipients.to = email.to.split(',').map(addr => addr.trim())
          }
        }
        if (!recipients.cc || recipients.cc.length === 0) {
          if (email.cc) {
            recipients.cc = email.cc.split(',').map(addr => addr.trim())
          }
        }
        
        // 处理标签（确保是数组）
        const labels = email.labels || []
        
        // 处理元数据
        const metadata = email.metadata || {}
        
        res.json({
          id: email.id,
          from: email.from,
          to: email.to, // 保留向后兼容
          cc: email.cc, // 保留向后兼容
          subject: email.subject,
          date: email.date,
          body: email.body,
          html: email.html || email.body.replace(/\n/g, '<br>'),
          read: email.read === 1,
          folder: email.folder,
          size: email.size,
          attachments: attachments,
          headers: email.headers ? (typeof email.headers === 'string' ? JSON.parse(email.headers) : email.headers) : {},
          recipients: recipients, // 新增：多收件人
          labels: labels, // 新增：标签数组
          metadata: metadata // 新增：元数据
        })
      } catch (parseError) {
        console.error('Mail detail parse error:', parseError)
        res.status(500).json({
          success: false,
          error: 'Failed to parse mail data',
          message: parseError.message
        })
      }
    })
    
  } catch (error) {
    console.error('Mail detail error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get mail detail',
      message: error.message
    })
  }
})
*/

// 删除邮件
app.delete('/api/mail/:id', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录邮件删除操作
    const logLine = `[${timestamp}] [MAIL_DELETE] User: ${user}, MailID: ${id}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 使用真实邮件数据库删除邮件
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" delete "${id}" "${user}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail delete error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to delete mail',
          message: error.message
        })
        return
      }
      
      res.json({
        success: true,
        message: 'Email deleted successfully'
      })
    })
    
  } catch (error) {
    console.error('Mail delete error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to delete email',
      message: error.message
    })
  }
})

// 还原邮件（从已删除文件夹恢复到原文件夹）
app.post('/api/mail/:id/restore', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录邮件还原操作
    const logLine = `[${timestamp}] [MAIL_RESTORE] User: ${user}, MailID: ${id}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" restore "${id}" "${user}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail restore error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to restore mail',
          message: error.message || stderr.toString()
        })
        return
      }
      
      res.json({
        success: true,
        message: 'Email restored successfully'
      })
    })
    
  } catch (error) {
    console.error('Mail restore error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to restore email',
      message: error.message
    })
  }
})

// 彻底删除邮件（硬删除）
app.delete('/api/mail/:id/permanent', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录邮件彻底删除操作
    const logLine = `[${timestamp}] [MAIL_HARD_DELETE] User: ${user}, MailID: ${id}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" hard-delete "${id}" "${user}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail hard delete error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to permanently delete mail',
          message: error.message || stderr.toString()
        })
        return
      }
      
      res.json({
        success: true,
        message: 'Email permanently deleted'
      })
    })
    
  } catch (error) {
    console.error('Mail hard delete error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to permanently delete email',
      message: error.message
    })
  }
})

// 获取文件夹列表
app.get('/api/mail/folders', auth, (req, res) => {
  try {
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    const username = getUsernameFromRequest(req)
    
    // 获取mail_users表的用户ID（用于邮件系统）
    getMailUserIdFromUsername(username, (err, userId) => {
      if (err) {
        console.error('Error getting mail user ID:', err)
        return res.status(500).json({
          success: false,
          error: 'Failed to get mail user ID'
        })
      }
      
      const userIdParam = userId ? userId.toString() : 'NULL'
      console.log(`[Folders API] Username: ${username}, Mail User ID: ${userIdParam}`)
      
      exec(`bash "${mailDbScript}" folders "${userIdParam}"`, (error, stdout, stderr) => {
        if (error) {
          console.error('Folders list error:', error)
          console.error('Folders stderr:', stderr)
          res.status(500).json({
            success: false,
            error: 'Failed to get folders',
            message: error.message
          })
          return
        }
        
        try {
          const folders = JSON.parse(stdout)
          console.log(`[Folders API] Retrieved ${folders.length} folders for user ${userIdParam}`)
          if (folders.length > 0) {
            console.log(`[Folders API] Folder details:`, folders.map((f) => ({
              id: f.id,
              name: f.name,
              folder_type: f.folder_type,
              user_id: f.user_id,
              is_active: f.is_active
            })))
          } else {
            console.log(`[Folders API] No folders found for user ${userIdParam}, checking database...`)
            // 调试：查询数据库中是否有该用户的文件夹
            const mailDbPass = getMailDbPassword()
            const debugQuery = `mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id, name, folder_type, user_id, is_active FROM email_folders WHERE folder_type='user' ORDER BY id DESC LIMIT 10;" 2>&1`
            exec(debugQuery, (debugError, debugStdout, debugStderr) => {
              if (!debugError && debugStdout) {
                console.log(`[Folders API] Debug - Recent user folders in DB:\n${debugStdout}`)
              }
              // 同时查询 mail_users 表中的用户信息
              const userQuery = `mysql -u mailuser -p"${getMailDbPassword().replace(/"/g, '\\"')}" maildb -s -r -e "SELECT id, username, email FROM mail_users WHERE username='${username}' OR email LIKE '%${username}%' LIMIT 5;" 2>&1`
              exec(userQuery, (userError, userStdout, userStderr) => {
                if (!userError && userStdout) {
                  console.log(`[Folders API] Debug - Mail users matching '${username}':\n${userStdout}`)
                }
              })
            })
          }
          res.json({
            success: true,
            folders: folders
          })
        } catch (parseError) {
          console.error('Folders parse error:', parseError)
          console.error('Folders stdout:', stdout)
          res.json({
            success: true,
            folders: []
          })
        }
      })
    })
  } catch (error) {
    console.error('Folders error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get folders',
      message: error.message
    })
  }
})

// 获取文件夹统计信息
app.get('/api/mail/folders/:id/stats', auth, (req, res) => {
  try {
    const { id } = req.params
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" folder-stats "${id}" "${user}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Folder stats error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to get folder stats',
          message: error.message
        })
        return
      }
      
      try {
        const stats = JSON.parse(stdout)
        res.json({
          success: true,
          stats: stats
        })
      } catch (parseError) {
        console.error('Folder stats parse error:', parseError)
        res.json({
          success: true,
          stats: { total: 0, unread: 0, read: 0, size: 0 }
        })
      }
    })
  } catch (error) {
    console.error('Folder stats error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get folder stats',
      message: error.message
    })
  }
})

// 获取邮件发送趋势统计
app.get('/api/mail/stats/sending-trends', auth, (req, res) => {
  try {
    const { period = 'day' } = req.query // hour/day/week
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" sending-trends "${period}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Sending trends error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to get sending trends',
          message: error.message
        })
        return
      }
      
      try {
        // 检查stdout是否为空或无效
        if (!stdout || stdout.trim() === '' || stdout.trim().toUpperCase() === 'NULL') {
          console.warn('Sending trends: stdout为空或NULL，返回空数组')
          res.json({
            success: true,
            data: []
          })
          return
        }
        
        const trends = JSON.parse(stdout.trim())
        res.json({
          success: true,
          data: trends
        })
      } catch (parseError) {
        console.error('Sending trends parse error:', parseError)
        console.error('Sending trends stdout:', stdout)
        console.error('Sending trends stderr:', stderr)
        res.json({
          success: true,
          data: []
        })
      }
    })
  } catch (error) {
    console.error('Sending trends error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get sending trends',
      message: error.message
    })
  }
})

// 获取发送频率vs发送数量关系统计
app.get('/api/mail/stats/frequency-analysis', auth, (req, res) => {
  try {
    const { group_by = 'user' } = req.query // user/day
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" frequency-analysis "${group_by}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Frequency analysis error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to get frequency analysis',
          message: error.message
        })
        return
      }
      
      try {
        // 检查stdout是否为空或无效
        if (!stdout || stdout.trim() === '' || stdout.trim().toUpperCase() === 'NULL') {
          console.warn('Frequency analysis: stdout为空或NULL，返回空数组')
          res.json({
            success: true,
            data: []
          })
          return
        }
        
        const analysis = JSON.parse(stdout.trim())
        res.json({
          success: true,
          data: analysis
        })
      } catch (parseError) {
        console.error('Frequency analysis parse error:', parseError)
        console.error('Frequency analysis stdout:', stdout)
        console.error('Frequency analysis stderr:', stderr)
        res.json({
          success: true,
          data: []
        })
      }
    })
  } catch (error) {
    console.error('Frequency analysis error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get frequency analysis',
      message: error.message
    })
  }
})

// 创建自定义文件夹
app.post('/api/mail/folders', auth, (req, res) => {
  try {
    const { name, display_name } = req.body
    
    if (!name) {
      return res.status(400).json({
        success: false,
        error: '文件夹名称不能为空'
      })
    }
    
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    const username = getUsernameFromRequest(req)
    
    // 获取mail_users表的用户ID（用于邮件系统）
    getMailUserIdFromUsername(username, (err, userId) => {
      if (err) {
        console.error('Error getting mail user ID:', err)
        return res.status(500).json({
          success: false,
          error: 'Failed to get mail user ID'
        })
      }
      
      if (!userId) {
        return res.status(400).json({
          success: false,
          error: '无法获取邮件用户ID，请先登录'
        })
      }
      
      const userIdParam = userId.toString()
      console.log(`[Create Folder] Username: ${username}, Mail User ID: ${userIdParam}, Folder: ${name}`)
      console.log(`[Create Folder] Command: bash "${mailDbScript}" add-folder "${name}" "${display_name || name}" "${userIdParam}"`)
      
      exec(`bash "${mailDbScript}" add-folder "${name}" "${display_name || name}" "${userIdParam}"`, (error, stdout, stderr) => {
        console.log(`[Create Folder] stdout:`, stdout)
        if (stderr) console.log(`[Create Folder] stderr:`, stderr)
        // 先尝试解析stdout，即使有error也可能包含JSON格式的错误信息
        let result = null
        try {
          if (stdout && stdout.trim()) {
            result = JSON.parse(stdout)
          }
        } catch (parseError) {
          // 如果解析失败，继续处理error情况
          console.error('Add folder parse error:', parseError, 'stdout:', stdout)
        }
        
        // 如果成功解析到结果，优先使用解析的结果
        if (result) {
          if (result.success) {
            res.json({
              success: true,
              folder: result
            })
          } else {
            // 脚本返回的错误（如验证失败、已存在等）
            res.status(400).json({
              success: false,
              error: result.error || 'Failed to create folder'
            })
          }
          return
        }
        
        // 如果没有解析到结果，处理exec error
        if (error) {
          console.error('Add folder error:', error)
          const errorMsg = stderr || stdout || error.message
          res.status(500).json({
            success: false,
            error: 'Failed to create folder',
            message: errorMsg.toString()
          })
          return
        }
        
        // 如果既没有error也没有result，返回未知错误
        res.status(500).json({
          success: false,
          error: 'Failed to create folder',
          message: 'Unknown error occurred'
        })
      })
    })
  } catch (error) {
    console.error('Add folder error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to create folder',
      message: error.message
    })
  }
})

// 更新自定义文件夹
app.put('/api/mail/folders/:id', auth, (req, res) => {
  try {
    const { id } = req.params
    const { name, display_name } = req.body
    
    if (!name && !display_name) {
      return res.status(400).json({
        success: false,
        error: '至少需要提供名称或显示名称之一'
      })
    }
    
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    const username = getUsernameFromRequest(req)
    
    // 获取用户ID
    getUserIdFromUsername(username, (err, userId) => {
      if (err) {
        console.error('Error getting user ID:', err)
        return res.status(500).json({
          success: false,
          error: 'Failed to get user ID'
        })
      }
      
      if (!userId) {
        return res.status(400).json({
          success: false,
          error: '无法获取用户ID，请先登录'
        })
      }
      
      const nameParam = name || ''
      const displayNameParam = display_name || ''
      const userIdParam = userId.toString()
      
      exec(`bash "${mailDbScript}" update-folder "${id}" "${nameParam}" "${displayNameParam}" "${userIdParam}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Update folder error:', error)
        const errorMsg = stderr || stdout || error.message
        res.status(500).json({
          success: false,
          error: 'Failed to update folder',
          message: errorMsg.toString()
        })
        return
      }
      
        try {
          const result = JSON.parse(stdout)
          if (result.success) {
            res.json({
              success: true,
              folder: result
            })
          } else {
            res.status(400).json({
              success: false,
              error: result.error || 'Failed to update folder'
            })
          }
        } catch (parseError) {
          console.error('Update folder parse error:', parseError, stdout)
          res.status(500).json({
            success: false,
            error: 'Failed to parse response',
            message: stdout.toString()
          })
        }
      })
    })
  } catch (error) {
    console.error('Update folder error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to update folder',
      message: error.message
    })
  }
})

// 删除自定义文件夹
app.delete('/api/mail/folders/:id', auth, (req, res) => {
  try {
    const { id } = req.params
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    const username = getUsernameFromRequest(req)
    
    // 获取用户ID
    getUserIdFromUsername(username, (err, userId) => {
      if (err) {
        console.error('Error getting user ID:', err)
        return res.status(500).json({
          success: false,
          error: 'Failed to get user ID'
        })
      }
      
      if (!userId) {
        return res.status(400).json({
          success: false,
          error: '无法获取用户ID，请先登录'
        })
      }
      
      const userIdParam = userId.toString()
      
      exec(`bash "${mailDbScript}" delete-folder "${id}" "${userIdParam}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Delete folder error:', error)
        const errorMsg = stderr || stdout || error.message
        res.status(500).json({
          success: false,
          error: 'Failed to delete folder',
          message: errorMsg.toString()
        })
        return
      }
      
        try {
          const result = JSON.parse(stdout)
          if (result.success) {
            res.json({
              success: true,
              message: '文件夹已删除'
            })
          } else {
            res.status(400).json({
              success: false,
              error: result.error || 'Failed to delete folder'
            })
          }
        } catch (parseError) {
          console.error('Delete folder parse error:', parseError, stdout)
          res.status(500).json({
            success: false,
            error: 'Failed to parse response',
            message: stdout.toString()
          })
        }
      })
    })
  } catch (error) {
    console.error('Delete folder error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to delete folder',
      message: error.message
    })
  }
})

// 获取标签列表
app.get('/api/mail/labels', auth, (req, res) => {
  try {
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" labels`, (error, stdout, stderr) => {
      if (error) {
        console.error('Labels list error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to get labels',
          message: error.message
        })
        return
      }
      
      try {
        const labels = JSON.parse(stdout)
        res.json({
          success: true,
          labels: labels
        })
      } catch (parseError) {
        console.error('Labels parse error:', parseError)
        res.json({
          success: true,
          labels: []
        })
      }
    })
  } catch (error) {
    console.error('Labels error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get labels',
      message: error.message
    })
  }
})

// 为邮件添加标签
app.post('/api/mail/:id/labels', auth, (req, res) => {
  try {
    const { id } = req.params
    const { labelId } = req.body
    
    if (!labelId) {
      return res.status(400).json({
        success: false,
        error: 'labelId is required'
      })
    }
    
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" add-label "${id}" "${labelId}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Add label error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to add label',
          message: error.message
        })
        return
      }
      
      res.json({
        success: true,
        message: 'Label added successfully'
      })
    })
  } catch (error) {
    console.error('Add label error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to add label',
      message: error.message
    })
  }
})

// 移除邮件标签
app.delete('/api/mail/:id/labels/:labelId', auth, (req, res) => {
  try {
    const { id, labelId } = req.params
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" remove-label "${id}" "${labelId}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Remove label error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to remove label',
          message: error.message
        })
        return
      }
      
      res.json({
        success: true,
        message: 'Label removed successfully'
      })
    })
  } catch (error) {
    console.error('Remove label error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to remove label',
      message: error.message
    })
  }
})

// 移动邮件到文件夹
app.put('/api/mail/:id/move', auth, (req, res) => {
  try {
    const { id } = req.params
    const { folder } = req.body
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    if (!folder) {
      return res.status(400).json({
        success: false,
        error: 'folder is required'
      })
    }
    
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    exec(`bash "${mailDbScript}" move "${id}" "${folder}" "${user}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Move email error:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to move email',
          message: error.message
        })
        return
      }
      
      res.json({
        success: true,
        message: 'Email moved successfully'
      })
    })
  } catch (error) {
    console.error('Move email error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to move email',
      message: error.message
    })
  }
})

// 标记邮件为已读
app.put('/api/mail/:id/read', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const username = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 获取用户的真实邮箱地址
    let userEmail = username
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${username}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
      }
    } catch (emailError) {
      console.warn('Failed to get user email for mark read, using username:', emailError.message)
    }
    
    // 记录邮件标记操作
    const logLine = `[${timestamp}] [MAIL_MARK_READ] User: ${username}, Email: ${userEmail}, MailID: ${id}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)
    
    // 调用mail_db.sh更新邮件为已读状态（传递用户邮箱地址）
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    exec(`bash "${mailDbScript}" mark_read "${id}" "${userEmail}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Failed to mark email as read:', error)
        console.error('stderr:', stderr)
        res.status(500).json({
          success: false,
          error: 'Failed to mark email as read',
          message: error.message
        })
      } else {
        console.log('Email marked as read successfully:', id)
        res.json({
          success: true,
          message: 'Email marked as read'
        })
      }
    })
    
  } catch (error) {
    console.error('Mail mark read error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to mark email as read',
      message: error.message
    })
  }
})

// 生成建议信息
function generateRecommendations(services, dns, db) {
  const recommendations = []
  
  if (!services.postfix) {
    recommendations.push({
      type: 'service',
      service: 'Postfix',
      message: '邮件发送服务未运行，请先安装和配置邮件服务',
      action: 'install-mail'
    })
  }
  
  if (!services.dovecot) {
    recommendations.push({
      type: 'service',
      service: 'Dovecot',
      message: '邮件接收服务未运行，请先安装和配置邮件服务',
      action: 'install-mail'
    })
  }
  
  // 根据DNS类型判断是否需要Bind服务
  const isPublicDns = dns.dns_type === 'public'
  if (!isPublicDns && !services.named) {
    recommendations.push({
      type: 'service',
      service: 'Bind DNS',
      message: 'DNS服务未运行，请先安装和配置DNS服务',
      action: 'install-dns'
    })
  }
  
  if (!services.mariadb) {
    recommendations.push({
      type: 'service',
      service: 'MariaDB',
      message: '数据库服务未运行，请先安装和配置数据库服务',
      action: 'install-database'
    })
  }
  
  if (!dns.dns_configured) {
    if (isPublicDns) {
      recommendations.push({
        type: 'dns',
        message: `公网DNS解析未配置，请确保域名 ${dns.domain || 'your-domain.com'} 的DNS记录已正确配置到公网DNS服务器`,
        action: 'configure-public-dns'
      })
    } else {
      recommendations.push({
        type: 'dns',
        message: `DNS解析未配置，请配置域名 ${dns.domain || 'your-domain.com'} 的DNS记录`,
        action: 'configure-dns'
      })
    }
  }
  
  if (!db.db_configured) {
    recommendations.push({
      type: 'database',
      message: '邮件数据库未初始化，请先初始化邮件系统',
      action: 'init-mail-db'
    })
  }
  
  return recommendations
}

// 用户日志查看API端点
app.get('/api/logs', auth, (req, res) => {
  try {
    const { 
      type = 'all',           // 日志类型: all, user, mail, system, terminal
      user = '',              // 用户过滤
      action = '',            // 操作过滤
      search = '',            // 搜索关键词
      limit = 50,             // 限制条数
      format = 'json'         // 导出格式: json, csv, txt
    } = req.query
    
    // 根据类型选择日志文件
    let logFiles = []
    switch (type) {
      case 'user':
        logFiles = [path.join(LOG_DIR, 'user-operations.log')]
        break
      case 'mail':
        logFiles = [path.join(LOG_DIR, 'mail-operations.log')]
        break
      case 'system':
        logFiles = [path.join(LOG_DIR, 'system.log')]
        break
      case 'terminal':
        logFiles = [path.join(LOG_DIR, 'user-operations.log')]
        break
      case 'unknown':
        // 未知日志需要从所有日志文件中查找
        logFiles = [
          path.join(LOG_DIR, 'user-operations.log'),
          path.join(LOG_DIR, 'mail-operations.log'),
          path.join(LOG_DIR, 'system.log')
        ]
        break
      case 'all':
      default:
        logFiles = [
          path.join(LOG_DIR, 'user-operations.log'),
          path.join(LOG_DIR, 'mail-operations.log'),
          path.join(LOG_DIR, 'system.log')
        ]
        break
    }
    
    let allLogs = []
    
    // 读取所有相关日志文件
    for (const logFile of logFiles) {
      if (fs.existsSync(logFile)) {
        const logContent = fs.readFileSync(logFile, 'utf8')
        const logLines = logContent.split('\n').filter(line => line.trim())
        
        const logs = logLines.map(line => {
          // 解析日志行格式 - 改进的解析逻辑
          const timestampMatch = line.match(/\[([^\]]+)\]/)
          const typeMatch = line.match(/\[([A-Z_]+)\]/)
          const userMatch = line.match(/User: ([^,]+)/)
          const actionMatch = line.match(/Action: ([^,]+)/)
          const categoryMatch = line.match(/Category: ([^,]+)/)
          const ipMatch = line.match(/IP: ([^\s,]+)/)
          const userAgentMatch = line.match(/UserAgent: ([^,]+)/)
          const detailsMatch = line.match(/Details: ({.*})/)
          
          // 如果没有找到标准格式，尝试其他格式
          let logType = typeMatch ? typeMatch[1] : 'UNKNOWN'
          let logUser = userMatch ? userMatch[1] : 'unknown'
          let logAction = actionMatch ? actionMatch[1] : 'unknown'
          let logCategory = categoryMatch ? categoryMatch[1] : 'general'
          let logIP = ipMatch ? ipMatch[1] : 'unknown'
          let logUserAgent = userAgentMatch ? userAgentMatch[1] : 'unknown'
          let logDetails = {}
          
          // 解析详细信息
          if (detailsMatch) {
            try {
              logDetails = JSON.parse(detailsMatch[1])
            } catch (e) {
              logDetails = { raw: detailsMatch[1] }
            }
          }
          
          // 处理特殊格式的日志行
          if (logType === 'UNKNOWN') {
            // 检查是否是代码行（包含import、const、function等）
            if (line.includes('import ') || line.includes('const ') || line.includes('function ') || 
                line.includes('app.') || line.includes('//') || line.includes('/*')) {
              logType = 'CODE_SNIPPET'
              logUser = 'system'
              logAction = 'code_display'
            }
            // 检查是否是输出内容
            else if (line.includes('OutputPreview:') || line.includes('Output:')) {
              logType = 'TERMINAL_OUTPUT'
              logUser = 'system'
              logAction = 'output_display'
            }
            // 检查是否是错误信息
            else if (line.includes('Error:') || line.includes('error:')) {
              logType = 'ERROR_MESSAGE'
              logUser = 'system'
              logAction = 'error_display'
            }
            // 检查是否是调试信息
            else if (line.includes('DEBUG') || line.includes('debug')) {
              logType = 'DEBUG_INFO'
              logUser = 'system'
              logAction = 'debug_display'
            }
          }
          
          return {
            timestamp: timestampMatch ? timestampMatch[1] : new Date().toISOString(),
            type: logType,
            user: logUser,
            action: logAction,
            category: logCategory,
            ip: logIP,
            userAgent: logUserAgent,
            details: logDetails,
            message: line,
            source: path.basename(logFile)
          }
        })
        
        allLogs = allLogs.concat(logs)
      }
    }
    
    // 应用过滤条件
    let filteredLogs = allLogs
    
    // 特殊处理：未知日志类型过滤
    if (type === 'unknown') {
      filteredLogs = filteredLogs.filter(log => 
        log.type === 'UNKNOWN' || log.type === 'unknown'
      )
    }
    
    // 用户过滤
    if (user) {
      filteredLogs = filteredLogs.filter(log => 
        log.user.toLowerCase().includes(user.toLowerCase())
      )
    }
    
    // 操作过滤
    if (action) {
      filteredLogs = filteredLogs.filter(log => 
        log.action.toLowerCase().includes(action.toLowerCase())
      )
    }
    
    // 搜索过滤
    if (search) {
      filteredLogs = filteredLogs.filter(log => 
        log.message.toLowerCase().includes(search.toLowerCase())
      )
    }
    
    // 按时间排序（最新的在前）
    filteredLogs.sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
    
    // 限制条数
    filteredLogs = filteredLogs.slice(0, parseInt(limit))
    
    // 根据格式返回数据
    if (format === 'csv') {
      const csvHeader = 'Timestamp,Type,User,Action,IP,Message,Source\n'
      const csvData = filteredLogs.map(log => 
        `"${log.timestamp}","${log.type}","${log.user}","${log.action}","${log.ip}","${log.message.replace(/"/g, '""')}","${log.source}"`
      ).join('\n')
      
      res.setHeader('Content-Type', 'text/csv')
      res.setHeader('Content-Disposition', 'attachment; filename="mail-logs.csv"')
      res.send(csvHeader + csvData)
      return
    } else if (format === 'txt') {
      const txtData = filteredLogs.map(log => log.message).join('\n')
      
      res.setHeader('Content-Type', 'text/plain')
      res.setHeader('Content-Disposition', 'attachment; filename="mail-logs.txt"')
      res.send(txtData)
      return
    }
    
    // 默认返回JSON格式
    res.json({
      success: true,
      logs: filteredLogs,
      total: filteredLogs.length,
      filters: {
        type,
        user,
        action,
        search,
        limit
      }
    })
  } catch (error) {
    console.error('Failed to read user logs:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to read user logs'
    })
  }
})


// 终端命令执行API端点
app.post('/api/terminal', auth, (req, res) => {
  const user = req.headers.authorization ? 
    Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 
    'unknown'
  const timestamp = new Date().toISOString()
  const clientIP = getRealClientIP(req)
  
  try {
    const { command } = req.body || {}
    console.log('Received command request:', { command, body: req.body })
    
    if (!command) {
      console.log('No command provided, returning error')
      return res.status(400).json({ error: 'Command is required' })
    }
    
    // 记录详细的终端命令开始信息
    const commandStartTime = Date.now()
    const workingDir = process.cwd()
    const nodeVersion = process.version
    const platform = process.platform
    const sessionId = req.headers['x-session-id'] || 'unknown'
    
    const detailedLogLine = `[${timestamp}] [TERMINAL_COMMAND_START] User: ${user}, Command: "${command}", IP: ${clientIP}, Session: ${sessionId}, WorkingDir: ${workingDir}, NodeVersion: ${nodeVersion}, Platform: ${platform}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), detailedLogLine)
    
    // 记录命令执行环境信息（命令终端使用 euser 用户）
    const envInfo = {
      USER: 'euser',
      HOME: '/home/euser',
      SHELL: '/bin/bash',
      TERM: 'xterm-256color',
      LANG: 'en_US.UTF-8',
      LC_ALL: 'en_US.UTF-8',
      PWD: workingDir,
      OLDPWD: workingDir,
      PATH: process.env.PATH
    }
    
    const envLogLine = `[${timestamp}] [TERMINAL_ENV] User: ${user}, Command: "${command}", Environment: ${JSON.stringify(envInfo)}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), envLogLine)
    
    console.log(`Executing command: ${command}`)
    console.log(`Current working directory: ${workingDir}`)
    console.log(`Node.js version: ${nodeVersion}`)
    console.log(`Platform: ${platform}`)
    console.log(`Session ID: ${sessionId}`)
    
    try {
      const output = execSync(command, {
        encoding: 'utf8',
        timeout: 30000,
        env: envInfo
      })
      
      const commandEndTime = Date.now()
      const executionTime = commandEndTime - commandStartTime
      
      console.log(`Command output: ${output}`)
      console.log(`Command execution time: ${executionTime}ms`)
      
      // 记录详细的命令执行结果
      const resultLog = `[${timestamp}] [TERMINAL_COMMAND_SUCCESS] User: ${user}, Command: "${command}", ExitCode: 0, ExecutionTime: ${executionTime}ms, OutputLength: ${output.length}, IP: ${clientIP}, Session: ${sessionId}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), resultLog)
      
      // 如果输出较长，记录输出摘要
      if (output.length > 1000) {
        const outputSummary = `[${timestamp}] [TERMINAL_OUTPUT_SUMMARY] User: ${user}, Command: "${command}", OutputPreview: "${output.substring(0, 500)}...", FullLength: ${output.length}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), outputSummary)
      } else {
        const outputLog = `[${timestamp}] [TERMINAL_OUTPUT] User: ${user}, Command: "${command}", Output: "${output.replace(/\n/g, '\\n')}"\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), outputLog)
      }
      
      res.json({
        success: true,
        output: output,
        exitCode: 0,
        executionTime: executionTime,
        outputLength: output.length
      })
      
    } catch (error) {
      const commandEndTime = Date.now()
      const executionTime = commandEndTime - commandStartTime
      
      console.error('Command execution error:', error)
      console.log(`Command execution time: ${executionTime}ms`)
      
      // 记录详细的错误信息
      const errorLog = `[${timestamp}] [TERMINAL_COMMAND_ERROR] User: ${user}, Command: "${command}", ExitCode: ${error.status || -1}, ExecutionTime: ${executionTime}ms, Error: "${error.message}", IP: ${clientIP}, Session: ${sessionId}\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), errorLog)
      
      // 记录错误输出
      if (error.stdout) {
        const stdoutLog = `[${timestamp}] [TERMINAL_STDOUT] User: ${user}, Command: "${command}", Stdout: "${error.stdout.replace(/\n/g, '\\n')}"\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), stdoutLog)
      }
      
      if (error.stderr) {
        const stderrLog = `[${timestamp}] [TERMINAL_STDERR] User: ${user}, Command: "${command}", Stderr: "${error.stderr.replace(/\n/g, '\\n')}"\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), stderrLog)
      }
      
      res.json({
        success: false,
        output: error.stdout || error.stderr || error.message,
        exitCode: error.status || -1,
        executionTime: executionTime,
        error: error.message
      })
    }
    
  } catch (err) {
    console.error('Failed to execute terminal command:', err.message)
    
    // 记录系统级错误
    const systemErrorLog = `[${timestamp}] [TERMINAL_SYSTEM_ERROR] User: ${user}, Command: "${req.body?.command || 'unknown'}", Error: "${err.message}", IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), systemErrorLog)
    
    res.status(500).json({ error: 'failed to execute command' })
  }
})

// 域名管理API端点
// 获取所有域名
app.get('/api/system/domains', auth, (req, res) => {
  try {
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 记录域名查询操作
    const logLine = `[${timestamp}] [DOMAIN_LIST] User: ${user}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    // 调用mail_db.sh获取域名列表
    const mailDbScript = path.join(__dirname, '..', 'scripts', 'mail_db.sh')
    exec(`bash "${mailDbScript}" list_domains`, (error, stdout, stderr) => {
      if (error) {
        console.error('Failed to get domains:', error)
        res.status(500).json({
          success: false,
          error: 'Failed to get domains',
          message: error.message
        })
      } else {
        try {
          const domains = JSON.parse(stdout.trim())
          res.json({
            success: true,
            domains: domains
          })
        } catch (parseError) {
          console.error('Failed to parse domains:', parseError)
          res.status(500).json({
            success: false,
            error: 'Failed to parse domains',
            message: parseError.message
          })
        }
      }
    })
    
  } catch (error) {
    console.error('Domain list error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get domains',
      message: error.message
    })
  }
})

// 添加域名
app.post('/api/system/domains', auth, (req, res) => {
  try {
    const { domain } = req.body
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    if (!domain || !domain.trim()) {
      res.status(400).json({
        success: false,
        error: 'Domain is required',
        message: '域名不能为空'
      })
      return
    }
    
    // 记录域名添加操作
    const logLine = `[${timestamp}] [DOMAIN_ADD] User: ${user}, Domain: ${domain.trim()}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    // 调用mail_db.sh添加域名
    const mailDbScript = path.join(__dirname, '..', 'scripts', 'mail_db.sh')
    exec(`bash "${mailDbScript}" add_domain "${domain.trim()}"`, (error, stdout, stderr) => {
      // 检查stdout中是否包含成功消息
      const stdoutStr = stdout ? stdout.toString() : ''
      const stderrStr = stderr ? stderr.toString() : ''
      
      if (stdoutStr.includes('域名添加成功')) {
        console.log('Domain added successfully:', domain.trim(), 'stdout:', stdoutStr)
        res.json({
          success: true,
          message: '域名添加成功'
        })
      } else if (stdoutStr.includes('错误: 域名') && stdoutStr.includes('已存在')) {
        // 域名已存在的情况
        console.log('Domain already exists:', domain.trim())
        res.status(400).json({
          success: false,
          error: 'Domain already exists',
          message: stdoutStr.trim() || '域名已存在'
        })
      } else if (error || stderrStr) {
        // 真正的错误
        console.error('Failed to add domain:', error, 'stderr:', stderrStr, 'stdout:', stdoutStr)
        res.status(500).json({
          success: false,
          error: 'Failed to add domain',
          message: stderrStr.trim() || stdoutStr.trim() || error?.message || '添加域名失败'
        })
      } else {
        // 未知情况，但可能成功
        console.log('Domain add completed (unknown status):', domain.trim(), 'stdout:', stdoutStr)
        res.json({
          success: true,
          message: '域名添加成功'
        })
      }
    })
    
  } catch (error) {
    console.error('Domain add error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to add domain',
      message: error.message
    })
  }
})

// 删除域名
app.delete('/api/system/domains/:id', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const user = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'
    
    // 先检查要删除的域名是否是DNS配置的域名
    const mailDbScript = path.join(__dirname, '..', 'scripts', 'mail_db.sh')
    exec(`bash "${mailDbScript}" list_domains`, (listError, listStdout) => {
      if (listError) {
        return res.status(500).json({
          success: false,
          error: 'Failed to get domains',
          message: '无法获取域名列表'
        })
      }
      
      try {
        const domains = JSON.parse(listStdout.toString())
        const domainToDelete = domains.find(d => d.id === id)
        
        if (!domainToDelete) {
          return res.status(404).json({
            success: false,
            error: 'Domain not found',
            message: '域名不存在'
          })
        }
        
        // 检查是否是DNS配置的域名
        const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
        let dnsDomain = null
        if (fs.existsSync(settingsFile)) {
          try {
            const settingsData = fs.readFileSync(settingsFile, 'utf8')
            const settings = JSON.parse(settingsData)
            dnsDomain = settings.dns?.bind?.domain || settings.dns?.public?.domain
          } catch (err) {
            console.warn('读取系统设置失败:', err.message)
          }
        }
        
        if (dnsDomain && domainToDelete.name.toLowerCase() === dnsDomain.toLowerCase()) {
          return res.status(400).json({
            success: false,
            error: 'Cannot delete DNS domain',
            message: 'DNS配置的域名不能删除，如需更换域名请重新配置DNS'
          })
        }
        
        // 记录域名删除操作
        const logLine = `[${timestamp}] [DOMAIN_DELETE] User: ${user}, DomainID: ${id}, Domain: ${domainToDelete.name}, IP: ${clientIP}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
        
        // 调用mail_db.sh删除域名
        exec(`bash "${mailDbScript}" delete_domain "${id}"`, (error, stdout, stderr) => {
          if (error) {
            console.error('Failed to delete domain:', error)
            res.status(500).json({
              success: false,
              error: 'Failed to delete domain',
              message: error.message
            })
          } else {
            console.log('Domain deleted successfully:', id)
            res.json({
              success: true,
              message: '域名删除成功'
            })
          }
        })
      } catch (parseError) {
        console.error('Failed to parse domains:', parseError)
        res.status(500).json({
          success: false,
          error: 'Failed to parse domains',
          message: parseError.message
        })
      }
    })
    
  } catch (error) {
    console.error('Domain delete error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to delete domain',
      message: error.message
    })
  }
})

// 垃圾邮件过滤配置API
app.get('/api/spam-filter/config', auth, (req, res) => {
  try {
    const clientIP = getRealClientIP(req)
    console.log(`[${new Date().toISOString()}] [API] 获取垃圾邮件过滤配置 - IP: ${clientIP}`)
    
    // 从数据库读取垃圾邮件过滤配置
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    let configResult
    try {
      configResult = execSync(`bash "${mailDbScript}" get-spam-config`, { encoding: 'utf8', timeout: 10000, stdio: ['pipe', 'pipe', 'pipe'] })
      console.log(`[获取配置] 脚本执行结果长度: ${configResult ? configResult.length : 0}`)
      console.log(`[获取配置] 脚本执行结果预览: ${configResult ? configResult.substring(0, 200) : 'null'}`)
    } catch (execError) {
      console.error(`[获取配置] 执行脚本失败:`, execError)
      console.error(`[获取配置] 错误输出:`, execError.stderr ? execError.stderr.toString() : '无stderr')
      throw new Error(`执行配置读取脚本失败: ${execError.message}`)
    }
    
    let spamConfig = {
      keywords: {
        chinese: [],
        english: []
      },
      domainBlacklist: [],
      emailBlacklist: [],
      rules: {
        minContentLines: 0,
        uppercaseRatio: 0.8,
        maxExclamationMarks: 6,
        maxSpecialChars: 8
      }
    }
    
    if (configResult && configResult.trim()) {
      try {
        const trimmedResult = configResult.trim()
        console.log(`[获取配置] 准备解析JSON，长度: ${trimmedResult.length}`)
        spamConfig = JSON.parse(trimmedResult)
        console.log(`[获取配置] JSON解析成功:`, {
          chineseKeywords: spamConfig.keywords?.chinese?.length || 0,
          englishKeywords: spamConfig.keywords?.english?.length || 0,
          domains: spamConfig.domainBlacklist?.length || 0,
          rules: spamConfig.rules ? '存在' : '不存在'
        })
      } catch (parseError) {
        console.error('[获取配置] 解析垃圾邮件过滤配置JSON失败:', parseError)
        console.error('[获取配置] 原始内容:', configResult.substring(0, 500))
        // 不抛出错误，使用默认配置
      }
    } else {
      console.warn('[获取配置] 脚本返回空结果，使用默认配置')
    }
    
    res.json({
      success: true,
      data: spamConfig
    })
  } catch (error) {
    console.error('获取垃圾邮件过滤配置失败:', error)
    res.status(500).json({
      success: false,
      message: '获取垃圾邮件过滤配置失败',
      error: error.message
    })
  }
})

// 更新垃圾邮件过滤配置API
app.post('/api/spam-filter/config', auth, (req, res) => {
  try {
    const clientIP = getRealClientIP(req)
    const { keywords, domainBlacklist, emailBlacklist, rules } = req.body
    
    console.log(`[${new Date().toISOString()}] [API] 更新垃圾邮件过滤配置 - IP: ${clientIP}`)
    
    // 验证配置数据
    if (!keywords || !domainBlacklist || !rules) {
      return res.status(400).json({
        success: false,
        message: '配置数据不完整'
      })
    }
    
    // 保存配置到数据库
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    
    // 使用临时文件传递JSON数据，避免shell转义问题
    const tempDir = '/tmp'
    const timestamp = Date.now()
    const tempFileCn = path.join(tempDir, `spam_config_cn_${timestamp}.json`)
    const tempFileEn = path.join(tempDir, `spam_config_en_${timestamp}.json`)
    const tempFileDomain = path.join(tempDir, `spam_config_domain_${timestamp}.json`)
    const tempFileEmail = path.join(tempDir, `spam_config_email_${timestamp}.json`)
    const tempFileRule = path.join(tempDir, `spam_config_rule_${timestamp}.json`)
    
    try {
      // 更新中文关键词
      console.log(`[更新配置] 更新中文关键词，数量: ${(keywords.chinese || []).length}`)
      fs.writeFileSync(tempFileCn, JSON.stringify(keywords.chinese || []))
      const resultCn = execSync(`bash "${mailDbScript}" update-spam-config keyword_cn "${tempFileCn}"`, { encoding: 'utf8', timeout: 10000, stdio: ['pipe', 'pipe', 'pipe'] })
      console.log(`[更新配置] 中文关键词更新结果:`, resultCn)
      if (resultCn.includes('错误') || resultCn.includes('失败')) {
        throw new Error(`更新中文关键词失败: ${resultCn}`)
      }
      
      // 更新英文关键词
      console.log(`[更新配置] 更新英文关键词，数量: ${(keywords.english || []).length}`)
      fs.writeFileSync(tempFileEn, JSON.stringify(keywords.english || []))
      const resultEn = execSync(`bash "${mailDbScript}" update-spam-config keyword_en "${tempFileEn}"`, { encoding: 'utf8', timeout: 10000, stdio: ['pipe', 'pipe', 'pipe'] })
      console.log(`[更新配置] 英文关键词更新结果:`, resultEn)
      if (resultEn.includes('错误') || resultEn.includes('失败')) {
        throw new Error(`更新英文关键词失败: ${resultEn}`)
      }
      
      // 更新域名黑名单
      console.log(`[更新配置] 更新域名黑名单，数量: ${(domainBlacklist || []).length}`)
      fs.writeFileSync(tempFileDomain, JSON.stringify(domainBlacklist || []))
      const resultDomain = execSync(`bash "${mailDbScript}" update-spam-config domain "${tempFileDomain}"`, { encoding: 'utf8', timeout: 10000, stdio: ['pipe', 'pipe', 'pipe'] })
      console.log(`[更新配置] 域名黑名单更新结果:`, resultDomain)
      if (resultDomain.includes('错误') || resultDomain.includes('失败')) {
        throw new Error(`更新域名黑名单失败: ${resultDomain}`)
      }
      
      // 更新邮箱黑名单（如果有）
      if (emailBlacklist && emailBlacklist.length > 0) {
        console.log(`[更新配置] 更新邮箱黑名单，数量: ${emailBlacklist.length}`)
        fs.writeFileSync(tempFileEmail, JSON.stringify(emailBlacklist))
        const resultEmail = execSync(`bash "${mailDbScript}" update-spam-config email "${tempFileEmail}"`, { encoding: 'utf8', timeout: 10000, stdio: ['pipe', 'pipe', 'pipe'] })
        console.log(`[更新配置] 邮箱黑名单更新结果:`, resultEmail)
        if (resultEmail.includes('错误') || resultEmail.includes('失败')) {
          throw new Error(`更新邮箱黑名单失败: ${resultEmail}`)
        }
      }
      
      // 更新过滤规则
      console.log(`[更新配置] 更新过滤规则:`, rules)
      const rulesData = {
        min_body_lines: rules.minContentLines || 0,
        max_caps_ratio: rules.uppercaseRatio || 0.8,
        max_exclamation: rules.maxExclamationMarks || 6,
        max_special_chars: rules.maxSpecialChars || 8
      }
      fs.writeFileSync(tempFileRule, JSON.stringify(rulesData))
      const resultRule = execSync(`bash "${mailDbScript}" update-spam-config rule "${tempFileRule}"`, { encoding: 'utf8', timeout: 10000, stdio: ['pipe', 'pipe', 'pipe'] })
      console.log(`[更新配置] 过滤规则更新结果:`, resultRule)
      if (resultRule.includes('错误') || resultRule.includes('失败')) {
        throw new Error(`更新过滤规则失败: ${resultRule}`)
      }
      
      // 验证更新结果：重新读取配置确认
      console.log(`[更新配置] 验证更新结果...`)
      const verifyResult = execSync(`bash "${mailDbScript}" get-spam-config`, { encoding: 'utf8', timeout: 10000 })
      console.log(`[更新配置] 验证读取结果:`, verifyResult.substring(0, 200))
    } catch (execError) {
      console.error(`[更新配置] 执行脚本失败:`, execError)
      console.error(`[更新配置] 错误消息:`, execError.message)
      console.error(`[更新配置] 错误堆栈:`, execError.stack)
      if (execError.stderr) {
        console.error(`[更新配置] stderr输出:`, execError.stderr.toString())
      }
      if (execError.stdout) {
        console.error(`[更新配置] stdout输出:`, execError.stdout.toString())
      }
      throw new Error(`更新配置失败: ${execError.message}`)
    } finally {
      // 清理临时文件
      [tempFileCn, tempFileEn, tempFileDomain, tempFileEmail, tempFileRule].forEach(file => {
        try {
          if (fs.existsSync(file)) fs.unlinkSync(file)
        } catch (e) {
          // 忽略清理错误
        }
      })
    }
    
    // 记录操作日志
    const logEntry = {
      timestamp: new Date().toISOString(),
      user: req.auth ? req.auth.name : 'unknown',
      action: 'UPDATE_SPAM_FILTER_CONFIG',
      category: 'system',
      details: {
        keywordsCount: (keywords.chinese?.length || 0) + (keywords.english?.length || 0),
        domainBlacklistCount: domainBlacklist.length,
        emailBlacklistCount: emailBlacklist?.length || 0,
        rules: rules
      },
      ip: clientIP
    }
    
    const logLine = `[${logEntry.timestamp}] [USER_LOG] User: ${logEntry.user}, Action: ${logEntry.action}, Category: ${logEntry.category}, Details: ${JSON.stringify(logEntry.details)}, IP: ${logEntry.ip}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)
    
    res.json({
      success: true,
      message: '垃圾邮件过滤配置已更新到数据库'
    })
  } catch (error) {
    console.error('更新垃圾邮件过滤配置失败:', error)
    res.status(500).json({
      success: false,
      message: '更新垃圾邮件过滤配置失败',
      error: error.message
    })
  }
})

// 垃圾邮件检测API（从数据库加载配置）
app.post('/api/spam-filter/check', auth, (req, res) => {
  try {
    const clientIP = getRealClientIP(req)
    const { subject, content, from, to } = req.body
    
    console.log(`[${new Date().toISOString()}] [API] 垃圾邮件检测 - IP: ${clientIP}`)
    
    // 从数据库加载垃圾邮件过滤配置
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')
    let spamConfig = {
      keywords: { chinese: [], english: [] },
      domainBlacklist: [],
      emailBlacklist: [],
      rules: { minContentLines: 1, uppercaseRatio: 0.7, maxExclamationMarks: 5, maxSpecialChars: 10 }
    }
    
      try {
      const configResult = execSync(`bash "${mailDbScript}" get-spam-config`, { encoding: 'utf8', timeout: 5000 })
      if (configResult && configResult.trim()) {
        spamConfig = JSON.parse(configResult.trim())
        console.log('从数据库加载垃圾邮件过滤配置:', {
          keywords_cn: spamConfig.keywords?.chinese?.length || 0,
          keywords_en: spamConfig.keywords?.english?.length || 0,
          domains: spamConfig.domainBlacklist?.length || 0,
          rules: spamConfig.rules
        })
    } else {
        console.log('数据库中没有垃圾邮件过滤配置，使用默认配置')
      }
    } catch (dbError) {
      console.warn('从数据库加载垃圾邮件过滤配置失败，使用默认配置:', dbError.message)
      // 使用默认配置继续
    }
    
    // 执行垃圾邮件检测
    const detectionResult = checkSpamContent(subject, content, from, to, spamConfig)
    
    res.json({
      success: true,
      data: detectionResult
    })
  } catch (error) {
    console.error('垃圾邮件检测失败:', error)
    res.status(500).json({
      success: false,
      message: '垃圾邮件检测失败',
      error: error.message
    })
  }
})

// 获取邮件详情（放在最后以避免与具体路由冲突）
app.get('/api/mail/:id', auth, (req, res) => {
  try {
    const { id } = req.params
    const timestamp = new Date().toISOString()
    const clientIP = getRealClientIP(req)
    const username = req.headers.authorization ? Buffer.from(req.headers.authorization.split(' ')[1], 'base64').toString().split(':')[0] : 'unknown'

    // 获取用户的真实邮箱地址
    let userEmail = username
    try {
      const mailDbPass = getMailDbPassword()
      const userEmailResult = execSync(`mysql -u mailuser -p"${mailDbPass.replace(/"/g, '\\"')}" maildb -s -r -e "SELECT email FROM mail_users WHERE username='${username}' LIMIT 1;"`, { encoding: 'utf8', timeout: 3000 }).trim()
      const lines = userEmailResult.split('\n').filter(line => line.trim() && line !== 'email')
      const email = lines[lines.length - 1]
      if (email && email.includes('@')) {
        userEmail = email
      }
    } catch (emailError) {
      console.warn('Failed to get user email for mail detail, using username:', emailError.message)
    }

    // 记录邮件详情查询
    const logLine = `[${timestamp}] [MAIL_READ] User: ${username}, Email: ${userEmail}, MailID: ${id}, IP: ${clientIP}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'mail-operations.log'), logLine)

    // 使用真实邮件数据库
    const mailDbScript = path.join(ROOT_DIR, 'backend', 'scripts', 'mail_db.sh')

    exec(`bash "${mailDbScript}" detail "${id}" "${userEmail}"`, (error, stdout, stderr) => {
      if (error) {
        console.error('Mail detail error:', error)
        console.error('Mail detail stderr:', stderr)
        console.error('Mail detail stdout:', stdout)
        res.status(500).json({
          success: false,
          error: 'Mail detail script error',
          message: error.message,
          stderr: stderr,
          stdout: stdout
        })
        return
      }

      try {
        // 直接使用正则表达式提取JSON，支持数组和对象格式
        const jsonArrayMatch = stdout.match(/\[[\s\S]*\]/)
        const jsonObjectMatch = stdout.match(/\{[\s\S]*\}/)
        
        let email = null
        if (jsonArrayMatch) {
          const emailArray = JSON.parse(jsonArrayMatch[0])
          if (emailArray && emailArray.length > 0) {
            email = emailArray[0]
          }
        } else if (jsonObjectMatch) {
          email = JSON.parse(jsonObjectMatch[0])
        }
        
        if (email && email.id) {
          const bodyPreview = email.body ? email.body.substring(0, 100) : 'NULL_OR_EMPTY'
          const htmlPreview = email.html ? email.html.substring(0, 100) : 'NULL_OR_EMPTY'
          console.log(`[邮件详情] 成功获取邮件详情: id=${id}, email_id=${email.id}, from=${email.from}, to=${email.to}`)
          console.log(`[邮件详情] body字段: 长度=${email.body ? email.body.length : 0}, 前100字符=${bodyPreview}`)
          console.log(`[邮件详情] html字段: 长度=${email.html ? email.html.length : 0}, 前100字符=${htmlPreview}`)
          console.log(`[邮件详情] 完整email对象键: ${Object.keys(email).join(', ')}`)
          console.log(`[邮件详情] body字段类型: ${typeof email.body}, 值: ${email.body ? '有值' : '无值'}`)
          console.log(`[邮件详情] html字段类型: ${typeof email.html}, 值: ${email.html ? '有值' : '无值'}`)
          
          // 确保body和html字段存在（即使为空字符串）
          if (email.body === undefined || email.body === null) {
            console.warn(`[邮件详情] 警告: body字段为undefined或null，设置为空字符串`)
            email.body = ''
          }
          if (email.html === undefined || email.html === null) {
            console.warn(`[邮件详情] 警告: html字段为undefined或null，设置为空字符串`)
            email.html = ''
          }
          
          res.json({
            success: true,
            email: email
          })
        } else {
          console.warn(`[邮件详情] 邮件未找到: id=${id}, user=${userEmail}, stdout长度=${stdout.length}, stdout前200字符=${stdout.substring(0, 200)}`)
          res.status(404).json({
            success: false,
            error: 'Email not found',
            message: `邮件ID ${id} 未找到或您没有权限访问`,
            debug: {
              id: id,
              user: userEmail,
              stdoutLength: stdout.length,
              stdoutPreview: stdout.substring(0, 200)
            }
          })
        }
      } catch (parseError) {
        console.error('Mail detail parse error:', parseError)
        console.error('Mail detail stdout:', stdout)
        res.status(500).json({
          success: false,
          error: 'Failed to parse mail detail',
          message: parseError.message,
          stdout: stdout.substring(0, 500)
        })
      }
    })

  } catch (error) {
    console.error('Mail detail error:', error)
    res.status(500).json({
      success: false,
      error: 'Failed to get mail detail',
      message: error.message
    })
  }
})

// 系统监控和自动通知功能
class SystemMonitor {
  constructor() {
    this.lastDiskCheck = Date.now()
    this.lastCpuCheck = Date.now()
    this.lastMemoryCheck = Date.now()
    this.lastServiceCheck = Date.now()
    this.checkInterval = 5 * 60 * 1000 // 5分钟检查一次
    this.startMonitoring()
  }

  startMonitoring() {
    // 定期检查系统状态
    setInterval(() => {
      this.checkSystemStatus()
    }, this.checkInterval)

    console.log('系统监控服务已启动，将每5分钟检查一次系统状态')
  }

  async checkSystemStatus() {
    try {
      const now = Date.now()

      // 检查磁盘使用率
      if (now - this.lastDiskCheck > 10 * 60 * 1000) { // 10分钟检查一次磁盘
        await this.checkDiskUsage()
        this.lastDiskCheck = now
      }

      // 检查CPU使用率（5分钟检查一次）
      if (now - this.lastCpuCheck > 5 * 60 * 1000) {
        await this.checkCpuUsage()
        this.lastCpuCheck = now
      }

      // 检查内存使用率（5分钟检查一次）
      if (now - this.lastMemoryCheck > 5 * 60 * 1000) {
        await this.checkMemoryUsage()
        this.lastMemoryCheck = now
      }

      // 检查关键服务状态
      if (now - this.lastServiceCheck > 5 * 60 * 1000) { // 5分钟检查一次服务
        await this.checkServices()
        this.lastServiceCheck = now
      }

    } catch (error) {
      console.error('系统状态检查失败:', error)
    }
  }

  getNotificationThresholds() {
    try {
      const settingsFile = path.join(ROOT_DIR, 'config', 'system-settings.json')
      if (!fs.existsSync(settingsFile)) {
        // 返回默认阈值
        return {
          cpu: { warning: 80, critical: 90 },
          memory: { warning: 80, critical: 90 },
          disk: { warning: 80, critical: 90 },
          network: { warning: 80, critical: 90 }
        }
      }
      
      const settingsData = fs.readFileSync(settingsFile, 'utf8')
      const settings = JSON.parse(settingsData)
      
      if (settings.notifications && settings.notifications.thresholds) {
        return settings.notifications.thresholds
      }
      
      // 返回默认阈值
      return {
        cpu: { warning: 80, critical: 90 },
        memory: { warning: 80, critical: 90 },
        disk: { warning: 80, critical: 90 },
        network: { warning: 80, critical: 90 }
      }
    } catch (error) {
      console.error('读取通知阈值配置失败:', error)
      // 返回默认阈值
      return {
        cpu: { warning: 80, critical: 90 },
        memory: { warning: 80, critical: 90 },
        disk: { warning: 80, critical: 90 },
        network: { warning: 80, critical: 90 }
      }
    }
  }

  async checkDiskUsage() {
    try {
      const thresholds = this.getNotificationThresholds()
      const diskUsage = execSync('df -h / | tail -1 | awk \'{print $5}\' | sed \'s/%//\'', { encoding: 'utf8' }).trim()

      const usagePercent = parseInt(diskUsage)
      const diskThresholds = thresholds.disk || { warning: 80, critical: 90 }
      
      if (usagePercent >= diskThresholds.critical) {
        await sendNotificationEmail('system',
          '磁盘空间告警',
          `系统磁盘使用率已达到 ${usagePercent}%，超过严重阈值（${diskThresholds.critical}%），请及时清理磁盘空间以避免系统运行异常。`,
          { priority: 'high' }
        )
      } else if (usagePercent >= diskThresholds.warning) {
        await sendNotificationEmail('maintenance',
          '磁盘空间警告',
          `系统磁盘使用率为 ${usagePercent}%，超过警告阈值（${diskThresholds.warning}%），建议清理不必要的文件。`,
          { priority: 'medium' }
        )
      }
    } catch (error) {
      console.error('磁盘使用率检查失败:', error)
    }
  }

  async checkCpuUsage() {
    try {
      const thresholds = this.getNotificationThresholds()
      
      // 获取CPU使用率（1分钟平均值）
      const cpuUsage = execSync("top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - $1}'", { encoding: 'utf8' }).trim()
      const usagePercent = parseFloat(cpuUsage) || 0
      const cpuThresholds = thresholds.cpu || { warning: 80, critical: 90 }
      
      if (usagePercent >= cpuThresholds.critical) {
        await sendNotificationEmail('system',
          'CPU使用率告警',
          `系统CPU使用率已达到 ${usagePercent.toFixed(1)}%，超过严重阈值（${cpuThresholds.critical}%），请检查系统负载和进程状态。`,
          { priority: 'high' }
        )
      } else if (usagePercent >= cpuThresholds.warning) {
        await sendNotificationEmail('maintenance',
          'CPU使用率警告',
          `系统CPU使用率为 ${usagePercent.toFixed(1)}%，超过警告阈值（${cpuThresholds.warning}%），建议检查系统负载。`,
          { priority: 'medium' }
        )
      }
    } catch (error) {
      console.error('CPU使用率检查失败:', error)
    }
  }

  async checkMemoryUsage() {
    try {
      const thresholds = this.getNotificationThresholds()
      
      // 获取内存使用率
      const memInfo = execSync("free | grep Mem | awk '{printf \"%.1f\", $3/$2 * 100.0}'", { encoding: 'utf8' }).trim()
      const usagePercent = parseFloat(memInfo) || 0
      const memoryThresholds = thresholds.memory || { warning: 80, critical: 90 }
      
      if (usagePercent >= memoryThresholds.critical) {
        await sendNotificationEmail('system',
          '内存使用率告警',
          `系统内存使用率已达到 ${usagePercent.toFixed(1)}%，超过严重阈值（${memoryThresholds.critical}%），请检查内存占用和进程状态。`,
          { priority: 'high' }
        )
      } else if (usagePercent >= memoryThresholds.warning) {
        await sendNotificationEmail('maintenance',
          '内存使用率警告',
          `系统内存使用率为 ${usagePercent.toFixed(1)}%，超过警告阈值（${memoryThresholds.warning}%），建议检查内存占用。`,
          { priority: 'medium' }
        )
      }
    } catch (error) {
      console.error('内存使用率检查失败:', error)
    }
  }

  async checkServices() {
    const services = [
      { name: 'postfix', displayName: '邮件发送服务' },
      { name: 'dovecot', displayName: '邮件接收服务' },
      { name: 'named', displayName: 'DNS服务' },
      { name: 'mariadb', displayName: '数据库服务' }
    ]

    for (const service of services) {
      try {
        const status = execSync(`systemctl is-active ${service.name}`, { encoding: 'utf8' }).trim()

        if (status !== 'active') {
          await sendNotificationEmail('system',
            '服务异常告警',
            `${service.displayName} (${service.name}) 服务状态异常，当前状态: ${status}。请检查服务配置和日志。`,
            { priority: 'high' }
          )
        }
      } catch (error) {
        console.error(`${service.name} 服务检查失败:`, error)
      }
    }
  }
}

// 启动系统监控（在服务器启动后开始监控）
let systemMonitor = null

// 测试数据库连接（可选，不阻塞服务启动）
function testDatabaseConnection() {
  try {
    const dbPass = getAppDbPassword()
    const testQuery = `mysql -u mailappuser --password="${dbPass.replace(/"/g, '\\"')}" mailapp -e "SELECT 1;" 2>&1`
    execSync(testQuery, { encoding: 'utf8', timeout: 3000 })
    console.log('数据库连接测试成功')
    return true
  } catch (error) {
    console.warn('数据库连接测试失败（服务将继续运行）:', error.message)
    console.warn('提示: 某些需要数据库的功能可能无法正常工作')
    return false
  }
}

// 错误处理中间件 - 处理payload too large等错误
app.use((err, req, res, next) => {
  if (err.type === 'entity.too.large') {
    return res.status(413).json({
      success: false,
      error: '请求体过大',
      message: '上传的文件大小超过限制（最大10MB）'
    })
  }
  
  // 处理其他JSON解析错误
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      error: '请求格式错误',
      message: '无法解析请求体，请检查数据格式'
    })
  }
  
  // 其他错误
  console.error('Express error:', err)
  res.status(err.status || 500).json({
    success: false,
    error: err.message || '服务器错误',
    message: err.message || '处理请求时发生错误'
  })
})

// 注意：不添加 Express 路由处理 /api/terminal/ws
// 让 WebSocket 升级请求直接由 HTTP 服务器的 upgrade 事件处理

// 创建 HTTP 服务器
const server = http.createServer(app)

// 创建 WebSocket 服务器（手动处理升级）
const wss = new WebSocketServer({ 
  noServer: true,  // 手动处理升级请求
  verifyClient: (info) => {
    // 允许所有连接，认证在连接建立后处理
    // 因为 Apache 代理可能无法传递认证头
    return true
  }
})

// 处理 WebSocket 升级请求
server.on('upgrade', (request, socket, head) => {
  const pathname = new URL(request.url, `http://${request.headers.host}`).pathname
  
  console.log(`[TERMINAL_WS] Upgrade event triggered: ${pathname}`)
  console.log(`[TERMINAL_WS] Full URL: ${request.url}`)
  console.log(`[TERMINAL_WS] Upgrade header: ${request.headers.upgrade}`)
  console.log(`[TERMINAL_WS] Connection header: ${request.headers.connection}`)
  console.log(`[TERMINAL_WS] All headers:`, JSON.stringify(request.headers, null, 2))
  
  if (pathname === '/api/terminal/ws') {
    // 检查是否是 WebSocket 升级请求
    const upgradeHeader = request.headers.upgrade
    const connectionHeader = request.headers.connection
    
    console.log(`[TERMINAL_WS] Checking upgrade: ${upgradeHeader}, connection: ${connectionHeader}`)
    
    if (upgradeHeader && upgradeHeader.toLowerCase() === 'websocket') {
      console.log(`[TERMINAL_WS] Handling WebSocket upgrade`)
      wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit('connection', ws, request)
      })
    } else {
      // 如果不是 WebSocket 升级请求，返回 426
      console.log(`[TERMINAL_WS] Not a WebSocket upgrade request, returning 426`)
      socket.write('HTTP/1.1 426 Upgrade Required\r\n')
      socket.write('Upgrade: websocket\r\n')
      socket.write('Connection: Upgrade\r\n')
      socket.write('\r\n')
      socket.destroy()
    }
  } else {
    // 如果不是 WebSocket 路径，返回 404
    console.log(`[TERMINAL_WS] Path mismatch: ${pathname} !== /api/terminal/ws`)
    socket.write('HTTP/1.1 404 Not Found\r\n\r\n')
    socket.destroy()
  }
})

// 存储活跃的终端会话
const terminalSessions = new Map()

wss.on('connection', (ws, req) => {
  const sessionId = uuidv4()
  let authenticated = false
  let user = 'unknown'
  
  // 尝试从子协议获取认证信息
  const protocols = req.headers['sec-websocket-protocol']
  console.log(`[TERMINAL_WS] Protocols header:`, protocols, `Type:`, typeof protocols)
  
  if (protocols) {
    // 处理数组或字符串格式
    const protocolList = Array.isArray(protocols) ? protocols : [protocols]
    for (const protocol of protocolList) {
      if (protocol && protocol.startsWith('auth.')) {
        const authToken = protocol.substring(5)
        console.log(`[TERMINAL_WS] Found auth protocol, token length: ${authToken.length}`)
        try {
          const decoded = Buffer.from(authToken, 'base64').toString()
          user = decoded.split(':')[0]
          authenticated = true
          console.log(`[TERMINAL_WS] Authentication successful from protocol, user: ${user}`)
          break
        } catch (error) {
          console.error('[TERMINAL_WS] Failed to decode auth from protocol:', error)
        }
      }
    }
  }
  
  // 如果没有从子协议获取到，尝试从 Authorization header 获取
  if (!authenticated) {
    const authHeader = req.headers.authorization
    console.log(`[TERMINAL_WS] Authorization header:`, authHeader ? 'present' : 'missing')
    if (authHeader) {
      try {
        const auth = authHeader.split(' ')[1]
        const decoded = Buffer.from(auth, 'base64').toString()
        user = decoded.split(':')[0]
        authenticated = true
        console.log(`[TERMINAL_WS] Authentication successful from header, user: ${user}`)
      } catch (error) {
        console.error('[TERMINAL_WS] Failed to decode auth from header:', error)
      }
    }
  }
  
  const timestamp = new Date().toISOString()
  const clientIP = getRealClientIP({ headers: req.headers, connection: req.socket })
  
  console.log(`[TERMINAL_WS] New connection: ${sessionId}, User: ${user}, IP: ${clientIP}, Authenticated: ${authenticated}`)
  
  const session = {
    ws,
    user,
    process: null,
    cwd: '/tmp',
    sessionId,
    startTime: Date.now(),
    authenticated,
    inputBuffer: ''
  }
  
  terminalSessions.set(sessionId, session)

  // 记录连接日志
  const logLine = `[${timestamp}] [TERMINAL_WS_CONNECT] Session: ${sessionId}, User: ${user}, IP: ${clientIP}\n`
  fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), logLine)

  ws.on('message', async (message) => {
    try {
      const data = JSON.parse(message.toString())
      const session = terminalSessions.get(sessionId)
      
      if (!session) {
        ws.send(JSON.stringify({ type: 'error', message: 'Session not found' }))
        return
      }
      
      // 处理认证消息
      if (data.type === 'auth') {
        try {
          const decoded = Buffer.from(data.token, 'base64').toString()
          session.user = decoded.split(':')[0]
          session.authenticated = true
          ws.send(JSON.stringify({ type: 'auth', success: true }))
          return
        } catch (error) {
          ws.send(JSON.stringify({ type: 'error', message: 'Authentication failed' }))
          ws.close()
          return
        }
      }
      
      // 如果未认证，要求认证（但允许 auth 和 init 消息）
      if (!session.authenticated && data.type !== 'auth' && data.type !== 'init') {
        console.log(`[TERMINAL_WS] Unauthenticated request for type: ${data.type}`)
        ws.send(JSON.stringify({ type: 'error', message: 'Not authenticated' }))
        return
      }
      
      // 允许在未认证状态下发送 init，但会在 init 时检查
      if (data.type === 'init') {
        // 如果未认证，先尝试通过消息认证
        if (!session.authenticated) {
          console.log(`[TERMINAL_WS] Init received but not authenticated, session will use message auth`)
        }
        // 初始化终端 - 使用 node-pty 创建伪终端
        let pty
        try {
          pty = await import('node-pty')
        } catch (error) {
          console.error(`[TERMINAL_WS] Failed to import node-pty:`, error)
          if (session.ws.readyState === 1) {
            session.ws.send(JSON.stringify({ 
              type: 'error', 
              message: 'Terminal initialization failed: node-pty not available. Please install: npm install node-pty' 
            }))
          }
          return
        }
        
        const shell = pty.spawn('sudo', ['-u', 'euser', '/bin/bash', '-l'], {
          name: 'xterm-256color',
          cols: 80,
          rows: 24,
          cwd: '/tmp',
          env: {
            ...process.env,
            TERM: 'xterm-256color',
            HOME: '/home/euser',
            USER: 'euser',
            SHELL: '/bin/bash',
            LANG: 'en_US.UTF-8',
            LC_ALL: 'en_US.UTF-8',
            PATH: process.env.PATH || '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin',
            COLORTERM: 'truecolor'
          }
        })

        shell.onData((data) => {
          const output = data.toString()
          console.log(`[TERMINAL_WS] Shell output for session ${sessionId}, length: ${output.length}, preview: ${output.substring(0, 50)}`)
          if (session.ws.readyState === 1) { // WebSocket.OPEN
            session.ws.send(JSON.stringify({ type: 'output', data: output }))
          }
        })

        shell.onExit(({ exitCode, signal }) => {
          console.log(`[TERMINAL_WS] Shell exited for session ${sessionId}, code: ${exitCode}, signal: ${signal}`)
          if (session.ws.readyState === 1) {
            session.ws.send(JSON.stringify({ type: 'exit', code: exitCode || 0 }))
          }
          session.process = null
        })

        session.process = shell
        
        // 记录命令执行日志
        const commandLog = `[${new Date().toISOString()}] [TERMINAL_WS_INIT] Session: ${sessionId}, User: ${user}, IP: ${clientIP}, PID: ${shell.pid}\n`
        fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), commandLog)
        
        console.log(`[TERMINAL_WS] Shell initialized for session ${sessionId}, User: ${user}, PID: ${shell.pid}`)
        
      } else if (data.type === 'input') {
        // 处理用户输入
        if (session.process && typeof session.process.write === 'function') {
          session.process.write(data.data)
          // 用户日志升级：按行缓冲，仅在完整命令行（Enter）时写入一条日志，避免逐字符刷屏
          if (typeof data.data === 'string' && data.data.length > 0) {
            session.inputBuffer = (session.inputBuffer || '') + data.data
            const lines = session.inputBuffer.split(/\r?\n/)
            if (lines.length > 1) {
              const completeLines = lines.slice(0, -1).map(s => s.trim()).filter(Boolean)
              session.inputBuffer = lines[lines.length - 1] || ''
              for (const line of completeLines) {
                const safeLine = line.replace(/\\/g, '\\\\').replace(/"/g, '\\"')
                const inputLog = `[${new Date().toISOString()}] [TERMINAL_WS_INPUT] Session: ${sessionId}, User: ${session.user}, Input: "${safeLine}"\n`
                fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), inputLog)
              }
            }
          }
        } else {
          console.log(`[TERMINAL_WS] Input received but no process for session ${sessionId}`)
        }
      } else if (data.type === 'resize') {
        // 处理终端大小变化
        if (session.process && typeof session.process.resize === 'function') {
          session.process.resize(data.cols || 80, data.rows || 24)
        }
      }
    } catch (error) {
      console.error(`[TERMINAL_WS] Error processing message for session ${sessionId}:`, error)
      if (ws.readyState === 1) {
        ws.send(JSON.stringify({ type: 'error', message: error.message }))
      }
    }
  })

  ws.on('error', (error) => {
    console.error(`[TERMINAL_WS] WebSocket error for session ${sessionId}:`, error)
  })

  ws.on('close', () => {
    const session = terminalSessions.get(sessionId)
    if (session) {
      if (session.process) {
        // node-pty 使用 kill() 方法
        if (typeof session.process.kill === 'function') {
          session.process.kill()
        }
      }
      const duration = Date.now() - session.startTime
      const closeLog = `[${new Date().toISOString()}] [TERMINAL_WS_DISCONNECT] Session: ${sessionId}, User: ${session.user}, Duration: ${duration}ms\n`
      fs.appendFileSync(path.join(LOG_DIR, 'user-operations.log'), closeLog)
    }
    terminalSessions.delete(sessionId)
    console.log(`[TERMINAL_WS] Connection closed: ${sessionId}`)
  })
})

server.listen(PORT, () => {
  console.log(`mail-ops dispatcher listening on ${PORT}`)
  console.log(`WebSocket server ready at ws://localhost:${PORT}/api/terminal/ws`)
  
  // 测试数据库连接（不阻塞启动）
  setTimeout(() => {
    testDatabaseConnection()
  }, 2000)

  // 延迟启动系统监控，避免启动时的干扰
  setTimeout(() => {
    systemMonitor = new SystemMonitor()
  }, 30000) // 30秒后启动监控
})

// 处理未捕获的异常，避免服务崩溃
process.on('uncaughtException', (error) => {
  console.error('未捕获的异常:', error)
  console.error('错误堆栈:', error.stack)
  // 不退出进程，记录错误并继续运行
  try {
    const errorLog = `[${new Date().toISOString()}] [UNCAUGHT_EXCEPTION] ${error.message}\n${error.stack}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'errors.log'), errorLog)
  } catch (logError) {
    console.error('无法写入错误日志:', logError.message)
  }
})

// 处理未处理的Promise拒绝
process.on('unhandledRejection', (reason, promise) => {
  console.error('未处理的Promise拒绝:', reason)
  // 不退出进程，记录错误并继续运行
  try {
    const errorLog = `[${new Date().toISOString()}] [UNHANDLED_REJECTION] ${reason}\n`
    fs.appendFileSync(path.join(LOG_DIR, 'errors.log'), errorLog)
  } catch (logError) {
    console.error('无法写入错误日志:', logError.message)
  }
})

