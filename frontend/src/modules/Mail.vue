<template>
  <Layout>
    <!-- 邮件界面 - 根据用户权限显示不同布局 -->
    <div class="relative min-h-screen overflow-hidden dark:bg-gray-900">
      <!-- 邮件主题动画背景 -->
      <div class="absolute inset-0 bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
        <!-- 浮动邮件图标 -->
        <div class="absolute top-20 left-10 w-16 h-16 text-blue-400 opacity-20 animate-float">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </svg>
        </div>
        <div class="absolute top-40 right-20 w-12 h-12 text-purple-400 opacity-15 animate-float-delayed">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </svg>
        </div>
        <div class="absolute bottom-20 left-1/4 w-20 h-20 text-indigo-400 opacity-10 animate-float-slow">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </svg>
        </div>
        <div class="absolute bottom-40 right-1/3 w-14 h-14 text-cyan-400 opacity-20 animate-float-reverse">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </svg>
        </div>
        
        <!-- 浮动信封 -->
        <div class="absolute top-32 left-1/3 w-8 h-8 text-green-400 opacity-25 animate-mail-drift">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </svg>
        </div>
        <div class="absolute bottom-32 right-1/4 w-6 h-6 text-pink-400 opacity-30 animate-pulse">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
          </svg>
        </div>
        
        <!-- 邮件主题装饰元素 -->
        <div class="absolute top-1/2 left-1/6 w-4 h-4 text-yellow-400 opacity-20 animate-spin" style="animation-duration: 20s;">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
          </svg>
        </div>
        <div class="absolute bottom-1/3 right-1/6 w-3 h-3 text-orange-400 opacity-25 animate-ping" style="animation-duration: 3s;">
          <svg fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
          </svg>
        </div>
        
        <!-- 邮件主题装饰线条 -->
        <div class="absolute top-1/4 left-0 w-full h-px bg-gradient-to-r from-transparent via-blue-300 to-transparent opacity-30"></div>
        <div class="absolute bottom-1/4 left-0 w-full h-px bg-gradient-to-r from-transparent via-purple-300 to-transparent opacity-30"></div>
        
        <!-- 网格背景 -->
        <div class="absolute inset-0 bg-grid-pattern opacity-5"></div>
        
        <!-- 邮件主题粒子效果 -->
        <div class="absolute top-1/3 left-1/4 w-2 h-2 bg-blue-400 rounded-full opacity-40 animate-ping"></div>
        <div class="absolute top-2/3 right-1/3 w-1 h-1 bg-purple-400 rounded-full opacity-50 animate-ping" style="animation-delay: 1s;"></div>
        <div class="absolute top-1/2 left-1/2 w-1.5 h-1.5 bg-indigo-400 rounded-full opacity-30 animate-ping" style="animation-delay: 2s;"></div>
      </div>
      
      <!-- 主内容区域 -->
      <div class="relative z-10 p-3 sm:p-6">
        <!-- 广播消息轮播 -->
        <div v-if="broadcastMessage" class="mb-6 max-w-full">
          <!-- 主容器 - 优雅的浅色卡片设计 -->
          <div class="relative bg-white/95 dark:bg-gray-800/95 backdrop-blur-md rounded-xl shadow-lg border border-blue-200/50 dark:border-gray-600 overflow-hidden hover:shadow-xl transition-shadow duration-300">
            <!-- 左侧装饰条 -->
            <div class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-blue-500 via-indigo-500 to-purple-500 z-10"></div>
            
            <!-- 内容区域 -->
            <div class="pl-5 pr-4 py-3.5 relative">
              <!-- 左右渐变遮罩 - 桌面端更宽 -->
              <div class="absolute left-0 top-0 bottom-0 w-12 md:w-20 bg-gradient-to-r from-white/95 via-white/95 to-transparent dark:from-gray-800/95 dark:via-gray-800/95 z-20 pointer-events-none"></div>
              <div class="absolute right-0 top-0 bottom-0 w-12 md:w-20 bg-gradient-to-l from-white/95 via-white/95 to-transparent dark:from-gray-800/95 dark:via-gray-800/95 z-20 pointer-events-none"></div>
              
              <!-- 滚动容器 - 确保只显示一个 -->
              <div class="relative overflow-hidden w-full">
                <!-- 滚动内容 -->
                <div class="flex items-center" :class="needsScroll ? 'animate-scroll' : ''" :style="needsScroll ? { animationDuration: `${scrollDuration}s` } : {}">
                  <!-- 第一份内容 -->
                  <div class="flex items-center space-x-3 text-gray-800 dark:text-gray-200 whitespace-nowrap px-4 flex-shrink-0">
                    <!-- 图标 -->
                    <div class="flex-shrink-0 flex items-center justify-center w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 shadow-sm">
                      <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"></path>
                      </svg>
                    </div>
                    <!-- 文字内容 -->
                    <div class="flex items-center space-x-2.5">
                      <span class="text-xs font-semibold text-blue-600 uppercase tracking-wider">系统广播</span>
                      <span class="w-1 h-1 rounded-full bg-gray-400"></span>
                      <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ broadcastMessage }}</span>
                    </div>
                  </div>
                  <!-- 重复显示以实现无缝循环 - 仅在需要滚动时显示 -->
                  <div v-if="needsScroll" class="flex items-center space-x-3 text-gray-800 whitespace-nowrap px-4 flex-shrink-0">
                    <!-- 图标 -->
                    <div class="flex-shrink-0 flex items-center justify-center w-8 h-8 rounded-lg bg-gradient-to-br from-blue-500 to-indigo-600 shadow-sm">
                      <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"></path>
                      </svg>
                    </div>
                    <!-- 文字内容 -->
                    <div class="flex items-center space-x-2.5">
                      <span class="text-xs font-semibold text-blue-600 uppercase tracking-wider">系统广播</span>
                      <span class="w-1 h-1 rounded-full bg-gray-400"></span>
                      <span class="text-sm font-medium text-gray-700 dark:text-gray-300">{{ broadcastMessage }}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 顶部装饰线 -->
            <div class="absolute top-0 left-0 right-0 h-0.5 bg-gradient-to-r from-blue-400 via-indigo-400 to-purple-400 opacity-60"></div>
          </div>
        </div>

        <!-- 邮件管理内容区域 -->
        <!-- 服务状态警告 -->
        <div v-if="showServiceWarning" class="mb-6 bg-yellow-50 dark:bg-yellow-900/30 border border-yellow-200 dark:border-yellow-600 rounded-lg p-4">
            <div class="flex items-start">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-yellow-400 dark:text-yellow-500" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
                </svg>
              </div>
              <div class="ml-3 flex-1">
                <h3 class="text-sm font-medium text-yellow-800 dark:text-yellow-200">
                  邮件系统未完全配置
                </h3>
                <div class="mt-2 text-sm text-yellow-700 dark:text-yellow-300">
                  <p>在使用邮件功能之前，请确保以下服务已正确配置：</p>
                  
                  <!-- 服务状态列表 -->
                  <div class="mt-3 space-y-3">
                    <div class="flex items-start">
                      <div :class="['w-2 h-2 rounded-full mr-3 mt-2', serviceStatus.services.postfix ? 'bg-green-400' : 'bg-red-400']"></div>
                      <div class="flex-1">
                        <div class="flex items-center">
                          <span class="text-sm font-medium text-yellow-900 dark:text-yellow-100">Postfix (邮件发送服务)</span>
                          <span v-if="!serviceStatus.services.postfix" class="ml-2 text-xs text-red-600 dark:text-red-400 font-medium">未运行</span>
                          <span v-else class="ml-2 text-xs text-green-600 dark:text-green-400 font-medium">运行中</span>
                        </div>
                        <p v-if="!serviceStatus.services.postfix" class="text-xs text-red-600 dark:text-red-400 mt-1">
                          可能原因：服务未安装、未启动或配置错误。请检查服务状态或重新安装配置。
                        </p>
                      </div>
                    </div>
                    
                    <div class="flex items-start">
                      <div :class="['w-2 h-2 rounded-full mr-3 mt-2', serviceStatus.services.dovecot ? 'bg-green-400' : 'bg-red-400']"></div>
                      <div class="flex-1">
                        <div class="flex items-center">
                          <span class="text-sm font-medium text-yellow-900 dark:text-yellow-100">Dovecot (邮件接收服务)</span>
                          <span v-if="!serviceStatus.services.dovecot" class="ml-2 text-xs text-red-600 dark:text-red-400 font-medium">未运行</span>
                          <span v-else class="ml-2 text-xs text-green-600 dark:text-green-400 font-medium">运行中</span>
                        </div>
                        <p v-if="!serviceStatus.services.dovecot" class="text-xs text-red-600 dark:text-red-400 mt-1">
                          可能原因：服务未安装、未启动或配置错误。请检查服务状态或重新安装配置。
                        </p>
                      </div>
                    </div>
                    
                    <div class="flex items-start">
                      <div :class="['w-2 h-2 rounded-full mr-3 mt-2', getDnsServiceStatus() ? 'bg-green-400' : 'bg-red-400']"></div>
                      <div class="flex-1">
                        <div class="flex items-center">
                          <span class="text-sm font-medium text-yellow-900 dark:text-yellow-100">{{ getDnsServiceName() }}</span>
                          <span v-if="!getDnsServiceStatus()" class="ml-2 text-xs text-red-600 dark:text-red-400 font-medium">未运行</span>
                          <span v-else class="ml-2 text-xs text-green-600 dark:text-green-400 font-medium">运行中</span>
                        </div>
                        <p v-if="!getDnsServiceStatus()" class="text-xs text-red-600 dark:text-red-400 mt-1">
                          {{ getDnsServiceErrorMessage() }}
                        </p>
                      </div>
                    </div>
                    
                    <div class="flex items-start">
                      <div :class="['w-2 h-2 rounded-full mr-3 mt-2', serviceStatus.services.mariadb ? 'bg-green-400' : 'bg-red-400']"></div>
                      <div class="flex-1">
                        <div class="flex items-center">
                          <span class="text-sm font-medium text-yellow-900 dark:text-yellow-100">MariaDB (数据库服务)</span>
                          <span v-if="!serviceStatus.services.mariadb" class="ml-2 text-xs text-red-600 dark:text-red-400 font-medium">未运行</span>
                          <span v-else class="ml-2 text-xs text-green-600 dark:text-green-400 font-medium">运行中</span>
                        </div>
                        <p v-if="!serviceStatus.services.mariadb" class="text-xs text-red-600 dark:text-red-400 mt-1">
                          可能原因：服务未安装、未启动或配置错误。请检查服务状态或重新安装配置。
                        </p>
                      </div>
                    </div>
                    
                    <div class="flex items-start">
                      <div :class="['w-2 h-2 rounded-full mr-3 mt-2', serviceStatus.dns.dns_configured ? 'bg-green-400' : 'bg-red-400']"></div>
                      <div class="flex-1">
                        <div class="flex items-center">
                          <span class="text-sm font-medium text-yellow-900 dark:text-yellow-100">DNS解析配置{{ serviceStatus.dns?.dns_type === 'public' ? '（公网）' : '' }}</span>
                          <span v-if="!serviceStatus.dns.dns_configured" class="ml-2 text-xs text-red-600 dark:text-red-400 font-medium">未配置</span>
                          <span v-else class="ml-2 text-xs text-green-600 dark:text-green-400 font-medium">已配置</span>
                        </div>
                        <p v-if="!serviceStatus.dns.dns_configured" class="text-xs text-red-600 dark:text-red-400 mt-1">
                          <template v-if="serviceStatus.dns?.dns_type === 'public'">
                            请确保域名 {{ serviceStatus.dns?.domain || serviceStatus.dns?.mail_domain || 'your-domain.com' }} 已在公网DNS配置 A 记录、MX 记录等。
                          </template>
                          <template v-else>
                            需要配置域名解析记录，包括A记录、MX记录等。请在系统设置中配置DNS。
                          </template>
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
                  
                  <!-- 建议操作 -->
                  <div v-if="serviceStatus.recommendations.length > 0" class="mt-4">
                    <p class="text-sm font-medium text-yellow-800 dark:text-yellow-200 mb-2">系统建议：</p>
                    <ul class="list-disc list-inside space-y-1 text-sm text-yellow-700 dark:text-yellow-300">
                      <li v-for="rec in serviceStatus.recommendations" :key="rec.type">
                        {{ rec.message }}
                      </li>
                    </ul>
                  </div>
                  
                  <!-- 操作按钮 -->
                  <div class="mt-4 flex space-x-3">
                    <button @click="checkServiceStatus" 
                            :disabled="serviceCheckLoading"
                            class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-yellow-700 dark:text-yellow-200 bg-yellow-100 dark:bg-yellow-800/50 hover:bg-yellow-200 dark:hover:bg-yellow-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500 dark:focus:ring-offset-gray-900 disabled:opacity-50">
                      <svg v-if="serviceCheckLoading" class="animate-spin -ml-1 mr-2 h-4 w-4 text-yellow-500" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      <svg v-else class="-ml-1 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                      </svg>
                      {{ serviceCheckLoading ? '检查中...' : '重新检查' }}
                    </button>
                    <router-link to="/dashboard" 
                                 class="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 dark:focus:ring-offset-gray-900">
                      <svg class="-ml-1 mr-2 h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0l1.83 7.5a2.25 2.25 0 01-2.15 2.75H9.5a2.25 2.25 0 01-2.15-2.75l1.83-7.5zM6 9a2.25 2.25 0 012.25-2.25H9.5a2.25 2.25 0 012.25 2.25v6a2.25 2.25 0 01-2.25 2.25H8.25A2.25 2.25 0 016 15V9z"></path>
                      </svg>
                      前往系统配置
                    </router-link>
                  </div>
                </div>
              </div>
            </div>
        </div>

        <!-- 邮件文件夹侧边栏 - 重新设计 -->
        <div class="flex flex-col sm:flex-row gap-4 sm:gap-6 mb-4 sm:mb-8">
          <!-- 左侧文件夹导航栏 - 手机端可折叠 -->
          <div class="w-full sm:w-64 flex-shrink-0 order-2 sm:order-1">
          <div class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md rounded-2xl shadow-xl border border-gray-100/50 dark:border-gray-600 p-5 space-y-2">
            <!-- 写邮件按钮 - 突出显示 -->
            <button @click="() => { userLogger.logButtonClick('写邮件', isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); goto('compose') }" 
                    :class="['w-full group relative overflow-hidden px-5 py-4 rounded-xl font-bold text-sm transition-all duration-500 transform hover:scale-[1.03] focus:outline-none focus:ring-2 focus:ring-offset-2', 
                             view === 'compose' 
                               ? 'bg-gradient-to-r from-purple-600 via-purple-500 to-indigo-600 text-white shadow-xl shadow-purple-500/40 scale-[1.02]' 
                               : 'bg-gradient-to-r from-purple-500 to-indigo-500 text-white shadow-lg hover:shadow-xl hover:from-purple-600 hover:to-indigo-600']">
              <div class="relative z-10 flex items-center justify-center space-x-2">
                <svg class="w-5 h-5 transition-transform duration-500 group-hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                </svg>
                <span class="relative">写邮件</span>
              </div>
              <div v-if="view === 'compose'" class="absolute inset-0 bg-white/20 animate-pulse"></div>
              <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 -translate-x-full group-hover:translate-x-full"></div>
            </button>

            <!-- 分隔线 -->
            <div class="h-px bg-gradient-to-r from-transparent via-gray-200 dark:via-gray-600 to-transparent my-3"></div>

            <!-- 系统文件夹列表 -->
            <div class="space-y-1">
              <!-- 收件箱 -->
              <button @click="() => { userLogger.logButtonClick('收件箱', isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); goto('inbox') }" 
                      :class="['w-full group relative px-4 py-3.5 rounded-xl font-semibold text-sm transition-all duration-300 flex items-center justify-between overflow-hidden', 
                               view === 'inbox' 
                                 ? 'bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/40 dark:to-indigo-900/40 text-blue-700 dark:text-blue-300 shadow-md border-l-4 border-blue-500 dark:border-blue-400 scale-[1.02]' 
                                 : 'text-gray-700 dark:text-gray-300 hover:bg-gradient-to-r hover:from-gray-50 hover:to-blue-50/30 dark:hover:from-gray-700 dark:hover:to-blue-900/30 hover:text-gray-900 dark:hover:text-gray-100 hover:shadow-sm']">
                <div class="flex items-center space-x-3 flex-1 min-w-0 relative z-10">
                  <div :class="['p-2.5 rounded-lg transition-all duration-300', view === 'inbox' ? 'bg-blue-100 dark:bg-blue-900/50 shadow-sm' : 'bg-gray-100 dark:bg-gray-700 group-hover:bg-blue-100 dark:group-hover:bg-blue-900/50']">
                    <svg class="w-5 h-5 transition-transform duration-300 group-hover:scale-110" :class="view === 'inbox' ? 'text-blue-600 dark:text-blue-400' : 'text-gray-600 dark:text-gray-400 group-hover:text-blue-600 dark:group-hover:text-blue-400'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                  </div>
                  <span class="flex-1 text-left truncate">收件箱</span>
                </div>
                <span class="ml-2 inline-flex items-center justify-center min-w-[28px] h-7 px-2.5 text-xs font-bold rounded-full shadow-sm transition-all duration-300 transform hover:scale-110"
                      :class="unreadCount > 0 
                        ? 'text-white bg-gradient-to-r from-red-500 to-pink-500 shadow-lg shadow-red-500/30 animate-pulse' 
                        : 'text-gray-500 dark:text-gray-400 bg-gray-200 dark:bg-gray-600'">
                  {{ unreadCount }}
                </span>
                <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/30 dark:via-white/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 -translate-x-full group-hover:translate-x-full"></div>
              </button>

              <!-- 已发送 -->
              <button @click="() => { userLogger.logButtonClick('已发送', isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); goto('sent') }" 
                      :class="['w-full group relative px-4 py-3 rounded-xl font-medium text-sm transition-all duration-200 flex items-center justify-between', 
                               view === 'sent' 
                                 ? 'bg-green-50 dark:bg-green-900/40 text-green-700 dark:text-green-300 shadow-sm border-l-4 border-green-500 dark:border-green-400' 
                                 : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100']">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                  <div :class="['p-2 rounded-lg transition-colors', view === 'sent' ? 'bg-green-100 dark:bg-green-900/50' : 'bg-gray-100 dark:bg-gray-700 group-hover:bg-gray-200 dark:group-hover:bg-gray-600']">
                    <svg class="w-5 h-5" :class="view === 'sent' ? 'text-green-600 dark:text-green-400' : 'text-gray-600 dark:text-gray-400'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                    </svg>
                  </div>
                  <span class="flex-1 text-left truncate">已发送</span>
                </div>
              </button>

              <!-- 草稿箱 -->
              <button @click="() => { userLogger.logButtonClick('草稿箱', isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); goto('drafts') }" 
                      :class="['w-full group relative px-4 py-3 rounded-xl font-medium text-sm transition-all duration-200 flex items-center justify-between', 
                               view === 'drafts' 
                                 ? 'bg-yellow-50 dark:bg-yellow-900/40 text-yellow-700 dark:text-yellow-300 shadow-sm border-l-4 border-yellow-500 dark:border-yellow-400' 
                                 : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100']">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                  <div :class="['p-2 rounded-lg transition-colors', view === 'drafts' ? 'bg-yellow-100 dark:bg-yellow-900/50' : 'bg-gray-100 dark:bg-gray-700 group-hover:bg-gray-200 dark:group-hover:bg-gray-600']">
                    <svg class="w-5 h-5" :class="view === 'drafts' ? 'text-yellow-600 dark:text-yellow-400' : 'text-gray-600 dark:text-gray-400'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                  </div>
                  <span class="flex-1 text-left truncate">草稿箱</span>
                </div>
              </button>

              <!-- 垃圾邮件 -->
              <button @click="() => { userLogger.logButtonClick('垃圾邮件', isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); goto('spam') }" 
                      :class="['w-full group relative px-4 py-3 rounded-xl font-medium text-sm transition-all duration-200 flex items-center justify-between', 
                               view === 'spam' 
                                 ? 'bg-red-50 dark:bg-red-900/40 text-red-700 dark:text-red-300 shadow-sm border-l-4 border-red-500 dark:border-red-400' 
                                 : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100']">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                  <div :class="['p-2 rounded-lg transition-colors', view === 'spam' ? 'bg-red-100 dark:bg-red-900/50' : 'bg-gray-100 dark:bg-gray-700 group-hover:bg-gray-200 dark:group-hover:bg-gray-600']">
                    <svg class="w-5 h-5" :class="view === 'spam' ? 'text-red-600 dark:text-red-400' : 'text-gray-600 dark:text-gray-400'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                    </svg>
                  </div>
                  <span class="flex-1 text-left truncate">垃圾邮件</span>
                </div>
              </button>

              <!-- 已删除 -->
              <button @click="() => { userLogger.logButtonClick('已删除', isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); goto('trash') }" 
                      :class="['w-full group relative px-4 py-3 rounded-xl font-medium text-sm transition-all duration-200 flex items-center justify-between', 
                               view === 'trash' 
                                 ? 'bg-gray-50 dark:bg-gray-700 text-gray-700 dark:text-gray-300 shadow-sm border-l-4 border-gray-500 dark:border-gray-400' 
                                 : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100']">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                  <div :class="['p-2 rounded-lg transition-colors', view === 'trash' ? 'bg-gray-100 dark:bg-gray-600' : 'bg-gray-100 dark:bg-gray-700 group-hover:bg-gray-200 dark:group-hover:bg-gray-600']">
                    <svg class="w-5 h-5 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </div>
                  <span class="flex-1 text-left truncate">已删除</span>
                </div>
              </button>
            </div>

            <!-- 自定义文件夹分隔线 -->
            <div v-if="customFoldersList.length > 0" class="h-px bg-gradient-to-r from-transparent via-gray-200 dark:via-gray-600 to-transparent my-3"></div>

            <!-- 自定义文件夹列表 -->
            <div v-if="customFoldersList.length > 0" class="space-y-1">
              <div class="px-4 py-2">
                <span class="text-xs font-semibold text-gray-400 dark:text-gray-500 uppercase tracking-wider">自定义文件夹</span>
              </div>
              <button v-for="folder in customFoldersList" 
                      :key="folder.id"
                      @click="() => { userLogger.logButtonClick(folder.display_name || folder.name, isAdmin ? '管理员邮件面板' : '普通用户邮件面板'); gotoCustomFolder(folder.name) }" 
                      :class="['w-full group relative px-4 py-2.5 rounded-lg font-medium text-sm transition-all duration-200 flex items-center justify-between', 
                               currentCustomFolder === folder.name
                                 ? 'bg-indigo-50 dark:bg-indigo-900/40 text-indigo-700 dark:text-indigo-300 shadow-sm border-l-4 border-indigo-500 dark:border-indigo-400' 
                                 : 'text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 hover:text-gray-900 dark:hover:text-gray-100']">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                  <div :class="['p-1.5 rounded-md transition-colors', currentCustomFolder === folder.name ? 'bg-indigo-100 dark:bg-indigo-900/50' : 'bg-gray-100 dark:bg-gray-700 group-hover:bg-gray-200 dark:group-hover:bg-gray-600']">
                    <svg class="w-4 h-4" :class="currentCustomFolder === folder.name ? 'text-indigo-600 dark:text-indigo-400' : 'text-gray-600 dark:text-gray-400'" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
                    </svg>
                  </div>
                  <span class="flex-1 text-left truncate text-sm">{{ folder.display_name || folder.name }}</span>
                </div>
                <div class="flex items-center space-x-1 ml-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button @click.stop="editCustomFolder(folder)" 
                          class="p-1 rounded-md hover:bg-gray-200 dark:hover:bg-gray-600 transition-colors"
                          title="重命名">
                    <svg class="w-3.5 h-3.5 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                  </button>
                  <button @click.stop="deleteCustomFolder(folder)" 
                          class="p-1 rounded-md hover:bg-red-100 dark:hover:bg-red-900/30 transition-colors"
                          title="删除">
                    <svg class="w-3.5 h-3.5 text-gray-500 dark:text-gray-400 hover:text-red-600 dark:hover:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </button>
                </div>
              </button>
            </div>

            <!-- 管理文件夹按钮 -->
            <div class="pt-2">
              <button @click="() => { showFolderManageDialog = true; loadFolders() }" 
                      class="w-full px-4 py-2.5 rounded-lg font-medium text-sm transition-all duration-200 flex items-center justify-center space-x-2 text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300 hover:bg-indigo-50 dark:hover:bg-indigo-900/30 border border-indigo-200 dark:border-indigo-600 hover:border-indigo-300 dark:hover:border-indigo-500">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                </svg>
                <span>管理文件夹</span>
              </button>
            </div>
          </div>
          </div>

          <!-- 右侧主内容区域 -->
          <div class="flex-1 min-w-0 order-1 sm:order-2">
          <!-- 收件箱 -->
          <div v-if="view==='inbox'" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
            <div class="p-3 sm:p-6 border-b border-gray-200/50 dark:border-gray-600 bg-gradient-to-r from-blue-50/80 via-indigo-50/80 to-purple-50/80 dark:from-gray-700/80 dark:via-gray-700/80 dark:to-gray-700/80 backdrop-blur-sm">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                <h2 class="text-xl sm:text-2xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
                  <div class="p-2 sm:p-2.5 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-xl shadow-lg mr-2 sm:mr-3">
                    <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                  </div>
                  <span class="bg-gradient-to-r from-blue-700 to-indigo-700 dark:from-blue-300 dark:to-indigo-300 bg-clip-text text-transparent">收件箱</span>
                  <span class="ml-2 text-base sm:text-lg font-medium text-gray-500 dark:text-gray-400">共 {{ mailStats.inbox?.total ?? 0 }} 封</span>
                </h2>
                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 w-full sm:w-auto">
                  <!-- 搜索框 -->
                  <div class="relative flex-1 sm:flex-none">
                    <input 
                      v-model="searchQuery" 
                      @keyup.enter="searchEmails"
                      @input="onSearchInput"
                      type="text" 
                      placeholder="搜索邮件内容..." 
                      class="pl-10 pr-4 py-2 sm:py-2.5 text-sm border-2 border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-300 dark:focus:border-blue-500 transition-all duration-200 w-full sm:w-64 bg-white/90 dark:bg-gray-700/90 backdrop-blur-sm"
                    >
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <button 
                      v-if="searchQuery" 
                      @click="clearSearch"
                      class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                  <button 
                    @click="searchEmails" 
                    :disabled="!searchQuery || searchLoading"
                    class="inline-flex items-center justify-center px-4 sm:px-5 py-2 sm:py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-blue-500 to-indigo-600 rounded-xl hover:from-blue-600 hover:to-indigo-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105"
                  >
                    <svg v-if="!searchLoading" class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <svg v-else class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span class="hidden sm:inline">{{ searchLoading ? '搜索中...' : '搜索' }}</span>
                    <span class="sm:hidden">{{ searchLoading ? '...' : '搜索' }}</span>
                  </button>
                  <button @click="loadEmails('inbox')" class="inline-flex items-center justify-center px-4 sm:px-5 py-2 sm:py-2.5 text-sm font-semibold text-blue-700 dark:text-blue-300 bg-white/90 dark:bg-gray-700/90 backdrop-blur-sm border-2 border-blue-200 dark:border-blue-600 rounded-xl hover:bg-blue-50 dark:hover:bg-blue-900/30 hover:border-blue-300 dark:hover:border-blue-500 hover:shadow-lg transition-all duration-300 shadow-md hover:scale-105">
                    <svg class="h-4 w-4 mr-2 transition-transform duration-300 hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    刷新
                  </button>
                </div>
              </div>
            </div>
            
            <div v-if="emailsLoading" class="p-16 text-center">
              <div class="inline-block">
                <svg class="animate-spin h-14 w-14 text-blue-600 dark:text-blue-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-gray-600 dark:text-gray-400 font-semibold text-lg">加载邮件中...</p>
              </div>
            </div>
            
            <div v-else-if="emails.length === 0" class="p-16 text-center">
              <div class="inline-block animate-fade-in">
                <div class="p-4 bg-gradient-to-br from-blue-100 to-indigo-100 dark:from-blue-900/40 dark:to-indigo-900/40 rounded-2xl inline-block mb-4">
                  <svg class="h-20 w-20 text-blue-400 dark:text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                  </svg>
                </div>
                <p class="text-gray-600 dark:text-gray-300 text-xl font-semibold mb-2">收件箱为空</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm">还没有收到任何邮件</p>
              </div>
            </div>
            
            <div v-else class="space-y-3 sm:space-y-4 p-3 sm:p-6">
              <transition-group name="email-list" tag="div">
                <div v-for="(email, index) in paginatedEmails" :key="email.id"
                     @click="openEmail(email)"
                     :style="{ 'animation-delay': `${index * 50}ms` }"
                     class="email-item group cursor-pointer transition-all duration-300 ease-out relative overflow-hidden rounded-xl sm:rounded-2xl border"
                     :class="{
                       'bg-gradient-to-br from-blue-50 via-indigo-50/80 to-purple-50/80 dark:from-blue-900/30 dark:via-indigo-900/30 dark:to-purple-900/30 border-blue-300 dark:border-blue-500 shadow-xl shadow-blue-500/20 scale-[1.01]': selectedEmail?.id === email.id,
                       'bg-white dark:bg-gray-700/80 border-gray-200 dark:border-gray-600 hover:border-blue-300 dark:hover:border-blue-500 hover:bg-gradient-to-br hover:from-gray-50/50 hover:to-blue-50/30 dark:hover:from-gray-700 dark:hover:to-blue-900/20 hover:shadow-lg hover:scale-[1.005]': selectedEmail?.id !== email.id
                     }">
                  <!-- 选中指示器 -->
                  <div v-if="selectedEmail?.id === email.id" class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-blue-500 to-indigo-600"></div>
                  
                  <!-- 未读邮件指示器 -->
                  <div v-if="isUnread(email)" class="absolute top-3 sm:top-4 right-3 sm:right-4">
                    <div class="w-2 sm:w-2.5 h-2 sm:h-2.5 bg-blue-500 rounded-full animate-pulse shadow-md ring-2 ring-blue-200"></div>
                  </div>
                  
                  <div class="p-3 sm:p-5">
                    <div class="flex items-start justify-between gap-2 sm:gap-4">
                      <div class="flex-1 min-w-0">
                        <!-- 发件人信息 -->
                        <div class="flex items-center flex-wrap gap-1.5 sm:gap-2 mb-2 sm:mb-3">
                          <div class="flex items-center space-x-1 sm:space-x-2">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 text-blue-600 dark:text-blue-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                            </svg>
                            <span class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide hidden sm:inline">发件人</span>
                          </div>
                          <p class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white truncate flex-1 min-w-0">{{ email.from }}</p>
                          <span v-if="isSystemNotification(email.from)" class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-yellow-700 dark:text-yellow-200 bg-yellow-100 dark:bg-yellow-900/50 border border-yellow-200 dark:border-yellow-700 rounded-lg">
                            <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                            </svg>
                            系统通知
                          </span>
                          <span v-else-if="isAdminSender(email.from)" class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-red-700 dark:text-red-200 bg-red-100 dark:bg-red-900/50 border border-red-200 dark:border-red-700 rounded-lg">系统管理员</span>
                          <span v-if="isCurrentUserCC(email)" class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-emerald-700 dark:text-emerald-200 bg-emerald-100 dark:bg-emerald-900/50 border border-emerald-200 dark:border-emerald-700 rounded-lg">
                            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                            抄送
                          </span>
                        </div>
                        
                        <!-- 邮件主题 -->
                        <h3 class="text-sm sm:text-base font-bold text-gray-900 dark:text-white mb-2 sm:mb-3 line-clamp-2 group-hover:text-blue-700 dark:group-hover:text-blue-300 transition-colors">
                          {{ email.subject || '(无主题)' }}
                        </h3>
                        
                        <!-- 底部信息栏 -->
                        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 sm:gap-0 pt-2 sm:pt-3 border-t border-gray-100 dark:border-gray-600">
                          <div class="flex items-center space-x-2 sm:space-x-3">
                            <span class="text-xs text-gray-500 dark:text-gray-300 font-medium">
                              <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                              </svg>
                              {{ formatDate(email.date) }}
                            </span>
                          </div>
                          <div class="flex items-center space-x-2">
                            <span v-if="isUnread(email)" class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-semibold text-blue-700 dark:text-blue-200 bg-blue-50 dark:bg-blue-900/50 border border-blue-200 dark:border-blue-700 rounded-lg">
                              <div class="w-1.5 h-1.5 bg-blue-500 rounded-full mr-1 sm:mr-1.5 animate-pulse"></div>
                              <span class="hidden sm:inline">新邮件</span>
                              <span class="sm:hidden">新</span>
                            </span>
                            <span v-else class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-medium text-gray-500 dark:text-gray-300 bg-gray-50 dark:bg-gray-600/80 border border-gray-200 dark:border-gray-500 rounded-lg">
                              <svg class="w-3 h-3 mr-1 sm:mr-1.5 text-gray-400 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                              </svg>
                              <span class="hidden sm:inline">已读</span>
                            </span>
                          </div>
                        </div>
                      </div>
                      
                      <!-- 操作按钮 - 手机端始终显示 -->
                      <div class="flex items-center space-x-1 sm:space-x-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-300 flex-shrink-0" @click.stop>
                        <!-- 快速操作：移动到文件夹 -->
                        <div class="relative move-button-group inline-block" @click.stop>
                          <button @click.stop class="inline-flex items-center px-2 sm:px-3 py-1.5 sm:py-2 text-xs font-medium text-gray-700 dark:text-gray-200 bg-white/90 dark:bg-gray-600/90 backdrop-blur-sm border border-gray-300 dark:border-gray-500 rounded-lg hover:bg-blue-50 dark:hover:bg-blue-900/40 hover:border-blue-300 dark:hover:border-blue-600 hover:text-blue-700 dark:hover:text-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 sm:mr-1.5 text-gray-500 dark:text-gray-400 move-button-group-hover:text-blue-600 dark:move-button-group-hover:text-blue-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                            </svg>
                            <span class="hidden sm:inline">移动</span>
                          </button>
                          <div class="absolute right-0 top-full mt-2 w-48 bg-white/95 dark:bg-gray-800/95 backdrop-blur-md rounded-xl shadow-xl border border-gray-200/50 dark:border-gray-600 opacity-0 invisible move-button-group-hover:opacity-100 move-button-group-hover:visible transition-all duration-300 z-50 transform translate-y-2 move-button-group-hover:translate-y-0" @click.stop>
                            <div class="py-2">
                              <button v-for="folder in getAvailableFolders(email.folder || 'inbox', email)" 
                                      :key="folder.value"
                                      @click.stop="moveEmailToFolder(email.id, folder.value)"
                                      class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-gradient-to-r hover:from-blue-50 hover:to-indigo-50 dark:hover:from-blue-900/40 dark:hover:to-indigo-900/40 hover:text-blue-700 dark:hover:text-blue-300 flex items-center transition-all duration-200 rounded-lg mx-1">
                                <svg class="w-4 h-4 mr-2 text-gray-400 dark:text-gray-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="getFolderIcon(folder.value)"></path>
                                </svg>
                                {{ folder.label }}
                              </button>
                            </div>
                          </div>
                        </div>
                        
                        <button @click.stop="showDeleteConfirmDialog(email.id)" 
                                class="inline-flex items-center justify-center px-2 sm:px-3 py-1.5 sm:py-2 text-xs font-medium text-red-600 dark:text-red-300 bg-red-50/90 dark:bg-red-900/40 backdrop-blur-sm border border-red-200 dark:border-red-700 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/60 hover:border-red-300 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                          <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 transition-transform duration-300 hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </transition-group>
          
          <!-- 分页组件 -->
          <div v-if="totalPages > 1" class="mt-4 sm:mt-8 flex flex-col sm:flex-row items-center justify-between gap-3 sm:gap-0 border-t border-gray-200/50 pt-4 sm:pt-6">
            <div class="flex items-center text-xs sm:text-sm text-gray-600">
              <span class="font-medium">显示第 <span class="text-blue-600 font-semibold">{{ startIndex + 1 }}</span>-<span class="text-blue-600 font-semibold">{{ endIndex }}</span> 条，共 <span class="text-blue-600 font-semibold">{{ totalEmails }}</span> 条</span>
            </div>
            <div class="flex items-center space-x-1 sm:space-x-2">
              <button @click="goToPage(currentPage - 1)" 
                      :disabled="currentPage <= 1"
                      class="px-3 sm:px-4 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gradient-to-r hover:from-blue-50 hover:to-indigo-50 hover:text-blue-600 hover:border-blue-300 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-sm hover:shadow-md disabled:hover:shadow-sm">
                上一页
              </button>
              
              <div class="flex space-x-1">
                <button v-for="page in visiblePages" :key="page"
                        @click="goToPage(page)"
                        :class="{
                          'bg-gradient-to-r from-blue-600 to-indigo-600 text-white shadow-lg shadow-blue-500/30 scale-105': page === currentPage,
                          'bg-white text-gray-700 hover:bg-gradient-to-r hover:from-gray-50 hover:to-blue-50/30 hover:text-blue-600 hover:border-blue-300': page !== currentPage
                        }"
                        class="px-3 sm:px-4 py-1.5 sm:py-2 text-xs sm:text-sm font-medium border border-gray-300 rounded-lg transition-all duration-300 hover:shadow-md">
                  {{ page }}
                </button>
              </div>
              
              <button @click="goToPage(currentPage + 1)" 
                      :disabled="currentPage >= totalPages"
                      class="px-3 sm:px-4 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-gray-600 bg-white border border-gray-300 rounded-lg hover:bg-gradient-to-r hover:from-blue-50 hover:to-indigo-50 hover:text-blue-600 hover:border-blue-300 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-sm hover:shadow-md disabled:hover:shadow-sm">
                下一页
              </button>
            </div>
          </div>
          </div>
          </div>
          <div v-else-if="view==='sent'" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
            <!-- 已发送 -->
            <div class="p-3 sm:p-6 border-b border-gray-200/50 dark:border-gray-600 bg-gradient-to-r from-emerald-50/80 via-green-50/80 to-teal-50/80 dark:from-gray-700/80 dark:via-gray-700/80 dark:to-gray-700/80 backdrop-blur-sm">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                <h2 class="text-xl sm:text-2xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
                  <div class="p-2 sm:p-2.5 bg-gradient-to-br from-emerald-500 to-green-600 rounded-xl shadow-lg mr-2 sm:mr-3">
                    <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                    </svg>
                  </div>
                  <span class="bg-gradient-to-r from-emerald-700 to-green-700 dark:from-emerald-300 dark:to-green-300 bg-clip-text text-transparent">已发送</span>
                  <span class="ml-2 text-base sm:text-lg font-medium text-gray-500 dark:text-gray-400">共 {{ mailStats.sent?.total ?? 0 }} 封</span>
                </h2>
                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 w-full sm:w-auto">
                  <!-- 搜索框 -->
                  <div class="relative flex-1 sm:flex-none">
                    <input 
                      v-model="searchQuery" 
                      @keyup.enter="searchEmails"
                      @input="onSearchInput"
                      type="text" 
                      placeholder="搜索邮件内容..." 
                      class="pl-10 pr-4 py-2 sm:py-2.5 text-sm border-2 border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-300 dark:focus:border-emerald-500 transition-all duration-200 w-full sm:w-64 bg-white/90 dark:bg-gray-700/90 backdrop-blur-sm"
                    >
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <button 
                      v-if="searchQuery" 
                      @click="clearSearch"
                      class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                  <button 
                    @click="searchEmails" 
                    :disabled="!searchQuery || searchLoading"
                    class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-emerald-500 to-green-600 rounded-xl hover:from-emerald-600 hover:to-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105"
                  >
                    <svg v-if="!searchLoading" class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <svg v-else class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ searchLoading ? '搜索中...' : '搜索' }}
                  </button>
                  <button @click="loadEmails('sent')" class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-emerald-700 bg-white/90 backdrop-blur-sm border-2 border-emerald-200 rounded-xl hover:bg-emerald-50 hover:border-emerald-300 hover:shadow-lg transition-all duration-300 shadow-md hover:scale-105">
                    <svg class="h-4 w-4 mr-2 transition-transform duration-300 hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    刷新
                  </button>
                </div>
              </div>
            </div>
            
            <div v-if="emailsLoading" class="p-16 text-center">
              <div class="inline-block">
                <svg class="animate-spin h-14 w-14 text-emerald-600 dark:text-emerald-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">加载邮件中...</p>
              </div>
            </div>
            
            <div v-else-if="emails.length === 0" class="p-16 text-center">
              <div class="inline-block animate-fade-in">
                <div class="p-4 bg-gradient-to-br from-emerald-100 to-green-100 dark:from-emerald-900/40 dark:to-green-900/40 rounded-2xl inline-block mb-4">
                  <svg class="h-20 w-20 text-emerald-400 dark:text-emerald-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                  </svg>
                </div>
                <p class="text-gray-600 dark:text-gray-300 text-xl font-semibold mb-2">已发送为空</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm">还没有发送任何邮件</p>
              </div>
            </div>
            
            <div v-else class="space-y-3 sm:space-y-4 p-3 sm:p-6">
              <transition-group name="email-list" tag="div">
                <div v-for="(email, index) in paginatedEmails" :key="email.id"
                     @click="openEmail(email)"
                     :style="{ 'animation-delay': `${index * 50}ms` }"
                     class="email-item group cursor-pointer transition-all duration-300 ease-out relative overflow-hidden rounded-xl sm:rounded-2xl border"
                     :class="{
                       'bg-gradient-to-br from-emerald-50 via-green-50/80 to-teal-50/80 dark:from-emerald-900/40 dark:via-green-900/40 dark:to-teal-900/40 border-emerald-300 dark:border-emerald-500 shadow-xl shadow-emerald-500/20 scale-[1.01]': selectedEmail?.id === email.id,
                       'bg-white dark:bg-gray-700/80 border-gray-200 dark:border-gray-600 hover:border-emerald-300 dark:hover:border-emerald-500 hover:bg-gradient-to-br hover:from-gray-50/50 hover:to-emerald-50/30 dark:hover:from-gray-700 dark:hover:to-emerald-900/20 hover:shadow-lg hover:scale-[1.005]': selectedEmail?.id !== email.id
                     }">
                  <!-- 选中指示器 -->
                  <div v-if="selectedEmail?.id === email.id" class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-emerald-500 to-green-600"></div>
                  
                  <!-- 未查看邮件指示器 -->
                  <div v-if="isUnread(email)" class="absolute top-4 right-4">
                    <div class="w-2.5 h-2.5 bg-emerald-500 rounded-full animate-pulse shadow-md ring-2 ring-emerald-200"></div>
                  </div>
                  
                  <div class="p-3 sm:p-5">
                    <div class="flex items-start justify-between gap-2 sm:gap-4">
                      <div class="flex-1 min-w-0">
                        <!-- 收件人信息 -->
                        <div class="flex items-center flex-wrap gap-1.5 sm:gap-2 mb-2 sm:mb-3">
                          <div class="flex items-center space-x-1 sm:space-x-2">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 text-emerald-600 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                            </svg>
                            <span class="text-xs font-medium text-gray-500 uppercase tracking-wide hidden sm:inline">收件人</span>
                          </div>
                          <p class="text-xs sm:text-sm font-semibold text-gray-900 truncate flex-1 min-w-0">{{ email.to }}</p>
                          <span v-if="isCurrentUserCC(email)" class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-emerald-700 bg-emerald-100 border border-emerald-200 rounded-lg">
                            <svg class="w-3 h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                            </svg>
                            抄送
                          </span>
                        </div>
                        
                        <!-- 邮件主题 -->
                        <h3 class="text-sm sm:text-base font-bold text-gray-900 dark:text-white mb-2 sm:mb-3 line-clamp-2 group-hover:text-emerald-700 dark:group-hover:text-emerald-300 transition-colors">
                          {{ email.subject || '(无主题)' }}
                        </h3>
                        
                        <!-- 底部信息栏 -->
                        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 sm:gap-0 pt-2 sm:pt-3 border-t border-gray-100 dark:border-gray-600">
                          <div class="flex items-center space-x-2 sm:space-x-3">
                            <span class="text-xs text-gray-500 dark:text-gray-300 font-medium">
                              <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                              </svg>
                              {{ formatDate(email.date) }}
                            </span>
                          </div>
                          <div class="flex items-center space-x-2">
                            <span v-if="isUnread(email)" class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-semibold text-emerald-700 dark:text-emerald-200 bg-emerald-50 dark:bg-emerald-900/50 border border-emerald-200 dark:border-emerald-700 rounded-lg">
                              <div class="w-1.5 h-1.5 bg-emerald-500 rounded-full mr-1 sm:mr-1.5 animate-pulse"></div>
                              <span class="hidden sm:inline">未查看</span>
                              <span class="sm:hidden">新</span>
                            </span>
                            <span v-else class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-medium text-gray-500 dark:text-gray-300 bg-gray-50 dark:bg-gray-600/80 border border-gray-200 dark:border-gray-500 rounded-lg">
                              <svg class="w-3 h-3 mr-1 sm:mr-1.5 text-gray-400 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                              </svg>
                              <span class="hidden sm:inline">已查看</span>
                            </span>
                          </div>
                        </div>
                      </div>
                      
                      <!-- 操作按钮 - 手机端始终显示 -->
                      <div class="flex items-center space-x-1 sm:space-x-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-300 flex-shrink-0" @click.stop>
                        <!-- 快速操作：移动到文件夹 -->
                        <div class="relative move-button-group inline-block" @click.stop>
                          <button @click.stop class="inline-flex items-center px-2 sm:px-3 py-1.5 sm:py-2 text-xs font-medium text-gray-700 dark:text-gray-200 bg-white/90 dark:bg-gray-600/90 backdrop-blur-sm border border-gray-300 dark:border-gray-500 rounded-lg hover:bg-emerald-50 dark:hover:bg-emerald-900/40 hover:border-emerald-300 dark:hover:border-emerald-600 hover:text-emerald-700 dark:hover:text-emerald-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 sm:mr-1.5 text-gray-500 dark:text-gray-400 move-button-group-hover:text-emerald-600 dark:move-button-group-hover:text-emerald-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                            </svg>
                            <span class="hidden sm:inline">移动</span>
                          </button>
                          <div class="absolute right-0 top-full mt-2 w-48 bg-white/95 dark:bg-gray-800/95 backdrop-blur-md rounded-xl shadow-xl border border-gray-200/50 dark:border-gray-600 opacity-0 invisible move-button-group-hover:opacity-100 move-button-group-hover:visible transition-all duration-300 z-50 transform translate-y-2 move-button-group-hover:translate-y-0" @click.stop>
                            <div class="py-2">
                              <button v-for="folder in getAvailableFolders(email.folder || 'sent', email)" 
                                      :key="folder.value"
                                      @click.stop="moveEmailToFolder(email.id, folder.value)"
                                      class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-gradient-to-r hover:from-emerald-50 hover:to-green-50 dark:hover:from-emerald-900/40 dark:hover:to-green-900/40 hover:text-emerald-700 dark:hover:text-emerald-300 flex items-center transition-all duration-200 rounded-lg mx-1">
                                <svg class="w-4 h-4 mr-2 text-gray-400 dark:text-gray-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="getFolderIcon(folder.value)"></path>
                                </svg>
                                {{ folder.label }}
                              </button>
                            </div>
                          </div>
                        </div>
                        
                        <button @click.stop="showDeleteConfirmDialog(email.id)" 
                                class="inline-flex items-center justify-center px-2 sm:px-3 py-1.5 sm:py-2 text-xs font-medium text-red-600 bg-red-50/90 backdrop-blur-sm border border-red-200 rounded-lg hover:bg-red-100 hover:border-red-300 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                          <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 transition-transform duration-300 hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </transition-group>
              
              <!-- 分页组件 -->
              <div v-if="totalPages > 1" class="mt-4 sm:mt-6 flex flex-col sm:flex-row items-center justify-between gap-3 sm:gap-0 border-t border-gray-200 pt-4 px-3 sm:px-5">
                <div class="flex items-center text-xs sm:text-sm text-gray-700">
                  <span>显示第 {{ startIndex + 1 }}-{{ endIndex }} 条，共 {{ totalEmails }} 条</span>
                </div>
                <div class="flex items-center space-x-1 sm:space-x-2">
                  <button @click="goToPage(currentPage - 1)" 
                          :disabled="currentPage <= 1"
                          class="px-3 sm:px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                    上一页
                  </button>
                  
                  <div class="flex space-x-1">
                    <button v-for="page in visiblePages" :key="page"
                            @click="goToPage(page)"
                            :class="{
                              'bg-green-600 text-white': page === currentPage,
                              'bg-white text-gray-700 hover:bg-gray-50': page !== currentPage
                            }"
                            class="px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium border border-gray-300 rounded-md">
                      {{ page }}
                    </button>
                  </div>
                  
                  <button @click="goToPage(currentPage + 1)" 
                          :disabled="currentPage >= totalPages"
                          class="px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                    下一页
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div v-else-if="view==='drafts'" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
            <div class="p-3 sm:p-6 border-b border-gray-200/50 dark:border-gray-600 bg-gradient-to-r from-yellow-50/80 via-amber-50/80 to-orange-50/80 dark:from-gray-700/80 dark:via-gray-700/80 dark:to-gray-700/80 backdrop-blur-sm">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                <h2 class="text-xl sm:text-2xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
                  <div class="p-2 sm:p-2.5 bg-gradient-to-br from-yellow-500 to-amber-600 rounded-xl shadow-lg mr-2 sm:mr-3">
                    <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                  </div>
                  <span class="bg-gradient-to-r from-yellow-700 to-amber-700 dark:from-yellow-300 dark:to-amber-300 bg-clip-text text-transparent">草稿箱</span>
                  <span class="ml-2 text-base sm:text-lg font-medium text-gray-500 dark:text-gray-400">共 {{ mailStats.drafts?.total ?? 0 }} 封</span>
                </h2>
                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 w-full sm:w-auto">
                  <!-- 搜索框 -->
                  <div class="relative flex-1 sm:flex-none">
                    <input 
                      v-model="searchQuery" 
                      @keyup.enter="searchEmails"
                      @input="onSearchInput"
                      type="text" 
                      placeholder="搜索邮件内容..." 
                      class="pl-10 pr-4 py-2 sm:py-2.5 text-sm border-2 border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:border-yellow-300 dark:focus:border-yellow-500 transition-all duration-200 w-full sm:w-64 bg-white/90 dark:bg-gray-700/90 backdrop-blur-sm"
                    >
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <button 
                      v-if="searchQuery" 
                      @click="clearSearch"
                      class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                  <button 
                    @click="searchEmails" 
                    :disabled="!searchQuery || searchLoading"
                    class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-yellow-500 to-amber-600 rounded-xl hover:from-yellow-600 hover:to-amber-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105"
                  >
                    <svg v-if="!searchLoading" class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <svg v-else class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ searchLoading ? '搜索中...' : '搜索' }}
                  </button>
                  <button @click="loadEmails('drafts')" class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-yellow-700 bg-white/90 backdrop-blur-sm border-2 border-yellow-200 rounded-xl hover:bg-yellow-50 hover:border-yellow-300 hover:shadow-lg transition-all duration-300 shadow-md hover:scale-105">
                    <svg class="h-4 w-4 mr-2 transition-transform duration-300 hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    刷新
                  </button>
                </div>
              </div>
            </div>
            
            <div v-if="emailsLoading" class="p-16 text-center">
              <div class="inline-block">
                <svg class="animate-spin h-14 w-14 text-yellow-600 dark:text-yellow-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">加载邮件中...</p>
              </div>
            </div>
            
            <div v-else-if="emails.length === 0" class="p-16 text-center">
              <div class="inline-block animate-fade-in">
                <div class="p-4 bg-gradient-to-br from-yellow-100 to-amber-100 dark:from-yellow-900/40 dark:to-amber-900/40 rounded-2xl inline-block mb-4">
                  <svg class="h-20 w-20 text-yellow-400 dark:text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                  </svg>
                </div>
                <p class="text-gray-600 dark:text-gray-300 text-xl font-semibold mb-2">草稿箱为空</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm">还没有保存任何草稿</p>
              </div>
            </div>
            
            <div v-else class="space-y-3 sm:space-y-4 p-3 sm:p-6">
              <transition-group name="email-list" tag="div">
                <div v-for="(email, index) in paginatedEmails" :key="email.id"
                     @click="editDraft(email)"
                     :style="{ 'animation-delay': `${index * 50}ms` }"
                     class="email-item group cursor-pointer transition-all duration-300 ease-out relative overflow-hidden rounded-xl sm:rounded-2xl border"
                     :class="{
                       'bg-gradient-to-br from-yellow-50 via-amber-50/80 to-orange-50/80 dark:from-yellow-900/40 dark:via-amber-900/40 dark:to-orange-900/40 border-yellow-300 dark:border-yellow-500 shadow-xl shadow-yellow-500/20 scale-[1.01]': selectedEmail?.id === email.id,
                       'bg-white dark:bg-gray-700/80 border-gray-200 dark:border-gray-600 hover:border-yellow-300 dark:hover:border-yellow-500 hover:bg-gradient-to-br hover:from-gray-50/50 hover:to-yellow-50/30 dark:hover:from-gray-700 dark:hover:to-yellow-900/20 hover:shadow-lg hover:scale-[1.005]': selectedEmail?.id !== email.id
                     }">
                  <!-- 选中指示器 -->
                  <div v-if="selectedEmail?.id === email.id" class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-yellow-500 to-amber-600"></div>
                  
                  <div class="p-3 sm:p-5">
                    <div class="flex items-start justify-between gap-2 sm:gap-4">
                      <div class="flex-1 min-w-0">
                        <!-- 收件人信息 -->
                        <div class="flex items-center flex-wrap gap-2 mb-3">
                          <div class="flex items-center space-x-2">
                            <svg class="w-4 h-4 text-yellow-600 dark:text-yellow-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 12a4 4 0 10-8 0 4 4 0 008 0zm0 0v1.5a2.5 2.5 0 005 0V12a9 9 0 10-9 9m4.5-1.206a8.959 8.959 0 01-4.5 1.207"></path>
                            </svg>
                            <span class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">收件人</span>
                          </div>
                          <p class="text-sm font-semibold text-gray-900 dark:text-white">{{ email.to || '未填写' }}</p>
                        </div>
                        
                        <!-- 邮件主题 -->
                        <h3 class="text-sm sm:text-base font-bold text-gray-900 dark:text-white mb-2 sm:mb-3 line-clamp-2 group-hover:text-yellow-700 dark:group-hover:text-yellow-300 transition-colors">
                          {{ email.subject || '(无主题)' }}
                        </h3>
                        
                        <!-- 底部信息栏 -->
                        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 sm:gap-0 pt-2 sm:pt-3 border-t border-gray-100 dark:border-gray-600">
                          <div class="flex items-center space-x-2 sm:space-x-3">
                            <span class="text-xs text-gray-500 dark:text-gray-300 font-medium">
                              <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                              </svg>
                              {{ formatDate(email.date) }}
                            </span>
                          </div>
                          <div class="flex items-center space-x-2">
                            <span class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-medium text-yellow-700 dark:text-yellow-200 bg-yellow-50 dark:bg-yellow-900/50 border border-yellow-200 dark:border-yellow-700 rounded-lg">
                              <svg class="w-3 h-3 mr-1 sm:mr-1.5 text-yellow-500 dark:text-yellow-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                              </svg>
                              <span class="hidden sm:inline">草稿</span>
                              <span class="sm:hidden">草</span>
                            </span>
                          </div>
                        </div>
                      </div>
                      
                      <!-- 操作按钮 - 手机端始终显示 -->
                      <div class="flex items-center space-x-1 sm:space-x-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-300 flex-shrink-0" @click.stop>
                        <button @click.stop="editDraft(email)" 
                                class="inline-flex items-center px-3 py-2 text-xs font-medium text-yellow-700 dark:text-yellow-200 bg-yellow-50/90 dark:bg-yellow-900/40 backdrop-blur-sm border border-yellow-200 dark:border-yellow-700 rounded-lg hover:bg-yellow-100 dark:hover:bg-yellow-900/60 hover:border-yellow-300 focus:outline-none focus:ring-2 focus:ring-yellow-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                          </svg>
                          编辑
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </transition-group>
          
          <!-- 分页组件 -->
          <div v-if="totalPages > 1" class="mt-4 sm:mt-6 flex flex-col sm:flex-row items-center justify-between gap-3 sm:gap-0 border-t border-gray-200 pt-4 px-3 sm:px-5">
            <div class="flex items-center text-xs sm:text-sm text-gray-700">
              <span>显示第 {{ startIndex + 1 }}-{{ endIndex }} 条，共 {{ totalEmails }} 条</span>
            </div>
            <div class="flex items-center space-x-1 sm:space-x-2">
              <button @click="goToPage(currentPage - 1)" 
                      :disabled="currentPage <= 1"
                      class="px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                上一页
              </button>
              
              <div class="flex space-x-1">
                <button v-for="page in visiblePages" :key="page"
                        @click="goToPage(page)"
                        :class="{
                          'bg-yellow-600 text-white': page === currentPage,
                          'bg-white text-gray-700 hover:bg-gray-50': page !== currentPage
                        }"
                        class="px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium border border-gray-300 rounded-md">
                  {{ page }}
                </button>
              </div>
              
              <button @click="goToPage(currentPage + 1)" 
                      :disabled="currentPage >= totalPages"
                      class="px-3 py-1.5 sm:py-2 text-xs sm:text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                下一页
              </button>
            </div>
          </div>
          </div>
          </div>
          <div v-else-if="view==='spam'" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
            <div class="p-3 sm:p-6 border-b border-gray-200/50 dark:border-gray-600 bg-gradient-to-r from-red-50/80 via-pink-50/80 to-rose-50/80 dark:from-gray-700/80 dark:via-gray-700/80 dark:to-gray-700/80 backdrop-blur-sm">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                <h2 class="text-xl sm:text-2xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
                  <div class="p-2 sm:p-2.5 bg-gradient-to-br from-red-500 to-pink-600 rounded-xl shadow-lg mr-2 sm:mr-3">
                    <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                    </svg>
                  </div>
                  <span class="bg-gradient-to-r from-red-700 to-pink-700 dark:from-red-300 dark:to-pink-300 bg-clip-text text-transparent">垃圾邮件</span>
                  <span class="ml-2 text-base sm:text-lg font-medium text-gray-500 dark:text-gray-400">共 {{ mailStats.spam?.total ?? 0 }} 封</span>
                </h2>
                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 w-full sm:w-auto">
                  <!-- 搜索框 -->
                  <div class="relative flex-1 sm:flex-none">
                    <input 
                      v-model="searchQuery" 
                      @keyup.enter="searchEmails"
                      @input="onSearchInput"
                      type="text" 
                      placeholder="搜索邮件内容..." 
                      class="pl-10 pr-4 py-2 sm:py-2.5 text-sm border-2 border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-300 dark:focus:border-red-500 transition-all duration-200 w-full sm:w-64 bg-white/90 dark:bg-gray-700/90 backdrop-blur-sm"
                    >
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <button 
                      v-if="searchQuery" 
                      @click="clearSearch"
                      class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                  <button 
                    @click="searchEmails" 
                    :disabled="!searchQuery || searchLoading"
                    class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-red-500 to-pink-600 rounded-xl hover:from-red-600 hover:to-pink-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105"
                  >
                    <svg v-if="!searchLoading" class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <svg v-else class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ searchLoading ? '搜索中...' : '搜索' }}
                  </button>
                  <button @click="loadEmails('spam')" class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-red-700 bg-white/90 backdrop-blur-sm border-2 border-red-200 rounded-xl hover:bg-red-50 hover:border-red-300 hover:shadow-lg transition-all duration-300 shadow-md hover:scale-105">
                    <svg class="h-4 w-4 mr-2 transition-transform duration-300 hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    刷新
                  </button>
                </div>
              </div>
            </div>
            
            <div v-if="emailsLoading" class="p-16 text-center">
              <div class="inline-block">
                <svg class="animate-spin h-14 w-14 text-red-600 dark:text-red-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">加载邮件中...</p>
              </div>
            </div>
            
            <div v-else-if="emails.length === 0" class="p-16 text-center">
              <div class="inline-block animate-fade-in">
                <div class="p-4 bg-gradient-to-br from-red-100 to-pink-100 dark:from-red-900/40 dark:to-pink-900/40 rounded-2xl inline-block mb-4">
                  <svg class="h-20 w-20 text-red-400 dark:text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                  </svg>
                </div>
                <p class="text-gray-600 dark:text-gray-300 text-xl font-semibold mb-2">垃圾邮件为空</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm">还没有收到任何垃圾邮件</p>
              </div>
            </div>
            
            <div v-else class="space-y-3 sm:space-y-4 p-3 sm:p-6">
              <transition-group name="email-list" tag="div">
                <div v-for="(email, index) in paginatedEmails" :key="email.id"
                     @click="openEmail(email)"
                     :style="{ 'animation-delay': `${index * 50}ms` }"
                     class="email-item group cursor-pointer transition-all duration-300 ease-out relative overflow-hidden rounded-xl sm:rounded-2xl border"
                     :class="{
                       'bg-gradient-to-br from-red-50 via-pink-50/80 to-rose-50/80 dark:from-red-900/40 dark:via-pink-900/40 dark:to-rose-900/40 border-red-300 dark:border-red-500 shadow-xl shadow-red-500/20 scale-[1.01]': selectedEmail?.id === email.id,
                       'bg-white dark:bg-gray-700/80 border-gray-200 dark:border-gray-600 hover:border-red-300 dark:hover:border-red-500 hover:bg-gradient-to-br hover:from-gray-50/50 hover:to-red-50/30 dark:hover:from-gray-700 dark:hover:to-red-900/20 hover:shadow-lg hover:scale-[1.005]': selectedEmail?.id !== email.id
                     }">
                  <!-- 选中指示器 -->
                  <div v-if="selectedEmail?.id === email.id" class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-red-500 to-pink-600"></div>
                  
                  <div class="p-3 sm:p-5">
                    <div class="flex items-start justify-between gap-2 sm:gap-4">
                      <div class="flex-1 min-w-0">
                        <!-- 发件人信息 -->
                        <div class="flex items-center flex-wrap gap-1.5 sm:gap-2 mb-2 sm:mb-3">
                          <div class="flex items-center space-x-1 sm:space-x-2">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 text-red-600 dark:text-red-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                            </svg>
                            <span class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide hidden sm:inline">发件人</span>
                          </div>
                          <p class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white truncate flex-1 min-w-0">{{ email.from }}</p>
                        </div>
                        
                        <!-- 邮件主题 -->
                        <h3 class="text-sm sm:text-base font-bold text-gray-900 dark:text-white mb-2 sm:mb-3 line-clamp-2 group-hover:text-red-700 dark:group-hover:text-red-300 transition-colors">
                          {{ email.subject || '(无主题)' }}
                        </h3>
                        
                        <!-- 底部信息栏 -->
                        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 sm:gap-0 pt-2 sm:pt-3 border-t border-gray-100 dark:border-gray-600">
                          <div class="flex items-center space-x-2 sm:space-x-3">
                            <span class="text-xs text-gray-500 dark:text-gray-300 font-medium">
                              <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                              </svg>
                              {{ formatDate(email.date) }}
                            </span>
                          </div>
                          <div class="flex items-center space-x-2">
                            <span class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-medium text-red-700 dark:text-red-200 bg-red-50 dark:bg-red-900/50 border border-red-200 dark:border-red-700 rounded-lg">
                              <svg class="w-3 h-3 mr-1 sm:mr-1.5 text-red-500 dark:text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                              </svg>
                              <span class="hidden sm:inline">垃圾邮件</span>
                              <span class="sm:hidden">垃圾</span>
                            </span>
                          </div>
                        </div>
                      </div>
                      
                      <!-- 操作按钮 - 手机端始终显示 -->
                      <div class="flex items-center space-x-1 sm:space-x-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-300 flex-shrink-0" @click.stop>
                        <!-- 快速操作：移动到文件夹 -->
                        <div class="relative move-button-group inline-block" @click.stop>
                          <button @click.stop class="inline-flex items-center px-2 sm:px-3 py-1.5 sm:py-2 text-xs font-medium text-gray-700 dark:text-gray-200 bg-white/90 dark:bg-gray-600/90 backdrop-blur-sm border border-gray-300 dark:border-gray-500 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/40 hover:border-red-300 dark:hover:border-red-600 hover:text-red-700 dark:hover:text-red-200 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 sm:mr-1.5 text-gray-500 dark:text-gray-400 move-button-group-hover:text-red-600 dark:move-button-group-hover:text-red-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                            </svg>
                            <span class="hidden sm:inline">移动</span>
                          </button>
                          <div class="absolute right-0 top-full mt-2 w-48 bg-white/95 dark:bg-gray-800/95 backdrop-blur-md rounded-xl shadow-xl border border-gray-200/50 dark:border-gray-600 opacity-0 invisible move-button-group-hover:opacity-100 move-button-group-hover:visible transition-all duration-300 z-50 transform translate-y-2 move-button-group-hover:translate-y-0" @click.stop>
                            <div class="py-2">
                              <button v-for="folder in getAvailableFolders(email.folder || 'spam', email)" 
                                      :key="folder.value"
                                      @click.stop="moveEmailToFolder(email.id, folder.value)"
                                      class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-gradient-to-r hover:from-red-50 hover:to-pink-50 dark:hover:from-red-900/40 dark:hover:to-pink-900/40 hover:text-red-700 dark:hover:text-red-300 flex items-center transition-all duration-200 rounded-lg mx-1">
                                <svg class="w-4 h-4 mr-2 text-gray-400 dark:text-gray-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="getFolderIcon(folder.value)"></path>
                                </svg>
                                {{ folder.label }}
                              </button>
                            </div>
                          </div>
                        </div>
                        
                        <button @click.stop="showDeleteConfirmDialog(email.id)" 
                                class="inline-flex items-center justify-center px-2 sm:px-3 py-1.5 sm:py-2 text-xs font-medium text-red-600 dark:text-red-300 bg-red-50/90 dark:bg-red-900/40 backdrop-blur-sm border border-red-200 dark:border-red-700 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/60 hover:border-red-300 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                          <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 transition-transform duration-300 hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </transition-group>
          
          <!-- 分页组件 -->
          <div v-if="totalPages > 1" class="mt-6 flex items-center justify-between border-t border-gray-200 dark:border-gray-600 pt-4 px-5">
            <div class="flex items-center text-sm text-gray-700 dark:text-gray-300">
              <span>显示第 {{ startIndex + 1 }}-{{ endIndex }} 条，共 {{ totalEmails }} 条邮件</span>
            </div>
            <div class="flex items-center space-x-2">
              <button @click="goToPage(currentPage - 1)" 
                      :disabled="currentPage <= 1"
                      class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                上一页
              </button>
              
              <div class="flex space-x-1">
                <button v-for="page in visiblePages" :key="page"
                        @click="goToPage(page)"
                        :class="{
                          'bg-red-600 text-white': page === currentPage,
                          'bg-white text-gray-700 hover:bg-gray-50': page !== currentPage
                        }"
                        class="px-3 py-2 text-sm font-medium border border-gray-300 rounded-md">
                  {{ page }}
                </button>
              </div>
              
              <button @click="goToPage(currentPage + 1)" 
                      :disabled="currentPage >= totalPages"
                      class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                下一页
              </button>
            </div>
          </div>
          </div>
          </div>
          <div v-else-if="view==='trash'" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
            <div class="p-3 sm:p-6 border-b border-gray-200/50 dark:border-gray-600 bg-gradient-to-r from-gray-50/80 via-slate-50/80 to-zinc-50/80 dark:from-gray-700/80 dark:via-gray-700/80 dark:to-gray-700/80 backdrop-blur-sm">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
                <h2 class="text-xl sm:text-2xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
                  <div class="p-2 sm:p-2.5 bg-gradient-to-br from-gray-500 to-slate-600 rounded-xl shadow-lg mr-2 sm:mr-3">
                    <svg class="w-5 h-5 sm:w-6 sm:h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </div>
                  <span class="bg-gradient-to-r from-gray-700 to-slate-700 dark:from-gray-300 dark:to-slate-300 bg-clip-text text-transparent">已删除</span>
                  <span class="ml-2 text-base sm:text-lg font-medium text-gray-500 dark:text-gray-400">共 {{ mailStats.trash?.total ?? 0 }} 封</span>
                </h2>
                <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:gap-3 w-full sm:w-auto">
                  <!-- 搜索框 -->
                  <div class="relative flex-1 sm:flex-none">
                    <input 
                      v-model="searchQuery" 
                      @keyup.enter="searchEmails"
                      @input="onSearchInput"
                      type="text" 
                      placeholder="搜索邮件内容..." 
                      class="pl-10 pr-4 py-2 sm:py-2.5 text-sm border-2 border-gray-200 dark:border-gray-600 dark:bg-gray-700 dark:text-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-gray-500 focus:border-gray-300 dark:focus:border-gray-500 transition-all duration-200 w-full sm:w-64 bg-white/90 dark:bg-gray-700/90 backdrop-blur-sm"
                    >
                    <svg class="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <button 
                      v-if="searchQuery" 
                      @click="clearSearch"
                      class="absolute right-2 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 transition-colors"
                    >
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                  <button 
                    @click="searchEmails" 
                    :disabled="!searchQuery || searchLoading"
                    class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-white bg-gradient-to-r from-gray-500 to-slate-600 rounded-xl hover:from-gray-600 hover:to-slate-700 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 shadow-md hover:shadow-lg hover:scale-105"
                  >
                    <svg v-if="!searchLoading" class="h-4 w-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
                    </svg>
                    <svg v-else class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ searchLoading ? '搜索中...' : '搜索' }}
                  </button>
                  <button @click="loadEmails('trash')" class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-gray-700 bg-white/90 backdrop-blur-sm border-2 border-gray-200 rounded-xl hover:bg-gray-50 hover:border-gray-300 hover:shadow-lg transition-all duration-300 shadow-md hover:scale-105">
                    <svg class="h-4 w-4 mr-2 transition-transform duration-300 hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    刷新
                  </button>
                </div>
              </div>
            </div>
            
            <div v-if="emailsLoading" class="p-16 text-center">
              <div class="inline-block">
                <svg class="animate-spin h-14 w-14 text-gray-600 dark:text-gray-400 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <p class="text-gray-600 dark:text-gray-300 font-semibold text-lg">加载邮件中...</p>
              </div>
            </div>
            <div v-else-if="emails.length === 0" class="p-16 text-center">
              <div class="inline-block animate-fade-in">
                <div class="p-4 bg-gradient-to-br from-gray-100 to-slate-100 dark:from-gray-700 dark:to-slate-700 rounded-2xl inline-block mb-4">
                  <svg class="h-20 w-20 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                  </svg>
                </div>
                <p class="text-gray-600 dark:text-gray-300 text-xl font-semibold mb-2">已删除文件夹为空</p>
                <p class="text-gray-400 dark:text-gray-500 text-sm">还没有删除任何邮件</p>
              </div>
            </div>
            
            <div v-else class="space-y-3 sm:space-y-4 p-3 sm:p-6">
              <transition-group name="email-list" tag="div">
                <div v-for="(email, index) in paginatedEmails" :key="email.id"
                     @click="openEmail(email)"
                     :style="{ 'animation-delay': `${index * 50}ms` }"
                     class="email-item group cursor-pointer transition-all duration-300 ease-out relative overflow-hidden rounded-xl sm:rounded-2xl border"
                     :class="{
                       'bg-gradient-to-br from-gray-50 via-slate-50/80 to-zinc-50/80 dark:from-gray-700 dark:via-slate-700/80 dark:to-zinc-700/80 border-gray-300 dark:border-gray-500 shadow-xl shadow-gray-500/20 scale-[1.01]': selectedEmail?.id === email.id,
                       'bg-white dark:bg-gray-700/80 border-gray-200 dark:border-gray-600 hover:border-gray-300 dark:hover:border-gray-500 hover:bg-gradient-to-br hover:from-gray-50/50 hover:to-slate-50/30 dark:hover:from-gray-700 dark:hover:to-slate-900/20 hover:shadow-lg hover:scale-[1.005]': selectedEmail?.id !== email.id
                     }">
                  <!-- 选中指示器 -->
                  <div v-if="selectedEmail?.id === email.id" class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-gray-500 to-slate-600"></div>
                  
                  <div class="p-3 sm:p-5">
                    <div class="flex items-start justify-between gap-2 sm:gap-4">
                      <div class="flex-1 min-w-0">
                        <!-- 发件人信息 -->
                        <div class="flex items-center flex-wrap gap-1.5 sm:gap-2 mb-2 sm:mb-3">
                          <div class="flex items-center space-x-1 sm:space-x-2">
                            <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 text-gray-600 dark:text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                            </svg>
                            <span class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide hidden sm:inline">发件人</span>
                          </div>
                          <p class="text-xs sm:text-sm font-semibold text-gray-900 dark:text-white truncate flex-1 min-w-0">{{ email.from }}</p>
                        </div>
                        
                        <!-- 邮件主题 -->
                        <h3 class="text-sm sm:text-base font-bold text-gray-900 dark:text-white mb-2 sm:mb-3 line-clamp-2 group-hover:text-gray-700 dark:group-hover:text-gray-300 transition-colors">
                          {{ email.subject || '(无主题)' }}
                        </h3>
                        
                        <!-- 底部信息栏 -->
                        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2 sm:gap-0 pt-2 sm:pt-3 border-t border-gray-100 dark:border-gray-600">
                          <div class="flex items-center space-x-2 sm:space-x-3">
                            <span class="text-xs text-gray-500 dark:text-gray-300 font-medium">
                              <svg class="w-3 h-3 sm:w-3.5 sm:h-3.5 inline mr-1 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                              </svg>
                              {{ formatDate(email.date) }}
                            </span>
                          </div>
                          <div class="flex items-center space-x-2">
                            <span class="inline-flex items-center px-2 sm:px-2.5 py-0.5 sm:py-1 text-xs font-medium text-gray-600 dark:text-gray-300 bg-gray-50 dark:bg-gray-600/80 border border-gray-200 dark:border-gray-500 rounded-lg">
                              <svg class="w-3 h-3 mr-1 sm:mr-1.5 text-gray-400 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                              </svg>
                              <span class="hidden sm:inline">已删除</span>
                              <span class="sm:hidden">删除</span>
                            </span>
                          </div>
                        </div>
                      </div>
                      
                      <!-- 操作按钮 - 手机端始终显示 -->
                      <div class="flex items-center space-x-1 sm:space-x-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity duration-300 flex-shrink-0" @click.stop>
                        <!-- 还原按钮 -->
                        <button @click.stop="restoreEmail(email.id)" 
                                class="inline-flex items-center px-3 py-2 text-xs font-medium text-green-700 dark:text-green-200 bg-green-50/90 dark:bg-green-900/40 backdrop-blur-sm border border-green-200 dark:border-green-700 rounded-lg hover:bg-green-100 dark:hover:bg-green-900/60 hover:border-green-300 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                          <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"></path>
                          </svg>
                          还原
                        </button>
                        <!-- 彻底删除按钮 -->
                        <button @click.stop="permanentlyDeleteEmail(email.id)" 
                                class="inline-flex items-center px-3 py-2 text-xs font-medium text-red-600 dark:text-red-300 bg-red-50/90 dark:bg-red-900/40 backdrop-blur-sm border border-red-200 dark:border-red-700 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/60 hover:border-red-300 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                          <svg class="w-4 h-4 transition-transform duration-300 hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                          </svg>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </transition-group>
          
          <!-- 分页组件 -->
          <div v-if="totalPages > 1" class="mt-6 flex items-center justify-between border-t border-gray-200 pt-4 px-5">
            <div class="flex items-center text-sm text-gray-700">
              <span>显示第 {{ startIndex + 1 }}-{{ endIndex }} 条，共 {{ totalEmails }} 条邮件</span>
            </div>
            <div class="flex items-center space-x-2">
              <button @click="goToPage(currentPage - 1)" 
                      :disabled="currentPage <= 1"
                      class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                上一页
              </button>
              
              <div class="flex space-x-1">
                <button v-for="page in visiblePages" :key="page"
                        @click="goToPage(page)"
                        :class="{
                          'bg-gray-600 text-white': page === currentPage,
                          'bg-white text-gray-700 hover:bg-gray-50': page !== currentPage
                        }"
                        class="px-3 py-2 text-sm font-medium border border-gray-300 rounded-md">
                  {{ page }}
                </button>
              </div>
              
              <button @click="goToPage(currentPage + 1)" 
                      :disabled="currentPage >= totalPages"
                      class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                下一页
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 自定义文件夹 -->
      <div v-else-if="view==='custom-folder' && currentCustomFolder" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
        <div class="p-6 border-b border-gray-200/50 bg-gradient-to-r from-indigo-50/80 via-purple-50/80 to-pink-50/80 backdrop-blur-sm">
          <div class="flex items-center justify-between">
            <h2 class="text-2xl font-bold text-gray-900 flex items-center">
              <div class="p-2.5 bg-gradient-to-br from-indigo-500 to-purple-600 rounded-xl shadow-lg mr-3">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
                </svg>
              </div>
              <span class="bg-gradient-to-r from-indigo-700 to-purple-700 bg-clip-text text-transparent">{{ customFoldersList.find(f => f.name === currentCustomFolder)?.display_name || currentCustomFolder }}</span>
              <span class="ml-2 text-base sm:text-lg font-medium text-gray-500">共 {{ totalEmails }} 封</span>
            </h2>
            <button @click="loadEmails(currentCustomFolder)" class="inline-flex items-center px-5 py-2.5 text-sm font-semibold text-indigo-700 bg-white/90 backdrop-blur-sm border-2 border-indigo-200 rounded-xl hover:bg-indigo-50 hover:border-indigo-300 hover:shadow-lg transition-all duration-300 shadow-md hover:scale-105">
              <svg class="h-4 w-4 mr-2 transition-transform duration-300 hover:rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
              </svg>
              刷新
            </button>
          </div>
        </div>
        
        <div v-if="emailsLoading" class="p-16 text-center">
          <div class="inline-block">
            <svg class="animate-spin h-14 w-14 text-indigo-600 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <p class="text-gray-600 font-semibold text-lg">加载邮件中...</p>
          </div>
        </div>
        
        <div v-else-if="emails.length === 0" class="p-16 text-center">
          <div class="inline-block animate-fade-in">
            <div class="p-4 bg-gradient-to-br from-indigo-100 to-purple-100 rounded-2xl inline-block mb-4">
              <svg class="h-20 w-20 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
              </svg>
            </div>
            <p class="text-gray-600 text-xl font-semibold mb-2">{{ customFoldersList.find(f => f.name === currentCustomFolder)?.display_name || currentCustomFolder }}为空</p>
            <p class="text-gray-400 text-sm">该文件夹中还没有任何邮件</p>
          </div>
        </div>
        
        <div v-else class="space-y-4 p-6">
          <transition-group name="email-list" tag="div">
            <div v-for="(email, index) in paginatedEmails" :key="email.id"
                 @click="openEmail(email)"
                 :style="{ 'animation-delay': `${index * 50}ms` }"
                 class="email-item group cursor-pointer transition-all duration-300 ease-out relative overflow-hidden rounded-2xl border"
                 :class="{
                   'bg-gradient-to-br from-indigo-50 via-purple-50/80 to-pink-50/80 dark:from-indigo-900/30 dark:via-purple-900/30 dark:to-pink-900/30 border-indigo-300 dark:border-indigo-500 shadow-xl shadow-indigo-500/20 scale-[1.01]': selectedEmail?.id === email.id,
                   'bg-white dark:bg-gray-700/80 border-gray-200 dark:border-gray-600 hover:border-indigo-300 dark:hover:border-indigo-500 hover:bg-gradient-to-br hover:from-gray-50/50 hover:to-indigo-50/30 dark:hover:from-gray-700 dark:hover:to-indigo-900/20 hover:shadow-lg hover:scale-[1.005]': selectedEmail?.id !== email.id
                 }">
              <!-- 选中指示器 -->
              <div v-if="selectedEmail?.id === email.id" class="absolute left-0 top-0 bottom-0 w-1 bg-gradient-to-b from-indigo-500 to-purple-600"></div>
              
              <!-- 未读邮件指示器 -->
              <div v-if="isUnread(email)" class="absolute top-4 right-4">
                <div class="w-2.5 h-2.5 bg-indigo-500 rounded-full animate-pulse shadow-md ring-2 ring-indigo-200 dark:ring-indigo-800"></div>
              </div>
              
              <div class="p-5">
                <div class="flex items-start justify-between gap-4">
                  <div class="flex-1 min-w-0">
                    <!-- 发件人信息 -->
                    <div class="flex items-center flex-wrap gap-2 mb-3">
                      <div class="flex items-center space-x-2">
                        <svg class="w-4 h-4 text-indigo-600 dark:text-indigo-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                        </svg>
                        <span class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide">发件人</span>
                      </div>
                      <p class="text-sm font-semibold text-gray-900 dark:text-white truncate">
                        {{ isSystemNotification(email.from) ? '系统通知' : isAdminSender(email.from) ? '系统管理员' : email.from }}
                      </p>
                      <span v-if="isSystemNotification(email.from)" class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-yellow-700 dark:text-yellow-200 bg-yellow-100 dark:bg-yellow-900/50 border border-yellow-200 dark:border-yellow-700 rounded-lg">
                        <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                          <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                        </svg>
                        系统通知
                      </span>
                      <span v-else-if="isAdminSender(email.from)" class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-red-700 dark:text-red-200 bg-red-100 dark:bg-red-900/50 border border-red-200 dark:border-red-700 rounded-lg">系统管理员</span>
                    </div>
                    
                    <!-- 邮件主题 -->
                    <h3 class="text-base font-bold text-gray-900 dark:text-white mb-3 line-clamp-2 group-hover:text-indigo-700 dark:group-hover:text-indigo-300 transition-colors">
                      {{ email.subject || '(无主题)' }}
                    </h3>
                    
                    <!-- 底部信息栏 -->
                    <div class="flex items-center justify-between pt-3 border-t border-gray-100 dark:border-gray-600">
                      <div class="flex items-center space-x-3">
                        <span class="text-xs text-gray-500 dark:text-gray-300 font-medium">
                          <svg class="w-3.5 h-3.5 inline mr-1 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                          </svg>
                          {{ formatDate(email.date) }}
                        </span>
                      </div>
                      <div class="flex items-center space-x-2">
                        <span v-if="isUnread(email)" class="inline-flex items-center px-2.5 py-1 text-xs font-semibold text-indigo-700 dark:text-indigo-200 bg-indigo-50 dark:bg-indigo-900/50 border border-indigo-200 dark:border-indigo-700 rounded-lg">
                          <div class="w-1.5 h-1.5 bg-indigo-500 rounded-full mr-1.5 animate-pulse"></div>
                          未读
                        </span>
                        <span v-else class="inline-flex items-center px-2.5 py-1 text-xs font-medium text-gray-500 dark:text-gray-300 bg-gray-50 dark:bg-gray-600/80 border border-gray-200 dark:border-gray-500 rounded-lg">
                          <svg class="w-3 h-3 mr-1.5 text-gray-400 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                          </svg>
                          已读
                        </span>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 操作按钮 -->
                  <div class="flex items-center space-x-2 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex-shrink-0" @click.stop>
                    <!-- 快速操作：移动到文件夹 -->
                    <div class="relative move-button-group inline-block" @click.stop>
                      <button @click.stop class="inline-flex items-center px-3 py-2 text-xs font-medium text-gray-700 dark:text-gray-200 bg-white/90 dark:bg-gray-600/90 backdrop-blur-sm border border-gray-300 dark:border-gray-500 rounded-lg hover:bg-indigo-50 dark:hover:bg-indigo-900/40 hover:border-indigo-300 dark:hover:border-indigo-600 hover:text-indigo-700 dark:hover:text-indigo-200 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                        <svg class="w-4 h-4 mr-1.5 text-gray-500 dark:text-gray-400 move-button-group-hover:text-indigo-600 dark:move-button-group-hover:text-indigo-400 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                        </svg>
                        移动
                      </button>
                      <div class="absolute right-0 top-full mt-2 w-48 bg-white/95 dark:bg-gray-800/95 backdrop-blur-md rounded-xl shadow-xl border border-gray-200/50 dark:border-gray-600 opacity-0 invisible move-button-group-hover:opacity-100 move-button-group-hover:visible transition-all duration-300 z-50 transform translate-y-2 move-button-group-hover:translate-y-0" @click.stop>
                        <div class="py-2">
                          <button v-for="folder in getAvailableFolders(email.folder || currentCustomFolder || '', email)" 
                                  :key="folder.value"
                                  @click.stop="moveEmailToFolder(email.id, folder.value)"
                                  class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-gradient-to-r hover:from-indigo-50 hover:to-purple-50 dark:hover:from-indigo-900/40 dark:hover:to-purple-900/40 hover:text-indigo-700 dark:hover:text-indigo-300 flex items-center transition-all duration-200 rounded-lg mx-1">
                            <svg class="w-4 h-4 mr-2 text-gray-400 dark:text-gray-500 transition-colors" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="getFolderIcon(folder.value)"></path>
                            </svg>
                            {{ folder.label }}
                          </button>
                        </div>
                      </div>
                    </div>
                    
                    <button @click.stop="softDeleteEmail(email.id)" 
                            class="inline-flex items-center px-3 py-2 text-xs font-medium text-red-600 dark:text-red-300 bg-red-50/90 dark:bg-red-900/40 backdrop-blur-sm border border-red-200 dark:border-red-700 rounded-lg hover:bg-red-100 dark:hover:bg-red-900/60 hover:border-red-300 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-1 transition-all duration-200 shadow-sm hover:shadow-md">
                      <svg class="w-4 h-4 transition-transform duration-300 hover:rotate-12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </transition-group>
          
          <!-- 分页 -->
          <div v-if="totalPages > 1" class="px-5 py-4 border-t border-gray-200">
            <div class="flex items-center justify-between">
              <div class="text-sm text-gray-700">
                显示 {{ startIndex + 1 }} - {{ endIndex }} 条，共 {{ totalEmails }} 条
              </div>
              <div class="flex space-x-2">
                <button @click="goToPage(currentPage - 1)" 
                        :disabled="currentPage <= 1"
                        class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                  上一页
                </button>
                <button @click="goToPage(currentPage + 1)" 
                        :disabled="currentPage >= totalPages"
                        class="px-3 py-2 text-sm font-medium text-gray-500 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                  下一页
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
        <div v-else-if="view==='compose'" class="bg-white/95 dark:bg-gray-800/95 backdrop-blur-md shadow-xl rounded-2xl border border-gray-100/50 dark:border-gray-600 overflow-hidden">
            <!-- 标题栏 -->
            <div class="p-5 border-b border-gray-200/50 dark:border-gray-600/50 bg-gradient-to-r from-purple-50/50 via-indigo-50/50 to-pink-50/50 dark:from-gray-800 dark:via-gray-800 dark:to-gray-800">
              <div class="flex items-center justify-between">
                <h2 class="text-xl font-bold text-gray-900 dark:text-gray-100 flex items-center">
                  <div class="relative">
                    <svg class="w-6 h-6 mr-2 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                    </svg>
                    <div class="absolute -top-1 -right-1 w-2 h-2 bg-purple-500 rounded-full animate-pulse"></div>
                  </div>
                  写邮件
                </h2>
                <button @click="clearForm" 
                        class="inline-flex items-center px-3 py-1.5 text-sm font-medium text-gray-600 dark:text-gray-300 bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-600 hover:border-gray-300 dark:hover:border-gray-500 transition-all duration-300">
                  <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                  </svg>
                  清空
                </button>
              </div>
            </div>
            
            <div class="p-6 space-y-6">
              <!-- 收件人 -->
              <div class="group">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2.5 flex items-center">
                  <svg class="w-4 h-4 mr-1.5 text-blue-500 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                  </svg>
                  收件人 <span class="text-red-500 dark:text-red-400 ml-1">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 pointer-events-none">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                    </svg>
                  </div>
                  <input v-model="to" type="email" 
                         class="w-full border-2 border-gray-200 dark:border-gray-600 rounded-xl pl-12 pr-12 py-3.5 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 dark:focus:ring-blue-400 dark:focus:border-blue-400 transition-all duration-300 bg-gradient-to-r from-white to-blue-50/30 dark:from-gray-700 dark:to-gray-700 hover:from-blue-50/50 hover:to-blue-50/50 dark:hover:from-gray-600 dark:hover:to-gray-600 shadow-sm hover:shadow-md text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400" 
                         placeholder="user@example.com" 
                         required />
                  <button @click="showUserSelector('to')" 
                          type="button"
                          class="absolute right-3 top-1/2 transform -translate-y-1/2 p-2 text-gray-400 dark:text-gray-500 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-900/30 rounded-lg transition-all duration-300 hover:scale-110">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                    </svg>
                  </button>
                </div>
              </div>

              <!-- 抄送 -->
              <div class="group">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2.5 flex items-center">
                  <svg class="w-4 h-4 mr-1.5 text-green-500 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                  </svg>
                  抄送 (CC) <span class="text-gray-400 dark:text-gray-500 text-xs font-normal ml-2">可选</span>
                </label>
                <div class="relative">
                  <div class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 pointer-events-none">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                    </svg>
                  </div>
                  <input v-model="cc" type="text" 
                         class="w-full border-2 border-gray-200 dark:border-gray-600 rounded-xl pl-12 pr-12 py-3.5 focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 dark:focus:ring-green-400 dark:focus:border-green-400 transition-all duration-300 bg-gradient-to-r from-white to-green-50/30 dark:from-gray-700 dark:to-gray-700 hover:from-green-50/50 hover:to-green-50/50 dark:hover:from-gray-600 dark:hover:to-gray-600 shadow-sm hover:shadow-md text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400" 
                         placeholder="cc@example.com (支持多个，用逗号分隔)" />
                  <button @click="showUserSelector('cc')" 
                          type="button"
                          class="absolute right-3 top-1/2 transform -translate-y-1/2 p-2 text-gray-400 dark:text-gray-500 hover:text-green-600 dark:hover:text-green-400 hover:bg-green-50 dark:hover:bg-green-900/30 rounded-lg transition-all duration-300 hover:scale-110">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                    </svg>
                  </button>
                </div>
                <!-- 已选择的抄送用户显示 -->
                <div v-if="selectedCCUsers.length > 0" class="mt-3 flex flex-wrap gap-2">
                  <span v-for="(user, index) in selectedCCUsers" :key="index" 
                        class="inline-flex items-center px-3 py-1.5 rounded-full text-sm font-medium bg-gradient-to-r from-green-100 to-emerald-100 dark:from-green-900/40 dark:to-emerald-900/40 text-green-800 dark:text-green-200 border border-green-200 dark:border-green-700 shadow-sm hover:shadow-md transition-all duration-200 hover:scale-105">
                    <svg class="w-3.5 h-3.5 mr-1.5 text-green-600 dark:text-green-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                    {{ user.email }}
                    <button @click="removeCCUser(index)" 
                            class="ml-2 p-0.5 rounded-full text-green-600 dark:text-green-400 hover:text-green-800 dark:hover:text-green-200 hover:bg-green-200 dark:hover:bg-green-700 transition-all duration-200">
                      <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </span>
                </div>
              </div>

              <!-- 主题 -->
              <div class="group">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2.5 flex items-center">
                  <svg class="w-4 h-4 mr-1.5 text-purple-500 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h10m-7 4h7"></path>
                  </svg>
                  主题 <span class="text-red-500 dark:text-red-400 ml-1">*</span>
                </label>
                <div class="relative">
                  <div class="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-400 dark:text-gray-500 pointer-events-none">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 8h10M7 12h10m-7 4h7"></path>
                    </svg>
                  </div>
                  <input v-model="subject" 
                         class="w-full border-2 border-gray-200 dark:border-gray-600 rounded-xl pl-12 pr-4 py-3.5 focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-purple-500 dark:focus:ring-purple-400 dark:focus:border-purple-400 transition-all duration-300 bg-gradient-to-r from-white to-purple-50/30 dark:from-gray-700 dark:to-gray-700 hover:from-purple-50/50 hover:to-purple-50/50 dark:hover:from-gray-600 dark:hover:to-gray-600 shadow-sm hover:shadow-md text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400" 
                         placeholder="输入邮件主题..." 
                         required />
                </div>
              </div>

              <!-- 附件 -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2.5 flex items-center">
                  <svg class="w-4 h-4 mr-1.5 text-indigo-500 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path>
                  </svg>
                  附件 <span class="text-gray-400 dark:text-gray-500 text-xs font-normal ml-2">可选</span>
                </label>
                <div class="border-2 border-dashed border-gray-300 dark:border-gray-600 rounded-xl p-6 hover:border-indigo-400 dark:hover:border-indigo-500 hover:bg-gradient-to-br hover:from-indigo-50/30 hover:to-purple-50/30 dark:hover:from-indigo-900/20 dark:hover:to-purple-900/20 transition-all duration-300 group cursor-pointer">
                  <input type="file" 
                         ref="fileInput" 
                         @change="handleFileSelect" 
                         multiple 
                         class="hidden" 
                         accept=".pdf,.md,.doc,.docx,.txt,.jpg,.jpeg,.png,.gif,.zip,.rar" />
                  <div @click="$refs.fileInput.click()" class="text-center">
                    <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-indigo-100 to-purple-100 dark:from-indigo-900/50 dark:to-purple-900/50 mb-4 group-hover:from-indigo-200 group-hover:to-purple-200 dark:group-hover:from-indigo-800/60 dark:group-hover:to-purple-800/60 transition-all duration-300 group-hover:scale-110">
                      <svg class="w-8 h-8 text-indigo-500 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                      </svg>
                    </div>
                    <p class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                      <span class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300">点击上传文件</span>
                      <span class="text-gray-500 dark:text-gray-400 mx-2">或</span>
                      <span class="text-indigo-600 dark:text-indigo-400 hover:text-indigo-700 dark:hover:text-indigo-300">拖拽文件到此处</span>
                    </p>
                    <p class="text-xs text-gray-500 dark:text-gray-400 mt-2">支持 PDF, MD, DOC, TXT, 图片, 压缩包等格式</p>
                    <p class="text-xs text-orange-500 dark:text-orange-400 mt-1 font-medium">单文件最大10MB，总大小不超过50MB</p>
                  </div>
                </div>
                
                <!-- 已选择的文件列表 -->
                <div v-if="attachments.length > 0" class="mt-4">
                  <h4 class="text-sm font-semibold text-gray-700 dark:text-gray-300 mb-3 flex items-center">
                    <svg class="w-4 h-4 mr-1.5 text-indigo-500 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    已选择的文件 ({{ attachments.length }})
                  </h4>
                  <div class="space-y-2">
                    <div v-for="(file, index) in attachments" :key="index" 
                         class="flex items-center justify-between bg-gradient-to-r from-indigo-50/50 to-purple-50/50 dark:from-indigo-900/30 dark:to-purple-900/30 hover:from-indigo-100/50 hover:to-purple-100/50 dark:hover:from-indigo-800/40 dark:hover:to-purple-800/40 rounded-xl px-4 py-3 transition-all duration-200 border border-indigo-200/50 dark:border-indigo-700/50 hover:border-indigo-300 dark:hover:border-indigo-600 hover:shadow-md">
                      <div class="flex items-center space-x-3 flex-1 min-w-0">
                        <div class="flex-shrink-0 w-10 h-10 rounded-lg bg-gradient-to-br from-indigo-100 to-purple-100 dark:from-indigo-800/60 dark:to-purple-800/60 flex items-center justify-center">
                          <svg class="w-5 h-5 text-indigo-600 dark:text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                          </svg>
                        </div>
                        <div class="flex-1 min-w-0">
                          <span class="text-sm font-medium text-gray-800 dark:text-gray-200 block truncate">{{ file.name }}</span>
                          <span class="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{{ formatFileSize(file.size) }}</span>
                        </div>
                      </div>
                      <button @click="removeAttachment(index)" 
                              class="ml-3 p-2 rounded-lg text-gray-400 dark:text-gray-500 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/30 transition-all duration-200 flex-shrink-0 hover:scale-110"
                              title="删除附件">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 正文 -->
              <div class="group">
                <label class="block text-sm font-semibold text-gray-700 dark:text-gray-300 mb-2.5 flex items-center">
                  <svg class="w-4 h-4 mr-1.5 text-pink-500 dark:text-pink-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                  </svg>
                  正文 <span class="text-red-500 dark:text-red-400 ml-1">*</span>
                </label>
                <div class="relative">
                  <textarea v-model="body" 
                            rows="10" 
                            class="w-full border-2 border-gray-200 dark:border-gray-600 rounded-xl px-4 py-4 focus:outline-none focus:ring-2 focus:ring-pink-500 focus:border-pink-500 dark:focus:ring-pink-400 dark:focus:border-pink-400 transition-all duration-300 resize-none bg-gradient-to-br from-white to-pink-50/20 dark:from-gray-700 dark:to-gray-700 hover:from-pink-50/30 hover:to-pink-50/30 dark:hover:from-gray-600 dark:hover:to-gray-600 shadow-sm hover:shadow-md leading-relaxed text-gray-900 dark:text-gray-100 placeholder-gray-500 dark:placeholder-gray-400" 
                            placeholder="在这里输入您的邮件内容..." 
                            required></textarea>
                  <div class="absolute bottom-3 right-3 text-xs text-gray-400 dark:text-gray-500">
                    <span v-if="body.length > 0">{{ body.length }} 字符</span>
                  </div>
                </div>
              </div>


              <!-- 草稿保存提示 -->
              <div v-if="draftSaved" class="flex items-center text-sm font-medium text-green-700 dark:text-green-300 bg-gradient-to-r from-green-50 to-emerald-50 dark:from-green-900/40 dark:to-emerald-900/40 border border-green-200 dark:border-green-700 rounded-xl px-4 py-3 shadow-sm animate-fade-in">
                <div class="flex-shrink-0 w-8 h-8 rounded-full bg-green-100 dark:bg-green-800/60 flex items-center justify-center mr-3">
                  <svg class="w-5 h-5 text-green-600 dark:text-green-400" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                  </svg>
                </div>
                <span>草稿已自动保存</span>
              </div>

              <!-- 通知消息 -->
              <div v-if="notice" :class="noticeClass" class="text-sm font-medium">{{ notice }}</div>

              <!-- 操作按钮 -->
              <div class="flex items-center justify-between pt-6 border-t border-gray-200/50 dark:border-gray-600/50">
                <div class="flex items-center space-x-3">
                  <button @click="sendEmail" 
                          :disabled="sending || !to || !subject || !body" 
                          class="group relative inline-flex items-center px-8 py-3.5 bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600 text-white rounded-xl font-semibold shadow-lg shadow-blue-500/30 hover:shadow-xl hover:shadow-blue-500/40 focus:outline-none focus:ring-4 focus:ring-blue-300 dark:focus:ring-blue-600 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-300 transform hover:scale-105 disabled:hover:scale-100 overflow-hidden">
                    <div class="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500 -translate-x-full group-hover:translate-x-full"></div>
                    <svg v-if="sending" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <svg v-else class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"></path>
                    </svg>
                    {{ sending ? '发送中...' : '发送邮件' }}
                  </button>
                  
                  <button @click="saveDraft" 
                          :disabled="!subject && !body"
                          class="inline-flex items-center px-6 py-3 bg-gradient-to-r from-yellow-500 to-amber-500 text-white rounded-xl font-medium shadow-md shadow-yellow-500/20 hover:shadow-lg hover:shadow-yellow-500/30 hover:from-yellow-600 hover:to-amber-600 focus:outline-none focus:ring-4 focus:ring-yellow-300 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 transform hover:scale-105">
                    <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                    保存草稿
                  </button>
                </div>
                
                <div class="flex items-center space-x-4 text-sm">
                  <div v-if="attachments.length > 0" class="flex items-center space-x-2 px-3 py-1.5 bg-indigo-50 dark:bg-indigo-900/40 text-indigo-700 dark:text-indigo-300 rounded-lg border border-indigo-200 dark:border-indigo-700">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path>
                    </svg>
                    <span class="font-medium">{{ attachments.length }} 个附件</span>
                  </div>
                  <div v-if="attachments.length === 0" class="text-gray-500 dark:text-gray-400 flex items-center">
                    <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 12H6"></path>
                    </svg>
                    <span>无附件</span>
                  </div>
                </div>
              </div>
              
              <!-- 发送进度条 -->
              <div v-if="sending" class="mt-4 p-4 bg-blue-50 dark:bg-blue-900/30 rounded-lg border border-blue-200 dark:border-blue-700">
                <div class="flex items-center justify-between text-sm text-blue-700 dark:text-blue-300 mb-2">
                  <span class="font-medium">正在发送邮件...</span>
                  <span>{{ sendingProgress }}%</span>
                </div>
                <div class="w-full bg-blue-200 dark:bg-blue-800 rounded-full h-2 mb-2">
                  <div class="bg-blue-600 dark:bg-blue-500 h-2 rounded-full transition-all duration-500 ease-out" :style="{ width: sendingProgress + '%' }"></div>
                </div>
                
                <!-- 时间信息 -->
                <div class="flex items-center justify-between text-xs text-blue-600 dark:text-blue-400 mb-2">
                  <div class="flex items-center space-x-4">
                    <span>已用时间: <span class="font-medium text-blue-800 dark:text-blue-300">{{ formatTime(elapsedTime) }}</span></span>
                    <span v-if="estimatedTime > 0">预计剩余: <span class="font-medium text-blue-800 dark:text-blue-300">{{ formatTime(estimatedTime) }}</span></span>
                  </div>
                  <div class="text-gray-500 dark:text-gray-400">
                    {{ Math.round(elapsedTime + estimatedTime) }}秒总预计
                  </div>
                </div>
                
                <div class="text-xs text-blue-600 dark:text-blue-400">
                  <span v-if="attachments.length > 0">
                    包含 {{ attachments.length }} 个附件
                    <span v-if="isLargeFile" class="text-orange-600 dark:text-orange-400 font-medium">（大文件，预计需要更长时间）</span>
                    <span v-if="!isLargeFile">，正在处理中...</span>
                  </span>
                  <span v-if="attachments.length === 0">正在处理邮件发送</span>
                </div>
              </div>
            </div>
          </div>
          <!-- 邮件详情模态框 - 重新设计 -->
          <div v-if="showEmailDetail" class="fixed inset-0 z-50 overflow-y-auto">
            <div class="flex items-center justify-center min-h-screen pt-0 sm:pt-4 px-0 sm:px-4 pb-0 sm:pb-20 text-center sm:block sm:p-0">
              <!-- 背景遮罩 -->
              <div class="fixed inset-0 bg-gray-900 bg-opacity-50 backdrop-blur-sm transition-opacity" @click="closeEmailDetail"></div>
              
              <!-- 模态框主体 -->
              <div class="inline-block align-bottom bg-white dark:bg-gray-800 rounded-t-2xl sm:rounded-2xl text-left overflow-hidden shadow-2xl transform transition-all w-full sm:my-8 sm:align-middle sm:max-w-5xl sm:w-full border border-gray-200 dark:border-gray-600">
                <!-- 头部区域 -->
                <div class="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-gray-700 dark:to-gray-700 px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 dark:border-gray-600">
                  <div class="flex items-center justify-between">
                    <div class="flex-1 min-w-0 pr-2 sm:pr-4">
                      <h3 class="text-lg sm:text-xl font-bold text-gray-900 dark:text-gray-100 truncate">{{ selectedEmail?.subject || '(无主题)' }}</h3>
                      <p class="text-xs sm:text-sm text-gray-500 dark:text-gray-400 mt-1">{{ formatDate(selectedEmail?.date) }}</p>
                    </div>
                    <button @click="closeEmailDetail" 
                            class="flex-shrink-0 p-2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 hover:bg-white dark:hover:bg-gray-600 rounded-lg transition-all duration-200">
                      <svg class="h-5 w-5 sm:h-6 sm:w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                </div>

                <!-- 邮件信息区域 -->
                <div class="px-4 sm:px-6 py-4 sm:py-5 bg-white dark:bg-gray-800">
                  <!-- 发件人和收件人信息 -->
                  <div class="space-y-3 sm:space-y-4 mb-4 sm:mb-6">
                    <!-- 发件人 -->
                    <div class="flex flex-col sm:flex-row items-start sm:items-start space-y-1 sm:space-y-0 sm:space-x-3">
                      <div class="flex-shrink-0 w-full sm:w-20">
                        <span class="text-xs sm:text-sm font-semibold text-gray-700 dark:text-gray-300">发件人:</span>
                      </div>
                      <div class="flex-1 min-w-0 w-full">
                        <div class="flex items-center space-x-2 flex-wrap">
                          <span class="text-xs sm:text-sm text-gray-900 dark:text-gray-100 break-all">{{ selectedEmail?.from }}</span>
                          <!-- 系统通知标签 -->
                          <span v-if="selectedEmail?.from && isSystemNotification(selectedEmail.from)" 
                                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium text-white bg-yellow-500 shadow-sm">
                            <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                            </svg>
                            系统通知
                          </span>
                          <!-- 系统管理员标签 -->
                          <span v-else-if="selectedEmail?.from && isAdminSender(selectedEmail.from)" 
                                class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium text-white bg-red-500 shadow-sm">
                            系统管理员
                          </span>
                        </div>
                      </div>
                    </div>

                    <!-- 收件人 -->
                    <div class="flex flex-col sm:flex-row items-start sm:items-start space-y-1 sm:space-y-0 sm:space-x-3">
                      <div class="flex-shrink-0 w-full sm:w-20">
                        <span class="text-xs sm:text-sm font-semibold text-blue-700 dark:text-blue-300">收件人:</span>
                      </div>
                      <div class="flex-1 min-w-0 w-full">
                        <div v-if="selectedEmail?.recipients && selectedEmail.recipients.to && selectedEmail.recipients.to.length > 0" class="flex flex-wrap gap-1.5">
                          <span v-for="(addr, idx) in selectedEmail.recipients.to" :key="idx" 
                                class="inline-flex items-center px-2 py-1 rounded-md text-xs sm:text-sm font-medium text-blue-700 dark:text-blue-300 bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-600 break-all">
                            {{ addr }}
                          </span>
                        </div>
                        <span v-else-if="selectedEmail?.to" class="inline-flex items-center px-2 py-1 rounded-md text-xs sm:text-sm font-medium text-blue-700 dark:text-blue-300 bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-600 break-all">{{ selectedEmail.to }}</span>
                        <span v-else class="text-xs sm:text-sm text-gray-500 dark:text-gray-400">无</span>
                      </div>
                    </div>

                    <!-- 抄送 -->
                    <div v-if="(selectedEmail?.recipients && selectedEmail.recipients.cc && selectedEmail.recipients.cc.length > 0) || (selectedEmail?.cc && selectedEmail.cc.trim())" 
                         class="flex flex-col sm:flex-row items-start sm:items-start space-y-1 sm:space-y-0 sm:space-x-3">
                      <div class="flex-shrink-0 w-full sm:w-20">
                        <span class="text-xs sm:text-sm font-semibold text-green-700 dark:text-green-300">抄送:</span>
                      </div>
                      <div class="flex-1 min-w-0 w-full">
                        <div v-if="selectedEmail?.recipients && selectedEmail.recipients.cc && selectedEmail.recipients.cc.length > 0" class="flex flex-wrap gap-1.5">
                          <span v-for="(addr, idx) in selectedEmail.recipients.cc" :key="idx" 
                                class="inline-flex items-center px-2 py-1 rounded-md text-xs sm:text-sm font-medium text-green-700 dark:text-green-300 bg-green-50 dark:bg-green-900/40 border border-green-200 dark:border-green-600 break-all">
                            {{ addr }}
                          </span>
                        </div>
                        <span v-else-if="selectedEmail?.cc && selectedEmail.cc.trim()" class="inline-flex items-center px-2 py-1 rounded-md text-xs sm:text-sm font-medium text-green-700 dark:text-green-300 bg-green-50 dark:bg-green-900/40 border border-green-200 dark:border-green-600 break-all">{{ selectedEmail.cc }}</span>
                      </div>
                    </div>

                    <!-- 密送 -->
                    <div v-if="selectedEmail?.recipients && selectedEmail.recipients.bcc && selectedEmail.recipients.bcc.length > 0" 
                         class="flex items-start space-x-3">
                      <div class="flex-shrink-0 w-20">
                        <span class="text-sm font-semibold text-gray-600 dark:text-gray-400">密送:</span>
                      </div>
                      <div class="flex-1 min-w-0">
                        <div class="flex flex-wrap gap-1">
                          <span v-for="(addr, idx) in selectedEmail.recipients.bcc" :key="idx" 
                                class="text-sm text-gray-900 dark:text-gray-100 break-all">
                            {{ addr }}<span v-if="idx < selectedEmail.recipients.bcc.length - 1">, </span>
                          </span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 附件显示 -->
                  <div v-if="selectedEmail?.attachments && Array.isArray(selectedEmail.attachments) && selectedEmail.attachments.length > 0" class="mb-6">
                    <div class="flex items-center mb-3">
                      <svg class="w-5 h-5 mr-2 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path>
                      </svg>
                      <h4 class="text-sm font-semibold text-gray-900 dark:text-gray-100">附件 ({{ selectedEmail.attachments.length }} 个)</h4>
                    </div>
                    <div class="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/30 dark:to-indigo-900/30 border border-blue-200 dark:border-blue-600 rounded-xl p-4">
                      <div class="space-y-2">
                        <div v-for="(attachment, index) in selectedEmail.attachments" :key="index" 
                             class="flex items-center justify-between bg-white dark:bg-gray-700/80 rounded-lg border border-blue-200 dark:border-blue-600 px-4 py-3 shadow-sm hover:shadow-md transition-all duration-200 hover:border-blue-300 dark:hover:border-blue-500">
                          <div class="flex items-center space-x-3 flex-1 min-w-0">
                            <div class="flex-shrink-0">
                              <svg class="w-6 h-6 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                              </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                              <p class="text-sm font-medium text-gray-900 dark:text-gray-100 truncate">{{ attachment.name }}</p>
                              <div class="flex items-center space-x-2 mt-0.5">
                                <span class="text-xs text-gray-500 dark:text-gray-400">{{ formatFileSize(attachment.size) }}</span>
                                <span v-if="getAttachmentSource(attachment)" class="text-xs text-gray-400 dark:text-gray-500">•</span>
                                <span v-if="getAttachmentSource(attachment)" class="text-xs text-gray-500 dark:text-gray-400">
                                  来自: <span class="text-gray-700 dark:text-gray-300 font-medium">{{ getAttachmentSource(attachment) }}</span>
                                </span>
                              </div>
                            </div>
                          </div>
                          <button @click="downloadAttachment(attachment)" 
                                  class="flex-shrink-0 ml-4 inline-flex items-center px-4 py-2 border border-transparent text-xs font-medium rounded-lg text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 shadow-sm hover:shadow">
                            <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
                            </svg>
                            下载
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 邮件正文（分离显示用户输入和多个引用原文） -->
                  <div class="space-y-4">
                    <!-- 普通邮件：直接显示正文内容 -->
                    <div v-if="parsedEmailContent.quotes.length === 0 && selectedEmail?.body && selectedEmail.body.trim() && !selectedEmail?.error"
                         class="bg-gray-50 dark:bg-gray-700/50 rounded-xl p-6 border border-gray-200 dark:border-gray-600">
                      <div class="text-gray-800 dark:text-gray-200 leading-relaxed whitespace-pre-wrap break-words"
                           style="word-break: break-word; overflow-wrap: break-word;">
                        {{ selectedEmail.body }}
                      </div>
                    </div>
                    
                    <!-- 答复邮件：显示用户回复和引用原文 -->
                    <template v-if="parsedEmailContent.quotes.length > 0 && !selectedEmail?.error">
                      <!-- 用户输入的内容 -->
                      <div v-if="parsedEmailContent.userContent && parsedEmailContent.userContent.trim()" 
                           class="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/30 dark:to-indigo-900/30 rounded-xl p-6 border-2 border-blue-200 dark:border-blue-600 shadow-sm">
                        <div class="flex items-center mb-3">
                          <svg class="w-5 h-5 mr-2 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                          </svg>
                          <h4 class="text-sm font-semibold text-blue-900 dark:text-blue-200">
                            由{{ selectedEmail?.from || '未知用户' }}的回复
                          </h4>
                        </div>
                        <div class="text-gray-800 dark:text-gray-200 leading-relaxed whitespace-pre-wrap break-words bg-white/60 dark:bg-gray-700/60 rounded-lg p-4 border border-blue-100 dark:border-blue-800"
                             style="word-break: break-word; overflow-wrap: break-word;">
                          {{ parsedEmailContent.userContent }}
                        </div>
                      </div>
                      
                      <!-- 多个引用原文（独立显示） -->
                      <div v-for="(quote, index) in parsedEmailContent.quotes" :key="index" 
                           class="bg-gradient-to-br from-gray-50 to-slate-50 dark:from-gray-700 dark:to-gray-700/80 rounded-xl p-6 border-2 border-gray-300 dark:border-gray-600 shadow-sm">
                      <div class="flex items-center justify-between mb-3">
                        <div class="flex items-center">
                          <svg class="w-5 h-5 mr-2 text-gray-600 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"></path>
                          </svg>
                          <h4 class="text-sm font-semibold text-gray-900 dark:text-gray-100">原始邮件 #{{ index + 1 }}</h4>
                        </div>
                        <span class="text-xs text-gray-500 dark:text-gray-400 bg-gray-200 dark:bg-gray-600 px-2 py-1 rounded-full">{{ quote.date || '未知时间' }}</span>
                      </div>
                      
                      <!-- 原始邮件信息 -->
                      <div class="bg-white/80 dark:bg-gray-700/80 rounded-lg p-4 mb-3 border border-gray-200 dark:border-gray-600 space-y-2">
                        <div class="flex items-start">
                          <span class="text-xs font-semibold text-purple-600 dark:text-purple-400 w-16 flex-shrink-0">发件人:</span>
                          <div class="flex flex-wrap gap-1 flex-1">
                            <span v-if="quote.from" 
                                  class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium text-purple-700 dark:text-purple-300 bg-purple-50 dark:bg-purple-900/40 border border-purple-200 dark:border-purple-600 break-all">
                              {{ quote.from }}
                            </span>
                            <span v-else class="text-xs text-gray-500 dark:text-gray-400">未知</span>
                          </div>
                        </div>
                        <div v-if="quote.to" class="flex items-start">
                          <span class="text-xs font-semibold text-blue-600 dark:text-blue-400 w-16 flex-shrink-0">收件人:</span>
                          <div class="flex flex-wrap gap-1 flex-1">
                            <span v-for="(addr, idx) in (Array.isArray(quote.to) ? quote.to : quote.to.split(',').map(a => a.trim()).filter(a => a))" :key="idx"
                                  class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium text-blue-700 dark:text-blue-300 bg-blue-50 dark:bg-blue-900/40 border border-blue-200 dark:border-blue-600 break-all">
                              {{ addr }}
                            </span>
                          </div>
                        </div>
                        <div v-if="quote.cc" class="flex items-start">
                          <span class="text-xs font-semibold text-green-600 dark:text-green-400 w-16 flex-shrink-0">抄送:</span>
                          <div class="flex flex-wrap gap-1 flex-1">
                            <span v-for="(addr, idx) in (Array.isArray(quote.cc) ? quote.cc : quote.cc.split(',').map(a => a.trim()).filter(a => a))" :key="idx"
                                  class="inline-flex items-center px-1.5 py-0.5 rounded text-xs font-medium text-green-700 dark:text-green-300 bg-green-50 dark:bg-green-900/40 border border-green-200 dark:border-green-600 break-all">
                              {{ addr }}
                            </span>
                          </div>
                        </div>
                        <div class="flex items-start">
                          <span class="text-xs font-semibold text-gray-600 dark:text-gray-400 w-16 flex-shrink-0">主题:</span>
                          <span class="text-xs text-gray-900 dark:text-gray-100 break-all flex-1">{{ quote.subject || '无主题' }}</span>
                        </div>
                      </div>
                      
                      <!-- 原始邮件正文 -->
                      <div class="bg-white/60 dark:bg-gray-700/60 rounded-lg p-4 border border-gray-200 dark:border-gray-600 max-h-64 overflow-y-auto">
                        <div class="text-sm text-gray-700 dark:text-gray-300 leading-relaxed whitespace-pre-wrap break-words"
                             style="word-break: break-word; overflow-wrap: break-word;">
                          {{ quote.body || '(无内容)' }}
                        </div>
                      </div>
                      </div>
                    </template>
                    
                    <!-- HTML内容（仅在普通邮件且没有body时显示，经 DOMPurify 消毒防 XSS） -->
                    <div v-if="parsedEmailContent.quotes.length === 0 && sanitizedEmailHtml && (!selectedEmail?.body || !selectedEmail.body.trim()) && !selectedEmail?.error"
                         v-html="sanitizedEmailHtml"
                         class="bg-gray-50 dark:bg-gray-700/50 rounded-xl p-6 border border-gray-200 dark:border-gray-600 text-gray-800 dark:text-gray-200 leading-relaxed break-words"
                         style="word-break: break-word; overflow-wrap: break-word;">
                    </div>
                    
                    <!-- 错误提示（仅在真正有错误且没有内容时显示） -->
                    <div v-if="selectedEmail && selectedEmail.error && parsedEmailContent.quotes.length === 0 && (!selectedEmail.body || !selectedEmail.body.trim()) && (!selectedEmail.html || !selectedEmail.html.trim())" 
                         class="flex items-center justify-center h-32 text-red-400 dark:text-red-300 bg-red-50 dark:bg-red-900/30 rounded-xl border-2 border-red-200 dark:border-red-700">
                      <div class="text-center">
                        <svg class="w-12 h-12 mx-auto mb-2 text-red-300 dark:text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                        </svg>
                        <p class="text-sm font-semibold text-red-600 dark:text-red-400">无法加载邮件详情</p>
                        <p class="text-xs text-red-500 dark:text-red-400 mt-2">{{ selectedEmail.errorMessage || '邮件不存在或您没有权限访问' }}</p>
                        <p class="text-xs text-gray-400 dark:text-gray-500 mt-1">邮件ID: {{ selectedEmail.id }}</p>
                      </div>
                    </div>
                    
                    <!-- 空内容提示（仅在普通邮件时显示，且没有错误） -->
                    <div v-else-if="parsedEmailContent.quotes.length === 0 && selectedEmail && !selectedEmail?.error && (!selectedEmail.body || !selectedEmail.body.trim()) && (!selectedEmail.html || !selectedEmail.html.trim())" 
                         class="flex items-center justify-center h-32 text-gray-400 dark:text-gray-500 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-200 dark:border-gray-600">
                      <div class="text-center">
                        <svg class="w-12 h-12 mx-auto mb-2 text-gray-300 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                        </svg>
                        <p class="text-sm dark:text-gray-300">邮件内容为空</p>
                        <p class="text-xs text-gray-400 dark:text-gray-500 mt-2">邮件ID: {{ selectedEmail.id }}</p>
                      </div>
                    </div>
                    
                    <!-- 加载中（仅在真正加载时显示） -->
                    <div v-else-if="!selectedEmail" class="flex items-center justify-center h-32 text-gray-400 dark:text-gray-500 bg-gray-50 dark:bg-gray-700/50 rounded-xl border border-gray-200 dark:border-gray-600">
                      <div class="text-center">
                        <svg class="w-12 h-12 mx-auto mb-2 text-gray-300 dark:text-gray-500 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                        </svg>
                        <p class="text-sm dark:text-gray-300">邮件内容加载中...</p>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 底部操作栏 -->
                <div class="bg-gray-50 dark:bg-gray-700/50 px-6 py-4 border-t border-gray-200 dark:border-gray-600 flex items-center justify-between flex-wrap gap-3">
                  <!-- 左侧操作按钮 -->
                  <div class="flex items-center space-x-3 flex-wrap">
                    <!-- 答复按钮组（下拉菜单） -->
                    <div class="relative reply-button-group">
                      <button class="inline-flex items-center px-4 py-2.5 text-sm font-medium text-white bg-blue-600 border border-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 transition-all duration-200 shadow-sm hover:shadow-md">
                        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"></path>
                        </svg>
                        答复
                        <svg class="w-4 h-4 ml-1.5 text-white reply-arrow" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                      </button>
                      <div class="absolute left-0 bottom-full mb-2 w-48 bg-white dark:bg-gray-700 rounded-lg shadow-xl border border-gray-200 dark:border-gray-600 opacity-0 invisible reply-dropdown transition-all duration-200 z-50">
                        <div class="py-2">
                          <button @click="openReplyDialog(false)" 
                                  class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-blue-50 dark:hover:bg-blue-900/40 hover:text-blue-700 dark:hover:text-blue-300 flex items-center transition-colors">
                            <svg class="w-5 h-5 mr-3 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 10h10a8 8 0 018 8v2M3 10l6 6m-6-6l6-6"></path>
                            </svg>
                            单独答复
                          </button>
                          <button @click="openReplyDialog(true)" 
                                  class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-blue-50 dark:hover:bg-blue-900/40 hover:text-blue-700 dark:hover:text-blue-300 flex items-center transition-colors">
                            <svg class="w-5 h-5 mr-3 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"></path>
                            </svg>
                            全部答复
                          </button>
                        </div>
                      </div>
                    </div>
                    
                    <!-- 移动到文件夹 -->
                    <div class="relative move-button-group">
                      <button class="inline-flex items-center px-4 py-2.5 text-sm font-medium text-gray-700 dark:text-gray-200 bg-white dark:bg-gray-600 border border-gray-300 dark:border-gray-500 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 dark:focus:ring-offset-gray-700 transition-all duration-200 shadow-sm hover:shadow-md">
                        <svg class="w-4 h-4 mr-2 text-gray-500 dark:text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
                        </svg>
                        移动到
                        <svg class="w-4 h-4 ml-1.5 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                      </button>
                      <div class="absolute left-0 bottom-full mb-2 w-56 bg-white dark:bg-gray-700 rounded-lg shadow-xl border border-gray-200 dark:border-gray-600 opacity-0 invisible move-button-group-hover:opacity-100 move-button-group-hover:visible transition-all duration-200 z-50">
                        <div class="py-2">
                          <div v-if="getAvailableFolders(selectedEmail?.folder || 'inbox', selectedEmail).length === 0" class="px-4 py-2 text-sm text-gray-500 dark:text-gray-400">
                            无可用目标文件夹
                          </div>
                          <button v-for="folder in getAvailableFolders(selectedEmail?.folder || 'inbox', selectedEmail)" 
                                  :key="folder.value"
                                  @click="handleMoveFolderAction(folder.value)"
                                  class="w-full text-left px-4 py-2.5 text-sm text-gray-700 dark:text-gray-200 hover:bg-blue-50 dark:hover:bg-blue-900/40 hover:text-blue-700 dark:hover:text-blue-300 flex items-center transition-colors">
                            <svg class="w-5 h-5 mr-3 text-gray-400 dark:text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" :d="getFolderIcon(folder.value)"></path>
                            </svg>
                            {{ folder.label }}
                          </button>
                        </div>
                      </div>
                    </div>
                    
                    <!-- 删除按钮 -->
                    <button @click="showDeleteConfirmDialog(selectedEmail?.id)" 
                            class="inline-flex items-center px-4 py-2.5 text-sm font-medium text-red-700 dark:text-red-300 bg-red-50 dark:bg-red-900/40 border border-red-200 dark:border-red-600 rounded-lg hover:bg-red-100 dark:hover:bg-red-800/50 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 dark:focus:ring-offset-gray-700 transition-all duration-200 shadow-sm hover:shadow-md">
                      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                      </svg>
                      删除
                    </button>
                  </div>

                  <!-- 右侧关闭按钮 -->
                  <button @click="closeEmailDetail" 
                          class="inline-flex items-center px-6 py-2.5 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 shadow-sm hover:shadow-md">
                    关闭
                  </button>
                </div>
              </div>
            </div>
          </div>
          <!-- 邮件详情模态框结束 -->
          
          <!-- 答复对话框 -->
          <Transition name="fade">
            <div v-if="showReplyDialog" 
                 class="fixed inset-0 z-50 flex items-center justify-center p-4"
                 @click.self="closeReplyDialog">
              <!-- 背景遮罩 -->
              <div class="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity"></div>
              
              <!-- 对话框内容 -->
              <div class="relative bg-white rounded-2xl shadow-2xl max-w-3xl w-full max-h-[90vh] overflow-hidden transform transition-all flex flex-col"
                   @click.stop>
                <!-- 装饰性顶部渐变条 -->
                <div class="h-1 bg-gradient-to-r from-blue-500 via-indigo-500 to-blue-500"></div>
                
                <!-- 头部 -->
                <div class="px-6 py-4 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-indigo-50">
                  <div class="flex items-center justify-between">
                    <h3 class="text-lg font-semibold text-gray-900">答复邮件</h3>
                    <button @click="closeReplyDialog" 
                            class="p-2 text-gray-400 hover:text-gray-600 hover:bg-white rounded-lg transition-all duration-200">
                      <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                    </button>
                  </div>
                </div>
                
                <!-- 内容区域 -->
                <div class="flex-1 overflow-y-auto px-6 py-4">
                  <!-- 答复模式提示 -->
                  <div v-if="isReplyAll" class="mb-4 p-3 bg-blue-50 border border-blue-200 rounded-lg">
                    <div class="flex items-center text-sm text-blue-700">
                      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                      <span>全部答复模式：将发送给原发件人和所有收件人、抄送人</span>
                    </div>
                  </div>
                  
                  <!-- 收件人 -->
                  <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-2">收件人</label>
                    <input v-model="replyTo" 
                           type="text" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="收件人邮箱">
                  </div>
                  
                  <!-- 抄送 -->
                  <div v-if="isReplyAll && replyCC" class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-2">抄送</label>
                    <input v-model="replyCC" 
                           type="text" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="抄送人邮箱（多个邮箱用逗号分隔）">
                  </div>
                  
                  <!-- 主题 -->
                  <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-2">主题</label>
                    <input v-model="replySubject" 
                           type="text" 
                           class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                           placeholder="邮件主题">
                  </div>
                  
                  <!-- 邮件正文（用户输入区域） -->
                  <div class="mb-4">
                    <label class="block text-sm font-medium text-gray-700 mb-2">邮件内容 <span class="text-xs text-gray-500 font-normal">(您的回复)</span></label>
                    <textarea v-model="replyBody" 
                              rows="6"
                              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                              placeholder="在这里输入您的回复内容..."></textarea>
                  </div>
                  
                  <!-- 引用原文（只读，不允许编辑） -->
                  <div class="mb-4">
                    <div class="flex items-center justify-between mb-2">
                      <label class="block text-sm font-medium text-gray-700">
                        引用原文 
                        <span class="text-xs text-gray-500 font-normal">(只读，不可编辑)</span>
                      </label>
                      <button @click="toggleReplyQuote" 
                              class="text-sm text-blue-600 hover:text-blue-700 flex items-center transition-colors">
                        <svg v-if="replyQuoteExpanded" class="w-4 h-4 mr-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7"></path>
                        </svg>
                        <svg v-else class="w-4 h-4 mr-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                        {{ replyQuoteExpanded ? '收起详细信息' : '展开详细信息' }}
                      </button>
                    </div>
                    <!-- 默认显示的文本内容（折叠状态） -->
                    <div v-if="!replyQuoteExpanded" 
                         class="bg-gray-50 border border-gray-200 rounded-lg p-3">
                      <div class="text-xs text-gray-500 mb-2">
                        <div class="font-semibold mb-1">原始邮件信息：</div>
                        <div>发件人：{{ selectedEmail?.from }}</div>
                        <div>时间：{{ formatReplyDate(selectedEmail?.date) }}</div>
                        <div>主题：{{ selectedEmail?.subject }}</div>
                      </div>
                      <div class="text-xs text-gray-400 mt-2 italic">
                        点击"展开详细信息"查看完整邮件内容
                      </div>
                    </div>
                    <!-- 展开时显示的完整内容（只读） -->
                    <Transition name="slide-fade">
                      <div v-if="replyQuoteExpanded" 
                           class="bg-gray-50 border border-gray-200 rounded-lg p-4 max-h-64 overflow-y-auto">
                        <div class="text-xs text-gray-500 mb-2">
                          <div class="font-semibold mb-1">原始邮件信息：</div>
                          <div>发件人：{{ selectedEmail?.from }}</div>
                          <div>时间：{{ formatReplyDate(selectedEmail?.date) }}</div>
                          <div>主题：{{ selectedEmail?.subject }}</div>
                        </div>
                        <div class="border-t border-gray-300 pt-3 mt-3">
                          <div class="text-sm text-gray-700 whitespace-pre-wrap break-words select-none cursor-default bg-white/50 p-2 rounded border border-gray-200">{{ replyQuote }}</div>
                        </div>
                      </div>
                    </Transition>
                  </div>
                  
                  <!-- 附件上传 -->
                  <div class="mb-4">
                    <label class="block text-sm font-semibold text-gray-700 mb-2 flex items-center">
                      <svg class="w-4 h-4 mr-1.5 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13"></path>
                      </svg>
                      附件 <span class="text-gray-400 text-xs font-normal ml-2">可选</span>
                    </label>
                    <div class="border-2 border-dashed border-gray-300 rounded-xl p-4 hover:border-indigo-400 hover:bg-gradient-to-br hover:from-indigo-50/30 hover:to-purple-50/30 transition-all duration-300 group cursor-pointer">
                      <input type="file" 
                             ref="replyFileInput" 
                             @change="handleReplyFileSelect" 
                             multiple 
                             class="hidden" 
                             accept=".pdf,.md,.doc,.docx,.txt,.jpg,.jpeg,.png,.gif,.zip,.rar" />
                      <div @click="replyFileInput?.click()" class="text-center">
                        <div class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-gradient-to-br from-indigo-100 to-purple-100 mb-3 group-hover:from-indigo-200 group-hover:to-purple-200 transition-all duration-300 group-hover:scale-110">
                          <svg class="w-6 h-6 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                          </svg>
                        </div>
                        <p class="text-sm font-medium text-gray-700 mb-1">
                          <span class="text-indigo-600 hover:text-indigo-700">点击上传文件</span>
                          <span class="text-gray-500 mx-2">或</span>
                          <span class="text-indigo-600 hover:text-indigo-700">拖拽文件到此处</span>
                        </p>
                        <p class="text-xs text-gray-500 mt-1">支持 PDF, MD, DOC, TXT, 图片, 压缩包等格式</p>
                        <p class="text-xs text-orange-500 mt-1 font-medium">单文件最大10MB，总大小不超过50MB</p>
                      </div>
                    </div>
                    
                    <!-- 原始邮件附件（只读） -->
                    <div v-if="replyOriginalAttachments.length > 0" class="mt-3">
                      <h4 class="text-xs font-semibold text-gray-700 mb-2 flex items-center">
                        <svg class="w-3 h-3 mr-1 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        原始邮件附件 ({{ replyOriginalAttachments.length }}) <span class="text-xs text-gray-400 font-normal ml-1">(将自动包含)</span>
                      </h4>
                      <div class="space-y-2">
                        <div v-for="(attachment, index) in replyOriginalAttachments" :key="`original-${index}`" 
                             class="flex items-center justify-between bg-gradient-to-r from-gray-50/50 to-slate-50/50 rounded-lg px-3 py-2 border border-gray-200/50">
                          <div class="flex items-center space-x-2 flex-1 min-w-0">
                            <div class="flex-shrink-0 w-8 h-8 rounded-lg bg-gradient-to-br from-gray-100 to-slate-100 flex items-center justify-center">
                              <svg class="w-4 h-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                              </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                              <span class="text-xs font-medium text-gray-700 block truncate">{{ attachment.name }}</span>
                              <div class="flex items-center space-x-2 mt-0.5">
                                <span class="text-xs text-gray-500">{{ formatFileSize(attachment.size || 0) }}</span>
                                <span v-if="attachment.from" class="text-xs text-gray-400">•</span>
                                <span v-if="attachment.from" class="text-xs text-gray-500">来自: <span class="text-gray-700 font-medium">{{ attachment.from }}</span></span>
                              </div>
                            </div>
                          </div>
                          <span class="ml-2 px-2 py-0.5 text-xs text-gray-500 bg-gray-100 rounded border border-gray-200 whitespace-nowrap">
                            原始
                          </span>
                        </div>
                      </div>
                    </div>
                    
                    <!-- 新添加的附件列表 -->
                    <div v-if="replyAttachments.length > 0" class="mt-3">
                      <h4 class="text-xs font-semibold text-gray-700 mb-2 flex items-center">
                        <svg class="w-3 h-3 mr-1 text-indigo-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                        </svg>
                        新添加的附件 ({{ replyAttachments.length }})
                      </h4>
                      <div class="space-y-2">
                        <div v-for="(file, index) in replyAttachments" :key="`new-${index}`" 
                             class="flex items-center justify-between bg-gradient-to-r from-indigo-50/50 to-purple-50/50 hover:from-indigo-100/50 hover:to-purple-100/50 rounded-lg px-3 py-2 transition-all duration-200 border border-indigo-200/50 hover:border-indigo-300">
                          <div class="flex items-center space-x-2 flex-1 min-w-0">
                            <div class="flex-shrink-0 w-8 h-8 rounded-lg bg-gradient-to-br from-indigo-100 to-purple-100 flex items-center justify-center">
                              <svg class="w-4 h-4 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                              </svg>
                            </div>
                            <div class="flex-1 min-w-0">
                              <span class="text-xs font-medium text-gray-800 block truncate">{{ file.name }}</span>
                              <span class="text-xs text-gray-500">{{ formatFileSize(file.size) }}</span>
                            </div>
                          </div>
                          <button @click="removeReplyAttachment(index)" 
                                  class="ml-2 p-1.5 rounded-lg text-gray-400 hover:text-red-600 hover:bg-red-50 transition-all duration-200 flex-shrink-0"
                                  title="删除附件">
                            <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                            </svg>
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
                
                <!-- 底部操作栏 -->
                <!-- 答复邮件发送进度条 -->
                <div v-if="sendingReply" class="px-6 py-4 border-t border-gray-200 bg-blue-50">
                  <div class="mb-3">
                    <div class="flex items-center justify-between mb-2">
                      <span class="text-sm font-medium text-blue-800">发送进度</span>
                      <span>{{ replyProgress }}%</span>
                    </div>
                    <div class="w-full bg-blue-200 rounded-full h-2 mb-2">
                      <div class="bg-blue-600 h-2 rounded-full transition-all duration-500 ease-out" :style="{ width: replyProgress + '%' }"></div>
                    </div>
                    
                    <!-- 时间信息 -->
                    <div class="flex items-center justify-between text-xs text-blue-700 mt-2">
                      <div class="flex items-center space-x-4">
                        <span>已用时间: <span class="font-medium text-blue-800">{{ formatTime(replyElapsedTime) }}</span></span>
                        <span v-if="replyEstimatedTime > 0">预计剩余: <span class="font-medium text-blue-800">{{ formatTime(replyEstimatedTime) }}</span></span>
                      </div>
                      <div class="text-gray-500">
                        {{ Math.round(replyElapsedTime + replyEstimatedTime) }}秒总预计
                      </div>
                    </div>
                    <div class="text-xs text-gray-600 mt-2">
                      <span v-if="replyAttachments.length > 0 || replyOriginalAttachments.length > 0">
                        包含 {{ replyAttachments.length + replyOriginalAttachments.length }} 个附件
                        <span v-if="replyIsLargeFile" class="text-orange-600 font-medium">（大文件，预计需要更长时间）</span>
                        <span v-if="!replyIsLargeFile">，正在处理中...</span>
                      </span>
                      <span v-if="replyAttachments.length === 0 && replyOriginalAttachments.length === 0">正在处理邮件发送</span>
                    </div>
                  </div>
                </div>
                
                <div class="px-6 py-4 border-t border-gray-200 bg-gray-50 flex items-center justify-end space-x-3">
                  <button @click="closeReplyDialog" 
                          :disabled="sendingReply"
                          class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed">
                    取消
                  </button>
                  <button @click="sendReply" 
                          :disabled="sendingReply"
                          class="px-6 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed">
                    <span v-if="sendingReply">发送中...</span>
                    <span v-else>发送</span>
                  </button>
                </div>
              </div>
            </div>
          </Transition>
          
          <!-- 删除确认对话框 -->
          <Transition name="fade">
            <div v-if="showDeleteConfirm" 
                 class="fixed inset-0 z-50 flex items-center justify-center p-4"
                 @click.self="cancelDeleteEmail">
              <!-- 背景遮罩 -->
              <div class="absolute inset-0 bg-black/40 backdrop-blur-sm transition-opacity"></div>
              
              <!-- 对话框内容 -->
              <div class="relative bg-white rounded-2xl shadow-2xl max-w-md w-full transform transition-all"
                   @click.stop>
                <!-- 装饰性顶部渐变条 -->
                <div class="h-1 bg-gradient-to-r from-red-500 via-orange-500 to-red-500 rounded-t-2xl"></div>
                
                <!-- 内容区域 -->
                <div class="p-6">
                  <!-- 图标和标题 -->
                  <div class="flex items-center space-x-4 mb-4">
                    <div class="flex-shrink-0 w-12 h-12 rounded-full bg-red-100 flex items-center justify-center">
                      <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                      </svg>
                    </div>
                    <div class="flex-1">
                      <h3 class="text-lg font-semibold text-gray-900">删除邮件</h3>
                      <p class="text-sm text-gray-500 mt-1">此操作将把邮件移动到已删除文件夹</p>
                    </div>
                  </div>
                  
                  <!-- 提示信息 -->
                  <div class="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-6">
                    <div class="flex items-start space-x-3">
                      <svg class="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                      </svg>
                      <div class="flex-1">
                        <p class="text-sm font-medium text-amber-800">确定要删除这封邮件吗？</p>
                        <p class="text-xs text-amber-700 mt-1">邮件将被移动到已删除文件夹，您可以稍后恢复。</p>
                      </div>
                    </div>
                  </div>
                  
                  <!-- 按钮组 -->
                  <div class="flex items-center justify-end space-x-3">
                    <button @click="cancelDeleteEmail"
                            class="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-all duration-200 shadow-sm hover:shadow-md">
                      取消
                    </button>
                    <button @click="confirmDeleteEmail"
                            class="px-5 py-2.5 text-sm font-medium text-white bg-gradient-to-r from-red-600 to-red-700 rounded-lg hover:from-red-700 hover:to-red-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-all duration-200 shadow-md hover:shadow-lg transform hover:scale-105">
                      <span class="flex items-center space-x-2">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                        <span>确认删除</span>
                      </span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </Transition>
          
          <!-- 右侧主内容区域结束 -->
          </div>
        <!-- 文件夹侧边栏结束 -->
        </div>
      </div>

    <!-- 文件夹管理对话框 -->
    <div v-if="showFolderManageDialog" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-full max-w-2xl shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">管理文件夹</h3>
            <button @click="showFolderManageDialog = false" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
          
          <!-- 创建新文件夹 -->
          <div class="mb-6 p-4 bg-gray-50 rounded-lg">
            <h4 class="text-sm font-medium text-gray-700 mb-3">创建新文件夹</h4>
            <div class="flex space-x-2">
              <input v-model="newFolderName" 
                     @keyup.enter="createCustomFolder"
                     placeholder="文件夹名称（英文、数字、下划线、连字符）"
                     class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
              <input v-model="newFolderDisplayName" 
                     @keyup.enter="createCustomFolder"
                     placeholder="显示名称（可选）"
                     class="flex-1 px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
              <button @click="createCustomFolder" 
                      class="px-4 py-2 bg-indigo-600 text-white rounded-md hover:bg-indigo-700 transition-colors text-sm font-medium">
                创建
              </button>
            </div>
            <p v-if="folderManageError" class="mt-2 text-sm text-red-600">{{ folderManageError }}</p>
          </div>
          
          <!-- 文件夹列表 -->
          <div class="max-h-96 overflow-y-auto">
            <div v-if="customFoldersList.length === 0" class="text-center py-8 text-gray-500">
              <svg class="w-12 h-12 mx-auto mb-3 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
              </svg>
              <p>暂无自定义文件夹</p>
            </div>
            <div v-else class="space-y-2">
              <div v-for="folder in customFoldersList" :key="folder.id" 
                   class="flex items-center justify-between p-3 bg-white border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors">
                <div class="flex items-center space-x-3 flex-1 min-w-0">
                  <svg class="w-5 h-5 text-indigo-600 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z"></path>
                  </svg>
                  <div class="flex-1 min-w-0">
                    <p class="text-sm font-medium text-gray-900 truncate">{{ folder.display_name || folder.name }}</p>
                    <p class="text-xs text-gray-500 truncate">{{ folder.name }}</p>
                  </div>
                </div>
                <div class="flex items-center space-x-2 ml-4">
                  <button @click="editCustomFolder(folder)" 
                          class="p-2 text-indigo-600 hover:bg-indigo-50 rounded-md transition-colors"
                          title="重命名">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                    </svg>
                  </button>
                  <button @click="deleteCustomFolder(folder)" 
                          class="p-2 text-red-600 hover:bg-red-50 rounded-md transition-colors"
                          title="删除">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 操作按钮 -->
          <div class="mt-6 flex justify-end">
            <button @click="showFolderManageDialog = false" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors">
              关闭
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 编辑文件夹对话框 -->
    <div v-if="editingFolder" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">编辑文件夹</h3>
            <button @click="editingFolder = null" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
          
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">文件夹名称</label>
              <input v-model="editFolderName" 
                     placeholder="文件夹名称（英文、数字、下划线、连字符）"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">显示名称</label>
              <input v-model="editFolderDisplayName" 
                     placeholder="显示名称（可选）"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-indigo-500 text-sm">
            </div>
            <p v-if="folderManageError" class="text-sm text-red-600">{{ folderManageError }}</p>
          </div>
          
          <div class="mt-6 flex justify-end space-x-3">
            <button @click="editingFolder = null" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors">
              取消
            </button>
            <button @click="updateCustomFolder" 
                    class="px-4 py-2 text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 rounded-md transition-colors">
              保存
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 用户选择器模态框 -->
    <div v-if="showUserSelectorModal" class="fixed inset-0 bg-gray-600 bg-opacity-50 overflow-y-auto h-full w-full z-50">
      <div class="relative top-20 mx-auto p-5 border w-96 shadow-lg rounded-md bg-white">
        <div class="mt-3">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-lg font-medium text-gray-900">
              {{ userSelectorType === 'to' ? '选择收件人' : '选择抄送用户' }}
            </h3>
            <button @click="closeUserSelector" class="text-gray-400 hover:text-gray-600">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
          
          <!-- 用户列表 -->
          <div class="max-h-64 overflow-y-auto">
            <div v-if="loadingUsers" class="text-center py-4">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
              <p class="text-sm text-gray-500 mt-2">加载用户中...</p>
            </div>
            <div v-else-if="users.length === 0" class="text-center py-4 text-gray-500">
              暂无用户
            </div>
            <div v-else class="space-y-2">
              <div v-for="user in users" :key="user.id" 
                   @click="selectUser(user)"
                   class="flex items-center justify-between p-3 hover:bg-gray-50 rounded-lg cursor-pointer transition-colors">
                <div class="flex items-center space-x-3">
                  <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                    <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                    </svg>
                  </div>
                  <div>
                    <p class="text-sm font-medium text-gray-900">{{ user.username }}</p>
                    <p class="text-xs text-gray-500">{{ user.email }}</p>
                  </div>
                </div>
                <div v-if="userSelectorType === 'cc' && isUserSelected(user)" 
                     class="text-green-600">
                  <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                  </svg>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 操作按钮 -->
          <div class="mt-4 flex justify-end space-x-3">
            <button @click="closeUserSelector" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors">
              取消
            </button>
            <button v-if="userSelectorType === 'cc'" 
                    @click="confirmCCSelection"
                    class="px-4 py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 rounded-md transition-colors">
              确认选择 ({{ selectedCCUsers.length }})
            </button>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import DOMPurify from 'dompurify'
import { userLogger } from '../utils/userLogger'
import { activityTracker } from '../utils/activityTracker'
import Layout from '../components/Layout.vue'

// 数据类型定义
interface Attachment {
  id?: number
  name: string
  type: string
  size: number
  content?: string  // Base64
  is_inline?: boolean
}

interface EmailRecipients {
  to: string[]
  cc: string[]
  bcc: string[]
}

interface EmailMetadata {
  reply_to?: string
  in_reply_to?: string
  thread_id?: string
  spam_score?: number
  virus_status?: string
  encryption_status?: string
  signature_status?: string
}

interface Email {
  id: number
  from: string
  to: string  // 保留向后兼容
  cc?: string  // 保留向后兼容
  subject: string
  body: string
  html?: string
  date: string
  read: boolean
  folder?: string  // 新增：文件夹名称
  size: number
  attachments?: Attachment[]  // 确保为数组
  recipients?: EmailRecipients  // 新增：多收件人
  metadata?: EmailMetadata  // 新增：元数据
}

const view = ref<'inbox'|'sent'|'drafts'|'trash'|'spam'|'compose'>('inbox')
const to = ref('')
const cc = ref('')
const subject = ref('')
const body = ref('')
const attachments = ref<File[]>([])
const notice = ref('')
const noticeType = ref<'success'|'error'|'info'>('info')
const draftAutoSaveEnabled = ref(true) // 是否启用自动保存草稿
const draftAutoSaveInterval = ref<NodeJS.Timeout | null>(null) // 自动保存定时器
const draftSaved = ref(false) // 草稿是否已保存
const editingDraftId = ref<number | null>(null) // 当前编辑的草稿ID

// 邮件相关状态
const emails = ref([])
const emailsLoading = ref(false)
const selectedEmail = ref(null)
const showEmailDetail = ref(false)
const currentLoadRequestId = ref(0) // 当前加载请求ID，用于防止竞态条件
const sending = ref(false)
const sendingProgress = ref(0)
const isLargeFile = ref(false)
const estimatedTime = ref(0) // 预计剩余时间（秒）
const elapsedTime = ref(0) // 已用时间（秒）
const startTime = ref(0) // 开始时间戳
const unreadCount = ref(0) // 收件箱未读数（与 Layout 未读角标一致）；仅收件箱显示侧栏计数
const currentPage = ref(1) // 当前页码
const pageSize = ref(8) // 每页显示数量
const totalEmails = ref(0) // 总邮件数
const unreadCountLoading = ref(false)
const mailStats = ref({
  inbox: { total: 0, unread: 0, read: 0, size: 0 },
  sent: { total: 0, unread: 0, read: 0, size: 0 },
  drafts: { total: 0, unread: 0, read: 0, size: 0 },
  trash: { total: 0, unread: 0, read: 0, size: 0 },
  spam: { total: 0, unread: 0, read: 0, size: 0 }
})

// 文件夹状态
const folders = ref<any[]>([])

// 自定义文件夹管理
const showFolderManageDialog = ref(false)
const editingFolder = ref<any>(null)
const editFolderName = ref('')
const editFolderDisplayName = ref('')
const newFolderName = ref('')
const newFolderDisplayName = ref('')
const showDeleteConfirm = ref(false)
const emailToDelete = ref<number | string | null>(null)

// 答复相关状态
const showReplyDialog = ref(false)
const replyTo = ref('')
const replyCC = ref('')
const replySubject = ref('')
const replyBody = ref('') // 用户输入的新回复内容（可编辑）
const replyQuote = ref('') // 引用原文（只读）
const replyQuoteExpanded = ref(false)
const sendingReply = ref(false)
const replyProgress = ref(0) // 答复邮件发送进度
const replyIsLargeFile = ref(false) // 答复邮件是否为大文件
const replyEstimatedTime = ref(0) // 答复邮件预计剩余时间（秒）
const replyElapsedTime = ref(0) // 答复邮件已用时间（秒）
const replyStartTime = ref(0) // 答复邮件开始时间戳
const isReplyAll = ref(false) // 是否为全部答复模式
const replyAttachments = ref<File[]>([]) // 答复邮件的新附件列表
const replyOriginalAttachments = ref<(Attachment & { from?: string })[]>([]) // 原始邮件的附件列表（只读，包含发件人信息）
const replyFileInput = ref<HTMLInputElement | null>(null) // 答复邮件的文件输入引用
const folderManageError = ref('')
const currentCustomFolder = ref<string | null>(null)

// 计算自定义文件夹列表
const customFoldersList = computed(() => {
  // 过滤用户自定义文件夹，确保 folder_type 为 'user' 且 is_active 不为 0
  // 兼容缺少 folder_type 的情况（新创建的文件夹可能缺少此字段）
  return folders.value.filter((f: any) => {
    const isUserFolder = (f.folder_type === 'user' || (f.folder_type === undefined && f.user_id !== undefined && f.user_id !== null))
    const isActive = f.is_active !== 0 && f.is_active !== false && f.is_active !== null && f.is_active !== undefined
    return isUserFolder && isActive
  })
})

// 用户选择器相关状态
const showUserSelectorModal = ref(false)
const userSelectorType = ref<'to'|'cc'>('to')
const users = ref([])
const loadingUsers = ref(false)
const selectedCCUsers = ref([])

// 公共判断：未读（后端可能返回 0/1 或 '0'/'1' 或 布尔）
const isUnread = (email: any) => {
  if (!email) return false
  // 优先检查 read_status 字段（后端返回的标准字段），如果没有则检查 read 字段（兼容旧数据）
  const v = email.read_status !== undefined ? email.read_status : email.read
  // 将字符串/数字统一转换
  if (typeof v === 'string') return v === '0' || v.toLowerCase() === 'false'
  if (typeof v === 'number') return v === 0
  return !v
}

// 分页计算属性
const totalPages = computed(() => Math.ceil(totalEmails.value / pageSize.value))
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, totalEmails.value))
const paginatedEmails = computed(() => {
  return emails.value.slice(startIndex.value, endIndex.value)
})

// 可见页码计算
const visiblePages = computed(() => {
  const pages: number[] = []
  const maxVisible = 5
  const start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  const end = Math.min(totalPages.value, start + maxVisible - 1)
  
  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// 服务状态检查
const serviceStatus = ref({
  mail_system_ready: false,
  services: {
    postfix: false,
    dovecot: false,
    named: false,
    mariadb: false
  },
  dns: {
    dns_configured: false,
    domain: null,
    mail_domain: null
  },
  database: {
    db_configured: false
  },
  recommendations: []
})
const showServiceWarning = ref(false)
const serviceCheckLoading = ref(false)

// 管理员邮箱信息
const adminEmail = ref('xm@localhost')

// 当前用户邮箱（用于判断抄送标记）
const currentUserEmail = ref<string | null>(null)

// 广播消息
const broadcastMessage = ref('')
const scrollDuration = ref(20) // 轮播动画时长（秒）
const windowWidth = ref(window.innerWidth)

// 判断是否需要滚动（消息较长时才需要滚动）
const needsScroll = computed(() => {
  if (!broadcastMessage.value) return false
  // 简化判断：如果消息长度超过一定字符数，则需要滚动
  // 考虑中文字符和英文字符的混合，使用字符数作为判断标准
  // 大约30个字符以上的消息需要滚动（可以根据实际情况调整）
  const minLengthForScroll = 30
  return broadcastMessage.value.length > minLengthForScroll
})

// 监听窗口大小变化
const updateWindowWidth = () => {
  windowWidth.value = window.innerWidth
}

// 搜索相关状态
const searchQuery = ref('')
const searchLoading = ref(false)
const isSearchMode = ref(false) // 是否处于搜索模式

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
      }
    }
  } catch (error) {
    console.warn('获取管理员邮箱失败:', error)
  }
}

// 当前用户信息
const currentUser = computed(() => {
  const apiAuth = sessionStorage.getItem('apiAuth')
  if (!apiAuth) return null
  
  try {
    const credentials = atob(apiAuth).split(':')
    return credentials[0] || null
  } catch {
    return null
  }
})

// 获取当前用户的完整邮箱地址
const getCurrentUserEmail = async () => {
  const username = currentUser.value
  if (!username) return 'unknown@localhost'
  
  // 所有用户都从后端获取真实邮箱地址（包括管理员xm）
  try {
    const response = await fetch('/api/user-email', {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.email) {
        console.log(`获取到用户邮箱: ${data.email}`)
        return data.email
      }
    }
  } catch (error) {
    console.error('获取用户邮箱失败:', error)
  }
  
  // 如果获取失败，使用默认值（但记录警告）
  console.warn(`获取用户邮箱失败，使用默认值: ${username}@localhost`)
  return `${username}@localhost`
}

// 判断发件人是否为系统管理员
function isAdminSender(fromAddr: string | null | undefined) {
  if (!fromAddr) return false
  const v = String(fromAddr).toLowerCase()
  // system@localhost 应该被识别为系统通知，不是管理员
  if (v === 'system@localhost') return false
  const adminEmailLower = adminEmail.value.toLowerCase()
  return v === adminEmailLower || v.startsWith('系统管理员<')
}

// 检查是否为系统通知邮件
function isSystemNotification(fromAddr: string | null | undefined) {
  if (!fromAddr) return false
  const v = String(fromAddr).toLowerCase()
  const isSystem = v === 'system@localhost'
  if (isSystem) {
    console.log('检测到系统通知邮件:', fromAddr)
  }
  return isSystem
}

// 判断当前用户是否是抄送收件人
function isCurrentUserCC(email: any): boolean {
  if (!currentUserEmail.value || !email) return false
  
  const userEmail = currentUserEmail.value.toLowerCase().trim()
  
  // 检查 recipients.cc 数组
  if (email.recipients && email.recipients.cc && Array.isArray(email.recipients.cc)) {
    const isInCC = email.recipients.cc.some((addr: string) => {
      return addr && addr.toLowerCase().trim() === userEmail
    })
    if (isInCC) {
      // 同时检查用户不在 to 列表中（如果用户在 to 列表中，不应该显示抄送标记）
      if (email.recipients.to && Array.isArray(email.recipients.to)) {
        const isInTo = email.recipients.to.some((addr: string) => {
          return addr && addr.toLowerCase().trim() === userEmail
        })
        // 如果用户在 to 列表中，不显示抄送标记
        if (isInTo) return false
      }
      return true
    }
  }
  
  // 向后兼容：检查旧的 cc 字段（字符串格式）
  if (email.cc && typeof email.cc === 'string') {
    const ccAddresses = email.cc.split(',').map((addr: string) => addr.trim().toLowerCase())
    if (ccAddresses.includes(userEmail)) {
      // 检查用户是否在 to 列表中
      if (email.to && typeof email.to === 'string') {
        const toAddresses = email.to.split(',').map((addr: string) => addr.trim().toLowerCase())
        if (toAddresses.includes(userEmail)) return false
      }
      return true
    }
  }
  
  return false
}

// 权限检查
const isAdmin = computed(() => {
  const apiAuth = sessionStorage.getItem('apiAuth')
  if (!apiAuth) return false
  
  try {
    const credentials = atob(apiAuth).split(':')
    const username = credentials[0]
    // 检查用户名是否为管理员（与Layout.vue保持一致）
    return username && username.toLowerCase() === 'xm'
  } catch {
    return false
  }
})

// 侧边栏控制现在由Layout组件管理

// tabClass 函数已被新的美化UI设计替代

// 处理文件选择
function handleFileSelect(event: Event) {
  try {
    const target = event.target as HTMLInputElement
    if (!target || !target.files) {
      console.warn('文件选择事件目标无效')
      return
    }
    
    const newFiles = Array.from(target.files)
    if (newFiles.length === 0) {
      console.warn('没有选择文件')
      return
    }
    
    const maxSize = 10 * 1024 * 1024 // 10MB限制
    
    // 检查文件大小
    const oversizedFiles = newFiles.filter(file => file.size > maxSize)
    if (oversizedFiles.length > 0) {
      notice.value = `文件 ${oversizedFiles.map(f => f.name).join(', ')} 超过10MB限制，已跳过`
      noticeType.value = 'warning'
    }
    
    // 只添加符合大小限制的文件
    const validFiles = newFiles.filter(file => file.size <= maxSize)
    
    if (validFiles.length === 0) {
      notice.value = '没有有效的文件可以添加'
      noticeType.value = 'warning'
      return
    }
    
    // 检查是否有重复文件
    const existingNames = new Set(attachments.value.map(f => f.name))
    const duplicateFiles = validFiles.filter(file => existingNames.has(file.name))
    if (duplicateFiles.length > 0) {
      notice.value = `文件 ${duplicateFiles.map(f => f.name).join(', ')} 已存在，已跳过`
      noticeType.value = 'warning'
    }
    
    const newValidFiles = validFiles.filter(file => !existingNames.has(file.name))
    attachments.value = [...attachments.value, ...newValidFiles]
    
    // 检查总大小
    const totalSize = attachments.value.reduce((sum, file) => sum + file.size, 0)
    if (totalSize > 50 * 1024 * 1024) { // 50MB总限制
      notice.value = '附件总大小超过50MB，建议分批发送'
      noticeType.value = 'warning'
    } else if (newValidFiles.length > 0) {
      notice.value = `已添加 ${newValidFiles.length} 个附件`
      noticeType.value = 'success'
      setTimeout(() => {
        if (notice.value === `已添加 ${newValidFiles.length} 个附件`) {
          notice.value = ''
        }
      }, 2000)
    }
    
    // 重置文件输入，允许重复选择同一文件
    if (target) {
      target.value = ''
    }
  } catch (error) {
    console.error('处理文件选择时出错:', error)
    notice.value = `文件选择失败: ${error instanceof Error ? error.message : '未知错误'}`
    noticeType.value = 'error'
  }
}

// 移除附件
function removeAttachment(index: number) {
  attachments.value.splice(index, 1)
}

// 格式化文件大小
function formatFileSize(bytes: number): string {
  if (bytes === 0) return '0 Bytes'
  const k = 1024
  const sizes = ['Bytes', 'KB', 'MB', 'GB']
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
}

// 格式化时间显示
function formatTime(seconds: number): string {
  if (seconds < 60) {
    return `${Math.round(seconds)}秒`
  } else if (seconds < 3600) {
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = Math.round(seconds % 60)
    return `${minutes}分${remainingSeconds}秒`
  } else {
    const hours = Math.floor(seconds / 3600)
    const minutes = Math.floor((seconds % 3600) / 60)
    return `${hours}小时${minutes}分钟`
  }
}

// 分页相关方法
function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function resetPagination() {
  currentPage.value = 1
}

// 从系统设置加载分页大小
function loadPageSizeFromSettings() {
  const savedPageSize = localStorage.getItem('mailPageSize')
  if (savedPageSize) {
    pageSize.value = parseInt(savedPageSize)
  }
}

// 保存分页大小到localStorage
function savePageSizeToSettings() {
  localStorage.setItem('mailPageSize', pageSize.value.toString())
}

// 将文件转换为Base64
function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    try {
      if (!file) {
        reject(new Error('文件对象为空'))
        return
      }
      
      const reader = new FileReader()
      reader.onload = () => {
        try {
          const result = reader.result as string
          if (!result) {
            reject(new Error('文件读取结果为空'))
            return
          }
          // 移除data:type;base64,前缀，只保留Base64内容
          const base64 = result.split(',')[1]
          if (!base64) {
            reject(new Error('Base64转换失败'))
            return
          }
          resolve(base64)
        } catch (error) {
          console.error('Base64转换错误:', error)
          reject(error)
        }
      }
      reader.onerror = (error) => {
        console.error('文件读取错误:', error)
        reject(new Error(`文件读取失败: ${file.name}`))
      }
      reader.onabort = () => {
        reject(new Error(`文件读取被中断: ${file.name}`))
      }
      reader.readAsDataURL(file)
    } catch (error) {
      console.error('文件处理错误:', error)
      reject(error)
    }
  })
}

// 下载附件
function downloadAttachment(attachment: any) {
  if (!attachment || !attachment.name) {
    alert('附件信息不完整')
    return
  }
  
  // 创建下载链接
  const link = document.createElement('a')
  link.href = `data:${attachment.type || 'application/octet-stream'};base64,${attachment.content || ''}`
  link.download = attachment.name
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
}

// 清空表单
// 保存草稿
async function saveDraft() {
  if (!subject.value && !body.value) {
    notice.value = '请输入主题或内容才能保存草稿'
    noticeType.value = 'error'
    return
  }
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const userEmail = await getCurrentUserEmail()
    
    if (!userEmail) {
      notice.value = '无法获取用户邮箱地址'
      noticeType.value = 'error'
      return
    }
    
    const response = await fetch('/api/mail/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        to: to.value || '',
        cc: cc.value || (selectedCCUsers.value.length > 0 ? selectedCCUsers.value.map(user => user.email).join(', ') : ''),
        subject: subject.value || '(无主题)',
        body: body.value || '',
        from: userEmail,
        folder: 'drafts', // 保存到草稿箱
        attachments: attachments.value.length > 0 ? await Promise.all(attachments.value.map(async (file, index) => {
          try {
            const base64Content = await fileToBase64(file)
            return {
              name: file.name,
              size: file.size,
              type: file.type || 'application/octet-stream',
              content: base64Content
            }
          } catch (error) {
            console.error(`附件 ${file.name} 转换失败:`, error)
            notice.value = `附件 ${file.name} 处理失败: ${error instanceof Error ? error.message : '未知错误'}`
            noticeType.value = 'error'
            throw error
          }
        })) : []
      })
    })
    
    const data = await response.json()
    
    if (response.ok && data.success) {
      draftSaved.value = true
      notice.value = '草稿已保存'
      noticeType.value = 'success'
      setTimeout(() => {
        draftSaved.value = false
      }, 3000)
    } else {
      notice.value = data.error || '保存草稿失败'
      noticeType.value = 'error'
    }
  } catch (error) {
    console.error('Error saving draft:', error)
    notice.value = '保存草稿时出错'
    noticeType.value = 'error'
  }
}

// 从Base64恢复附件
async function base64ToFile(base64: string, filename: string, mimeType: string): Promise<File> {
  // 移除data URL前缀（如果有）
  const base64Data = base64.includes(',') ? base64.split(',')[1] : base64
  
  // 将Base64转换为二进制
  const byteCharacters = atob(base64Data)
  const byteNumbers = new Array(byteCharacters.length)
  for (let i = 0; i < byteCharacters.length; i++) {
    byteNumbers[i] = byteCharacters.charCodeAt(i)
  }
  const byteArray = new Uint8Array(byteNumbers)
  const blob = new Blob([byteArray], { type: mimeType })
  
  // 创建File对象
  return new File([blob], filename, { type: mimeType })
}

// 编辑草稿
async function editDraft(email: any) {
  try {
    // 获取完整的草稿详情
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/${email.id}`, {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (!response.ok) {
      notice.value = '获取草稿详情失败'
      noticeType.value = 'error'
      return
    }
    
    const apiResponse = await response.json()
    const draftDetail = apiResponse.email || apiResponse
    
    // 设置当前编辑的草稿ID
    editingDraftId.value = draftDetail.id
    
    // 加载草稿内容到表单
    to.value = draftDetail.to || ''
    cc.value = draftDetail.cc || ''
    subject.value = draftDetail.subject || ''
    body.value = draftDetail.body || draftDetail.html || ''
    
    
    // 处理收件人选择器（如果有多个收件人）
    if (draftDetail.recipients && draftDetail.recipients.to) {
      // 如果recipients.to是数组，可以在这里处理
      if (Array.isArray(draftDetail.recipients.to)) {
        to.value = draftDetail.recipients.to.join(', ')
      }
    }
    
    // 处理抄送选择器
    if (draftDetail.recipients && draftDetail.recipients.cc) {
      if (Array.isArray(draftDetail.recipients.cc)) {
        cc.value = draftDetail.recipients.cc.join(', ')
      }
    }
    
    // 处理附件
    attachments.value = []
    if (draftDetail.attachments && draftDetail.attachments.length > 0) {
      try {
        // 附件可能是字符串（JSON）或数组
        let attachmentList = draftDetail.attachments
        if (typeof attachmentList === 'string') {
          attachmentList = JSON.parse(attachmentList)
        }
        
        // 从Base64恢复附件
        const filePromises = attachmentList.map(async (att: any) => {
          if (att.content) {
            return await base64ToFile(att.content, att.name || 'attachment', att.type || 'application/octet-stream')
          }
          return null
        })
        
        const files = await Promise.all(filePromises)
        attachments.value = files.filter((f): f is File => f !== null)
      } catch (error) {
        console.error('Error loading draft attachments:', error)
        notice.value = '加载附件时出错'
        noticeType.value = 'error'
      }
    }
    
    // 切换到发送界面
    goto('compose')
    
    notice.value = '草稿已加载，可以继续编辑'
    noticeType.value = 'success'
    setTimeout(() => {
      notice.value = ''
    }, 3000)
  } catch (error) {
    console.error('Error editing draft:', error)
    notice.value = '编辑草稿时出错'
    noticeType.value = 'error'
  }
}

// 自动保存草稿（每30秒）
function setupAutoSaveDraft() {
  if (draftAutoSaveInterval.value) {
    clearInterval(draftAutoSaveInterval.value)
  }
  
  if (!draftAutoSaveEnabled.value) {
    return
  }
  
  draftAutoSaveInterval.value = setInterval(() => {
    if ((subject.value || body.value) && view.value === 'compose') {
      saveDraft()
    }
  }, 30000) // 30秒自动保存一次
}

function clearForm() {
  to.value = ''
  cc.value = ''
  subject.value = ''
  body.value = ''
  attachments.value = []
  notice.value = ''
  selectedCCUsers.value = []
  draftSaved.value = false
  editingDraftId.value = null // 清空编辑状态
  if (draftAutoSaveInterval.value) {
    clearInterval(draftAutoSaveInterval.value)
    draftAutoSaveInterval.value = null
  }
}

function goto(v: 'inbox'|'sent'|'drafts'|'trash'|'spam'|'compose') { 
  // 切换视图前，如果是写邮件视图，停止自动保存
  if (view.value === 'compose' && draftAutoSaveInterval.value) {
    clearInterval(draftAutoSaveInterval.value)
    draftAutoSaveInterval.value = null
  }
  
  // 立即清空邮件列表和关闭邮件详情，避免显示旧数据
  emails.value = []
  showEmailDetail.value = false
  selectedEmail.value = null
  currentCustomFolder.value = null
  
  // 立即设置加载状态，避免显示空列表
  emailsLoading.value = true
  
  view.value = v
  
  if (v === 'inbox' || v === 'sent' || v === 'drafts' || v === 'trash' || v === 'spam') {
    loadEmails(v)
    loadMailStats() // 加载邮件统计
  } else if (v === 'compose') {
    // 切换到写邮件视图时，启动自动保存
    setupAutoSaveDraft()
    emailsLoading.value = false
  }
}

// 加载文件夹列表
async function loadFolders() {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch('/api/mail/folders', {
      headers: { 'Authorization': `Basic ${auth}` }
    })
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.folders) {
        // 确保使用新数组来触发响应式更新
        folders.value = [...data.folders]
        console.log('文件夹列表已更新，共', folders.value.length, '个文件夹')
        console.log('所有文件夹详情:', folders.value.map((f: any) => ({
          id: f.id,
          name: f.name,
          display_name: f.display_name,
          folder_type: f.folder_type,
          user_id: f.user_id,
          is_active: f.is_active
        })))
        console.log('自定义文件夹:', customFoldersList.value.length, '个')
        console.log('自定义文件夹详情:', customFoldersList.value.map((f: any) => ({
          id: f.id,
          name: f.name,
          display_name: f.display_name,
          folder_type: f.folder_type,
          user_id: f.user_id,
          is_active: f.is_active
        })))
      } else {
        console.warn('加载文件夹失败:', data.error || '未知错误')
      }
    } else {
      console.error('加载文件夹失败，HTTP状态:', response.status)
      const errorText = await response.text()
      console.error('错误详情:', errorText)
    }
  } catch (error) {
    console.error('Error loading folders:', error)
  }
}

// 创建自定义文件夹
async function createCustomFolder() {
  if (!newFolderName.value.trim()) {
    folderManageError.value = '文件夹名称不能为空'
    return
  }
  
  // 验证文件夹名称格式
  if (!/^[a-zA-Z0-9_-]+$/.test(newFolderName.value)) {
    folderManageError.value = '文件夹名称只能包含字母、数字、下划线和连字符'
    return
  }
  
  folderManageError.value = ''
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch('/api/mail/folders', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        name: newFolderName.value.trim(),
        display_name: newFolderDisplayName.value.trim() || newFolderName.value.trim()
      })
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 保存文件夹名称用于后续检查
        const createdFolderName = newFolderName.value.trim()
        const createdFolderDisplayName = newFolderDisplayName.value.trim() || createdFolderName
        
        newFolderName.value = ''
        newFolderDisplayName.value = ''
        folderManageError.value = ''
        
        // 如果API返回了新创建的文件夹数据，直接添加到列表中
        if (data.folder) {
          // 确保文件夹对象包含必要的字段
          const newFolder = {
            ...data.folder,
            folder_type: data.folder.folder_type || 'user',
            is_active: data.folder.is_active !== undefined ? data.folder.is_active : 1
          }
          
          // 检查是否已存在，避免重复添加
          const exists = folders.value.find((f: any) => f.id === newFolder.id || f.name === newFolder.name)
          if (!exists) {
            folders.value.push(newFolder)
            console.log('新文件夹已添加到列表:', newFolder)
          }
        }
        
        // 重新加载文件夹列表以确保数据同步
        await loadFolders()
        
        // 再次检查，如果还是没有，等待一下再加载
        setTimeout(async () => {
          const folderExists = folders.value.find((f: any) => f.name === createdFolderName || (data.folder && f.id === data.folder.id))
          if (!folderExists) {
            console.log('文件夹未在列表中，重新加载...')
            await loadFolders()
          } else {
            console.log('文件夹已成功显示在列表中')
          }
        }, 500)
        
        notice.value = '文件夹创建成功'
        noticeType.value = 'success'
        setTimeout(() => { notice.value = '' }, 2000)
      } else {
        folderManageError.value = data.error || '创建文件夹失败'
        // 如果错误是文件夹已存在，刷新列表以显示已存在的文件夹
        if (data.error && data.error.includes('已存在')) {
          console.log('文件夹已存在，刷新列表...')
          await loadFolders()
          // 清空输入框
          newFolderName.value = ''
          newFolderDisplayName.value = ''
        }
      }
    } else {
      const errorData = await response.json().catch(() => ({}))
      const errorMsg = errorData.error || '创建文件夹失败'
      folderManageError.value = errorMsg
      
      // 如果错误是文件夹已存在，刷新列表以显示已存在的文件夹
      if (errorMsg.includes('已存在')) {
        console.log('文件夹已存在，刷新列表...')
        await loadFolders()
        // 清空输入框
        newFolderName.value = ''
        newFolderDisplayName.value = ''
      }
    }
  } catch (error) {
    console.error('Error creating folder:', error)
    folderManageError.value = '创建文件夹时出错'
  }
}

// 编辑自定义文件夹
function editCustomFolder(folder: any) {
  editingFolder.value = folder
  editFolderName.value = folder.name
  editFolderDisplayName.value = folder.display_name || folder.name
  folderManageError.value = ''
}

// 更新自定义文件夹
async function updateCustomFolder() {
  if (!editingFolder.value) return
  
  if (!editFolderName.value.trim()) {
    folderManageError.value = '文件夹名称不能为空'
    return
  }
  
  // 验证文件夹名称格式
  if (!/^[a-zA-Z0-9_-]+$/.test(editFolderName.value)) {
    folderManageError.value = '文件夹名称只能包含字母、数字、下划线和连字符'
    return
  }
  
  const oldFolderName = editingFolder.value.name
  const newFolderName = editFolderName.value.trim()
  folderManageError.value = ''
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/folders/${editingFolder.value.id}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        name: newFolderName,
        display_name: editFolderDisplayName.value.trim() || newFolderName
      })
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 如果当前正在查看该文件夹，更新视图
        if (currentCustomFolder.value === oldFolderName) {
          currentCustomFolder.value = newFolderName
        }
        
        editingFolder.value = null
        editFolderName.value = ''
        editFolderDisplayName.value = ''
        folderManageError.value = ''
        await loadFolders()
        notice.value = '文件夹更新成功'
        noticeType.value = 'success'
        setTimeout(() => { notice.value = '' }, 2000)
      } else {
        folderManageError.value = data.error || '更新文件夹失败'
      }
    } else {
      const errorData = await response.json()
      folderManageError.value = errorData.error || '更新文件夹失败'
    }
  } catch (error) {
    console.error('Error updating folder:', error)
    folderManageError.value = '更新文件夹时出错'
  }
}

// 删除自定义文件夹
async function deleteCustomFolder(folder: any) {
  if (!confirm(`确定要删除文件夹"${folder.display_name || folder.name}"吗？文件夹中的邮件将被移动到已删除文件夹。`)) {
    return
  }
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/folders/${folder.id}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        await loadFolders()
        notice.value = '文件夹已删除'
        noticeType.value = 'success'
        setTimeout(() => { notice.value = '' }, 2000)
        
        // 如果当前正在查看该文件夹，切换到收件箱
        if (currentCustomFolder.value === folder.name) {
          goto('inbox')
        }
      } else {
        notice.value = data.error || '删除文件夹失败'
        noticeType.value = 'error'
      }
    } else {
      const errorData = await response.json()
      notice.value = errorData.error || '删除文件夹失败'
      noticeType.value = 'error'
    }
  } catch (error) {
    console.error('Error deleting folder:', error)
    notice.value = '删除文件夹时出错'
    noticeType.value = 'error'
  }
}

// 跳转到自定义文件夹
function gotoCustomFolder(folderName: string) {
  // 立即清空邮件列表和关闭邮件详情，避免显示旧数据
  emails.value = []
  showEmailDetail.value = false
  selectedEmail.value = null
  
  // 立即设置加载状态
  emailsLoading.value = true
  
  // 设置当前自定义文件夹
  currentCustomFolder.value = folderName
  view.value = 'custom-folder'
  
  // 加载邮件
  loadEmails(folderName)
}

// 还原邮件（从已删除文件夹恢复到原文件夹）
async function restoreEmail(emailId: number | string) {
  if (!emailId) return
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/${emailId}/restore`, {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 从邮件列表中移除
        emails.value = emails.value.filter((e: any) => e.id !== emailId)
        // 如果当前查看的是该邮件，关闭详情
        if (selectedEmail?.id === emailId) {
          closeEmailDetail()
        }
        // 重新加载统计
        loadMailStats()
        notice.value = '邮件已还原'
        noticeType.value = 'success'
        setTimeout(() => {
          notice.value = ''
        }, 2000)
      } else {
        notice.value = data.error || '还原邮件失败'
        noticeType.value = 'error'
      }
    } else {
      const errorData = await response.json()
      notice.value = errorData.error || '还原邮件失败'
      noticeType.value = 'error'
    }
  } catch (error) {
    console.error('Error restoring email:', error)
    notice.value = '还原邮件时出错'
    noticeType.value = 'error'
  }
}

// 彻底删除邮件（硬删除）
async function permanentlyDeleteEmail(emailId: number | string) {
  if (!emailId) return
  if (!confirm('确定要彻底删除这封邮件吗？此操作不可恢复！')) return
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/${emailId}/permanent`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 从邮件列表中移除
        emails.value = emails.value.filter((e: any) => e.id !== emailId)
        // 如果当前查看的是该邮件，关闭详情
        if (selectedEmail?.id === emailId) {
          closeEmailDetail()
        }
        // 重新加载统计
        loadMailStats()
        notice.value = '邮件已彻底删除'
        noticeType.value = 'success'
        setTimeout(() => {
          notice.value = ''
        }, 2000)
      } else {
        notice.value = data.error || '彻底删除邮件失败'
        noticeType.value = 'error'
      }
    } else {
      const errorData = await response.json()
      notice.value = errorData.error || '彻底删除邮件失败'
      noticeType.value = 'error'
    }
  } catch (error) {
    console.error('Error permanently deleting email:', error)
    notice.value = '彻底删除邮件时出错'
    noticeType.value = 'error'
  }
}


// 检查服务状态
async function checkServiceStatus() {
  serviceCheckLoading.value = true
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch('/api/mail/service-status', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 规范化服务状态：优先使用后端的 system_services 与系统面板一致
        if (data.system_services) {
          const s = data.system_services
          const normalized = {
            postfix: s.postfix === 'running',
            dovecot: s.dovecot === 'running',
            named: s.named === 'running',
            mariadb: s.mariadb === 'running'
          }
          data.services = normalized
        }

        serviceStatus.value = data
        showServiceWarning.value = !data.mail_system_ready

        if (!data.mail_system_ready) {
          console.warn('邮件系统未完全配置，显示服务状态警告')
        }
      }
    } else {
      console.error('Failed to check service status:', response.statusText)
      showServiceWarning.value = true
    }
  } catch (error) {
    console.error('Error checking service status:', error)
    showServiceWarning.value = true
  } finally {
    serviceCheckLoading.value = false
  }
}

// 更新Layout组件中的未读邮件计数
function updateLayoutUnreadCount() {
  // 通过事件总线或直接调用父组件的方法来更新未读邮件计数
  // 这里我们使用localStorage作为通信机制
  localStorage.setItem('unreadEmailCount', unreadCount.value.toString())
  
  // 触发自定义事件通知Layout组件更新
  window.dispatchEvent(new CustomEvent('unreadCountUpdated', {
    detail: { count: unreadCount.value }
  }))
}

// 加载邮件统计
async function loadMailStats() {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch('/api/mail/stats', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.stats) {
        // 向后兼容处理：确保所有文件夹统计都有默认值
        mailStats.value = {
          inbox: data.stats.inbox || { total: 0, unread: 0, read: 0, size: 0 },
          sent: data.stats.sent || { total: 0, unread: 0, read: 0, size: 0 },
          drafts: data.stats.drafts || { total: 0, unread: 0, read: 0, size: 0 },
          trash: data.stats.trash || { total: 0, unread: 0, read: 0, size: 0 },
          spam: data.stats.spam || { total: 0, unread: 0, read: 0, size: 0 }
        }
        // 仅收件箱在侧栏显示未读数，由 loadMailStats 更新
        unreadCount.value = mailStats.value.inbox?.unread || 0
        // 更新Layout组件中的未读邮件计数
        updateLayoutUnreadCount()
      }
    } else {
      console.error('Failed to load mail stats:', response.statusText)
    }
  } catch (error) {
    console.error('Error loading mail stats:', error)
  }
}

// 搜索邮件
async function searchEmails() {
  if (!searchQuery.value.trim()) {
    notice.value = '请输入搜索关键词'
    noticeType.value = 'warning'
    return
  }
  
  searchLoading.value = true
  isSearchMode.value = true
  emails.value = []
  emailsLoading.value = true
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/search?q=${encodeURIComponent(searchQuery.value.trim())}&folder=${view.value}`, {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      
      // 处理邮件数据并去重（基于内容特征，避免显示重复邮件）
      const processedEmails = (data.emails || []).map((email: any) => {
        const readStatus = email.read_status !== undefined ? email.read_status : (email.read !== undefined ? email.read : 0)
        return {
          ...email,
          read: readStatus,
          read_status: readStatus,
          recipients: email.recipients || { to: [], cc: [], bcc: [] },
          metadata: email.metadata || {},
          attachments: Array.isArray(email.attachments) ? email.attachments : []
        }
      })
      
      // 去重：基于内容特征生成唯一键，相同内容的邮件只保留一个
      const emailMap = new Map<string, any>()
      for (const email of processedEmails) {
        // 生成唯一键：基于message_id前缀、主题、发件人、日期
        const baseMessageId = email.message_id ? email.message_id.split('_')[0] : ''
        const contentKey = `${baseMessageId}_${email.subject || ''}_${email.from || ''}_${email.date || ''}`
        
        const existingEmail = emailMap.get(contentKey)
        if (existingEmail) {
          // 如果同一封邮件的多个记录有不同的read_status，优先保留未读记录
          const existingIsUnread = isUnread(existingEmail)
          const currentIsUnread = isUnread(email)
          
          if (currentIsUnread && !existingIsUnread) {
            // 新邮件是未读，已存在的是已读，保留新邮件（未读优先）
            emailMap.set(contentKey, email)
          } else if (!currentIsUnread && existingIsUnread) {
            // 新邮件是已读，已存在的是未读，保留已存在的（未读优先）
            // 不做任何操作
          } else {
            // 状态相同，保留id较小的（通常是第一条记录）
            if (email.id < existingEmail.id) {
              emailMap.set(contentKey, email)
            }
          }
        } else {
          // 新邮件，添加到Map
          emailMap.set(contentKey, email)
        }
      }
      
      // 将去重后的邮件转换为数组
      emails.value = Array.from(emailMap.values())
      
      // 按时间降序排序，确保最新的邮件在最上面
      emails.value.sort((a, b) => {
        const dateA = new Date(a.date)
        const dateB = new Date(b.date)
        return dateB.getTime() - dateA.getTime()
      })
      
      totalEmails.value = emails.value.length
      resetPagination()
      
      if (emails.value.length === 0) {
        notice.value = '未找到匹配的邮件'
        noticeType.value = 'info'
      } else {
        notice.value = `找到 ${emails.value.length} 封匹配的邮件`
        noticeType.value = 'success'
        setTimeout(() => {
          notice.value = ''
        }, 3000)
      }
    } else {
      throw new Error('搜索失败')
    }
  } catch (error) {
    console.error('Error searching emails:', error)
    notice.value = '搜索邮件失败，请重试'
    noticeType.value = 'error'
    emails.value = []
  } finally {
    searchLoading.value = false
    emailsLoading.value = false
  }
}

// 清除搜索
function clearSearch() {
  searchQuery.value = ''
  isSearchMode.value = false
  loadEmails(view.value)
}

// 搜索输入处理
function onSearchInput() {
  // 如果清空搜索框，自动退出搜索模式
  if (!searchQuery.value.trim() && isSearchMode.value) {
    clearSearch()
  }
}

// 加载邮件列表
async function loadEmails(folder: string) {
  // 如果处于搜索模式，先退出搜索模式
  if (isSearchMode.value) {
    isSearchMode.value = false
    searchQuery.value = ''
  }
  // 立即清空旧数据，避免显示其他用户的数据或旧数据
  emails.value = []
  emailsLoading.value = true
  unreadCountLoading.value = true
  
  // 生成请求ID，用于防止竞态条件（快速切换时只显示最新请求的结果）
  const requestId = Date.now()
  currentLoadRequestId.value = requestId
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/list?folder=${folder}`, {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    // 检查是否是最新的请求，如果不是则忽略结果（防止显示旧数据）
    if (currentLoadRequestId.value !== requestId) {
      console.log('忽略过期的邮件列表请求:', folder, '当前请求ID:', requestId, '最新请求ID:', currentLoadRequestId.value)
      return
    }
    
  if (response.ok) {
      const data = await response.json()
      
      // 再次检查请求ID，确保数据是最新的（双重检查防止竞态条件）
      if (currentLoadRequestId.value !== requestId) {
        console.log('忽略过期的邮件列表数据:', folder, '当前请求ID:', requestId, '最新请求ID:', currentLoadRequestId.value)
        return
      }
      
      // 处理邮件数据并去重（基于内容特征，避免显示重复邮件）
      const processedEmails = (data.emails || []).map((email: any) => {
        // 向后兼容处理：确保所有新字段都有默认值
        // 确保 read_status 字段存在（从 read 字段同步，或使用默认值）
        const readStatus = email.read_status !== undefined ? email.read_status : (email.read !== undefined ? email.read : 0)
        return {
          ...email,
          read: readStatus, // 确保 read 字段存在
          read_status: readStatus, // 确保 read_status 字段也存在
          recipients: email.recipients || { to: [], cc: [], bcc: [] },
          metadata: email.metadata || {},
          attachments: Array.isArray(email.attachments) ? email.attachments : []
        }
      })
      
      // 去重：基于内容特征生成唯一键，相同内容的邮件只保留一个
      const emailMap = new Map<string, any>()
      
      for (const email of processedEmails) {
        // 生成内容特征键：发件人、主题、时间（精确到秒）、文件夹
        const from = (email.from || email.from_addr || '').trim().toLowerCase()
        const subject = (email.subject || '').trim()
        // 时间精确到秒，避免毫秒差异导致重复
        const date = email.date ? new Date(email.date).toISOString().substring(0, 19) : ''
        const emailFolder = email.folder || folder || ''
        
        // 草稿箱、已删除：按 id 区分，不按内容合并，避免多条草稿/删除记录因主题时间相同被合并成一条
        const contentKey = (folder === 'drafts' || folder === 'trash') && email.id != null
          ? `id:${email.id}`
          : `${from}|${subject}|${date}|${emailFolder}`
        
        // 如果该键已存在，检查是否是重复邮件
        if (emailMap.has(contentKey)) {
          const existingEmail = emailMap.get(contentKey)
          
          // 比较内容是否真的相同（更严格的比较）
          const isSameContent = 
            from === (existingEmail.from || existingEmail.from_addr || '').trim().toLowerCase() &&
            subject === (existingEmail.subject || '').trim() &&
            date === (existingEmail.date ? new Date(existingEmail.date).toISOString().substring(0, 19) : '')
          
          if (isSameContent) {
            // 内容相同，这是同一封邮件的不同记录（如_inbox和_cc）
            // 保留ID较小的，但如果新邮件的read_status=0（未读），则保留新邮件（确保未读状态优先）
            const existingIsUnread = isUnread(existingEmail)
            const currentIsUnread = isUnread(email)
            
            if (currentIsUnread && !existingIsUnread) {
              // 新邮件是未读，已存在的是已读，保留新邮件（未读优先）
              emailMap.set(contentKey, email)
            } else if (!currentIsUnread && existingIsUnread) {
              // 新邮件是已读，已存在的是未读，保留已存在的（未读优先）
              // 不做任何操作
            } else if (email.id && existingEmail.id) {
              // 都是未读或都是已读，保留ID较小的（通常是较早创建的）
              if (email.id < existingEmail.id) {
                emailMap.set(contentKey, email)
              }
              // 否则保留已存在的邮件
            } else if (email.id && !existingEmail.id) {
              // 新邮件有ID，已存在的没有，保留新的
              emailMap.set(contentKey, email)
            } else if (!email.id && existingEmail.id) {
              // 新邮件没有ID，已存在的有，保留已存在的
              // 不做任何操作
            } else {
              // 都没有ID，保留已存在的
              // 不做任何操作
            }
          } else {
            // 内容不同，可能是不同的邮件，但键相同（不太可能），保留新邮件
            emailMap.set(contentKey, email)
          }
        } else {
          // 新邮件，添加到Map
          emailMap.set(contentKey, email)
        }
      }
      
      // 将去重后的邮件转换为数组
      emails.value = Array.from(emailMap.values())
      
      // 按时间降序排序，确保最新的邮件在最上面
      emails.value.sort((a, b) => {
        const dateA = new Date(a.date)
        const dateB = new Date(b.date)
        return dateB.getTime() - dateA.getTime()
      })
      
      totalEmails.value = emails.value.length
      
      // 重置分页到第一页
      resetPagination()
      
      // 与收件箱一致：每次加载完邮件后都刷新统计，保证收件箱/已发送/垃圾邮件侧栏未读数统一来自 loadMailStats
      loadMailStats()
      if (folder === 'sent') {
        // 顶部未读角标：在已发送页显示 0
        unreadCount.value = 0
        updateLayoutUnreadCount()
      }
    } else {
      console.error('Failed to load emails:', response.statusText)
      // 请求失败时，如果是当前请求，清空邮件列表
      if (currentLoadRequestId.value === requestId) {
        emails.value = []
      }
    }
  } catch (error) {
    console.error('Error loading emails:', error)
    // 发生错误时，如果是当前请求，清空邮件列表
    if (currentLoadRequestId.value === requestId) {
      emails.value = []
    }
  } finally {
    // 只有当前请求才更新加载状态
    if (currentLoadRequestId.value === requestId) {
      emailsLoading.value = false
      unreadCountLoading.value = false
    }
  }
}

// 打开邮件详情
async function openEmail(email: any) {
  showEmailDetail.value = true
  
  try {
    // 获取完整的邮件详情
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/${email.id}`, {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json'
      }
    })
    
    if (response.ok) {
      const apiResponse = await response.json()
      console.log('Email detail API response:', apiResponse)

      // API返回的数据在 email 字段下
      const emailDetail = apiResponse.email || apiResponse
      console.log('Email detail API response:', apiResponse)
      console.log('Email detail body:', emailDetail.body)
      console.log('Email detail html:', emailDetail.html)
      console.log('Email detail body type:', typeof emailDetail.body)
      console.log('Email detail body length:', emailDetail.body ? emailDetail.body.length : 0)
      console.log('Email detail body trimmed:', emailDetail.body ? emailDetail.body.trim() : 'N/A')
      console.log('Email detail full object:', JSON.stringify(emailDetail, null, 2))
      
      // 确保body和html字段存在
      // 如果详情API返回的body和html都是空的，尝试使用列表中的email对象的body和html
      if ((!emailDetail.body || !emailDetail.body.trim()) && (!emailDetail.html || !emailDetail.html.trim())) {
        console.warn('警告：邮件详情中body和html字段都为空或不存在')
        console.warn('邮件详情完整数据:', emailDetail)
        // 尝试从列表中的email对象获取body和html
        if (email && email.body && email.body.trim()) {
          console.log('使用列表中的email对象的body字段')
          emailDetail.body = email.body
        }
        if (email && email.html && email.html.trim()) {
          console.log('使用列表中的email对象的html字段')
          emailDetail.html = email.html
        }
      } else {
        // 调试：检查body字段的实际内容
        if (emailDetail.body) {
          console.log('Body字段存在，内容:', emailDetail.body.substring(0, 200))
          console.log('Body字段trim后长度:', emailDetail.body.trim().length)
        }
        if (emailDetail.html) {
          console.log('HTML字段存在，内容:', emailDetail.html.substring(0, 200))
          console.log('HTML字段trim后长度:', emailDetail.html.trim().length)
        }
      }

      // 向后兼容处理：确保attachments始终为数组
      if (!emailDetail.attachments) {
        emailDetail.attachments = []
      } else if (typeof emailDetail.attachments === 'string') {
        try {
          emailDetail.attachments = JSON.parse(emailDetail.attachments)
        } catch (e) {
          console.error('Failed to parse attachments:', e)
          emailDetail.attachments = []
        }
      } else if (!Array.isArray(emailDetail.attachments)) {
        emailDetail.attachments = []
      }

      // 向后兼容处理：确保其他新字段都有默认值
      emailDetail.recipients = emailDetail.recipients || {
        to: emailDetail.to ? emailDetail.to.split(',').map((addr: string) => addr.trim()) : [],
        cc: emailDetail.cc ? emailDetail.cc.split(',').map((addr: string) => addr.trim()) : [],
        bcc: []
      }
      emailDetail.metadata = emailDetail.metadata || {}

      console.log('Setting selectedEmail to:', emailDetail)
      selectedEmail.value = emailDetail

      // 强制更新，确保Vue响应性
      await nextTick()
      console.log('After nextTick, selectedEmail:', selectedEmail.value)
      
      // get_email_detail API 已经会在获取详情时标记为已读
      // 更新本地邮件列表中所有相同邮件的状态（基于message_id前缀）
      const baseMessageId = emailDetail.message_id ? emailDetail.message_id.split('_')[0] : null
      if (baseMessageId && isUnread(email) && view.value === 'inbox') {
        // 更新本地邮件列表状态
        emails.value.forEach((e: any) => {
          const eBaseMessageId = e.message_id ? e.message_id.split('_')[0] : null
          if (eBaseMessageId === baseMessageId) {
            // 同时更新 read 和 read_status 字段，确保兼容性
            e.read = 1
            e.read_status = 1
          }
        })
        
        // 更新selectedEmail的状态（确保显示为已读）
        if (selectedEmail.value) {
          selectedEmail.value.read = 1
          selectedEmail.value.read_status = 1
        }
        
        // 异步更新统计，不阻塞UI
        // 使用较短的延迟，让统计更新更平滑
        setTimeout(() => {
          loadMailStats()
        }, 100)
      }
    } else {
      // 处理错误响应（404等）
      let errorMessage = '获取邮件详情失败'
      try {
        const errorData = await response.json()
        errorMessage = errorData.message || errorData.error || errorMessage
        console.error('Failed to fetch email detail:', errorMessage, errorData)
      } catch (e) {
        console.error('Failed to fetch email detail:', response.status, response.statusText)
        errorMessage = `获取邮件详情失败: ${response.status} ${response.statusText}`
      }
      
      // 显示错误提示
      notice.value = errorMessage
      noticeType.value = 'error'
      
      // 如果邮件不存在（404），关闭详情视图并使用列表中的email对象（可能不完整）
      if (response.status === 404) {
        console.warn(`邮件ID ${email.id} 不存在或您没有权限访问`)
        // 使用列表中的email对象，但标记为错误状态
        selectedEmail.value = {
          ...email,
          error: true,
          errorMessage: errorMessage
        }
      } else {
        // 其他错误，使用列表中的email对象
        selectedEmail.value = email
      }
    }
  } catch (error) {
    console.error('Error fetching email detail:', error)
    selectedEmail.value = email
  }
}

// 关闭邮件详情
function closeEmailDetail() {
  showEmailDetail.value = false
  selectedEmail.value = null
}

// 删除邮件
// 软删除邮件（移动到已删除文件夹）
function showDeleteConfirmDialog(emailId: number | string) {
  if (!emailId) return
  emailToDelete.value = emailId
  showDeleteConfirm.value = true
}

async function confirmDeleteEmail() {
  const emailId = emailToDelete.value
  if (!emailId) return
  
  showDeleteConfirm.value = false
  
  try {
    await moveEmailToFolder(emailId, 'trash')
    // 从列表中移除
    emails.value = emails.value.filter(email => email.id !== emailId)
    // 如果当前查看的是已删除的邮件详情，关闭详情页
    if (selectedEmail?.id === emailId) {
      closeEmailDetail()
    }
    // 重新加载统计以获取准确的未读数量（不基于当前页面邮件列表计算）
    loadMailStats()
  } catch (error) {
    console.error('Error deleting email:', error)
    notice.value = '删除邮件失败'
    noticeType.value = 'error'
  } finally {
    emailToDelete.value = null
  }
}

function cancelDeleteEmail() {
  showDeleteConfirm.value = false
  emailToDelete.value = null
}

// 处理移动到文件夹（带选择器重置）
async function handleMoveFolder(event: Event) {
  const target = event.target as HTMLSelectElement
  const folder = target.value
  if (!folder || !selectedEmail?.id) return
  
  await moveEmailToFolder(selectedEmail.id, folder)
  // 重置选择器
  target.value = ''
}

// 处理移动到文件夹（新版本，直接传值）
async function handleMoveFolderAction(folder: string) {
  const id = selectedEmail.value?.id
  if (!folder || id == null || id === undefined) return
  await moveEmailToFolder(id, folder)
}


// 获取可用的目标文件夹列表（根据当前文件夹和邮件状态）
function getAvailableFolders(currentFolder: string, email?: any): Array<{value: string, label: string}> {
  // 系统文件夹
  const systemFolders = [
    { value: 'inbox', label: '收件箱' },
    { value: 'sent', label: '已发送' },
    { value: 'drafts', label: '草稿箱' },
    { value: 'spam', label: '垃圾邮件' },
    { value: 'trash', label: '已删除' }
  ]
  
  // 自定义文件夹（从folders ref中获取，排除系统文件夹和当前文件夹）
  const customFolders = folders.value
    .filter((f: any) => f.folder_type === 'user' && f.name !== currentFolder && f.is_active !== 0)
    .map((f: any) => ({
      value: f.name,
      label: f.display_name || f.name
    }))
  
  // 根据当前文件夹过滤可用的目标文件夹
  let availableFolders: Array<{value: string, label: string}> = []
  
  switch (currentFolder) {
    case 'inbox':
      // 收件箱可以移动到：垃圾邮件、已删除、自定义文件夹
      availableFolders = [
        ...systemFolders.filter(f => f.value === 'spam' || f.value === 'trash'),
        ...customFolders
      ]
      break
    
    case 'sent':
      // 已发送可以移动到：已删除、自定义文件夹（不需要移动到垃圾邮件）
      availableFolders = [
        ...systemFolders.filter(f => f.value === 'trash'),
        ...customFolders
      ]
      break
    
    case 'drafts':
      // 草稿箱可以移动到：已删除（草稿不应该移动到其他文件夹）
      availableFolders = systemFolders.filter(f => f.value === 'trash')
      break
    
    case 'spam':
      // 垃圾邮件可以移动到：收件箱（恢复）、已删除、自定义文件夹
      availableFolders = [
        ...systemFolders.filter(f => f.value === 'inbox' || f.value === 'trash'),
        ...customFolders
      ]
      break
    
    case 'trash':
      // 已删除可以移动到：原文件夹（收件箱/已发送/草稿），不建议移动到垃圾邮件
      // 如果邮件有原文件夹信息，优先显示原文件夹
      const originalFolder = email?.original_folder || email?.folder_before_delete
      if (originalFolder && ['inbox', 'sent', 'drafts'].includes(originalFolder)) {
        const originalFolderObj = systemFolders.find(f => f.value === originalFolder)
        if (originalFolderObj) {
          availableFolders = [originalFolderObj, ...customFolders]
        } else {
          availableFolders = [
            ...systemFolders.filter(f => ['inbox', 'sent', 'drafts'].includes(f.value)),
            ...customFolders
          ]
        }
      } else {
        // 没有原文件夹信息，显示所有可能的原文件夹
        availableFolders = [
          ...systemFolders.filter(f => ['inbox', 'sent', 'drafts'].includes(f.value)),
          ...customFolders
        ]
      }
      break
    
    default:
      // 自定义文件夹：可以移动到所有文件夹（除了当前文件夹和草稿箱）
      if (customFolders.some(f => f.value === currentFolder)) {
        availableFolders = [
          ...systemFolders.filter(f => f.value !== 'drafts' && f.value !== currentFolder),
          ...customFolders.filter(f => f.value !== currentFolder)
        ]
      } else {
        // 默认情况下，可以移动到所有文件夹（除了当前文件夹）
        availableFolders = [
          ...systemFolders.filter(f => f.value !== currentFolder),
          ...customFolders
        ]
      }
  }
  
  return availableFolders
}

// 获取文件夹图标
function getFolderIcon(folderValue: string): string {
  const icons: Record<string, string> = {
    'inbox': 'M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z',
    'sent': 'M12 19l9 2-9-18-9 18 9-2zm0 0v-8',
    'drafts': 'M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z',
    'spam': 'M6 18L18 6M6 6l12 12',
    'trash': 'M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16'
  }
  return icons[folderValue] || icons['inbox']
}

// 移动到文件夹
async function moveEmailToFolder(emailId: number | string, folder: string) {
  if (emailId == null || emailId === '' || !folder) return
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/mail/${emailId}/move`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({ folder })
    })
    
    if (response.ok) {
      let data: { success?: boolean; error?: string }
      try {
        data = await response.json()
      } catch {
        data = {}
      }
      if (data.success) {
        // 从当前列表中移除已移动的邮件，使列表立即更新
        emails.value = emails.value.filter((e: any) => e.id != emailId)
        // 如果当前查看的是该邮件，关闭详情并更新选中状态
        if (selectedEmail.value && selectedEmail.value.id != null && selectedEmail.value.id == emailId) {
          closeEmailDetail()
        }
        // 重新加载统计
        loadMailStats()
        notice.value = '邮件已移动'
        noticeType.value = 'success'
        setTimeout(() => {
          notice.value = ''
        }, 2000)
      } else {
        notice.value = (data && data.error) || '移动邮件失败'
        noticeType.value = 'error'
      }
    } else {
      let errorData: { error?: string } = {}
      try {
        errorData = await response.json()
      } catch {
        errorData = {}
      }
      notice.value = errorData.error || '移动邮件失败'
      noticeType.value = 'error'
    }
  } catch (error) {
    console.error('Error moving email:', error)
    notice.value = '移动邮件时出错'
    noticeType.value = 'error'
  }
}


// 保留原有的deleteEmail函数作为硬删除（如果需要）
async function deleteEmail(emailId: string) {
  // 使用软删除
  await softDeleteEmail(emailId)
}

// 发送邮件
async function sendEmail() {
  if (!to.value) { 
    notice.value = '请输入收件人'
    noticeType.value = 'error'
    userLogger.logMailOperation('send_failed', { reason: 'missing_recipient' })
    return 
  }
  
  if (!subject.value) {
    notice.value = '请输入邮件主题'
    noticeType.value = 'error'
    return
  }
  
  if (!body.value) {
    notice.value = '请输入邮件内容'
    noticeType.value = 'error'
    return
  }
  
  sending.value = true
  sendingProgress.value = 0
  notice.value = ''
  startTime.value = Date.now()
  elapsedTime.value = 0
  estimatedTime.value = 0
  
  // 智能进度更新（根据附件大小调整）
  const hasAttachments = attachments.value.length > 0
  const totalSize = attachments.value.reduce((sum, file) => sum + file.size, 0)
  isLargeFile.value = totalSize > 100 * 1024 // 大于100KB
  
  // 根据文件大小估算预计时间
  let baseTime = 5 // 基础5秒
  if (totalSize > 1024 * 1024) { // 大于1MB
    baseTime = 300 // 5分钟
  } else if (totalSize > 500 * 1024) { // 大于500KB
    baseTime = 120 // 2分钟
  } else if (totalSize > 100 * 1024) { // 大于100KB
    baseTime = 30 // 30秒
  }
  estimatedTime.value = baseTime
  
  let progressStep = 15
  let progressInterval = 200
  
  if (isLargeFile.value) {
    progressStep = 5 // 大文件进度更慢
    progressInterval = 500 // 更新间隔更长
  }
  
  const progressIntervalId = setInterval(() => {
    if (sendingProgress.value < 90) {
      sendingProgress.value += Math.random() * progressStep
      
      // 更新已用时间
      elapsedTime.value = Math.floor((Date.now() - startTime.value) / 1000)
      
      // 动态调整预计剩余时间
      if (sendingProgress.value > 0) {
        const remainingProgress = 100 - sendingProgress.value
        const timePerPercent = elapsedTime.value / sendingProgress.value
        estimatedTime.value = Math.max(1, Math.round(remainingProgress * timePerPercent))
      }
    }
  }, progressInterval)
  
  // 实时时间更新器（更频繁的更新）
  const timeUpdateInterval = setInterval(() => {
    if (sending.value) {
      elapsedTime.value = Math.floor((Date.now() - startTime.value) / 1000)
    }
  }, 1000) // 每秒更新一次
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const userEmail = await getCurrentUserEmail()
    
    // 检查用户邮箱是否获取成功
    if (!userEmail) {
      notice.value = '无法获取用户邮箱地址，请确保您已在邮件系统中注册'
      noticeType.value = 'error'
      sending.value = false
      clearInterval(progressIntervalId)
      clearInterval(timeUpdateInterval)
      return
    }
    
    // 垃圾邮件预检测（仅提示，不阻止发送）
    // 注意：后端会在发送时再次检测，如果检测到垃圾邮件会自动存储到垃圾邮箱
    try {
      const spamCheckResponse = await fetch('/api/spam-filter/check', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${auth}`
        },
        body: JSON.stringify({
          subject: subject.value,
          content: body.value,
          from: userEmail,
          to: to.value
        })
      })
      
      if (spamCheckResponse.ok) {
        const spamData = await spamCheckResponse.json()
        if (spamData.success && spamData.data.isSpam) {
          // 仅显示警告提示，不阻止发送
          // 邮件会正常发送，但会被存储到垃圾邮箱
          console.log('预检测到垃圾邮件内容，邮件将正常发送但存储到垃圾邮箱')
        }
      }
    } catch (spamError) {
      console.error('垃圾邮件预检测失败:', spamError)
      // 如果检测失败，继续发送邮件
    }
    
    const response = await fetch('/api/mail/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        to: to.value,
        cc: cc.value || (selectedCCUsers.value.length > 0 ? selectedCCUsers.value.map(user => user.email).join(', ') : ''),
        subject: subject.value,
        body: body.value,
        from: userEmail,
        attachments: attachments.value.length > 0 ? await Promise.all(attachments.value.map(async (file, index) => {
          try {
            const base64Content = await fileToBase64(file)
            return {
              name: file.name,
              size: file.size,
              type: file.type || 'application/octet-stream',
              content: base64Content
            }
          } catch (error) {
            console.error(`附件 ${file.name} 转换失败:`, error)
            notice.value = `附件 ${file.name} 处理失败: ${error instanceof Error ? error.message : '未知错误'}`
            noticeType.value = 'error'
            throw error
          }
        })) : []
      })
    })
    
    const data = await response.json()
    
    if (response.ok && data.success) {
      sendingProgress.value = 100
      setTimeout(() => {
        // 如果检测到垃圾邮件，显示特殊提示
        if (data.spamDetection && data.spamDetection.isSpam) {
          const violations = data.spamDetection.violations
          const keywords = data.spamDetection.detectedKeywords
          let violationMessages = violations.map((v: any) => v.message).join('\n')
          let keywordMessage = keywords.length > 0 ? `\n检测到的违禁关键词: ${keywords.join(', ')}` : ''
          notice.value = `邮件已发送，但检测到垃圾邮件内容，已自动移动到垃圾邮箱。\n\n违规详情:\n${violationMessages}${keywordMessage}\n\n垃圾邮件评分: ${data.spamDetection.spamScore}`
          noticeType.value = 'warning'
        } else {
          notice.value = '邮件发送成功！'
          noticeType.value = 'success'
        }
      }, 300)
      
      // 如果是从草稿编辑发送的，删除原草稿
      if (editingDraftId.value) {
        try {
          const deleteResponse = await fetch(`/api/mail/${editingDraftId.value}`, {
            method: 'DELETE',
            headers: {
              'Authorization': `Basic ${auth}`
            }
          })
          
          if (deleteResponse.ok) {
            console.log('原草稿已删除')
            // 刷新草稿箱（如果当前在草稿箱视图）
            if (view.value === 'drafts') {
              loadEmails('drafts')
            }
          }
        } catch (deleteError) {
          console.error('删除原草稿失败:', deleteError)
          // 不影响发送成功的提示
        }
        editingDraftId.value = null
      }
      
      // 记录发送成功
      userLogger.logMailOperation('send_success', {
        to: to.value,
        cc: cc.value,
        subjectLength: subject.value.length,
        bodyLength: body.value.length,
        attachmentCount: attachments.value.length
      })
      
      // 刷新邮件统计
      loadMailStats()
      
      // 如果检测到垃圾邮件，刷新垃圾邮箱；否则刷新已发送文件夹
      if (data.spamDetection && data.spamDetection.isSpam) {
        // 如果当前在垃圾邮箱视图，刷新邮件列表
        if (view.value === 'spam') {
          setTimeout(() => {
            loadEmails('spam')
          }, 500)
        }
        // 如果当前在已发送文件夹，也刷新（因为邮件也会存储到已发送文件夹）
        if (view.value === 'sent') {
          setTimeout(() => {
            loadEmails('sent')
          }, 500)
        }
      } else {
        // 如果当前在已发送文件夹，刷新邮件列表（避免显示重复邮件）
        if (view.value === 'sent') {
          // 延迟刷新，确保后端已保存邮件
          setTimeout(() => {
            loadEmails('sent')
          }, 500)
        }
      }
      
      // 清空表单
      setTimeout(() => {
        clearForm()
        editingDraftId.value = null // 确保清空编辑状态
      }, 1000)
    } else {
      // 处理不同类型的错误
      if (data.error === '附件大小超限' || data.error === '附件总大小超限') {
        // 附件大小超限错误
        let errorMessage = data.message || data.error
        if (data.details) {
          if (data.details.oversizedFiles && data.details.oversizedFiles.length > 0) {
            const fileList = data.details.oversizedFiles.map((f: any) => `${f.name} (${f.size})`).join('\n')
            errorMessage = `附件大小超限：\n${fileList}\n\n单文件最大限制：${data.details.maxSingleFileSize || '10MB'}`
          } else if (data.details.totalSize) {
            errorMessage = `附件总大小超限：\n当前总大小：${data.details.totalSize}\n最大限制：${data.details.maxTotalSize || '50MB'}\n\n请删除部分附件或分批发送。`
          }
        }
        notice.value = errorMessage
        noticeType.value = 'error'
        
        userLogger.logMailOperation('send_failed', {
          to: to.value,
          reason: 'attachment_size_exceeded',
          details: data.details
        })
      } else if (data.domainCheck) {
        // 域名验证错误
        notice.value = `域名验证失败：${data.domainCheck.message}`
        noticeType.value = 'error'
        
        userLogger.logMailOperation('send_failed', {
          to: to.value,
          reason: 'domain_check_failed',
          domain: data.domainCheck.fromDomain || data.domainCheck.toDomain
        })
      } else if (data.spamDetection) {
        // 垃圾邮件检测错误
        const violations = data.spamDetection.violations
        const keywords = data.spamDetection.detectedKeywords
        let violationMessages = violations.map(v => v.message).join('\n')
        let keywordMessage = keywords.length > 0 ? `\n检测到的违禁关键词: ${keywords.join(', ')}` : ''
        
        notice.value = `邮件被垃圾邮件过滤器阻止！\n\n违规详情:\n${violationMessages}${keywordMessage}\n\n垃圾邮件评分: ${data.spamDetection.spamScore}\n\n请修改邮件内容后重试。`
        noticeType.value = 'error'
        
        userLogger.logMailOperation('send_failed', {
          to: to.value,
          reason: 'spam_detected',
          spamScore: data.spamDetection.spamScore
        })
      } else {
        // 其他错误
        notice.value = data.message || data.error || '邮件发送失败'
        noticeType.value = 'error'
        
        userLogger.logMailOperation('send_failed', {
          to: to.value,
          reason: data.error || 'unknown_error'
        })
      }
    }
  } catch (error) {
    console.error('Error sending email:', error)
    
    // 检查是否是网络错误或请求体过大错误
    let errorMessage = '网络错误，请重试'
    if (error instanceof TypeError && error.message.includes('fetch')) {
      errorMessage = '网络连接失败，请检查网络连接后重试'
    } else if (error instanceof Error) {
      // 检查是否是请求体过大错误
      if (error.message.includes('413') || error.message.includes('PayloadTooLargeError') || error.message.includes('request entity too large')) {
        const totalSize = attachments.value.reduce((sum, file) => sum + file.size, 0)
        errorMessage = `请求数据过大（附件总大小：${(totalSize / 1024 / 1024).toFixed(2)}MB），请减少附件数量或大小后重试`
      } else {
        errorMessage = `发送失败：${error.message}`
      }
    }
    
    notice.value = errorMessage
    noticeType.value = 'error'
    
    userLogger.logMailOperation('send_failed', {
      to: to.value,
      reason: 'network_error',
      errorMessage: error instanceof Error ? error.message : 'unknown'
    })
  } finally {
    clearInterval(progressIntervalId)
    clearInterval(timeUpdateInterval)
    setTimeout(() => {
      sending.value = false
      sendingProgress.value = 0
      elapsedTime.value = 0
      estimatedTime.value = 0
      startTime.value = 0
    }, 1000)
  }
}

// 格式化答复日期（显示详细时间）
function formatReplyDate(dateString: string) {
  if (!dateString) return ''
  
  try {
    const date = new Date(dateString)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))
    
    // 格式化日期时间
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')
    
    // 如果是今天，只显示时间
    if (diffDays === 0) {
      return `今天 ${hours}:${minutes}:${seconds}`
    }
    // 如果是昨天
    if (diffDays === 1) {
      return `昨天 ${hours}:${minutes}:${seconds}`
    }
    // 如果是一周内
    if (diffDays < 7) {
      return `${diffDays}天前 ${hours}:${minutes}:${seconds}`
    }
    // 其他情况显示完整日期时间
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
  } catch (error) {
    return dateString
  }
}

// 打开答复对话框
async function openReplyDialog(replyAll: boolean = false) {
  if (!selectedEmail.value) return
  
  isReplyAll.value = replyAll
  
  // 获取当前用户邮箱（用于排除自己）
  let currentUserEmail: string | null = null
  try {
    currentUserEmail = await getCurrentUserEmail()
  } catch (error) {
    console.error('Failed to get current user email:', error)
    // 如果获取失败，尝试从sessionStorage获取用户名
    const auth = sessionStorage.getItem('apiAuth')
    if (auth) {
      try {
        const decoded = atob(auth)
        const username = decoded.split(':')[0]
        currentUserEmail = `${username}@localhost` // 默认格式
      } catch (e) {
        console.error('Failed to decode auth:', e)
      }
    }
  }
  
  // 获取原邮件的收件人和抄送人
  const originalFrom = selectedEmail.value.from || ''
  const originalTo = selectedEmail.value.to || ''
  const originalCC = selectedEmail.value.cc || ''
  
  // 处理收件人列表（支持新格式recipients）
  let originalToList: string[] = []
  let originalCCList: string[] = []
  
  if (selectedEmail.value.recipients) {
    originalToList = selectedEmail.value.recipients.to || []
    originalCCList = selectedEmail.value.recipients.cc || []
  } else {
    // 向后兼容旧格式
    if (originalTo) {
      originalToList = originalTo.split(',').map(addr => addr.trim()).filter(addr => addr)
    }
    if (originalCC) {
      originalCCList = originalCC.split(',').map(addr => addr.trim()).filter(addr => addr)
    }
  }
  
  if (replyAll) {
    // 全部答复：收件人 = 原发件人 + 原收件人（排除自己），抄送 = 原抄送人（排除自己）
    const toList: string[] = []
    const ccList: string[] = []
    
    // 添加原发件人（如果不是自己）
    if (originalFrom && (!currentUserEmail || !originalFrom.toLowerCase().includes(currentUserEmail.toLowerCase().split('@')[0]))) {
      toList.push(originalFrom)
    }
    
    // 添加原收件人（排除自己和原发件人）
    originalToList.forEach(addr => {
      if (addr && addr.trim()) {
        const addrLower = addr.toLowerCase()
        const isSelf = currentUserEmail && addrLower.includes(currentUserEmail.toLowerCase().split('@')[0])
        const isOriginalSender = addrLower === originalFrom.toLowerCase()
        if (!isSelf && !isOriginalSender && !toList.some(a => a.toLowerCase() === addrLower)) {
          toList.push(addr.trim())
        }
      }
    })
    
    // 添加原抄送人（排除自己、原发件人和已在收件人列表中的）
    originalCCList.forEach(addr => {
      if (addr && addr.trim()) {
        const addrLower = addr.toLowerCase()
        const isSelf = currentUserEmail && addrLower.includes(currentUserEmail.toLowerCase().split('@')[0])
        const isOriginalSender = addrLower === originalFrom.toLowerCase()
        const alreadyInTo = toList.some(a => a.toLowerCase() === addrLower)
        if (!isSelf && !isOriginalSender && !alreadyInTo && !ccList.some(a => a.toLowerCase() === addrLower)) {
          ccList.push(addr.trim())
        }
      }
    })
    
    replyTo.value = toList.join(', ')
    replyCC.value = ccList.join(', ')
  } else {
    // 单独答复：仅对原发件人发送
    replyTo.value = originalFrom
    replyCC.value = ''
  }
  
  // 设置主题（添加Re:前缀，如果还没有的话）
  const originalSubject = selectedEmail.value.subject || ''
  if (originalSubject.startsWith('Re:') || originalSubject.startsWith('RE:')) {
    replySubject.value = originalSubject
  } else {
    replySubject.value = `Re: ${originalSubject}`
  }
  
  // 初始化邮件正文（引用原文）
  const originalBody = selectedEmail.value.body || selectedEmail.value.html || ''
  const originalDate = formatReplyDate(selectedEmail.value.date)
  
  // 构建引用原文（默认折叠，只显示基本信息）
  // 确保body字段不为空，如果原邮件body为空，使用占位符
  const quotedBody = originalBody.trim() || '(原邮件内容为空)'
  
  // 构建收件人和抄送信息字符串
  let toInfo = ''
  let ccInfo = ''
  
  if (selectedEmail.value.recipients) {
    // 新格式：使用recipients对象
    if (selectedEmail.value.recipients.to && selectedEmail.value.recipients.to.length > 0) {
      toInfo = `收件人: ${selectedEmail.value.recipients.to.join(', ')}\n`
    }
    if (selectedEmail.value.recipients.cc && selectedEmail.value.recipients.cc.length > 0) {
      ccInfo = `抄送: ${selectedEmail.value.recipients.cc.join(', ')}\n`
    }
  } else {
    // 向后兼容旧格式
    if (originalTo && originalTo.trim()) {
      toInfo = `收件人: ${originalTo}\n`
    }
    if (originalCC && originalCC.trim()) {
      ccInfo = `抄送: ${originalCC}\n`
    }
  }
  
  replyQuote.value = `\n\n--- 原始邮件 ---\n发件人: ${originalFrom}\n${toInfo}${ccInfo}时间: ${originalDate}\n主题: ${originalSubject}\n\n${quotedBody}`
  
  // 清空用户输入区域
  replyBody.value = ''
  
  // 保存原始邮件的附件（只读），并添加发件人信息
  replyOriginalAttachments.value = selectedEmail.value.attachments && Array.isArray(selectedEmail.value.attachments) 
    ? selectedEmail.value.attachments.map(att => ({
        ...att,
        from: originalFrom // 添加发件人信息
      }))
    : []
  
  // 清空新附件列表
  replyAttachments.value = []
  if (replyFileInput.value) {
    replyFileInput.value.value = ''
  }
  
  // 默认折叠引用原文（只显示文本内容）
  replyQuoteExpanded.value = false
  
  // 显示对话框
  showReplyDialog.value = true
}

// 关闭答复对话框
function closeReplyDialog() {
  showReplyDialog.value = false
  replyTo.value = ''
  replyCC.value = ''
  replySubject.value = ''
  replyBody.value = ''
  replyQuote.value = ''
  replyQuoteExpanded.value = false
  isReplyAll.value = false
  replyAttachments.value = []
  replyOriginalAttachments.value = []
  if (replyFileInput.value) {
    replyFileInput.value.value = ''
  }
}

// 处理答复邮件的文件选择
function handleReplyFileSelect(event: Event) {
  try {
    const target = event.target as HTMLInputElement
    if (!target || !target.files) {
      console.warn('文件选择事件目标无效')
      return
    }
    
    const newFiles = Array.from(target.files)
    if (newFiles.length === 0) {
      console.warn('没有选择文件')
      return
    }
    
    const maxSize = 10 * 1024 * 1024 // 10MB限制
    
    // 检查文件大小
    const oversizedFiles = newFiles.filter(file => file.size > maxSize)
    if (oversizedFiles.length > 0) {
      notice.value = `文件 ${oversizedFiles.map(f => f.name).join(', ')} 超过10MB限制，已跳过`
      noticeType.value = 'warning'
    }
    
    // 只添加符合大小限制的文件
    const validFiles = newFiles.filter(file => file.size <= maxSize)
    
    if (validFiles.length === 0) {
      notice.value = '没有有效的文件可以添加'
      noticeType.value = 'warning'
      return
    }
    
    // 检查是否有重复文件（包括原始附件和新附件）
    const existingNames = new Set([
      ...replyAttachments.value.map(f => f.name),
      ...replyOriginalAttachments.value.map(a => a.name)
    ])
    const duplicateFiles = validFiles.filter(file => existingNames.has(file.name))
    if (duplicateFiles.length > 0) {
      notice.value = `文件 ${duplicateFiles.map(f => f.name).join(', ')} 已存在（可能是原始附件），已跳过`
      noticeType.value = 'warning'
    }
    
    const newValidFiles = validFiles.filter(file => !existingNames.has(file.name))
    replyAttachments.value = [...replyAttachments.value, ...newValidFiles]
    
    // 检查总大小
    const totalSize = replyAttachments.value.reduce((sum, file) => sum + file.size, 0)
    if (totalSize > 50 * 1024 * 1024) { // 50MB总限制
      notice.value = '附件总大小超过50MB，建议分批发送'
      noticeType.value = 'warning'
    } else if (newValidFiles.length > 0) {
      notice.value = `已添加 ${newValidFiles.length} 个附件`
      noticeType.value = 'success'
      setTimeout(() => {
        if (notice.value === `已添加 ${newValidFiles.length} 个附件`) {
          notice.value = ''
        }
      }, 2000)
    }
    
    // 重置文件输入，允许重复选择同一文件
    if (target) {
      target.value = ''
    }
  } catch (error) {
    console.error('处理文件选择时出错:', error)
    notice.value = `文件选择失败: ${error instanceof Error ? error.message : '未知错误'}`
    noticeType.value = 'error'
  }
}

// 移除答复邮件的附件
function removeReplyAttachment(index: number) {
  replyAttachments.value.splice(index, 1)
}

// 切换引用原文展开/折叠
function toggleReplyQuote() {
  replyQuoteExpanded.value = !replyQuoteExpanded.value
}

// 发送答复邮件
async function sendReply() {
  if (!replyTo.value) {
    notice.value = '请输入收件人'
    noticeType.value = 'error'
    return
  }
  
  if (!replySubject.value) {
    notice.value = '请输入邮件主题'
    noticeType.value = 'error'
    return
  }
  
  // 检查用户输入内容（允许为空，因为引用原文可能包含内容）
  // 但至少要有用户输入或引用原文
  if (!replyBody.value.trim() && !replyQuote.value.trim()) {
    notice.value = '请输入邮件内容或确保引用原文不为空'
    noticeType.value = 'error'
    return
  }
  
  sendingReply.value = true
  replyProgress.value = 0
  notice.value = ''
  replyStartTime.value = Date.now()
  replyElapsedTime.value = 0
  replyEstimatedTime.value = 0
  
  // 计算总附件大小（包括原始附件和新附件）
  const totalAttachmentSize = [
    ...replyOriginalAttachments.value.map(att => att.size || 0),
    ...replyAttachments.value.map(file => file.size)
  ].reduce((sum, size) => sum + size, 0)
  
  // 智能进度更新（根据附件大小调整）
  const hasAttachments = replyAttachments.value.length > 0 || replyOriginalAttachments.value.length > 0
  replyIsLargeFile.value = totalAttachmentSize > 100 * 1024 // 大于100KB
  
  // 根据文件大小估算预计时间（与大文件发送保持一致）
  let baseTime = 5 // 基础5秒
  if (totalAttachmentSize > 30 * 1024 * 1024) { // 大于30MB
    baseTime = 600 // 10分钟
  } else if (totalAttachmentSize > 20 * 1024 * 1024) { // 大于20MB
    baseTime = 480 // 8分钟
  } else if (totalAttachmentSize > 10 * 1024 * 1024) { // 大于10MB
    baseTime = 360 // 6分钟
  } else if (totalAttachmentSize > 5 * 1024 * 1024) { // 大于5MB
    baseTime = 240 // 4分钟
  } else if (totalAttachmentSize > 1024 * 1024) { // 大于1MB
    baseTime = 180 // 3分钟
  } else if (totalAttachmentSize > 500 * 1024) { // 大于500KB
    baseTime = 120 // 2分钟
  } else if (totalAttachmentSize > 100 * 1024) { // 大于100KB
    baseTime = 30 // 30秒
  }
  replyEstimatedTime.value = baseTime
  
  let progressStep = 15
  let progressInterval = 200
  
  if (replyIsLargeFile.value) {
    progressStep = 5 // 大文件进度更慢
    progressInterval = 500 // 更新间隔更长
  }
  
  // 在try块外声明定时器变量，以便在finally块中清理
  let replyProgressIntervalId: ReturnType<typeof setInterval> | null = null
  let replyTimeUpdateInterval: ReturnType<typeof setInterval> | null = null
  
  replyProgressIntervalId = setInterval(() => {
    if (replyProgress.value < 90) {
      replyProgress.value += Math.random() * progressStep
      
      // 更新已用时间
      replyElapsedTime.value = Math.floor((Date.now() - replyStartTime.value) / 1000)
      
      // 动态调整预计剩余时间
      if (replyProgress.value > 0) {
        const remainingProgress = 100 - replyProgress.value
        const timePerPercent = replyElapsedTime.value / replyProgress.value
        replyEstimatedTime.value = Math.max(1, Math.round(remainingProgress * timePerPercent))
      }
    }
  }, progressInterval)
  
  // 实时时间更新器（更频繁的更新）
  replyTimeUpdateInterval = setInterval(() => {
    if (sendingReply.value) {
      replyElapsedTime.value = Math.floor((Date.now() - replyStartTime.value) / 1000)
    }
  }, 1000) // 每秒更新一次
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const userEmail = await getCurrentUserEmail()
    
    if (!userEmail) {
      notice.value = '无法获取用户邮箱地址，请确保您已在邮件系统中注册'
      noticeType.value = 'error'
      // 清理进度更新定时器
      if (replyProgressIntervalId) clearInterval(replyProgressIntervalId)
      if (replyTimeUpdateInterval) clearInterval(replyTimeUpdateInterval)
      sendingReply.value = false
      return
    }
    
    // 合并用户输入的内容和引用原文
    // 确保finalBody不为空
    const userContent = replyBody.value.trim()
    const quoteContent = replyQuote.value.trim()
    const finalBody = userContent + (userContent && quoteContent ? '\n\n' : '') + quoteContent
    
    // 再次检查finalBody是否为空
    if (!finalBody.trim()) {
      notice.value = '邮件内容不能为空'
      noticeType.value = 'error'
      sendingReply.value = false
      return
    }
    
    // 处理附件：包含原始附件和新添加的附件
    const allAttachments: any[] = []
    
    // 添加调试日志（在allAttachments声明之后）
    console.log('发送答复邮件:', {
      to: replyTo.value,
      cc: replyCC.value,
      subject: replySubject.value,
      bodyLength: finalBody.length,
      userContentLength: userContent.length,
      quoteContentLength: quoteContent.length,
      originalAttachmentsCount: replyOriginalAttachments.value.length,
      newAttachmentsCount: replyAttachments.value.length
    })
    
    // 先添加原始附件（直接使用，不需要转换）
    // 注意：为原始附件添加来源信息，以便在邮件详情中显示
    if (replyOriginalAttachments.value.length > 0) {
      replyOriginalAttachments.value.forEach(att => {
        allAttachments.push({
          name: att.name,
          size: att.size || 0,
          type: att.type || 'application/octet-stream',
          content: att.content || '', // 原始附件已经有Base64内容
          from: att.from || selectedEmail.value?.from || '' // 添加发件人信息作为来源
        })
      })
    }
    
    // 再添加新附件（需要转换为Base64）
    // 新附件来自当前用户（发送答复邮件的用户）
    if (replyAttachments.value.length > 0) {
      const newAttachmentsData = await Promise.all(replyAttachments.value.map(async (file) => {
        try {
          const base64Content = await fileToBase64(file)
          return {
            name: file.name,
            size: file.size,
            type: file.type || 'application/octet-stream',
            content: base64Content,
            from: userEmail // 新附件来自当前用户
          }
        } catch (error) {
          console.error(`附件 ${file.name} 转换失败:`, error)
          notice.value = `附件 ${file.name} 处理失败: ${error instanceof Error ? error.message : '未知错误'}`
          noticeType.value = 'error'
          throw error
        }
      }))
      allAttachments.push(...newAttachmentsData)
    }
    
    const response = await fetch('/api/mail/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        to: replyTo.value,
        cc: replyCC.value || '',
        subject: replySubject.value,
        body: finalBody,
        from: userEmail,
        attachments: allAttachments
      })
    })
    
    const data = await response.json()
    
    if (response.ok && data.success) {
      // 清理进度更新定时器
      if (replyProgressIntervalId) clearInterval(replyProgressIntervalId)
      if (replyTimeUpdateInterval) clearInterval(replyTimeUpdateInterval)
      
      replyProgress.value = 100
      notice.value = '答复邮件发送成功！'
      noticeType.value = 'success'
      
      // 关闭答复对话框
      closeReplyDialog()
      
      // 关闭邮件详情对话框
      closeEmailDetail()
      
      // 刷新已发送文件夹
      if (view.value === 'sent') {
        setTimeout(() => {
          loadEmails('sent')
        }, 500)
      }
      
      // 刷新邮件统计
      loadMailStats()
      
      // 记录发送成功
      userLogger.logMailOperation('reply_success', {
        to: replyTo.value,
        cc: replyCC.value || '',
        subject: replySubject.value,
        originalEmailId: selectedEmail.value?.id,
        replyAll: isReplyAll.value
      })
    } else {
      // 清理进度更新定时器
      if (replyProgressIntervalId) clearInterval(replyProgressIntervalId)
      if (replyTimeUpdateInterval) clearInterval(replyTimeUpdateInterval)
      
      // 处理不同类型的错误
      if (data.error === '附件大小超限' || data.error === '附件总大小超限') {
        // 附件大小超限错误
        let errorMessage = data.message || data.error
        if (data.details) {
          if (data.details.oversizedFiles && data.details.oversizedFiles.length > 0) {
            const fileList = data.details.oversizedFiles.map((f: any) => `${f.name} (${f.size})`).join('\n')
            errorMessage = `附件大小超限：\n${fileList}\n\n单文件最大限制：${data.details.maxSingleFileSize || '10MB'}`
          } else if (data.details.totalSize) {
            errorMessage = `附件总大小超限：\n当前总大小：${data.details.totalSize}\n最大限制：${data.details.maxTotalSize || '50MB'}\n\n请删除部分附件或分批发送。`
          }
        }
        notice.value = errorMessage
        noticeType.value = 'error'
        
        userLogger.logMailOperation('reply_failed', {
          to: replyTo.value,
          reason: 'attachment_size_exceeded',
          details: data.details
        })
      } else {
        notice.value = data.message || data.error || '答复邮件发送失败'
        noticeType.value = 'error'
        
        userLogger.logMailOperation('reply_failed', {
          to: replyTo.value,
          reason: data.error || 'unknown_error'
        })
      }
    }
  } catch (error) {
    console.error('Error sending reply:', error)
    
    // 检查是否是网络错误或请求体过大错误
    let errorMessage = '网络错误，请重试'
    if (error instanceof TypeError && error.message.includes('fetch')) {
      errorMessage = '网络连接失败，请检查网络连接后重试'
    } else if (error instanceof Error) {
      // 检查是否是请求体过大错误
      if (error.message.includes('413') || error.message.includes('PayloadTooLargeError') || error.message.includes('request entity too large')) {
        const totalSize = [...replyOriginalAttachments.value, ...replyAttachments.value].reduce((sum, file) => {
          return sum + (file.size || 0)
        }, 0)
        errorMessage = `请求数据过大（附件总大小：${(totalSize / 1024 / 1024).toFixed(2)}MB），请减少附件数量或大小后重试`
      } else {
        errorMessage = `发送失败：${error.message}`
      }
    }
    
    notice.value = errorMessage
    noticeType.value = 'error'
    
    userLogger.logMailOperation('reply_failed', {
      to: replyTo.value,
      reason: 'network_error',
      errorMessage: error instanceof Error ? error.message : 'unknown'
    })
  } finally {
    // 清理进度更新定时器
    if (replyProgressIntervalId) clearInterval(replyProgressIntervalId)
    if (replyTimeUpdateInterval) clearInterval(replyTimeUpdateInterval)
    sendingReply.value = false
    // 延迟重置进度，让用户看到100%完成状态
    setTimeout(() => {
      replyProgress.value = 0
      replyElapsedTime.value = 0
      replyEstimatedTime.value = 0
    }, 1000)
  }
}

function formatDate(dateString: string) {
  if (!dateString) return '未知时间'
  
  // 调试输出
  console.log('时间字符串:', dateString, '类型:', typeof dateString)
  
  // 尝试直接解析
  let date = new Date(dateString)
  console.log('直接解析结果:', date, '是否有效:', !isNaN(date.getTime()))
  
  // 如果解析失败，尝试添加时区信息
  if (isNaN(date.getTime())) {
    const dateWithTimezone = dateString + ' GMT+0800'
    date = new Date(dateWithTimezone)
    console.log('添加时区后:', dateWithTimezone, '解析结果:', date)
  }
  
  // 如果还是失败，尝试ISO格式
  if (isNaN(date.getTime())) {
    const isoFormat = dateString.replace(' ', 'T')
    date = new Date(isoFormat)
    console.log('ISO格式:', isoFormat, '解析结果:', date)
  }
  
  if (isNaN(date.getTime())) {
    console.error('无法解析时间:', dateString)
    return '时间格式错误'
  }
  
  // 直接使用本地时间格式化，不进行时区转换
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  
  return `${year}/${month}/${day} ${hours}:${minutes}`
}

// 解析邮件正文，分离用户输入和多个引用原文
interface ParsedQuote {
  from?: string
  to?: string | string[]
  cc?: string | string[]
  date?: string
  subject?: string
  body?: string
}

interface ParsedEmailContent {
  userContent: string
  quotes: ParsedQuote[]
}

function parseEmailContent(body: string): ParsedEmailContent {
  if (!body || !body.trim()) {
    return { userContent: '', quotes: [] }
  }
  
  // 分割邮件正文，查找所有"--- 原始邮件 ---"分隔符
  const separator = '--- 原始邮件 ---'
  const parts = body.split(separator)
  
  // 第一部分是用户输入的内容
  const userContent = parts[0]?.trim() || ''
  
  // 后续部分都是引用原文
  const quotes: ParsedQuote[] = []
  
  for (let i = 1; i < parts.length; i++) {
    const quoteText = parts[i]?.trim()
    if (!quoteText) continue
    
    const quote: ParsedQuote = {}
    
    // 解析发件人
    const fromMatch = quoteText.match(/发件人:\s*(.+?)(?:\n|$)/i)
    if (fromMatch) {
      quote.from = fromMatch[1].trim()
    }
    
    // 解析收件人
    const toMatch = quoteText.match(/收件人:\s*(.+?)(?:\n|$)/i)
    if (toMatch) {
      const toStr = toMatch[1].trim()
      quote.to = toStr.includes(',') ? toStr.split(',').map(a => a.trim()) : toStr
    }
    
    // 解析抄送
    const ccMatch = quoteText.match(/抄送:\s*(.+?)(?:\n|$)/i)
    if (ccMatch) {
      const ccStr = ccMatch[1].trim()
      quote.cc = ccStr.includes(',') ? ccStr.split(',').map(a => a.trim()) : ccStr
    }
    
    // 解析时间
    const dateMatch = quoteText.match(/时间:\s*(.+?)(?:\n|$)/i)
    if (dateMatch) {
      quote.date = dateMatch[1].trim()
    }
    
    // 解析主题
    const subjectMatch = quoteText.match(/主题:\s*(.+?)(?:\n|$)/i)
    if (subjectMatch) {
      quote.subject = subjectMatch[1].trim()
    }
    
    // 提取正文（在最后一个信息行之后的内容）
    // 查找所有信息行的结束位置
    const infoPatterns = [
      /发件人:\s*.+?\n/gi,
      /收件人:\s*.+?\n/gi,
      /抄送:\s*.+?\n/gi,
      /时间:\s*.+?\n/gi,
      /主题:\s*.+?\n/gi
    ]
    
    let lastInfoEnd = 0
    for (const pattern of infoPatterns) {
      const matches = [...quoteText.matchAll(pattern)]
      for (const match of matches) {
        const endPos = match.index! + match[0].length
        if (endPos > lastInfoEnd) {
          lastInfoEnd = endPos
        }
      }
    }
    
    // 提取正文（在最后一个信息行之后）
    if (lastInfoEnd > 0) {
      const bodyText = quoteText.substring(lastInfoEnd).trim()
      quote.body = bodyText || '(无内容)'
    } else {
      // 如果没有找到信息行，整个内容就是正文
      quote.body = quoteText || '(无内容)'
    }
    
    quotes.push(quote)
  }
  
  return { userContent, quotes }
}

// 计算属性：解析当前选中邮件的正文
const parsedEmailContent = computed<ParsedEmailContent>(() => {
  if (!selectedEmail.value?.body) {
    return { userContent: '', quotes: [] }
  }
  return parseEmailContent(selectedEmail.value.body)
})

// 邮件 HTML 经 DOMPurify 消毒后展示，防止 XSS
const sanitizedEmailHtml = computed(() => {
  const html = selectedEmail.value?.html
  if (!html || !String(html).trim()) return ''
  return DOMPurify.sanitize(html)
})

// 获取附件来源（发件人）
function getAttachmentSource(attachment: any): string | null {
  // 如果附件本身有from字段，直接返回（这是最准确的方式）
  if (attachment.from) {
    return attachment.from
  }
  
  // 如果邮件是答复邮件（有引用原文），尝试推断来源
  if (parsedEmailContent.value.quotes.length > 0) {
    // 答复邮件中，附件可能来自：
    // 1. 当前邮件的发件人（新添加的附件）
    // 2. 某个引用原文的发件人（原始附件）
    
    // 由于我们无法准确知道附件来自哪个原始邮件，我们采用以下策略：
    // - 如果邮件有引用原文，说明这是答复邮件
    // - 附件可能是从原始邮件继承的，也可能是新添加的
    // - 我们显示当前邮件的发件人，因为附件是在当前邮件中显示的
    // 注意：这不够准确，但至少能告诉用户附件是在哪个邮件中显示的
    
    // 更好的方法是：检查附件名称是否在引用原文中出现
    // 如果出现，可能是原始附件；否则，可能是新附件
    const attachmentName = attachment.name || ''
    let foundInQuote = false
    let quoteFrom = null
    
    // 检查附件名称是否在某个引用原文中提到
    for (const quote of parsedEmailContent.value.quotes) {
      if (quote.body && quote.body.includes(attachmentName)) {
        foundInQuote = true
        quoteFrom = quote.from
        break
      }
    }
    
    // 如果附件名称在引用原文中找到，显示引用原文的发件人
    if (foundInQuote && quoteFrom) {
      return quoteFrom
    }
    
    // 否则，显示当前邮件的发件人（可能是新添加的附件）
    if (selectedEmail.value?.from) {
      return selectedEmail.value.from
    }
  } else {
    // 如果没有引用原文，附件来自当前邮件的发件人
    if (selectedEmail.value?.from) {
      return selectedEmail.value.from
    }
  }
  
  return null
}

// 用户选择器相关方法
async function showUserSelector(type: 'to'|'cc') {
  userSelectorType.value = type
  showUserSelectorModal.value = true
  loadingUsers.value = true
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      console.error('未找到认证信息，无法查询用户列表')
      return
    }
    
    const response = await fetch('/api/ops', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify({
        action: 'query-users'
      })
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.users) {
        users.value = data.users
      } else {
        console.error('获取用户列表失败:', data.message)
        users.value = []
      }
    } else {
      console.error('获取用户列表失败:', response.statusText)
      users.value = []
    }
  } catch (error) {
    console.error('获取用户列表错误:', error)
    users.value = []
  } finally {
    loadingUsers.value = false
  }
}

function closeUserSelector() {
  showUserSelectorModal.value = false
  users.value = []
}

function selectUser(user: any) {
  if (userSelectorType.value === 'to') {
    // 收件人只能选择一个
    to.value = user.email
    closeUserSelector()
  } else {
    // 抄送可以选择多个
    if (!isUserSelected(user)) {
      selectedCCUsers.value.push(user)
    } else {
      // 如果已选择，则取消选择
      const index = selectedCCUsers.value.findIndex(u => u.id === user.id)
      if (index > -1) {
        selectedCCUsers.value.splice(index, 1)
      }
    }
  }
}

function isUserSelected(user: any) {
  return selectedCCUsers.value.some(u => u.id === user.id)
}

function confirmCCSelection() {
  // 更新抄送输入框
  const emails = selectedCCUsers.value.map(user => user.email).join(', ')
  cc.value = emails
  closeUserSelector()
}

// 加载广播消息
async function loadBroadcast() {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      return
    }
    
    const response = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.settings && data.settings.broadcast) {
        broadcastMessage.value = data.settings.broadcast.message || ''
        // 根据消息长度调整滚动速度
        if (broadcastMessage.value) {
          const messageLength = broadcastMessage.value.length
          scrollDuration.value = Math.max(15, Math.min(30, messageLength / 5))
        }
      }
    }
  } catch (error) {
    console.error('加载广播消息失败:', error)
  }
}

function removeCCUser(index: number) {
  selectedCCUsers.value.splice(index, 1)
  // 同步更新抄送输入框
  const emails = selectedCCUsers.value.map(user => user.email).join(', ')
  cc.value = emails
}

function logout() {
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

// 页面访问日志记录
userLogger.logPageView('/mail')

// 组件挂载时检查服务状态
onMounted(async () => {
  // 获取管理员邮箱
  fetchAdminEmail()

  // 加载分页设置
  loadPageSizeFromSettings()

  // 加载文件夹列表
  loadFolders()

  // 获取当前用户邮箱（用于判断抄送标记）
  try {
    const userEmail = await getCurrentUserEmail()
    currentUserEmail.value = userEmail
    console.log('当前用户邮箱已设置:', userEmail)
  } catch (error) {
    console.error('获取当前用户邮箱失败:', error)
  }

  // 加载广播消息
  await loadBroadcast()

  // 监听窗口大小变化
  window.addEventListener('resize', updateWindowWidth)

  // 先检查服务状态
  await checkServiceStatus()
  
  // 如果系统就绪，加载邮件数据
  if (serviceStatus.value.mail_system_ready) {
    loadEmails('inbox')
    loadMailStats()
  }
  
  // 监听视图变化，启动/停止自动保存
  if (view.value === 'compose') {
    setupAutoSaveDraft()
  }
})

// 组件卸载时清理事件监听器
onUnmounted(() => {
  window.removeEventListener('resize', updateWindowWidth)
})

const noticeClass = computed(() => {
  if (noticeType.value==='success') return 'text-green-600 dark:text-green-400'
  if (noticeType.value==='error') return 'text-red-600 dark:text-red-400'
  return 'text-yellow-700 dark:text-yellow-400'
})

// DNS服务状态相关函数
const getDnsServiceStatus = () => {
  // 如果是公网DNS，不需要检查Bind服务
  if (serviceStatus.value.dns?.dns_type === 'public') {
    return true // 公网DNS总是显示为正常
  }
  // 本地DNS需要检查Bind服务
  return serviceStatus.value.services?.named || false
}

const getDnsServiceName = () => {
  if (serviceStatus.value.dns?.dns_type === 'public') {
    return '公网DNS (域名解析服务)'
  }
  return 'Bind DNS (域名解析服务)'
}

const getDnsServiceErrorMessage = () => {
  if (serviceStatus.value.dns?.dns_type === 'public') {
    return '公网DNS配置可能有问题，请检查域名解析设置。'
  }
  return '可能原因：服务未安装、未启动或配置错误。请检查服务状态或重新安装配置。'
}
</script>

<style scoped>
/* 邮件主题动画效果 */
@keyframes float {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-20px) rotate(5deg); }
}

@keyframes float-delayed {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-15px) rotate(-3deg); }
}

@keyframes float-slow {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(-10px) rotate(2deg); }
}

@keyframes float-reverse {
  0%, 100% { transform: translateY(0px) rotate(0deg); }
  50% { transform: translateY(15px) rotate(-2deg); }
}

@keyframes mail-drift {
  0% { transform: translateX(0px) translateY(0px); }
  25% { transform: translateX(10px) translateY(-5px); }
  50% { transform: translateX(-5px) translateY(-10px); }
  75% { transform: translateX(-10px) translateY(5px); }
  100% { transform: translateX(0px) translateY(0px); }
}

.animate-float {
  animation: float 6s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 8s ease-in-out infinite;
  animation-delay: 2s;
}

.animate-float-slow {
  animation: float-slow 10s ease-in-out infinite;
  animation-delay: 1s;
}

.animate-float-reverse {
  animation: float-reverse 7s ease-in-out infinite;
  animation-delay: 3s;
}

.animate-mail-drift {
  animation: mail-drift 12s ease-in-out infinite;
}

/* 网格背景图案 */
.bg-grid-pattern {
  background-image: 
    linear-gradient(rgba(59, 130, 246, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(59, 130, 246, 0.1) 1px, transparent 1px);
  background-size: 20px 20px;
}

/* 邮件主题渐变背景 */
.bg-mail-gradient {
  background: linear-gradient(135deg, 
    rgba(59, 130, 246, 0.1) 0%, 
    rgba(99, 102, 241, 0.1) 25%, 
    rgba(139, 92, 246, 0.1) 50%, 
    rgba(168, 85, 247, 0.1) 75%, 
    rgba(236, 72, 153, 0.1) 100%);
}

/* 邮件列表项进入动画 */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.email-item {
  animation: fadeInUp 0.5s ease-out forwards;
  opacity: 0;
}

/* 淡入动画 */
@keyframes fade-in {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

.animate-fade-in {
  animation: fade-in 0.6s ease-out;
}

/* 邮件列表过渡动画 */
.email-list-enter-active {
  transition: all 0.5s ease-out;
}

.email-list-leave-active {
  transition: all 0.3s ease-in;
}

.email-list-enter-from {
  opacity: 0;
  transform: translateY(20px) scale(0.95);
}

.email-list-leave-to {
  opacity: 0;
  transform: translateX(-20px) scale(0.95);
}

.email-list-move {
  transition: transform 0.5s ease;
}


/* 移动按钮组悬停效果 - 只在悬停按钮容器本身时显示下拉菜单 */
.move-button-group:hover > div[class*="opacity-0"] {
  opacity: 1 !important;
  visibility: visible !important;
  transform: translateY(0) !important;
}

.move-button-group:hover svg[class*="text-gray-500"] {
  color: rgb(37, 99, 235) !important;
}

/* 答复按钮组悬停效果 */
.reply-button-group:hover .reply-dropdown {
  opacity: 1 !important;
  visibility: visible !important;
  transform: translateY(0) !important;
}

.reply-button-group:hover .reply-arrow {
  transform: rotate(180deg);
  transition: transform 0.2s ease;
}

/* 平滑滚动 */
* {
  scroll-behavior: smooth;
}

/* 广播消息横向轮播动画 */
@keyframes scroll {
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-50%);
  }
}

.animate-scroll {
  animation: scroll linear infinite;
  display: flex;
  width: max-content;
}

/* 删除确认对话框过渡效果 */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-active .relative,
.fade-leave-active .relative {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.fade-enter-from {
  opacity: 0;
}

.fade-enter-from .relative {
  transform: scale(0.9) translateY(-10px);
  opacity: 0;
}

.fade-leave-to {
  opacity: 0;
}

.fade-leave-to .relative {
  transform: scale(0.9) translateY(-10px);
  opacity: 0;
}

/* 答复对话框引用原文折叠/展开过渡效果 */
.slide-fade-enter-active {
  transition: all 0.3s ease-out;
}

.slide-fade-leave-active {
  transition: all 0.3s ease-in;
}

.slide-fade-enter-from {
  transform: translateY(-10px);
  opacity: 0;
}

.slide-fade-leave-to {
  transform: translateY(-10px);
  opacity: 0;
}
</style>


