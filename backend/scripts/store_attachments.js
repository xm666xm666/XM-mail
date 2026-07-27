#!/usr/bin/env node
/**
 * ============================================================================
 * 脚本名称: store_attachments.js
 * 工作职责: 邮件附件存储 - 将附件写入 email_attachments 表
 *           由 mail_db.sh store 调用，使用 mysql CLI 写入 MariaDB
 * 系统组件: XM邮件管理系统 - 邮件附件存储模块
 * ============================================================================
 * 用法说明:
 *   由 mail_db.sh store 通过环境变量调用，不直接命令行执行
 *
 * 环境变量:
 *   ATTACHMENTS_FILE_PATH - 附件 JSON 文件路径（与 ATTACHMENTS_JSON 二选一）
 *   ATTACHMENTS_JSON      - 附件 JSON 内联字符串
 *   EMAIL_ID              - 邮件 ID（必填）
 *   DB_HOST               - 数据库主机（默认 localhost）
 *   DB_USER               - 数据库用户（默认 mailuser）
 *   DB_PASS_FILE          - 密码文件路径（默认 /etc/mail-ops/mail-db.pass）
 *   DB_NAME               - 数据库名（默认 maildb）
 *
 * 附件格式:
 *   - path 型：{ name, path, type, size } — 从 path 复制到 /var/mail-ops/attachments/
 *   - content 型：{ name, content, type, size } — content 为 Base64，写入 content_base64
 *
 * 依赖关系:
 *   - Node.js
 *   - mysql CLI（MariaDB 客户端）
 *   - 调用方：mail_db.sh store
 * ============================================================================
 */
const fs = require('fs')
const path = require('path')
const { execSync } = require('child_process')
const crypto = require('crypto')

const ATTACH_DIR = '/var/mail-ops/attachments'

function escapeSql (str) {
  if (str == null || str === undefined) return ''
  return String(str).replace(/\\/g, '\\\\').replace(/'/g, "''")
}

function main () {
  const attachmentsFile = process.env.ATTACHMENTS_FILE_PATH || ''
  const attachmentsInline = process.env.ATTACHMENTS_JSON || ''
  const emailId = parseInt(process.env.EMAIL_ID || '0', 10)
  const dbHost = process.env.DB_HOST || 'localhost'
  const dbUser = process.env.DB_USER || 'mailuser'
  const dbPassFile = process.env.DB_PASS_FILE || '/etc/mail-ops/mail-db.pass'
  const dbName = process.env.DB_NAME || 'maildb'

  let attachmentsJson = ''
  if (attachmentsFile && fs.existsSync(attachmentsFile)) {
    attachmentsJson = fs.readFileSync(attachmentsFile, 'utf8')
  } else {
    attachmentsJson = attachmentsInline
  }

  if (!attachmentsJson || attachmentsJson === '[valid]') {
    return
  }

  let attachments
  try {
    attachments = JSON.parse(attachmentsJson)
  } catch (e) {
    console.error(`Error parsing attachments JSON: ${e.message}`)
    return
  }

  if (!Array.isArray(attachments) || attachments.length === 0) {
    return
  }

  const dbPass = fs.readFileSync(dbPassFile, 'utf8').trim()
  const mysqlEnv = { ...process.env, MYSQL_PWD: dbPass }

  fs.mkdirSync(ATTACH_DIR, { recursive: true })

  for (const att of attachments) {
    const filename = att.name || ''
    if (!filename) continue

    const contentType = att.type || ''
    const sizeBytes = parseInt(att.size || 0, 10)
    const contentBase64 = att.content || ''
    const srcPath = att.path || ''

    let filePathVal = ''
    let contentBase64Escaped = ''

    if (srcPath && fs.existsSync(srcPath)) {
      const destName = `${emailId}_${crypto.randomBytes(4).toString('hex')}_${filename}`.replace(/\//g, '_')
      const destPath = path.join(ATTACH_DIR, destName)
      try {
        fs.copyFileSync(srcPath, destPath)
        filePathVal = destPath
      } catch (e) {
        console.error(`Warning: Failed to copy attachment ${filename}: ${e.message}`)
      }
    } else {
      contentBase64Escaped = escapeSql(contentBase64)
    }

    const filenameEscaped = escapeSql(filename)
    const contentTypeEscaped = escapeSql(contentType)
    const filePathEscaped = escapeSql(filePathVal)

    const sql = `INSERT INTO email_attachments (email_id, filename, content_type, size_bytes, file_path, content_base64) VALUES (${emailId}, '${filenameEscaped}', '${contentTypeEscaped}', ${sizeBytes}, '${filePathEscaped}', '${contentBase64Escaped}');`

    try {
      const tmpFile = `/tmp/mail_attach_${Date.now()}_${Math.random().toString(36).slice(2)}.sql`
      fs.writeFileSync(tmpFile, sql, 'utf8')
      execSync(`mysql -h "${dbHost}" -u "${dbUser}" "${dbName}" < "${tmpFile}"`, {
        env: mysqlEnv,
        shell: true
      })
      fs.unlinkSync(tmpFile)
    } catch (e) {
      console.error(`Warning: Failed to insert attachment ${filename}: ${e.stderr || e.message}`)
    }
  }
}

main()
