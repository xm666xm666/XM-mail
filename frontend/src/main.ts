import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './modules/App.vue'
import Landing from './modules/Landing.vue'
import Login from './modules/Login.vue'
import Register from './modules/Register.vue'
import Dashboard from './modules/Dashboard.vue'
import Reset from './modules/Reset.vue'
import Mail from './modules/Mail.vue'
import Settings from './modules/Settings.vue'
import Profile from './modules/Profile.vue'
import Changelog from './modules/Changelog.vue'
import { activityTracker } from './utils/activityTracker'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/', component: Landing },
    { path: '/home', component: Landing },
    { path: '/login', component: Login },
    { path: '/register', component: Register },
    { path: '/reset', component: Reset },
    { path: '/changelog', component: Changelog },
    { path: '/dashboard', component: Dashboard, meta: { requiresAdmin: true } },
    { path: '/mail', component: Mail },
    { path: '/settings', component: Settings, meta: { requiresAdmin: true } },
    { path: '/profile', component: Profile }
  ]
})

// 路由守卫 - 检查管理员权限
router.beforeEach((to, from, next) => {
  // 公开页面，不需要认证
  const publicPages = ['/', '/home', '/login', '/register', '/reset', '/changelog']
  if (publicPages.includes(to.path)) {
    // 如果访问公开页面，停止活动追踪
    activityTracker.stop()
    next()
    return
  }
  
  const auth = sessionStorage.getItem('apiAuth')
  if (!auth) {
    // 如果没有认证，停止活动追踪并跳转到登录页
    activityTracker.stop()
    next('/login')
    return
  }
  
  try {
    const credentials = atob(auth).split(':')
    const username = credentials[0]
    
    // 检查是否为管理员
    const isAdmin = username && username.toLowerCase() === 'xm'
    
    // 检查是否需要管理员权限
    if (to.meta.requiresAdmin) {
      if (!isAdmin) {
        // 普通用户重定向到邮件页面
        next('/mail')
        return
      }
    }
    
    // 对于普通用户，限制访问某些页面
    if (!isAdmin && (to.path === '/dashboard' || to.path.startsWith('/admin'))) {
      next('/mail')
      return
    }
    
    // 如果已登录，启动活动追踪（会自动从系统设置中加载会话超时时间）
    activityTracker.start(() => {
      // 超时回调：清除认证信息并跳转到登录页
      console.log('用户无操作超时，自动退出登录')
      sessionStorage.removeItem('apiAuth')
      router.push('/login')
      
      // 显示提示（如果可能的话）
      alert('由于长时间无操作，您已自动退出登录。请重新登录。')
    })
    
  } catch {
    activityTracker.stop()
    next('/login')
    return
  }
  
  next()
})

createApp(App).use(router).mount('#app')


