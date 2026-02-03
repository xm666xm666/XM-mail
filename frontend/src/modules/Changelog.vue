<template>
  <div class="changelog-page">
    <!-- 科幻背景效果 -->
    <div class="sci-fi-background">
      <div class="gradient-orb orb-1"></div>
      <div class="gradient-orb orb-2"></div>
      <div class="gradient-orb orb-3"></div>
      <div class="grid-pattern"></div>
      <div class="particle-container">
        <div v-for="i in 50" :key="i" class="particle" :style="getParticleStyle(i)"></div>
      </div>
    </div>

    <!-- 导航栏 -->
    <nav class="navbar">
      <div class="nav-container">
        <router-link to="/" class="logo">
          <img src="/favicon.ico" alt="Logo" class="logo-icon" />
          <span class="logo-text">XM邮件管理系统</span>
        </router-link>
        <button class="mobile-menu-toggle" @click="toggleMobileMenu" :aria-expanded="mobileMenuOpen">
          <span class="hamburger-line"></span>
          <span class="hamburger-line"></span>
          <span class="hamburger-line"></span>
        </button>
        <div class="nav-links" :class="{ 'mobile-menu-open': mobileMenuOpen }">
          <router-link to="/#features" class="nav-link" @click="closeMobileMenu">特性</router-link>
          <router-link to="/#architecture" class="nav-link" @click="closeMobileMenu">架构</router-link>
          <router-link to="/#tech-stack" class="nav-link" @click="closeMobileMenu">技术栈</router-link>
          <router-link to="/changelog" class="nav-link active" @click="closeMobileMenu">更新日志</router-link>
          <button @click="goToRegister" class="nav-button secondary">注册</button>
          <button @click="goToLogin" class="nav-button">登录</button>
        </div>
      </div>
    </nav>

    <!-- 主内容区域 -->
    <section class="changelog-section">
      <div class="section-container">
        <div class="section-header">
          <h1 class="page-title">更新日志</h1>
          <p class="page-subtitle">了解XM邮件管理系统的版本更新历史</p>
        </div>

        <!-- 加载状态 -->
        <div v-if="loading" class="loading-container">
          <div class="loading-spinner"></div>
          <p class="loading-text">正在加载更新日志...</p>
        </div>

        <!-- 错误状态 -->
        <div v-else-if="error" class="error-container">
          <div class="error-icon">⚠️</div>
          <p class="error-text">{{ error }}</p>
          <button @click="loadChangelog" class="retry-button">重试</button>
        </div>

        <!-- 版本列表 -->
        <div v-else class="versions-container">
          <!-- 最新版本 -->
          <div v-if="latestVersion" class="latest-version-card">
            <div class="version-badge">最新版本</div>
            <div class="version-header">
              <h2 class="version-title">{{ latestVersion.version }}</h2>
              <span class="version-date">{{ latestVersion.date }}</span>
            </div>
            <div class="version-content">
              <h3 class="version-title-text">{{ latestVersion.title }}</h3>
              <p class="version-description">{{ latestVersion.description }}</p>
            </div>
          </div>

          <!-- 版本历史列表 -->
          <div class="versions-list">
            <div 
              v-for="(version, index) in paginatedVersions" 
              :key="(currentPage - 1) * itemsPerPage + index"
              class="version-card"
              :class="{ 'version-card-visible': visibleVersions[(currentPage - 1) * itemsPerPage + index] }"
              :style="{ animationDelay: `${index * 0.1}s` }"
            >
              <div class="version-card-header">
                <div class="version-number">{{ version.version }}</div>
                <div class="version-date-badge">{{ version.date }}</div>
              </div>
              <div class="version-content">
                <h3 class="version-title-text">{{ version.title }}</h3>
                <p class="version-description">{{ version.description }}</p>
              </div>
            </div>
          </div>

          <!-- 分页控件 -->
          <div v-if="totalPages > 1" class="pagination-container">
            <div class="pagination-info">
              共 {{ Math.max(0, versions.length - 1) }} 个版本，第 {{ currentPage }} / {{ totalPages }} 页
            </div>
            <div class="pagination-controls">
              <button 
                @click="prevPage" 
                :disabled="currentPage === 1"
                class="pagination-button"
                :class="{ 'disabled': currentPage === 1 }"
              >
                上一页
              </button>
              
              <div class="pagination-numbers">
                <button
                  v-for="(page, index) in pageNumbers"
                  :key="index"
                  @click="typeof page === 'number' ? goToPage(page) : null"
                  :disabled="page === '...'"
                  class="pagination-number"
                  :class="{ 
                    'active': page === currentPage,
                    'ellipsis': page === '...',
                    'disabled': page === '...'
                  }"
                >
                  {{ page }}
                </button>
              </div>
              
              <button 
                @click="nextPage" 
                :disabled="currentPage === totalPages"
                class="pagination-button"
                :class="{ 'disabled': currentPage === totalPages }"
              >
                下一页
              </button>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 页脚 -->
    <footer class="footer">
      <div class="footer-container">
        <div class="footer-content">
          <div class="footer-section">
            <div class="footer-logo">
              <img src="/favicon.ico" alt="Logo" class="logo-icon" />
              <span class="logo-text">XM邮件管理系统</span>
            </div>
            <p class="footer-description">企业级邮件管理系统，智能化、自动化、安全可靠</p>
          </div>
          <div class="footer-section">
            <h4 class="footer-title">产品</h4>
            <ul class="footer-links">
              <li><router-link to="/#features">特性</router-link></li>
              <li><router-link to="/#architecture">架构</router-link></li>
              <li><router-link to="/#tech-stack">技术栈</router-link></li>
            </ul>
          </div>
          <div class="footer-section">
            <h4 class="footer-title">资源</h4>
            <ul class="footer-links">
              <li><router-link to="/changelog">更新日志</router-link></li>
              <li><a href="#support">支持</a></li>
              <li><a href="https://github.com/xm666xm666/XM-mail/" target="_blank" rel="noopener noreferrer">GitHub</a></li>
            </ul>
          </div>
          <div class="footer-section">
            <h4 class="footer-title">联系</h4>
            <ul class="footer-links">
              <li><a href="mailto:xm@localhost">邮箱</a></li>
              <li><a href="#contact">联系我们</a></li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <div class="copyright">
            <svg viewBox="0 0 24 24" fill="currentColor">
              <circle cx="12" cy="12" r="10"/>
              <text x="12" y="16" text-anchor="middle" font-size="8" font-weight="bold">C</text>
            </svg>
            <span>2024-2026 XM.</span>
            <!-- 备案号显示 -->
            <span v-if="icpSettings.enabled && icpSettings.number" class="icp-inline">
              <a :href="icpSettings.url" target="_blank" rel="noopener noreferrer">
                {{ icpSettings.number }}
              </a>
            </span>
          </div>
          <div class="footer-text">XM邮件管理平台 | 欢迎使用</div>
          <div class="version-text">Powered by XM {{ currentVersion }}</div>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { versionManager } from '../utils/versionManager'

const router = useRouter()

// 版本管理
const currentVersion = ref('V0.0.1')

// 备案号设置
const icpSettings = ref({
  enabled: false,
  number: '',
  url: 'https://beian.miit.gov.cn/'
})

// 加载系统设置（仅获取备案号相关设置）
const loadIcpSettings = async () => {
  try {
    // 使用公开的备案号API，无需认证
    const response = await fetch('/api/icp-info')
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.icp) {
        icpSettings.value = {
          enabled: data.icp.enabled || false,
          number: data.icp.number || '',
          url: data.icp.url || 'https://beian.miit.gov.cn/'
        }
      }
    }
  } catch (error) {
    console.warn('加载备案号设置失败:', error)
  }
}

// 移动端菜单状态
const mobileMenuOpen = ref(false)

const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

const closeMobileMenu = () => {
  mobileMenuOpen.value = false
}

// 获取版本信息
const loadVersion = async () => {
  try {
    const version = await versionManager.getVersion()
    currentVersion.value = `V${version}`
  } catch (error) {
    console.warn('获取版本信息失败:', error)
  }
}

// 更新日志数据
const versions = ref<any[]>([])
const latestVersion = ref<any>(null)
const loading = ref(true)
const error = ref<string | null>(null)
const visibleVersions = ref<boolean[]>([])
let observer: IntersectionObserver | null = null

// 分页相关
const currentPage = ref(1)
const itemsPerPage = 15
const totalPages = ref(1)

// 粒子样式
const getParticleStyle = (index: number) => {
  const size = Math.random() * 3 + 1
  const duration = Math.random() * 20 + 10
  const delay = Math.random() * 5
  const x = Math.random() * 100
  return {
    width: `${size}px`,
    height: `${size}px`,
    left: `${x}%`,
    animationDuration: `${duration}s`,
    animationDelay: `${delay}s`
  }
}

// 加载更新日志
const loadChangelog = async () => {
  try {
    loading.value = true
    error.value = null
    
    const response = await fetch('/api/changelog')
    if (!response.ok) {
      throw new Error('获取更新日志失败')
    }
    
    const data = await response.json()
    if (data.success) {
      versions.value = data.versions || []
      latestVersion.value = data.latestVersion
      // 计算总页数时，排除第一个版本（因为最新版本卡片已经显示了）
      const historyVersionsCount = Math.max(0, versions.value.length - 1)
      totalPages.value = Math.ceil(historyVersionsCount / itemsPerPage)
      // visibleVersions 数组也需要排除第一个版本
      visibleVersions.value = new Array(historyVersionsCount).fill(false)
      
      // 设置滚动观察器
      setTimeout(() => {
        setupScrollObserver()
      }, 100)
    } else {
      throw new Error(data.error || '获取更新日志失败')
    }
  } catch (err: any) {
    console.error('加载更新日志失败:', err)
    error.value = err.message || '加载更新日志失败，请稍后重试'
  } finally {
    loading.value = false
  }
}

// 计算当前页显示的版本（跳过第一个版本，因为最新版本卡片已经显示了）
const paginatedVersions = computed(() => {
  // 从第二个版本开始显示（索引1开始）
  const historyVersions = versions.value.slice(1)
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return historyVersions.slice(start, end)
})

// 分页导航
const goToPage = (page: number) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    // 滚动到顶部
    window.scrollTo({ top: 0, behavior: 'smooth' })
    // 重新设置观察器
    setTimeout(() => {
      setupScrollObserver()
    }, 100)
  }
}

const prevPage = () => {
  if (currentPage.value > 1) {
    goToPage(currentPage.value - 1)
  }
}

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    goToPage(currentPage.value + 1)
  }
}

// 生成页码数组
const pageNumbers = computed(() => {
  const pages: (number | string)[] = []
  const total = totalPages.value
  const current = currentPage.value
  
  if (total <= 7) {
    // 如果总页数少于等于7，显示所有页码
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // 显示逻辑：首页、当前页附近、末页
    pages.push(1)
    
    if (current > 3) {
      pages.push('...')
    }
    
    const start = Math.max(2, current - 1)
    const end = Math.min(total - 1, current + 1)
    
    for (let i = start; i <= end; i++) {
      pages.push(i)
    }
    
    if (current < total - 2) {
      pages.push('...')
    }
    
    pages.push(total)
  }
  
  return pages
})

// 设置滚动监听
const setupScrollObserver = () => {
  // 清理旧的观察器
  if (observer) {
    observer.disconnect()
  }
  
  const versionCards = document.querySelectorAll('.version-card')
  if (versionCards.length === 0) return

  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          const cards = Array.from(versionCards)
          const index = cards.indexOf(entry.target as Element)
          if (index !== -1) {
            // 注意：这里不需要加1，因为 paginatedVersions 已经排除了第一个版本
            const globalIndex = (currentPage.value - 1) * itemsPerPage + index
            if (globalIndex >= 0 && globalIndex < visibleVersions.value.length) {
              visibleVersions.value[globalIndex] = true
            }
          }
        }
      })
    },
    {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    }
  )

  versionCards.forEach((card) => {
    observer?.observe(card)
  })
}

const goToLogin = () => {
  router.push('/login')
}

const goToRegister = () => {
  router.push('/register')
}

// 组件挂载时加载数据
onMounted(() => {
  loadVersion()
  loadIcpSettings()
  loadChangelog()
})

// 组件卸载时清理观察器
onUnmounted(() => {
  if (observer) {
    observer.disconnect()
    observer = null
  }
})
</script>

<style scoped>
.changelog-page {
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
  background: #0a0a0f;
  color: #ffffff;
}

/* 科幻背景效果 */
.sci-fi-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 0;
  overflow: hidden;
}

.gradient-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.3;
  animation: float 20s ease-in-out infinite;
}

.orb-1 {
  width: 600px;
  height: 600px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  top: -200px;
  left: -200px;
  animation-delay: 0s;
}

.orb-2 {
  width: 500px;
  height: 500px;
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  bottom: -150px;
  right: -150px;
  animation-delay: 5s;
}

.orb-3 {
  width: 400px;
  height: 400px;
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation-delay: 10s;
}

@keyframes float {
  0%, 100% {
    transform: translate(0, 0) scale(1);
  }
  33% {
    transform: translate(30px, -30px) scale(1.1);
  }
  66% {
    transform: translate(-20px, 20px) scale(0.9);
  }
}

.grid-pattern {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-image: 
    linear-gradient(rgba(102, 126, 234, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(102, 126, 234, 0.1) 1px, transparent 1px);
  background-size: 50px 50px;
  opacity: 0.3;
}

.particle-container {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.particle {
  position: absolute;
  background: rgba(102, 126, 234, 0.6);
  border-radius: 50%;
  animation: particle-float linear infinite;
}

@keyframes particle-float {
  0% {
    transform: translateY(100vh) translateX(0);
    opacity: 0;
  }
  10% {
    opacity: 1;
  }
  90% {
    opacity: 1;
  }
  100% {
    transform: translateY(-100px) translateX(100px);
    opacity: 0;
  }
}

/* 导航栏 */
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 100;
  padding: 1.5rem 0;
  background: rgba(10, 10, 15, 0.8);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(102, 126, 234, 0.2);
}

.nav-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.5rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-decoration: none;
}

.logo-icon {
  width: 2rem;
  height: 2rem;
  object-fit: contain;
}

.nav-links {
  display: flex;
  align-items: center;
  gap: 2rem;
}

.nav-link {
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  font-size: 0.95rem;
  transition: color 0.3s ease;
  position: relative;
}

.nav-link:hover,
.nav-link.active {
  color: #667eea;
}

.nav-link::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, #667eea, #764ba2);
  transition: width 0.3s ease;
}

.nav-link:hover::after,
.nav-link.active::after {
  width: 100%;
}

.nav-button {
  padding: 0.6rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.nav-button.secondary {
  background: transparent;
  border: 2px solid rgba(102, 126, 234, 0.5);
  color: rgba(255, 255, 255, 0.9);
}

.nav-button.secondary:hover {
  background: rgba(102, 126, 234, 0.1);
  border-color: rgba(102, 126, 234, 0.8);
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
}

.nav-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
}

/* 主内容区域 */
.changelog-section {
  position: relative;
  z-index: 1;
  padding: 10rem 2rem 4rem;
  min-height: 100vh;
}

.section-container {
  max-width: 1200px;
  margin: 0 auto;
}

.section-header {
  text-align: center;
  margin-bottom: 4rem;
}

.page-title {
  font-size: clamp(2.5rem, 5vw, 4rem);
  font-weight: 800;
  margin-bottom: 1rem;
  background: linear-gradient(135deg, #ffffff 0%, #667eea 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.7);
}

/* 加载和错误状态 */
.loading-container,
.error-container {
  text-align: center;
  padding: 4rem 2rem;
}

.loading-spinner {
  width: 50px;
  height: 50px;
  border: 4px solid rgba(102, 126, 234, 0.2);
  border-top-color: #667eea;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  margin: 0 auto 1.5rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-text {
  color: rgba(255, 255, 255, 0.7);
  font-size: 1.1rem;
}

.error-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
}

.error-text {
  color: rgba(255, 255, 255, 0.7);
  font-size: 1.1rem;
  margin-bottom: 2rem;
}

.retry-button {
  padding: 0.75rem 2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.retry-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
}

/* 版本列表 */
.versions-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.latest-version-card {
  background: rgba(255, 255, 255, 0.05);
  border: 2px solid rgba(102, 126, 234, 0.5);
  border-radius: 20px;
  padding: 2.5rem;
  backdrop-filter: blur(20px);
  box-shadow: 0 20px 60px rgba(102, 126, 234, 0.2);
  animation: fadeInUp 0.6s ease-out;
}

.version-badge {
  display: inline-block;
  padding: 0.5rem 1rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
  margin-bottom: 1.5rem;
}

.version-header {
  display: flex;
  align-items: center;
  gap: 1.5rem;
  flex-wrap: wrap;
  margin-bottom: 1.5rem;
}

.version-title {
  font-size: 2.5rem;
  font-weight: 800;
  background: linear-gradient(135deg, #ffffff 0%, #667eea 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
}

.version-date {
  padding: 0.5rem 1rem;
  background: rgba(102, 126, 234, 0.2);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 12px;
  font-size: 0.9rem;
  color: rgba(255, 255, 255, 0.8);
}

.latest-version-card .version-content {
  margin-top: 0;
}

.latest-version-card .version-title-text {
  font-size: 1.3rem;
  font-weight: 600;
  color: white;
  margin-bottom: 1rem;
}

.latest-version-card .version-description {
  color: rgba(255, 255, 255, 0.8);
  line-height: 1.8;
  font-size: 1rem;
}

.versions-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.version-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 16px;
  padding: 2rem;
  backdrop-filter: blur(10px);
  transition: all 0.3s ease;
  opacity: 0;
  transform: translateY(30px);
}

.version-card-visible {
  animation: fadeInUp 0.6s ease-out forwards;
}

.version-card:hover {
  transform: translateY(-5px);
  border-color: rgba(102, 126, 234, 0.5);
  box-shadow: 0 10px 30px rgba(102, 126, 234, 0.2);
  background: rgba(255, 255, 255, 0.08);
}

.version-card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  flex-wrap: wrap;
  gap: 1rem;
}

.version-number {
  font-size: 1.5rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.version-date-badge {
  padding: 0.4rem 0.8rem;
  background: rgba(102, 126, 234, 0.2);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 8px;
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.8);
}

.version-content {
  margin-top: 1rem;
}

.version-title-text {
  font-size: 1.2rem;
  font-weight: 600;
  color: white;
  margin-bottom: 0.75rem;
}

.version-description {
  color: rgba(255, 255, 255, 0.7);
  line-height: 1.8;
  font-size: 0.95rem;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 分页控件 */
.pagination-container {
  margin-top: 3rem;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 16px;
  backdrop-filter: blur(10px);
}

.pagination-info {
  text-align: center;
  color: rgba(255, 255, 255, 0.7);
  font-size: 0.9rem;
  margin-bottom: 1.5rem;
}

.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.pagination-button {
  padding: 0.6rem 1.5rem;
  background: rgba(102, 126, 234, 0.2);
  border: 1px solid rgba(102, 126, 234, 0.3);
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.9);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.pagination-button:hover:not(.disabled) {
  background: rgba(102, 126, 234, 0.4);
  border-color: rgba(102, 126, 234, 0.5);
  transform: translateY(-2px);
}

.pagination-button.disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.pagination-numbers {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.pagination-number {
  min-width: 40px;
  height: 40px;
  padding: 0 0.75rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 8px;
  color: rgba(255, 255, 255, 0.8);
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.pagination-number:hover:not(.disabled):not(.active) {
  background: rgba(102, 126, 234, 0.2);
  border-color: rgba(102, 126, 234, 0.4);
  transform: translateY(-2px);
}

.pagination-number.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: rgba(102, 126, 234, 0.5);
  color: white;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
}

.pagination-number.ellipsis {
  border: none;
  background: transparent;
  cursor: default;
  min-width: auto;
  padding: 0 0.5rem;
}

.pagination-number.disabled {
  cursor: default;
}

/* 页脚 */
.footer {
  position: relative;
  z-index: 1;
  padding: 4rem 2rem 2rem;
  background: rgba(10, 10, 15, 0.8);
  border-top: 1px solid rgba(102, 126, 234, 0.2);
}

.footer-container {
  max-width: 1400px;
  margin: 0 auto;
}

.footer-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 3rem;
  margin-bottom: 3rem;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-size: 1.5rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 1rem;
}

.footer-description {
  color: rgba(255, 255, 255, 0.6);
  line-height: 1.6;
}

.footer-title {
  font-size: 1.1rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: white;
}

.footer-links {
  list-style: none;
  padding: 0;
  margin: 0;
}

.footer-links li {
  margin-bottom: 0.75rem;
}

.footer-links a {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  transition: color 0.3s ease;
}

.footer-links a:hover {
  color: #667eea;
}

.footer-bottom {
  text-align: center;
  padding-top: 2rem;
  border-top: 1px solid rgba(102, 126, 234, 0.2);
}

.copyright {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.6);
}

.copyright svg {
  width: 16px;
  height: 16px;
}

.footer-text {
  font-size: 0.8rem;
  color: rgba(255, 255, 255, 0.5);
  margin-bottom: 0.25rem;
}

.version-text {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.4);
}

.icp-inline {
  margin-left: 0.75rem;
  font-size: 0.75rem;
}

.icp-inline a {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  transition: color 0.3s ease;
}

.icp-inline a:hover {
  color: rgba(255, 255, 255, 0.8);
}

/* 移动端菜单按钮 */
.mobile-menu-toggle {
  display: none;
  flex-direction: column;
  gap: 5px;
  background: transparent;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  z-index: 101;
}

.hamburger-line {
  width: 25px;
  height: 3px;
  background: #667eea;
  border-radius: 2px;
  transition: all 0.3s ease;
}

.mobile-menu-toggle[aria-expanded="true"] .hamburger-line:nth-child(1) {
  transform: rotate(45deg) translate(8px, 8px);
}

.mobile-menu-toggle[aria-expanded="true"] .hamburger-line:nth-child(2) {
  opacity: 0;
}

.mobile-menu-toggle[aria-expanded="true"] .hamburger-line:nth-child(3) {
  transform: rotate(-45deg) translate(7px, -7px);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .nav-container {
    padding: 0 1rem;
  }

  .logo-text {
    font-size: 1.2rem;
  }

  .logo-icon {
    width: 1.5rem;
    height: 1.5rem;
  }

  .mobile-menu-toggle {
    display: flex;
  }

  .nav-links {
    position: fixed;
    top: 0;
    right: -100%;
    width: 280px;
    height: 100vh;
    background: rgba(10, 10, 15, 0.98);
    backdrop-filter: blur(20px);
    flex-direction: column;
    align-items: flex-start;
    padding: 5rem 2rem 2rem;
    gap: 1.5rem;
    border-left: 1px solid rgba(102, 126, 234, 0.2);
    transition: right 0.3s ease;
    z-index: 100;
    overflow-y: auto;
  }

  .nav-links.mobile-menu-open {
    right: 0;
  }

  .nav-link {
    display: block;
    width: 100%;
    padding: 0.75rem 0;
    font-size: 1rem;
  }

  .nav-button {
    width: 100%;
    padding: 0.75rem 1.5rem;
    font-size: 0.95rem;
    justify-content: center;
  }

  .changelog-section {
    padding: 6rem 1rem 2rem;
  }

  .section-header {
    margin-bottom: 2.5rem;
  }

  .page-title {
    font-size: 2rem;
  }

  .page-subtitle {
    font-size: 1rem;
  }

  .latest-version-card {
    padding: 1.5rem;
  }

  .version-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .version-title {
    font-size: 2rem;
  }

  .version-card {
    padding: 1.5rem;
  }

  .version-card-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
  }

  .version-number {
    font-size: 1.3rem;
  }

  .version-title-text {
    font-size: 1.1rem;
  }

  .version-description {
    font-size: 0.9rem;
    line-height: 1.6;
  }

  .pagination-container {
    padding: 1.5rem 1rem;
  }

  .pagination-info {
    font-size: 0.85rem;
    margin-bottom: 1rem;
  }

  .pagination-controls {
    flex-direction: column;
    gap: 1rem;
  }

  .pagination-button {
    width: 100%;
    padding: 0.75rem 1.5rem;
    font-size: 0.9rem;
  }

  .pagination-numbers {
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.5rem;
  }

  .pagination-number {
    min-width: 36px;
    height: 36px;
    font-size: 0.85rem;
  }

  .footer {
    padding: 3rem 1rem 1.5rem;
  }

  .footer-content {
    grid-template-columns: repeat(2, 1fr);
    gap: 2rem;
  }

  .footer-section:first-child {
    grid-column: 1 / -1;
  }

  .footer-logo {
    font-size: 1.2rem;
  }

  .footer-title {
    font-size: 1rem;
    margin-bottom: 0.75rem;
  }

  .footer-links li {
    margin-bottom: 0.5rem;
  }

  .footer-links a {
    font-size: 0.9rem;
  }

  .footer-bottom {
    text-align: center;
  }

  .copyright,
  .footer-text,
  .version-text {
    font-size: 0.75rem;
  }
}

@media (max-width: 480px) {
  .page-title {
    font-size: 1.75rem;
  }

  .latest-version-card .version-title {
    font-size: 1.75rem;
  }

  .version-card {
    padding: 1.25rem;
  }

  .pagination-numbers {
    gap: 0.25rem;
  }

  .pagination-number {
    min-width: 32px;
    height: 32px;
    font-size: 0.8rem;
    padding: 0 0.5rem;
  }

  .nav-links {
    width: 100%;
  }

  .footer-content {
    grid-template-columns: repeat(2, 1fr);
    gap: 1.5rem;
  }

  .footer-section:first-child {
    grid-column: 1 / -1;
  }

  .footer-title {
    font-size: 0.95rem;
  }

  .footer-links a {
    font-size: 0.85rem;
  }
}
</style>
