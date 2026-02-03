/**
 * 用户操作日志记录工具
 * 用于记录前端用户的各种操作，包括按钮点击、邮件操作等
 */

interface UserLogEntry {
  timestamp: string
  action: string
  details?: any
  user?: string
  ip?: string
}

class UserLogger {
  private static instance: UserLogger
  private logBuffer: UserLogEntry[] = []
  private maxBufferSize = 50
  private flushInterval = 30000 // 30秒

  private constructor() {
    // 定期刷新日志到后端
    setInterval(() => {
      this.flushLogs()
    }, this.flushInterval)
    
    // 页面卸载时刷新日志
    window.addEventListener('beforeunload', () => {
      this.flushLogs()
    })
  }

  public static getInstance(): UserLogger {
    if (!UserLogger.instance) {
      UserLogger.instance = new UserLogger()
    }
    return UserLogger.instance
  }

  /**
   * 记录用户操作
   */
  public log(action: string, details?: any): void {
    const entry: UserLogEntry = {
      timestamp: new Date().toISOString(),
      action,
      details: this.sanitizeDetails(details),
      user: this.getCurrentUser(),
      ip: this.getClientIP()
    }

    this.logBuffer.push(entry)

    // 如果缓冲区满了，立即刷新
    if (this.logBuffer.length >= this.maxBufferSize) {
      this.flushLogs()
    }

    // 开发环境下在控制台输出
    if (process.env.NODE_ENV === 'development') {
      console.log('[UserLogger]', entry)
    }
  }

  /**
   * 记录按钮点击
   */
  public logButtonClick(buttonName: string, context?: string): void {
    this.log('button_click', {
      button: buttonName,
      context: context || 'unknown',
      page: window.location.pathname
    })
  }

  /**
   * 记录邮件操作
   */
  public logMailOperation(operation: string, details?: any): void {
    this.log('mail_operation', {
      operation,
      ...this.sanitizeMailDetails(details)
    })
  }

  /**
   * 记录登录操作
   */
  public logLogin(attempt: 'success' | 'failed', username?: string): void {
    this.log('login_attempt', {
      result: attempt,
      username: username ? this.maskUsername(username) : 'unknown'
    })
  }

  /**
   * 记录注册操作
   */
  public logRegister(attempt: 'success' | 'failed', username?: string): void {
    this.log('register_attempt', {
      result: attempt,
      username: username ? this.maskUsername(username) : 'unknown'
    })
  }

  /**
   * 记录页面访问
   */
  public logPageView(page: string): void {
    this.log('page_view', {
      page,
      referrer: document.referrer
    })
  }

  /**
   * 清理敏感信息
   */
  private sanitizeDetails(details: any): any {
    if (!details || typeof details !== 'object') {
      return details
    }

    const sanitized = { ...details }
    
    // 移除或掩码敏感字段
    const sensitiveFields = ['password', 'pass', 'pwd', 'token', 'secret', 'key']
    sensitiveFields.forEach(field => {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]'
      }
    })

    return sanitized
  }

  /**
   * 清理邮件相关敏感信息
   */
  private sanitizeMailDetails(details: any): any {
    if (!details || typeof details !== 'object') {
      return details
    }

    const sanitized = { ...details }
    
    // 掩码邮件地址
    if (sanitized.to) {
      sanitized.to = this.maskEmail(sanitized.to)
    }
    if (sanitized.from) {
      sanitized.from = this.maskEmail(sanitized.from)
    }
    if (sanitized.cc) {
      sanitized.cc = Array.isArray(sanitized.cc) 
        ? sanitized.cc.map((email: string) => this.maskEmail(email))
        : this.maskEmail(sanitized.cc)
    }
    if (sanitized.bcc) {
      sanitized.bcc = Array.isArray(sanitized.bcc)
        ? sanitized.bcc.map((email: string) => this.maskEmail(email))
        : this.maskEmail(sanitized.bcc)
    }

    // 掩码邮件内容（只保留长度和类型信息）
    if (sanitized.body) {
      sanitized.bodyLength = sanitized.body.length
      sanitized.bodyType = typeof sanitized.body
      delete sanitized.body
    }
    if (sanitized.subject) {
      sanitized.subjectLength = sanitized.subject.length
      sanitized.subjectPreview = sanitized.subject.substring(0, 20) + (sanitized.subject.length > 20 ? '...' : '')
      delete sanitized.subject
    }

    return sanitized
  }

  /**
   * 掩码用户名
   */
  private maskUsername(username: string): string {
    if (username.length <= 2) return '*'.repeat(username.length)
    return username[0] + '*'.repeat(username.length - 2) + username[username.length - 1]
  }

  /**
   * 掩码邮件地址
   */
  private maskEmail(email: string): string {
    const [local, domain] = email.split('@')
    if (!domain) return email
    
    const maskedLocal = local.length <= 2 
      ? '*'.repeat(local.length)
      : local[0] + '*'.repeat(local.length - 2) + local[local.length - 1]
    
    return `${maskedLocal}@${domain}`
  }

  /**
   * 获取当前用户
   */
  private getCurrentUser(): string {
    try {
      const auth = sessionStorage.getItem('apiAuth')
      if (auth) {
        const decoded = atob(auth)
        return decoded.split(':')[0] || 'unknown'
      }
    } catch (e) {
      // 忽略解析错误
    }
    return 'anonymous'
  }

  /**
   * 获取客户端IP（简化版本）
   */
  private getClientIP(): string {
    // 在实际应用中，这应该从后端获取真实IP
    return 'client'
  }

  /**
   * 刷新日志到后端
   */
  private async flushLogs(): Promise<void> {
    if (this.logBuffer.length === 0) return

    const logs = [...this.logBuffer]
    this.logBuffer = []

    try {
      const auth = sessionStorage.getItem('apiAuth')
      if (!auth) return

      await fetch('/api/user-logs', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${auth}`
        },
        body: JSON.stringify({ logs })
      })
    } catch (error) {
      console.error('Failed to flush user logs:', error)
      // 如果发送失败，将日志重新加入缓冲区
      this.logBuffer.unshift(...logs)
    }
  }
}

// 导出单例实例
export const userLogger = UserLogger.getInstance()

// 导出类型
export type { UserLogEntry }
