<template>
  <div class="reset-page">
    <!-- 科幻背景效果 -->
    <div class="sci-fi-background">
      <div class="gradient-orb orb-1"></div>
      <div class="gradient-orb orb-2"></div>
      <div class="gradient-orb orb-3"></div>
      <div class="grid-pattern"></div>
      <div class="particle-container">
        <div v-for="i in 30" :key="i" class="particle" :style="getParticleStyle(i)"></div>
      </div>
    </div>

    <!-- 返回首页按钮 -->
    <div class="back-home">
      <router-link to="/" class="back-button">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        <span>返回首页</span>
      </router-link>
    </div>

    <div class="reset-container">
      <div class="reset-card">
        <div class="card-header">
          <div class="logo-section">
            <img src="/favicon.ico" alt="Logo" class="logo-icon" />
            <div class="logo-text">XM邮件管理系统</div>
          </div>
          <h2 class="card-title">重置密码</h2>
          <p class="card-subtitle">设置新的登录密码</p>
        </div>

        <div v-if="notice" class="notice-container">
          <div v-if="noticeType==='error'" class="notice notice-error">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <span>{{ notice }}</span>
          </div>
          <div v-else-if="noticeType==='success'" class="notice notice-success">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
              <polyline points="22 4 12 14.01 9 11.01"/>
            </svg>
            <span>{{ notice }}</span>
          </div>
          <div v-else class="notice notice-info">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="16" x2="12" y2="12"/>
              <line x1="12" y1="8" x2="12.01" y2="8"/>
            </svg>
            <span>{{ notice }}</span>
          </div>
        </div>

        <form @submit.prevent="reset" class="reset-form">
          <div class="form-group">
            <label class="form-label">用户名</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                <circle cx="12" cy="7" r="4"/>
              </svg>
              <input v-model="username" required 
                     class="form-input" 
                     placeholder="请输入用户名" />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">新密码</label>
            <div class="input-wrapper">
              <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
              </svg>
              <input type="password" v-model="newpass" required 
                     class="form-input" 
                     placeholder="请输入新密码" />
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">验证码</label>
            <div class="captcha-wrapper">
              <div class="input-wrapper flex-1">
                <svg class="input-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0 1 12 2.944a11.955 11.955 0 0 1-8.618 3.04A12.02 12.02 0 0 0 3 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                </svg>
                <input v-model="captchaAnswer" required 
                       type="number"
                       class="form-input" 
                       placeholder="请输入答案" />
              </div>
              <div class="captcha-display">
                {{ captchaQuestion }}
              </div>
              <button type="button" @click="refreshCaptcha" class="refresh-button">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <polyline points="23 4 23 10 17 10"/>
                  <polyline points="1 20 1 14 7 14"/>
                  <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"/>
                </svg>
              </button>
            </div>
          </div>

          <button type="submit" class="submit-button">
            <svg class="button-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 7a2 2 0 0 1 2 2m4 0a6 6 0 0 1-7.743 5.743L11 17H9v2H7v2H4a1 1 0 0 1-1-1v-2.586a1 1 0 0 1 .293-.707l5.964-5.964A6 6 0 1 1 21 9z"/>
            </svg>
            <span>重置密码</span>
          </button>
        </form>

        <div class="form-footer">
          <router-link to="/login" class="footer-link">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4M10 17l5-5-5-5M13.8 12H3"/>
            </svg>
            <span>返回登录</span>
          </router-link>
        </div>
      </div>
    </div>

    <!-- 版权信息 -->
    <footer class="page-footer">
      <div class="footer-content">
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
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { versionManager } from '../utils/versionManager'

const username = ref('')
const newpass = ref('')
const notice = ref('')
const noticeType = ref<'info'|'success'|'error'>('info')
const captchaId = ref('')
const captchaQuestion = ref('')
const captchaAnswer = ref('')

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

// 获取版本信息
const loadVersion = async () => {
  try {
    const version = await versionManager.getVersion()
    currentVersion.value = `V${version}`
  } catch (error) {
    console.warn('获取版本信息失败:', error)
  }
}

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

// 加载验证码
async function loadCaptcha() {
  try {
    const res = await fetch('/api/captcha/generate')
    if (!res.ok) {
      throw new Error('获取验证码失败')
    }
    const data = await res.json()
    if (data.success) {
      captchaId.value = data.captchaId
      captchaQuestion.value = data.question
      captchaAnswer.value = ''
    }
  } catch (e:any) {
    console.error('加载验证码失败:', e)
    noticeType.value = 'error'
    notice.value = `获取验证码失败: ${e?.message || e}`
  }
}

// 刷新验证码
async function refreshCaptcha() {
  await loadCaptcha()
}

async function reset() {
  try {
    // 验证验证码
    if (!captchaId.value || captchaAnswer.value == null || captchaAnswer.value === '') {
      noticeType.value = 'error'
      notice.value = '请完成验证码验证'
      return
    }
    
    // 验证密码（从系统设置中获取）
    try {
      const settingsRes = await fetch('/api/system-settings', {
        headers: {
          // 未登录时 fallback 仅用于拉取重置页所需系统设置；部署后请修改 xm 密码
          'Authorization': `Basic ${sessionStorage.getItem('apiAuth') || btoa('xm:xm666@')}`
        }
      })
      if (settingsRes.ok) {
        const settingsData = await settingsRes.json()
        if (settingsData.success && settingsData.settings?.security) {
          const security = settingsData.settings.security
          const minLength = security.passwordMinLength || 8
          const requireSpecialChars = security.requireSpecialChars || false
          
          // 验证密码长度
          if (newpass.value.length < minLength) {
            noticeType.value = 'error'
            notice.value = `密码长度至少需要${minLength}个字符`
            return
          }
          
          // 如果要求特殊字符，验证密码复杂度
          if (requireSpecialChars) {
            const hasUpperCase = /[A-Z]/.test(newpass.value)
            const hasLowerCase = /[a-z]/.test(newpass.value)
            const hasNumber = /[0-9]/.test(newpass.value)
            const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(newpass.value)
            
            if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
              noticeType.value = 'error'
              const missingParts: string[] = []
              if (!hasUpperCase) missingParts.push('大写字母')
              if (!hasLowerCase) missingParts.push('小写字母')
              if (!hasNumber) missingParts.push('数字')
              if (!hasSpecialChar) missingParts.push('特殊字符')
              notice.value = `密码不符合要求：缺少${missingParts.join('、')}。密码必须包含大小写字母、数字和特殊字符`
              return
            }
          }
        }
      }
    } catch (e) {
      // 如果获取系统设置失败，使用默认值8
      if (newpass.value.length < 8) {
        noticeType.value = 'error'
        notice.value = '密码长度至少需要8个字符'
        return
      }
    }
    
    // 重置密码操作需要认证
    // 安全说明：未登录访问重置页时使用 xm 默认凭证作为 fallback，仅用于调用重置 API。
    // 首次部署后必须在「设置」中修改 xm 密码，并避免将默认凭证暴露给公网。
    let token = sessionStorage.getItem('apiAuth')
    if (!token) {
      token = btoa('xm:xm666@')
    }
    const res = await fetch('/api/ops', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'Authorization': `Basic ${token}` },
      body: JSON.stringify({ 
        action: 'app-reset', 
        params: { 
          username: username.value, 
          newpass: newpass.value,
          captchaId: captchaId.value,
          captchaAnswer: captchaAnswer.value
        } 
      })
    })
    if (!res.ok) {
      let errorMessage = `重置失败 (HTTP ${res.status})`
      try {
        const errorData = await res.json()
        if (errorData.error) {
          errorMessage = errorData.error
        } else if (errorData.message) {
          errorMessage = errorData.message
        } else {
          const txt = await res.text()
          errorMessage = txt || errorMessage
        }
      } catch (e) {
        // 如果JSON解析失败，尝试读取文本
        try {
          const txt = await res.text()
          if (txt) {
            // 尝试解析JSON字符串
            try {
              const parsed = JSON.parse(txt)
              errorMessage = parsed.error || parsed.message || txt
            } catch {
              errorMessage = txt
            }
          }
        } catch (e2) {
          // 忽略错误，使用默认消息
        }
      }
      
      noticeType.value = 'error'
      notice.value = errorMessage
      
      // 如果验证码错误，刷新验证码
      if (res.status === 400 && (errorMessage.includes('验证码') || errorMessage.includes('captcha'))) {
        await refreshCaptcha()
      }
      return
    }
    noticeType.value = 'success'
    notice.value = '密码已重置。若仍无法登录，请确认管理员已完成应用库 schema 初始化（仅首次部署需要）'
    // 清空表单
    username.value = ''
    newpass.value = ''
    captchaAnswer.value = ''
    await refreshCaptcha()
  } catch (e:any) {
    noticeType.value = 'error'
    notice.value = `重置失败: ${e?.message || e}`
  }
}

// 组件挂载时获取版本信息和验证码
onMounted(() => {
  loadVersion()
  loadIcpSettings()
  loadCaptcha()
})
</script>

<style scoped>
.reset-page {
  min-height: 100vh;
  position: relative;
  overflow-x: hidden;
  background: #0a0a0f;
  color: #ffffff;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem 1rem;
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
  width: 500px;
  height: 500px;
  background: linear-gradient(135deg, #fb923c 0%, #ef4444 100%);
  top: -150px;
  right: -150px;
  animation-delay: 0s;
}

.orb-2 {
  width: 400px;
  height: 400px;
  background: linear-gradient(135deg, #fbbf24 0%, #fb923c 100%);
  bottom: -100px;
  left: -100px;
  animation-delay: 5s;
}

.orb-3 {
  width: 300px;
  height: 300px;
  background: linear-gradient(135deg, #f97316 0%, #dc2626 100%);
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
    linear-gradient(rgba(251, 146, 60, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(251, 146, 60, 0.1) 1px, transparent 1px);
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
  background: rgba(251, 146, 60, 0.6);
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

/* 返回首页按钮 */
.back-home {
  position: fixed;
  top: 2rem;
  left: 2rem;
  z-index: 100;
}

.back-button {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(251, 146, 60, 0.3);
  border-radius: 12px;
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.back-button:hover {
  background: rgba(251, 146, 60, 0.2);
  border-color: rgba(251, 146, 60, 0.5);
  color: white;
  transform: translateX(-3px);
}

.back-button svg {
  width: 20px;
  height: 20px;
}

/* 重置容器 */
.reset-container {
  position: relative;
  z-index: 1;
  width: 100%;
  max-width: 480px;
}

.reset-card {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(251, 146, 60, 0.3);
  border-radius: 24px;
  padding: 3rem 2.5rem;
  backdrop-filter: blur(20px);
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: fadeInUp 0.6s ease-out;
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

.card-header {
  text-align: center;
  margin-bottom: 2rem;
}

.logo-section {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.logo-icon {
  width: 3rem;
  height: 3rem;
  object-fit: contain;
}

.logo-text {
  font-size: 1.75rem;
  font-weight: 700;
  background: linear-gradient(135deg, #fb923c 0%, #ef4444 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.card-title {
  font-size: 2rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
  background: linear-gradient(135deg, #ffffff 0%, #fb923c 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.card-subtitle {
  color: rgba(255, 255, 255, 0.6);
  font-size: 0.95rem;
}

/* 通知 */
.notice-container {
  margin-bottom: 1.5rem;
}

.notice {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem 1.25rem;
  border-radius: 12px;
  font-size: 0.9rem;
  backdrop-filter: blur(10px);
}

.notice svg {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.notice-error {
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  color: #fca5a5;
}

.notice-success {
  background: rgba(34, 197, 94, 0.1);
  border: 1px solid rgba(34, 197, 94, 0.3);
  color: #86efac;
}

.notice-info {
  background: rgba(59, 130, 246, 0.1);
  border: 1px solid rgba(59, 130, 246, 0.3);
  color: #93c5fd;
}

/* 表单 */
.reset-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-label {
  font-size: 0.9rem;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.9);
}

.input-wrapper {
  position: relative;
  display: flex;
  align-items: center;
}

.input-icon {
  position: absolute;
  left: 1rem;
  width: 20px;
  height: 20px;
  color: rgba(255, 255, 255, 0.5);
  pointer-events: none;
  z-index: 1;
}

.form-input {
  width: 100%;
  padding: 1rem 1rem 1rem 3rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(251, 146, 60, 0.3);
  border-radius: 12px;
  color: white;
  font-size: 1rem;
  transition: all 0.3s ease;
  backdrop-filter: blur(10px);
}

.form-input::placeholder {
  color: rgba(255, 255, 255, 0.4);
}

.form-input:focus {
  outline: none;
  border-color: rgba(251, 146, 60, 0.6);
  background: rgba(255, 255, 255, 0.08);
  box-shadow: 0 0 0 3px rgba(251, 146, 60, 0.1);
}

.captcha-wrapper {
  display: flex;
  gap: 0.75rem;
  align-items: center;
}

.captcha-display {
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #fb923c 0%, #ef4444 100%);
  color: white;
  font-weight: 700;
  font-size: 1.1rem;
  border-radius: 12px;
  min-width: 100px;
  text-align: center;
  box-shadow: 0 4px 15px rgba(251, 146, 60, 0.3);
}

.refresh-button {
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(251, 146, 60, 0.3);
  border-radius: 12px;
  color: rgba(255, 255, 255, 0.8);
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.refresh-button:hover {
  background: rgba(251, 146, 60, 0.2);
  border-color: rgba(251, 146, 60, 0.5);
  color: white;
}

.refresh-button svg {
  width: 20px;
  height: 20px;
}

.submit-button {
  width: 100%;
  padding: 1rem 2rem;
  background: linear-gradient(135deg, #fb923c 0%, #ef4444 100%);
  border: none;
  border-radius: 12px;
  color: white;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  margin-top: 0.5rem;
  box-shadow: 0 10px 30px rgba(251, 146, 60, 0.3);
}

.submit-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 15px 40px rgba(251, 146, 60, 0.4);
}

.button-icon {
  width: 20px;
  height: 20px;
}

.form-footer {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid rgba(251, 146, 60, 0.2);
}

.footer-link {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  font-size: 0.9rem;
  transition: color 0.3s ease;
}

.footer-link:hover {
  color: #fb923c;
}

.footer-link svg {
  width: 18px;
  height: 18px;
}

/* 页脚 */
.page-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  padding: 1.5rem 2rem;
  background: rgba(10, 10, 15, 0.8);
  backdrop-filter: blur(20px);
  border-top: 1px solid rgba(251, 146, 60, 0.2);
}

.footer-content {
  max-width: 1400px;
  margin: 0 auto;
  text-align: center;
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
  color: rgba(255, 255, 255, 0.5);
  text-decoration: none;
  transition: color 0.3s ease;
}

.icp-inline a:hover {
  color: rgba(255, 255, 255, 0.7);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .reset-page {
    padding: 1rem;
    padding-bottom: 6rem;
  }

  .reset-card {
    padding: 2rem 1.5rem;
  }

  .back-home {
    top: 1rem;
    left: 1rem;
  }

  .back-button {
    padding: 0.6rem 1rem;
  }

  .back-button span {
    display: none;
  }

  .logo-icon {
    width: 2.5rem;
    height: 2.5rem;
  }

  .logo-text {
    font-size: 1.5rem;
  }

  .card-title {
    font-size: 1.75rem;
  }

  .card-subtitle {
    font-size: 0.9rem;
  }

  .form-input {
    padding: 0.875rem 0.875rem 0.875rem 2.75rem;
    font-size: 0.95rem;
  }

  .input-icon {
    width: 18px;
    height: 18px;
    left: 0.875rem;
  }

  .captcha-wrapper {
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .captcha-display {
    padding: 0.875rem 1.25rem;
    font-size: 1rem;
    min-width: 80px;
    flex: 1;
    min-width: 0;
  }

  .refresh-button {
    padding: 0.875rem;
    min-width: 44px;
    min-height: 44px;
  }

  .submit-button {
    padding: 1rem 1.5rem;
    font-size: 0.95rem;
    min-height: 48px;
  }

  .form-footer {
    flex-direction: column;
    align-items: stretch;
    gap: 0.75rem;
  }

  .footer-link {
    justify-content: center;
    padding: 0.75rem;
    font-size: 0.85rem;
    min-height: 44px;
  }

  .page-footer {
    padding: 1rem;
  }

  .copyright,
  .footer-text,
  .version-text {
    font-size: 0.75rem;
  }
}

@media (max-width: 480px) {
  .reset-page {
    padding: 0.75rem;
    padding-bottom: 5.5rem;
  }

  .reset-card {
    padding: 1.5rem 1.25rem;
  }

  .back-home {
    top: 0.75rem;
    left: 0.75rem;
  }

  .back-button {
    padding: 0.5rem 0.75rem;
  }

  .logo-icon {
    width: 2rem;
    height: 2rem;
  }

  .logo-text {
    font-size: 1.3rem;
  }

  .card-title {
    font-size: 1.5rem;
  }

  .card-subtitle {
    font-size: 0.85rem;
  }

  .form-input {
    padding: 0.75rem 0.75rem 0.75rem 2.5rem;
    font-size: 0.9rem;
  }

  .input-icon {
    width: 16px;
    height: 16px;
    left: 0.75rem;
  }

  .captcha-display {
    padding: 0.75rem 1rem;
    font-size: 0.95rem;
  }

  .submit-button {
    padding: 0.875rem 1.25rem;
    font-size: 0.9rem;
  }

  .page-footer {
    padding: 0.75rem;
  }

  .copyright,
  .footer-text,
  .version-text {
    font-size: 0.7rem;
  }
}
</style>