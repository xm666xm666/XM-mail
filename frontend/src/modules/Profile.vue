<template>
  <Layout>
    <div class="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 py-4 sm:py-8 px-4 sm:px-6 lg:px-8">
      <div class="max-w-3xl mx-auto">
        <!-- 页面标题 -->
        <div class="mb-4 sm:mb-8">
          <h1 class="text-xl sm:text-2xl lg:text-3xl font-bold text-gray-900 mb-1 sm:mb-2">个人资料</h1>
          <p class="text-gray-600 text-xs sm:text-sm">管理您的账户信息和设置</p>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          <div class="flex items-center">
            <svg class="h-5 w-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span class="text-sm text-red-600">{{ error }}</span>
          </div>
        </div>

        <!-- 成功提示 -->
        <div v-if="success" class="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
          <div class="flex items-center">
            <svg class="h-5 w-5 text-green-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span class="text-sm text-green-600">{{ success }}</span>
          </div>
        </div>

        <!-- 个人资料表单 -->
        <div class="bg-white rounded-lg sm:rounded-xl shadow-lg overflow-hidden">
          <div class="p-4 sm:p-6">
            <!-- 头像上传区域 -->
            <div class="mb-6 sm:mb-8">
              <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-3 sm:mb-4">头像</label>
              <div class="flex flex-col sm:flex-row items-start sm:items-center space-y-4 sm:space-y-0 sm:space-x-6">
                <!-- 当前头像预览 -->
                <div class="relative">
                  <div class="h-20 w-20 sm:h-24 sm:w-24 rounded-full overflow-hidden bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center shadow-lg">
                    <img 
                      v-if="avatarPreview" 
                      :src="avatarPreview" 
                      alt="头像" 
                      class="h-full w-full object-cover"
                      @error="handleAvatarError"
                    />
                    <svg v-else class="h-10 w-10 sm:h-12 sm:w-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </div>
                  <div v-if="avatarUploading" class="absolute inset-0 bg-black bg-opacity-50 rounded-full flex items-center justify-center">
                    <svg class="animate-spin h-5 w-5 sm:h-6 sm:w-6 text-white" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </div>

                <!-- 上传按钮 -->
                <div class="flex-1 w-full sm:w-auto">
                  <label class="cursor-pointer">
                    <input
                      type="file"
                      ref="avatarInput"
                      @change="handleAvatarChange"
                      accept="image/jpeg,image/jpg,image/png,image/gif,image/webp"
                      class="hidden"
                    />
                    <div class="inline-flex items-center px-3 sm:px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200 shadow-md hover:shadow-lg text-xs sm:text-sm">
                      <svg class="h-4 w-4 sm:h-5 sm:w-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"></path>
                      </svg>
                      <span>{{ avatarUploading ? '上传中...' : '上传头像' }}</span>
                    </div>
                  </label>
                  <p class="mt-2 text-xs text-gray-500">支持 JPG、PNG、GIF、WebP 格式，建议尺寸 200x200 像素</p>
                  <button
                    v-if="avatarPreview && !avatarUploading"
                    @click="removeAvatar"
                    class="mt-2 text-xs sm:text-sm text-red-600 hover:text-red-700"
                  >
                    移除头像
                  </button>
                </div>
              </div>
            </div>

            <!-- 用户名 -->
            <div class="mb-4 sm:mb-6">
              <label for="username" class="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">
                用户名
              </label>
              <input
                id="username"
                v-model="formData.username"
                type="text"
                class="w-full px-3 sm:px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm sm:text-base"
                placeholder="请输入用户名"
              />
            </div>

            <!-- 邮箱 -->
            <div class="mb-4 sm:mb-6">
              <label for="email" class="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">
                邮箱
              </label>
              <input
                id="email"
                v-model="formData.email"
                type="email"
                class="w-full px-3 sm:px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent text-sm sm:text-base"
                placeholder="请输入邮箱地址"
              />
            </div>

            <!-- 密码 -->
            <div class="mb-6">
              <label for="password" class="block text-sm font-medium text-gray-700 mb-2">
                新密码
              </label>
              <input
                id="password"
                v-model="formData.password"
                type="password"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="留空则不修改密码"
              />
              <p class="mt-1 text-xs text-gray-500">留空则不修改密码</p>
            </div>

            <!-- 确认密码 -->
            <div class="mb-6" v-if="formData.password">
              <label for="confirmPassword" class="block text-sm font-medium text-gray-700 mb-2">
                确认密码
              </label>
              <input
                id="confirmPassword"
                v-model="formData.confirmPassword"
                type="password"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                placeholder="请再次输入密码"
              />
            </div>

            <!-- 操作按钮 -->
            <div class="flex items-center justify-end space-x-4 pt-6 border-t border-gray-200">
              <button
                @click="resetForm"
                type="button"
                class="px-6 py-2 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors duration-200"
              >
                重置
              </button>
              <button
                @click="saveProfile"
                :disabled="saving"
                class="px-6 py-2 bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-lg hover:from-blue-700 hover:to-purple-700 transition-all duration-200 shadow-md hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed flex items-center"
              >
                <svg v-if="saving" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <span>{{ saving ? '保存中...' : '保存更改' }}</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { activityTracker } from '../utils/activityTracker'
import Layout from '../components/Layout.vue'

const router = useRouter()

// 表单数据
const formData = ref({
  username: '',
  email: '',
  password: '',
  confirmPassword: ''
})

// 原始数据（用于重置）
const originalData = ref({
  username: '',
  email: '',
  avatar: ''
})

// 头像相关
const avatarInput = ref<HTMLInputElement | null>(null)
const avatarPreview = ref<string>('')
const avatarFile = ref<File | null>(null)
const avatarUploading = ref(false)

// 状态
const saving = ref(false)
const error = ref<string | null>(null)
const success = ref<string | null>(null)

// 获取当前用户信息
const getCurrentUser = () => {
  const auth = sessionStorage.getItem('apiAuth')
  if (!auth) {
    router.push('/login')
    return null
  }
  
  try {
    const credentials = atob(auth).split(':')
    return credentials[0]
  } catch {
    router.push('/login')
    return null
  }
}

// 加载用户信息
const loadUserProfile = async () => {
  const username = getCurrentUser()
  if (!username) return

  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return

    // 查询用户信息
    const response = await fetch('/api/ops', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        action: 'query-user-profile',
        params: { username }
      })
    })

    if (response.ok) {
      const data = await response.json()
      if (data.success && data.user) {
        formData.value.username = data.user.username || username
        formData.value.email = data.user.email || ''
        originalData.value.username = data.user.username || username
        originalData.value.email = data.user.email || ''
        
        // 加载头像（确保URL正确）
        let avatarValue = data.user.avatar || ''
        // 过滤NULL、空字符串和无效值
        if (avatarValue && typeof avatarValue === 'string') {
          avatarValue = avatarValue.trim()
          // 去除可能的NULL字符串（MySQL可能返回字符串"NULL"）
          if (avatarValue.toUpperCase() === 'NULL' || avatarValue === '' || avatarValue === 'null') {
            avatarValue = ''
          }
        } else {
          avatarValue = ''
        }
        
        if (avatarValue) {
          let avatarUrl = avatarValue
          // 如果头像URL不是完整URL，确保以/开头
          if (!avatarUrl.startsWith('http') && !avatarUrl.startsWith('/')) {
            avatarUrl = '/' + avatarUrl
          }
          // 设置头像预览
          console.log('加载头像URL:', avatarUrl)
          avatarPreview.value = avatarUrl
          originalData.value.avatar = avatarUrl
        } else {
          console.log('用户没有头像')
          avatarPreview.value = ''
          originalData.value.avatar = ''
        }
      }
    } else {
      // 如果API调用失败，至少加载用户名
      const data = await response.json()
      console.error('加载用户信息失败:', data.error || '未知错误')
      formData.value.username = username
      originalData.value.username = username
      // 显示错误提示但不阻止用户继续操作
      error.value = '加载用户信息失败，但可以继续编辑'
      setTimeout(() => {
        error.value = null
      }, 3000)
    }
  } catch (err) {
    console.error('加载用户信息失败:', err)
    // 如果API不存在，使用默认值
    formData.value.username = username
    originalData.value.username = username
    // 显示错误提示但不阻止用户继续操作
    error.value = '加载用户信息失败，但可以继续编辑'
    setTimeout(() => {
      error.value = null
    }, 3000)
  }
}

// 处理头像选择
const handleAvatarChange = (event: Event) => {
  const target = event.target as HTMLInputElement
  const file = target.files?.[0]
  
  if (!file) return

  // 验证文件类型
  const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
  if (!validTypes.includes(file.type)) {
    error.value = '不支持的图片格式，请上传 JPG、PNG、GIF 或 WebP 格式的图片'
    return
  }

  // 验证文件大小（最大5MB）
  if (file.size > 5 * 1024 * 1024) {
    error.value = '图片大小不能超过 5MB'
    return
  }

  // 创建预览
  const reader = new FileReader()
  reader.onload = (e) => {
    avatarPreview.value = e.target?.result as string
  }
  reader.readAsDataURL(file)
  
  avatarFile.value = file
  error.value = null
}

// 移除头像
const removeAvatar = () => {
  avatarPreview.value = ''
  avatarFile.value = null
  if (avatarInput.value) {
    avatarInput.value.value = ''
  }
  // 注意：移除头像只是清除预览，实际删除需要调用API
  // 这里只是清除本地预览，保存时会更新数据库
}

// 处理头像加载错误
const handleAvatarError = (event: Event) => {
  console.warn('头像加载失败，使用默认头像')
  const target = event.target as HTMLImageElement
  if (target) {
    target.style.display = 'none'
  }
  // 不设置avatarPreview为空，保持原始值以便后续重试
}

// 上传头像
const uploadAvatar = async (): Promise<string | null> => {
  if (!avatarFile.value) return null

  const username = getCurrentUser()
  if (!username) return null

  avatarUploading.value = true
  error.value = null

  try {
    // 将文件转换为base64
    const reader = new FileReader()
    const base64Promise = new Promise<string>((resolve, reject) => {
      reader.onload = (e) => {
        resolve(e.target?.result as string)
      }
      reader.onerror = reject
      reader.readAsDataURL(avatarFile.value!)
    })

    const base64Data = await base64Promise

    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return null

    const response = await fetch('/api/upload-avatar', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        avatar: base64Data,
        username: username
      })
    })

    if (response.ok) {
      const data = await response.json()
      if (data.success && data.avatarUrl) {
        // 确保返回的URL格式正确
        let avatarUrl = data.avatarUrl
        if (!avatarUrl.startsWith('http') && !avatarUrl.startsWith('/')) {
          avatarUrl = '/' + avatarUrl
        }
        // 更新预览
        avatarPreview.value = avatarUrl
        return avatarUrl
      } else {
        error.value = data.error || '头像上传失败'
        return null
      }
    } else {
      const data = await response.json()
      error.value = data.error || '头像上传失败'
      return null
    }
  } catch (err) {
    console.error('头像上传失败:', err)
    error.value = '头像上传失败，请稍后重试'
    return null
  } finally {
    avatarUploading.value = false
  }
}

// 保存个人资料
const saveProfile = async () => {
  error.value = null
  success.value = null

  // 验证密码
  if (formData.value.password) {
    // 从系统设置中获取密码要求
    let minPasswordLength = 8 // 默认值
    let requireSpecialChars = false // 默认不要求
    try {
      const auth = sessionStorage.getItem('apiAuth')
      if (auth) {
        const settingsRes = await fetch('/api/system-settings', {
          headers: {
            'Authorization': `Basic ${auth}`
          }
        })
        if (settingsRes.ok) {
          const settingsData = await settingsRes.json()
          if (settingsData.success && settingsData.settings?.security) {
            minPasswordLength = settingsData.settings.security.passwordMinLength || 8
            requireSpecialChars = settingsData.settings.security.requireSpecialChars || false
          }
        }
      }
    } catch (e) {
      console.warn('获取密码要求失败，使用默认值:', e)
    }
    
    // 验证密码长度
    if (formData.value.password.length < minPasswordLength) {
      error.value = `密码长度至少需要${minPasswordLength}个字符`
      return
    }
    
    // 如果要求特殊字符，验证密码复杂度
    if (requireSpecialChars) {
      const hasUpperCase = /[A-Z]/.test(formData.value.password)
      const hasLowerCase = /[a-z]/.test(formData.value.password)
      const hasNumber = /[0-9]/.test(formData.value.password)
      const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(formData.value.password)
      
      if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
        error.value = '密码必须包含大小写字母、数字和特殊字符'
        return
      }
    }
    if (formData.value.password !== formData.value.confirmPassword) {
      error.value = '两次输入的密码不一致'
      return
    }
  }

  // 验证邮箱格式（允许标准邮箱格式或 @localhost）
  // 标准格式：user@domain.com（必须包含点）
  // 特殊格式：user@localhost（允许localhost作为域名）
  if (formData.value.email && !/^[^\s@]+@([^\s@]+\.[^\s@]+|localhost)$/.test(formData.value.email)) {
    error.value = '请输入有效的邮箱地址'
    return
  }

  // 检测密码是否被更改
  const passwordChanged = !!formData.value.password

  saving.value = true

  try {
    const username = getCurrentUser()
    if (!username) return

    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return

    // 先上传头像（如果有新选择的头像文件）
    let avatarUrl = null
    if (avatarFile.value) {
      avatarUrl = await uploadAvatar()
      if (avatarFile.value && !avatarUrl) {
        // 头像上传失败，但不阻止其他信息的保存
        console.warn('头像上传失败，但继续保存其他信息')
      }
    } else if (avatarPreview.value && avatarPreview.value !== originalData.value.avatar) {
      // 如果头像预览已改变但不是新上传的文件（可能是直接修改URL的情况）
      // 这种情况通常不会发生，但为了安全起见保留
      avatarUrl = avatarPreview.value
    }

    // 准备更新数据
    // 确保 original_username 有值，优先使用 originalData，其次使用当前用户名
    const originalUsername = originalData.value.username || username
    if (!originalUsername) {
      error.value = '无法获取用户名，请重新登录'
      saving.value = false
      return
    }
    
    const updateData: any = {
      action: 'app-update',
      params: {
        original_username: originalUsername
      }
    }

    // 如果用户名改变，添加新用户名
    if (formData.value.username && formData.value.username !== originalData.value.username) {
      updateData.params.new_username = formData.value.username
    }

    // 如果邮箱改变，添加新邮箱
    if (formData.value.email && formData.value.email !== originalData.value.email) {
      updateData.params.email = formData.value.email
    }

    // 如果密码改变，添加新密码
    if (formData.value.password) {
      updateData.params.password = formData.value.password
    }

    // 如果有头像URL，添加头像信息
    if (avatarUrl) {
      updateData.params.avatar = avatarUrl
    }

    // 发送更新请求
    const response = await fetch('/api/ops', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify(updateData)
    })

    if (response.ok) {
      const data = await response.json()
      if (data.ok || data.success) {
        // 如果密码被更改，显示特殊提示并退出登录
        if (passwordChanged) {
          success.value = '密码已成功更改，请重新登录'
          
          // 清除密码字段和文件选择
          formData.value.password = ''
          formData.value.confirmPassword = ''
          avatarFile.value = null
          if (avatarInput.value) {
            avatarInput.value.value = ''
          }
          
          // 2秒后清除认证信息并跳转到登录页面
          setTimeout(() => {
            // 停止活动追踪
            activityTracker.stop()
            
            // 清除所有认证信息
            sessionStorage.removeItem('apiAuth')
            // 跳转到登录页面
            router.push('/login')
          }, 2000)
        } else {
          // 密码未更改，正常处理
          success.value = '个人资料已成功更新'
          
          // 更新原始数据
          originalData.value.username = formData.value.username
          originalData.value.email = formData.value.email
          if (avatarUrl) {
            // 确保头像URL格式正确
            let finalAvatarUrl = avatarUrl
            if (!finalAvatarUrl.startsWith('http') && !finalAvatarUrl.startsWith('/')) {
              finalAvatarUrl = '/' + finalAvatarUrl
            }
            originalData.value.avatar = finalAvatarUrl
            avatarPreview.value = finalAvatarUrl
          }
          
          // 如果用户名改变，更新sessionStorage
          if (formData.value.username !== username) {
            const credentials = atob(auth).split(':')
            const newAuth = btoa(`${formData.value.username}:${credentials[1]}`)
            sessionStorage.setItem('apiAuth', newAuth)
          }

          // 清除密码字段和文件选择
          formData.value.password = ''
          formData.value.confirmPassword = ''
          avatarFile.value = null
          if (avatarInput.value) {
            avatarInput.value.value = ''
          }
          
          // 重新加载用户信息以确保数据同步
          setTimeout(() => {
            loadUserProfile()
          }, 500)

          // 刷新Layout中的头像显示
          if ((window as any).refreshUserAvatar) {
            setTimeout(() => {
              (window as any).refreshUserAvatar()
            }, 600)
          }

          // 3秒后清除成功消息
          setTimeout(() => {
            success.value = null
          }, 3000)
        }
      } else {
        error.value = data.error || '更新失败，请稍后重试'
      }
    } else {
      const data = await response.json()
      error.value = data.error || '更新失败，请稍后重试'
    }
  } catch (err) {
    console.error('保存个人资料失败:', err)
    error.value = '保存失败，请稍后重试'
  } finally {
    saving.value = false
  }
}

// 重置表单
const resetForm = () => {
  formData.value.username = originalData.value.username
  formData.value.email = originalData.value.email
  formData.value.password = ''
  formData.value.confirmPassword = ''
  error.value = null
  success.value = null
  
  // 重置头像到原始值
  avatarPreview.value = originalData.value.avatar || ''
  avatarFile.value = null
  if (avatarInput.value) {
    avatarInput.value.value = ''
  }
}

// 组件挂载时加载用户信息
onMounted(() => {
  const username = getCurrentUser()
  if (username) {
    // 先设置默认值，确保即使API失败也能保存
    formData.value.username = username
    originalData.value.username = username
    // 然后加载完整信息
    loadUserProfile()
  } else {
    error.value = '未登录，请先登录'
    setTimeout(() => {
      router.push('/login')
    }, 2000)
  }
})
</script>

<style scoped>
/* 自定义样式 */
</style>

