<template>
  <div class="landing-page">
    <AnimatedBackground />
    <!-- 导航栏 -->
    <nav class="navbar">
      <div class="nav-container">
        <div class="logo">
          <img src="/favicon.ico" alt="Logo" class="logo-icon" />
          <span class="logo-text">XM邮件管理系统</span>
        </div>
        <button class="mobile-menu-toggle" @click="toggleMobileMenu" :aria-expanded="mobileMenuOpen">
          <span class="hamburger-line"></span>
          <span class="hamburger-line"></span>
          <span class="hamburger-line"></span>
        </button>
        <div class="nav-links" :class="{ 'mobile-menu-open': mobileMenuOpen }">
          <a href="#features" class="nav-link" @click="closeMobileMenu">特性</a>
          <a href="#architecture" class="nav-link" @click="closeMobileMenu">架构</a>
          <a href="#tech-stack" class="nav-link" @click="closeMobileMenu">技术栈</a>
          <router-link to="/changelog" class="nav-link" @click="closeMobileMenu">更新日志</router-link>
          <button @click="goToRegister" class="nav-button secondary">注册</button>
          <button @click="goToLogin" class="nav-button">登录</button>
        </div>
      </div>
    </nav>

    <!-- 主标题区域 -->
    <section class="hero-section">
      <div class="hero-content">
        <div class="hero-badge">
          <span class="badge-text">{{ currentVersion }}</span>
          <span class="badge-dot"></span>
        </div>
        <h1 class="hero-title">
          <span class="title-line">智能无限，</span>
          <span class="title-line highlight">邮件无界</span>
        </h1>
        <p class="hero-subtitle">
          XM邮件管理系统，一个能理解需求、独立完成各类邮件服务任务的企业级系统，
          <br />
          助你高效推进邮件服务的每一步。
        </p>
        <div class="hero-actions">
          <button @click="goToLogin" class="cta-button primary">
            <span>立即开始</span>
            <svg class="arrow-icon" viewBox="0 0 24 24" fill="none">
              <path d="M5 12h14M12 5l7 7-7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
          <button @click="scrollToFeatures" class="cta-button secondary">
            <span>探索特性</span>
          </button>
        </div>
        <div class="hero-stats">
          <div class="stat-item">
            <div class="stat-number">15</div>
            <div class="stat-label">数据库表</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">21</div>
            <div class="stat-label">核心脚本</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">7</div>
            <div class="stat-label">架构层次</div>
          </div>
          <div class="stat-item">
            <div class="stat-number">∞</div>
            <div class="stat-label">无限可能</div>
          </div>
        </div>
      </div>
    </section>

    <!-- 特性展示区域 -->
    <section id="features" class="features-section">
      <div class="section-container">
        <div class="section-header">
          <h2 class="section-title">核心特性</h2>
          <p class="section-subtitle">企业级邮件服务，智能化管理，自动化部署</p>
        </div>
        <div class="features-grid">
          <div v-for="(feature, index) in features" :key="index" class="feature-card" :style="{ animationDelay: `${index * 0.1}s` }">
            <div class="feature-icon">{{ feature.icon }}</div>
            <h3 class="feature-title">{{ feature.title }}</h3>
            <p class="feature-description">{{ feature.description }}</p>
            <div class="feature-tags">
              <span v-for="tag in feature.tags" :key="tag" class="feature-tag">{{ tag }}</span>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 架构展示区域 -->
    <section id="architecture" class="architecture-section">
      <div class="section-container">
        <div class="section-header">
          <h2 class="section-title">系统架构</h2>
          <p class="section-subtitle">分层架构设计，职责清晰，易于扩展</p>
        </div>
        <div class="architecture-visual" ref="architectureRef">
          <div 
            class="arch-layer" 
            v-for="(layer, index) in architectureLayers" 
            :key="index"
            :class="{ 'arch-layer-visible': visibleLayers[index] }"
            :style="{ animationDelay: `${index * 0.15}s` }"
          >
            <div class="layer-number">{{ String(index + 1).padStart(2, '0') }}</div>
            <div class="layer-content">
              <h3 class="layer-title">{{ layer.name }}</h3>
              <p class="layer-description">{{ layer.description }}</p>
              <div class="layer-tech">
                <span v-for="tech in layer.tech" :key="tech" class="tech-badge">{{ tech }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 技术栈展示 -->
    <section id="tech-stack" class="tech-stack-section">
      <div class="section-container">
        <div class="section-header">
          <h2 class="section-title">技术栈</h2>
          <p class="section-subtitle">现代化技术栈，稳定可靠，性能卓越</p>
        </div>
        <div class="tech-categories" ref="techStackRef">
          <div 
            v-for="(category, index) in techStack" 
            :key="index" 
            class="tech-category"
            :class="{ 'tech-category-visible': visibleTechCategories[index] }"
            :style="{ animationDelay: `${index * 0.15}s` }"
          >
            <h3 class="category-title">{{ category.name }}</h3>
            <div class="tech-items">
              <div v-for="tech in category.items" :key="tech.name" class="tech-item">
                <div class="tech-icon">{{ tech.icon }}</div>
                <div class="tech-info">
                  <div class="tech-name">{{ tech.name }}</div>
                  <div class="tech-version">{{ tech.version }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA区域 -->
    <section class="cta-section">
      <div class="cta-container">
        <div class="cta-content">
          <h2 class="cta-title">准备好开始了吗？</h2>
          <p class="cta-subtitle">一键部署，即刻体验企业级邮件服务</p>
          <div class="cta-actions">
            <button @click="goToLogin" class="cta-button large primary">
              <span>立即登录</span>
              <svg class="arrow-icon" viewBox="0 0 24 24" fill="none">
                <path d="M5 12h14M12 5l7 7-7 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              </svg>
            </button>
            <button @click="goToRegister" class="cta-button large secondary">
              <span>立即注册</span>
            </button>
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
              <li><a href="#features">特性</a></li>
              <li><a href="#architecture">架构</a></li>
              <li><a href="#tech-stack">技术栈</a></li>
            </ul>
          </div>
          <div class="footer-section">
            <h4 class="footer-title">资源</h4>
            <ul class="footer-links">
              <li><router-link to="/changelog">更新日志</router-link></li>
              <li><a href="https://github.com/xm666xm666/XM-mail/" target="_blank" rel="noopener noreferrer">GitHub</a></li>
            </ul>
          </div>
          <div class="footer-section">
            <h4 class="footer-title">联系</h4>
            <ul class="footer-links">
              <li><a href="mailto:admin@xm666.fun">邮箱</a></li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <CopyrightFooter variant="marketing" :icp="icpSettings" :version="currentVersion" />
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { versionManager } from '../utils/versionManager'
import AnimatedBackground from '../components/AnimatedBackground.vue'
import CopyrightFooter from '../components/CopyrightFooter.vue'

const router = useRouter()

// 版本管理（初始值，实际从 API 加载；0.0.1 表示获取失败/系统错误）
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

// 架构区域可见性管理
const architectureRef = ref<HTMLElement | null>(null)
const visibleLayers = ref<boolean[]>(new Array(7).fill(false))
let observer: IntersectionObserver | null = null

// 技术栈区域可见性管理
const techStackRef = ref<HTMLElement | null>(null)
const visibleTechCategories = ref<boolean[]>(new Array(4).fill(false))
let techObserver: IntersectionObserver | null = null

// 设置滚动监听
const setupScrollObserver = () => {
  if (!architectureRef.value) return

  observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          // 当架构区域进入视口时，逐个显示条框
          architectureLayers.forEach((_, index) => {
            setTimeout(() => {
              visibleLayers.value[index] = true
            }, index * 150) // 每个条框延迟150ms
          })
          // 触发一次后取消观察
          if (observer && architectureRef.value) {
            observer.unobserve(architectureRef.value)
          }
        }
      })
    },
    {
      threshold: 0.2, // 当20%的区域可见时触发
      rootMargin: '0px 0px -100px 0px' // 提前100px触发
    }
  )

  observer.observe(architectureRef.value)
}

// 设置技术栈滚动监听
const setupTechScrollObserver = () => {
  if (!techStackRef.value) return

  techObserver = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          // 当技术栈区域进入视口时，逐个显示卡片
          techStack.forEach((_, index) => {
            setTimeout(() => {
              visibleTechCategories.value[index] = true
            }, index * 150) // 每个卡片延迟150ms
          })
          // 触发一次后取消观察
          if (techObserver && techStackRef.value) {
            techObserver.unobserve(techStackRef.value)
          }
        }
      })
    },
    {
      threshold: 0.2, // 当20%的区域可见时触发
      rootMargin: '0px 0px -100px 0px' // 提前100px触发
    }
  )

  techObserver.observe(techStackRef.value)
}

const goToLogin = () => {
  router.push('/login')
}

const goToRegister = () => {
  router.push('/register')
}

const scrollToFeatures = () => {
  const element = document.getElementById('features')
  element?.scrollIntoView({ behavior: 'smooth' })
}

const features = [
  {
    icon: '🚀',
    title: '一键部署',
    description: '自动化部署流程，无需手动配置，几分钟内完成系统部署',
    tags: ['自动化', '快速部署', '零配置']
  },
  {
    icon: '🔒',
    title: '安全可靠',
    description: '多层安全防护，密码加密存储，操作审计，SSL/TLS加密传输',
    tags: ['安全', '加密', '审计']
  },
  {
    icon: '📧',
    title: '邮件管理',
    description: '完整的邮件收发功能，文件夹管理，标签分类，附件支持',
    tags: ['SMTP', 'IMAP', 'POP3']
  },
  {
    icon: '👥',
    title: '用户管理',
    description: '虚拟用户支持，多域名管理，批量操作，权限控制',
    tags: ['虚拟用户', '多域名', '权限']
  },
  {
    icon: '📊',
    title: '系统监控',
    description: '实时监控服务状态，资源使用情况，日志查看，健康检查',
    tags: ['监控', '日志', '健康检查']
  },
  {
    icon: '🌐',
    title: 'DNS配置',
    description: '支持Bind DNS和公网DNS，自动配置DNS记录，健康检查',
    tags: ['DNS', '自动化', '健康检查']
  },
  {
    icon: '💾',
    title: '备份恢复',
    description: '自动备份数据库和配置文件，支持定时备份，一键恢复',
    tags: ['备份', '恢复', '定时任务']
  },
  {
    icon: '🛡️',
    title: '垃圾过滤',
    description: '智能垃圾邮件过滤，关键词检测，域名黑名单，规则过滤',
    tags: ['过滤', '安全', '智能']
  }
]

const architectureLayers = [
  {
    name: '用户访问层',
    description: '支持Web浏览器、邮件客户端和移动设备访问',
    tech: ['Web浏览器', '邮件客户端', '移动设备']
  },
  {
    name: 'Web服务层',
    description: 'Apache提供静态文件服务和API反向代理',
    tech: ['Apache 2.4', '反向代理', 'SSL/TLS']
  },
  {
    name: '应用服务层',
    description: 'Node.js Express调度层，统一管理脚本执行和API路由',
    tech: ['Node.js', 'Express', 'WebSocket']
  },
  {
    name: '业务逻辑层',
    description: '21个Bash脚本 + store_attachments.js，实现各种业务功能',
    tech: ['Bash脚本', '自动化', '权限管理']
  },
  {
    name: '邮件服务层',
    description: 'Postfix和Dovecot提供邮件收发服务',
    tech: ['Postfix', 'Dovecot', 'Maildir']
  },
  {
    name: '数据存储层',
    description: '双数据库架构，15张表，完整的数据管理',
    tech: ['MariaDB', '15张表', '数据管理']
  },
  {
    name: '基础设施层',
    description: 'DNS、systemd、日志系统等基础设施服务',
    tech: ['DNS', 'systemd', '日志系统']
  }
]

const techStack = [
  {
    name: '前端技术',
    items: [
      { name: 'Vue 3', version: '3.5.29', icon: '⚡' },
      { name: 'TypeScript', version: 'Latest', icon: '📘' },
      { name: 'Tailwind CSS', version: '4.2.1', icon: '🎨' },
      { name: 'Vite', version: '7.3.1', icon: '⚙️' },
      { name: '@xterm/xterm', version: '6.0.0', icon: '🖥️' }
    ]
  },
  {
    name: '后端技术',
    items: [
      { name: 'Node.js', version: 'v24.14.0 (LTS Krypton)', icon: '🟢' },
      { name: 'Express', version: '5.2.1', icon: '🚂' },
      { name: 'WebSocket', version: '8.19.0', icon: '🔌' },
      { name: 'node-pty', version: '1.1.0', icon: '💻' }
    ]
  },
  {
    name: '邮件服务',
    items: [
      { name: 'Postfix', version: 'Latest', icon: '📮' },
      { name: 'Dovecot', version: 'Latest', icon: '📬' },
      { name: 'MariaDB', version: '10.5+', icon: '🗄️' }
    ]
  },
  {
    name: '系统环境',
    items: [
      { name: 'Rocky Linux', version: '9.x', icon: '🐧' },
      { name: 'Apache', version: '2.4', icon: '🌐' },
      { name: 'systemd', version: 'Latest', icon: '⚙️' }
    ]
  }
]

// 组件挂载时获取版本信息和设置滚动监听
onMounted(() => {
  loadVersion()
  loadIcpSettings()
  setTimeout(() => {
    setupScrollObserver()
    setupTechScrollObserver()
  }, 100)
})

// 组件卸载时清理观察器
onUnmounted(() => {
  if (observer) {
    observer.disconnect()
    observer = null
  }
  if (techObserver) {
    techObserver.disconnect()
    techObserver = null
  }
})
</script>

<style scoped>
.landing-page {
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
  background: #0c0e14;
  color: #f8fafc;
  font-family: 'Plus Jakarta Sans', system-ui, sans-serif;
}

/* 导航栏 - 高端玻璃拟态 */
.navbar {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  z-index: 100;
  padding: 1.25rem 0;
  background: rgba(12, 14, 20, 0.85);
  backdrop-filter: blur(24px);
  -webkit-backdrop-filter: blur(24px);
  border-bottom: 1px solid rgba(245, 158, 11, 0.12);
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
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 50%, #d97706 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  letter-spacing: -0.02em;
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
  color: rgba(248, 250, 252, 0.75);
  text-decoration: none;
  font-size: 0.95rem;
  font-weight: 500;
  transition: color 0.3s ease;
  position: relative;
}

.nav-link:hover {
  color: #fbbf24;
}

.nav-link::after {
  content: '';
  position: absolute;
  bottom: -5px;
  left: 0;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, #fbbf24, #f59e0b);
  transition: width 0.3s ease;
}

.nav-link:hover::after {
  width: 100%;
}

.nav-button {
  padding: 0.6rem 1.5rem;
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  border: none;
  border-radius: 10px;
  color: #0c0e14;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 14px rgba(245, 158, 11, 0.25);
}

.nav-button.secondary {
  background: transparent;
  border: 1px solid rgba(245, 158, 11, 0.4);
  color: #fbbf24;
}

.nav-button.secondary:hover {
  background: rgba(245, 158, 11, 0.1);
  border-color: rgba(245, 158, 11, 0.6);
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(245, 158, 11, 0.15);
}

.nav-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(245, 158, 11, 0.35);
}

/* 主标题区域 */
.hero-section {
  position: relative;
  z-index: 1;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 8rem 2rem 4rem;
}

.hero-content {
  max-width: 1200px;
  text-align: center;
  animation: fadeInUp 1s ease-out;
}

.hero-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1.25rem;
  background: rgba(245, 158, 11, 0.08);
  border: 1px solid rgba(245, 158, 11, 0.25);
  border-radius: 100px;
  margin-bottom: 2rem;
  font-size: 0.9rem;
  font-weight: 500;
  color: #fbbf24;
  letter-spacing: 0.02em;
}

.badge-dot {
  width: 8px;
  height: 8px;
  background: #f59e0b;
  border-radius: 50%;
  animation: pulse 2s ease-in-out infinite;
  box-shadow: 0 0 12px rgba(245, 158, 11, 0.6);
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
    transform: scale(1);
  }
  50% {
    opacity: 0.6;
    transform: scale(1.2);
  }
}

.hero-title {
  font-size: clamp(3rem, 8vw, 5.5rem);
  font-weight: 800;
  line-height: 1.08;
  margin-bottom: 1.5rem;
  letter-spacing: -0.03em;
  background: linear-gradient(135deg, #f8fafc 0%, #fbbf24 40%, #f59e0b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.title-line {
  display: block;
}

.title-line.highlight {
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.hero-subtitle {
  font-size: clamp(1.1rem, 2vw, 1.25rem);
  color: rgba(248, 250, 252, 0.65);
  line-height: 1.85;
  margin-bottom: 3rem;
  max-width: 720px;
  margin-left: auto;
  margin-right: auto;
  font-weight: 400;
}

.hero-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 4rem;
  flex-wrap: wrap;
}

.cta-button {
  display: inline-flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 2rem;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.cta-button.primary {
  background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
  color: #0c0e14;
  box-shadow: 0 8px 24px rgba(245, 158, 11, 0.3);
}

.cta-button.primary:hover {
  transform: translateY(-3px);
  box-shadow: 0 16px 40px rgba(245, 158, 11, 0.4);
}

.cta-button.secondary {
  background: rgba(255, 255, 255, 0.06);
  color: #f8fafc;
  border: 1px solid rgba(245, 158, 11, 0.3);
}

.cta-button.secondary:hover {
  background: rgba(245, 158, 11, 0.08);
  border-color: rgba(245, 158, 11, 0.5);
}

.cta-button.large {
  padding: 1.25rem 2.5rem;
  font-size: 1.1rem;
}

.arrow-icon {
  width: 20px;
  height: 20px;
  transition: transform 0.3s ease;
}

.cta-button:hover .arrow-icon {
  transform: translateX(5px);
}

.hero-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
  gap: 1.5rem;
  max-width: 800px;
  margin: 0 auto;
}

.stat-item {
  text-align: center;
  padding: 1.5rem 1.25rem;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(245, 158, 11, 0.15);
  border-radius: 16px;
  backdrop-filter: blur(12px);
  transition: all 0.3s ease;
}

.stat-item:hover {
  transform: translateY(-4px);
  border-color: rgba(245, 158, 11, 0.35);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.2);
}

.stat-number {
  font-size: 2.25rem;
  font-weight: 800;
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin-bottom: 0.5rem;
  letter-spacing: -0.02em;
}

.stat-label {
  font-size: 0.875rem;
  color: rgba(248, 250, 252, 0.55);
  font-weight: 500;
}

/* 特性展示区域 */
.features-section {
  position: relative;
  z-index: 1;
  padding: 8rem 2rem;
  background: rgba(12, 14, 20, 0.6);
}

.section-container {
  max-width: 1400px;
  margin: 0 auto;
}

.section-header {
  text-align: center;
  margin-bottom: 4rem;
}

.section-title {
  font-size: clamp(2.5rem, 5vw, 3.75rem);
  font-weight: 800;
  margin-bottom: 1rem;
  letter-spacing: -0.02em;
  background: linear-gradient(135deg, #f8fafc 0%, #fbbf24 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.section-subtitle {
  font-size: 1.15rem;
  color: rgba(248, 250, 252, 0.6);
  font-weight: 500;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.75rem;
}

.feature-card {
  padding: 2rem;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(245, 158, 11, 0.12);
  border-radius: 20px;
  backdrop-filter: blur(16px);
  transition: all 0.35s ease;
  animation: fadeInUp 0.6s ease-out backwards;
}

.feature-card:hover {
  transform: translateY(-8px);
  border-color: rgba(245, 158, 11, 0.3);
  box-shadow: 0 24px 48px rgba(0, 0, 0, 0.25);
  background: rgba(255, 255, 255, 0.05);
}

.feature-icon {
  font-size: 2.75rem;
  margin-bottom: 1.25rem;
}

.feature-title {
  font-size: 1.35rem;
  font-weight: 700;
  margin-bottom: 1rem;
  color: #f8fafc;
  letter-spacing: -0.01em;
}

.feature-description {
  color: rgba(248, 250, 252, 0.6);
  line-height: 1.65;
  margin-bottom: 1.5rem;
  font-size: 0.95rem;
}

.feature-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.feature-tag {
  padding: 0.4rem 0.9rem;
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.2);
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 500;
  color: #fbbf24;
}

/* 架构展示区域 */
.architecture-section {
  position: relative;
  z-index: 1;
  padding: 8rem 2rem;
}

.architecture-visual {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  max-width: 1000px;
  margin: 0 auto;
}

.arch-layer {
  display: flex;
  gap: 2rem;
  padding: 2rem;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(245, 158, 11, 0.15);
  border-radius: 16px;
  backdrop-filter: blur(12px);
  transition: all 0.3s ease;
  opacity: 0;
  transform: translateX(-100%);
}

.arch-layer:nth-child(even) {
  transform: translateX(100%);
}

.arch-layer-visible {
  animation: slideInHorizontal 0.8s ease-out forwards;
}

.arch-layer-visible:nth-child(even) {
  animation: slideInHorizontalRight 0.8s ease-out forwards;
}

.arch-layer:hover {
  transform: translateX(10px);
  border-color: rgba(245, 158, 11, 0.35);
  box-shadow: 0 10px 30px rgba(245, 158, 11, 0.1);
}

.layer-number {
  font-size: 2rem;
  font-weight: 800;
  color: #f59e0b;
  min-width: 60px;
}

.layer-content {
  flex: 1;
}

.layer-title {
  font-size: 1.5rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: white;
}

.layer-description {
  color: rgba(255, 255, 255, 0.7);
  margin-bottom: 1rem;
}

.layer-tech {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.tech-badge {
  padding: 0.4rem 0.8rem;
  background: rgba(245, 158, 11, 0.1);
  border: 1px solid rgba(245, 158, 11, 0.25);
  border-radius: 8px;
  font-size: 0.85rem;
  color: #fbbf24;
}

/* 技术栈展示 */
.tech-stack-section {
  position: relative;
  z-index: 1;
  padding: 8rem 2rem;
  background: rgba(10, 10, 15, 0.5);
}

.tech-categories {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

.tech-category {
  padding: 2rem;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(245, 158, 11, 0.12);
  border-radius: 20px;
  backdrop-filter: blur(12px);
  opacity: 0;
  transform: translateY(-100%);
}

.tech-category:nth-child(even) {
  transform: translateY(100%);
}

.tech-category-visible {
  animation: slideInVertical 0.8s ease-out forwards;
}

.tech-category-visible:nth-child(even) {
  animation: slideInVerticalBottom 0.8s ease-out forwards;
}

.category-title {
  font-size: 1.3rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
  color: white;
  border-bottom: 2px solid rgba(245, 158, 11, 0.25);
  padding-bottom: 0.5rem;
}

.tech-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tech-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: rgba(245, 158, 11, 0.06);
  border-radius: 12px;
  transition: all 0.3s ease;
}

.tech-item:hover {
  background: rgba(245, 158, 11, 0.12);
  transform: translateX(5px);
}

.tech-icon {
  font-size: 2rem;
}

.tech-info {
  flex: 1;
}

.tech-name {
  font-weight: 600;
  color: white;
  margin-bottom: 0.25rem;
}

.tech-version {
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.6);
}

/* CTA区域 */
.cta-section {
  position: relative;
  z-index: 1;
  padding: 8rem 2rem;
}

.cta-container {
  max-width: 800px;
  margin: 0 auto;
  text-align: center;
  padding: 4rem 2rem;
  background: rgba(255, 255, 255, 0.03);
  border: 1px solid rgba(245, 158, 11, 0.2);
  border-radius: 24px;
  backdrop-filter: blur(24px);
}

.cta-title {
  font-size: clamp(2rem, 4vw, 3rem);
  font-weight: 800;
  margin-bottom: 1rem;
  letter-spacing: -0.02em;
  background: linear-gradient(135deg, #f8fafc 0%, #fbbf24 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.cta-subtitle {
  font-size: 1.15rem;
  color: rgba(248, 250, 252, 0.65);
  margin-bottom: 2rem;
}

.cta-actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

/* 页脚 */
.footer {
  position: relative;
  z-index: 1;
  padding: 4rem 2rem 2rem;
  background: rgba(12, 14, 20, 0.9);
  border-top: 1px solid rgba(245, 158, 11, 0.12);
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
  background: linear-gradient(135deg, #fbbf24 0%, #f59e0b 100%);
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
  color: #fbbf24;
}

.footer-bottom {
  text-align: center;
  padding-top: 2rem;
  border-top: 1px solid rgba(245, 158, 11, 0.1);
}

/* 动画 */
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

@keyframes fadeInLeft {
  from {
    opacity: 0;
    transform: translateX(-30px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInHorizontal {
  from {
    opacity: 0;
    transform: translateX(-100%);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInHorizontalRight {
  from {
    opacity: 0;
    transform: translateX(100%);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

@keyframes slideInVertical {
  from {
    opacity: 0;
    transform: translateY(-100%);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes slideInVerticalBottom {
  from {
    opacity: 0;
    transform: translateY(100%);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
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
  background: #f59e0b;
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
    border-left: 1px solid rgba(245, 158, 11, 0.15);
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

  .hero-section {
    padding: 6rem 1rem 3rem;
    min-height: auto;
  }

  .hero-title {
    font-size: 2.5rem;
    margin-bottom: 1rem;
  }

  .hero-subtitle {
    font-size: 1rem;
    line-height: 1.6;
    margin-bottom: 2rem;
  }

  .hero-actions {
    flex-direction: column;
    gap: 1rem;
    margin-bottom: 3rem;
  }

  .cta-button {
    width: 100%;
    justify-content: center;
    padding: 1rem 1.5rem;
    font-size: 0.95rem;
  }

  .hero-stats {
    grid-template-columns: repeat(2, 1fr);
    gap: 1rem;
  }

  .stat-item {
    padding: 1rem;
  }

  .stat-number {
    font-size: 2rem;
  }

  .stat-label {
    font-size: 0.8rem;
  }

  .features-section {
    padding: 4rem 1rem;
  }

  .section-header {
    margin-bottom: 2.5rem;
  }

  .section-title {
    font-size: 2rem;
  }

  .section-subtitle {
    font-size: 1rem;
  }

  .features-grid {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  .feature-card {
    padding: 1.5rem;
  }

  .feature-icon {
    font-size: 2.5rem;
  }

  .feature-title {
    font-size: 1.3rem;
  }

  .architecture-section {
    padding: 4rem 1rem;
  }

  .architecture-visual {
    gap: 1rem;
  }

  .arch-layer {
    flex-direction: column;
    padding: 1.5rem;
    gap: 1rem;
  }

  .layer-number {
    font-size: 1.5rem;
    min-width: auto;
  }

  .layer-title {
    font-size: 1.2rem;
  }

  .tech-stack-section {
    padding: 4rem 1rem;
  }

  .tech-categories {
    grid-template-columns: 1fr;
    gap: 1.5rem;
  }

  .tech-category {
    padding: 1.5rem;
  }

  .category-title {
    font-size: 1.1rem;
  }

  .tech-item {
    padding: 0.75rem;
  }

  .cta-section {
    padding: 4rem 1rem;
  }

  .cta-container {
    padding: 2.5rem 1.5rem;
  }

  .cta-title {
    font-size: 1.8rem;
  }

  .cta-subtitle {
    font-size: 1rem;
  }

  .cta-actions {
    flex-direction: column;
    gap: 1rem;
  }

  .cta-button.large {
    width: 100%;
    padding: 1rem 1.5rem;
    font-size: 1rem;
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
}

@media (max-width: 480px) {
  .hero-title {
    font-size: 2rem;
  }

  .hero-stats {
    grid-template-columns: 1fr;
  }

  .section-title {
    font-size: 1.75rem;
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
