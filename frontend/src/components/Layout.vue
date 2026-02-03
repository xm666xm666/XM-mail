<template>
  <div class="min-h-screen bg-gray-50">
    <!-- 左侧导航栏 - 仅管理员可见 -->
    <div v-if="isAdmin" class="fixed inset-y-0 left-0 z-50 w-full sm:w-64 bg-white shadow-lg transform transition-all duration-300 ease-in-out hover:shadow-xl" :class="{ '-translate-x-full': !sidebarOpen, 'translate-x-0': sidebarOpen }" :style="{ opacity: isInitialized ? 1 : 0 }">
      <!-- 导航栏头部 -->
      <div class="flex items-center justify-between h-14 sm:h-16 px-4 sm:px-6 border-b border-gray-200">
        <div class="flex items-center">
          <div class="h-7 w-7 sm:h-8 sm:w-8 rounded-lg flex items-center justify-center">
            <img src="/favicon.ico" alt="XM邮件系统" class="h-7 w-7 sm:h-8 sm:w-8 rounded-lg" />
          </div>
          <span class="ml-2 sm:ml-3 text-base sm:text-lg font-bold text-gray-900">XM邮件系统</span>
        </div>
        <button @click="toggleSidebar" class="p-2 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100">
          <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>


      <!-- 导航菜单 -->
      <nav class="mt-6 px-3 overflow-y-auto scrollbar-thin scrollbar-thumb-gray-300 scrollbar-track-gray-100">
        <div class="space-y-1">
          <!-- 仪表板 -->
          <router-link 
            to="/dashboard" 
            @click="() => { userLogger.logButtonClick('仪表板', '左侧导航'); toggleSidebar() }"
            class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-all duration-300 transform hover:scale-105 hover:shadow-md"
            :class="$route.path === '/dashboard' ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-700 shadow-sm' : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'"
          >
            <svg class="mr-3 h-5 w-5 transition-all duration-300 group-hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2H5a2 2 0 00-2-2z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 5a2 2 0 012-2h4a2 2 0 012 2v6H8V5z"></path>
            </svg>
            <span class="transition-all duration-300 group-hover:font-semibold">仪表板</span>
            <div v-if="$route.path === '/dashboard'" class="ml-auto w-2 h-2 bg-blue-500 rounded-full animate-pulse"></div>
          </router-link>

          <!-- 邮件管理 -->
          <router-link 
            to="/mail" 
            @click="() => { userLogger.logButtonClick('邮件管理', '左侧导航'); toggleSidebar() }"
            class="group flex items-center px-3 py-2 text-sm font-medium rounded-md transition-all duration-300 transform hover:scale-105 hover:shadow-md"
            :class="$route.path === '/mail' ? 'bg-blue-50 text-blue-700 border-r-2 border-blue-700 shadow-sm' : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900'"
          >
            <svg class="mr-3 h-5 w-5 transition-all duration-300 group-hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
            </svg>
            <span class="transition-all duration-300 group-hover:font-semibold">邮件管理</span>
            <div v-if="$route.path === '/mail'" class="ml-auto w-2 h-2 bg-blue-500 rounded-full animate-pulse"></div>
          </router-link>

          <!-- 系统监控 -->
          <div class="pt-4">
            <div class="px-3 mb-2">
              <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider">系统管理</h3>
            </div>
            
            <button 
              @click="() => { userLogger.logButtonClick('系统状态', '左侧导航'); showSystemStatus(); toggleSidebar() }"
              class="group flex items-center w-full px-3 py-2 text-sm font-medium rounded-md text-gray-700 hover:bg-gradient-to-r hover:from-blue-500 hover:to-cyan-500 hover:text-white transition-all duration-300 transform hover:scale-105 hover:shadow-md relative overflow-hidden"
            >
              <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-cyan-500 opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
              <svg class="mr-3 h-5 w-5 transition-all duration-300 group-hover:rotate-12 group-hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
              </svg>
              <span class="relative z-10 transition-all duration-300 group-hover:font-semibold">系统状态</span>
              <div class="absolute inset-0 bg-gradient-to-r from-blue-500 to-cyan-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"></div>
            </button>

            <button 
              @click="() => { userLogger.logButtonClick('日志查看', '左侧导航'); showLogViewer(); toggleSidebar() }"
              class="group flex items-center w-full px-3 py-2 text-sm font-medium rounded-md text-gray-700 hover:bg-gradient-to-r hover:from-green-500 hover:to-emerald-500 hover:text-white transition-all duration-300 transform hover:scale-105 hover:shadow-md relative overflow-hidden"
            >
              <div class="absolute inset-0 bg-gradient-to-r from-green-500 to-emerald-500 opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
              <svg class="mr-3 h-5 w-5 transition-all duration-300 group-hover:rotate-12 group-hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <span class="relative z-10 transition-all duration-300 group-hover:font-semibold">日志查看</span>
              <div class="absolute inset-0 bg-gradient-to-r from-green-500 to-emerald-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"></div>
            </button>

            <button 
              @click="() => { userLogger.logButtonClick('命令终端', '左侧导航'); showCommandTerminal(); toggleSidebar() }"
              class="group flex items-center w-full px-3 py-2 text-sm font-medium rounded-md text-gray-700 hover:bg-gradient-to-r hover:from-orange-500 hover:to-red-500 hover:text-white transition-all duration-300 transform hover:scale-105 hover:shadow-md relative overflow-hidden"
              title="命令终端（用户 euser）"
            >
              <div class="absolute inset-0 bg-gradient-to-r from-orange-500 to-red-500 opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
              <svg class="mr-3 h-5 w-5 transition-all duration-300 group-hover:rotate-12 group-hover:text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
              </svg>
              <span class="relative z-10 transition-all duration-300 group-hover:font-semibold">命令终端</span>
              <span class="relative z-10 ml-1 text-xs text-gray-500 group-hover:text-orange-100">(euser)</span>
              <div class="absolute inset-0 bg-gradient-to-r from-orange-500 to-red-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"></div>
            </button>

          </div>

          <!-- 设置 -->
          <div class="pt-4">
            <div class="px-3 mb-2">
              <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider">设置</h3>
            </div>
            
            <router-link 
              to="/settings" 
              @click="() => { userLogger.logButtonClick('系统设置', '左侧导航'); toggleSidebar() }"
              class="group flex items-center w-full px-3 py-2 text-sm font-medium rounded-md transition-all duration-300 relative overflow-hidden transform hover:scale-105 hover:shadow-lg"
              :class="$route.path === '/settings' ? 'bg-gradient-to-r from-purple-500 to-pink-500 text-white shadow-sm' : 'text-gray-700 hover:bg-gradient-to-r hover:from-purple-500 hover:to-pink-500 hover:text-white'"
            >
              <div class="absolute inset-0 bg-gradient-to-r from-purple-500 to-pink-500 opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
              <svg class="mr-3 h-5 w-5 transition-all duration-300 group-hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
              <span class="relative z-10 group-hover:font-semibold transition-all duration-300">系统设置</span>
              <div v-if="$route.path === '/settings'" class="ml-auto w-2 h-2 bg-white rounded-full animate-pulse"></div>
              <div class="absolute inset-0 bg-gradient-to-r from-purple-500 to-pink-500 transform scale-x-0 group-hover:scale-x-100 transition-transform duration-300 origin-left"></div>
              <div class="absolute right-2 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-all duration-300">
                <svg class="h-4 w-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
                </svg>
              </div>
            </router-link>
          </div>
        </div>
      </nav>

      <!-- 底部用户信息 -->
      <div class="absolute bottom-0 left-0 right-0 p-3 sm:p-4 border-t border-gray-200 bg-gradient-to-r from-blue-50 to-purple-50">
        <div class="flex items-center">
          <div class="h-9 w-9 sm:h-10 sm:w-10 rounded-full overflow-hidden bg-gradient-to-r from-green-500 to-blue-500 flex items-center justify-center shadow-lg">
            <img 
              v-if="userAvatar" 
              :src="userAvatar" 
              alt="用户头像" 
              class="h-full w-full object-cover"
              @error="handleAvatarError"
            />
            <svg v-else class="h-4 w-4 sm:h-5 sm:w-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
            </svg>
          </div>
          <div class="ml-2 sm:ml-3 flex-1 min-w-0">
            <p class="text-xs sm:text-sm font-semibold text-gray-900 truncate">{{ currentUser || '未知用户' }}</p>
            <p class="text-xs text-green-600 font-medium flex items-center truncate">
              <svg class="h-3 w-3 mr-1 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <span class="truncate">{{ adminEmailDisplay }}</span>
            </p>
          </div>
          <div class="text-right flex-shrink-0 ml-2">
            <div class="text-xs text-gray-500">在线</div>
            <div class="w-2 h-2 bg-green-400 rounded-full animate-pulse mx-auto mt-0.5"></div>
          </div>
        </div>
        
        <!-- 邮件统计信息 -->
        <div class="mt-2 sm:mt-3 pt-2 sm:pt-3 border-t border-gray-200">
          <div class="flex items-center justify-between text-xs">
            <div class="flex items-center text-gray-600">
              <svg class="h-3 w-3 sm:h-4 sm:w-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
              </svg>
              <span>未读邮件</span>
            </div>
            <span class="bg-red-500 text-white px-1.5 sm:px-2 py-0.5 rounded-full font-medium text-xs">{{ unreadEmailCount }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- 主内容区域 -->
    <div class="flex-1 flex flex-col transition-all duration-300 ease-in-out" :class="{ 'sm:ml-64': sidebarOpen && isAdmin, 'ml-0': !sidebarOpen || !isAdmin }">
      <!-- 顶部导航栏 -->
      <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="flex items-center justify-between h-14 sm:h-16 px-3 sm:px-4 lg:px-6 xl:px-8">
          <div class="flex items-center min-w-0 flex-1">
            <button v-if="isAdmin" @click="toggleSidebar" class="p-2 rounded-md text-gray-400 hover:text-gray-600 hover:bg-gray-100 flex-shrink-0">
              <svg class="h-5 w-5 sm:h-6 sm:w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16"></path>
              </svg>
            </button>
            <h1 class="ml-2 sm:ml-4 text-base sm:text-lg lg:text-xl font-semibold text-gray-900 truncate">{{ pageTitle }}</h1>
          </div>
          <div class="flex items-center space-x-4">
            <!-- 用户信息 -->
            <div class="flex items-center space-x-2">
              <div class="h-8 w-8 rounded-full overflow-hidden bg-gradient-to-r from-blue-500 to-purple-500 flex items-center justify-center flex-shrink-0">
                <img 
                  v-if="userAvatar" 
                  :src="userAvatar" 
                  alt="用户头像" 
                  class="h-full w-full object-cover"
                  @error="handleAvatarError"
                />
                <svg v-else class="h-4 w-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                </svg>
              </div>
              <div class="text-sm">
                <span class="font-medium text-gray-900">{{ currentUser || '未知用户' }}</span>
                <span :class="['ml-2 text-xs', isAdmin ? 'text-green-600' : 'text-gray-500']">
                  {{ isAdmin ? '管理员' : '普通用户' }}
                </span>
              </div>
            </div>
            <!-- 个人资料按钮 -->
            <router-link
              to="/profile"
              @click="() => { userLogger.logButtonClick('个人资料', '顶部导航') }"
              class="flex items-center px-3 py-2 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors duration-200"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
              </svg>
              个人资料
            </router-link>
            <button 
              @click="() => { userLogger.logButtonClick('退出登录', '顶部导航'); logout() }" 
              class="flex items-center px-3 py-2 text-sm font-medium text-gray-700 hover:text-gray-900 hover:bg-gray-50 rounded-md transition-colors duration-200"
            >
              <svg class="mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"></path>
              </svg>
              退出登录
            </button>
          </div>
        </div>
      </header>

      <!-- 页面内容 -->
      <main class="flex-1 overflow-auto">
        <slot></slot>
      </main>
    </div>

    <!-- 版权信息 -->
    <footer class="bg-gray-50 border-t border-gray-200 py-4 px-6">
      <div class="max-w-7xl mx-auto">
        <div class="text-center text-sm text-gray-600">
          <div class="flex items-center justify-center space-x-2 mb-2">
            <svg class="w-4 h-4 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
              <path d="M10 2C5.58 2 2 5.58 2 10s3.58 8 8 8 8-3.58 8-8-3.58-8-8-8zm0 14c-3.31 0-6-2.69-6-6s2.69-6 6-6 6 2.69 6 6-2.69 6-6 6z"/>
              <text x="10" y="14" text-anchor="middle" font-family="Arial, sans-serif" font-size="10" font-weight="bold">C</text>
            </svg>
            <span class="font-medium">2024-2026 XM.</span>
            <!-- 备案号显示 -->
            <span v-if="icpSettings.enabled && icpSettings.number" class="text-gray-500 text-xs ml-2">
              <a :href="icpSettings.url" target="_blank" rel="noopener noreferrer" class="hover:text-gray-700 transition-colors duration-200">
                {{ icpSettings.number }}
              </a>
            </span>
          </div>
          <div class="text-gray-500 mb-1">XM邮件管理平台 | 欢迎使用</div>
          <div class="text-gray-400 text-xs">Powered by XM <span class="version-text">{{ currentVersion }}</span></div>
        </div>
      </div>
    </footer>

    <!-- 移动端遮罩 -->
    <div 
      v-if="sidebarOpen" 
      @click="toggleSidebar"
      class="fixed inset-0 z-40 bg-black bg-opacity-50 lg:hidden"
    ></div>

    <!-- 系统状态对话框 -->
    <div v-if="showSystemStatusDialog" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showSystemStatusDialog = false"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-blue-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full">
                <div class="flex items-center justify-between mb-4">
                  <h3 class="text-lg leading-6 font-medium text-gray-900">系统状态监控</h3>
                  <div class="flex items-center space-x-2">
                    <div v-if="systemStatus.loading" class="flex items-center space-x-2">
                      <svg class="animate-spin h-4 w-4 text-blue-600" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      <span class="text-sm text-gray-500">更新中...</span>
                    </div>
                    <div v-if="systemStatus.lastUpdate" class="text-xs text-gray-500">
                      最后更新: {{ new Date(systemStatus.lastUpdate).toLocaleTimeString('zh-CN') }}
                    </div>
                  </div>
                </div>
                
                <!-- 错误提示 -->
                <div v-if="systemStatus.error" class="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                  <div class="flex items-center">
                    <svg class="h-5 w-5 text-red-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    <span class="text-sm text-red-600">{{ systemStatus.error }}</span>
                  </div>
                </div>
                
                <div class="mt-4">
                  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <!-- 服务状态 -->
                    <div class="bg-white p-4 rounded-lg border">
                      <div class="flex items-center justify-between mb-3">
                        <h4 class="text-sm font-medium text-gray-900">服务状态</h4>
                        <div class="flex items-center space-x-2 text-xs">
                          <div class="flex items-center space-x-1">
                            <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                            <span class="text-gray-600">运行中: {{ getServiceCount('running') }}</span>
                          </div>
                          <div class="flex items-center space-x-1">
                            <div class="w-2 h-2 bg-red-500 rounded-full"></div>
                            <span class="text-gray-600">已关闭: {{ getServiceCount('stopped') }}</span>
                          </div>
                          <div class="flex items-center space-x-1">
                            <div class="w-2 h-2 bg-orange-500 rounded-full animate-pulse"></div>
                            <span class="text-gray-600">错误: {{ getServiceCount('error') }}</span>
                          </div>
                        </div>
                      </div>
                      
                      <!-- 紧凑的服务状态网格 -->
                      <div class="grid grid-cols-2 gap-2">
                        <div v-for="(service, name) in systemStatus.services" :key="name" 
                             class="flex items-center space-x-2 p-2 rounded-lg transition-all duration-300 hover:bg-gray-50 cursor-pointer" 
                             @click="debugServiceStatus(name, service)">
                          <div class="relative">
                            <div :class="['w-2 h-2 rounded-full', getServiceStatusDotColor(service.status)]"></div>
                            <div v-if="service.status === 'running'" class="absolute inset-0 w-2 h-2 rounded-full bg-green-400 animate-ping opacity-75"></div>
                            <div v-if="service.status === 'error'" class="absolute inset-0 w-2 h-2 rounded-full bg-orange-400 animate-ping opacity-75"></div>
                          </div>
                          <div class="flex-1 min-w-0">
                            <div class="text-xs font-medium text-gray-700 truncate">{{ getServiceDisplayName(name) }}</div>
                            <div class="text-xs text-gray-500">{{ getServiceStatusText(service.status) }}</div>
                          </div>
                        </div>
                      </div>
                    </div>
            
            <!-- DNS状态 -->
            <div class="bg-white p-4 rounded-lg border">
              <h4 class="text-sm font-medium text-gray-900 mb-3">DNS解析状态</h4>
              <div v-if="systemStatus.dns" class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">配置域名</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.dns.configuredDomain || '未配置' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">配置主机名</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.dns.configuredHostname || '未配置' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">DNS健康度</span>
                  <span :class="['text-sm font-medium', getDnsHealthColor(systemStatus.dns.healthScore)]">
                    {{ systemStatus.dns.healthScore || 0 }}%
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">整体状态</span>
                  <span :class="['text-sm font-medium', getDnsStatusColor(systemStatus.dns.overallStatus)]">
                    {{ getDnsStatusText(systemStatus.dns.overallStatus) }}
                  </span>
                </div>
                
                <!-- DNS记录详情 -->
                <div v-if="systemStatus.dns.configuredDomain" class="mt-3 pt-2 border-t border-gray-200">
                  <div class="text-xs font-medium text-gray-500 mb-2">DNS记录详情</div>
                  <div class="space-y-1 text-xs">
                    <div class="flex justify-between">
                      <span class="text-gray-500">MX记录</span>
                      <span :class="['font-medium', getDnsRecordColor(systemStatus.dns.mxStatus)]">
                        {{ getDnsRecordText(systemStatus.dns.mxStatus) }}
                      </span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-gray-500">A记录</span>
                      <span :class="['font-medium', getDnsRecordColor(systemStatus.dns.aStatus)]">
                        {{ getDnsRecordText(systemStatus.dns.aStatus) }}
                      </span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-gray-500">PTR记录</span>
                      <span :class="['font-medium', getDnsRecordColor(systemStatus.dns.ptrStatus)]">
                        {{ getDnsRecordText(systemStatus.dns.ptrStatus) }}
                      </span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-gray-500">SPF记录</span>
                      <span :class="['font-medium', getDnsRecordColor(systemStatus.dns.spfStatus)]">
                        {{ getDnsRecordText(systemStatus.dns.spfStatus) }}
                      </span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-gray-500">DKIM记录</span>
                      <span :class="['font-medium', getDnsRecordColor(systemStatus.dns.dkimStatus)]">
                        {{ getDnsRecordText(systemStatus.dns.dkimStatus) }}
                      </span>
                    </div>
                    <div class="flex justify-between">
                      <span class="text-gray-500">DMARC记录</span>
                      <span :class="['font-medium', getDnsRecordColor(systemStatus.dns.dmarcStatus)]">
                        {{ getDnsRecordText(systemStatus.dns.dmarcStatus) }}
                      </span>
                    </div>
                  </div>
                  
                  <!-- DNS统计信息 -->
                  <div v-if="systemStatus.dns.summary" class="mt-2 pt-2 border-t border-gray-200">
                    <div class="text-xs text-gray-500 mb-1">记录统计</div>
                    <div class="grid grid-cols-2 gap-1 text-xs">
                      <div class="flex justify-between">
                        <span class="text-gray-500">总计</span>
                        <span class="font-medium">{{ systemStatus.dns.summary.total }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">已配置</span>
                        <span class="font-medium text-green-600">{{ systemStatus.dns.summary.configured }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">缺失</span>
                        <span class="font-medium text-yellow-600">{{ systemStatus.dns.summary.missing }}</span>
                      </div>
                      <div class="flex justify-between">
                        <span class="text-gray-500">错误</span>
                        <span class="font-medium text-red-600">{{ systemStatus.dns.summary.errors }}</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- 错误信息 -->
                <div v-if="systemStatus.dns.error" class="mt-2 p-2 bg-red-50 rounded text-xs text-red-600">
                  {{ systemStatus.dns.error }}
                </div>
              </div>
              <div v-else class="text-sm text-gray-500">
                DNS状态信息不可用
              </div>
            </div>
            
            <!-- 系统信息 -->
            <div class="bg-white p-4 rounded-lg border">
              <h4 class="text-sm font-medium text-gray-900 mb-3">系统信息</h4>
              <div class="space-y-2">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">主机名</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.hostname || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">操作系统</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.osVersion || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">内核版本</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.kernelVersion || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">架构</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.architecture || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">时区</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.timezone || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">启动时间</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.bootTime || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">运行时间</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ formatUptime(systemStatus.systemInfo.uptime || 0) }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">当前用户</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.currentUser || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Node版本</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.nodeVersion || 'Unknown' }}
                  </span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">系统负载</span>
                  <span class="text-sm font-medium text-blue-600">
                    {{ systemStatus.systemInfo.loadAverage || 'Unknown' }}
                  </span>
                </div>
              </div>
            </div>
            
            <!-- 系统资源 -->
            <div class="bg-white p-4 rounded-lg border">
              <h4 class="text-sm font-medium text-gray-900 mb-3">系统资源</h4>
                             <div class="space-y-2">
                               <div class="flex justify-between">
                                 <span class="text-sm text-gray-600">CPU使用率</span>
                                 <span :class="['text-sm font-medium', getResourceColor(systemStatus.resources.cpu)]">
                                   {{ systemStatus.resources.cpu?.toFixed(1) || 0 }}%
                                 </span>
                               </div>
                               <div class="flex justify-between">
                                 <span class="text-sm text-gray-600">内存使用率</span>
                                 <span :class="['text-sm font-medium', getResourceColor(systemStatus.resources.memory)]">
                                   {{ systemStatus.resources.memory?.toFixed(1) || 0 }}%
                                 </span>
                               </div>
                               <div class="flex justify-between">
                                 <span class="text-sm text-gray-600">磁盘使用率</span>
                                 <span :class="['text-sm font-medium', getResourceColor(systemStatus.resources.disk)]">
                                   {{ systemStatus.resources.disk?.toFixed(1) || 0 }}%
                                 </span>
                               </div>
                               <div class="flex justify-between">
                                 <span class="text-sm text-gray-600">负载平均值</span>
                                 <span :class="['text-sm font-medium', getResourceColor(systemStatus.resources.loadAverage * 100)]">
                                   {{ systemStatus.resources.loadAverage?.toFixed(2) || 0 }}
                                 </span>
                               </div>
                               
                               <!-- 内存详细信息 -->
                               <div v-if="systemStatus.resources.memoryDetails" class="mt-3 pt-2 border-t border-gray-200">
                                 <div class="text-xs font-medium text-gray-500 mb-2">内存详情</div>
                                 <div class="grid grid-cols-2 gap-2 text-xs">
                                   <div class="flex justify-between">
                                     <span class="text-gray-500">总计</span>
                                     <span class="font-medium">{{ systemStatus.resources.memoryDetails.total }}</span>
                                   </div>
                                   <div class="flex justify-between">
                                     <span class="text-gray-500">已用</span>
                                     <span class="font-medium text-red-600">{{ systemStatus.resources.memoryDetails.used }}</span>
                                   </div>
                                   <div class="flex justify-between">
                                     <span class="text-gray-500">空闲</span>
                                     <span class="font-medium text-green-600">{{ systemStatus.resources.memoryDetails.free }}</span>
                                   </div>
                                   <div class="flex justify-between">
                                     <span class="text-gray-500">可用</span>
                                     <span class="font-medium text-blue-600">{{ systemStatus.resources.memoryDetails.available }}</span>
                                   </div>
                                 </div>
                               </div>
                               
                               <!-- 网络连接和进程信息 -->
                               <div class="mt-3 pt-2 border-t border-gray-200">
                                 <div class="flex justify-between">
                                   <span class="text-sm text-gray-600">网络连接</span>
                                   <span class="text-sm font-medium text-blue-600">
                                     {{ systemStatus.network.connections || 0 }}
                                   </span>
                                 </div>
                                 <div class="flex justify-between">
                                   <span class="text-sm text-gray-600">进程数</span>
                                   <span class="text-sm font-medium text-blue-600">
                                     {{ systemStatus.processes.count || 0 }}
                                   </span>
                                 </div>
                               </div>
                               
                               <!-- 详细信息展开按钮 -->
                               <div class="mt-3">
                                 <button 
                                   @click="toggleResourceDetails" 
                                   class="text-xs text-blue-600 hover:text-blue-800 underline"
                                 >
                                   {{ showResourceDetails ? '隐藏详细信息' : '显示详细信息' }}
                                 </button>
                               </div>
                               
                               <!-- 详细信息面板 -->
                               <div v-if="showResourceDetails" class="mt-3 p-3 bg-gray-50 rounded-lg text-xs">
                                 <div v-if="systemStatus.resources.cpuDetails" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">CPU信息</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.cpuDetails }}</pre>
                                 </div>
                                 
                                 <div v-if="systemStatus.resources.diskDetails" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">磁盘使用</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.diskDetails }}</pre>
                                 </div>
                                 
                                 <div v-if="systemStatus.resources.networkInterfaces" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">网络接口</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.networkInterfaces }}</pre>
                                 </div>
                                 
                                 <div v-if="systemStatus.resources.temperature" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">系统温度</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.temperature }}</pre>
                                 </div>
                                 
                                 <div v-if="systemStatus.resources.topProcesses" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">CPU占用最高的进程</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.topProcesses }}</pre>
                                 </div>
                                 
                                 <div v-if="systemStatus.resources.swapInfo" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">交换空间</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.swapInfo }}</pre>
                                 </div>
                                 
                                 <div v-if="systemStatus.resources.mountInfo" class="mb-3">
                                   <div class="font-medium text-gray-700 mb-1">文件系统</div>
                                   <pre class="text-gray-600 whitespace-pre-wrap">{{ systemStatus.resources.mountInfo }}</pre>
                                 </div>
                               </div>
                             </div>
                           </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button @click="showSystemStatusDialog = false; stopSystemStatusPolling()" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm">
              关闭
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 系统设置对话框已迁移到独立页面 /settings -->

    <!-- 垃圾邮件过滤配置对话框 -->
    <div v-if="showSpamFilterDialog" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showSpamFilterDialog = false"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-orange-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full">
                <h3 class="text-lg leading-6 font-medium text-gray-900">垃圾邮件过滤配置</h3>
                <p class="text-sm text-gray-500 mt-1">配置垃圾邮件过滤规则和关键词</p>
                
                <!-- 过滤配置内容 -->
                <div class="mt-6 space-y-6">
                  <!-- 关键词管理 -->
                  <div class="bg-gradient-to-br from-orange-50 to-red-50 p-6 rounded-xl border border-orange-200">
                    <div class="flex items-center mb-4">
                      <div class="p-2 bg-orange-100 rounded-lg">
                        <svg class="h-5 w-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                        </svg>
                      </div>
                      <h4 class="ml-3 text-lg font-semibold text-gray-900">关键词管理</h4>
                    </div>
                    
                    <!-- 添加关键词 -->
                    <div class="mb-4">
                      <div class="flex items-center space-x-2">
                        <input v-model="newSpamKeyword" type="text" placeholder="输入垃圾邮件关键词" class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500">
                        <select v-model="newSpamKeywordLang" class="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-orange-500">
                          <option value="cn">中文</option>
                          <option value="en">英文</option>
                        </select>
                        <button @click="addSpamKeyword" :disabled="!newSpamKeyword" class="px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-700 disabled:opacity-50 disabled:cursor-not-allowed">
                          添加
                        </button>
                      </div>
                    </div>
                    
                    <!-- 关键词列表 -->
                    <div class="space-y-2 max-h-40 overflow-y-auto">
                      <div v-for="(keyword, index) in spamKeywords" :key="index" class="flex items-center justify-between p-2 bg-white rounded-md border">
                        <div class="flex items-center space-x-2">
                          <span class="text-sm font-medium text-gray-700">{{ keyword.text }}</span>
                          <span class="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">{{ keyword.lang === 'cn' ? '中文' : '英文' }}</span>
                        </div>
                        <button @click="removeSpamKeyword(index)" class="text-red-600 hover:text-red-800">
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 域名黑名单管理 -->
                  <div class="bg-gradient-to-br from-red-50 to-pink-50 p-6 rounded-xl border border-red-200">
                    <div class="flex items-center mb-4">
                      <div class="p-2 bg-red-100 rounded-lg">
                        <svg class="h-5 w-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                        </svg>
                      </div>
                      <h4 class="ml-3 text-lg font-semibold text-gray-900">域名黑名单</h4>
                    </div>
                    
                    <!-- 添加域名 -->
                    <div class="mb-4">
                      <div class="flex items-center space-x-2">
                        <input v-model="newSpamDomain" type="text" placeholder="输入垃圾邮件域名" class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500">
                        <button @click="addSpamDomain" :disabled="!newSpamDomain" class="px-4 py-2 bg-red-600 text-white rounded-md hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed">
                          添加
                        </button>
                      </div>
                    </div>
                    
                    <!-- 域名列表 -->
                    <div class="space-y-2 max-h-40 overflow-y-auto">
                      <div v-for="(domain, index) in spamDomains" :key="index" class="flex items-center justify-between p-2 bg-white rounded-md border">
                        <span class="text-sm font-medium text-gray-700">{{ domain }}</span>
                        <button @click="removeSpamDomain(index)" class="text-red-600 hover:text-red-800">
                          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 过滤规则配置 -->
                  <div class="bg-gradient-to-br from-blue-50 to-cyan-50 p-6 rounded-xl border border-blue-200">
                    <div class="flex items-center mb-4">
                      <div class="p-2 bg-blue-100 rounded-lg">
                        <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        </svg>
                      </div>
                      <h4 class="ml-3 text-lg font-semibold text-gray-900">过滤规则配置</h4>
                    </div>
                    
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">最小邮件内容行数</label>
                        <input v-model.number="spamFilterConfig.minBodyLines" type="number" min="1" max="10" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                      </div>
                      
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">大写字母比例阈值</label>
                        <input v-model.number="spamFilterConfig.maxCapsRatio" type="number" min="0" max="1" step="0.1" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                      </div>
                      
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">最大感叹号数量</label>
                        <input v-model.number="spamFilterConfig.maxExclamation" type="number" min="1" max="20" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                      </div>
                      
                      <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">最大特殊字符数量</label>
                        <input v-model.number="spamFilterConfig.maxSpecialChars" type="number" min="1" max="50" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button @click="saveSpamFilterConfig" :disabled="spamFilterSaving" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-gradient-to-r from-orange-600 to-red-600 text-base font-medium text-white hover:from-orange-700 hover:to-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200">
              <svg v-if="spamFilterSaving" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              {{ spamFilterSaving ? '保存中...' : '保存配置' }}
            </button>
            <button @click="testSpamFilter" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm transition-all duration-200">
              测试过滤
            </button>
            <button @click="showSpamFilterDialog = false" class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm transition-all duration-200">
              取消
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 日志查看对话框 -->
    <div v-if="showLogViewerDialog" class="fixed inset-0 z-50 overflow-y-auto">
      <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
        <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="showLogViewerDialog = false"></div>
        <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-6xl sm:w-full">
          <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
            <div class="sm:flex sm:items-start">
              <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-green-100 sm:mx-0 sm:h-10 sm:w-10">
                <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
              </div>
              <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left w-full">
                <h3 class="text-lg leading-6 font-medium text-gray-900">用户操作日志查看器</h3>
                
                <!-- 日志过滤器 -->
                <div class="mt-4 space-y-4">
                  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <!-- 日志类型过滤 -->
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">日志类型</label>
                      <select v-model="logFilters.type" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option v-for="type in logTypes" :key="type.value" :value="type.value">{{ type.label }}</option>
                      </select>
                    </div>
                    
                    <!-- 操作分类过滤 -->
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">操作分类</label>
                      <select v-model="logFilters.category" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option v-for="category in logCategories" :key="category.value" :value="category.value">{{ category.label }}</option>
                      </select>
                    </div>
                    
                    <!-- 用户过滤 -->
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">用户过滤</label>
                      <input v-model="logFilters.user" type="text" placeholder="输入用户名" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    
                    <!-- 操作过滤 -->
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">操作过滤</label>
                      <input v-model="logFilters.action" type="text" placeholder="输入操作类型" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    
                    <!-- 搜索关键词 -->
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">搜索关键词</label>
                      <input v-model="logFilters.search" type="text" placeholder="输入搜索关键词" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                    </div>
                    
                    <!-- 显示条数 -->
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">显示条数</label>
                      <select v-model="logFilters.limit" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                        <option value="20">20条</option>
                        <option value="50">50条</option>
                        <option value="100">100条</option>
                        <option value="200">200条</option>
                      </select>
                    </div>
                  </div>
                  
                  <!-- 操作按钮 -->
                  <div class="flex flex-wrap gap-2">
                    <button @click="applyLogFilters" class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500">
                      应用过滤器
                    </button>
                    <button @click="exportLogs('csv')" class="px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500">
                      导出CSV
                    </button>
                    <button @click="exportLogs('txt')" class="px-4 py-2 bg-yellow-600 text-white rounded-md hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-yellow-500">
                      导出TXT
                    </button>
                    <button @click="exportLogs('json')" class="px-4 py-2 bg-purple-600 text-white rounded-md hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-purple-500">
                      导出JSON
                    </button>
                  </div>
                </div>
                
                <!-- 日志统计信息 -->
                <div class="mt-4">
                  <div class="bg-blue-50 border border-blue-200 rounded-lg p-3 mb-4">
                    <div class="flex items-center justify-between">
                      <div class="flex items-center space-x-4">
                        <div class="flex items-center space-x-2">
                          <span class="text-blue-600 font-medium">📊 日志统计</span>
                        </div>
                        <div class="flex items-center space-x-4 text-sm">
                          <span class="text-gray-600">总日志数: <span class="font-bold text-blue-600" id="total-logs">-</span></span>
                          <span class="text-gray-600">未知日志: <span class="font-bold text-red-600" id="unknown-logs">-</span></span>
                          <span class="text-gray-600">解析率: <span class="font-bold text-green-600" id="parse-rate">-</span></span>
                        </div>
                      </div>
                      <div class="text-xs text-gray-500">
                        最后更新: <span id="last-update">-</span>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- 日志显示区域 -->
                <div class="mt-4">
                  <div class="bg-gray-900 text-green-400 p-4 rounded-lg font-mono text-sm h-96 overflow-y-auto log-viewer-content">
                    <div class="flex items-center justify-center h-full">
                      <div class="text-gray-500">
                        <svg class="animate-spin h-8 w-8 mx-auto mb-2" fill="none" viewBox="0 0 24 24">
                          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        <p>正在加载用户日志...</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
            <button @click="showLogViewerDialog = false" class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-green-600 text-base font-medium text-white hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 sm:ml-3 sm:w-auto sm:text-sm">
              关闭
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 新的终端组件 -->
    <Terminal :visible="showCommandTerminalDialog" @close="showCommandTerminalDialog = false" />

    <!-- 删除域名确认弹窗已迁移到独立页面 /settings -->
  </div>
</template>

<style scoped>
@keyframes slide-in {
  from {
    transform: translateX(-100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

@keyframes bounce-in {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  50% {
    transform: scale(1.05);
  }
  70% {
    transform: scale(0.9);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}

@keyframes pulse-glow {
  0%, 100% {
    box-shadow: 0 0 5px rgba(59, 130, 246, 0.5);
  }
  50% {
    box-shadow: 0 0 20px rgba(59, 130, 246, 0.8);
  }
}

.animate-slide-in {
  animation: slide-in 0.5s ease-out;
}

.animate-bounce-in {
  animation: bounce-in 0.6s ease-out;
}

.animate-pulse-glow {
  animation: pulse-glow 2s ease-in-out infinite;
}

/* 自定义滚动条样式 */
.scrollbar-thin {
  scrollbar-width: thin;
}

.scrollbar-thumb-gray-300::-webkit-scrollbar-thumb {
  background-color: rgb(209, 213, 219);
  border-radius: 0.375rem;
}

.scrollbar-track-gray-100::-webkit-scrollbar-track {
  background-color: rgb(243, 244, 246);
}

.scrollbar-thin::-webkit-scrollbar {
  width: 6px;
}

/* 悬停时的发光效果 */
.group:hover .animate-pulse-glow {
  animation: pulse-glow 1s ease-in-out infinite;
}
</style>

<script setup lang="ts">
import { ref, computed, nextTick, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { userLogger } from '../utils/userLogger'
import { versionManager } from '../utils/versionManager'
import { activityTracker } from '../utils/activityTracker'
import Terminal from './Terminal.vue'

const route = useRoute()
const sidebarOpen = ref(false)
const isInitialized = ref(false)

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

// 核心版本管理，默认版本，出现0.0.1代表系统错误
const currentVersion = ref('V0.0.1')
const versionLoading = ref(false)

// 对话框状态管理
const showSystemStatusDialog = ref(false)
const showLogViewerDialog = ref(false)
const showCommandTerminalDialog = ref(false)
const showSpamFilterDialog = ref(false)

// 检查当前用户是否为管理员
const isAdmin = computed(() => {
  // 如果还没有初始化，返回false避免闪烁
  if (!isInitialized.value) return false
  
  const auth = sessionStorage.getItem('apiAuth')
  if (!auth) return false
  
  try {
    const credentials = atob(auth).split(':')
    const username = credentials[0]
    return username && username.toLowerCase() === 'xm'
  } catch {
    return false
  }
})

// 当前用户信息
const currentUser = computed(() => {
  const auth = sessionStorage.getItem('apiAuth')
  if (!auth) return null

  try {
    const credentials = atob(auth).split(':')
    return credentials[0] || null
  } catch {
    return null
  }
})

// 管理员邮箱信息
const adminEmail = ref('xm@localhost')
const adminEmailDisplay = ref('系统管理员 (xm@localhost)')

// 用户头像
const userAvatar = ref<string>('')

// 获取管理员邮箱
const fetchAdminEmail = async () => {
  try {
    const response = await fetch('/api/admin-email', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })

    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        adminEmail.value = data.email
        adminEmailDisplay.value = data.display
        console.log('管理员邮箱已更新:', adminEmail.value)
      }
    }
  } catch (error) {
    console.warn('获取管理员邮箱失败:', error)
  }
}

// 获取用户头像
const fetchUserAvatar = async () => {
  // 先检查认证信息
  const auth = sessionStorage.getItem('apiAuth')
  if (!auth) {
    userAvatar.value = ''
    return
  }

  // 获取用户名
  const username = currentUser.value
  if (!username) {
    // 如果currentUser还没有值，尝试从auth中解析
    try {
      const credentials = atob(auth).split(':')
      const parsedUsername = credentials[0]
      if (parsedUsername) {
        // 使用解析出的用户名
        await fetchAvatarForUser(parsedUsername, auth)
      } else {
        userAvatar.value = ''
      }
    } catch {
      userAvatar.value = ''
    }
    return
  }

  await fetchAvatarForUser(username, auth)
}

// 为指定用户获取头像
const fetchAvatarForUser = async (username: string, auth: string) => {
  try {
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
      if (data.success && data.user && data.user.avatar) {
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
          userAvatar.value = avatarUrl
          console.log('加载用户头像:', avatarUrl)
        } else {
          userAvatar.value = ''
        }
      } else {
        userAvatar.value = ''
      }
    } else {
      // 如果是401错误，静默处理，不显示错误
      if (response.status === 401) {
        console.warn('获取用户头像失败: 未授权，可能用户尚未登录')
        userAvatar.value = ''
      } else {
        userAvatar.value = ''
      }
    }
  } catch (error) {
    // 静默处理错误，不影响用户体验
    console.warn('获取用户头像失败:', error)
    userAvatar.value = ''
  }
}

// 处理头像加载错误
const handleAvatarError = (event: Event) => {
  console.warn('头像加载失败，使用默认图标')
  const target = event.target as HTMLImageElement
  if (target) {
    target.style.display = 'none'
  }
  // 不设置userAvatar为空，保持原始值以便后续重试
}

// 在window对象上暴露方法，供其他组件调用
;(window as any).refreshAdminEmail = fetchAdminEmail
;(window as any).refreshUserAvatar = fetchUserAvatar

// 未读邮件数量
const unreadEmailCount = ref(0)

// 获取未读邮件数量
const loadUnreadEmailCount = async () => {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return
    
    const response = await fetch('/api/mail/list?folder=inbox', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      const emails = data.emails || []
      unreadEmailCount.value = emails.filter(email => !email.read).length
    }
  } catch (error) {
    console.error('获取未读邮件数量失败:', error)
  }
}

// 从localStorage更新未读邮件计数
const updateUnreadCountFromStorage = () => {
  const storedCount = localStorage.getItem('unreadEmailCount')
  if (storedCount !== null) {
    unreadEmailCount.value = parseInt(storedCount) || 0
  }
}

const pageTitle = computed(() => {
  switch (route.path) {
    case '/dashboard':
      return '系统仪表板'
    case '/mail':
      return '邮件管理'
    default:
      return 'XM邮件管理系统'
  }
})

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const logout = () => {
  // 防抖：避免并发请求导致重复触发退出操作
  // @ts-ignore
  if (window.__loggingOut) return
  // @ts-ignore
  window.__loggingOut = true
  
  // 停止活动追踪
  activityTracker.stop()
  
  sessionStorage.removeItem('apiAuth')
  // 使用导航方式跳转登录，避免多次整页刷新
  window.location.href = '/login'
}

// 对话框显示函数
// 系统状态相关状态
const systemStatus = ref({
  services: {},
  resources: {},
  systemInfo: {},
  network: {},
  processes: {},
  lastUpdate: null,
  loading: false,
  error: null
})

const showResourceDetails = ref(false)

const systemStatusInterval = ref(null)

const showSystemStatus = async () => {
  showSystemStatusDialog.value = true
  await loadSystemStatus()
  startSystemStatusPolling()
}

// 加载系统状态
const loadSystemStatus = async () => {
  systemStatus.value.loading = true
  systemStatus.value.error = null
  
  try {
    const response = await fetch('/api/system-status', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    const result = await response.json()
    if (result.success) {
      systemStatus.value = {
        ...result.data,
        loading: false,
        error: null
      }
    } else {
      systemStatus.value.error = result.message || '获取系统状态失败'
      systemStatus.value.loading = false
    }
  } catch (error) {
    console.error('加载系统状态失败:', error)
    systemStatus.value.error = '网络连接失败'
    systemStatus.value.loading = false
  }
}

// 开始系统状态轮询
const startSystemStatusPolling = () => {
  if (systemStatusInterval.value) {
    clearInterval(systemStatusInterval.value)
  }
  
  systemStatusInterval.value = setInterval(async () => {
    if (showSystemStatusDialog.value) {
      await loadSystemStatus()
    }
  }, 5000) // 每5秒更新一次
}

// 停止系统状态轮询
const stopSystemStatusPolling = () => {
  if (systemStatusInterval.value) {
    clearInterval(systemStatusInterval.value)
    systemStatusInterval.value = null
  }
}

// 获取服务状态颜色
const getServiceStatusColor = (status) => {
  const colors = {
    'running': 'text-green-600',
    'stopped': 'text-red-600',
    'error': 'text-orange-600'
  }
  return colors[status] || 'text-gray-600'
}

// 获取服务状态图标
const getServiceStatusIcon = (status) => {
  const icons = {
    'running': '✅',
    'stopped': '❌',
    'error': '⚠️'
  }
  return icons[status] || '❓'
}

// 获取服务状态圆点颜色
const getServiceStatusDotColor = (status) => {
  const colors = {
    'running': 'bg-green-500 animate-pulse',
    'stopped': 'bg-red-500',
    'error': 'bg-orange-500 animate-pulse'
  }
  return colors[status] || 'bg-gray-400'
}

// 获取服务状态徽章颜色
const getServiceStatusBadgeColor = (status) => {
  const colors = {
    'running': 'bg-green-100 text-green-800 border border-green-200',
    'stopped': 'bg-red-100 text-red-800 border border-red-200',
    'error': 'bg-orange-100 text-orange-800 border border-orange-200'
  }
  return colors[status] || 'bg-gray-100 text-gray-800 border border-gray-200'
}

// 获取服务状态文本
const getServiceStatusText = (status) => {
  const texts = {
    'running': '运行中',
    'stopped': '已关闭',
    'error': '错误'
  }
  return texts[status] || '未知'
}

// 调试函数 - 显示服务状态信息
const debugServiceStatus = (service, status) => {
  console.log(`Service ${service}: status=${status.status}, rawStatus=${status.rawStatus}, lastCheck=${status.lastCheck}`)
}

// 切换资源详细信息显示
const toggleResourceDetails = () => {
  showResourceDetails.value = !showResourceDetails.value
}

// 获取服务显示名称
const getServiceDisplayName = (name) => {
  const names = {
    'postfix': 'Postfix',
    'dovecot': 'Dovecot',
    'httpd': 'Apache',
    'mariadb': 'MariaDB',
    'named': 'DNS',
    'firewalld': '防火墙',
    'dispatcher': '调度器',
    'mail': '邮件系统'
  }
  return names[name] || name
}

// 获取服务状态数量
const getServiceCount = (status) => {
  if (!systemStatus.value.services) return 0
  return Object.values(systemStatus.value.services).filter(service => service.status === status).length
}

// 组件挂载时初始化
// 获取版本信息
const loadVersion = async () => {
  try {
    versionLoading.value = true
    const version = await versionManager.getVersion()
    currentVersion.value = `V${version}`
  } catch (error) {
    console.warn('获取版本信息失败:', error)
    // 保持默认版本
  } finally {
    versionLoading.value = false
  }
}

onMounted(() => {
  // 立即检查认证状态，避免闪烁
  const auth = sessionStorage.getItem('apiAuth')
  if (auth) {
    // 如果有认证信息，立即初始化
    isInitialized.value = true
    // 加载未读邮件数量
    loadUnreadEmailCount()
    // 加载版本信息
    loadVersion()
    // 加载备案号设置（公开信息，无需认证）
    loadIcpSettings()
    // 获取管理员邮箱
    fetchAdminEmail()
    // 延迟获取用户头像，确保currentUser已经计算完成
    nextTick(() => {
      setTimeout(() => {
        fetchUserAvatar()
      }, 100)
    })
  } else {
    // 如果没有认证信息，延迟一点时间再初始化
    nextTick(() => {
      setTimeout(() => {
        isInitialized.value = true
        // 加载版本信息
        loadVersion()
        // 加载备案号设置（公开信息，无需认证）
        loadIcpSettings()
      }, 50)
    })
  }
  
  // 监听未读邮件计数更新事件
  window.addEventListener('unreadCountUpdated', (event: any) => {
    unreadEmailCount.value = event.detail.count
  })
  
  // 设置定时刷新未读邮件数量（每30秒）
  setInterval(() => {
    if (isAdmin.value) {
      loadUnreadEmailCount()
    }
  }, 30000)
  
  // 定期检查localStorage中的未读邮件计数
  setInterval(() => {
    updateUnreadCountFromStorage()
  }, 1000)
})

// 获取资源使用率颜色
const getResourceColor = (value, thresholds = { warning: 70, critical: 90 }) => {
  if (value >= thresholds.critical) return 'text-red-600'
  if (value >= thresholds.warning) return 'text-orange-600'
  return 'text-green-600'
}

// DNS相关函数
const getDnsHealthColor = (score) => {
  if (score >= 80) return 'text-green-600'
  if (score >= 60) return 'text-blue-600'
  if (score >= 40) return 'text-yellow-600'
  return 'text-red-600'
}

const getDnsStatusColor = (status) => {
  const colors = {
    'excellent': 'text-green-600',
    'good': 'text-blue-600',
    'fair': 'text-yellow-600',
    'poor': 'text-red-600',
    'not_configured': 'text-gray-600',
    'error': 'text-red-600'
  }
  return colors[status] || 'text-gray-600'
}

const getDnsStatusText = (status) => {
  const texts = {
    'excellent': '优秀',
    'good': '良好',
    'fair': '一般',
    'poor': '较差',
    'not_configured': '未配置',
    'error': '错误'
  }
  return texts[status] || '未知'
}

const getDnsRecordColor = (status) => {
  const colors = {
    'configured': 'text-green-600',
    'missing': 'text-yellow-600',
    'error': 'text-red-600'
  }
  return colors[status] || 'text-gray-600'
}

const getDnsRecordText = (status) => {
  const texts = {
    'configured': '已配置',
    'missing': '缺失',
    'error': '错误'
  }
  return texts[status] || '未知'
}

// 格式化时间
const formatUptime = (seconds) => {
  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)
  
  if (days > 0) return `${days}天 ${hours}小时 ${minutes}分钟`
  if (hours > 0) return `${hours}小时 ${minutes}分钟`
  return `${minutes}分钟`
}

// 垃圾邮件过滤相关状态
const spamKeywords = ref<Array<{text: string, lang: string}>>([])
const spamDomains = ref<string[]>([])
const newSpamKeyword = ref('')
const newSpamKeywordLang = ref('cn')
const newSpamDomain = ref('')
const spamFilterSaving = ref(false)
const spamFilterConfig = ref({
  minBodyLines: 3,
  maxCapsRatio: 0.7,
  maxExclamation: 5,
  maxSpecialChars: 10
})

// 系统设置相关代码已迁移到独立页面 /settings

// 显示垃圾邮件过滤配置
const showSpamFilterConfig = () => {
  showSpamFilterDialog.value = true
  loadSpamFilterConfig()
}

// 加载垃圾邮件过滤配置
const loadSpamFilterConfig = async () => {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return
    
    const response = await fetch('/api/spam-filter/config', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 更新关键词列表
        spamKeywords.value = [
          ...(data.data.keywords.chinese || []).map(keyword => ({ text: keyword, lang: 'cn' })),
          ...(data.data.keywords.english || []).map(keyword => ({ text: keyword, lang: 'en' }))
        ]
        
        // 更新域名黑名单
        spamDomains.value = data.data.domainBlacklist || []
        
        // 更新过滤规则
        spamFilterConfig.value = {
          minBodyLines: data.data.rules.minContentLines || 3,
          maxCapsRatio: data.data.rules.uppercaseRatio || 0.7,
          maxExclamation: data.data.rules.maxExclamationMarks || 5,
          maxSpecialChars: data.data.rules.maxSpecialChars || 10
        }
      }
    }
  } catch (error) {
    console.error('加载垃圾邮件过滤配置失败:', error)
    // 使用默认配置
    spamKeywords.value = [
      { text: '免费', lang: 'cn' },
      { text: '赚钱', lang: 'cn' },
      { text: '投资', lang: 'cn' },
      { text: 'viagra', lang: 'en' },
      { text: 'casino', lang: 'en' }
    ]
    spamDomains.value = ['spam.com', 'junk.com', 'trash.com']
  }
}

// 添加垃圾邮件关键词
const addSpamKeyword = () => {
  if (newSpamKeyword.value.trim()) {
    spamKeywords.value.push({
      text: newSpamKeyword.value.trim(),
      lang: newSpamKeywordLang.value
    })
    newSpamKeyword.value = ''
  }
}

// 删除垃圾邮件关键词
const removeSpamKeyword = (index: number) => {
  spamKeywords.value.splice(index, 1)
}

// 添加垃圾邮件域名
const addSpamDomain = () => {
  if (newSpamDomain.value.trim()) {
    spamDomains.value.push(newSpamDomain.value.trim())
    newSpamDomain.value = ''
  }
}

// 删除垃圾邮件域名
const removeSpamDomain = (index: number) => {
  spamDomains.value.splice(index, 1)
}

// 保存垃圾邮件过滤配置
const saveSpamFilterConfig = async () => {
  spamFilterSaving.value = true
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return
    
    // 准备配置数据
    const keywords = {
      chinese: spamKeywords.value.filter(k => k.lang === 'cn').map(k => k.text),
      english: spamKeywords.value.filter(k => k.lang === 'en').map(k => k.text)
    }
    
    const configData = {
      keywords,
      domainBlacklist: spamDomains.value,
      emailBlacklist: [], // 邮箱黑名单（如果需要可以添加）
      rules: {
        minContentLines: spamFilterConfig.value.minBodyLines,
        uppercaseRatio: spamFilterConfig.value.maxCapsRatio,
        maxExclamationMarks: spamFilterConfig.value.maxExclamation,
        maxSpecialChars: spamFilterConfig.value.maxSpecialChars
      }
    }
    
    const response = await fetch('/api/spam-filter/config', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify(configData)
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        alert('垃圾邮件过滤配置保存成功！')
        showSpamFilterDialog.value = false
      } else {
        throw new Error(data.message || '保存失败')
      }
    } else {
      throw new Error('保存失败')
    }
  } catch (error) {
    console.error('保存垃圾邮件过滤配置失败:', error)
    alert('保存失败，请重试')
  } finally {
    spamFilterSaving.value = false
  }
}

// 测试垃圾邮件过滤
const testSpamFilter = async () => {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) return
    
    // 测试邮件内容
    const testData = {
      subject: '免费赚钱投资机会！',
      content: '这是一个包含违禁关键词的测试邮件内容。',
      from: 'test@spam.com',
      to: 'user@example.com'
    }
    
    const response = await fetch('/api/spam-filter/check', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify(testData)
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        const result = data.data
        if (result.isSpam) {
          alert(`垃圾邮件检测成功！\n检测到 ${result.violations.length} 项违规\n评分: ${result.spamScore}\n详情: ${result.summary}`)
        } else {
          alert('垃圾邮件检测完成，邮件内容正常')
        }
      }
    } else {
      throw new Error('测试失败')
    }
  } catch (error) {
    console.error('测试垃圾邮件过滤失败:', error)
    alert('测试失败，请重试')
  }
}

// 系统设置相关函数已迁移到独立页面 /settings

// 日志查看器相关状态
const logFilters = ref({
  type: 'all',
  user: '',
  action: '',
  category: '',
  search: '',
  limit: 50
})

const logCategories = ref([
  { value: '', label: '所有分类' },
  { value: 'general', label: '常规操作' },
  { value: 'mail', label: '邮件操作' },
  { value: 'dns', label: 'DNS配置' },
  { value: 'system', label: '系统设置' },
  { value: 'user', label: '用户管理' },
  { value: 'security', label: '安全操作' },
  { value: 'backup', label: '备份恢复' },
  { value: 'monitoring', label: '监控日志' }
])

const logTypes = ref([
  { value: 'all', label: '所有类型' },
  { value: 'USER_LOG', label: '用户操作' },
  { value: 'MAIL_OPERATION', label: '邮件操作' },
  { value: 'DNS_CONFIG', label: 'DNS配置' },
  { value: 'SYSTEM_SETTINGS', label: '系统设置' },
  { value: 'SECURITY', label: '安全操作' },
  { value: 'BACKUP', label: '备份操作' },
  { value: 'TERMINAL_OUTPUT', label: '终端输出' },
  { value: 'ERROR_MESSAGE', label: '错误信息' },
  { value: 'DEBUG_INFO', label: '调试信息' }
])

const showLogViewer = async () => {
  showLogViewerDialog.value = true
  // 重置过滤器
  logFilters.value = {
    type: 'all',
    user: '',
    action: '',
    category: '',
    search: '',
    limit: 50
  }
  // 加载用户日志
  await loadUserLogs()
}

// 加载用户日志
const loadUserLogs = async () => {
  try {
    const params = new URLSearchParams()
    Object.keys(logFilters.value).forEach(key => {
      if (logFilters.value[key]) {
        params.append(key, logFilters.value[key])
      }
    })
    
    const response = await fetch(`/api/logs?${params.toString()}`, {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    const result = await response.json()
    if (result.success && result.logs) {
      updateLogDisplay(result.logs)
    } else {
      updateLogDisplay([])
    }
  } catch (error) {
    console.error('加载用户日志失败:', error)
    updateLogDisplay([])
  }
}

// 应用日志过滤器
const applyLogFilters = async () => {
  await loadUserLogs()
}

// 导出日志
const exportLogs = async (format) => {
  try {
    const params = new URLSearchParams()
    Object.keys(logFilters.value).forEach(key => {
      if (logFilters.value[key]) {
        params.append(key, logFilters.value[key])
      }
    })
    params.append('format', format)
    
    const response = await fetch(`/api/logs?${params.toString()}`, {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (response.ok) {
      const blob = await response.blob()
      const url = window.URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `mail-logs.${format}`
      document.body.appendChild(a)
      a.click()
      window.URL.revokeObjectURL(url)
      document.body.removeChild(a)
    }
  } catch (error) {
    console.error('导出日志失败:', error)
  }
}

// 解析日志消息，提取操作类型和其他信息
const parseLogMessage = (message) => {
  const parsed = {
    operation: 'unknown',
    email: '',
    folder: '',
    limit: '',
    offset: '',
    details: {}
  }
  
  // 尝试从消息中提取操作类型（如 MAIL_LIST）
  const operationMatch = message.match(/\[([A-Z_]+)\]/)
  if (operationMatch) {
    parsed.operation = operationMatch[1]
  }
  
  // 提取 Email
  const emailMatch = message.match(/Email: ([^,]+)/)
  if (emailMatch) {
    parsed.email = emailMatch[1]
  }
  
  // 提取 Folder
  const folderMatch = message.match(/Folder: ([^,]+)/)
  if (folderMatch) {
    parsed.folder = folderMatch[1]
  }
  
  // 提取 Limit
  const limitMatch = message.match(/Limit: ([^,]+)/)
  if (limitMatch) {
    parsed.limit = limitMatch[1]
  }
  
  // 提取 Offset
  const offsetMatch = message.match(/Offset: ([^,]+)/)
  if (offsetMatch) {
    parsed.offset = offsetMatch[1]
  }
  
  // 提取 Operation（如果存在）
  const operationMatch2 = message.match(/Operation: ([^,]+)/)
  if (operationMatch2) {
    parsed.operation = operationMatch2[1]
  }
  
  return parsed
}

// 更新日志显示
const updateLogDisplay = (logs) => {
  const logContainer = document.querySelector('.log-viewer-content')
  if (logContainer) {
    // 更新统计信息
    updateLogStatistics(logs)
    
    if (logs.length === 0) {
      logContainer.innerHTML = `
        <div class="flex items-center justify-center h-full">
          <div class="text-gray-500">
            <svg class="h-8 w-8 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
            </svg>
            <p>暂无用户日志</p>
          </div>
        </div>
      `
      return
    }
    
    logContainer.innerHTML = logs.map(log => {
      // 格式化时间戳为 [YYYY/MM/DD HH:mm:ss]
      const date = new Date(log.timestamp)
      const formattedDate = `${date.getFullYear()}/${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')} ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}:${String(date.getSeconds()).padStart(2, '0')}`
      
      // 解析日志消息
      const parsed = parseLogMessage(log.message)
      
      // 确定操作类型（优先使用解析出的操作类型，否则使用 log.action）
      const operationType = parsed.operation !== 'unknown' ? parsed.operation : (log.action || 'unknown')
      
      // 根据日志类型显示不同的图标
      const getLogIcon = (type, operation) => {
        // 优先根据操作类型选择图标
        const operationIcons = {
          'MAIL_LIST': '📧',
          'MAIL_SEND': '📤',
          'MAIL_RECEIVE': '📥',
          'MAIL_DELETE': '🗑️',
          'MAIL_MOVE': '📦',
          'FOLDER_CREATE': '📁',
          'FOLDER_DELETE': '🗂️',
          'LOGIN': '🔐',
          'LOGOUT': '🚪',
          'USER_CREATE': '👤',
          'USER_UPDATE': '✏️',
          'USER_DELETE': '❌'
        }
        
        if (operationIcons[operation]) {
          return operationIcons[operation]
        }
        
        // 根据日志类型选择图标
        const typeIcons = {
          'TERMINAL_COMMAND_START': '🚀',
          'TERMINAL_COMMAND_SUCCESS': '✅',
          'TERMINAL_COMMAND_ERROR': '❌',
          'TERMINAL_ENV': '🔧',
          'TERMINAL_OUTPUT': '📄',
          'TERMINAL_OUTPUT_SUMMARY': '📋',
          'TERMINAL_STDOUT': '📤',
          'TERMINAL_STDERR': '📥',
          'TERMINAL_SYSTEM_ERROR': '💥',
          'USER_OPERATION': '👤',
          'OPERATION_START': '🔄',
          'OPERATION_END': '🏁',
          'JSON_OUTPUT': '📊',
          'DEBUG': '🐛',
          'CODE_SNIPPET': '💻',
          'ERROR_MESSAGE': '⚠️',
          'DEBUG_INFO': '🔍',
          'USER_LOG': '👤',
          'MAIL_OPERATION': '📧',
          'DNS_CONFIG': '🌐',
          'SYSTEM_SETTINGS': '⚙️',
          'SECURITY': '🔒',
          'BACKUP': '💾',
          'UNKNOWN': '❓'
        }
        return typeIcons[type] || '📝'
      }
      
      const logIcon = getLogIcon(log.type, operationType)
      
      // 获取日志源文件名（简化显示）
      const getSourceName = (source) => {
        if (!source) return 'unknown.log'
        const parts = source.split('/')
        return parts[parts.length - 1] || source
      }
      
      const sourceName = getSourceName(log.source)
      
      // 为未知日志添加特殊样式
      const isUnknownLog = log.type === 'UNKNOWN' || log.type === 'unknown' || operationType === 'unknown'
      
      // 构建详细信息显示
      let detailsHtml = ''
      if (parsed.email) {
        detailsHtml += `<span class="text-cyan-400">📧 ${parsed.email}</span>`
      }
      if (parsed.folder) {
        detailsHtml += `<span class="text-blue-400">📁 ${parsed.folder}</span>`
      }
      if (parsed.limit) {
        detailsHtml += `<span class="text-yellow-400">📊 Limit: ${parsed.limit}</span>`
      }
      if (parsed.offset) {
        detailsHtml += `<span class="text-yellow-400">📍 Offset: ${parsed.offset}</span>`
      }
      
      return `<div class="log-entry mb-3 p-4 bg-gray-800 rounded-lg border-l-4 ${isUnknownLog ? 'border-red-500 bg-red-900/20' : 'border-blue-500'} hover:bg-gray-750 transition-colors">
        <div class="flex items-start space-x-3">
          <div class="text-2xl flex-shrink-0">${logIcon}</div>
          <div class="flex-1 min-w-0">
            <div class="flex items-center space-x-2 mb-2 flex-wrap">
              <span class="text-blue-400 text-sm font-mono">[${formattedDate}]</span>
              <span class="text-green-400 text-sm font-bold">[${operationType}]</span>
              ${isUnknownLog ? '<span class="text-red-400 text-xs font-bold px-2 py-1 bg-red-900/50 rounded">未知操作</span>' : ''}
          </div>
            <div class="flex items-center space-x-4 mb-2 flex-wrap text-xs">
              <span class="text-yellow-400">📁 ${sourceName}</span>
              <span class="text-purple-400">👤 ${log.user || 'unknown'}</span>
              <span class="text-green-400">⚡ ${operationType}</span>
              <span class="text-cyan-400">🌐 ${log.ip || 'unknown'}</span>
        </div>
            ${detailsHtml ? `<div class="flex items-center space-x-3 mb-2 flex-wrap text-xs">${detailsHtml}</div>` : ''}
            <div class="text-gray-300 text-xs font-mono break-all bg-gray-900/50 p-2 rounded mt-2">
            ${log.message}
            </div>
          </div>
        </div>
      </div>`
    }).join('')
    
    // 滚动到底部显示最新日志
    nextTick(() => {
      if (logContainer) {
        logContainer.scrollTop = logContainer.scrollHeight
      }
    })
  }
}

// 更新日志统计信息
const updateLogStatistics = (logs) => {
  const totalLogs = logs.length
  const unknownLogs = logs.filter(log => log.type === 'UNKNOWN' || log.type === 'unknown').length
  const parseRate = totalLogs > 0 ? Math.round(((totalLogs - unknownLogs) / totalLogs) * 100) : 100
  
  // 更新统计信息显示
  const totalLogsElement = document.getElementById('total-logs')
  const unknownLogsElement = document.getElementById('unknown-logs')
  const parseRateElement = document.getElementById('parse-rate')
  const lastUpdateElement = document.getElementById('last-update')
  
  if (totalLogsElement) totalLogsElement.textContent = totalLogs
  if (unknownLogsElement) unknownLogsElement.textContent = unknownLogs
  if (parseRateElement) parseRateElement.textContent = `${parseRate}%`
  if (lastUpdateElement) lastUpdateElement.textContent = new Date().toLocaleTimeString('zh-CN')
}

// 获取日志源文件颜色
const getSourceColor = (source) => {
  const colors = {
    'user-operations.log': 'text-yellow-400',
    'mail-operations.log': 'text-green-400',
    'system.log': 'text-blue-400',
    'install.log': 'text-purple-400'
  }
  return colors[source] || 'text-gray-400'
}

// 获取日志类型颜色
const getLogTypeColor = (type) => {
  const colors = {
    'USER_OPERATION': 'text-yellow-400',
    'TERMINAL_COMMAND': 'text-purple-400',
    'TERMINAL_RESULT': 'text-green-400',
    'TERMINAL_COMMAND_START': 'text-blue-400',
    'TERMINAL_COMMAND_SUCCESS': 'text-green-400',
    'TERMINAL_COMMAND_ERROR': 'text-red-400',
    'TERMINAL_ENV': 'text-cyan-400',
    'TERMINAL_OUTPUT': 'text-gray-300',
    'TERMINAL_OUTPUT_SUMMARY': 'text-orange-400',
    'TERMINAL_STDOUT': 'text-green-300',
    'TERMINAL_STDERR': 'text-red-300',
    'TERMINAL_SYSTEM_ERROR': 'text-red-500',
    'OPERATION_START': 'text-blue-400',
    'OPERATION_END': 'text-green-400',
    'JSON_OUTPUT': 'text-cyan-400',
    'DEBUG': 'text-gray-400',
    'CODE_SNIPPET': 'text-purple-300',
    'ERROR_MESSAGE': 'text-red-400',
    'DEBUG_INFO': 'text-gray-400',
    'UNKNOWN': 'text-gray-500'
  }
  return colors[type] || 'text-white'
}

const showCommandTerminal = () => {
  showCommandTerminalDialog.value = true
}

// 页面访问日志记录
userLogger.logPageView(route.path)
// 获取分类颜色
const getCategoryColor = (category) => {
  const colors = {
    'general': 'bg-gray-100 text-gray-800',
    'mail': 'bg-green-100 text-green-800',
    'dns': 'bg-purple-100 text-purple-800',
    'system': 'bg-orange-100 text-orange-800',
    'user': 'bg-blue-100 text-blue-800',
    'security': 'bg-red-100 text-red-800',
    'backup': 'bg-indigo-100 text-indigo-800',
    'monitoring': 'bg-yellow-100 text-yellow-800'
  }
  return colors[category] || 'bg-gray-100 text-gray-800'
}
</script>
