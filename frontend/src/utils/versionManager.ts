// 版本管理工具
import axios from 'axios'

// 版本信息接口
export interface VersionInfo {
  success: boolean
  version: string
  timestamp: string
  clientIP?: string
}

// 版本管理器类
export class VersionManager {
  private static instance: VersionManager
  private cachedVersion: string | null = null
  private lastFetchTime: number = 0
  private readonly CACHE_DURATION = 5 * 60 * 1000 // 5分钟缓存

  private constructor() {}

  public static getInstance(): VersionManager {
    if (!VersionManager.instance) {
      VersionManager.instance = new VersionManager()
    }
    return VersionManager.instance
  }

  // 获取版本信息
  public async getVersion(): Promise<string> {
    const now = Date.now()
    
    // 如果缓存未过期，直接返回缓存版本
    if (this.cachedVersion && (now - this.lastFetchTime) < this.CACHE_DURATION) {
      return this.cachedVersion
    }

    try {
      // 版本API现在是公开的，不需要认证信息
      // 如果有认证信息，可以带上（用于日志记录），但不是必需的
      const auth = sessionStorage.getItem('apiAuth')
      const headers: Record<string, string> = {}
      if (auth) {
        headers['Authorization'] = `Basic ${auth}`
      }
      
      const response = await axios.get<VersionInfo>('/api/version', {
        timeout: 5000,
        headers
      })

      if (response.data.success) {
        this.cachedVersion = response.data.version
        this.lastFetchTime = now
        return response.data.version
      } else {
        throw new Error('获取版本信息失败')
      }
    } catch (error) {
      console.warn('获取版本信息失败，使用默认版本:', error)
      // 如果API调用失败，返回默认版本
      return '3.4.1'
    }
  }

  // 强制刷新版本信息
  public async refreshVersion(): Promise<string> {
    this.cachedVersion = null
    this.lastFetchTime = 0
    return await this.getVersion()
  }

  // 清除缓存
  public clearCache(): void {
    this.cachedVersion = null
    this.lastFetchTime = 0
  }

  // 获取当前缓存的版本
  public getCachedVersion(): string | null {
    return this.cachedVersion
  }

  // 检查是否需要刷新版本
  public shouldRefresh(): boolean {
    const now = Date.now()
    return !this.cachedVersion || (now - this.lastFetchTime) >= this.CACHE_DURATION
  }
}

// 导出单例实例
export const versionManager = VersionManager.getInstance()

// 便捷函数
export const getVersion = () => versionManager.getVersion()
export const refreshVersion = () => versionManager.refreshVersion()
export const getCachedVersion = () => versionManager.getCachedVersion()
