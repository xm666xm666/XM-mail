/**
 * 用户活动追踪器
 * 用于检测用户无操作状态，超时后自动退出
 */

const DEFAULT_INACTIVITY_TIMEOUT = 5 * 60 * 1000 // 默认5分钟（毫秒）
const CHECK_INTERVAL = 30 * 1000 // 每30秒检查一次

class ActivityTracker {
  private lastActivityTime: number = Date.now()
  private checkTimer: number | null = null
  private isTracking: boolean = false
  private onTimeoutCallback: (() => void) | null = null
  private inactivityTimeout: number = DEFAULT_INACTIVITY_TIMEOUT

  /**
   * 从系统设置加载会话超时时间
   */
  public async loadSessionTimeout() {
    try {
      const auth = sessionStorage.getItem('apiAuth')
      if (!auth) {
        this.inactivityTimeout = DEFAULT_INACTIVITY_TIMEOUT
        return
      }

      const response = await fetch('/api/system-settings', {
        headers: {
          'Authorization': `Basic ${auth}`
        }
      })

      if (response.ok) {
        const data = await response.json()
        if (data.success && data.settings?.security?.sessionTimeout) {
          const timeoutMinutes = parseInt(data.settings.security.sessionTimeout, 10)
          if (timeoutMinutes >= 5 && timeoutMinutes <= 1440) {
            this.inactivityTimeout = timeoutMinutes * 60 * 1000 // 转换为毫秒
            console.log(`会话超时时间已更新为: ${timeoutMinutes}分钟`)
          } else {
            this.inactivityTimeout = DEFAULT_INACTIVITY_TIMEOUT
            console.warn(`无效的会话超时时间: ${timeoutMinutes}分钟，使用默认值5分钟`)
          }
        } else {
          this.inactivityTimeout = DEFAULT_INACTIVITY_TIMEOUT
        }
      } else {
        this.inactivityTimeout = DEFAULT_INACTIVITY_TIMEOUT
      }
    } catch (error) {
      console.warn('加载会话超时设置失败，使用默认值:', error)
      this.inactivityTimeout = DEFAULT_INACTIVITY_TIMEOUT
    }
  }

  /**
   * 开始追踪用户活动
   */
  public async start(onTimeout: () => void) {
    if (this.isTracking) {
      return
    }

    // 先加载会话超时设置
    await this.loadSessionTimeout()

    this.onTimeoutCallback = onTimeout
    this.isTracking = true
    this.lastActivityTime = Date.now()

    // 监听各种用户活动事件
    this.setupEventListeners()

    // 开始定期检查
    this.startCheckTimer()

    const timeoutMinutes = Math.floor(this.inactivityTimeout / 60000)
    console.log(`用户活动追踪已启动，无操作超时时间：${timeoutMinutes}分钟`)
  }

  /**
   * 停止追踪用户活动
   */
  public stop() {
    if (!this.isTracking) {
      return
    }

    this.isTracking = false
    this.removeEventListeners()
    this.stopCheckTimer()

    console.log('用户活动追踪已停止')
  }

  /**
   * 更新最后活动时间
   */
  public updateActivity() {
    if (!this.isTracking) {
      return
    }

    const now = Date.now()
    const timeSinceLastActivity = now - this.lastActivityTime

    // 如果距离上次活动超过30秒，才更新（避免过于频繁）
    if (timeSinceLastActivity > 30000) {
      this.lastActivityTime = now
      console.log('用户活动已更新')
    } else {
      this.lastActivityTime = now
    }
  }

  /**
   * 设置事件监听器
   */
  private setupEventListeners() {
    // 鼠标移动
    document.addEventListener('mousemove', this.handleActivity)
    // 鼠标点击
    document.addEventListener('mousedown', this.handleActivity)
    // 鼠标滚轮
    document.addEventListener('wheel', this.handleActivity)
    // 键盘输入
    document.addEventListener('keydown', this.handleActivity)
    // 键盘按下
    document.addEventListener('keypress', this.handleActivity)
    // 触摸事件（移动设备）
    document.addEventListener('touchstart', this.handleActivity)
    document.addEventListener('touchmove', this.handleActivity)
    // 窗口焦点
    window.addEventListener('focus', this.handleActivity)
    // 页面可见性变化
    document.addEventListener('visibilitychange', this.handleVisibilityChange)
  }

  /**
   * 移除事件监听器
   */
  private removeEventListeners() {
    document.removeEventListener('mousemove', this.handleActivity)
    document.removeEventListener('mousedown', this.handleActivity)
    document.removeEventListener('wheel', this.handleActivity)
    document.removeEventListener('keydown', this.handleActivity)
    document.removeEventListener('keypress', this.handleActivity)
    document.removeEventListener('touchstart', this.handleActivity)
    document.removeEventListener('touchmove', this.handleActivity)
    window.removeEventListener('focus', this.handleActivity)
    document.removeEventListener('visibilitychange', this.handleVisibilityChange)
  }

  /**
   * 处理用户活动
   */
  private handleActivity = () => {
    this.updateActivity()
  }

  /**
   * 处理页面可见性变化
   */
  private handleVisibilityChange = () => {
    if (document.visibilityState === 'visible') {
      // 页面变为可见时，更新活动时间
      this.updateActivity()
    }
  }

  /**
   * 开始检查定时器
   */
  private startCheckTimer() {
    this.stopCheckTimer()

    this.checkTimer = window.setInterval(() => {
      this.checkInactivity()
    }, CHECK_INTERVAL)
  }

  /**
   * 停止检查定时器
   */
  private stopCheckTimer() {
    if (this.checkTimer !== null) {
      clearInterval(this.checkTimer)
      this.checkTimer = null
    }
  }

  /**
   * 检查是否超时
   */
  private checkInactivity() {
    if (!this.isTracking) {
      return
    }

    const now = Date.now()
    const timeSinceLastActivity = now - this.lastActivityTime

    if (timeSinceLastActivity >= this.inactivityTimeout) {
      const timeoutMinutes = Math.floor(this.inactivityTimeout / 60000)
      console.warn(`用户无操作超过${timeoutMinutes}分钟，自动退出`)
      this.handleTimeout()
    } else {
      const remainingMinutes = Math.ceil((this.inactivityTimeout - timeSinceLastActivity) / 60000)
      if (remainingMinutes <= 1) {
        console.log(`警告：用户将在${remainingMinutes}分钟后因无操作自动退出`)
      }
    }
  }

  /**
   * 处理超时
   */
  private handleTimeout() {
    this.stop()

    if (this.onTimeoutCallback) {
      this.onTimeoutCallback()
    }
  }

  /**
   * 获取剩余时间（秒）
   */
  public getRemainingTime(): number {
    if (!this.isTracking) {
      return 0
    }

    const now = Date.now()
    const timeSinceLastActivity = now - this.lastActivityTime
    const remaining = this.inactivityTimeout - timeSinceLastActivity

    return Math.max(0, Math.floor(remaining / 1000))
  }
}

// 导出单例
export const activityTracker = new ActivityTracker()

