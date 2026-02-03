<template>
  <Layout>
    <!-- 动态背景 -->
    <div class="relative min-h-screen overflow-hidden">
      <!-- 背景装饰 -->
      <div class="absolute inset-0 bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50">
        <!-- 浮动圆形装饰 -->
        <div class="absolute top-20 left-10 w-32 h-32 bg-gradient-to-r from-blue-400 to-purple-500 rounded-full opacity-20 animate-float"></div>
        <div class="absolute top-40 right-20 w-24 h-24 bg-gradient-to-r from-green-400 to-blue-500 rounded-full opacity-15 animate-float-delayed"></div>
        <div class="absolute bottom-20 left-1/4 w-40 h-40 bg-gradient-to-r from-purple-400 to-pink-500 rounded-full opacity-10 animate-float-slow"></div>
        <div class="absolute bottom-40 right-1/3 w-28 h-28 bg-gradient-to-r from-yellow-400 to-orange-500 rounded-full opacity-20 animate-float-reverse"></div>
        
        <!-- 网格背景 -->
        <div class="absolute inset-0 bg-grid-pattern opacity-5"></div>
      </div>
      
      <!-- 主内容区域 -->
      <div class="relative z-10 p-3 sm:p-6">
      <!-- 系统操作卡片 -->
      <div class="bg-white/80 backdrop-blur-sm shadow-xl rounded-2xl mb-6 border border-white/20 animate-fade-in-up">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4 flex items-center">
            <svg class="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
            </svg>
            系统管理
          </h3>
          <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3 sm:gap-4">
            <!-- 环境检查 -->
            <button @click="() => { userLogger.logButtonClick('环境检查', '系统管理'); openEnvironmentCheckDialog() }" 
                    class="group relative overflow-hidden bg-gradient-to-br from-cyan-500 via-blue-500 to-indigo-600 hover:from-cyan-600 hover:via-blue-600 hover:to-indigo-700 text-white px-3 sm:px-6 py-3 sm:py-4 rounded-xl sm:rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-cyan-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none animate-bounce-in" style="animation-delay: 0.1s">
              <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-20 transition-opacity duration-300"></div>
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2">
                <svg class="h-5 w-5 sm:h-6 sm:w-6 group-hover:rotate-12 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span class="text-xs sm:text-sm font-semibold">环境检查</span>
              </div>
            </button>


            <!-- 安装服务 -->
            <button @click="() => { userLogger.logButtonClick('安装服务', '系统管理'); openInstallDialog() }" 
                    :disabled="loading"
                    class="group relative overflow-hidden bg-gradient-to-br from-violet-500 via-purple-500 to-fuchsia-600 hover:from-violet-600 hover:via-purple-600 hover:to-fuchsia-700 text-white px-3 sm:px-6 py-3 sm:py-4 rounded-xl sm:rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-violet-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none animate-bounce-in" style="animation-delay: 0.3s">
              <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-20 transition-opacity duration-300"></div>
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2">
                <svg class="h-5 w-5 sm:h-6 sm:w-6 group-hover:translate-y-1 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                </svg>
                <span class="text-xs sm:text-sm font-semibold">安装服务</span>
              </div>
            </button>

            <!-- 配置服务 -->
            <button @click="() => { userLogger.logButtonClick('配置服务', '系统管理'); openConfigDialog() }" 
                    :disabled="loading"
                    class="group relative overflow-hidden bg-gradient-to-br from-rose-500 via-pink-500 to-red-600 hover:from-rose-600 hover:via-pink-600 hover:to-red-700 text-white px-3 sm:px-6 py-3 sm:py-4 rounded-xl sm:rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-rose-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none animate-bounce-in" style="animation-delay: 0.4s">
              <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-20 transition-opacity duration-300"></div>
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2">
                <svg class="h-5 w-5 sm:h-6 sm:w-6 group-hover:rotate-12 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                <span class="text-xs sm:text-sm font-semibold">配置服务</span>
              </div>
            </button>

            <!-- 服务管理 -->
            <button @click="() => { userLogger.logButtonClick('服务管理', '系统管理'); openServiceManagementDialog() }" 
                    :disabled="loading"
                    class="group relative overflow-hidden bg-gradient-to-br from-orange-500 via-red-500 to-pink-500 hover:from-orange-600 hover:via-red-600 hover:to-pink-600 text-white px-3 sm:px-6 py-3 sm:py-4 rounded-xl sm:rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-orange-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none animate-bounce-in" style="animation-delay: 0.5s">
              <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2">
                <svg class="h-5 w-5 sm:h-6 sm:w-6 group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                </svg>
                <span class="text-xs sm:text-sm font-semibold">服务管理</span>
              </div>
            </button>

            <!-- 服务状态 -->
            <button @click="() => { userLogger.logButtonClick('服务状态', '系统管理'); openServiceStatusDialog() }" 
                    :disabled="loading"
                    class="group relative overflow-hidden bg-gradient-to-br from-blue-500 via-indigo-500 to-purple-500 hover:from-blue-600 hover:via-indigo-600 hover:to-purple-600 text-white px-3 sm:px-6 py-3 sm:py-4 rounded-xl sm:rounded-2xl shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-300 focus:outline-none focus:ring-4 focus:ring-blue-300 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none animate-bounce-in" style="animation-delay: 0.6s">
              <div class="absolute inset-0 bg-white opacity-0 group-hover:opacity-10 transition-opacity duration-300"></div>
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2">
                <svg class="h-5 w-5 sm:h-6 sm:w-6 group-hover:scale-110 transition-transform duration-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                </svg>
                <span class="text-xs sm:text-sm font-semibold">服务状态</span>
              </div>
            </button>

          </div>
        </div>
      </div>

      <!-- 高级功能卡片 -->
      <div class="bg-white/80 backdrop-blur-sm shadow-xl rounded-2xl mb-6 border border-white/20 animate-fade-in-up" style="animation-delay: 0.2s">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4 flex items-center">
            <svg class="w-5 h-5 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
            </svg>
            高级功能
          </h3>
          <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3 sm:gap-4">
            <!-- 申请证书 -->
            <button @click="() => { userLogger.logButtonClick('申请证书', '高级功能'); openCertDialog() }" 
                    :disabled="loading"
                    class="advanced-feature-card advanced-feature-card-amber group relative bg-white/90 backdrop-blur-sm border-2 border-amber-200 text-gray-800 px-3 sm:px-6 py-3 sm:py-4 rounded-lg sm:rounded-xl shadow-md focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:border-gray-200 animate-slide-in-left" style="animation-delay: 0.4s">
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2 z-10">
                <div class="advanced-feature-icon-wrapper p-1.5 sm:p-2 rounded-lg bg-amber-50 group-hover:bg-amber-100 transition-colors duration-300">
                  <svg class="advanced-feature-icon h-5 w-5 sm:h-6 sm:w-6 text-amber-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                </div>
                <span class="advanced-feature-text text-xs sm:text-sm font-semibold text-gray-700">申请证书</span>
              </div>
            </button>


            <!-- 备份功能 -->
            <button @click="() => { userLogger.logButtonClick('备份功能', '高级功能'); openBackupManagementDialog() }" 
                    :disabled="loading"
                    class="advanced-feature-card advanced-feature-card-blue group relative bg-white/90 backdrop-blur-sm border-2 border-blue-200 text-gray-800 px-3 sm:px-6 py-3 sm:py-4 rounded-lg sm:rounded-xl shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:border-gray-200 animate-slide-in-left" style="animation-delay: 0.7s">
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2 z-10">
                <div class="advanced-feature-icon-wrapper p-1.5 sm:p-2 rounded-lg bg-blue-50 group-hover:bg-blue-100 transition-colors duration-300">
                  <svg class="advanced-feature-icon h-5 w-5 sm:h-6 sm:w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"></path>
                  </svg>
                </div>
                <span class="advanced-feature-text text-xs sm:text-sm font-semibold text-gray-700">备份功能</span>
              </div>
            </button>

            <!-- 管理SSL -->
            <button @click="() => { userLogger.logButtonClick('管理SSL', '高级功能'); openSslManagementDialog() }" 
                    :disabled="loading"
                    class="advanced-feature-card advanced-feature-card-green group relative bg-white/90 backdrop-blur-sm border-2 border-green-200 text-gray-800 px-3 sm:px-6 py-3 sm:py-4 rounded-lg sm:rounded-xl shadow-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:border-gray-200 animate-slide-in-left" style="animation-delay: 0.9s">
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2 z-10">
                <div class="advanced-feature-icon-wrapper p-1.5 sm:p-2 rounded-lg bg-green-50 group-hover:bg-green-100 transition-colors duration-300">
                  <svg class="advanced-feature-icon h-5 w-5 sm:h-6 sm:w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                </div>
                <span class="advanced-feature-text text-xs sm:text-sm font-semibold text-gray-700">管理SSL</span>
              </div>
            </button>

            <!-- 垃圾邮件过滤配置 -->
            <button @click="() => { userLogger.logButtonClick('垃圾邮件过滤', '高级功能'); openSpamFilterDialog() }" 
                    :disabled="loading"
                    class="advanced-feature-card advanced-feature-card-orange group relative bg-white/90 backdrop-blur-sm border-2 border-rose-200 text-gray-800 px-3 sm:px-6 py-3 sm:py-4 rounded-lg sm:rounded-xl shadow-md focus:outline-none focus:ring-2 focus:ring-rose-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:border-gray-200 animate-slide-in-left" style="animation-delay: 0.9s">
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2 z-10">
                <div class="advanced-feature-icon-wrapper p-1.5 sm:p-2 rounded-lg bg-rose-50 group-hover:bg-rose-100 transition-colors duration-300">
                  <svg class="advanced-feature-icon h-5 w-5 sm:h-6 sm:w-6 text-rose-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
                <span class="advanced-feature-text text-xs sm:text-sm font-semibold text-gray-700">垃圾邮件过滤</span>
              </div>
            </button>

            <!-- 广播 -->
            <button @click="() => { userLogger.logButtonClick('广播', '高级功能'); openBroadcastDialog() }" 
                    :disabled="loading"
                    class="advanced-feature-card advanced-feature-card-blue group relative bg-white/90 backdrop-blur-sm border-2 border-blue-200 text-gray-800 px-3 sm:px-6 py-3 sm:py-4 rounded-lg sm:rounded-xl shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed disabled:border-gray-200 animate-slide-in-left" style="animation-delay: 1.0s">
              <div class="relative flex flex-col items-center space-y-1 sm:space-y-2 z-10">
                <div class="advanced-feature-icon-wrapper p-1.5 sm:p-2 rounded-lg bg-blue-50 group-hover:bg-blue-100 transition-colors duration-300">
                  <svg class="advanced-feature-icon h-5 w-5 sm:h-6 sm:w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5.882V19.24a1.76 1.76 0 01-3.417.592l-2.147-6.15M18 13a3 3 0 100-6M5.436 13.683A4.001 4.001 0 017 6h1.832c4.1 0 7.625-1.234 9.168-3v14c-1.543-1.766-5.067-3-9.168-3H7a3.988 3.988 0 01-1.564-.317z"></path>
                  </svg>
                </div>
                <span class="advanced-feature-text text-xs sm:text-sm font-semibold text-gray-700">广播</span>
              </div>
            </button>
          </div>
        </div>
      </div>

      <!-- 备份管理对话框 -->
      <div v-if="showBackupManagementDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeBackupManagementDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between sticky top-0 bg-white/95 backdrop-blur-sm z-10">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">备份管理</h3>
            <button @click="closeBackupManagementDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <!-- 标签页切换 -->
            <div class="border-b border-gray-200 mb-6">
              <nav class="-mb-px flex space-x-4">
                <button @click="backupTab = 'full'" 
                        :class="['py-2 px-4 text-sm font-medium border-b-2 transition-colors', 
                                 backupTab === 'full' 
                                   ? 'border-blue-500 text-blue-600' 
                                   : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300']">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"></path>
                  </svg>
                  完整备份
                </button>
                <button @click="backupTab = 'scheduled'" 
                        :class="['py-2 px-4 text-sm font-medium border-b-2 transition-colors', 
                                 backupTab === 'scheduled' 
                                   ? 'border-blue-500 text-blue-600' 
                                   : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300']">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                  定时备份
                </button>
              </nav>
            </div>
            
            <!-- 完整备份标签页 -->
            <div v-if="backupTab === 'full'" class="space-y-4">
              <div class="bg-blue-50 border border-blue-200 rounded-lg p-6">
                <div class="flex items-center justify-between mb-4">
                  <div>
                    <h4 class="text-lg font-medium text-blue-900 mb-2">立即执行完整备份</h4>
                    <p class="text-sm text-blue-700">备份所有数据库、配置文件和邮件数据</p>
                  </div>
                  <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center">
                    <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M9 19l3 3m0 0l3-3m-3 3V10"></path>
                    </svg>
                  </div>
                </div>
                <div class="bg-white rounded-lg p-4 mb-4">
                  <h5 class="text-sm font-medium text-gray-900 mb-3">备份内容</h5>
                  <ul class="space-y-2 text-sm text-gray-600">
                    <li class="flex items-center">
                      <svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                      </svg>
                      数据库备份（MariaDB）
                    </li>
                    <li class="flex items-center">
                      <svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                      </svg>
                      配置文件备份（Postfix, Dovecot, Apache等）
                    </li>
                    <li class="flex items-center">
                      <svg class="w-4 h-4 mr-2 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                      </svg>
                      邮件目录备份（/var/vmail）
                    </li>
                  </ul>
                </div>
                <button @click="executeFullBackup" 
                        :disabled="loading"
                        class="w-full px-6 py-3 text-base font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed rounded-lg transition-colors shadow-lg hover:shadow-xl">
                  <svg v-if="loading" class="animate-spin h-5 w-5 mr-2 inline" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  {{ loading ? '备份中...' : '立即执行完整备份' }}
                </button>
              </div>
            </div>
            
            <!-- 定时备份标签页 -->
            <div v-if="backupTab === 'scheduled'" class="space-y-6">
              <!-- 备份间隔设置 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">备份间隔设置</h4>
                <div class="space-y-3">
                  <!-- 自定义天数 -->
                  <div class="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-all cursor-pointer"
                       :class="{ 'border-blue-500 bg-blue-50': backupInterval === 'custom' }"
                       @click="backupInterval = 'custom'">
                    <div class="flex items-start space-x-3">
                      <input type="radio" :checked="backupInterval === 'custom'" class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">自定义间隔</h5>
                        <p class="text-xs text-gray-500 mt-1">设置自定义的备份间隔天数</p>
                        <div class="mt-3 flex items-center space-x-3">
                          <input v-model="customDays" type="number" min="1" max="365" placeholder="天数" 
                                 class="w-20 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                          <span class="text-sm text-gray-600">天</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 自定义执行时间 -->
                  <div class="border border-gray-200 rounded-lg p-4">
                    <div class="flex items-start space-x-3">
                      <input v-model="customTimeEnabled" type="checkbox" class="mt-1 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">自定义执行时间</h5>
                        <p class="text-xs text-gray-500 mt-1">设置具体的执行时间（时:分:秒）</p>
                        <div v-if="customTimeEnabled" class="mt-3 grid grid-cols-3 gap-2 sm:gap-3">
                          <div>
                            <label class="block text-xs text-gray-600 mb-1">小时</label>
                            <input v-model="customHour" type="number" min="0" max="23" 
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500">
                          </div>
                          <div>
                            <label class="block text-xs text-gray-600 mb-1">分钟</label>
                            <input v-model="customMinute" type="number" min="0" max="59" 
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500">
                          </div>
                          <div>
                            <label class="block text-xs text-gray-600 mb-1">秒</label>
                            <input v-model="customSecond" type="number" min="0" max="59" 
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500">
                          </div>
                        </div>
                        <div v-if="customTimeEnabled" class="mt-2 text-xs text-purple-600">
                          执行时间: {{ String(customHour).padStart(2, '0') }}:{{ String(customMinute).padStart(2, '0') }}:{{ String(customSecond).padStart(2, '0') }}
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 预设间隔选项 -->
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 sm:gap-3">
                    <div class="border border-gray-200 rounded-lg p-3 hover:border-green-300 hover:bg-green-50 transition-all cursor-pointer"
                         :class="{ 'border-green-500 bg-green-50': backupInterval === '1' }"
                         @click="backupInterval = '1'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '1'" class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每日备份</h5>
                          <p class="text-xs text-gray-500">每天凌晨2点执行</p>
                        </div>
                      </div>
                    </div>

                    <div class="border border-gray-200 rounded-lg p-3 hover:border-orange-300 hover:bg-orange-50 transition-all cursor-pointer"
                         :class="{ 'border-orange-500 bg-orange-50': backupInterval === '3' }"
                         @click="backupInterval = '3'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '3'" class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每3天备份</h5>
                          <p class="text-xs text-gray-500">每3天凌晨2点执行</p>
                        </div>
                      </div>
                    </div>

                    <div class="border border-gray-200 rounded-lg p-3 hover:border-purple-300 hover:bg-purple-50 transition-all cursor-pointer"
                         :class="{ 'border-purple-500 bg-purple-50': backupInterval === '7' }"
                         @click="backupInterval = '7'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '7'" class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每周备份</h5>
                          <p class="text-xs text-gray-500">每周日凌晨2点执行</p>
                        </div>
                      </div>
                    </div>

                    <div class="border border-gray-200 rounded-lg p-3 hover:border-red-300 hover:bg-red-50 transition-all cursor-pointer"
                         :class="{ 'border-red-500 bg-red-50': backupInterval === '30' }"
                         @click="backupInterval = '30'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '30'" class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每月备份</h5>
                          <p class="text-xs text-gray-500">每月1号凌晨2点执行</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 备份内容选择 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">备份内容</h4>
                <div class="space-y-2">
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input v-model="backupDatabase" type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <span class="text-sm text-gray-700">数据库备份 (MariaDB)</span>
                  </label>
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input v-model="backupConfig" type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <span class="text-sm text-gray-700">配置文件备份 (Postfix, Dovecot, Apache等)</span>
                  </label>
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input v-model="backupMaildir" type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <span class="text-sm text-gray-700">邮件目录备份 (/var/vmail)</span>
                  </label>
                </div>
              </div>

              <!-- 备份保留设置 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">备份保留设置</h4>
                <div class="flex items-center space-x-3">
                  <label class="text-sm text-gray-700">保留备份</label>
                  <input v-model="retentionDays" type="number" min="1" max="365" placeholder="7" 
                         class="w-20 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                  <span class="text-sm text-gray-600">天</span>
                </div>
                <p class="text-xs text-gray-500 mt-1">超过指定天数的备份文件将被自动删除</p>
              </div>
            </div>
          </div>
          
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm">
            <button @click="closeBackupManagementDialog" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
              关闭
            </button>
            <button v-if="backupTab === 'scheduled'"
                    @click="executeBackupSetup"
                    :disabled="!backupDatabase && !backupConfig && !backupMaildir"
                    class="px-4 py-2 text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 disabled:bg-gray-300 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-2">
              设置定时备份
            </button>
          </div>
        </div>
      </div>

      <!-- 定时备份对话框（保留以兼容旧代码，但不再使用） -->
      <div v-if="false && showBackupDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeBackupDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">设置定时备份</h3>
            <button @click="closeBackupDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <div class="space-y-6">
              <!-- 备份间隔设置 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">备份间隔设置</h4>
                <div class="space-y-3">
                  <!-- 自定义天数 -->
                  <div class="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-all cursor-pointer"
                       :class="{ 'border-blue-500 bg-blue-50': backupInterval === 'custom' }"
                       @click="backupInterval = 'custom'">
                    <div class="flex items-start space-x-3">
                      <input type="radio" :checked="backupInterval === 'custom'" class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">自定义间隔</h5>
                        <p class="text-xs text-gray-500 mt-1">设置自定义的备份间隔天数</p>
                        <div class="mt-3 flex items-center space-x-3">
                          <input v-model="customDays" type="number" min="1" max="365" placeholder="天数" 
                                 class="w-20 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                          <span class="text-sm text-gray-600">天</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 自定义执行时间 -->
                  <div class="border border-gray-200 rounded-lg p-4">
                    <div class="flex items-start space-x-3">
                      <input v-model="customTimeEnabled" type="checkbox" class="mt-1 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">自定义执行时间</h5>
                        <p class="text-xs text-gray-500 mt-1">设置具体的执行时间（时:分:秒）</p>
                        <div v-if="customTimeEnabled" class="mt-3 grid grid-cols-3 gap-2 sm:gap-3">
                          <div>
                            <label class="block text-xs text-gray-600 mb-1">小时</label>
                            <input v-model="customHour" type="number" min="0" max="23" 
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500">
                          </div>
                          <div>
                            <label class="block text-xs text-gray-600 mb-1">分钟</label>
                            <input v-model="customMinute" type="number" min="0" max="59" 
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500">
                          </div>
                          <div>
                            <label class="block text-xs text-gray-600 mb-1">秒</label>
                            <input v-model="customSecond" type="number" min="0" max="59" 
                                   class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500">
                          </div>
                        </div>
                        <div v-if="customTimeEnabled" class="mt-2 text-xs text-purple-600">
                          执行时间: {{ String(customHour).padStart(2, '0') }}:{{ String(customMinute).padStart(2, '0') }}:{{ String(customSecond).padStart(2, '0') }}
                        </div>
                      </div>
                    </div>
                  </div>

                  <!-- 预设间隔选项 -->
                  <div class="grid grid-cols-1 sm:grid-cols-2 gap-2 sm:gap-3">
                    <div class="border border-gray-200 rounded-lg p-3 hover:border-green-300 hover:bg-green-50 transition-all cursor-pointer"
                         :class="{ 'border-green-500 bg-green-50': backupInterval === '1' }"
                         @click="backupInterval = '1'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '1'" class="h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每日备份</h5>
                          <p class="text-xs text-gray-500">每天凌晨2点执行</p>
                        </div>
                      </div>
                    </div>

                    <div class="border border-gray-200 rounded-lg p-3 hover:border-orange-300 hover:bg-orange-50 transition-all cursor-pointer"
                         :class="{ 'border-orange-500 bg-orange-50': backupInterval === '3' }"
                         @click="backupInterval = '3'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '3'" class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每3天备份</h5>
                          <p class="text-xs text-gray-500">每3天凌晨2点执行</p>
                        </div>
                      </div>
                    </div>

                    <div class="border border-gray-200 rounded-lg p-3 hover:border-purple-300 hover:bg-purple-50 transition-all cursor-pointer"
                         :class="{ 'border-purple-500 bg-purple-50': backupInterval === '7' }"
                         @click="backupInterval = '7'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '7'" class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每周备份</h5>
                          <p class="text-xs text-gray-500">每周日凌晨2点执行</p>
                        </div>
                      </div>
                    </div>

                    <div class="border border-gray-200 rounded-lg p-3 hover:border-red-300 hover:bg-red-50 transition-all cursor-pointer"
                         :class="{ 'border-red-500 bg-red-50': backupInterval === '30' }"
                         @click="backupInterval = '30'">
                      <div class="flex items-center space-x-2">
                        <input type="radio" :checked="backupInterval === '30'" class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300">
                        <div>
                          <h5 class="text-sm font-medium text-gray-900">每月备份</h5>
                          <p class="text-xs text-gray-500">每月1号凌晨2点执行</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- 备份内容选择 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">备份内容</h4>
                <div class="space-y-2">
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input v-model="backupDatabase" type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <span class="text-sm text-gray-700">数据库备份 (MariaDB)</span>
                  </label>
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input v-model="backupConfig" type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <span class="text-sm text-gray-700">配置文件备份 (Postfix, Dovecot, Apache等)</span>
                  </label>
                  <label class="flex items-center space-x-3 cursor-pointer">
                    <input v-model="backupMaildir" type="checkbox" class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                    <span class="text-sm text-gray-700">邮件目录备份 (/var/vmail)</span>
                  </label>
                </div>
              </div>

              <!-- 备份保留设置 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">备份保留设置</h4>
                <div class="flex items-center space-x-3">
                  <label class="text-sm text-gray-700">保留备份</label>
                  <input v-model="retentionDays" type="number" min="1" max="365" placeholder="7" 
                         class="w-20 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                  <span class="text-sm text-gray-600">天</span>
                </div>
                <p class="text-xs text-gray-500 mt-1">超过指定天数的备份文件将被自动删除</p>
              </div>
            </div>
          </div>
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm">
            <button @click="closeBackupDialog" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
              取消
            </button>
            <button @click="executeBackupSetup"
                    :disabled="!backupDatabase && !backupConfig && !backupMaildir"
                    class="px-4 py-2 text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 disabled:bg-gray-300 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-2">
              设置定时备份
            </button>
          </div>
        </div>
      </div>

      <!-- 证书申请对话框 -->
      <div v-if="showCertDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeCertDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">申请SSL证书</h3>
            <button @click="closeCertDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <div class="space-y-6">
              <!-- 域名设置 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">域名</label>
                <input v-model="certDomain" type="text" placeholder="输入域名，如：example.com" 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
              </div>

              <!-- CA证书信息 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">CA根证书信息</h4>
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">国家代码</label>
                    <input v-model="caCountry" type="text" placeholder="CN" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">省份</label>
                    <input v-model="caState" type="text" placeholder="Beijing" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">城市</label>
                    <input v-model="caCity" type="text" placeholder="Beijing" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">组织</label>
                    <input v-model="caOrganization" type="text" placeholder="skills" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">组织单位</label>
                    <input v-model="caUnit" type="text" placeholder="system" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">通用名称</label>
                    <input v-model="caCommonName" type="text" placeholder="CA Server" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">邮箱</label>
                    <input v-model="caEmail" type="email" placeholder="ca@example.com" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">有效期（天）</label>
                    <input v-model="caValidity" type="number" min="3650" max="36500" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                    <p class="text-xs text-gray-500 mt-1">默认30年（10950天）</p>
                  </div>
                </div>
              </div>

              <!-- 服务器证书信息 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">服务器证书信息</h4>
                <div class="grid grid-cols-2 gap-4">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">国家代码</label>
                    <input v-model="certCountry" type="text" placeholder="CN" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">省份</label>
                    <input v-model="certState" type="text" placeholder="Beijing" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">城市</label>
                    <input v-model="certCity" type="text" placeholder="Beijing" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">组织</label>
                    <input v-model="certOrganization" type="text" placeholder="skills" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">组织单位</label>
                    <input v-model="certUnit" type="text" placeholder="system" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">通用名称</label>
                    <input v-model="certCommonName" type="text" placeholder="服务器域名或IP" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                    <p class="text-xs text-gray-500 mt-1">通常与域名相同</p>
                  </div>
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-2">邮箱</label>
                    <input v-model="certEmail" type="email" placeholder="admin@example.com" 
                           class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                  </div>
                </div>
              </div>

              <!-- 证书有效期 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">证书有效期（天）</label>
                <input v-model="certValidity" type="number" min="365" max="3650" 
                       class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                <p class="text-xs text-gray-500 mt-1">建议设置365-3650天（1-10年）</p>
              </div>

              <!-- 主题备用名称 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">主题备用名称（SAN）</label>
                <textarea v-model="certSAN" rows="3" placeholder="输入多个域名或IP，每行一个，如：&#10;*.example.com&#10;example.com&#10;192.168.1.100" 
                          class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"></textarea>
                <p class="text-xs text-gray-500 mt-1">支持通配符域名和IP地址，每行一个</p>
              </div>

              <!-- 证书说明 -->
              <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <h4 class="text-sm font-medium text-blue-900 mb-2">证书申请说明</h4>
                <div class="text-sm text-blue-800 space-y-1">
                  <p>• 系统将自动创建CA根证书（如果不存在）</p>
                  <p>• 生成服务器证书和私钥（自动添加服务器IP到证书）</p>
                  <p>• 配置Apache SSL虚拟主机（不自动跳转HTTP到HTTPS，需用户选择开启）</p>
                  <p>• 支持通过域名和IP地址访问HTTPS</p>
                  <p>• 更新系统证书信任库</p>
                  <p>• 自动配置DNS解析</p>
                </div>
              </div>

              <!-- 下载根证书 -->
              <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                <div class="flex items-center justify-between">
                  <div>
                    <h4 class="text-sm font-medium text-green-900 mb-1">CA根证书</h4>
                    <p class="text-xs text-green-700">下载并安装根证书以避免浏览器安全警告</p>
                  </div>
                  <button @click="downloadCACert"
                          class="px-4 py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 rounded-md transition-colors flex items-center space-x-2">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                    </svg>
                    <span>下载根证书</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm">
            <button @click="closeCertDialog" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
              取消
            </button>
            <button @click="executeCertRequest"
                    :disabled="!certDomain"
                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-2">
              申请证书
            </button>
          </div>
        </div>
      </div>

      <!-- 垃圾邮件过滤配置对话框 -->
      <div v-if="showSpamFilterDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeSpamFilterDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-6xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <!-- 通知消息 -->
          <div v-if="notice && showSpamFilterDialog" class="absolute top-4 right-4 z-50 max-w-md animate-slide-in-right">
            <div :class="{
              'bg-green-50 border-green-200 text-green-800': noticeType === 'success',
              'bg-red-50 border-red-200 text-red-800': noticeType === 'error',
              'bg-yellow-50 border-yellow-200 text-yellow-800': noticeType === 'warning',
              'bg-blue-50 border-blue-200 text-blue-800': noticeType === 'info'
            }" class="px-4 py-3 rounded-xl border-2 shadow-lg flex items-start space-x-3">
              <svg v-if="noticeType === 'success'" class="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <svg v-else-if="noticeType === 'error'" class="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <svg v-else-if="noticeType === 'warning'" class="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
              </svg>
              <svg v-else class="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <div class="flex-1">
                <p class="text-sm font-semibold whitespace-pre-line">{{ notice }}</p>
              </div>
              <button @click="notice = ''" class="text-gray-400 hover:text-gray-600 flex-shrink-0">
                <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
              </button>
            </div>
          </div>
          <!-- 头部 -->
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">垃圾邮件过滤配置</h3>
            <button @click="closeSpamFilterDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          
          <!-- 统计信息 -->
          <div class="px-4 sm:px-6 py-3 sm:py-4 bg-gray-50 border-b border-gray-200">
            <div class="grid grid-cols-3 gap-4">
              <div class="bg-white border border-gray-200 rounded-lg p-3">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-xs text-gray-500 mb-1">关键词总数</p>
                    <p class="text-xl font-semibold text-gray-900">{{ spamKeywords.length }}</p>
                  </div>
                  <div class="p-2 bg-orange-100 rounded-lg">
                    <svg class="h-5 w-5 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z"></path>
                    </svg>
                  </div>
                </div>
              </div>
              <div class="bg-white border border-gray-200 rounded-lg p-3">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-xs text-gray-500 mb-1">域名黑名单</p>
                    <p class="text-xl font-semibold text-gray-900">{{ spamDomains.length }}</p>
                  </div>
                  <div class="p-2 bg-red-100 rounded-lg">
                    <svg class="h-5 w-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                    </svg>
                  </div>
                </div>
              </div>
              <div class="bg-white border border-gray-200 rounded-lg p-3">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-xs text-gray-500 mb-1">过滤规则</p>
                    <p class="text-xl font-semibold text-gray-900">4</p>
                  </div>
                  <div class="p-2 bg-blue-100 rounded-lg">
                    <svg class="h-5 w-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                    </svg>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 内容区域 -->
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <div class="space-y-6">
              <!-- 关键词管理 -->
              <div>
                <div class="flex items-center justify-between mb-3">
                  <h4 class="text-sm font-medium text-gray-900">关键词管理</h4>
                  <div class="flex items-center space-x-2">
                    <span class="px-2 py-1 bg-orange-100 text-orange-700 rounded text-xs font-medium">
                      中文: {{ spamKeywords.filter(k => k.lang === 'cn').length }}
                    </span>
                    <span class="px-2 py-1 bg-amber-100 text-amber-700 rounded text-xs font-medium">
                      英文: {{ spamKeywords.filter(k => k.lang === 'en').length }}
                    </span>
                  </div>
                </div>
                <div class="border border-gray-200 rounded-lg p-4">
                  <!-- 添加关键词 -->
                  <div class="mb-6">
                    <div class="flex items-center space-x-3">
                      <div class="flex-1">
                        <input v-model="newSpamKeyword" type="text" 
                               placeholder="输入垃圾邮件关键词..." 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                               @keyup.enter="addSpamKeyword">
                      </div>
                      <select v-model="newSpamKeywordLang" class="px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                        <option value="cn">中文</option>
                        <option value="en">英文</option>
                      </select>
                      <button @click="addSpamKeyword" 
                              :disabled="!newSpamKeyword.trim()" 
                              class="px-4 py-2 text-sm font-medium text-white bg-orange-600 hover:bg-orange-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-md transition-colors">
                        添加
                      </button>
                    </div>
                  </div>
                  
                  <!-- 关键词列表 -->
                  <div v-if="spamKeywords.length > 0" class="space-y-2 max-h-64 overflow-y-auto mt-4">
                    <div v-for="(keyword, index) in spamKeywords" :key="index" 
                         class="group flex items-center justify-between p-3 border border-gray-200 rounded-md hover:bg-gray-50 transition-colors">
                      <div class="flex items-center space-x-3">
                        <div :class="keyword.lang === 'cn' ? 'bg-orange-100 text-orange-700' : 'bg-amber-100 text-amber-700'" 
                             class="px-2 py-1 rounded text-xs font-medium">
                          {{ keyword.lang === 'cn' ? '中文' : 'English' }}
                        </div>
                        <span class="text-sm text-gray-700">{{ keyword.text }}</span>
                      </div>
                      <button @click="removeSpamKeyword(index)" 
                              class="p-1 text-red-500 hover:text-red-700 hover:bg-red-50 rounded transition-colors">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                      </button>
                    </div>
                  </div>
                  <div v-else class="text-center py-8 text-gray-400 text-sm">
                    暂无关键词，请添加
                  </div>
                </div>
              </div>
              
              <!-- 域名黑名单管理 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">域名黑名单</h4>
                <div class="border border-gray-200 rounded-lg p-4">
                  <!-- 添加域名 -->
                  <div class="mb-4">
                    <div class="flex items-center space-x-3">
                      <div class="flex-1">
                        <input v-model="newSpamDomain" type="text" 
                               placeholder="输入域名，如：spam.com" 
                               class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                               @keyup.enter="addSpamDomain">
                      </div>
                      <button @click="addSpamDomain" 
                              :disabled="!newSpamDomain.trim()" 
                              class="px-4 py-2 text-sm font-medium text-white bg-red-600 hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-md transition-colors">
                        添加
                      </button>
                    </div>
                  </div>
                  
                  <!-- 域名列表 -->
                  <div v-if="spamDomains.length > 0" class="space-y-2 max-h-64 overflow-y-auto mt-4">
                    <div v-for="(domain, index) in spamDomains" :key="index" 
                         class="group flex items-center justify-between p-3 border border-gray-200 rounded-md hover:bg-gray-50 transition-colors">
                      <div class="flex items-center space-x-3">
                        <svg class="h-4 w-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"></path>
                        </svg>
                        <span class="text-sm text-gray-700">{{ domain }}</span>
                      </div>
                      <button @click="removeSpamDomain(index)" 
                              class="p-1 text-red-500 hover:text-red-700 hover:bg-red-50 rounded transition-colors">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                        </svg>
                      </button>
                    </div>
                  </div>
                  <div v-else class="text-center py-8 text-gray-400 text-sm">
                    暂无域名，请添加
                  </div>
                </div>
              </div>
              
              <!-- 过滤规则配置 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">过滤规则配置</h4>
                <div class="border border-gray-200 rounded-lg p-4">
                  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">最小邮件内容行数</label>
                      <input v-model.number="spamFilterConfig.minBodyLines" 
                             type="number" min="0" max="10" 
                             class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                      <p class="text-xs text-gray-500 mt-1">邮件内容少于此行数将被标记为可疑</p>
                    </div>
                    
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">大写字母比例阈值</label>
                      <input v-model.number="spamFilterConfig.maxCapsRatio" 
                             type="number" min="0" max="1" step="0.1" 
                             class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                      <p class="text-xs text-gray-500 mt-1">超过此比例的大写字母将被视为垃圾邮件特征</p>
                    </div>
                    
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">最大感叹号数量</label>
                      <input v-model.number="spamFilterConfig.maxExclamation" 
                             type="number" min="1" max="20" 
                             class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                      <p class="text-xs text-gray-500 mt-1">邮件中感叹号超过此数量将被标记</p>
                    </div>
                    
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-2">最大特殊字符数量</label>
                      <input v-model.number="spamFilterConfig.maxSpecialChars" 
                             type="number" min="1" max="50" 
                             class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                      <p class="text-xs text-gray-500 mt-1">特殊字符超过此数量将被视为垃圾邮件</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 底部操作栏 -->
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm">
            <button @click="closeSpamFilterDialog" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
              取消
            </button>
            <button @click="testSpamFilter" 
                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md transition-colors order-3 sm:order-2">
              测试过滤
            </button>
            <button @click="saveSpamFilterConfig" 
                    :disabled="spamFilterSaving" 
                    class="px-4 py-2 text-sm font-medium text-white bg-orange-600 hover:bg-orange-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-3">
              {{ spamFilterSaving ? '保存中...' : '保存配置' }}
            </button>
          </div>
        </div>
      </div>

      <!-- 广播对话框 -->
      <div v-if="showBroadcastDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeBroadcastDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <!-- 头部 -->
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">系统广播</h3>
            <button @click="closeBroadcastDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          
          <!-- 内容区域 -->
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <div class="space-y-6">
              <!-- 当前广播消息 -->
              <div v-if="currentBroadcast" class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
                <div class="flex items-start justify-between">
                  <div class="flex-1">
                    <p class="text-sm font-medium text-blue-800 mb-2">当前广播消息：</p>
                    <p class="text-sm text-gray-700 whitespace-pre-line">{{ currentBroadcast }}</p>
                  </div>
                  <button @click="showClearBroadcastConfirmDialog" class="ml-4 text-blue-600 hover:text-blue-800 transition-colors">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                    </svg>
                  </button>
                </div>
              </div>

              <!-- 输入区域 -->
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  广播消息内容
                </label>
                <textarea v-model="broadcastMessage" 
                          rows="6"
                          placeholder="请输入要广播的消息内容，此消息将显示在所有用户的邮件页面顶部..."
                          class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 resize-none"></textarea>
                <p class="mt-2 text-xs text-gray-500">消息将在所有用户的邮件页面顶部横向轮播显示</p>
              </div>
            </div>
          </div>
          
          <!-- 底部操作栏 -->
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm">
            <button @click="closeBroadcastDialog" 
                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
              取消
            </button>
            <button @click="saveBroadcast" 
                    :disabled="broadcastSaving || !broadcastMessage.trim()" 
                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-2">
              {{ broadcastSaving ? '保存中...' : '发布广播' }}
            </button>
          </div>
        </div>
      </div>

      <!-- 清除广播消息确认对话框 -->
      <div v-if="showClearBroadcastConfirm" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm transition-opacity" @click="showClearBroadcastConfirm = false"></div>
        <div class="relative bg-white rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-md transform transition-all duration-300 scale-100 animate-scale-in">
          <!-- 装饰性顶部渐变条 -->
          <div class="h-1 bg-gradient-to-r from-red-500 via-orange-500 to-yellow-500 rounded-t-2xl"></div>
          
          <!-- 内容区域 -->
          <div class="px-6 py-6">
            <!-- 图标和标题 -->
            <div class="flex items-center justify-center mb-4">
              <div class="flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-red-100 to-orange-100">
                <svg class="w-8 h-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
              </div>
            </div>
            
            <!-- 标题 -->
            <h3 class="text-xl font-semibold text-gray-900 text-center mb-2">
              确认清除广播消息
            </h3>
            
            <!-- 提示信息 -->
            <div class="bg-orange-50 border border-orange-200 rounded-lg p-4 mb-6">
              <div class="flex items-start space-x-3">
                <svg class="w-5 h-5 text-orange-500 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                </svg>
                <div class="flex-1">
                  <p class="text-sm font-medium text-orange-800 mb-1">
                    此操作将永久清除当前的广播消息
                  </p>
                  <p class="text-xs text-orange-700">
                    清除后，所有用户将不再看到此广播消息。此操作不可撤销。
                  </p>
                </div>
              </div>
            </div>
            
            <!-- 当前消息预览 -->
            <div v-if="currentBroadcast" class="bg-gray-50 border border-gray-200 rounded-lg p-3 mb-6">
              <p class="text-xs font-medium text-gray-500 mb-1">当前广播消息：</p>
              <p class="text-sm text-gray-700 line-clamp-3">{{ currentBroadcast }}</p>
            </div>
          </div>
          
          <!-- 底部按钮 -->
          <div class="px-4 sm:px-6 py-3 sm:py-4 bg-gray-50 rounded-b-xl sm:rounded-b-2xl flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
            <button 
              @click="showClearBroadcastConfirm = false" 
              class="px-5 py-2.5 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 transition-all duration-200 order-2 sm:order-1">
              取消
            </button>
            <button 
              @click="confirmClearBroadcast" 
              :disabled="broadcastSaving"
              class="px-5 py-2.5 text-sm font-medium text-white bg-gradient-to-r from-red-500 to-orange-500 hover:from-red-600 hover:to-orange-600 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2 rounded-lg shadow-md hover:shadow-lg transform hover:scale-105 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none order-1 sm:order-2">
              <span v-if="!broadcastSaving" class="flex items-center justify-center space-x-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
                <span>确认清除</span>
              </span>
              <span v-else class="flex items-center justify-center space-x-2">
                <svg class="animate-spin h-4 w-4" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                <span>清除中...</span>
              </span>
            </button>
          </div>
        </div>
      </div>

      <!-- 服务状态对话框 -->
      <div v-if="showServiceStatusDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeServiceStatusDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <div class="flex items-center space-x-2 sm:space-x-3">
              <h3 class="text-base sm:text-lg font-medium text-gray-900">系统服务状态</h3>
              <div class="flex items-center space-x-1 sm:space-x-2">
                <div class="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span class="text-xs text-gray-500 hidden sm:inline">实时更新</span>
              </div>
            </div>
            <button @click="closeServiceStatusDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <div v-if="serviceStatusLoading" class="flex items-center justify-center py-8">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
              <span class="ml-3 text-gray-600">正在检查服务状态...</span>
            </div>
            <div v-else class="space-y-6">
              <!-- 服务状态概览 -->
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <!-- 邮件服务状态 -->
                <div class="bg-gradient-to-br from-green-50 to-emerald-50 border border-green-200 rounded-lg p-4">
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="text-sm font-medium text-gray-900">邮件服务</h4>
                    <div class="flex items-center space-x-2">
                      <div :class="getServiceStatusClass(serviceStatuses.mail?.status)" class="w-2 h-2 rounded-full"></div>
                      <span class="text-xs text-gray-600">{{ getServiceStatusText(serviceStatuses.mail?.status) }}</span>
                    </div>
                  </div>
                  <div class="text-xs text-gray-600 space-y-1">
                    <div>Postfix: {{ getServiceStatusText(serviceStatuses.postfix?.status) }}</div>
                    <div>Dovecot: {{ getServiceStatusText(serviceStatuses.dovecot?.status) }}</div>
                  </div>
                </div>

                <!-- 数据库服务状态 -->
                <div class="bg-gradient-to-br from-blue-50 to-indigo-50 border border-blue-200 rounded-lg p-4">
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="text-sm font-medium text-gray-900">数据库服务</h4>
                    <div class="flex items-center space-x-2">
                      <div :class="getServiceStatusClass(serviceStatuses.mariadb?.status)" class="w-2 h-2 rounded-full"></div>
                      <span class="text-xs text-gray-600">{{ getServiceStatusText(serviceStatuses.mariadb?.status) }}</span>
                    </div>
                  </div>
                  <div class="text-xs text-gray-600">
                    MariaDB: {{ getServiceStatusText(serviceStatuses.mariadb?.status) }}
                  </div>
                </div>

                <!-- DNS服务状态 -->
                <div class="bg-gradient-to-br from-purple-50 to-violet-50 border border-purple-200 rounded-lg p-4">
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="text-sm font-medium text-gray-900">DNS服务</h4>
                    <div class="flex items-center space-x-2">
                      <div :class="getServiceStatusClass(serviceStatuses.named?.status)" class="w-2 h-2 rounded-full"></div>
                      <span class="text-xs text-gray-600">{{ getServiceStatusText(serviceStatuses.named?.status) }}</span>
                    </div>
                  </div>
                  <div class="text-xs text-gray-600">
                    Bind: {{ getServiceStatusText(serviceStatuses.named?.status) }}
                  </div>
                </div>

                <!-- 安全服务状态 -->
                <div class="bg-gradient-to-br from-orange-50 to-amber-50 border border-orange-200 rounded-lg p-4">
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="text-sm font-medium text-gray-900">安全服务</h4>
                    <div class="flex items-center space-x-2">
                      <div :class="getServiceStatusClass(serviceStatuses.firewalld?.status)" class="w-2 h-2 rounded-full"></div>
                      <span class="text-xs text-gray-600">{{ getServiceStatusText(serviceStatuses.firewalld?.status) }}</span>
                    </div>
                  </div>
                  <div class="text-xs text-gray-600 space-y-1">
                    <div>防火墙: {{ getServiceStatusText(serviceStatuses.firewalld?.status) }}</div>
                    <div>反垃圾邮件: {{ getServiceStatusText(serviceStatuses.rspamd?.status) }}</div>
                  </div>
                </div>

                <!-- 调度层服务状态 -->
                <div class="bg-gradient-to-br from-cyan-50 to-teal-50 border border-cyan-200 rounded-lg p-4">
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="text-sm font-medium text-gray-900">调度层服务</h4>
                    <div class="flex items-center space-x-2">
                      <div :class="getServiceStatusClass(serviceStatuses.dispatcher?.status)" class="w-2 h-2 rounded-full"></div>
                      <span class="text-xs text-gray-600">{{ getServiceStatusText(serviceStatuses.dispatcher?.status) }}</span>
                    </div>
                  </div>
                  <div class="text-xs text-gray-600">
                    API调度器: {{ getServiceStatusText(serviceStatuses.dispatcher?.status) }}
                  </div>
                </div>

                <!-- Web服务状态 -->
                <div class="bg-gradient-to-br from-pink-50 to-rose-50 border border-pink-200 rounded-lg p-4">
                  <div class="flex items-center justify-between mb-2">
                    <h4 class="text-sm font-medium text-gray-900">Web服务</h4>
                    <div class="flex items-center space-x-2">
                      <div :class="getServiceStatusClass(serviceStatuses.httpd?.status)" class="w-2 h-2 rounded-full"></div>
                      <span class="text-xs text-gray-600">{{ getServiceStatusText(serviceStatuses.httpd?.status) }}</span>
                    </div>
                  </div>
                  <div class="text-xs text-gray-600">
                    Apache: {{ getServiceStatusText(serviceStatuses.httpd?.status) }}
                  </div>
                </div>
              </div>

              <!-- 系统信息 -->
              <div class="bg-gray-50 rounded-lg p-4">
                <h4 class="text-sm font-medium text-gray-900 mb-3">系统信息</h4>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
                  <div>
                    <span class="text-gray-600">系统时间:</span>
                    <span class="ml-2 font-mono">{{ systemInfo.timestamp }}</span>
                  </div>
                  <div>
                    <span class="text-gray-600">系统负载:</span>
                    <span class="ml-2 font-mono">{{ systemInfo.loadAverage || 'N/A' }}</span>
                  </div>
                  <div>
                    <span class="text-gray-600">内存使用:</span>
                    <span class="ml-2 font-mono">{{ systemInfo.memoryUsage || 'N/A' }}</span>
                  </div>
                  <div>
                    <span class="text-gray-600">磁盘使用:</span>
                    <span class="ml-2 font-mono">{{ systemInfo.diskUsage || 'N/A' }}</span>
                  </div>
                </div>
              </div>

              <!-- 操作按钮 -->
              <div class="flex justify-end space-x-3">
                <button @click="refreshServiceStatus" 
                        :disabled="serviceStatusLoading"
                        class="px-4 py-2 text-sm font-medium text-blue-700 bg-blue-100 hover:bg-blue-200 disabled:opacity-50 disabled:cursor-not-allowed rounded-md transition-colors">
                  <svg class="w-4 h-4 inline mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                  </svg>
                  刷新状态
                </button>
                <button @click="closeServiceStatusDialog" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors">
                  关闭
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 用户管理卡片 -->
      <div class="bg-white/80 backdrop-blur-sm shadow-xl rounded-2xl mb-6 border border-white/20 animate-fade-in-up" style="animation-delay: 0.3s">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4 flex items-center">
            <svg class="w-5 h-5 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
            </svg>
            用户管理
          </h3>
          
          <!-- 用户列表 -->
          <div class="mb-6">
            <div class="flex items-center justify-between mb-4">
              <h4 class="text-md font-medium text-gray-700">数据库用户列表</h4>
              <div class="flex items-center gap-1.5 sm:gap-2 flex-wrap">
                <button @click="() => { userLogger.logButtonClick('批量创建用户', '用户管理'); openBatchCreateDialog() }" 
                        class="inline-flex items-center px-2 sm:px-3 py-1 sm:py-1.5 text-xs sm:text-sm font-medium text-purple-600 hover:text-purple-800 transition-all duration-200">
                  <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
                  </svg>
                  <span class="hidden sm:inline">批量创建</span>
                  <span class="sm:hidden">批量</span>
                </button>
                <button @click="() => { userLogger.logButtonClick('批量删除用户', '用户管理'); openBatchDeleteDialog() }" 
                        :disabled="selectedUsers.size === 0"
                        class="inline-flex items-center px-2 sm:px-3 py-1 sm:py-1.5 text-xs sm:text-sm font-medium text-red-600 hover:text-red-800 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed">
                  <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                  </svg>
                  <span class="hidden sm:inline">批量删除 ({{ selectedUsers.size }})</span>
                  <span class="sm:hidden">删除({{ selectedUsers.size }})</span>
                </button>
                <button @click="() => { userLogger.logButtonClick('刷新用户列表', '用户管理'); loadUsers() }" 
                        :disabled="loadingUsers"
                        class="inline-flex items-center px-2 sm:px-3 py-1 sm:py-1.5 text-xs sm:text-sm font-medium text-blue-600 hover:text-blue-800 transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed">
                  <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 mr-1" 
                       :class="{ 'animate-spin': loadingUsers }" 
                       fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                  </svg>
                  <span v-if="loadingUsers" class="hidden sm:inline">刷新中...</span>
                  <span v-else class="hidden sm:inline">刷新</span>
                  <span class="sm:hidden">刷新</span>
                </button>
              </div>
            </div>
            
            <!-- 用户表格 - 手机端使用卡片布局 -->
            <div class="bg-gray-50 rounded-lg overflow-hidden">
              <!-- 桌面端：表格布局 -->
              <div class="hidden md:block overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                  <thead class="bg-gray-100">
                    <tr>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">序号</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        <input type="checkbox" 
                               :checked="selectedUsers.size > 0 && selectedUsers.size === users.filter(u => u.username !== 'xm').length"
                               @change="toggleSelectAllUsers"
                               class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
                      </th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">用户名</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">邮箱</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">注册时间</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">类型</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">操作</th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <tr v-if="!users || users.length === 0">
                      <td colspan="7" class="px-4 py-8 text-center text-gray-500">
                        <div class="flex flex-col items-center">
                          <svg class="w-8 h-8 text-gray-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                          </svg>
                          暂无用户数据 ({{ users ? users.length : 0 }} 个用户)
                        </div>
                      </td>
                    </tr>
                    <tr v-for="(user, index) in (paginatedUsers || [])" :key="user.username" class="hover:bg-gray-50">
                      <td class="px-4 py-3 text-sm text-gray-500">{{ (currentPage - 1) * pageSize + index + 1 }}</td>
                      <td class="px-4 py-3 text-sm">
                        <input v-if="user.username !== 'xm'" 
                               type="checkbox" 
                               :checked="selectedUsers.has(user.id)"
                               @change="toggleUserSelection(user.id)"
                               class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
                        <span v-else class="text-gray-400 text-xs">-</span>
                      </td>
                      <td class="px-4 py-3 text-sm font-medium text-gray-900">{{ user.username }}</td>
                      <td class="px-4 py-3 text-sm text-gray-500">{{ user.email }}</td>
                      <td class="px-4 py-3 text-sm text-gray-500">{{ formatDate(user.created_at) }}</td>
                      <td class="px-4 py-3 text-sm">
                        <span v-if="user.username === 'xm'" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                          管理员
                        </span>
                        <span v-else class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          普通用户
                        </span>
                      </td>
                      <td class="px-4 py-3 text-sm">
                        <div class="flex items-center space-x-3">
                          <button v-if="user.username !== 'xm'" 
                                  @click="() => { userLogger.logButtonClick('修改用户', '用户管理'); openEditUserDialog(user) }" 
                                  class="text-blue-600 hover:text-blue-800 transition-colors duration-200" title="修改用户">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                            </svg>
                          </button>
                          <button v-if="user.username !== 'xm'" 
                                  @click="() => { userLogger.logButtonClick('删除用户', '用户管理'); showDeleteUserDialog(user.username, user.email) }" 
                                  class="text-red-600 hover:text-red-800 transition-colors duration-200" title="删除用户">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                            </svg>
                          </button>
                          <span v-if="user.username === 'xm'" class="text-gray-400 text-xs">受保护</span>
                        </div>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              
              <!-- 手机端：卡片布局 -->
              <div class="md:hidden space-y-3 p-3">
                <div v-if="!users || users.length === 0" class="text-center py-8 text-gray-500">
                  <div class="flex flex-col items-center">
                    <svg class="w-8 h-8 text-gray-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197m13.5-9a2.5 2.5 0 11-5 0 2.5 2.5 0 015 0z"></path>
                    </svg>
                    暂无用户数据 ({{ users ? users.length : 0 }} 个用户)
                  </div>
                </div>
                <div v-for="(user, index) in (paginatedUsers || [])" :key="user.username" 
                     class="bg-white rounded-lg p-4 shadow-sm border border-gray-200">
                  <div class="flex items-start justify-between mb-3">
                    <div class="flex-1">
                      <div class="flex items-center space-x-2 mb-2">
                        <input v-if="user.username !== 'xm'" 
                               type="checkbox" 
                               :checked="selectedUsers.has(user.id)"
                               @change="toggleUserSelection(user.id)"
                               class="h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
                        <span class="text-xs text-gray-500">#{{ (currentPage - 1) * pageSize + index + 1 }}</span>
                        <span v-if="user.username === 'xm'" class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800">
                          管理员
                        </span>
                        <span v-else class="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          普通用户
                        </span>
                      </div>
                      <h5 class="text-sm font-semibold text-gray-900 mb-1">{{ user.username }}</h5>
                      <p class="text-xs text-gray-600 mb-1">{{ user.email }}</p>
                      <p class="text-xs text-gray-500">{{ formatDate(user.created_at) }}</p>
                    </div>
                    <div class="flex items-center space-x-2 ml-2">
                      <button v-if="user.username !== 'xm'" 
                              @click="() => { userLogger.logButtonClick('修改用户', '用户管理'); openEditUserDialog(user) }" 
                              class="p-2 text-blue-600 hover:bg-blue-50 rounded-lg transition-colors" title="修改用户">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                        </svg>
                      </button>
                      <button v-if="user.username !== 'xm'" 
                              @click="() => { userLogger.logButtonClick('删除用户', '用户管理'); showDeleteUserDialog(user.username, user.email) }" 
                              class="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors" title="删除用户">
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                      </button>
                      <span v-if="user.username === 'xm'" class="text-xs text-gray-400">受保护</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 分页组件 -->
            <div v-if="users.length > 0" class="mt-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 sm:gap-0">
              <div class="flex items-center space-x-2">
                <span class="text-xs sm:text-sm text-gray-700">每页显示</span>
                <select v-model="pageSize" @change="changePageSize(pageSize)" 
                        class="px-2 py-1 text-xs sm:text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500">
                  <option value="5">5</option>
                  <option value="10">10</option>
                  <option value="15">15</option>
                  <option value="20">20</option>
                  <option value="25">25</option>
                  <option value="50">50</option>
                </select>
                <span class="text-xs sm:text-sm text-gray-700">条记录</span>
              </div>
              
              <div class="flex items-center space-x-2">
                <span class="text-xs sm:text-sm text-gray-700">
                  显示第 {{ paginationInfo.start }}-{{ paginationInfo.end }} 条，共 {{ paginationInfo.total }} 条
                </span>
              </div>
              
              <div v-if="totalPages > 1" class="flex items-center space-x-1">
                <button @click="goToPreviousPage" 
                        :disabled="!canGoPrevious"
                        class="px-2 sm:px-3 py-1 text-xs sm:text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                  上一页
                </button>
                
                <!-- 页码按钮 -->
                <template v-for="page in Math.min(5, totalPages)" :key="page">
                  <button v-if="page <= totalPages" 
                          @click="goToPage(page)"
                          :class="[
                            'px-2 sm:px-3 py-1 text-xs sm:text-sm font-medium rounded-md',
                            page === currentPage 
                              ? 'bg-blue-600 text-white' 
                              : 'text-gray-700 bg-white border border-gray-300 hover:bg-gray-50'
                          ]">
                    {{ page }}
                  </button>
                </template>
                
                <button v-if="totalPages > 5" 
                        class="px-2 sm:px-3 py-1 text-xs sm:text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md">
                  ...
                </button>
                
                <button v-if="totalPages > 5" 
                        @click="goToPage(totalPages)"
                        :class="[
                          'px-2 sm:px-3 py-1 text-xs sm:text-sm font-medium rounded-md',
                          totalPages === currentPage 
                            ? 'bg-blue-600 text-white' 
                            : 'text-gray-700 bg-white border border-gray-300 hover:bg-gray-50'
                        ]">
                  {{ totalPages }}
                </button>
                
                <button @click="goToNextPage" 
                        :disabled="!canGoNext"
                        class="px-2 sm:px-3 py-1 text-xs sm:text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-md hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed">
                  下一页
                </button>
              </div>
              
              <!-- 当只有一页时显示提示 -->
              <div v-else class="flex items-center">
                <span class="text-xs sm:text-sm text-gray-500">所有用户已显示</span>
              </div>
            </div>
          </div>
          
          <!-- 添加用户表单 -->
          <div class="space-y-4 mt-6 sm:mt-8">
            <h4 class="text-base sm:text-md font-medium text-gray-700">添加新用户</h4>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-3 sm:gap-4">
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">用户名</label>
                <input v-model="username" placeholder="请输入用户名" 
                       class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200" />
              </div>
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">邮箱地址</label>
                <input v-model="email" placeholder="user@example.com" 
                       class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200" />
              </div>
              <div>
                <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1 sm:mb-2">密码</label>
                <input v-model="password" 
                       type="password" 
                       placeholder="请输入密码" 
                       @input="validatePassword"
                       class="w-full px-3 py-2 text-sm border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 transition-all duration-200" />
                <p v-if="passwordHint" class="text-xs text-gray-500 mt-1">{{ passwordHint }}</p>
                <p v-if="passwordError" class="text-xs text-red-600 mt-1">{{ passwordError }}</p>
              </div>
            </div>
            <div v-if="addUserError" class="mb-3 p-3 bg-red-50 border border-red-200 rounded-md">
              <div class="flex items-start">
                <svg class="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <p class="text-sm text-red-800">{{ addUserError }}</p>
              </div>
            </div>
            <div v-if="addUserSuccess" class="mb-3 p-3 bg-green-50 border border-green-200 rounded-md">
              <div class="flex items-start">
                <svg class="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <p class="text-sm text-green-800">{{ addUserSuccess }}</p>
              </div>
            </div>
            <div class="flex justify-end">
              <button @click="() => { userLogger.logButtonClick('添加用户', '用户管理'); addUser() }" 
                      class="group inline-flex items-center px-3 sm:px-4 py-2 border border-transparent text-xs sm:text-sm font-medium rounded-lg sm:rounded-xl text-white bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-all duration-300 transform hover:scale-105 hover:shadow-lg">
                <svg class="h-3 w-3 sm:h-4 sm:w-4 mr-1 sm:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"></path>
                </svg>
                添加用户
              </button>
            </div>
          </div>
          
          <!-- 邮件发送统计图表 -->
          <div class="mt-6 sm:mt-8 grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
            <!-- 图表一：邮件发送趋势 -->
            <div class="bg-white rounded-lg sm:rounded-xl shadow-lg border border-gray-200 p-4 sm:p-6">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 sm:gap-0 mb-4">
                <h4 class="text-base sm:text-lg font-semibold text-gray-800 flex items-center">
                  <svg class="w-4 h-4 sm:w-5 sm:h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                  </svg>
                  邮件发送趋势
                </h4>
                <div class="flex items-center space-x-1 sm:space-x-2">
                  <button
                    v-for="period in ['hour', 'day', 'week']"
                    :key="period"
                    @click="trendPeriod = period; loadSendingTrends()"
                    :class="[
                      'px-2 sm:px-3 py-1 text-xs sm:text-sm rounded-lg transition-colors',
                      trendPeriod === period
                        ? 'bg-blue-600 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    ]"
                  >
                    {{ period === 'hour' ? '小时' : period === 'day' ? '天' : '周' }}
                  </button>
                </div>
              </div>
              <div class="relative h-48 sm:h-64">
                <canvas ref="trendChartRef"></canvas>
                <div v-if="loadingTrends" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75 z-10">
                  <div class="text-gray-500 flex items-center">
                    <svg class="animate-spin h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    加载中...
                  </div>
                </div>
                <div v-if="!loadingTrends && trendDataEmpty" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-90 z-10">
                  <div class="text-center text-gray-400">
                    <svg class="w-12 h-12 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"></path>
                    </svg>
                    <p class="text-sm">暂无数据</p>
                    <p class="text-xs mt-1">图表将每30秒自动刷新</p>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 图表二：发送频率 vs 发送数量关系 -->
            <div class="bg-white rounded-lg sm:rounded-xl shadow-lg border border-gray-200 p-4 sm:p-6">
              <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 sm:gap-0 mb-4">
                <h4 class="text-base sm:text-lg font-semibold text-gray-800 flex items-center">
                  <svg class="w-4 h-4 sm:w-5 sm:h-5 mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z"></path>
                  </svg>
                  发送频率分析
                </h4>
                <div class="flex items-center space-x-1 sm:space-x-2">
                  <button
                    v-for="groupBy in ['user', 'day']"
                    :key="groupBy"
                    @click="frequencyGroupBy = groupBy; loadFrequencyAnalysis()"
                    :class="[
                      'px-2 sm:px-3 py-1 text-xs sm:text-sm rounded-lg transition-colors',
                      frequencyGroupBy === groupBy
                        ? 'bg-purple-600 text-white'
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    ]"
                  >
                    {{ groupBy === 'user' ? '按用户' : '按天' }}
                  </button>
                </div>
              </div>
              <div class="relative h-48 sm:h-64">
                <canvas ref="frequencyChartRef"></canvas>
                <div v-if="loadingFrequency" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-75 z-10">
                  <div class="text-gray-500 flex items-center">
                    <svg class="animate-spin h-5 w-5 mr-2" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    加载中...
                  </div>
                </div>
                <div v-if="!loadingFrequency && frequencyDataEmpty" class="absolute inset-0 flex items-center justify-center bg-white bg-opacity-90 z-10">
                  <div class="text-center text-gray-400">
                    <svg class="w-12 h-12 mx-auto mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z"></path>
                    </svg>
                    <p class="text-sm">暂无数据</p>
                    <p class="text-xs mt-1">图表将每30秒自动刷新</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 状态显示 -->
      <div v-if="loading || error || opId" class="bg-white shadow rounded-lg mb-6">
        <div class="px-4 py-5 sm:p-6">
          <div v-if="loading" class="flex items-center">
            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-blue-600" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span class="text-blue-600 font-medium">正在执行操作...</span>
          </div>
          
          <div v-if="error" class="bg-red-50 border border-red-200 rounded-md p-4">
            <div class="flex">
              <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-red-800">操作失败</h3>
                <div class="mt-2 text-sm text-red-700">{{ error }}</div>
              </div>
            </div>
          </div>
          
          <div v-if="opId" class="mt-4 animate-fade-in-up">
            <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4 flex items-center gap-3">
              <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <span>操作日志 ({{ opId }})</span>
              <span v-if="status==='running'" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 animate-pulse">
                <div class="w-2 h-2 bg-yellow-500 rounded-full mr-2 animate-ping"></div>
                进行中
              </span>
              <span v-else-if="status==='success'" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
                成功
              </span>
              <span v-else-if="status==='failed'" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-red-100 text-red-800">
                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path>
                </svg>
                失败
              </span>
            </h3>
            <div class="bg-gray-900/90 backdrop-blur-sm rounded-xl p-4 overflow-auto max-h-96 border border-gray-700/50 shadow-2xl">
              <pre class="text-green-400 text-sm whitespace-pre-wrap font-mono">{{ logs }}</pre>
            </div>
          </div>
        </div>
      </div>

      <!-- 操作日志对话框 -->
      <div v-if="showOperationLog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="showOperationLog = false"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-lg font-medium text-gray-900 flex items-center gap-3">
              <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
              </svg>
              <span>操作日志</span>
              <span v-if="loading" class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800 animate-pulse">
                <div class="w-2 h-2 bg-yellow-500 rounded-full mr-2 animate-ping"></div>
                进行中
              </span>
              <span v-else class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"></path>
                </svg>
                完成
              </span>
            </h3>
            <button @click="showOperationLog = false" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5 max-h-96 overflow-auto">
            <div class="bg-gray-900/90 backdrop-blur-sm rounded-xl p-4 border border-gray-700/50 shadow-2xl">
              <pre class="text-green-400 text-sm whitespace-pre-wrap font-mono">{{ logs }}</pre>
            </div>
          </div>
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex justify-end">
            <button @click="showOperationLog = false" class="px-4 py-2 text-sm rounded-md text-white bg-blue-600 hover:bg-blue-700 transition-colors">
              关闭
            </button>
          </div>
        </div>
      </div>

      <!-- 环境检查对话框 -->
      <div v-if="showEnvironmentCheckDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeEnvironmentCheckDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">系统环境检查</h3>
            <button @click="closeEnvironmentCheckDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <p class="text-sm text-gray-600 mb-6">系统将执行环境检查和健康检查，确保所有服务正常运行。</p>
            
            <!-- 操作状态显示 -->
            <div v-if="loading" class="mb-6">
              <div class="flex items-center space-x-3 mb-4">
                <div class="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
                <span class="text-sm font-medium text-gray-700">正在执行检查...</span>
              </div>
            </div>

            <!-- 成功信息 -->
            <div v-if="status === 'success' && !loading" class="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
              <div class="flex items-center">
                <svg class="h-5 w-5 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span class="text-sm text-green-700">环境检查完成！系统状态良好</span>
              </div>
            </div>

            <!-- 错误信息 -->
            <div v-if="error" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
              <div class="flex items-center">
                <svg class="h-5 w-5 text-red-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span class="text-sm text-red-700">{{ error }}</span>
              </div>
            </div>

            <!-- 日志显示区域 -->
            <div v-if="logs" class="mb-6">
              <h4 class="text-sm font-medium text-gray-700 mb-2">检查日志：</h4>
              <div class="bg-gray-900 text-green-400 p-4 rounded-lg font-mono text-sm max-h-64 overflow-y-auto whitespace-pre-wrap">{{ logs }}</div>
            </div>

            <!-- 操作按钮 -->
            <div class="flex justify-end space-x-3">
              <button @click="closeEnvironmentCheckDialog" 
                      class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors">
                关闭
              </button>
              <button @click="callEnvironmentCheck" 
                      :disabled="loading"
                      class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-lg transition-colors">
                {{ loading ? '检查中...' : (status === 'success' ? '重新检查' : '开始检查') }}
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 安装服务对话框 -->
      <div v-if="showInstallDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeInstallDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">选择要安装的服务</h3>
            <button @click="closeInstallDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <p class="text-sm text-gray-600 mb-6">请选择您要安装的服务组件，系统将自动安装和配置选中的服务。</p>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <!-- 邮件服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-all cursor-pointer" 
                   :class="{ 'border-blue-500 bg-blue-50': selectedServices.includes('mail') }"
                   @click="toggleService('mail')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedServices.includes('mail')" class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">邮件服务</h4>
                    <p class="text-xs text-gray-500 mt-1">Postfix + Dovecot 邮件服务器</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• SMTP 邮件发送</li>
                      <li>• IMAP/POP3 邮件接收</li>
                      <li>• 虚拟用户支持</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- 数据库服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-green-300 hover:bg-green-50 transition-all cursor-pointer" 
                   :class="{ 'border-green-500 bg-green-50': selectedServices.includes('database') }"
                   @click="toggleService('database')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedServices.includes('database')" class="mt-1 h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">数据库服务</h4>
                    <p class="text-xs text-gray-500 mt-1">MariaDB 数据库服务器</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• 用户账户管理</li>
                      <li>• 域名管理</li>
                      <li>• 邮件路由配置</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- DNS服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-purple-300 hover:bg-purple-50 transition-all cursor-pointer" 
                   :class="{ 'border-purple-500 bg-purple-50': selectedServices.includes('dns') }"
                   @click="toggleService('dns')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedServices.includes('dns')" class="mt-1 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">DNS服务</h4>
                    <p class="text-xs text-gray-500 mt-1">Bind DNS 服务器</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• 域名解析</li>
                      <li>• MX 记录</li>
                      <li>• 邮件记录配置</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- 安全服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-red-300 hover:bg-red-50 transition-all cursor-pointer" 
                   :class="{ 'border-red-500 bg-red-50': selectedServices.includes('security') }"
                   @click="toggleService('security')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedServices.includes('security')" class="mt-1 h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">安全服务</h4>
                    <p class="text-xs text-gray-500 mt-1">SSL证书 + 防火墙</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• SSL/TLS 加密</li>
                      <li>• 防火墙配置</li>
                      <li>• 安全策略</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-6 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm pt-4 border-t border-gray-200">
              <button @click="closeInstallDialog" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
                取消
              </button>
              <button @click="executeInstall" 
                      :disabled="selectedServices.length === 0"
                      class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-2">
                开始安装 ({{ selectedServices.length }} 个服务)
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 服务管理对话框 -->
      <div v-if="showServiceManagementDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeServiceManagementDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">服务管理</h3>
            <button @click="closeServiceManagementDialog" class="text-gray-400 hover:text-gray-600 transition-colors">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <!-- 操作类型选择 -->
            <div class="mb-6">
              <h4 class="text-sm font-medium text-gray-900 mb-3">选择操作类型</h4>
              <div class="grid grid-cols-2 gap-4">
                <button @click="serviceAction = 'restart'" 
                        :class="serviceAction === 'restart' ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'"
                        class="px-4 py-2 rounded-lg transition-colors">
                  <div class="flex items-center space-x-2">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
                    </svg>
                    <span>重启服务</span>
                  </div>
                </button>
                <button @click="serviceAction = 'stop'" 
                        :class="serviceAction === 'stop' ? 'bg-red-500 text-white' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'"
                        class="px-4 py-2 rounded-lg transition-colors">
                  <div class="flex items-center space-x-2">
                    <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z"></path>
                    </svg>
                    <span>关闭服务</span>
                  </div>
                </button>
              </div>
            </div>

            <!-- 服务选择 -->
            <div class="space-y-4">
              <h4 class="text-sm font-medium text-gray-900">选择要{{ serviceAction === 'restart' ? '重启' : '关闭' }}的服务</h4>
              
              <!-- 邮件服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-all cursor-pointer" 
                   :class="{ 'border-blue-500 bg-blue-50': selectedRestartServices.includes('mail') }"
                   @click="toggleRestartService('mail')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedRestartServices.includes('mail')" class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">邮件服务</h4>
                    <p class="text-xs text-gray-500 mt-1">Postfix + Dovecot</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• SMTP 服务</li>
                      <li>• IMAP/POP3 服务</li>
                      <li>• 邮件传输</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- 数据库服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-green-300 hover:bg-green-50 transition-all cursor-pointer" 
                   :class="{ 'border-green-500 bg-green-50': selectedRestartServices.includes('database') }"
                   @click="toggleRestartService('database')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedRestartServices.includes('database')" class="mt-1 h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">数据库服务</h4>
                    <p class="text-xs text-gray-500 mt-1">MariaDB</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• 用户数据存储</li>
                      <li>• 邮件配置</li>
                      <li>• 系统数据</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- DNS服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-purple-300 hover:bg-purple-50 transition-all cursor-pointer" 
                   :class="{ 'border-purple-500 bg-purple-50': selectedRestartServices.includes('dns') }"
                   @click="toggleRestartService('dns')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedRestartServices.includes('dns')" class="mt-1 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">DNS服务</h4>
                    <p class="text-xs text-gray-500 mt-1">Bind DNS</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• 域名解析</li>
                      <li>• MX记录</li>
                      <li>• 反向解析</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- 安全服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-red-300 hover:bg-red-50 transition-all cursor-pointer" 
                   :class="{ 'border-red-500 bg-red-50': selectedRestartServices.includes('security') }"
                   @click="toggleRestartService('security')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedRestartServices.includes('security')" class="mt-1 h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">安全服务</h4>
                    <p class="text-xs text-gray-500 mt-1">SSL证书 + 防火墙</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• SSL/TLS 加密</li>
                      <li>• 防火墙配置</li>
                      <li>• 安全策略</li>
                    </ul>
                  </div>
                </div>
              </div>

              <!-- 调度层服务 -->
              <div class="border border-gray-200 rounded-lg p-4 hover:border-indigo-300 hover:bg-indigo-50 transition-all cursor-pointer" 
                   :class="{ 'border-indigo-500 bg-indigo-50': selectedRestartServices.includes('dispatcher') }"
                   @click="toggleRestartService('dispatcher')">
                <div class="flex items-start space-x-3">
                  <input type="checkbox" :checked="selectedRestartServices.includes('dispatcher')" class="mt-1 h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded">
                  <div class="flex-1">
                    <h4 class="text-sm font-medium text-gray-900">调度层服务</h4>
                    <p class="text-xs text-gray-500 mt-1">API 调度器</p>
                    <ul class="text-xs text-gray-600 mt-2 space-y-1">
                      <li>• API 接口</li>
                      <li>• 脚本调度</li>
                      <li>• 系统管理</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-6 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm pt-4 border-t border-gray-200">
              <button @click="closeServiceManagementDialog" class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors order-2 sm:order-1">
                取消
              </button>
              <button @click="executeServiceAction" 
                      :disabled="selectedRestartServices.length === 0"
                      :class="serviceAction === 'restart' ? 'bg-orange-600 hover:bg-orange-700' : 'bg-red-600 hover:bg-red-700'"
                      class="px-4 py-2 text-sm font-medium text-white disabled:bg-gray-300 disabled:cursor-not-allowed rounded-md transition-colors order-1 sm:order-2">
                {{ serviceAction === 'restart' ? '开始重启' : '开始关闭' }} ({{ selectedRestartServices.length }} 个服务)
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- 配置服务对话框（域名设置向导） -->
      <div v-if="showConfigDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
        <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeConfigDialog"></div>
        <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto border border-white/20 animate-scale-in">
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
            <h3 class="text-base sm:text-lg font-medium text-gray-900">配置服务</h3>
            <button class="text-gray-400 hover:text-gray-600" @click="closeConfigDialog" aria-label="关闭">
              <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
            </button>
          </div>
          <div class="px-4 sm:px-6 py-4 sm:py-5">
            <div v-if="configStep===1" class="space-y-6">
              <!-- 配置类型选择 -->
              <div>
                <h4 class="text-sm font-medium text-gray-900 mb-3">选择配置类型</h4>
                <div class="space-y-3">
                  <!-- 系统基本信息配置 -->
                  <div class="border border-gray-200 rounded-lg p-4 hover:border-green-300 hover:bg-green-50 transition-all cursor-pointer" 
                       :class="{ 'border-green-500 bg-green-50': configType === 'system' }"
                       @click="configType = 'system'">
                    <div class="flex items-start space-x-3">
                      <input type="radio" :checked="configType === 'system'" class="mt-1 h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">系统基本信息</h5>
                        <p class="text-xs text-gray-500 mt-1">配置系统名称和管理员邮箱</p>
                        <ul class="text-xs text-gray-600 mt-2 space-y-1">
                          <li>• 修改系统名称</li>
                          <li>• 设置管理员邮箱</li>
                          <li>• 系统参数配置</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                  
                  <!-- DNS配置选项 -->
                  <div class="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-all cursor-pointer" 
                       :class="{ 'border-blue-500 bg-blue-50': configType === 'dns' }"
                       @click="configType = 'dns'">
                    <div class="flex items-start space-x-3">
                      <input type="radio" :checked="configType === 'dns'" class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">DNS解析配置</h5>
                        <p class="text-xs text-gray-500 mt-1">配置DNS解析方式和域名设置</p>
                        <ul class="text-xs text-gray-600 mt-2 space-y-1">
                          <li>• 本地DNS (Bind) 配置</li>
                          <li>• 域名解析设置</li>
                          <li>• DNS健康检查</li>
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              
              <!-- 系统基本信息配置 -->
              <div v-if="configType === 'system'" class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">系统名称</label>
                  <input v-model="systemName" type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent" placeholder="请输入系统名称">
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">管理员邮箱</label>
                  <input v-model="adminEmail" type="email" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent" placeholder="请输入管理员邮箱">
                  <p class="text-xs text-gray-500 mt-1">管理员邮箱用于系统通知和DNS配置</p>
                </div>
              </div>
              
              <!-- DNS配置选项 -->
              <div v-if="configType === 'dns'">
                <h4 class="text-sm font-medium text-gray-900 mb-3">选择DNS解析方式</h4>
                <div class="space-y-3">
                  <!-- 本地DNS选项 -->
                  <div class="border border-gray-200 rounded-lg p-4 hover:border-blue-300 hover:bg-blue-50 transition-all cursor-pointer" 
                       :class="{ 'border-blue-500 bg-blue-50': dnsType === 'bind' }"
                       @click="dnsType = 'bind'">
                    <div class="flex items-start space-x-3">
                      <input type="radio" :checked="dnsType === 'bind'" class="mt-1 h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">本地DNS (Bind)</h5>
                        <p class="text-xs text-gray-500 mt-1">使用本机Bind DNS服务器进行域名解析</p>
                        <ul class="text-xs text-gray-600 mt-2 space-y-1">
                          <li>• 自动安装和配置Bind DNS</li>
                          <li>• 配置MX、A、PTR记录</li>
                          <li>• 支持SPF、DKIM、DMARC记录</li>
                          <li>• 完全自主控制DNS解析</li>
                        </ul>
                      </div>
                    </div>
                  </div>

                  <!-- 公网DNS选项 -->
                  <div class="border border-gray-200 rounded-lg p-4 hover:border-green-300 hover:bg-green-50 transition-all cursor-pointer" 
                       :class="{ 'border-green-500 bg-green-50': dnsType === 'public' }"
                       @click="dnsType = 'public'">
                    <div class="flex items-start space-x-3">
                      <input type="radio" :checked="dnsType === 'public'" class="mt-1 h-4 w-4 text-green-600 focus:ring-green-500 border-gray-300">
                      <div class="flex-1">
                        <h5 class="text-sm font-medium text-gray-900">公网DNS</h5>
                        <p class="text-xs text-gray-500 mt-1">获取公网域名并配置Apache虚拟主机</p>
                        <ul class="text-xs text-gray-600 mt-2 space-y-1">
                          <li>• 获取公网域名信息</li>
                          <li>• 自动配置Apache HTTP虚拟主机（不自动配置HTTPS）</li>
                          <li>• 更新系统DNS设置</li>
                          <li>• 支持HTTP访问（HTTPS需上传证书后配置）</li>
                        </ul>
                      </div>
                    </div>
                  </div>

                </div>
              </div>

              <!-- 域名输入 - 仅在DNS配置时显示 -->
              <div v-if="configType === 'dns'">
                <label class="block text-sm font-medium text-gray-700 mb-2">邮件域名</label>
                <p v-if="dnsType === 'bind'" class="text-sm text-gray-600 mb-3">请输入需要配置的邮件域名，例如：example.com。系统将把该域名应用到 Postfix 配置，并在数据库中确保该域存在。</p>
                <p v-else-if="dnsType === 'public'" class="text-sm text-gray-600 mb-3">请输入您的公网域名，例如：example.com。系统将获取该域名信息并配置Apache虚拟主机。</p>
                <input v-model="configDomain" placeholder="example.com" class="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-primary-500 focus:border-primary-500" />
              </div>
            </div>
            <div v-else-if="configStep===2" class="space-y-4">
              <!-- 本地DNS配置确认 -->
              <div v-if="dnsType === 'bind'">
                <p class="text-sm text-gray-700">请确认以下配置：</p>
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 space-y-3">
                  <div class="flex items-center justify-between">
                    <span class="text-sm text-gray-600">域名：</span>
                    <span class="font-medium text-gray-900">{{ configDomain }}</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <span class="text-sm text-gray-600">DNS解析方式：</span>
                    <span class="font-medium text-blue-900">本地DNS (Bind)</span>
                  </div>
                  <div class="text-xs text-blue-700">
                    <p>• 将自动安装和配置Bind DNS服务器</p>
                    <p>• 配置MX、A、PTR、SPF、DKIM、DMARC记录</p>
                    <p>• 自动配置系统DNS指向本地服务器</p>
                    <p>• 执行DNS解析测试验证配置</p>
                  </div>
                </div>
              </div>

              <!-- 公网DNS配置确认 -->
              <div v-else-if="dnsType === 'public'">
                <p class="text-sm text-gray-700">请确认以下配置：</p>
                <div class="bg-green-50 border border-green-200 rounded-lg p-4 space-y-3">
                  <div class="flex items-center justify-between">
                    <span class="text-sm text-gray-600">域名：</span>
                    <span class="font-medium text-gray-900">{{ configDomain }}</span>
                  </div>
                  <div class="flex items-center justify-between">
                    <span class="text-sm text-gray-600">DNS解析方式：</span>
                    <span class="font-medium text-green-900">公网DNS</span>
                  </div>
                  <div class="text-xs text-green-700">
                    <p>• 获取公网域名信息</p>
                    <p>• 自动配置Apache HTTP虚拟主机（不自动配置HTTPS）</p>
                    <p>• 更新系统DNS设置</p>
                    <p>• 支持HTTP访问（HTTPS需上传证书后配置）</p>
                  </div>
                </div>
              </div>


            </div>
            <div v-else-if="configStep===3" class="space-y-3">
              <p class="text-sm text-gray-700">正在执行配置，请稍候...</p>
            </div>
          </div>
          <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row items-center justify-between space-y-2 sm:space-y-0 sticky bottom-0 bg-white/95 backdrop-blur-sm">
            <div class="text-xs text-gray-500 order-2 sm:order-1">步骤 {{ configStep }} / 3</div>
            <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2 order-1 sm:order-2 w-full sm:w-auto">
              <button class="px-4 py-2 text-sm rounded-md border border-gray-300 text-gray-700 bg-white hover:bg-gray-50" @click="closeConfigDialog" :disabled="configStep===3">取消</button>
              <button v-if="configStep===1 && configType==='system'" class="px-4 py-2 text-sm rounded-md text-white bg-green-600 hover:bg-green-700 disabled:opacity-50" @click="executeConfigure" :disabled="!systemName.trim() || !adminEmail.trim()">配置系统信息</button>
              <button v-else-if="configStep===1 && configType==='dns'" class="px-4 py-2 text-sm rounded-md text-white bg-primary-600 hover:bg-primary-700 disabled:opacity-50" @click="proceedConfigNext" :disabled="!configDomain">下一步</button>
              <button v-else-if="configStep===2" class="px-4 py-2 text-sm rounded-md text-white bg-purple-600 hover:bg-purple-700" @click="executeConfigure">执行配置</button>
              <button v-else-if="configStep===3" class="px-4 py-2 text-sm rounded-md text-white bg-gray-400 cursor-not-allowed" disabled>进行中...</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 批量创建用户对话框 -->
    <div v-if="showBatchCreateDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="closeBatchCreateDialog">
      <div class="bg-white rounded-2xl shadow-2xl w-full max-w-2xl max-h-[90vh] overflow-y-auto mx-4" @click.stop>
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-base sm:text-lg font-medium text-gray-900">批量创建用户</h3>
          <button class="text-gray-400 hover:text-gray-600" @click="closeBatchCreateDialog" aria-label="关闭">
            <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </div>
        
        <div class="px-4 sm:px-6 py-4 sm:py-5">
          <!-- 创建方式选择 -->
          <div class="mb-6">
            <h4 class="text-sm font-medium text-gray-900 mb-3">选择创建方式</h4>
            <div class="space-y-3">
              <div class="border border-gray-200 rounded-lg p-4 hover:border-purple-300 hover:bg-purple-50 transition-all cursor-pointer" 
                   :class="{ 'border-purple-500 bg-purple-50': batchCreateMode === 'list' }"
                   @click="batchCreateMode = 'list'">
                <div class="flex items-start space-x-3">
                  <input type="radio" :checked="batchCreateMode === 'list'" class="mt-1 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                  <div class="flex-1">
                    <h5 class="text-sm font-medium text-gray-900">用户名列表</h5>
                    <p class="text-xs text-gray-500 mt-1">用逗号分割多个用户名</p>
                    <p class="text-xs text-gray-600 mt-1">例如：user1,user2,user3</p>
                  </div>
                </div>
              </div>
              
              <div class="border border-gray-200 rounded-lg p-4 hover:border-purple-300 hover:bg-purple-50 transition-all cursor-pointer" 
                   :class="{ 'border-purple-500 bg-purple-50': batchCreateMode === 'count' }"
                   @click="batchCreateMode = 'count'">
                <div class="flex items-start space-x-3">
                  <input type="radio" :checked="batchCreateMode === 'count'" class="mt-1 h-4 w-4 text-purple-600 focus:ring-purple-500 border-gray-300">
                  <div class="flex-1">
                    <h5 class="text-sm font-medium text-gray-900">批量创建</h5>
                    <p class="text-xs text-gray-500 mt-1">输入用户名前缀和数量，自动添加序号</p>
                    <p class="text-xs text-gray-600 mt-1">例如：user → user01, user02, user03</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 用户名列表方式 -->
          <div v-if="batchCreateMode === 'list'" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">用户名列表</label>
              <textarea v-model="batchUsernameList" 
                        placeholder="请输入用户名，用逗号分割，例如：user1,user2,user3"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                        rows="3"></textarea>
              <p class="text-xs text-gray-500 mt-1">用逗号分割多个用户名，系统会自动创建对应的邮箱和密码</p>
            </div>
          </div>
          
          <!-- 批量创建方式 -->
          <div v-if="batchCreateMode === 'count'" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">用户名前缀</label>
              <input v-model="batchUsernamePrefix" 
                     placeholder="例如：user"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
              <p class="text-xs text-gray-500 mt-1">系统会自动添加序号，如：user01, user02, user03</p>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">创建数量</label>
              <input v-model.number="batchUserCount" 
                     type="number" 
                     min="1" 
                     max="100"
                     placeholder="1"
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent">
              <p class="text-xs text-gray-500 mt-1">最多可创建100个用户</p>
            </div>
          </div>
          
          <!-- 密码设置 -->
          <div class="mt-6">
            <h4 class="text-sm font-medium text-gray-900 mb-3">密码设置</h4>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">用户密码</label>
              <input v-model="batchPassword" 
                     type="password" 
                     placeholder="请输入用户密码（必填）"
                     @input="batchCreatePasswordError = ''"
                     :class="batchCreatePasswordError ? 'border-red-500' : 'border-gray-300'"
                     class="w-full px-3 py-2 rounded-md focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent border">
              <p v-if="batchCreatePasswordError" class="text-xs text-red-500 mt-1">{{ batchCreatePasswordError }}</p>
              <p v-else class="text-xs text-gray-500 mt-1">所有用户将使用相同的密码，建议使用强密码</p>
            </div>
          </div>
          
          <!-- 创建结果 -->
          <div v-if="batchCreateResults.length > 0" class="mt-6">
            <h4 class="text-sm font-medium text-gray-900 mb-3">创建结果</h4>
            <div class="bg-gray-50 rounded-lg p-4 max-h-64 overflow-y-auto">
              <div v-for="result in batchCreateResults" :key="result.username" 
                   class="flex items-center justify-between py-2 border-b border-gray-200 last:border-b-0">
                <div class="flex-1">
                  <div class="flex items-center space-x-2">
                    <span class="font-medium">{{ result.username }}</span>
                    <span class="text-gray-500">{{ result.email }}</span>
                    <span class="text-gray-400">密码: {{ result.success ? '已设置' : '—' }}</span>
                  </div>
                  <div v-if="!result.success && result.reason" class="mt-1">
                    <span class="text-xs text-red-500">{{ result.reason }}</span>
                  </div>
                </div>
                <div class="flex items-center">
                  <svg v-if="result.success" class="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                  </svg>
                  <svg v-else class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                  </svg>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex justify-end space-x-2 sm:space-x-3">
          <button @click="closeBatchCreateDialog" 
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500">
            取消
          </button>
          <button @click="executeBatchCreate" 
                  :disabled="batchCreating || !canBatchCreate"
                  class="px-4 py-2 text-sm font-medium text-white bg-purple-600 border border-transparent rounded-lg hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed">
            <svg v-if="batchCreating" class="w-4 h-4 mr-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
            {{ batchCreating ? '创建中...' : '开始创建' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 批量删除用户确认弹窗 -->
    <div v-if="showBatchDeleteDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="closeBatchDeleteDialog">
      <div class="bg-white rounded-xl shadow-2xl max-w-lg w-full mx-4 transform transition-all duration-300 scale-100" @click.stop>
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-base sm:text-lg font-medium text-gray-900">批量删除用户</h3>
          <button class="text-gray-400 hover:text-gray-600" @click="closeBatchDeleteDialog" aria-label="关闭">
            <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
          </button>
        </div>
        
        <div class="px-4 sm:px-6 py-4 sm:py-5">
          <div class="flex items-center mb-4">
            <div class="flex-shrink-0">
              <svg class="h-8 w-8 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
              </svg>
            </div>
            <div class="ml-3">
              <h4 class="text-sm font-medium text-gray-900">确认删除操作</h4>
              <p class="text-sm text-gray-500 mt-1">您即将删除 {{ selectedUsers.size }} 个用户，此操作不可撤销。</p>
            </div>
          </div>
          
          <!-- 选中的用户列表 -->
          <div class="bg-gray-50 rounded-lg p-4 max-h-48 overflow-y-auto">
            <h5 class="text-sm font-medium text-gray-900 mb-3">将要删除的用户：</h5>
            <div class="space-y-2">
              <div v-for="userId in Array.from(selectedUsers)" :key="userId" 
                   class="flex items-center justify-between py-2 px-3 bg-white rounded border">
                <div class="flex items-center">
                  <span class="text-sm font-medium text-gray-900">
                    {{ users.find(u => u.id === userId)?.username }}
                  </span>
                  <span class="text-sm text-gray-500 ml-2">
                    {{ users.find(u => u.id === userId)?.email }}
                  </span>
                </div>
                <svg class="w-4 h-4 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                </svg>
              </div>
            </div>
          </div>
          
          <div class="mt-4 p-3 bg-red-50 rounded-lg">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
                </svg>
              </div>
              <div class="ml-3">
                <h5 class="text-sm font-medium text-red-800">重要提醒</h5>
                <div class="mt-1 text-sm text-red-700">
                  <ul class="list-disc list-inside space-y-1">
                    <li>删除用户将同时删除其所有邮件记录</li>
                    <li>此操作无法撤销，请谨慎操作</li>
                    <li>管理员用户 (xm) 受保护，无法删除</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex justify-end space-x-2 sm:space-x-3">
          <button @click="closeBatchDeleteDialog" 
                  :disabled="batchDeleting"
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 disabled:opacity-50 disabled:cursor-not-allowed">
            取消
          </button>
          <button @click="executeBatchDelete" 
                  :disabled="batchDeleting"
                  class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed">
            <svg v-if="batchDeleting" class="w-4 h-4 mr-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
            {{ batchDeleting ? '删除中...' : '确认删除' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 修改用户弹窗 -->
    <div v-if="showEditUserDialog" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="cancelEditUser">
      <div class="bg-white rounded-lg shadow-xl max-w-md w-full mx-4" @click.stop>
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-base sm:text-lg font-semibold text-gray-900">修改用户信息</h3>
          <button @click="cancelEditUser" class="text-gray-400 hover:text-gray-600 transition-colors">
            <svg class="w-4 h-4 sm:w-5 sm:h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
            </svg>
          </button>
        </div>
        <div class="px-4 sm:px-6 py-4">
          <div class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">用户名</label>
              <input v-model="editUserForm.username" 
                     type="text" 
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="请输入用户名">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">邮箱</label>
              <input v-model="editUserForm.email" 
                     type="email" 
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="请输入邮箱地址">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">新密码（留空则不修改）</label>
              <input v-model="editUserForm.password" 
                     type="password" 
                     class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
                     placeholder="留空则不修改密码">
            </div>
            <div v-if="editUserError" class="text-sm text-red-600 bg-red-50 p-2 rounded">
              {{ editUserError }}
            </div>
          </div>
        </div>
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex justify-end space-x-2 sm:space-x-3">
          <button @click="cancelEditUser" 
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors">
            取消
          </button>
          <button @click="confirmEditUser" 
                  :disabled="loading"
                  class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-md transition-colors disabled:opacity-50 disabled:cursor-not-allowed">
            {{ loading ? '保存中...' : '保存' }}
          </button>
        </div>
      </div>
    </div>

    <!-- 删除用户确认弹窗 -->
    <div v-if="showDeleteUserConfirm" class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" @click="cancelDeleteUser">
      <div class="bg-white rounded-xl shadow-2xl max-w-md w-full mx-4 transform transition-all duration-300 scale-100" @click.stop>
        <!-- 弹窗头部 -->
        <div class="flex items-center justify-between p-6 border-b border-gray-200">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
              <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
              </svg>
            </div>
            <div>
              <h3 class="text-lg font-semibold text-gray-900">删除用户确认</h3>
              <p class="text-sm text-gray-500">此操作不可撤销</p>
            </div>
          </div>
        </div>

        <!-- 弹窗内容 -->
        <div class="p-6">
          <div class="mb-4">
            <p class="text-gray-700 mb-2">您确定要删除以下用户吗？</p>
            <div class="bg-red-50 border border-red-200 rounded-lg p-3">
              <div class="flex items-center space-x-2">
                <svg class="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"></path>
                </svg>
                <div>
                  <span class="font-medium text-red-800">{{ userToDelete?.username }}</span>
                  <span class="text-red-600 ml-2">({{ userToDelete?.email }})</span>
                </div>
              </div>
            </div>
          </div>
          
          <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-4">
            <div class="flex items-start space-x-2">
              <svg class="w-5 h-5 text-yellow-600 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
              </svg>
              <div>
                <p class="text-sm text-yellow-800 font-medium">重要提醒</p>
                <p class="text-sm text-yellow-700 mt-1">删除后该用户的所有邮件数据将被永久删除，无法恢复。</p>
              </div>
            </div>
          </div>
        </div>

        <!-- 弹窗底部按钮 -->
        <div class="flex items-center justify-end space-x-3 p-6 bg-gray-50 rounded-b-xl">
          <button @click="cancelDeleteUser" 
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-colors duration-200">
            取消
          </button>
          <button @click="confirmDeleteUser" 
                  :disabled="loading"
                  class="px-4 py-2 text-sm font-medium text-white bg-red-600 border border-transparent rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200">
            <svg v-if="loading" class="w-4 h-4 mr-2 animate-spin" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"></path>
            </svg>
            <svg v-else class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
            </svg>
            {{ loading ? '删除中...' : '确认删除' }}
          </button>
        </div>
      </div>
    </div>

    <!-- SSL管理对话框 -->
    <div v-if="showSslManagementDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-0 sm:p-2 md:p-4">
      <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="closeSslManagementDialog"></div>
      <div class="relative bg-white/95 backdrop-blur-sm rounded-none sm:rounded-xl md:rounded-2xl shadow-2xl w-full h-full sm:h-auto sm:max-w-6xl sm:max-h-[90vh] overflow-y-auto border-0 sm:border border-white/20 animate-scale-in">
        <!-- 通知消息（显示在对话框内部，移动端调整位置） -->
        <div v-if="notice && showSslManagementDialog" class="fixed sm:absolute top-4 sm:top-16 left-4 sm:left-auto sm:right-4 z-50 w-[calc(100%-2rem)] sm:w-auto sm:max-w-md animate-slide-in-right">
          <div :class="{
            'bg-green-50 border-green-200 text-green-800': noticeType === 'success',
            'bg-red-50 border-red-200 text-red-800': noticeType === 'error',
            'bg-yellow-50 border-yellow-200 text-yellow-800': noticeType === 'warning',
            'bg-blue-50 border-blue-200 text-blue-800': noticeType === 'info'
          }" class="px-4 py-3 rounded-xl border-2 shadow-lg flex items-start space-x-3">
            <svg v-if="noticeType === 'success'" class="h-5 w-5 text-green-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <svg v-else-if="noticeType === 'error'" class="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <svg v-else-if="noticeType === 'warning'" class="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L4.268 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
            </svg>
            <svg v-else class="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <div class="flex-1">
              <p class="text-sm font-semibold whitespace-pre-line">{{ notice }}</p>
            </div>
            <button @click="notice = ''" class="text-gray-400 hover:text-gray-600 flex-shrink-0">
              <svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
              </svg>
            </button>
          </div>
        </div>
        
        <!-- 头部 -->
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between sticky top-0 bg-white/95 backdrop-blur-sm z-10">
          <h3 class="text-base sm:text-lg font-medium text-gray-900">SSL证书管理</h3>
          <button @click="closeSslManagementDialog" class="text-gray-400 hover:text-gray-600 transition-colors p-1 -mr-1">
            <svg class="h-5 w-5 sm:h-6 sm:w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
        
        <div class="px-3 sm:px-4 md:px-6 py-3 sm:py-4 md:py-5">
          <!-- 标签页切换（移动端优化） -->
          <div class="border-b border-gray-200 mb-4 sm:mb-6 overflow-x-auto -mx-3 sm:mx-0">
            <nav class="-mb-px flex space-x-2 sm:space-x-4 px-3 sm:px-0 min-w-max sm:min-w-0">
              <button @click="sslTab = 'domains'" 
                      :class="['py-2.5 sm:py-2 px-3 sm:px-4 text-xs sm:text-sm font-medium border-b-2 transition-colors whitespace-nowrap', 
                               sslTab === 'domains' 
                                 ? 'border-green-500 text-green-600' 
                                 : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300']">
                <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5 sm:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                </svg>
                域名管理
              </button>
              <button @click="sslTab = 'certificates'" 
                      :class="['py-2.5 sm:py-2 px-3 sm:px-4 text-xs sm:text-sm font-medium border-b-2 transition-colors whitespace-nowrap', 
                               sslTab === 'certificates' 
                                 ? 'border-green-500 text-green-600' 
                                 : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300']">
                <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5 sm:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                </svg>
                证书管理
              </button>
              <button @click="sslTab = 'upload'" 
                      :class="['py-2.5 sm:py-2 px-3 sm:px-4 text-xs sm:text-sm font-medium border-b-2 transition-colors whitespace-nowrap', 
                               sslTab === 'upload' 
                                 ? 'border-green-500 text-green-600' 
                                 : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300']">
                <svg class="w-3.5 h-3.5 sm:w-4 sm:h-4 inline mr-1.5 sm:mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                </svg>
                上传证书
              </button>
            </nav>
          </div>
          
          <!-- 域名管理标签页 -->
          <div v-if="sslTab === 'domains'" class="space-y-4">
            <!-- 启用SSL按钮（仅在SSL未启用时显示，移动端优化） -->
            <div v-if="!sslEnabled" class="bg-yellow-50 border border-yellow-200 rounded-lg p-3 sm:p-4 mb-3 sm:mb-4">
              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
                <div class="flex-1 min-w-0">
                  <h4 class="text-sm sm:text-base font-medium text-yellow-900 mb-1">SSL未启用</h4>
                  <p class="text-xs sm:text-sm text-yellow-700 break-words">请先为域名配置SSL证书并启用SSL</p>
                </div>
                <button @click="enableSslForDomain" 
                        :disabled="sslEnabling || !selectedSslDomain"
                        class="w-full sm:w-auto px-4 py-2.5 sm:py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed rounded-md transition-colors touch-manipulation sm:ml-4">
                  {{ sslEnabling ? '配置中...' : '启用SSL' }}
                </button>
              </div>
            </div>
            
            <!-- HTTP跳转HTTPS按钮（在有已配置SSL的域名时显示，移动端优化） -->
            <div v-if="hasConfiguredSslDomains" class="bg-blue-50 border border-blue-200 rounded-lg p-3 sm:p-4 mb-3 sm:mb-4">
              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-3 sm:space-y-0">
                <div class="flex-1 min-w-0">
                  <h4 class="text-sm sm:text-base font-medium text-blue-900 mb-1">HTTP自动跳转HTTPS</h4>
                  <p v-if="httpRedirectEnabled" class="text-xs sm:text-sm text-green-700 font-medium break-words">
                    ✓ HTTP跳转HTTPS已配置，所有HTTP请求将自动跳转到HTTPS
                  </p>
                  <p v-else class="text-xs sm:text-sm text-blue-700 break-words">默认关闭，点击按钮启用HTTP自动跳转HTTPS（配置需要2-3分钟）</p>
                </div>
                <div class="flex flex-col sm:flex-row gap-2 sm:gap-3 w-full sm:w-auto">
                  <button v-if="!httpRedirectEnabled" 
                          @click="enableHttpRedirect" 
                          :disabled="httpRedirectEnabling"
                          class="w-full sm:w-auto px-4 py-2.5 sm:py-2 text-sm font-medium rounded-md transition-colors flex-shrink-0 touch-manipulation min-h-[44px] sm:min-h-0"
                          :class="httpRedirectEnabling
                            ? 'bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed'
                            : 'bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed'"
                          title="启用HTTP跳转HTTPS">
                    <span v-if="httpRedirectEnabling" class="flex items-center justify-center">
                      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      配置中...
                    </span>
                    <span v-else class="flex items-center justify-center">
                      <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
                      </svg>
                      启用HTTP跳转
                    </span>
                  </button>
                  <button v-else
                          @click="disableHttpRedirect" 
                          :disabled="httpRedirectDisabling"
                          class="w-full sm:w-auto px-4 py-2.5 sm:py-2 text-sm font-medium rounded-md transition-colors flex-shrink-0 touch-manipulation min-h-[44px] sm:min-h-0"
                          :class="httpRedirectDisabling
                            ? 'bg-red-600 text-white hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed'
                            : 'bg-red-600 text-white hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed'"
                          title="禁用HTTP跳转HTTPS">
                    <span v-if="httpRedirectDisabling" class="flex items-center justify-center">
                      <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      禁用中...
                    </span>
                    <span v-else class="flex items-center justify-center">
                      <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                      </svg>
                      禁用HTTP跳转
                    </span>
                  </button>
                </div>
              </div>
            </div>
            
            <!-- 域名列表 -->
            <div class="bg-white rounded-lg border border-gray-200 p-3 sm:p-4">
              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-2 sm:space-y-0 mb-3 sm:mb-4">
                <h5 class="text-sm sm:text-base font-medium text-gray-900">已配置的SSL域名</h5>
                <button @click="showAddDomainForm = !showAddDomainForm" 
                        class="w-full sm:w-auto text-xs sm:text-sm px-4 py-2 sm:px-3 sm:py-1 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors touch-manipulation">
                  {{ showAddDomainForm ? '取消' : '添加域名' }}
                </button>
              </div>
              
              <!-- 添加域名表单（移动端优化） -->
              <div v-if="showAddDomainForm" class="mb-3 sm:mb-4 p-3 sm:p-4 bg-gray-50 rounded-lg border border-gray-200">
                <div class="space-y-3">
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">域名</label>
                    <input v-model="newSslDomain" 
                           type="text" 
                           placeholder="example.com" 
                           class="w-full px-3 py-2.5 sm:py-2 text-base sm:text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                  </div>
                  
                  <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1.5">关联证书</label>
                    <select v-model="newSslDomainCert" 
                            class="w-full px-3 py-2.5 sm:py-2 text-base sm:text-sm border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                      <option value="">选择证书（可选）</option>
                      <option v-for="cert in availableCertificatesForBinding" :key="cert.name" :value="cert.name">
                        {{ cert.name }} {{ cert.expiresAt ? `(到期: ${cert.expiresAt})` : '' }}
                      </option>
                    </select>
                    <p class="text-xs text-gray-500 mt-1.5 break-words">留空则自动关联同名证书，或选择已有证书实现多域名共享（证书链文件不会显示在此列表中）</p>
                  </div>
                  
                  <div class="flex flex-col sm:flex-row space-y-2 sm:space-y-0 sm:space-x-2">
                    <button @click="addSslDomain" 
                            :disabled="!newSslDomain || sslDomainAdding"
                            class="flex-1 px-4 py-2.5 sm:py-2 text-sm bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed touch-manipulation">
                      {{ sslDomainAdding ? '添加中...' : '添加域名' }}
                    </button>
                    <button @click="showAddDomainForm = false" 
                            class="flex-1 sm:flex-none px-4 py-2.5 sm:py-2 text-sm bg-gray-200 text-gray-700 rounded-md hover:bg-gray-300 touch-manipulation">
                      取消
                    </button>
                  </div>
                </div>
              </div>
              
              <!-- 域名列表（移动端优化） -->
              <div class="space-y-2 sm:space-y-3">
                <div v-for="domain in sslDomains" :key="domain.name" 
                     class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-3 sm:p-3 bg-gray-50 rounded-lg border border-gray-200 space-y-3 sm:space-y-0">
                  <div class="flex items-start sm:items-center space-x-3 flex-1 min-w-0">
                    <div class="w-8 h-8 sm:w-8 sm:h-8 bg-green-100 rounded-full flex items-center justify-center flex-shrink-0">
                      <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                      </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex flex-col sm:flex-row sm:items-center space-y-1 sm:space-y-0 sm:space-x-2">
                        <span class="text-sm sm:text-base font-medium text-gray-900 break-words">{{ domain.name }}</span>
                        <span v-if="domain.certName" class="text-xs text-gray-500 break-words">
                          (证书: {{ domain.certName }})
                        </span>
                      </div>
                      <div class="flex flex-wrap items-center gap-1.5 sm:gap-2 mt-1.5 sm:mt-1">
                        <span v-if="domain.certExists" class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800">
                          <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                          </svg>
                          证书存在
                        </span>
                        <span v-if="domain.sslConfigured" class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-blue-100 text-blue-800">
                          <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M2.166 4.999A11.954 11.954 0 0010 1.944 11.954 11.954 0 0017.834 5c.11.65.166 1.32.166 2.001 0 5.225-3.34 9.67-8 11.317C5.34 16.67 2 12.225 2 7c0-.682.057-1.35.166-2.001zm11.541 3.708a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                          </svg>
                          Apache SSL已配置
                        </span>
                        <span v-if="!domain.sslConfigured && domain.certExists" class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-yellow-100 text-yellow-800">
                          <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
                          </svg>
                          Apache SSL未配置
                        </span>
                        <span v-if="domain.expiresAt" class="text-xs text-gray-500 whitespace-nowrap">
                          到期：{{ domain.expiresAt }}
                        </span>
                      </div>
                    </div>
                  </div>
                  <div class="flex flex-wrap sm:flex-nowrap items-center gap-2 w-full sm:w-auto">
                    <!-- 配置HTTPS按钮（已配置时禁用，移动端优化） -->
                    <button v-if="domain.certExists" 
                            @click="configureDomainSsl(domain)"
                            :disabled="domain.sslConfigured || domain.sslConfiguring"
                            class="flex-1 sm:flex-none px-3 sm:px-3 py-2 sm:py-1.5 text-xs sm:text-xs font-medium rounded-md transition-colors touch-manipulation min-h-[44px] sm:min-h-0"
                            :class="domain.sslConfigured 
                              ? 'bg-blue-600 text-white cursor-not-allowed opacity-60' 
                              : domain.sslConfiguring
                                ? 'bg-green-600 text-white hover:bg-green-700 disabled:bg-green-400'
                                : 'bg-green-600 text-white hover:bg-green-700 disabled:bg-green-400'"
                            :title="domain.sslConfigured ? 'Apache SSL已配置，请先禁用SSL后再配置' : '配置Apache SSL'">
                      <span v-if="domain.sslConfiguring" class="flex items-center justify-center">
                        <svg class="animate-spin -ml-1 mr-1.5 h-3.5 w-3.5 sm:h-3 sm:w-3 text-white" fill="none" viewBox="0 0 24 24">
                          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        配置中...
                      </span>
                      <span v-else class="flex items-center justify-center">
                        <svg v-if="domain.sslConfigured" class="w-3.5 h-3.5 sm:w-3 sm:h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                        </svg>
                        <svg v-else class="w-3.5 h-3.5 sm:w-3 sm:h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
                        </svg>
                        {{ domain.sslConfigured ? '已配置' : '配置HTTPS' }}
                      </span>
                    </button>
                    <!-- 禁用SSL按钮（仅在已配置时显示，未配置时禁用，移动端优化） -->
                    <button v-if="domain.certExists" 
                            @click="disableDomainSsl(domain)"
                            :disabled="!domain.sslConfigured || domain.sslDisabling"
                            class="flex-1 sm:flex-none px-3 sm:px-3 py-2 sm:py-1.5 text-xs sm:text-xs font-medium rounded-md transition-colors touch-manipulation min-h-[44px] sm:min-h-0"
                            :class="!domain.sslConfigured
                              ? 'bg-gray-400 text-white cursor-not-allowed opacity-60'
                              : domain.sslDisabling
                                ? 'bg-red-600 text-white hover:bg-red-700 disabled:bg-red-400'
                                : 'bg-red-600 text-white hover:bg-red-700 disabled:bg-red-400'"
                            :title="!domain.sslConfigured ? '请先配置SSL后再禁用' : '禁用Apache SSL配置'">
                      <span v-if="domain.sslDisabling" class="flex items-center justify-center">
                        <svg class="animate-spin -ml-1 mr-1.5 h-3.5 w-3.5 sm:h-3 sm:w-3 text-white" fill="none" viewBox="0 0 24 24">
                          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        禁用中...
                      </span>
                      <span v-else class="flex items-center justify-center">
                        <svg class="w-3.5 h-3.5 sm:w-3 sm:h-3 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636"></path>
                        </svg>
                        禁用SSL
                      </span>
                    </button>
                    <!-- 编辑和删除按钮（移动端优化） -->
                    <div class="flex items-center space-x-1 sm:space-x-2">
                      <button @click="editDomainCert(domain)" 
                              class="p-2.5 sm:p-2 text-blue-500 hover:text-blue-700 hover:bg-blue-50 rounded-lg transition-colors touch-manipulation min-w-[44px] sm:min-w-0 min-h-[44px] sm:min-h-0 flex items-center justify-center"
                              title="编辑证书关联">
                        <svg class="w-5 h-5 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                        </svg>
                      </button>
                      <button @click="removeSslDomain(domain.name)" 
                              class="p-2.5 sm:p-2 text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors touch-manipulation min-w-[44px] sm:min-w-0 min-h-[44px] sm:min-h-0 flex items-center justify-center"
                              title="删除域名">
                        <svg class="w-5 h-5 sm:w-4 sm:h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                        </svg>
                      </button>
                    </div>
                  </div>
                </div>
                
                <div v-if="sslDomains.length === 0" class="text-center py-8 text-gray-500 text-sm">
                  暂无配置的SSL域名
                </div>
              </div>
            </div>
          </div>
          
          <!-- 证书管理标签页（移动端优化） -->
          <div v-if="sslTab === 'certificates'" class="space-y-3 sm:space-y-4">
            <div class="bg-white rounded-lg border border-gray-200 p-3 sm:p-4 md:p-6">
              <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-2 sm:space-y-0 mb-3 sm:mb-4">
                <h5 class="text-sm sm:text-base font-medium text-gray-900">可用证书列表</h5>
                <span class="text-xs text-gray-500">{{ availableCertificates.length }} 个证书</span>
              </div>
              <div class="space-y-2 sm:space-y-3">
                <div v-for="cert in availableCertificates" :key="cert.name" 
                     class="flex flex-col sm:flex-row sm:items-center sm:justify-between p-3 sm:p-4 bg-gradient-to-r from-gray-50 to-white rounded-lg border border-gray-200 hover:border-blue-300 hover:shadow-md transition-all duration-200 space-y-3 sm:space-y-0">
                  <div class="flex items-start sm:items-center space-x-3 sm:space-x-4 flex-1 min-w-0">
                    <div class="flex-shrink-0 w-10 h-10 bg-gradient-to-br from-blue-100 to-blue-200 rounded-full flex items-center justify-center shadow-sm">
                      <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                      </svg>
                    </div>
                    <div class="flex-1 min-w-0">
                      <div class="flex flex-col sm:flex-row sm:items-center space-y-1 sm:space-y-0 sm:space-x-2 mb-1 sm:mb-1">
                        <span class="text-sm sm:text-base font-semibold text-gray-900 break-words">{{ cert.name }}</span>
                        <span v-if="cert.expiresAt && isCertExpiringSoon(cert.expiresAt)" 
                              class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-red-100 text-red-800 self-start sm:self-center">
                          <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
                          </svg>
                          即将过期
                        </span>
                      </div>
                      <div class="flex flex-wrap items-center gap-1.5 sm:gap-2 mt-2">
                        <span v-if="cert.expiresAt" 
                              class="inline-flex items-center px-2 py-1 rounded-md text-xs font-medium"
                              :class="isCertExpiringSoon(cert.expiresAt) ? 'bg-red-100 text-red-800' : 'bg-green-100 text-green-800'">
                          <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z" clip-rule="evenodd"></path>
                          </svg>
                          到期：{{ cert.expiresAt }}
                        </span>
                        <span v-if="cert.domains && cert.domains.length > 0" 
                              class="inline-flex items-center px-2 py-1 rounded-md text-xs font-medium bg-blue-100 text-blue-800">
                          <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M11.3 1.047A5 5 0 0115 6h-2.5a2.5 2.5 0 00-4.6-.544A2.5 2.5 0 005.5 8H3a3 3 0 100 6h2.5a2.5 2.5 0 004.6.544A5 5 0 1111.3 1.047zM9 8H5.5a.5.5 0 00-.5.5v3a.5.5 0 00.5.5H9v-4zm4.5 0H11v4h2.5a.5.5 0 00.5-.5v-3a.5.5 0 00-.5-.5z" clip-rule="evenodd"></path>
                          </svg>
                          已关联 {{ cert.domains.length }} 个域名
                        </span>
                      </div>
                    </div>
                  </div>
                  <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 sm:space-x-2 sm:ml-4 w-full sm:w-auto">
                    <button @click="viewCertDetails(cert)" 
                            class="flex-1 sm:flex-none px-4 py-2.5 sm:py-2 text-xs sm:text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center space-x-1 touch-manipulation min-h-[44px] sm:min-h-0"
                            title="查看证书详细信息">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                      </svg>
                      <span>查看详情</span>
                    </button>
                    <button @click="deleteCertificate(cert)" 
                            :disabled="cert.deleting"
                            class="flex-1 sm:flex-none px-4 py-2.5 sm:py-2 text-xs sm:text-sm font-medium text-white bg-red-600 hover:bg-red-700 disabled:bg-red-400 disabled:cursor-not-allowed rounded-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center space-x-1 touch-manipulation min-h-[44px] sm:min-h-0"
                            title="删除证书">
                      <svg v-if="!cert.deleting" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                      </svg>
                      <svg v-else class="animate-spin w-4 h-4" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      <span>{{ cert.deleting ? '删除中...' : '删除' }}</span>
                    </button>
                  </div>
                </div>
                
                <div v-if="availableCertificates.length === 0" class="text-center py-12 text-gray-500">
                  <svg class="w-16 h-16 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
                  </svg>
                  <p class="text-sm font-medium">暂无可用证书</p>
                  <p class="text-xs text-gray-400 mt-1">请在上传证书标签页上传证书</p>
                </div>
              </div>
            </div>
          </div>
          
          <!-- 上传证书标签页（移动端优化） -->
          <div v-if="sslTab === 'upload'" class="space-y-3 sm:space-y-4">
            <div class="bg-white rounded-lg border border-gray-200 p-3 sm:p-4">
              <h5 class="text-sm sm:text-base font-medium text-gray-900 mb-3 sm:mb-4">批量上传SSL证书</h5>
              
              <!-- 拖拽上传区域（移动端优化） -->
              <div 
                @drop="handleDrop"
                @dragover.prevent="isDragging = true"
                @dragleave.prevent="isDragging = false"
                @dragenter.prevent
                @click="() => fileInputRef?.click()"
                :class="[
                  'border-2 border-dashed rounded-lg p-6 sm:p-8 text-center transition-colors cursor-pointer touch-manipulation',
                  isDragging 
                    ? 'border-green-500 bg-green-50' 
                    : 'border-gray-300 hover:border-green-400 hover:bg-gray-50'
                ]">
                <input 
                  type="file" 
                  multiple 
                  accept=".crt,.pem,.cer,.key"
                  @change="handleFileSelect"
                  class="hidden"
                  ref="fileInputRef"
                  id="cert-file-input">
                <div class="cursor-pointer">
                  <svg class="w-12 h-12 sm:w-16 sm:h-16 mx-auto mb-3 sm:mb-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                  </svg>
                  <p class="text-sm sm:text-base font-medium text-gray-700 mb-1.5 sm:mb-1 break-words">
                    {{ isDragging ? '松开鼠标上传文件' : '拖拽证书文件到此处或点击选择文件' }}
                  </p>
                  <p class="text-xs sm:text-sm text-gray-500 break-words">
                    支持同时上传多个文件，系统将自动识别同一域名的证书文件<br class="hidden sm:block">
                    <span class="block sm:inline">例如：example.com.key、www.example.com_public.crt、www.example.com_chain.crt</span>
                  </p>
                </div>
              </div>
              
              <!-- 证书上传项列表（移动端优化） -->
              <div v-if="certificateUploadList.length > 0" class="mt-4 sm:mt-6 space-y-3 sm:space-y-4">
                <div v-for="(item, index) in certificateUploadList" :key="item.id" 
                     class="border border-gray-200 rounded-lg p-3 sm:p-4 bg-gray-50">
                  <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between space-y-2 sm:space-y-0 mb-3">
                    <div class="flex-1 min-w-0">
                      <h6 class="text-sm font-medium text-gray-900">证书 #{{ index + 1 }}</h6>
                      <p v-if="item.domainName" class="text-xs text-gray-500 mt-1 break-words">域名: {{ item.domainName }}</p>
                    </div>
                    <button @click="removeCertificateUploadItem(item.id)" 
                            class="w-full sm:w-auto text-xs px-3 py-2 sm:px-2 sm:py-1 text-red-600 hover:bg-red-50 rounded transition-colors touch-manipulation min-h-[44px] sm:min-h-0">
                      删除
                    </button>
                  </div>
                  
                  <div class="space-y-3">
                    <div>
                      <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1.5">证书文件 (.crt, .pem, .cer) *</label>
                      <div class="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2">
                        <input 
                          @change="(e) => handleBatchCertFileChange(e, item.id)" 
                          type="file" 
                          accept=".crt,.pem,.cer"
                          class="flex-1 px-3 py-2.5 sm:px-2 sm:py-1.5 text-sm sm:text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                        <span v-if="item.certFile" class="text-xs text-green-600 break-words sm:break-normal">✓ {{ item.certFile.name }}</span>
                      </div>
                    </div>
                    
                    <div>
                      <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1.5">私钥文件 (.key, .pem) *</label>
                      <div class="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2">
                        <input 
                          @change="(e) => handleBatchKeyFileChange(e, item.id)" 
                          type="file" 
                          accept=".key,.pem"
                          class="flex-1 px-3 py-2.5 sm:px-2 sm:py-1.5 text-sm sm:text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                        <span v-if="item.keyFile" class="text-xs text-green-600 break-words sm:break-normal">✓ {{ item.keyFile.name }}</span>
                      </div>
                    </div>
                    
                    <div>
                      <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1.5">证书链文件 (.crt, .pem, .cer) <span class="text-gray-400">(可选)</span></label>
                      <div class="flex flex-col sm:flex-row sm:items-center space-y-2 sm:space-y-0 sm:space-x-2">
                        <input 
                          @change="(e) => handleBatchChainFileChange(e, item.id)" 
                          type="file" 
                          accept=".crt,.pem,.cer"
                          class="flex-1 px-3 py-2.5 sm:px-2 sm:py-1.5 text-sm sm:text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                        <span v-if="item.chainFile" class="text-xs text-green-600 break-words sm:break-normal">✓ {{ item.chainFile.name }}</span>
                        <span v-else class="text-xs text-gray-400">未选择</span>
                      </div>
                      <p class="text-xs text-gray-500 mt-1.5 break-words">证书链文件用于完整的SSL证书验证，通常包含中间证书（不会绑定到域名）</p>
                    </div>
                    
                    <div>
                      <label class="block text-xs sm:text-sm font-medium text-gray-700 mb-1.5">证书名称（用于标识） *</label>
                      <input v-model="item.certName" 
                             type="text" 
                             :placeholder="item.domainName ? `例如: ${item.domainName}` : '例如: my-cert-2024'" 
                             class="w-full px-3 py-2.5 sm:px-2 sm:py-1.5 text-sm sm:text-xs border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                      <p class="text-xs text-gray-500 mt-1.5 break-words">证书名称用于在系统中标识此证书，可与域名不同</p>
                    </div>
                  </div>
                </div>
                
                <div class="pt-3 sm:pt-4 border-t border-gray-200">
                  <button @click="uploadBatchCertificates" 
                          :disabled="batchCertUploading || !canUploadBatchCertificates"
                          class="w-full px-4 py-3 sm:py-2 text-sm font-medium bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors touch-manipulation min-h-[44px] sm:min-h-0 flex items-center justify-center">
                    <svg v-if="batchCertUploading" class="animate-spin h-4 w-4 mr-2" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    {{ batchCertUploading ? '上传中...' : `上传 ${certificateUploadList.length} 个证书` }}
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 底部按钮 -->
        <div class="px-3 sm:px-4 md:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3 sticky bottom-0 bg-white/95 backdrop-blur-sm">
          <button @click="closeSslManagementDialog" 
                  class="w-full sm:w-auto px-4 py-2.5 sm:py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors touch-manipulation">
            关闭
          </button>
        </div>
      </div>
    </div>
    
    <!-- 证书详情对话框 -->
    <div v-if="showCertDetailsDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
      <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="showCertDetailsDialog = false"></div>
      <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-3xl max-h-[90vh] border border-white/20 animate-scale-in flex flex-col">
        <div class="px-4 sm:px-6 py-4 border-b border-gray-200 flex items-center justify-between bg-gradient-to-r from-blue-50 to-indigo-50">
          <div class="flex items-center space-x-3">
            <div class="w-10 h-10 bg-gradient-to-br from-blue-500 to-indigo-600 rounded-lg flex items-center justify-center shadow-lg">
              <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"></path>
              </svg>
            </div>
            <div>
              <h3 class="text-lg sm:text-xl font-semibold text-gray-900">证书详细信息</h3>
              <p v-if="certDetails" class="text-xs sm:text-sm text-gray-600 mt-0.5">{{ certDetails.name }}</p>
            </div>
          </div>
          <button @click="showCertDetailsDialog = false" class="text-gray-400 hover:text-gray-600 transition-colors p-1 hover:bg-white/50 rounded-lg">
            <svg class="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
        
        <div class="flex-1 overflow-y-auto px-4 sm:px-6 py-4 sm:py-6">
          <div v-if="certDetailsLoading" class="flex items-center justify-center py-12">
            <svg class="animate-spin h-8 w-8 text-blue-600" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <span class="ml-3 text-gray-600">加载证书信息中...</span>
          </div>
          
          <div v-else-if="certDetails" class="space-y-6">
            <!-- 基本信息卡片 -->
            <div class="bg-gradient-to-br from-gray-50 to-white rounded-lg border border-gray-200 p-4 sm:p-6 shadow-sm">
              <h4 class="text-sm font-semibold text-gray-900 mb-4 flex items-center">
                <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                基本信息
              </h4>
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">证书名称</label>
                  <p class="mt-1 text-sm font-semibold text-gray-900">{{ certDetails.name }}</p>
                </div>
                <div>
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">状态</label>
                  <p class="mt-1">
                    <span v-if="certDetails.isValid" class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                      <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                      </svg>
                      有效
                    </span>
                    <span v-else class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                      <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                      </svg>
                      已过期
                    </span>
                  </p>
                </div>
                <div>
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">生效日期</label>
                  <p class="mt-1 text-sm text-gray-900">{{ certDetails.notBefore || '未知' }}</p>
                </div>
                <div>
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">到期日期</label>
                  <p class="mt-1 text-sm font-semibold" :class="certDetails.isValid ? 'text-gray-900' : 'text-red-600'">
                    {{ certDetails.notAfter || '未知' }}
                  </p>
                </div>
              </div>
            </div>
            
            <!-- 证书文件信息 -->
            <div class="bg-gradient-to-br from-gray-50 to-white rounded-lg border border-gray-200 p-4 sm:p-6 shadow-sm">
              <h4 class="text-sm font-semibold text-gray-900 mb-4 flex items-center">
                <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                证书文件
              </h4>
              <div class="space-y-3">
                <div class="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm font-medium text-gray-900">证书文件 (.crt)</p>
                      <p class="text-xs text-gray-500 mt-0.5 font-mono">{{ certDetails.certFile }}</p>
                    </div>
                  </div>
                  <span class="text-xs text-green-600 font-medium">存在</span>
                </div>
                <div v-if="certDetails.keyExists" class="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"></path>
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm font-medium text-gray-900">私钥文件 (.key)</p>
                      <p class="text-xs text-gray-500 mt-0.5 font-mono">{{ certDetails.keyFile }}</p>
                    </div>
                  </div>
                  <span class="text-xs text-green-600 font-medium">存在</span>
                </div>
                <div v-if="certDetails.chainExists" class="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200">
                  <div class="flex items-center space-x-3">
                    <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                      <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-3 7h3m-3 4h3m-6-4h.01M9 16h.01"></path>
                      </svg>
                    </div>
                    <div>
                      <p class="text-sm font-medium text-gray-900">证书链文件 (.chain.crt)</p>
                      <p class="text-xs text-gray-500 mt-0.5 font-mono">{{ certDetails.chainFile }}</p>
                    </div>
                  </div>
                  <span class="text-xs text-green-600 font-medium">存在</span>
                </div>
              </div>
            </div>
            
            <!-- 证书详细信息 -->
            <div v-if="certDetails.subject || certDetails.issuer || certDetails.serial || certDetails.fingerprint" 
                 class="bg-gradient-to-br from-gray-50 to-white rounded-lg border border-gray-200 p-4 sm:p-6 shadow-sm">
              <h4 class="text-sm font-semibold text-gray-900 mb-4 flex items-center">
                <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"></path>
                </svg>
                证书详细信息
              </h4>
              <div class="space-y-3">
                <div v-if="certDetails.subject">
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">主题 (Subject)</label>
                  <p class="mt-1 text-sm text-gray-900 font-mono break-all">{{ certDetails.subject }}</p>
                </div>
                <div v-if="certDetails.issuer">
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">颁发者 (Issuer)</label>
                  <p class="mt-1 text-sm text-gray-900 font-mono break-all">{{ certDetails.issuer }}</p>
                </div>
                <div v-if="certDetails.serial">
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">序列号 (Serial)</label>
                  <p class="mt-1 text-sm text-gray-900 font-mono">{{ certDetails.serial }}</p>
                </div>
                <div v-if="certDetails.fingerprint">
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">SHA256 指纹</label>
                  <p class="mt-1 text-sm text-gray-900 font-mono break-all">{{ certDetails.fingerprint }}</p>
                </div>
                <div v-if="certDetails.san && certDetails.san.length > 0">
                  <label class="text-xs font-medium text-gray-500 uppercase tracking-wide">SAN (Subject Alternative Names)</label>
                  <div class="mt-2 space-y-1">
                    <div v-for="(san, index) in certDetails.san" :key="index" 
                         class="inline-flex items-center px-2 py-1 rounded-md text-xs font-medium mr-2 mb-2"
                         :class="san.type === 'DNS' ? 'bg-blue-100 text-blue-800' : 'bg-purple-100 text-purple-800'">
                      <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                        <path v-if="san.type === 'DNS'" fill-rule="evenodd" d="M11.3 1.047A5 5 0 0115 6h-2.5a2.5 2.5 0 00-4.6-.544A2.5 2.5 0 005.5 8H3a3 3 0 100 6h2.5a2.5 2.5 0 004.6.544A5 5 0 1111.3 1.047zM9 8H5.5a.5.5 0 00-.5.5v3a.5.5 0 00.5.5H9v-4zm4.5 0H11v4h2.5a.5.5 0 00.5-.5v-3a.5.5 0 00-.5-.5z" clip-rule="evenodd"></path>
                        <path v-else fill-rule="evenodd" d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z" clip-rule="evenodd"></path>
                      </svg>
                      {{ san.type }}: {{ san.value }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 关联域名 -->
            <div v-if="certDetails.usedByDomains && certDetails.usedByDomains.length > 0" 
                 class="bg-gradient-to-br from-gray-50 to-white rounded-lg border border-gray-200 p-4 sm:p-6 shadow-sm">
              <h4 class="text-sm font-semibold text-gray-900 mb-4 flex items-center">
                <svg class="w-4 h-4 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                </svg>
                关联域名 ({{ certDetails.usedByDomains.length }})
              </h4>
              <div class="flex flex-wrap gap-2">
                <span v-for="domain in certDetails.usedByDomains" :key="domain" 
                      class="inline-flex items-center px-3 py-1.5 rounded-lg text-sm font-medium bg-blue-100 text-blue-800">
                  <svg class="w-4 h-4 mr-1.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                  </svg>
                  {{ domain }}
                </span>
              </div>
            </div>
            
            <div v-else class="bg-gradient-to-br from-gray-50 to-white rounded-lg border border-gray-200 p-4 sm:p-6 shadow-sm">
              <div class="text-center py-4">
                <svg class="w-12 h-12 mx-auto text-gray-300 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                </svg>
                <p class="text-sm text-gray-500">此证书未关联任何域名</p>
              </div>
            </div>
          </div>
          
          <div v-else class="text-center py-12 text-gray-500">
            <svg class="w-16 h-16 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <p class="text-sm font-medium">无法加载证书信息</p>
          </div>
        </div>
        
        <div class="px-4 sm:px-6 py-4 border-t border-gray-200 flex justify-end bg-gray-50/50">
          <button @click="showCertDetailsDialog = false" 
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 border border-gray-300 rounded-lg transition-colors shadow-sm">
            关闭
          </button>
        </div>
      </div>
    </div>
    
    <!-- 编辑证书关联对话框 -->
    <div v-if="showEditCertDialog" class="fixed inset-0 z-50 flex items-center justify-center animate-fade-in p-2 sm:p-4">
      <div class="absolute inset-0 bg-black/50 backdrop-blur-sm" @click="showEditCertDialog = false"></div>
      <div class="relative bg-white/95 backdrop-blur-sm rounded-xl sm:rounded-2xl shadow-2xl w-full max-w-md border border-white/20 animate-scale-in">
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-base sm:text-lg font-medium text-gray-900">编辑证书关联</h3>
          <button @click="showEditCertDialog = false" class="text-gray-400 hover:text-gray-600 transition-colors">
            <svg class="h-4 w-4 sm:h-5 sm:w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
            </svg>
          </button>
        </div>
        <div class="px-4 sm:px-6 py-4 sm:py-5">
          <div v-if="editingDomainCert" class="space-y-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">域名</label>
              <input :value="editingDomainCert.name" 
                     type="text" 
                     disabled
                     class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-600">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">关联证书</label>
              <select v-model="editingCertName" 
                      class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500">
                <option value="">选择证书（留空则使用同名证书）</option>
                <option v-for="cert in availableCertificatesForBinding" :key="cert.name" :value="cert.name">
                  {{ cert.name }} {{ cert.expiresAt ? `(到期: ${cert.expiresAt})` : '' }}
                </option>
              </select>
              <p class="text-xs text-gray-500 mt-1">留空则自动关联同名证书，或选择已有证书实现多域名共享（证书链文件不会显示在此列表中）</p>
            </div>
          </div>
        </div>
        <div class="px-4 sm:px-6 py-3 sm:py-4 border-t border-gray-200 flex flex-col sm:flex-row justify-end space-y-2 sm:space-y-0 sm:space-x-3">
          <button @click="showEditCertDialog = false" 
                  class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors">
            取消
          </button>
          <button @click="saveDomainCertEdit" 
                  class="px-4 py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 rounded-md transition-colors">
            保存
          </button>
        </div>
      </div>
    </div>
    </div>
  </Layout>
</template>

<style scoped>
/* 弹窗响应式优化 */
@media (max-height: 600px) {
  .fixed.inset-0 {
    align-items: flex-start;
    padding-top: 1rem;
  }
}

/* 确保按钮区域在小屏幕上可见 */
.sticky.bottom-0 {
  position: sticky;
  bottom: 0;
  z-index: 10;
}

/* 小屏幕优化 */
@media (max-width: 640px) {
  .max-w-2xl,
  .max-w-3xl,
  .max-w-4xl {
    margin: 0.5rem;
    max-width: calc(100vw - 1rem);
  }
  
  .px-6 {
    padding-left: 1rem;
    padding-right: 1rem;
  }
  
  .py-4 {
    padding-top: 0.75rem;
    padding-bottom: 0.75rem;
  }
}

/* 确保弹窗内容可滚动 */
.overflow-y-auto {
  scrollbar-width: thin;
  scrollbar-color: rgba(156, 163, 175, 0.5) transparent;
}

.overflow-y-auto::-webkit-scrollbar {
  width: 6px;
}

.overflow-y-auto::-webkit-scrollbar-track {
  background: transparent;
}

.overflow-y-auto::-webkit-scrollbar-thumb {
  background-color: rgba(156, 163, 175, 0.5);
  border-radius: 3px;
}

.overflow-y-auto::-webkit-scrollbar-thumb:hover {
  background-color: rgba(156, 163, 175, 0.7);
}
</style>

<script setup lang="ts">
import axios from 'axios'
import { ref, onUnmounted, onMounted, computed, nextTick, watch } from 'vue'
import { userLogger } from '../utils/userLogger'
import { activityTracker } from '../utils/activityTracker'
import Layout from '../components/Layout.vue'
import {
  Chart,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler,
  LineController,
  ScatterController,
  BarController
} from 'chart.js'

// 注册 Chart.js 组件（包括控制器、元素、插件）
Chart.register(
  LineController,
  ScatterController,
  BarController,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  Title,
  Tooltip,
  Legend,
  Filler
)

// 导入系统设置
const systemSettings = ref({
  general: {
    systemName: 'XM邮件管理系统',
    adminEmail: 'xm@localhost'
  }
})

// 批量创建用户计算属性（含密码必填）
const canBatchCreate = computed(() => {
  const hasPassword = batchPassword.value.trim().length > 0
  if (!hasPassword) return false
  if (batchCreateMode.value === 'list') {
    return batchUsernameList.value.trim().length > 0
  } else if (batchCreateMode.value === 'count') {
    return batchUsernamePrefix.value.trim().length > 0 && batchUserCount.value > 0
  }
  return false
})

// 分页计算属性
const paginationInfo = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value + 1
  const end = Math.min(currentPage.value * pageSize.value, totalUsers.value)
  return {
    start,
    end,
    total: totalUsers.value,
    current: currentPage.value,
    totalPages: totalPages.value
  }
})

// 分页按钮状态
const canGoPrevious = computed(() => currentPage.value > 1)
const canGoNext = computed(() => currentPage.value < totalPages.value)

// 获取本地域名
const getLocalDomain = async () => {
  // 优先从系统设置的邮件域名列表中获取（最可靠）
  const domains = systemSettings.value.mail?.domains || []
  if (domains.length > 0) {
    const domain = domains[0].name
    if (domain && domain !== 'localhost') {
      return domain
    }
  }
  
  // 如果邮件域名列表为空，尝试从管理员邮箱中提取域名
  const adminEmailValue = systemSettings.value.general?.adminEmail || adminEmail.value
  if (adminEmailValue && adminEmailValue.includes('@')) {
    const domain = adminEmailValue.split('@')[1]
    if (domain && domain !== 'localhost') {
      return domain
    }
  }
  
  // 尝试从DNS配置中获取域名
  const dnsDomain = systemSettings.value.dns?.bind?.domain || systemSettings.value.dns?.domain
  if (dnsDomain && dnsDomain !== 'localhost') {
    return dnsDomain
  }
  
  // 尝试从数据库中查询实际的域名（通过API获取域名列表）
  try {
    const response = await fetch('/api/system/domains', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.domains && Array.isArray(data.domains) && data.domains.length > 0) {
        // 找到第一个非localhost的域名
        const validDomain = data.domains.find((d: any) => {
          const domainName = typeof d === 'string' ? d : d.name
          return domainName && domainName !== 'localhost'
        })
        if (validDomain) {
          const domainName = typeof validDomain === 'string' ? validDomain : validDomain.name
          return domainName
        }
      }
    }
  } catch (error) {
    console.warn('查询邮件域名失败:', error)
  }
  
  // 如果所有方法都失败，尝试从xm用户的邮箱中提取
  try {
    const response = await fetch('/api/users', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.users && Array.isArray(data.users)) {
        // 查找xm用户的邮箱
        const xmUser = data.users.find((u: any) => u.username === 'xm')
        if (xmUser && xmUser.email && xmUser.email.includes('@')) {
          const domain = xmUser.email.split('@')[1]
          if (domain && domain !== 'localhost') {
            return domain
          }
        }
      }
    }
  } catch (error) {
    console.warn('查询用户邮箱失败:', error)
  }
  
  // 最后默认返回skills.com（根据用户提供的信息）
  return 'skills.com'
}

// 加载系统设置
const loadSystemSettings = async () => {
  try {
    const response = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 深度合并后端设置和默认设置
        systemSettings.value = {
          ...systemSettings.value,
          ...data.settings,
          general: {
            ...systemSettings.value.general,
            ...data.settings.general
          },
          mail: {
            ...systemSettings.value.mail,
            ...data.settings.mail
          },
          dns: {
            ...systemSettings.value.dns,
            ...data.settings.dns
          }
        }
        console.log('系统设置加载成功，管理员邮箱:', systemSettings.value.general?.adminEmail)
        console.log('系统设置加载成功，域名列表:', systemSettings.value.mail?.domains)
        
        // 加载系统设置后更新分页配置
        loadPaginationSettings()
      }
    }
  } catch (error) {
    console.error('加载系统设置失败:', error)
  }
}

// 打开批量创建对话框
function openBatchCreateDialog() {
  showBatchCreateDialog.value = true
  batchCreateMode.value = 'list'
  batchUsernameList.value = ''
  batchUsernamePrefix.value = ''
  batchUserCount.value = 1
  batchPassword.value = '' // 重置密码输入框，要求用户每次输入
  batchCreatePasswordError.value = ''
  batchCreateResults.value = []
  batchCreating.value = false
}

// 关闭批量创建对话框
function closeBatchCreateDialog() {
  showBatchCreateDialog.value = false
}

// 切换用户选择状态
function toggleUserSelection(userId: string) {
  if (selectedUsers.value.has(userId)) {
    selectedUsers.value.delete(userId)
  } else {
    selectedUsers.value.add(userId)
  }
}

// 全选/取消全选用户
function toggleSelectAllUsers() {
  if (selectedUsers.value.size === users.value.length) {
    selectedUsers.value.clear()
  } else {
    selectedUsers.value.clear()
    users.value.forEach(user => {
      if (user.username !== 'xm') { // 不选择管理员用户
        selectedUsers.value.add(user.id)
      }
    })
  }
}

// 打开批量删除对话框
function openBatchDeleteDialog() {
  if (selectedUsers.value.size === 0) {
    notice.value = '请先选择要删除的用户'
    noticeType.value = 'warning'
    return
  }
  showBatchDeleteDialog.value = true
}

// 关闭批量删除对话框
function closeBatchDeleteDialog() {
  showBatchDeleteDialog.value = false
}

// 执行批量删除用户
async function executeBatchDelete() {
  if (batchDeleting.value) return
  
  batchDeleting.value = true
  
  try {
    const selectedUserIds = Array.from(selectedUsers.value)
    const selectedUserList = users.value.filter(user => selectedUserIds.includes(user.id))
    
    let successCount = 0
    let failedCount = 0
    
    for (const user of selectedUserList) {
      try {
        const response = await axios.post('/api/ops', {
          action: 'user-del',
          params: {
            email: user.email
          }
        }, { headers: authHeader() })
        
        if (response.data.success) {
          successCount++
        } else {
          failedCount++
        }
      } catch (error) {
        console.error(`删除用户 ${user.username} 失败:`, error)
        failedCount++
      }
    }
    
    // 刷新用户列表
    await loadUsers()
    
    // 清空选择
    selectedUsers.value.clear()
    
    // 显示结果
    if (successCount > 0) {
      notice.value = `批量删除完成！成功删除 ${successCount} 个用户`
      if (failedCount > 0) {
        notice.value += `，${failedCount} 个用户删除失败`
      }
      noticeType.value = 'success'
    } else {
      notice.value = '批量删除失败，请检查用户权限'
      noticeType.value = 'error'
    }
    
  } catch (error) {
    console.error('批量删除用户失败:', error)
    notice.value = '批量删除失败：' + error.message
    noticeType.value = 'error'
  } finally {
    batchDeleting.value = false
    showBatchDeleteDialog.value = false
  }
}

// 分页相关函数
function updatePagination() {
  totalUsers.value = users.value.length
  totalPages.value = Math.ceil(totalUsers.value / pageSize.value)
  
  // 确保当前页不超过总页数
  if (currentPage.value > totalPages.value && totalPages.value > 0) {
    currentPage.value = totalPages.value
  }
  
  // 计算分页数据
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  paginatedUsers.value = users.value.slice(start, end)
}

function goToPage(page: number) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    updatePagination()
  }
}

function goToPreviousPage() {
  if (canGoPrevious.value) {
    goToPage(currentPage.value - 1)
  }
}

function goToNextPage() {
  if (canGoNext.value) {
    goToPage(currentPage.value + 1)
  }
}

function changePageSize(newSize: number) {
  pageSize.value = newSize
  currentPage.value = 1 // 重置到第一页
  updatePagination()
  
  // 同步到系统设置
  if (systemSettings.value.general) {
    systemSettings.value.general.userPageSize = newSize
  }
  
  // 保存到localStorage作为备用
  savePaginationSettings()
}

// 从系统设置加载分页配置
function loadPaginationSettings() {
  // 优先从系统设置获取分页配置
  if (systemSettings.value.general?.userPageSize) {
    pageSize.value = systemSettings.value.general.userPageSize
  } else {
    // 从localStorage获取分页配置作为备用
    const savedPageSize = localStorage.getItem('userPageSize')
    if (savedPageSize) {
      pageSize.value = parseInt(savedPageSize)
    }
  }
}

// 保存分页配置
function savePaginationSettings() {
  localStorage.setItem('userPageSize', pageSize.value.toString())
}

// 检查用户是否存在
async function checkUserExists(username: string): Promise<boolean> {
  try {
    // 直接查询数据库检查用户是否存在
    const response = await axios.post('/api/ops', {
      action: 'check-user-exists',
      params: {
        username: username
      }
    }, { headers: authHeader() })
    
    return response.data.success && response.data.exists
  } catch (error) {
    console.error(`检查用户 ${username} 是否存在失败:`, error)
    // 如果查询失败，假设用户不存在，允许创建
    return false
  }
}

// 执行批量创建用户
async function executeBatchCreate() {
  if (batchCreating.value) return
  
  // 先校验密码，未输入时在对话框内提醒，不发起请求
  const userPassword = batchPassword.value.trim()
  if (!userPassword) {
    notice.value = '请先输入用户密码'
    noticeType.value = 'error'
    batchCreatePasswordError.value = '请先输入用户密码'
    return
  }
  batchCreatePasswordError.value = ''
  
  batchCreating.value = true
  batchCreateResults.value = []
  
  try {
    let usernames: string[] = []
    
    if (batchCreateMode.value === 'list') {
      // 解析逗号分割的用户名列表
      usernames = batchUsernameList.value
        .split(',')
        .map(name => name.trim())
        .filter(name => name.length > 0)
    } else if (batchCreateMode.value === 'count') {
      // 生成带序号的用户名
      usernames = []
      for (let i = 1; i <= batchUserCount.value; i++) {
        const paddedNumber = i.toString().padStart(2, '0')
        usernames.push(`${batchUsernamePrefix.value}${paddedNumber}`)
      }
    }
    
    if (usernames.length === 0) {
      throw new Error('没有有效的用户名')
    }
    
    const localDomain = await getLocalDomain()
    console.log('批量创建用户使用的域名:', localDomain)

    // 批量创建用户
    for (const username of usernames) {
      try {
        const email = `${username}@${localDomain}`
        
        // 先检查用户是否已存在
        const userExists = await checkUserExists(username)
        if (userExists) {
          batchCreateResults.value.push({
            username: username,
            email: email,
            success: false,
            reason: '用户已存在'
          })
          continue
        }
        
        // 调用添加用户API
        const response = await axios.post('/api/ops', {
          action: 'app-register',
          params: {
            username: username,
            email: email,
            password: userPassword
          }
        }, { headers: authHeader() })
        
        if (response.data.success) {
          batchCreateResults.value.push({
            username: username,
            email: email,
            success: true
          })
        } else {
          // 提取详细的错误信息
          let errorMessage = '创建失败'
          if (response.data.error) {
            errorMessage = response.data.error
          } else if (response.data.message) {
            errorMessage = response.data.message
          }
          
          batchCreateResults.value.push({
            username: username,
            email: email,
            success: false,
            reason: errorMessage
          })
        }
      } catch (error: any) {
        console.error(`创建用户 ${username} 失败:`, error)
        
        // 提取详细的错误信息
        let errorMessage = 'API调用失败'
        if (error.response) {
          // 服务器返回了错误响应
          const errorData = error.response.data
          if (errorData?.error) {
            errorMessage = errorData.error
          } else if (errorData?.message) {
            errorMessage = errorData.message
          } else if (typeof errorData === 'string') {
            errorMessage = errorData
          } else {
            errorMessage = `HTTP ${error.response.status}: ${error.response.statusText || '请求失败'}`
          }
        } else if (error.message) {
          errorMessage = error.message
        }
        
        batchCreateResults.value.push({
          username: username,
          email: `${username}@${localDomain}`,
          success: false,
          reason: errorMessage
        })
      }
    }
    
    // 刷新用户列表
    await loadUsers()
    
    // 显示成功消息
    const successCount = batchCreateResults.value.filter(r => r.success).length
    const existingCount = batchCreateResults.value.filter(r => !r.success && r.reason === '用户已存在').length
    const failedCount = batchCreateResults.value.filter(r => !r.success && r.reason !== '用户已存在').length
    const totalCount = batchCreateResults.value.length
    
    if (successCount > 0) {
      let message = `批量创建完成！成功创建 ${successCount}/${totalCount} 个用户，密码已统一设置，请妥善保管并勿在公开场合展示`
      if (existingCount > 0) {
        message += `，跳过 ${existingCount} 个已存在用户`
      }
      if (failedCount > 0) {
        message += `，${failedCount} 个用户创建失败`
      }
      notice.value = message
      noticeType.value = 'success'
    } else if (existingCount > 0) {
      notice.value = `所有用户都已存在，共跳过 ${existingCount} 个用户`
      noticeType.value = 'warning'
    } else {
      notice.value = '批量创建失败，请检查用户名格式和网络连接'
      noticeType.value = 'error'
    }
    
  } catch (error) {
    console.error('批量创建用户失败:', error)
    notice.value = '批量创建失败：' + error.message
    noticeType.value = 'error'
  } finally {
    batchCreating.value = false
  }
}

// 图表相关状态
const trendChartRef = ref<HTMLCanvasElement | null>(null)
const frequencyChartRef = ref<HTMLCanvasElement | null>(null)
const trendChart = ref<Chart | null>(null)
const frequencyChart = ref<Chart | null>(null)
const trendPeriod = ref<'hour' | 'day' | 'week'>('day')
const frequencyGroupBy = ref<'user' | 'day'>('user')
const loadingTrends = ref(false)
const loadingFrequency = ref(false)
const trendDataEmpty = ref(false)
const frequencyDataEmpty = ref(false)
const chartRefreshInterval = ref<number | null>(null)

// 加载邮件发送趋势数据
async function loadSendingTrends() {
  if (!trendChartRef.value) {
    console.warn('趋势图表引用未准备好，延迟加载')
    setTimeout(() => loadSendingTrends(), 500)
    return
  }
  
  loadingTrends.value = true
  trendDataEmpty.value = false
  
  try {
    console.log('开始加载发送趋势数据，周期:', trendPeriod.value)
    const response = await axios.get('/api/mail/stats/sending-trends', {
      params: { period: trendPeriod.value },
      headers: authHeader()
    })
    
    console.log('发送趋势API响应:', response.data)
    
    const data = response.data.success && response.data.data ? response.data.data : []
    trendDataEmpty.value = data.length === 0
    
    console.log('解析后的数据:', data, '数据长度:', data.length)
    
    // 如果没有数据，创建空状态图表
    if (!data || data.length === 0) {
      console.log('没有数据，创建空状态图表')
      trendDataEmpty.value = true
      
      // 根据时间周期生成空标签
      let labels: string[] = []
      const now = new Date()
      
      if (trendPeriod.value === 'hour') {
        // 最近24小时
        for (let i = 23; i >= 0; i--) {
          const date = new Date(now.getTime() - i * 60 * 60 * 1000)
          labels.push(date.toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit' }))
        }
      } else if (trendPeriod.value === 'day') {
        // 最近30天
        for (let i = 29; i >= 0; i--) {
          const date = new Date(now.getTime() - i * 24 * 60 * 60 * 1000)
          labels.push(date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' }))
        }
      } else {
        // 最近12周
        for (let i = 11; i >= 0; i--) {
          const date = new Date(now.getTime() - i * 7 * 24 * 60 * 60 * 1000)
          const week = Math.ceil(date.getDate() / 7)
          labels.push(`${date.getFullYear()}-W${week}`)
        }
      }
      
      const emptyData = new Array(labels.length).fill(0)
      
      // 销毁旧图表
      if (trendChart.value) {
        trendChart.value.destroy()
        trendChart.value = null
      }
      
      // 确保 Canvas 没有被占用
      await nextTick()
      
      // 检查 Canvas 元素是否存在
      if (!trendChartRef.value) {
        console.error('Canvas 元素不存在，无法创建空状态图表')
        return
      }
      
      // 检查 Canvas 元素是否在 DOM 中
      if (!document.contains(trendChartRef.value)) {
        console.error('Canvas 元素不在 DOM 中，延迟创建空状态图表')
        setTimeout(() => loadTrendAnalysis(), 500)
        return
      }
      
      // 检查 Canvas 上下文是否可用
      try {
        const ctx = trendChartRef.value.getContext('2d')
        if (!ctx) {
          console.error('无法获取 Canvas 上下文，延迟创建空状态图表')
          setTimeout(() => loadTrendAnalysis(), 500)
          return
        }
      } catch (ctxError) {
        console.error('获取 Canvas 上下文失败:', ctxError)
        setTimeout(() => loadTrendAnalysis(), 500)
        return
      }
      
      // 创建空状态图表
      trendChart.value = new Chart(trendChartRef.value, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [
            {
              label: '邮件发送数量',
              data: emptyData,
              borderColor: 'rgb(200, 200, 200)',
              backgroundColor: 'rgba(200, 200, 200, 0.1)',
              fill: true,
              tension: 0.4,
              yAxisID: 'y',
              pointRadius: 0,
              pointHoverRadius: 0
            },
            {
              label: `发送频率 (${trendPeriod.value === 'hour' ? '封/小时' : '封/天'})`,
              data: emptyData,
              borderColor: 'rgb(220, 220, 220)',
              backgroundColor: 'rgba(220, 220, 220, 0.1)',
              fill: true,
              tension: 0.4,
              yAxisID: 'y1',
              pointRadius: 0,
              pointHoverRadius: 0
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            mode: 'index',
            intersect: false
          },
          plugins: {
            legend: {
              position: 'top',
            },
            title: {
              display: false
            },
            tooltip: {
              enabled: false
            }
          },
          scales: {
            x: {
              display: true,
              title: {
                display: true,
                text: trendPeriod.value === 'hour' ? '时间 (小时)' : trendPeriod.value === 'day' ? '日期' : '周'
              }
            },
            y: {
              type: 'linear',
              display: true,
              position: 'left',
              title: {
                display: true,
                text: '邮件数量 (封)'
              },
              min: 0,
              max: 10
            },
            y1: {
              type: 'linear',
              display: true,
              position: 'right',
              title: {
                display: true,
                text: `发送频率 (${trendPeriod.value === 'hour' ? '封/小时' : '封/天'})`
              },
              grid: {
                drawOnChartArea: false
              },
              min: 0,
              max: 1
            }
          }
        }
      })
    } else {
      console.log('有数据，开始创建图表，数据项:', data)
      trendDataEmpty.value = false  // 确保空数据标志为false，这样遮罩层不会显示
      
      const labels = data.map((item: any) => item.time_label || String(item.time_label))
      // 邮件数量必须是整数，确保不包含null或undefined
      const emailCounts = data.map((item: any) => {
        const count = Math.round(Number(item.email_count) || 0)
        return isNaN(count) ? 0 : count
      }).filter((val: any) => val !== null && val !== undefined)
      // 根据时间周期获取频率单位和数据，确保不包含null或undefined
      const frequencyUnit = data[0]?.frequency_unit || 'day'
      const frequencies = data.map((item: any) => {
        const freq = Number(item.frequency_per_period || item.frequency_per_hour) || 0
        return isNaN(freq) ? 0 : freq
      }).filter((val: any) => val !== null && val !== undefined)
      
      // 确保数组长度一致
      const minLength = Math.min(labels.length, emailCounts.length, frequencies.length)
      const validLabels = labels.slice(0, minLength)
      const validEmailCounts = emailCounts.slice(0, minLength)
      const validFrequencies = frequencies.slice(0, minLength)
      
      // 根据时间周期确定频率单位显示文本
      const frequencyLabel = trendPeriod.value === 'hour' ? '封/小时' : '封/天'
      
      console.log('处理后的数据:', { labels: validLabels, emailCounts: validEmailCounts, frequencies: validFrequencies, frequencyUnit, frequencyLabel })
      
      // 销毁旧图表
      if (trendChart.value) {
        console.log('销毁旧趋势图表')
        trendChart.value.destroy()
        trendChart.value = null
      }
      
      // 确保 Canvas 没有被占用
      await nextTick()
      
      // 再次检查 Canvas 元素是否存在
      if (!trendChartRef.value) {
        console.error('Canvas 元素不存在，无法创建图表')
        return
      }
      
      // 检查 Canvas 元素是否在 DOM 中
      if (!document.contains(trendChartRef.value)) {
        console.error('Canvas 元素不在 DOM 中，延迟创建图表')
        setTimeout(() => loadTrendAnalysis(), 500)
        return
      }
      
      // 检查 Canvas 上下文是否可用
      try {
        const ctx = trendChartRef.value.getContext('2d')
        if (!ctx) {
          console.error('无法获取 Canvas 上下文，延迟创建图表')
          setTimeout(() => loadTrendAnalysis(), 500)
          return
        }
      } catch (ctxError) {
        console.error('获取 Canvas 上下文失败:', ctxError)
        setTimeout(() => loadTrendAnalysis(), 500)
        return
      }
      
      console.log('创建新趋势图表，Canvas元素:', trendChartRef.value)
      console.log('数据详情:', { labels, emailCounts, frequencies })
      
      try {
        // 确保数据有效
        if (!validLabels || !validEmailCounts || !validFrequencies || 
            validLabels.length === 0 || validEmailCounts.length === 0 || validFrequencies.length === 0) {
          console.error('图表数据无效，无法创建图表')
          trendDataEmpty.value = true
          return
        }
        
        // 创建新图表
        trendChart.value = new Chart(trendChartRef.value, {
          type: 'line',
          data: {
            labels: validLabels,
            datasets: [
              {
                label: '邮件发送数量',
                data: validEmailCounts,
                borderColor: 'rgb(59, 130, 246)',
                backgroundColor: 'rgba(59, 130, 246, 0.1)',
                fill: true,
                tension: 0.4,
                yAxisID: 'y'
              },
              {
                label: `发送频率 (${frequencyLabel})`,
                data: validFrequencies,
                borderColor: 'rgb(168, 85, 247)',
                backgroundColor: 'rgba(168, 85, 247, 0.1)',
                fill: true,
                tension: 0.4,
                yAxisID: 'y1'
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
              mode: 'index',
              intersect: false
            },
            plugins: {
              legend: {
                position: 'top',
              },
              title: {
                display: false
              },
              tooltip: {
                callbacks: {
                  label: function(context) {
                    if (context.datasetIndex === 0) {
                      // 邮件数量显示为整数
                      return `邮件数量: ${Math.round(context.parsed.y)} 封`
                    } else {
                      // 发送频率根据时间周期显示不同单位
                      const unit = trendPeriod.value === 'hour' ? '封/小时' : '封/天'
                      const freq = context.parsed.y
                      let freqDisplay = ''
                      
                      // 格式化频率显示，使其更美观
                      if (freq < 0.01) {
                        freqDisplay = '< 0.01'
                      } else if (freq < 0.1) {
                        freqDisplay = freq.toFixed(2)
                      } else if (freq < 1) {
                        freqDisplay = freq.toFixed(2)
                      } else if (freq < 10) {
                        freqDisplay = freq.toFixed(1)
                      } else {
                        freqDisplay = Math.round(freq).toString()
                      }
                      
                      return `发送频率: ${freqDisplay} ${unit}`
                    }
                  }
                }
              }
            },
            scales: {
              x: {
                display: true,
                title: {
                  display: true,
                  text: trendPeriod.value === 'hour' ? '时间 (小时)' : trendPeriod.value === 'day' ? '日期' : '周'
                }
              },
            y: {
              type: 'linear',
              display: true,
              position: 'left',
              title: {
                display: true,
                text: '邮件数量 (封)'
              },
              ticks: {
                stepSize: 1,  // 邮件数量以1为单位
                callback: function(value) {
                  return Math.round(value as number)  // 确保显示为整数
                }
              }
            },
            y1: {
              type: 'linear',
              display: true,
              position: 'right',
              title: {
                display: true,
                text: `发送频率 (${frequencyLabel})`
              },
              grid: {
                drawOnChartArea: false
              },
              ticks: {
                callback: function(value) {
                  return value.toFixed(1)
                }
              }
            }
            }
          }
        })
        
        console.log('趋势图表创建成功')
      } catch (chartError: any) {
        console.error('创建趋势图表时出错:', chartError)
        console.error('错误详情:', chartError.message, chartError.stack)
        trendDataEmpty.value = true
        
        // 清理可能损坏的图表实例
        if (trendChart.value) {
          try {
            trendChart.value.destroy()
          } catch (destroyError) {
            console.error('销毁图表时出错:', destroyError)
          }
          trendChart.value = null
        }
        
        // 不抛出错误，避免中断执行
        console.warn('图表创建失败，将在下次刷新时重试')
      }
    }
  } catch (error: any) {
    console.error('加载发送趋势失败:', error)
    console.error('错误详情:', error.response?.data || error.message)
    trendDataEmpty.value = true
    
    // 即使出错也显示空状态图表
    if (trendChartRef.value) {
      const now = new Date()
      let labels: string[] = []
      
      if (trendPeriod.value === 'hour') {
        for (let i = 23; i >= 0; i--) {
          const date = new Date(now.getTime() - i * 60 * 60 * 1000)
          labels.push(date.toLocaleString('zh-CN', { month: '2-digit', day: '2-digit', hour: '2-digit' }))
        }
      } else if (trendPeriod.value === 'day') {
        for (let i = 29; i >= 0; i--) {
          const date = new Date(now.getTime() - i * 24 * 60 * 60 * 1000)
          labels.push(date.toLocaleDateString('zh-CN', { month: '2-digit', day: '2-digit' }))
        }
      } else {
        for (let i = 11; i >= 0; i--) {
          const date = new Date(now.getTime() - i * 7 * 24 * 60 * 60 * 1000)
          const week = Math.ceil(date.getDate() / 7)
          labels.push(`${date.getFullYear()}-W${week}`)
        }
      }
      
      const emptyData = new Array(labels.length).fill(0)
      
      if (trendChart.value) {
        trendChart.value.destroy()
        trendChart.value = null
      }
      
      // 确保 Canvas 没有被占用
      await nextTick()
      
      trendChart.value = new Chart(trendChartRef.value, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [
            {
              label: '邮件发送数量',
              data: emptyData,
              borderColor: 'rgb(200, 200, 200)',
              backgroundColor: 'rgba(200, 200, 200, 0.1)',
              fill: true,
              tension: 0.4,
              yAxisID: 'y',
              pointRadius: 0,
              pointHoverRadius: 0
            },
            {
              label: `发送频率 (${trendPeriod.value === 'hour' ? '封/小时' : '封/天'})`,
              data: emptyData,
              borderColor: 'rgb(220, 220, 220)',
              backgroundColor: 'rgba(220, 220, 220, 0.1)',
              fill: true,
              tension: 0.4,
              yAxisID: 'y1',
              pointRadius: 0,
              pointHoverRadius: 0
            }
          ]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          interaction: {
            mode: 'index',
            intersect: false
          },
          plugins: {
            legend: {
              position: 'top',
            },
            title: {
              display: false
            },
            tooltip: {
              enabled: false
            }
          },
          scales: {
            x: {
              display: true,
              title: {
                display: true,
                text: trendPeriod.value === 'hour' ? '时间 (小时)' : trendPeriod.value === 'day' ? '日期' : '周'
              }
            },
            y: {
              type: 'linear',
              display: true,
              position: 'left',
              title: {
                display: true,
                text: '邮件数量 (封)'
              },
              min: 0,
              max: 10
            },
            y1: {
              type: 'linear',
              display: true,
              position: 'right',
              title: {
                display: true,
                text: `发送频率 (${trendPeriod.value === 'hour' ? '封/小时' : '封/天'})`
              },
              grid: {
                drawOnChartArea: false
              },
              min: 0,
              max: 1,
              ticks: {
                callback: function(value) {
                  return value.toFixed(1)
                }
              }
            }
          }
        }
      })
    }
  } finally {
    loadingTrends.value = false
  }
}

// 加载发送频率分析数据
async function loadFrequencyAnalysis() {
  if (!frequencyChartRef.value) {
    console.warn('频率图表引用未准备好，延迟加载')
    setTimeout(() => loadFrequencyAnalysis(), 500)
    return
  }
  
  loadingFrequency.value = true
  frequencyDataEmpty.value = false
  
  try {
    console.log('开始加载频率分析数据，分组方式:', frequencyGroupBy.value)
    const response = await axios.get('/api/mail/stats/frequency-analysis', {
      params: { group_by: frequencyGroupBy.value },
      headers: authHeader()
    })
    
    console.log('频率分析API响应:', response.data)
    
    const data = response.data.success && response.data.data ? response.data.data : []
    frequencyDataEmpty.value = data.length === 0
    
    console.log('解析后的数据:', data, '数据长度:', data.length)
    
    // 如果没有数据，创建空状态图表
    if (!data || data.length === 0) {
      console.log('没有频率分析数据，创建空状态图表')
      frequencyDataEmpty.value = true
      
      // 销毁旧图表
      if (frequencyChart.value) {
        frequencyChart.value.destroy()
        frequencyChart.value = null
      }
      
      // 确保 Canvas 没有被占用
      await nextTick()
      
      // 创建空状态散点图
      frequencyChart.value = new Chart(frequencyChartRef.value, {
        type: 'scatter',
        data: {
          datasets: [{
            label: frequencyGroupBy.value === 'user' ? '用户发送行为' : '每日发送行为',
            data: [],
            backgroundColor: 'rgba(200, 200, 200, 0.3)',
            borderColor: 'rgb(200, 200, 200)',
            pointRadius: 0,
            pointHoverRadius: 0
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            },
            title: {
              display: false
            },
            tooltip: {
              enabled: false
            }
          },
          scales: {
            x: {
              type: 'linear',
              position: 'bottom',
              title: {
                display: true,
                text: '发送频率 (封/分钟)'
              },
              min: 0,
              max: 10
            },
            y: {
              title: {
                display: true,
                text: '邮件发送总量 (封)'
              },
              min: 0,
              max: 10
            }
          }
        }
      })
    } else {
      console.log('有频率分析数据，开始创建图表，数据项:', data)
      frequencyDataEmpty.value = false  // 确保空数据标志为false
      
      // 频率单位改为封/天，邮件数量必须是整数，确保不包含null或undefined
      const totals = data.map((item: any) => {
        const total = Math.round(parseFloat(item.total_emails) || 0)
        return isNaN(total) ? 0 : total
      }).filter((val: any) => val !== null && val !== undefined)
      // 频率显示优化：保留1位小数，但显示时更友好，确保不包含null或undefined
      const frequencies = data.map((item: any) => {
        const freq = parseFloat(item.frequency_per_day || item.frequency_per_minute) || 0
        return isNaN(freq) ? 0 : freq
      }).filter((val: any) => val !== null && val !== undefined)
      const labels = data.map((item: any) => {
        if (frequencyGroupBy.value === 'user') {
          // 优先显示用户显示名称，如果没有则显示邮箱
          return item.identifier || item.email || '未知用户'
        } else {
          // 按天显示日期
          return item.identifier || '未知日期'
        }
      }).filter((val: any) => val !== null && val !== undefined && val !== '')
      
      // 确保数组长度一致
      const minLength = Math.min(labels.length, totals.length, frequencies.length)
      const validLabels = labels.slice(0, minLength)
      const validTotals = totals.slice(0, minLength)
      const validFrequencies = frequencies.slice(0, minLength)
      
      console.log('处理后的频率分析数据:', { frequencies: validFrequencies, totals: validTotals, labels: validLabels })
      
      // 销毁旧图表
      if (frequencyChart.value) {
        console.log('销毁旧频率图表')
        frequencyChart.value.destroy()
        frequencyChart.value = null
      }
      
      // 确保 Canvas 没有被占用
      await nextTick()
      
      // 再次检查 Canvas 元素是否存在
      if (!frequencyChartRef.value) {
        console.error('Canvas 元素不存在，无法创建图表')
        return
      }
      
      // 检查 Canvas 元素是否在 DOM 中
      if (!document.contains(frequencyChartRef.value)) {
        console.error('Canvas 元素不在 DOM 中，延迟创建图表')
        setTimeout(() => loadFrequencyAnalysis(), 500)
        return
      }
      
      // 检查 Canvas 上下文是否可用
      try {
        const ctx = frequencyChartRef.value.getContext('2d')
        if (!ctx) {
          console.error('无法获取 Canvas 上下文，延迟创建图表')
          setTimeout(() => loadFrequencyAnalysis(), 500)
          return
        }
      } catch (ctxError) {
        console.error('获取 Canvas 上下文失败:', ctxError)
        setTimeout(() => loadFrequencyAnalysis(), 500)
        return
      }
      
      console.log('创建新频率图表，Canvas元素:', frequencyChartRef.value)
      console.log('数据详情:', { frequencies, totals, labels, data })
      
      // 保存数据引用用于tooltip
      const chartDataRef = data
      const groupByRef = frequencyGroupBy.value
      
      // 确保数据有效
      if (!validLabels || !validTotals || !validFrequencies || 
          validLabels.length === 0 || validTotals.length === 0 || validFrequencies.length === 0) {
        console.error('频率图表数据无效，无法创建图表')
        frequencyDataEmpty.value = true
        return
      }
      
      try {
        // 创建新图表 - 使用柱状图（混合图表：柱状图+折线图）
        // 注意：混合图表需要在数据集级别指定 type，主图表类型保持为 'bar'
        frequencyChart.value = new Chart(frequencyChartRef.value, {
          type: 'bar',
          data: {
            labels: validLabels,
            datasets: [
              {
                type: 'bar',
                label: frequencyGroupBy.value === 'user' ? '邮件发送总量' : '每日发送总量',
                data: validTotals,
                backgroundColor: 'rgba(168, 85, 247, 0.6)',
                borderColor: 'rgb(168, 85, 247)',
                borderWidth: 1,
                yAxisID: 'y'
              },
              {
                type: 'line',
                label: frequencyGroupBy.value === 'user' ? '平均发送频率' : '每日频率',
                data: validFrequencies,
                backgroundColor: 'rgba(59, 130, 246, 0.3)',
                borderColor: 'rgb(59, 130, 246)',
                borderWidth: 2,
                yAxisID: 'y1',
                pointRadius: 5,
                pointHoverRadius: 7,
                pointBackgroundColor: 'rgb(59, 130, 246)',
                pointBorderColor: '#fff',
                pointBorderWidth: 2,
                tension: 0.3,
                fill: false
              }
            ]
          },
          options: {
            responsive: true,
            maintainAspectRatio: false,
            interaction: {
              mode: 'index',
              intersect: false
            },
            plugins: {
              legend: {
                position: 'top',
              },
              title: {
                display: false
              },
              tooltip: {
                callbacks: {
                  title: function(context) {
                    const index = context[0].dataIndex
                    const item = chartDataRef[index]
                    if (groupByRef === 'user') {
                      const email = item?.email || ''
                      return email ? `${labels[index]} (${email})` : labels[index]
                    } else {
                      return labels[index]
                    }
                  },
                  label: function(context) {
                    const index = context.dataIndex
                    if (context.datasetIndex === 0) {
                      // 邮件总量 - 显示为整数
                      const total = Math.round(context.parsed.y)
                      return `发送总量: ${total} 封`
                    } else {
                      // 发送频率 - 优化显示格式，使其更美观
                      const freq = context.parsed.y
                      const total = totals[index]
                      let freqDisplay = ''
                      let freqDescription = ''
                      
                      // 格式化频率显示
                      if (freq < 0.01) {
                        freqDisplay = '< 0.01'
                        freqDescription = '极低'
                      } else if (freq < 0.1) {
                        freqDisplay = freq.toFixed(2)
                        freqDescription = '很低'
                      } else if (freq < 1) {
                        freqDisplay = freq.toFixed(1)
                        freqDescription = '较低'
                      } else if (freq < 10) {
                        freqDisplay = freq.toFixed(1)
                        freqDescription = '正常'
                      } else {
                        freqDisplay = Math.round(freq).toString()
                        freqDescription = '较高'
                      }
                      
                      // 如果总量和频率相同（按天统计时），只显示总量
                      if (groupByRef === 'day' && Math.abs(total - freq) < 0.01) {
                        return `发送总量: ${total} 封`
                      }
                      
                      return `平均发送频率: ${freqDisplay} 封/天`
                    }
                  }
                }
              }
            },
            scales: {
              x: {
                display: true,
                title: {
                  display: true,
                  text: frequencyGroupBy.value === 'user' ? '用户' : '日期'
                },
                ticks: {
                  maxRotation: frequencyGroupBy.value === 'user' ? 45 : 0,
                  minRotation: frequencyGroupBy.value === 'user' ? 45 : 0
                }
              },
              y: {
                type: 'linear',
                display: true,
                position: 'left',
                title: {
                  display: true,
                  text: '邮件发送总量 (封)'
                },
                ticks: {
                  stepSize: 1,
                  callback: function(value) {
                    return Math.round(value as number)
                  }
                }
              },
              y1: {
                type: 'linear',
                display: true,
                position: 'right',
                title: {
                  display: true,
                  text: '平均发送频率 (封/天)'
                },
                grid: {
                  drawOnChartArea: false
                },
                ticks: {
                  callback: function(value) {
                    const num = value as number
                    // 优化刻度显示，使其更美观
                    if (num < 0.01) {
                      return '< 0.01'
                    } else if (num < 0.1) {
                      return num.toFixed(2)
                    } else if (num < 1) {
                      return num.toFixed(1)
                    } else if (num < 10) {
                      return num.toFixed(1)
                    } else {
                      return Math.round(num).toString()
                    }
                  },
                  stepSize: function(context) {
                    // 根据数据范围动态调整步长
                    const max = context.chart.scales.y1.max
                    if (max < 1) return 0.1
                    if (max < 5) return 0.5
                    if (max < 10) return 1
                    return 2
                  }
                }
              }
            }
          }
      })
      
      console.log('频率图表创建成功')
    } catch (chartError: any) {
      console.error('创建频率图表时出错:', chartError)
      console.error('错误详情:', chartError.message, chartError.stack)
      frequencyDataEmpty.value = true
      
      // 清理可能损坏的图表实例
      if (frequencyChart.value) {
        try {
          frequencyChart.value.destroy()
        } catch (destroyError) {
          console.error('销毁图表时出错:', destroyError)
        }
        frequencyChart.value = null
      }
      
      // 不抛出错误，避免中断执行
      console.warn('图表创建失败，将在下次刷新时重试')
    }
    }
  } catch (error: any) {
    console.error('加载频率分析失败:', error)
    console.error('错误详情:', error.response?.data || error.message)
    frequencyDataEmpty.value = true
    
    // 即使出错也显示空状态图表
    if (frequencyChartRef.value) {
      if (frequencyChart.value) {
        frequencyChart.value.destroy()
        frequencyChart.value = null
      }
      
      // 确保 Canvas 没有被占用
      await nextTick()
      
      frequencyChart.value = new Chart(frequencyChartRef.value, {
        type: 'scatter',
        data: {
          datasets: [{
            label: frequencyGroupBy.value === 'user' ? '用户发送行为' : '每日发送行为',
            data: [],
            backgroundColor: 'rgba(200, 200, 200, 0.3)',
            borderColor: 'rgb(200, 200, 200)',
            pointRadius: 0,
            pointHoverRadius: 0
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            legend: {
              display: false
            },
            title: {
              display: false
            },
            tooltip: {
              enabled: false
            }
          },
          scales: {
            x: {
              type: 'linear',
              position: 'bottom',
              title: {
                display: true,
                text: '发送频率 (封/分钟)'
              },
              min: 0,
              max: 10
            },
            y: {
              title: {
                display: true,
                text: '邮件发送总量 (封)'
              },
              min: 0,
              max: 10
            }
          }
        }
      })
    }
  } finally {
    loadingFrequency.value = false
  }
}

// 页面加载时自动加载用户列表
onMounted(async () => {
  // 注意：已移除HTTP到HTTPS自动重定向逻辑
  // HTTP跳转HTTPS应该由用户通过前端"启用HTTP跳转HTTPS"按钮来配置
  // 或者通过Apache配置来实现，而不是在前端代码中自动跳转
  // 这样可以确保用户有完全的控制权，默认不跳转
  
  // 页面访问日志记录
  userLogger.logPageView('/dashboard')
  loadPaginationSettings() // 加载分页设置
  loadUsers()
  loadSystemSettings() // 加载系统设置以获取域名信息
  
  // 等待DOM渲染完成后初始化图表
  await nextTick()
  
  // 确保图表容器已渲染
  const initCharts = () => {
    if (trendChartRef.value && frequencyChartRef.value) {
      console.log('图表容器已准备好，开始加载数据')
      loadSendingTrends()
      loadFrequencyAnalysis()
      
      // 设置定时刷新（每30秒刷新一次）
      chartRefreshInterval.value = window.setInterval(() => {
        console.log('定时刷新图表数据')
        loadSendingTrends()
        loadFrequencyAnalysis()
      }, 30000)
    } else {
      console.log('图表容器未准备好，500ms后重试')
      setTimeout(initCharts, 500)
    }
  }
  
  setTimeout(initCharts, 500)
})

// 组件卸载时销毁图表和定时器
onUnmounted(() => {
  if (chartRefreshInterval.value) {
    clearInterval(chartRefreshInterval.value)
    chartRefreshInterval.value = null
  }
  if (trendChart.value) {
    trendChart.value.destroy()
  }
  if (frequencyChart.value) {
    frequencyChart.value.destroy()
  }
})

const opId = ref('')
const logs = ref('')
const domain = ref('')
const username = ref('')
const email = ref('')
const password = ref('')
const delEmail = ref('')
const loading = ref(false)
const error = ref('')
const status = ref<'running'|'success'|'failed'|''>('')
const notice = ref('')
const noticeType = ref<'success'|'error'|'warning'|'info'>('info')

// 用户管理相关数据
const users = ref<Array<{id: number, username: string, email: string, created_at: string}>>([])
const loadingUsers = ref(false)

// 批量创建用户相关数据
const showBatchCreateDialog = ref(false)
const batchCreateMode = ref<'list' | 'count'>('list') // 'list' 或 'count'
const batchUsernameList = ref('') // 逗号分割的用户名列表
const batchUsernamePrefix = ref('') // 用户名前缀
const batchUserCount = ref(1) // 创建数量
const batchCreateResults = ref<Array<{username: string, email: string, success: boolean, reason?: string}>>([])
const batchCreating = ref(false)
const batchPassword = ref('') // 批量创建用户密码（必填，不设默认值）
const batchCreatePasswordError = ref('') // 点击创建时未填密码的提示

// 批量删除用户状态
const selectedUsers = ref<Set<string>>(new Set()) // 选中的用户ID集合
const showBatchDeleteDialog = ref(false) // 批量删除对话框
const batchDeleting = ref(false) // 批量删除进行中

// 用户列表分页状态
const currentPage = ref(1) // 当前页码
const pageSize = ref(10) // 每页显示数量
const totalUsers = ref(0) // 用户总数
const totalPages = ref(0) // 总页数
const paginatedUsers = ref<any[]>([]) // 分页后的用户列表

// 安装服务对话框状态
const showInstallDialog = ref(false)
const selectedServices = ref<string[]>([])

// 操作日志对话框状态
const showOperationLog = ref(false)

// 服务管理对话框状态
const showServiceManagementDialog = ref(false)
const selectedRestartServices = ref<string[]>([])
const serviceAction = ref<'restart' | 'stop'>('restart')

// 环境检查对话框状态
const showEnvironmentCheckDialog = ref(false)

// 配置服务对话框状态
const showConfigDialog = ref(false)
const configStep = ref(1) // 1: 输入域名, 2: 确认, 3: 执行
const configDomain = ref('')
const dnsType = ref('bind')
const configType = ref('system') // 'system' 或 'dns'
const systemName = ref('XM邮件管理系统')
const adminEmail = ref('xm@localhost')

// 备份管理对话框状态
const showBackupManagementDialog = ref(false)
const backupTab = ref('full') // 'full' 或 'scheduled'

// 定时备份对话框状态（保留以兼容旧代码）
const showBackupDialog = ref(false)
const backupInterval = ref('7') // 默认每周备份
const customDays = ref(7)
const backupDatabase = ref(true)
const backupConfig = ref(true)
const backupMaildir = ref(true)
const retentionDays = ref(7)

// 自定义时间设置
const customTimeEnabled = ref(false)
const customHour = ref(2) // 默认凌晨2点
const customMinute = ref(0) // 默认0分
const customSecond = ref(0) // 默认0秒

// 证书申请对话框状态
const showCertDialog = ref(false)
const certDomain = ref('')
const certCountry = ref('CN')
const certState = ref('Beijing')
const certCity = ref('Beijing')
const certOrganization = ref('skills')
const certUnit = ref('system')
const certCommonName = ref('') // 服务器证书通用名称
const certEmail = ref('')
const certValidity = ref(1825) // 5年
const certSAN = ref('') // 主题备用名称

// CA证书信息
const caCountry = ref('CN')
const caState = ref('Beijing')
const caCity = ref('Beijing')
const caOrganization = ref('skills')
const caUnit = ref('system')
const caCommonName = ref('CA Server')
const caEmail = ref('')
const caValidity = ref(10950) // 30年

// 服务状态对话框状态
const showServiceStatusDialog = ref(false)
const serviceStatusLoading = ref(false)
const serviceStatuses = ref({})
const systemInfo = ref({})

// 垃圾邮件过滤对话框状态
const showSpamFilterDialog = ref(false)
const spamKeywords = ref<Array<{text: string, lang: string}>>([])
const spamDomains = ref<string[]>([])
const newSpamKeyword = ref('')
const newSpamKeywordLang = ref('cn')
const newSpamDomain = ref('')
const spamFilterSaving = ref(false)
const spamFilterConfig = ref({
  minBodyLines: 0,
  maxCapsRatio: 0.8,
  maxExclamation: 6,
  maxSpecialChars: 8
})
const refreshInterval = ref<number | null>(null)

// 广播对话框状态
const showBroadcastDialog = ref(false)
const broadcastMessage = ref('')
const currentBroadcast = ref('')
const broadcastSaving = ref(false)
const showClearBroadcastConfirm = ref(false)

// SSL管理对话框状态
const showSslManagementDialog = ref(false)
const sslTab = ref('domains') // 'domains', 'certificates', 'upload'
const sslDomains = ref<any[]>([])
const availableCertificates = ref<any[]>([])

// 检查是否有已配置SSL的域名
const hasConfiguredSslDomains = computed(() => {
  return sslDomains.value.some(domain => domain.sslConfigured && domain.certExists)
})

// 过滤后的证书列表（排除chain类型证书，用于域名绑定）
const availableCertificatesForBinding = computed(() => {
  return availableCertificates.value.filter(cert => {
    const certName = cert.name?.toLowerCase() || ''
    // 排除包含chain、ca-bundle、intermediate等关键词的证书
    return !certName.includes('chain') && 
           !certName.includes('ca-bundle') && 
           !certName.includes('intermediate') &&
           !certName.includes('_chain') &&
           !certName.includes('-chain')
  })
})
const showAddDomainForm = ref(false)
const newSslDomain = ref('')
const newSslDomainCert = ref('')
const sslDomainAdding = ref(false)
const sslEnabled = ref(false)
const sslEnabling = ref(false)
const selectedSslDomain = ref('')
const httpRedirectEnabling = ref(false)
const httpRedirectDisabling = ref(false)
const httpRedirectEnabled = ref(false) // 初始状态为false，需要用户手动启用
const showEditCertDialog = ref(false)
const editingDomainCert = ref<any>(null)
const editingCertName = ref('')

// 证书详情对话框
const showCertDetailsDialog = ref(false)
const certDetails = ref<any>(null)
const certDetailsLoading = ref(false)

// 证书上传相关状态
const certFile = ref<File | null>(null)
const keyFile = ref<File | null>(null)
const uploadCertName = ref('')
const certUploading = ref(false)

// 批量证书上传相关状态
interface CertificateUploadItem {
  certFile: File | null
  keyFile: File | null
  chainFile: File | null
  certName: string
  domainName: string // 自动识别的域名
  id: string
}
const certificateUploadList = ref<CertificateUploadItem[]>([])
const batchCertUploading = ref(false)
const isDragging = ref(false)
const fileInputRef = ref<HTMLInputElement | null>(null)


function authHeader() {
  const token = sessionStorage.getItem('apiAuth') || ''
  console.log('认证头信息:', { token: token ? '存在' : '不存在', length: token.length })
  return { Authorization: `Basic ${token}` }
}

// 不带轮询的API调用函数，用于批量安装
async function callWithoutPolling(action: string, params?: any): Promise<{ success: boolean, opId?: string }> {
  try {
    const { data } = await axios.post('/api/ops', { action, params }, { headers: authHeader() })

    if (!data.opId) {
      return { success: false }
    }

    // 等待脚本执行完成，安装操作等待更长时间
    const isInstallAction = action.startsWith('install-')
    // 安全加固操作需要3分钟超时，其他安装操作2分钟，其他操作30秒
    let maxWaitTime = 30000 // 默认30秒
    if (isInstallAction) {
      if (action === 'install-security') {
        maxWaitTime = 200000 // 安全加固等待200秒（3分20秒），留出缓冲时间
      } else {
        maxWaitTime = 120000 // 其他安装操作等待2分钟
      }
    }
    const checkInterval = 2000 // 2秒检查一次，减少API调用频率
    let waitTime = 0

    console.log(`开始等待操作 ${action} 完成，最多等待 ${maxWaitTime/1000} 秒`)

    while (waitTime < maxWaitTime) {
      await new Promise(resolve => setTimeout(resolve, checkInterval))
      waitTime += checkInterval

      try {
        const logRes = await axios.get(`/api/ops/${data.opId}/log`, { headers: authHeader() })
        const logContent = logRes.data || ''

        // 检查是否完成
        if (logContent.includes('OPERATION_END')) {
          const exitCodeMatch = logContent.match(/Exit code: (\d+)/)
          if (exitCodeMatch) {
            const exitCode = parseInt(exitCodeMatch[1])
            console.log(`操作 ${action} 完成，退出码: ${exitCode}`)
            // 退出码为0表示成功
            if (exitCode === 0) {
              return { success: true, opId: data.opId }
            }
            // 退出码非0，但检查是否有成功关键词（某些脚本可能返回非0但实际成功）
            const hasSuccessKeyword = logContent.includes('脚本执行完成') ||
                                     logContent.includes('安装完成') ||
                                     logContent.includes('配置完成') ||
                                     logContent.includes('安全加固基础配置完成') ||
                                     logContent.includes('安装成功') ||
                                     logContent.includes('配置成功')
            if (hasSuccessKeyword) {
              console.log(`操作 ${action} 退出码非0但检测到成功关键词，认为成功`)
              return { success: true, opId: data.opId }
            }
            return { success: false, opId: data.opId }
          }

          // 如果没有找到退出码，但包含成功关键词，也认为是成功
          const isSuccess = logContent.includes('脚本执行完成') ||
                           logContent.includes('安装完成') ||
                           logContent.includes('配置完成') ||
                           logContent.includes('安全加固基础配置完成') ||
                           logContent.includes('安装成功') ||
                           logContent.includes('配置成功')
          if (isSuccess) {
            console.log(`操作 ${action} 完成，检测到成功关键词`)
            return { success: true, opId: data.opId }
          }
        }

        // 检查是否有明显的成功标记（即使还没有OPERATION_END）
        if (logContent.includes('脚本执行完成') ||
            logContent.includes('安装完成') ||
            logContent.includes('配置完成') ||
            logContent.includes('安全加固基础配置完成') ||
            logContent.includes('安装成功') ||
            logContent.includes('配置成功')) {
          console.log(`操作 ${action} 检测到成功关键词，提前返回成功`)
          return { success: true, opId: data.opId }
        }

        // 检查是否有明显的失败标记
        if (logContent.includes('Exit code: 1') ||
            logContent.includes('Exit code: 2') ||
            logContent.includes('脚本执行失败') ||
            logContent.includes('安装失败') ||
            logContent.includes('配置失败')) {
          console.log(`操作 ${action} 检测到失败关键词`)
          return { success: false, opId: data.opId }
        }

        // 记录进度
        if (waitTime % 10000 === 0) { // 每10秒记录一次
          console.log(`等待操作 ${action} 中... 已等待 ${waitTime/1000} 秒`)
        }

      } catch (logError) {
        console.error('获取日志失败:', logError)
        // 继续等待，不立即返回失败
      }
    }

    // 超时，记录详细信息并返回失败
    console.warn(`操作 ${action} 超时（${maxWaitTime/1000}秒）`)

    // 即使超时，也尝试最后一次检查结果
    try {
      const logRes = await axios.get(`/api/ops/${data.opId}/log`, { headers: authHeader() })
      const logContent = logRes.data || ''
      // 检查退出码为0
      if (logContent.includes('OPERATION_END') && logContent.includes('Exit code: 0')) {
        console.log(`超时后检查发现操作 ${action} 实际成功（退出码0）`)
        return { success: true, opId: data.opId }
      }
      // 检查成功关键词（即使退出码不是0，也可能成功）
      if (logContent.includes('安全加固基础配置完成') ||
          logContent.includes('安装完成') ||
          logContent.includes('配置完成') ||
          logContent.includes('安装成功') ||
          logContent.includes('配置成功')) {
        console.log(`超时后检查发现操作 ${action} 实际成功（成功关键词）`)
        return { success: true, opId: data.opId }
      }
    } catch (finalCheckError) {
      console.error('超时后的最终检查也失败:', finalCheckError)
    }

    return { success: false, opId: data.opId }

  } catch (err: any) {
    console.error('API调用失败:', err)
    return { success: false }
  }
}

// 环境检查函数（简化版本，只执行环境检查）
async function callEnvironmentCheck(): Promise<void> {
  try {
    console.log('callEnvironmentCheck: 开始环境检查')
    
    // 关闭环境检查对话框
    closeEnvironmentCheckDialog()
    
    // 显示操作日志对话框
    showOperationLog.value = true
    loading.value = true
    error.value = ''
    opId.value = ''
    status.value = ''
    
    // 设置初始日志（call函数会保留已有的日志内容）
    logs.value = '正在执行环境检查...\n'
    console.log('callEnvironmentCheck: 开始执行环境检查')
    
    // 调用check操作，call函数会设置opId并开始轮询日志
    const checkResult = await call('check')
    console.log('callEnvironmentCheck: 环境检查结果:', checkResult)
    if (!checkResult.success) {
      throw new Error('环境检查失败')
    }

    console.log('callEnvironmentCheck: 环境检查完成')
  } catch (err: any) {
    console.error('环境检查失败:', err)
    error.value = err.response?.data?.error || err.message || '环境检查失败'
    status.value = 'error'
    loading.value = false
    if (logs.value) {
      logs.value += `\n❌ 环境检查失败: ${error.value}\n`
    } else {
      logs.value = `❌ 环境检查失败: ${error.value}\n`
    }
  }
}

async function call(action: string, params?: any): Promise<{ success: boolean, opId?: string }> {
  try {
    // 只在没有设置初始状态时才设置
    if (!opId.value) {
      loading.value = true
      error.value = ''
      opId.value = ''
      // 保留已有的日志内容，如果没有则初始化为空
      if (!logs.value) {
        logs.value = ''
      }
      status.value = ''
    }
    
    const { data } = await axios.post('/api/ops', { action, params }, { headers: authHeader() })
    opId.value = data.opId
    // 追加"执行中..."而不是覆盖，保留已有的日志内容
    if (logs.value && !logs.value.includes('执行中...')) {
      logs.value += '\n执行中...\n'
    } else if (!logs.value) {
      logs.value = '执行中...'
    }
    status.value = 'running'
    
    // 等待操作完成并返回结果
    return new Promise((resolve) => {
      // 开始轮询日志，统一轮询机制
      let pollCount = 0
      const pollInterval = setInterval(async () => {
        if (!opId.value) {
          clearInterval(pollInterval)
          return
        }
        pollCount++
        
        try {
          await fetchLog()
        } catch (err) {
          console.error('轮询过程中获取日志失败:', err)
          // 不要中断轮询，继续尝试
        }
        
        // 检查是否完成
        if (status.value === 'success' || status.value === 'failed') {
          clearInterval(pollInterval)
          resolve({ 
            success: status.value === 'success', 
            opId: opId.value 
          })
          return
        }
        
        // 如果轮询超过120次（60秒）还没有结果，停止轮询
        if (pollCount > 120) {
          clearInterval(pollInterval)
          if (loading.value) {
            loading.value = false
          }
          if (logs.value === '等待脚本执行...' || logs.value === '等待日志文件生成...') {
            logs.value += '\n[警告] 操作超时，请检查系统状态'
          }
          resolve({ success: false, opId: opId.value })
        }
      }, 500)
    })
    
  } catch (err: any) {
    error.value = err.response?.data?.error || err.message || '操作失败'
    logs.value = `错误: ${error.value}`
    console.error('API调用失败:', err)
    loading.value = false
    
    // 如果是认证错误，不要自动跳转，让用户手动处理
    if (err.response?.status === 401) {
      error.value = '认证失败，请检查登录状态'
      logs.value = '认证失败，请重新登录'
    }
    
    return { success: false }
  }
}

async function fetchLog() {
  if (!opId.value) return
  try {
    console.log('fetchLog: 获取日志，OpID:', opId.value)
    const res = await axios.get(`/api/ops/${opId.value}/log`, { headers: authHeader() })
    if (res.data && res.data.trim()) {
      logs.value = res.data
      console.log('fetchLog: 日志内容长度:', res.data.length)
      // 基于 OPERATION_END 退出码判定状态
      const m = res.data.match(/OPERATION_END\] Exit code:\s*(\d+)/)
      if (m) {
        const code = parseInt(m[1] || '1', 10)
        console.log('fetchLog: 检测到操作结束，退出码:', code)
        status.value = code === 0 ? 'success' : 'failed'
        loading.value = false
      }
      // 若无 OPERATION_END，但检测到明显完成标记，则仅结束加载（状态保持进行中或成功提示）
      if (!m && (
          res.data.includes('脚本执行完成') ||
          res.data.includes('环境检查完成') ||
          res.data.includes('健康检查通过') ||
          res.data.includes('健康检查发现问题') ||
          res.data.includes('安装完成') ||
          res.data.includes('配置完成') ||
          res.data.includes('服务重启完成') ||
          res.data.includes('系统健康状态良好') ||
          res.data.includes('=== 环境检查完成 ===')
        )) {
        console.log('fetchLog: 检测到完成标记')
        loading.value = false
        status.value = 'success'
      }
    } else {
      logs.value = '等待脚本执行...'
    }
  } catch (err: any) {
    console.error('fetchLog: 获取日志失败:', err)
    if (err.response?.status === 404) {
      logs.value = '等待日志文件生成...'
    } else if (err.response?.status === 401) {
      console.error('认证失败，获取日志失败:', err)
      logs.value += `\n[错误] 认证失败，请检查登录状态`
      // 不要自动跳转，让用户手动处理
    } else {
      console.error('获取日志失败:', err)
      logs.value += `\n[错误] 获取日志失败: ${err.message}`
    }
  }
}

// 加载用户列表
async function loadUsers() {
  try {
    loadingUsers.value = true
    console.log('开始加载用户列表...')
    console.log('当前用户数据:', users.value)
    const response = await axios.post('/api/ops', {
      action: 'query-users'
    }, { headers: authHeader() })
    
    console.log('API响应:', response.data)
    console.log('response.data.success:', response.data.success)
    console.log('response.data.opId:', response.data.opId)
    
    if (response.data.success) {
      // 检查是否直接返回了用户数据
      if (response.data.users && Array.isArray(response.data.users)) {
        console.log('直接获取到用户数据:', response.data.users)
        users.value = response.data.users
        console.log('更新后的用户数据:', users.value)
      } else {
        // 如果没有直接返回用户数据，使用轮询方式
        const opId = response.data.opId
        console.log('opId存在:', !!opId)
        if (opId) {
          console.log('开始轮询用户数据，OpID:', opId)
          try {
            console.log('准备调用 pollForUsers 函数')
            // 轮询日志文件，查找用户数据
            await pollForUsers(opId)
            console.log('pollForUsers 函数调用完成，当前用户数据:', users.value)
          } catch (pollError) {
            console.error('pollForUsers 函数调用失败:', pollError)
            console.error('错误详情:', pollError.message)
            console.error('错误堆栈:', pollError.stack)
            // 确保users.value不为undefined
            if (!users.value) {
              users.value = []
            }
          }
        }
      }
    } else {
      console.error('API请求失败，response.data.success为false')
      console.error('错误信息:', response.data.error)
      console.error('完整响应:', response.data)
    }
  } catch (error) {
    console.error('loadUsers函数执行失败:', error)
    console.error('错误类型:', error.constructor.name)
    console.error('错误消息:', error.message)
    console.error('错误堆栈:', error.stack)
  } finally {
    loadingUsers.value = false
    // 更新分页信息
    updatePagination()
  }
}

// 轮询日志文件，查找用户数据
async function pollForUsers(opId: string) {
  console.log('pollForUsers 函数开始执行，OpID:', opId)
  const maxAttempts = 30 // 最多轮询30次
  let attempts = 0
  
  console.log('开始轮询循环，最大尝试次数:', maxAttempts)
  
  while (attempts < maxAttempts) {
    try {
      console.log(`开始轮询第${attempts + 1}次，OpID: ${opId}`)
      const response = await axios.get(`/api/ops/${opId}/log`, { headers: authHeader() })
      const logContent = response.data
      
      console.log(`轮询第${attempts + 1}次，日志内容:`, logContent)
      
      // 查找JSON_OUTPUT行
      const lines = logContent.split('\n')
      for (const line of lines) {
        if (line.includes('[JSON_OUTPUT]')) {
          console.log('找到JSON_OUTPUT行:', line)
          try {
            // 使用更简单的方法：直接查找JSON_OUTPUT后的内容
            const jsonStart = line.indexOf('[JSON_OUTPUT]')
            if (jsonStart !== -1) {
              const jsonContent = line.substring(jsonStart + '[JSON_OUTPUT]'.length).trim()
              console.log('JSON内容:', jsonContent)
              const data = JSON.parse(jsonContent)
              console.log('解析后的数据:', data)
              if (data.success && data.users) {
                console.log('解析到的用户数据:', data.users)
                console.log('用户数据长度:', data.users.length)
                users.value = data.users
                console.log('更新后的users.value:', users.value)
                return
              }
            }
          } catch (e) {
            console.error('解析用户数据失败:', e)
          }
        }
      }
      
      // 如果找到操作结束标记，停止轮询
      if (logContent.includes('[OPERATION_END]')) {
        console.log('找到操作结束标记，停止轮询')
        break
      }
      
      attempts++
      await new Promise(resolve => setTimeout(resolve, 1000)) // 等待1秒
    } catch (error) {
      console.error('轮询用户数据失败:', error)
      break
    }
  }
  
  // 如果轮询结束但没有找到用户数据，显示警告
  if (users.value.length === 0) {
    console.warn('轮询完成但未找到用户数据')
    // 确保users.value不为undefined
    if (!users.value) {
      users.value = []
    }
  }
  
  console.log('pollForUsers 函数执行完成，最终用户数据:', users.value)
}

// 密码提示和错误状态
const passwordHint = ref('')
const passwordError = ref('')
const addUserError = ref('')
const addUserSuccess = ref('')

// 验证密码并更新提示
async function validatePassword() {
  passwordError.value = ''
  passwordHint.value = ''
  
  if (!password.value) {
    return
  }
  
  try {
    // 从系统设置中获取密码要求
    const settingsRes = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (settingsRes.ok) {
      const settingsData = await settingsRes.json()
      if (settingsData.success && settingsData.settings?.security) {
        const security = settingsData.settings.security
        const minLength = security.passwordMinLength || 8
        const requireSpecialChars = security.requireSpecialChars || false
        
        // 构建密码提示
        let hint = `密码长度至少需要${minLength}个字符`
        if (requireSpecialChars) {
          hint += '，必须包含大小写字母、数字和特殊字符'
        }
        passwordHint.value = hint
        
        // 验证密码长度
        if (password.value.length < minLength) {
          passwordError.value = `密码长度至少需要${minLength}个字符`
          return
        }
        
        // 如果要求特殊字符，验证密码复杂度
        if (requireSpecialChars) {
          const hasUpperCase = /[A-Z]/.test(password.value)
          const hasLowerCase = /[a-z]/.test(password.value)
          const hasNumber = /[0-9]/.test(password.value)
          const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password.value)
          
          if (!hasUpperCase || !hasLowerCase || !hasNumber || !hasSpecialChar) {
            const missingParts: string[] = []
            if (!hasUpperCase) missingParts.push('大写字母')
            if (!hasLowerCase) missingParts.push('小写字母')
            if (!hasNumber) missingParts.push('数字')
            if (!hasSpecialChar) missingParts.push('特殊字符')
            passwordError.value = `密码不符合要求：缺少${missingParts.join('、')}`
            return
          }
        }
      }
    }
  } catch (e) {
    // 如果获取系统设置失败，使用默认值
    if (password.value.length < 8) {
      passwordHint.value = '密码长度至少需要8个字符'
      passwordError.value = '密码长度至少需要8个字符'
    } else {
      passwordHint.value = '密码长度至少需要8个字符'
    }
  }
}

// 添加用户
async function addUser() {
  // 清除之前的错误和成功消息
  addUserError.value = ''
  addUserSuccess.value = ''
  
  if (!username.value || !email.value || !password.value) {
    addUserError.value = '请填写用户名、邮箱和密码'
    return
  }
  
  // 验证密码
  if (passwordError.value) {
    addUserError.value = passwordError.value
    return
  }
  
  try {
    loading.value = true
    
    console.log('添加用户请求参数:', { 
      action: 'app-register', 
      username: username.value, 
      email: email.value, 
      password: password.value 
    })
    
    const response = await axios.post('/api/ops', {
      action: 'app-register',
      username: username.value,
      email: email.value,
      password: password.value
    }, { headers: authHeader() })
    
    console.log('添加用户API响应:', response.data)
    
    if (response.data.success) {
      // 显示成功消息
      addUserSuccess.value = `用户 ${username.value} 创建成功！`
      
      // 清空表单
      username.value = ''
      email.value = ''
      password.value = ''
      passwordHint.value = ''
      passwordError.value = ''
      
      // 重新加载用户列表
      await loadUsers()
      
      // 3秒后清除成功消息
      setTimeout(() => {
        addUserSuccess.value = ''
      }, 3000)
    } else {
      // 提取详细的错误信息
      let errorMessage = '添加用户失败'
      if (response.data.error) {
        errorMessage = response.data.error
      } else if (response.data.message) {
        errorMessage = response.data.message
      }
      addUserError.value = errorMessage
    }
  } catch (error: any) {
    console.error('添加用户失败:', error)
    
    // 提取详细的错误信息
    let errorMessage = '添加用户失败'
    if (error.response) {
      // 服务器返回了错误响应
      const errorData = error.response.data
      if (errorData?.error) {
        errorMessage = errorData.error
      } else if (errorData?.message) {
        errorMessage = errorData.message
      } else if (typeof errorData === 'string') {
        errorMessage = errorData
      } else {
        errorMessage = `HTTP ${error.response.status}: ${error.response.statusText || '请求失败'}`
      }
    } else if (error.message) {
      errorMessage = error.message
    }
    
    addUserError.value = errorMessage
  } finally {
    loading.value = false
  }
}

// 格式化日期
function formatDate(dateString: string) {
  if (!dateString) return '未知'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('zh-CN', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch (error) {
    return '格式错误'
  }
}

// 轮询删除操作结果
async function pollForDeleteResult(opId: string) {
  console.log('pollForDeleteResult 函数开始执行，OpID:', opId)
  const maxAttempts = 30
  let attempts = 0
  
  while (attempts < maxAttempts) {
    try {
      console.log(`轮询删除操作第${attempts + 1}次，OpID: ${opId}`)
      const response = await axios.get(`/api/ops/${opId}/log`, { headers: authHeader() })
      const logContent = response.data
      
      console.log(`删除操作轮询第${attempts + 1}次，日志内容:`, logContent)
      
      // 检查操作是否完成
      if (logContent.includes('[OPERATION_END]')) {
        console.log('删除操作已完成')
        // 检查是否有错误
        if (logContent.includes('[ERROR]')) {
          console.error('删除操作出现错误')
          throw new Error('删除操作失败')
        }
        return
      }
      
      attempts++
      await new Promise(resolve => setTimeout(resolve, 1000))
    } catch (error) {
      console.error('轮询删除操作失败:', error)
      throw error
    }
  }
  
  console.warn('删除操作轮询超时')
  throw new Error('删除操作超时')
}

// 删除用户确认弹窗状态
const showDeleteUserConfirm = ref(false)
const userToDelete = ref<{username: string, email: string} | null>(null)

// 修改用户弹窗状态
const showEditUserDialog = ref(false)
const editUserForm = ref({
  originalUsername: '',
  username: '',
  email: '',
  password: ''
})
const editUserError = ref('')

// 显示修改用户弹窗
function openEditUserDialog(user: any) {
  editUserForm.value = {
    originalUsername: user.username,
    username: user.username,
    email: user.email,
    password: ''
  }
  editUserError.value = ''
  showEditUserDialog.value = true
}

// 取消修改用户
function cancelEditUser() {
  showEditUserDialog.value = false
  editUserForm.value = {
    originalUsername: '',
    username: '',
    email: '',
    password: ''
  }
  editUserError.value = ''
}

// 确认修改用户
async function confirmEditUser() {
  if (!editUserForm.value.username || !editUserForm.value.email) {
    editUserError.value = '用户名和邮箱不能为空'
    return
  }
  
  // 验证邮箱格式
  // 验证邮箱格式（允许标准邮箱格式或 @localhost）
  const emailRegex = /^[^\s@]+@([^\s@]+\.[^\s@]+|localhost)$/
  if (!emailRegex.test(editUserForm.value.email)) {
    editUserError.value = '邮箱格式不正确'
    return
  }
  
  editUserError.value = ''
  
  try {
    loading.value = true
    
    // 密码为空时不传 password 字段，后端保持原密码不变（app_user.sh update 支持不传密码）
    const params: any = {
      username: editUserForm.value.originalUsername
    }
    
    // 只传递有值的字段
    if (editUserForm.value.username !== editUserForm.value.originalUsername) {
      params.new_username = editUserForm.value.username
    }
    if (editUserForm.value.email) {
      params.email = editUserForm.value.email
    }
    if (editUserForm.value.password) {
      params.password = editUserForm.value.password
    }
    
    const response = await axios.post('/api/ops', {
      action: 'app-update',
      params: params
    }, { headers: authHeader() })
    
    if (response.data.success) {
      const opId = response.data.opId
      if (opId) {
        try {
          await pollForResult(opId)
        } catch (pollError) {
          console.error('轮询修改操作失败:', pollError)
        }
      }
      // 重新加载用户列表
      await loadUsers()
      showEditUserDialog.value = false
      
      // 根据更新内容显示不同的提示信息
      let successMessage = '用户信息修改成功'
      if (editUserForm.value.username !== editUserForm.value.originalUsername) {
        successMessage += `。用户名已从 "${editUserForm.value.originalUsername}" 改为 "${editUserForm.value.username}"，请使用新用户名登录`
      }
      if (editUserForm.value.password) {
        successMessage += '。密码已更新，请使用新密码登录'
      } else {
        successMessage += '。密码未修改，请继续使用原密码'
      }
      
      notice.value = successMessage
      noticeType.value = 'success'
      setTimeout(() => { notice.value = '' }, 5000)
    } else {
      editUserError.value = response.data.error || '修改用户失败'
    }
  } catch (error: any) {
    console.error('修改用户失败:', error)
    editUserError.value = error.response?.data?.error || error.message || '修改用户失败'
  } finally {
    loading.value = false
  }
}

// 显示删除用户确认弹窗
function showDeleteUserDialog(username: string, userEmail: string) {
  userToDelete.value = { username, email: userEmail }
  showDeleteUserConfirm.value = true
}

// 取消删除用户
function cancelDeleteUser() {
  showDeleteUserConfirm.value = false
  userToDelete.value = null
}

// 确认删除用户
async function confirmDeleteUser() {
  if (!userToDelete.value) return
  
  const { username, email } = userToDelete.value
  console.log('用户确认删除，开始执行删除操作')
  
  showDeleteUserConfirm.value = false
  userToDelete.value = null
  
  try {
    loading.value = true
    error.value = ''
    
    console.log('删除用户请求参数:', { action: 'user-del', email: email })
    console.log('发送API请求到 /api/ops')
    
    const response = await axios.post('/api/ops', {
      action: 'user-del',
      email: email
    }, { headers: authHeader() })
    
    console.log('删除用户API响应:', response.data)
    
    if (response.data.success) {
      // 等待删除操作完成
      const opId = response.data.opId
      if (opId) {
        console.log('等待删除操作完成，OpID:', opId)
        try {
          await pollForDeleteResult(opId)
          console.log('删除操作完成，开始刷新用户列表')
        } catch (pollError) {
          console.error('轮询删除操作失败:', pollError)
        }
      }
      // 重新加载用户列表
      await loadUsers()
      error.value = ''
    } else {
      error.value = response.data.error || '删除用户失败'
    }
  } catch (error) {
    console.error('删除用户失败:', error)
    console.error('错误类型:', error.constructor.name)
    console.error('错误消息:', error.message)
    console.error('错误状态码:', error.response?.status)
    console.error('错误响应数据:', error.response?.data)
    error.value = '删除用户失败: ' + (error.message || '未知错误')
  } finally {
    loading.value = false
  }
}

async function installCert() {
  const domainInput = prompt('输入证书域名（需已解析到本机）:')
  if (!domainInput) return
  await call('install-cert', { domain: domainInput })
}

// 环境检查相关函数
function openEnvironmentCheckDialog() {
  // 重置状态
  loading.value = false
  error.value = ''
  opId.value = ''
  logs.value = ''
  status.value = ''
  showEnvironmentCheckDialog.value = true
}

function closeEnvironmentCheckDialog() {
  showEnvironmentCheckDialog.value = false
  // 如果操作正在进行中（有opId），不要清理状态，保留日志
  // 只有在没有操作进行时才清理状态
  if (!opId.value && !loading.value) {
    loading.value = false
    error.value = ''
    logs.value = ''
    status.value = ''
  }
}

// 安装服务相关函数
function openInstallDialog() {
  selectedServices.value = []
  showInstallDialog.value = true
}

function closeInstallDialog() {
  console.log('closeInstallDialog called, showInstallDialog before:', showInstallDialog.value)
  showInstallDialog.value = false
  selectedServices.value = []
  console.log('closeInstallDialog executed, showInstallDialog after:', showInstallDialog.value)
}

// 备份管理相关函数
function openBackupManagementDialog() {
  showBackupManagementDialog.value = true
  backupTab.value = 'full' // 默认显示完整备份标签页
}

function closeBackupManagementDialog() {
  showBackupManagementDialog.value = false
}

// 执行完整备份（保留对话框显示“备份中...”，完成后提示并关闭）
async function executeFullBackup() {
  if (loading.value) return
  try {
    const result = await call('full-backup')
    if (result.success) {
      notice.value = '完整备份已完成'
      noticeType.value = 'success'
    } else {
      notice.value = error.value || '完整备份失败，请查看操作日志'
      noticeType.value = 'error'
    }
  } finally {
    loading.value = false
    closeBackupManagementDialog()
  }
}

// 定时备份相关函数（保留以兼容旧代码）
function openBackupDialog() {
  // 重定向到备份管理对话框的定时备份标签页
  showBackupManagementDialog.value = true
  backupTab.value = 'scheduled'
}

function closeBackupDialog() {
  showBackupDialog.value = false
}

// 证书申请相关函数
function openCertDialog() {
  showCertDialog.value = true
}

function closeCertDialog() {
  showCertDialog.value = false
}

// SSL管理相关函数
function openSslManagementDialog() {
  showSslManagementDialog.value = true
  sslTab.value = 'domains'
  loadSslData()
}

function closeSslManagementDialog() {
  showSslManagementDialog.value = false
  showAddDomainForm.value = false
  newSslDomain.value = ''
  newSslDomainCert.value = ''
  certFile.value = null
  keyFile.value = null
  uploadCertName.value = ''
  certificateUploadList.value = []
}

// 加载SSL数据
async function loadSslData() {
  console.log('[SSL管理] 开始加载SSL数据...')
  try {
    await Promise.all([
      loadSslDomains(),
      loadAvailableCertificates(),
      checkSslStatus(),
      checkHttpRedirectStatus()
    ])
    console.log('[SSL管理] SSL数据加载完成, HTTP跳转状态:', httpRedirectEnabled.value)
  } catch (error) {
    console.error('[SSL管理] 加载SSL数据失败:', error)
  }
}

// 加载SSL域名列表
async function loadSslDomains() {
  try {
    const response = await axios.get('/api/cert/domains', { headers: authHeader() })
    if (response.data.success) {
      const domains = response.data.domains || []
      // 为每个域名检查SSL配置状态
      for (const domain of domains) {
        if (domain.certExists) {
          try {
            const statusResponse = await axios.get(`/api/cert/domains/${domain.name}/ssl-status`, { headers: authHeader() })
            if (statusResponse.data.success) {
              domain.sslConfigured = statusResponse.data.configured || false
            }
          } catch (error) {
            console.error(`检查域名 ${domain.name} SSL状态失败:`, error)
            domain.sslConfigured = false
          }
        } else {
          domain.sslConfigured = false
        }
        // 初始化状态标志
        domain.sslConfiguring = false
        domain.sslDisabling = false
      }
      sslDomains.value = domains
    }
  } catch (error) {
    console.error('加载SSL域名列表失败:', error)
  }
}

// 加载可用证书列表
async function loadAvailableCertificates() {
  try {
    const response = await axios.get('/api/cert/list', { headers: authHeader() })
    if (response.data.success) {
      const certificates = response.data.certificates || []
      // 为每个证书添加deleting属性
      availableCertificates.value = certificates.map((cert: any) => ({
        ...cert,
        deleting: false
      }))
    }
  } catch (error) {
    console.error('加载证书列表失败:', error)
  }
}

// 检查SSL状态
async function checkSslStatus() {
  try {
    const response = await axios.get('/api/cert/ssl-status', { headers: authHeader() })
    if (response.data.success) {
      sslEnabled.value = response.data.enabled || false
    }
  } catch (error) {
    console.error('检查SSL状态失败:', error)
  }
}

// 检查HTTP跳转HTTPS配置状态
async function checkHttpRedirectStatus() {
  try {
    console.log('[HTTP跳转] 开始检查HTTP跳转状态...')
    const response = await axios.get('/api/cert/http-redirect-status', { headers: authHeader() })
    console.log('[HTTP跳转] API完整响应:', JSON.stringify(response.data, null, 2))
    
    if (response.data.success) {
      const wasEnabled = httpRedirectEnabled.value
      
      // 严格检查：必须同时满足以下条件才认为已配置
      // 1. API返回enabled=true（配置文件存在且有有效域名）
      // 2. 至少有一个有效域名
      // 注意：即使Apache配置语法检查失败，只要配置文件存在且有有效域名，也认为已配置
      // 因为配置可能已经生效，语法检查失败可能是权限问题或其他原因
      const apiEnabled = response.data.enabled === true && 
                        response.data.configuredDomains && 
                        Array.isArray(response.data.configuredDomains) &&
                        response.data.configuredDomains.length > 0 &&
                        response.data.configuredDomains.some((d: string) => d && d.match(/^[a-zA-Z0-9.-]+$/))
      
      httpRedirectEnabled.value = apiEnabled
      
      console.log('[HTTP跳转] 状态检查详情:')
      console.log('  - API enabled:', response.data.enabled)
      console.log('  - Apache配置有效:', response.data.apacheConfigValid)
      console.log('  - 配置文件存在:', response.data.configFilesExist)
      console.log('  - 域名列表:', response.data.configuredDomains)
      console.log('  - 最终状态:', wasEnabled, '->', httpRedirectEnabled.value)
      
      if (!apiEnabled) {
        if (response.data.configFilesExist && !response.data.apacheConfigValid) {
          console.warn('[HTTP跳转] ⚠ 配置文件存在但Apache配置语法错误')
        } else if (!response.data.configFilesExist) {
          console.log('[HTTP跳转] ✗ HTTP跳转未配置（配置文件不存在）')
        } else {
          console.log('[HTTP跳转] ✗ HTTP跳转未配置或配置无效')
        }
      } else {
        console.log('[HTTP跳转] ✓ HTTP跳转已配置，域名:', response.data.configuredDomains.join(', '))
      }
    } else {
      console.warn('[HTTP跳转] API返回失败:', response.data)
      httpRedirectEnabled.value = false
    }
  } catch (error) {
    console.error('检查HTTP跳转状态失败:', error)
    httpRedirectEnabled.value = false
  }
}

// 添加SSL域名
async function addSslDomain() {
  if (!newSslDomain.value.trim()) {
    notice.value = '请输入域名'
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 3000)
    return
  }
  
  sslDomainAdding.value = true
  
  try {
    const response = await axios.post('/api/cert/domains', {
      domain: newSslDomain.value.trim(),
      certName: newSslDomainCert.value || null
    }, { headers: authHeader() })
    
    if (response.data.success) {
      notice.value = 'SSL域名添加成功'
      noticeType.value = 'success'
      newSslDomain.value = ''
      newSslDomainCert.value = ''
      showAddDomainForm.value = false
      await loadSslDomains()
      setTimeout(() => { notice.value = '' }, 3000)
    } else {
      notice.value = response.data.error || '添加SSL域名失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '添加SSL域名失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    sslDomainAdding.value = false
  }
}

// 配置域名的Apache SSL
async function configureDomainSsl(domain: any) {
  if (!domain.certExists) {
    notice.value = '证书不存在，无法配置SSL'
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 3000)
    return
  }
  
  domain.sslConfiguring = true
  
  try {
    const response = await axios.post(`/api/cert/domains/${domain.name}/enable-ssl`, {}, { headers: authHeader() })
    if (response.data.success) {
      notice.value = response.data.message || 'Apache SSL配置成功'
      noticeType.value = 'success'
      
      // 重新加载域名列表以更新状态
      await loadSslDomains()
      
      setTimeout(() => { notice.value = '' }, 8000)
    } else {
      notice.value = response.data.error || response.data.message || '配置SSL失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '配置SSL失败: ' + (error.response?.data?.error || error.response?.data?.message || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    domain.sslConfiguring = false
  }
}

// 禁用域名的Apache SSL
async function disableDomainSsl(domain: any) {
  if (!confirm(`确定要禁用域名 ${domain.name} 的Apache SSL配置吗？禁用后将删除SSL VirtualHost配置文件。`)) {
    return
  }
  
  domain.sslDisabling = true
  
  try {
    const response = await axios.post(`/api/cert/domains/${domain.name}/disable-ssl`, {}, { headers: authHeader() })
    if (response.data.success) {
      notice.value = response.data.message || 'SSL配置已禁用'
      noticeType.value = 'success'
      
      // 重新加载域名列表以更新状态
      await loadSslDomains()
      
      setTimeout(() => { notice.value = '' }, 5000)
    } else {
      notice.value = response.data.error || response.data.message || '禁用SSL失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '禁用SSL失败: ' + (error.response?.data?.error || error.response?.data?.message || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    domain.sslDisabling = false
  }
}

// 删除SSL域名
async function removeSslDomain(domain: string) {
  if (!confirm(`确定要删除SSL域名 ${domain} 吗？`)) {
    return
  }
  
  try {
    const response = await axios.delete(`/api/cert/domains/${encodeURIComponent(domain)}`, { headers: authHeader() })
    
    if (response.data.success) {
      notice.value = 'SSL域名删除成功'
      noticeType.value = 'success'
      await loadSslDomains()
      setTimeout(() => { notice.value = '' }, 3000)
    } else {
      notice.value = response.data.error || '删除SSL域名失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '删除SSL域名失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  }
}

// 编辑域名证书关联
async function editDomainCert(domain: any) {
  editingDomainCert.value = domain
  editingCertName.value = domain.certName || ''
  showEditCertDialog.value = true
  
  // 确保证书列表已加载
  if (availableCertificates.value.length === 0) {
    await loadAvailableCertificates()
  }
}

async function saveDomainCertEdit() {
  if (!editingDomainCert.value) return
  
  try {
    const response = await axios.put(`/api/cert/domains/${encodeURIComponent(editingDomainCert.value.name)}/cert`, {
      certName: editingCertName.value || null
    }, { headers: authHeader() })
    
    if (response.data.success) {
      notice.value = '证书关联更新成功'
      noticeType.value = 'success'
      showEditCertDialog.value = false
      editingDomainCert.value = null
      editingCertName.value = ''
      await loadSslDomains()
      setTimeout(() => { notice.value = '' }, 3000)
    } else {
      notice.value = response.data.error || '更新证书关联失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '更新证书关联失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  }
}

// 处理证书文件选择（保留以兼容旧代码）
function handleCertFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    certFile.value = target.files[0]
  }
}

// 处理私钥文件选择（保留以兼容旧代码）
function handleKeyFileChange(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    keyFile.value = target.files[0]
  }
}

// 从文件名提取域名
function extractDomainFromFileName(fileName: string): string {
  // 移除扩展名
  let name = fileName.replace(/\.(crt|pem|cer|key)$/i, '')
  
  // 移除常见后缀：_chain, _public, _private, chain, public, private
  name = name.replace(/[_-]?(chain|public|private)$/i, '')
  
  // 提取域名（支持www.前缀）
  // 匹配模式：www.domain.com 或 domain.com
  // 使用RegExp构造函数避免esbuild解析问题
  const domainPattern = new RegExp('(?:www\\.)?([a-z0-9]([-a-z0-9]{0,61}[a-z0-9])?\\.)+[a-z]{2,}', 'i')
  const domainMatch = name.match(domainPattern)
  if (domainMatch) {
    return domainMatch[0].toLowerCase()
  }
  
  // 如果没有匹配到标准域名格式，尝试提取基础名称
  // 例如：example.com.key -> example.com
  const parts = name.split('.')
  if (parts.length >= 2) {
    return parts.slice(0, -1).join('.')
  }
  
  return name
}

// 判断文件类型
function getFileType(fileName: string): 'key' | 'cert' | 'chain' | 'unknown' {
  const lowerName = fileName.toLowerCase()
  
  // 私钥文件
  if (lowerName.endsWith('.key') || lowerName.endsWith('.pem')) {
    if (lowerName.includes('key') || lowerName.includes('private')) {
      return 'key'
    }
  }
  
  // 证书链文件（优先判断，因为chain不应该绑定到域名）
  if (lowerName.includes('_chain') || lowerName.includes('-chain') || 
      lowerName.includes('chain') || lowerName.includes('ca-bundle') ||
      lowerName.includes('intermediate')) {
    return 'chain'
  }
  
  // 证书文件（public或普通crt）
  if (lowerName.endsWith('.crt') || lowerName.endsWith('.cer') || 
      lowerName.endsWith('.pem') || lowerName.includes('_public') ||
      lowerName.includes('-public') || lowerName.includes('public')) {
    return 'cert'
  }
  
  return 'unknown'
}

// 处理拖拽上传
function handleDrop(event: DragEvent) {
  event.preventDefault()
  isDragging.value = false
  
  const files = event.dataTransfer?.files
  if (files && files.length > 0) {
    processFiles(Array.from(files))
  }
}

// 处理文件选择
function handleFileSelect(event: Event) {
  const target = event.target as HTMLInputElement
  if (target.files && target.files.length > 0) {
    processFiles(Array.from(target.files))
  }
  // 清空input，允许重复选择相同文件
  if (target) {
    target.value = ''
  }
}

// 处理文件并自动分组
function processFiles(files: File[]) {
  // 按域名分组文件
  const domainGroups = new Map<string, {
    keyFile: File | null
    certFile: File | null
    chainFile: File | null
    domainName: string
  }>()
  
  files.forEach(file => {
    const domain = extractDomainFromFileName(file.name)
    const fileType = getFileType(file.name)
    
    if (!domainGroups.has(domain)) {
      domainGroups.set(domain, {
        keyFile: null,
        certFile: null,
        chainFile: null,
        domainName: domain
      })
    }
    
    const group = domainGroups.get(domain)!
    
    switch (fileType) {
      case 'key':
        if (!group.keyFile) {
          group.keyFile = file
        }
        break
      case 'cert':
        if (!group.certFile) {
          group.certFile = file
        }
        break
      case 'chain':
        if (!group.chainFile) {
          group.chainFile = file
        }
        break
    }
  })
  
  // 为每个域名组创建证书上传项
  domainGroups.forEach((group, domain) => {
    // 只添加有证书文件和私钥文件的组
    if (group.certFile && group.keyFile) {
      certificateUploadList.value.push({
        certFile: group.certFile,
        keyFile: group.keyFile,
        chainFile: group.chainFile,
        certName: domain, // 默认使用域名作为证书名称
        domainName: domain,
        id: Date.now().toString() + Math.random().toString(36).substr(2, 9)
      })
    }
  })
  
  // 如果没有成功识别任何证书，提示用户
  if (certificateUploadList.value.length === 0) {
    notice.value = '未能自动识别证书文件，请检查文件名格式（例如：domain.com.key, domain.com_public.crt, domain.com_chain.crt）'
    noticeType.value = 'warning'
    setTimeout(() => { notice.value = '' }, 5000)
  }
}

// 批量证书上传相关函数（保留以兼容手动添加）
function addCertificateUploadItem() {
  certificateUploadList.value.push({
    certFile: null,
    keyFile: null,
    chainFile: null,
    certName: '',
    domainName: '',
    id: Date.now().toString() + Math.random().toString(36).substr(2, 9)
  })
}

function removeCertificateUploadItem(id: string) {
  const index = certificateUploadList.value.findIndex(item => item.id === id)
  if (index > -1) {
    certificateUploadList.value.splice(index, 1)
  }
}

function handleBatchCertFileChange(event: Event, id: string) {
  const target = event.target as HTMLInputElement
  const item = certificateUploadList.value.find(item => item.id === id)
  if (item && target.files && target.files.length > 0) {
    item.certFile = target.files[0]
  }
}

function handleBatchKeyFileChange(event: Event, id: string) {
  const target = event.target as HTMLInputElement
  const item = certificateUploadList.value.find(item => item.id === id)
  if (item && target.files && target.files.length > 0) {
    item.keyFile = target.files[0]
  }
}

function handleBatchChainFileChange(event: Event, id: string) {
  const target = event.target as HTMLInputElement
  const item = certificateUploadList.value.find(item => item.id === id)
  if (item && target.files && target.files.length > 0) {
    item.chainFile = target.files[0]
  }
}

// 检查是否可以批量上传
const canUploadBatchCertificates = computed(() => {
  return certificateUploadList.value.length > 0 && 
         certificateUploadList.value.every(item => 
           item.certFile && item.keyFile && item.certName.trim()
         )
})

// 批量上传证书
async function uploadBatchCertificates() {
  if (!canUploadBatchCertificates.value) {
    notice.value = '请确保所有证书项都填写完整（证书文件、私钥文件和证书名称）'
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 3000)
    return
  }
  
  batchCertUploading.value = true
  notice.value = ''
  noticeType.value = 'info'
  
  try {
    const formData = new FormData()
    
    // 添加每个证书的信息
    // 使用简单的字段名格式，避免方括号解析问题
    certificateUploadList.value.forEach((item, index) => {
      if (item.certFile) formData.append(`cert_${index}`, item.certFile)
      if (item.keyFile) formData.append(`key_${index}`, item.keyFile)
      if (item.chainFile) formData.append(`chain_${index}`, item.chainFile)
      formData.append(`certName_${index}`, item.certName.trim())
    })
    
    formData.append('count', certificateUploadList.value.length.toString())
    
    const response = await axios.post('/api/cert/batch-upload', formData, {
      headers: {
        ...authHeader(),
        'Content-Type': 'multipart/form-data'
      }
    })
    
    // 检查响应是否成功（即使有部分失败，只要response.data.success为true就显示成功消息）
    if (response.data && response.data.success !== false) {
      const results = response.data.results || []
      const successCount = results.filter((r: any) => r.success).length
      const failCount = results.length - successCount
      const apacheConfiguredCount = response.data.apacheConfiguredCount || results.filter((r: any) => r.success && r.apacheConfigured).length
      
      // 使用后端返回的消息，如果没有则自己构建
      let message = response.data.message || `成功上传 ${successCount} 个证书`
      
      // 如果有Apache配置，添加提示信息
      if (apacheConfiguredCount > 0) {
        message += '。Apache SSL配置需要2-3分钟生效，请稍后访问HTTPS页面验证。注意：HTTP跳转HTTPS需要手动启用。'
        noticeType.value = 'success'
      } else if (failCount === 0) {
        noticeType.value = 'success'
      } else {
        noticeType.value = 'warning'
      }
      
      notice.value = message
      
      // 清空上传列表
      certificateUploadList.value = []
      
      // 重新加载证书列表和SSL域名列表
      await loadAvailableCertificates()
      await loadSslDomains()
      
      // 延长显示时间，特别是当有Apache配置时
      setTimeout(() => { notice.value = '' }, apacheConfiguredCount > 0 ? 10000 : 8000)
    } else {
      // 失败情况
      notice.value = response.data?.error || response.data?.message || '批量上传失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '批量上传失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    batchCertUploading.value = false
  }
}

// 上传证书
async function uploadCertificate() {
  if (!certFile.value || !keyFile.value) {
    notice.value = '请选择证书文件和私钥文件'
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 3000)
    return
  }
  
  if (!uploadCertName.value.trim()) {
    notice.value = '请输入证书名称'
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 3000)
    return
  }
  
  certUploading.value = true
  
  try {
    const formData = new FormData()
    formData.append('cert', certFile.value)
    formData.append('key', keyFile.value)
    formData.append('certName', uploadCertName.value.trim())
    
    const response = await axios.post('/api/cert/upload', formData, {
      headers: {
        ...authHeader(),
        'Content-Type': 'multipart/form-data'
      }
    })
    
    if (response.data.success) {
      notice.value = '证书上传成功'
      noticeType.value = 'success'
      certFile.value = null
      keyFile.value = null
      uploadCertName.value = ''
      // 重置文件输入
      const certInput = document.querySelector('input[type="file"][accept*=".crt"]') as HTMLInputElement
      const keyInput = document.querySelector('input[type="file"][accept*=".key"]') as HTMLInputElement
      if (certInput) certInput.value = ''
      if (keyInput) keyInput.value = ''
      
      await loadAvailableCertificates()
      setTimeout(() => { notice.value = '' }, 3000)
    } else {
      notice.value = response.data.error || '证书上传失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '证书上传失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    certUploading.value = false
  }
}

// 启用SSL
async function enableSslForDomain() {
  if (!selectedSslDomain.value) {
    // 如果没有选择域名，使用第一个域名
    if (sslDomains.value.length > 0) {
      selectedSslDomain.value = sslDomains.value[0].name
    } else {
      notice.value = '请先添加SSL域名'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 3000)
      return
    }
  }
  
  sslEnabling.value = true
  
  try {
    const response = await axios.post('/api/ops', {
      action: 'enable-ssl',
      params: {
        domain: selectedSslDomain.value
      }
    }, { headers: authHeader() })
    
    if (response.data.success) {
      notice.value = 'SSL配置成功！Apache已启用SSL/TLS加密'
      noticeType.value = 'success'
      await checkSslStatus()
      setTimeout(() => { notice.value = '' }, 5000)
    } else {
      notice.value = response.data.error || 'SSL配置失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    notice.value = '启用SSL失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    sslEnabling.value = false
  }
}

// 启用HTTP跳转HTTPS
async function enableHttpRedirect() {
  // 检查是否有已配置SSL的域名
  const configuredDomains = sslDomains.value.filter(d => d.sslConfigured && d.certExists)
  if (configuredDomains.length === 0) {
    notice.value = '请先为域名配置SSL证书（点击"配置HTTPS"按钮）'
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
    return
  }
  
  httpRedirectEnabling.value = true
  
  try {
    console.log('[HTTP跳转] 开始配置HTTP跳转HTTPS...')
    const response = await axios.post('/api/ops', {
      action: 'enable-http-redirect',
      params: {}
    }, { headers: authHeader() })
    
    console.log('[HTTP跳转] API响应:', response.data)
    
    if (response.data.success) {
      const opId = response.data.opId
      console.log('[HTTP跳转] 操作ID:', opId)
      
      // 等待2秒后检查操作日志，确认脚本是否执行成功
      setTimeout(async () => {
        try {
          const logResponse = await axios.get(`/api/ops/${opId}/log`, { headers: authHeader() })
          const logContent = logResponse.data || ''
          console.log('[HTTP跳转] 操作日志:', logContent)
          
          // 检查日志中是否有错误信息
          if (logContent.includes('[ERROR]') || logContent.includes('失败') || logContent.includes('错误')) {
            notice.value = 'HTTP跳转HTTPS配置可能失败，请查看操作日志或手动检查Apache配置'
            noticeType.value = 'warning'
            setTimeout(() => { notice.value = '' }, 10000)
          } else if (logContent.includes('[SUCCESS]') || logContent.includes('成功') || logContent.includes('完成')) {
            notice.value = 'HTTP跳转HTTPS配置成功！配置已生效，HTTP请求将自动跳转到HTTPS（配置需要2-3分钟生效）'
            noticeType.value = 'success'
            // 刷新HTTP跳转状态
            await checkHttpRedirectStatus()
            setTimeout(() => { notice.value = '' }, 10000)
          } else {
            // 如果没有明确的成功/失败标记，显示一般成功消息
            notice.value = 'HTTP跳转HTTPS配置请求已提交！正在配置中，请等待2-3分钟生效。如果未生效，请检查Apache配置。'
            noticeType.value = 'info'
            // 刷新HTTP跳转状态
            await checkHttpRedirectStatus()
            setTimeout(() => { notice.value = '' }, 10000)
          }
        } catch (logError) {
          console.error('[HTTP跳转] 获取操作日志失败:', logError)
          // 即使无法获取日志，也显示成功消息（因为API返回了success）
          notice.value = 'HTTP跳转HTTPS配置请求已提交！正在配置中，请等待2-3分钟生效。如果未生效，请检查Apache配置。'
          noticeType.value = 'info'
          // 刷新HTTP跳转状态
          await checkHttpRedirectStatus()
          setTimeout(() => { notice.value = '' }, 10000)
        }
      }, 2000)
      
      // 立即显示初始成功消息
      notice.value = 'HTTP跳转HTTPS配置请求已提交，正在处理中...'
      noticeType.value = 'info'
      
      // 刷新SSL域名列表和HTTP跳转状态
      await Promise.all([
        loadSslDomains(),
        checkHttpRedirectStatus()
      ])
    } else {
      const errorMsg = response.data.error || response.data.message || '配置HTTP跳转失败'
      console.error('[HTTP跳转] 配置失败:', errorMsg)
      notice.value = '配置HTTP跳转失败: ' + errorMsg
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 8000)
    }
  } catch (error: any) {
    console.error('[HTTP跳转] 请求失败:', error)
    const errorMsg = error.response?.data?.error || error.response?.data?.message || error.message || '未知错误'
    notice.value = '配置HTTP跳转失败: ' + errorMsg
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 8000)
  } finally {
    httpRedirectEnabling.value = false
  }
}

// 禁用HTTP跳转HTTPS
async function disableHttpRedirect() {
  if (!confirm('确定要禁用HTTP自动跳转HTTPS吗？禁用后将删除所有HTTP跳转配置文件。')) {
    return
  }
  
  httpRedirectDisabling.value = true
  
  try {
    console.log('[HTTP跳转] 开始禁用HTTP跳转HTTPS...')
    const response = await axios.post('/api/cert/disable-http-redirect', {}, { headers: authHeader() })
    
    console.log('[HTTP跳转] 禁用API响应:', response.data)
    
    if (response.data.success) {
      notice.value = 'HTTP跳转HTTPS已禁用！所有HTTP跳转配置文件已删除，Apache服务已重启。'
      noticeType.value = 'success'
      
      // 刷新HTTP跳转状态
      await checkHttpRedirectStatus()
      
      setTimeout(() => {
        notice.value = ''
      }, 5000)
    } else {
      const errorMsg = response.data.error || response.data.message || '禁用HTTP跳转失败'
      console.error('[HTTP跳转] 禁用失败:', errorMsg)
      notice.value = '禁用HTTP跳转失败: ' + errorMsg
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 8000)
    }
  } catch (error: any) {
    console.error('[HTTP跳转] 禁用请求失败:', error)
    const errorMsg = error.response?.data?.error || error.response?.data?.message || error.message || '未知错误'
    notice.value = '禁用HTTP跳转失败: ' + errorMsg
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 8000)
  } finally {
    httpRedirectDisabling.value = false
  }
}

// 查看证书详情
// 检查证书是否即将过期（30天内）
function isCertExpiringSoon(expiresAt: string): boolean {
  if (!expiresAt) return false
  try {
    // 解析日期字符串（格式：2026/1/26）
    const parts = expiresAt.split('/')
    if (parts.length === 3) {
      const year = parseInt(parts[0])
      const month = parseInt(parts[1]) - 1
      const day = parseInt(parts[2])
      const expireDate = new Date(year, month, day)
      const now = new Date()
      const daysUntilExpiry = Math.ceil((expireDate.getTime() - now.getTime()) / (1000 * 60 * 60 * 24))
      return daysUntilExpiry > 0 && daysUntilExpiry <= 30
    }
  } catch (e) {
    console.error('解析证书到期日期失败:', e)
  }
  return false
}

// 查看证书详细信息
async function viewCertDetails(cert: any) {
  showCertDetailsDialog.value = true
  certDetails.value = null
  certDetailsLoading.value = true
  
  try {
    const response = await axios.get(`/api/cert/${encodeURIComponent(cert.name)}/details`, { headers: authHeader() })
    if (response.data.success) {
      certDetails.value = response.data.certificate
    } else {
      notice.value = response.data.error || '获取证书详细信息失败'
      noticeType.value = 'error'
      setTimeout(() => { notice.value = '' }, 5000)
    }
  } catch (error: any) {
    console.error('获取证书详细信息失败:', error)
    notice.value = '获取证书详细信息失败: ' + (error.response?.data?.error || error.message || '未知错误')
    noticeType.value = 'error'
    setTimeout(() => { notice.value = '' }, 5000)
  } finally {
    certDetailsLoading.value = false
  }
}

// 删除证书
async function deleteCertificate(cert: any) {
  if (!confirm(`确定要删除证书 "${cert.name}" 吗？\n\n此操作将删除以下文件：\n- ${cert.name}.crt\n- ${cert.name}.key\n- ${cert.name}.chain.crt（如果存在）\n\n删除后无法恢复！`)) {
    return
  }
  
  cert.deleting = true
  
  try {
    const response = await axios.delete(`/api/cert/${encodeURIComponent(cert.name)}`, { headers: authHeader() })
    if (response.data.success) {
      notice.value = response.data.message || '证书删除成功'
      noticeType.value = 'success'
      
      // 重新加载证书列表
      await loadAvailableCertificates()
      
      setTimeout(() => { notice.value = '' }, 3000)
    } else {
      notice.value = response.data.error || response.data.message || '删除证书失败'
      noticeType.value = 'error'
      if (response.data.usedByDomains && response.data.usedByDomains.length > 0) {
        notice.value += `\n证书被以下域名使用: ${response.data.usedByDomains.join(', ')}`
      }
      setTimeout(() => { notice.value = '' }, 8000)
    }
  } catch (error: any) {
    console.error('删除证书失败:', error)
    notice.value = '删除证书失败: ' + (error.response?.data?.error || error.response?.data?.message || error.message || '未知错误')
    noticeType.value = 'error'
    if (error.response?.data?.usedByDomains && error.response.data.usedByDomains.length > 0) {
      notice.value += `\n证书被以下域名使用: ${error.response.data.usedByDomains.join(', ')}`
    }
    setTimeout(() => { notice.value = '' }, 8000)
  } finally {
    cert.deleting = false
  }
}

async function executeCertRequest() {
  console.log('executeCertRequest called')
  
  if (!certDomain.value) {
    alert('请输入域名')
    return
  }

  // 关闭对话框
  closeCertDialog()

  // 显示操作日志对话框
  showOperationLog.value = true
  loading.value = true
  opId.value = 'cert-request-' + Date.now() // 生成唯一的操作ID
  logs.value = '开始申请SSL证书...\n'

  try {
    // 调用后端API申请证书
    const result = await callWithoutPolling('install-cert', {
      domain: certDomain.value,
      country: certCountry.value,
      state: certState.value,
      city: certCity.value,
      organization: certOrganization.value,
      unit: certUnit.value,
      commonName: certCommonName.value,
      email: certEmail.value,
      validity: certValidity.value,
      san: certSAN.value,
      caCountry: caCountry.value,
      caState: caState.value,
      caCity: caCity.value,
      caOrganization: caOrganization.value,
      caUnit: caUnit.value,
      caCommonName: caCommonName.value,
      caEmail: caEmail.value,
      caValidity: caValidity.value
    })

    if (result && result.success) {
      logs.value += `✅ SSL证书申请成功\n`
      logs.value += `🌐 域名: ${certDomain.value}\n`
      logs.value += `📅 有效期: ${certValidity.value}天\n`
      logs.value += `🔒 证书类型: 自签名CA证书\n`
      logs.value += `\n🎉 SSL证书配置完成！\n`
    } else {
      logs.value += `❌ SSL证书申请失败\n`
      if (result && 'error' in result) {
        logs.value += `错误信息: ${(result as any).error}\n`
      }
    }
  } catch (error) {
    console.error('Cert request error:', error)
    logs.value += `❌ SSL证书申请出错: ${error.message}\n`
  }

  // 关闭加载状态
  loading.value = false

  console.log('Cert request completed')
}

// 下载CA根证书
async function downloadCACert() {
  try {
    const token = sessionStorage.getItem('apiAuth')
    if (!token) {
      alert('请先登录')
      return
    }

    const response = await fetch('/api/cert/ca-cert', {
      method: 'GET',
      headers: {
        'Authorization': `Basic ${token}`
      }
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({ error: '下载失败' }))
      alert(`下载根证书失败: ${errorData.error || '未知错误'}`)
      return
    }

    // 获取证书内容
    const certContent = await response.text()
    
    // 创建下载链接
    const blob = new Blob([certContent], { type: 'application/x-x509-ca-cert' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = 'cacert.pem'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)

    // 显示成功消息
    alert('根证书下载成功！\n\n请将证书安装到系统信任库中：\n• Windows: 双击证书文件，选择"安装证书"，选择"本地计算机"，选择"将所有证书放入以下存储"，选择"受信任的根证书颁发机构"\n• Linux: 将证书复制到 /usr/local/share/ca-certificates/ 目录，然后运行 sudo update-ca-trust\n• macOS: 双击证书文件，在"钥匙串访问"中选择"系统"，将证书拖入"系统根证书"')
  } catch (error) {
    console.error('下载根证书失败:', error)
    alert(`下载根证书失败: ${error.message}`)
  }
}

async function executeBackupSetup() {
  console.log('executeBackupSetup called')
  console.log('backupInterval:', backupInterval.value)
  console.log('customDays:', customDays.value)
  console.log('backupDatabase:', backupDatabase.value)
  console.log('backupConfig:', backupConfig.value)
  console.log('backupMaildir:', backupMaildir.value)
  console.log('retentionDays:', retentionDays.value)

  // 计算实际的备份间隔天数
  let intervalDays = 7
  if (backupInterval.value === 'custom') {
    intervalDays = customDays.value || 7
  } else {
    intervalDays = parseInt(backupInterval.value)
  }

  console.log('Calculated interval days:', intervalDays)

  // 立即关闭备份弹窗
  closeBackupManagementDialog()

  // 显示操作日志对话框
  showOperationLog.value = true
  loading.value = true
  opId.value = 'backup-setup-' + Date.now() // 生成唯一的操作ID
  logs.value = '开始设置定时备份...\n'

  try {
    // 调用后端API设置定时备份
    const result = await callWithoutPolling('setup-backup-cron', {
      interval: intervalDays,
      database: backupDatabase.value,
      config: backupConfig.value,
      maildir: backupMaildir.value,
      retention: retentionDays.value,
      customTime: customTimeEnabled.value,
      customHour: customHour.value,
      customMinute: customMinute.value,
      customSecond: customSecond.value
    })

    if (result && result.success) {
      logs.value += `✅ 定时备份设置成功\n`
      logs.value += `📅 备份间隔: 每${intervalDays}天\n`
      logs.value += `📦 备份内容: ${getBackupContentDescription()}\n`
      logs.value += `🗑️ 保留时间: ${retentionDays.value}天\n`
      logs.value += `\n🚀 正在立即执行首次备份...\n`
      logs.value += `⏰ 后续备份将按照设定时间自动执行\n`
      logs.value += `\n🎉 定时备份配置完成！\n`
      
      // 关闭备份管理对话框
      setTimeout(() => {
        closeBackupManagementDialog()
      }, 2000)
    } else {
      logs.value += `❌ 定时备份设置失败\n`
      if (result && 'error' in result) {
        logs.value += `错误信息: ${(result as any).error}\n`
      }
    }
  } catch (error) {
    console.error('Backup setup error:', error)
    logs.value += `❌ 定时备份设置出错: ${error.message}\n`
  }

  // 关闭加载状态
  loading.value = false

  console.log('Backup setup completed')
}

function getBackupContentDescription() {
  const contents: string[] = []
  if (backupDatabase.value) contents.push('数据库')
  if (backupConfig.value) contents.push('配置文件')
  if (backupMaildir.value) contents.push('邮件目录')
  return contents.length > 0 ? contents.join('、') : '无'
}

// 服务状态相关函数
function openServiceStatusDialog() {
  showServiceStatusDialog.value = true
  loadServiceStatus()
  
  // 启动自动刷新，每3秒刷新一次
  if (refreshInterval.value) {
    clearInterval(refreshInterval.value)
  }
  refreshInterval.value = setInterval(() => {
    if (showServiceStatusDialog.value) {
      console.log('Auto refreshing service status...')
      loadServiceStatus(false) // 自动刷新时不显示加载状态
    }
  }, 3000)
}

function closeServiceStatusDialog() {
  showServiceStatusDialog.value = false
  
  // 清除自动刷新
  if (refreshInterval.value) {
    clearInterval(refreshInterval.value)
    refreshInterval.value = null
  }
}

async function loadServiceStatus(showLoading = true) {
  if (showLoading) {
    serviceStatusLoading.value = true
  }
  try {
    console.log('Loading service status...')
    console.log('Auth header:', authHeader())
    
    // 先测试简单的API调用
    console.log('Testing API connectivity...')
    const testResponse = await fetch('/api/test-status', {
      method: 'GET',
      headers: {
        'Authorization': authHeader().Authorization,
        'Content-Type': 'application/json'
      }
    })
    
    console.log('Test API status:', testResponse.status)
    if (testResponse.ok) {
      const testData = await testResponse.json()
      console.log('Test API response:', testData)
    } else {
      console.error('Test API failed:', testResponse.statusText)
    }
    
    // 调用系统状态API
    const response = await fetch('/api/system-status', {
      method: 'GET',
      headers: {
        'Authorization': authHeader().Authorization,
        'Content-Type': 'application/json'
      }
    })
    
    console.log('Response status:', response.status)
    console.log('Response ok:', response.ok)
    console.log('Response headers:', response.headers)
    
    if (response.ok) {
      const data = await response.json()
      console.log('API Response:', data) // 调试日志
      console.log('Services data:', data.data?.services) // 调试服务数据
      
      // 设置服务状态
      serviceStatuses.value = data.data?.services || {}
      console.log('Service statuses set to:', serviceStatuses.value) // 调试最终状态
      
      // 设置系统信息
      systemInfo.value = {
        timestamp: data.data?.systemInfo?.timestamp || new Date().toLocaleString(),
        loadAverage: data.data?.systemInfo?.loadAverage || 'N/A',
        memoryUsage: data.data?.systemInfo?.memoryUsage || 'N/A',
        diskUsage: data.data?.systemInfo?.diskUsage || 'N/A'
      }
      console.log('System info set to:', systemInfo.value)
    } else {
      console.error('Failed to load service status:', response.statusText)
      const errorText = await response.text()
      console.error('Error response:', errorText)
      
      // 如果API调用失败，设置默认状态
      serviceStatuses.value = {
        postfix: { status: 'unknown', lastCheck: new Date().toISOString() },
        dovecot: { status: 'unknown', lastCheck: new Date().toISOString() },
        httpd: { status: 'unknown', lastCheck: new Date().toISOString() },
        mariadb: { status: 'unknown', lastCheck: new Date().toISOString() },
        named: { status: 'unknown', lastCheck: new Date().toISOString() },
        firewalld: { status: 'unknown', lastCheck: new Date().toISOString() },
        dispatcher: { status: 'unknown', lastCheck: new Date().toISOString() },
        mail: { status: 'unknown', lastCheck: new Date().toISOString() }
      }
      systemInfo.value = {
        timestamp: new Date().toLocaleString(),
        loadAverage: 'N/A',
        memoryUsage: 'N/A',
        diskUsage: 'N/A'
      }
    }
  } catch (error) {
    console.error('Error loading service status:', error)
    serviceStatuses.value = {}
    systemInfo.value = {
      timestamp: new Date().toLocaleString(),
      loadAverage: 'N/A',
      memoryUsage: 'N/A',
      diskUsage: 'N/A'
    }
  } finally {
    serviceStatusLoading.value = false
  }
}

async function refreshServiceStatus() {
  await loadServiceStatus(true) // 手动刷新时显示加载状态
}

function getServiceStatusClass(status: string) {
  switch (status) {
    case 'active':
    case 'running':
      return 'bg-green-500'
    case 'inactive':
    case 'stopped':
      return 'bg-gray-400'
    case 'failed':
    case 'error':
      return 'bg-red-500'
    default:
      return 'bg-yellow-500'
  }
}

function getServiceStatusText(status: string) {
  switch (status) {
    case 'active':
    case 'running':
      return '运行中'
    case 'inactive':
    case 'stopped':
      return '已停止'
    case 'failed':
    case 'error':
      return '失败'
    default:
      return '未知'
  }
}

// 组件卸载时清理定时器
onUnmounted(() => {
  if (refreshInterval.value) {
    clearInterval(refreshInterval.value)
    refreshInterval.value = null
  }
})

function toggleService(service: string) {
  console.log('toggleService called with:', service)
  console.log('Current selectedServices:', selectedServices.value)
  const index = selectedServices.value.indexOf(service)
  if (index > -1) {
    selectedServices.value.splice(index, 1)
    console.log('Removed service:', service)
  } else {
    selectedServices.value.push(service)
    console.log('Added service:', service)
  }
  console.log('Updated selectedServices:', selectedServices.value)
}

// 服务管理相关函数
function openServiceManagementDialog() {
  selectedRestartServices.value = []
  serviceAction.value = 'restart'
  showServiceManagementDialog.value = true
}

function closeServiceManagementDialog() {
  console.log('closeServiceManagementDialog called, showServiceManagementDialog before:', showServiceManagementDialog.value)
  showServiceManagementDialog.value = false
  selectedRestartServices.value = []
  serviceAction.value = 'restart'
  console.log('closeServiceManagementDialog executed, showServiceManagementDialog after:', showServiceManagementDialog.value)
}

function toggleRestartService(service: string) {
  console.log('toggleRestartService called with:', service)
  console.log('Current selectedRestartServices:', selectedRestartServices.value)
  const index = selectedRestartServices.value.indexOf(service)
  if (index > -1) {
    selectedRestartServices.value.splice(index, 1)
    console.log('Removed restart service:', service)
  } else {
    selectedRestartServices.value.push(service)
    console.log('Added restart service:', service)
  }
  console.log('Updated selectedRestartServices:', selectedRestartServices.value)
}

// 防止重复执行的标志
let isInstalling = false

async function executeInstall() {
  console.log('executeInstall called')
  console.log('selectedServices:', selectedServices.value)
  console.log('selectedServices.length:', selectedServices.value.length)
  
  // 防止重复执行
  if (isInstalling) {
    console.log('安装操作正在进行中，请勿重复执行')
    return
  }
  
  if (selectedServices.value.length === 0) {
    console.log('No services selected, returning')
    return
  }
  
  // 设置安装标志
  isInstalling = true
  console.log('Starting installation process')
  
  // 保存选中的服务，因为closeInstallDialog会清空selectedServices
  const servicesToInstall = [...selectedServices.value]
  console.log('Services to install:', servicesToInstall)
  
  // 立即关闭安装弹窗
  closeInstallDialog()
  
  // 显示操作日志对话框
  showOperationLog.value = true
  loading.value = true
  opId.value = 'install-' + Date.now() // 生成唯一的操作ID
  logs.value = '开始安装服务...\n'
  
  // 安装结果收集
  const installResults = {
    success: [] as string[],
    failed: [] as string[]
  }
  
  // 根据选择的服务执行不同的安装操作
  try {
    for (const service of servicesToInstall) {
      console.log('Installing service:', service)
      logs.value += `\n正在安装 ${getServiceDisplayName(service)}...\n`
      
      try {
        let result
        switch (service) {
          case 'mail':
            console.log('Calling install-mail')
            result = await callWithoutPolling('install-mail')
            break
          case 'database':
            console.log('Calling install-database')
            result = await callWithoutPolling('install-database')
            break
          case 'dns':
            console.log('Calling install-dns')
            result = await callWithoutPolling('install-dns')
            break
          case 'security':
            console.log('Calling install-security')
            result = await callWithoutPolling('install-security')
            break
        }
        
        // 检查安装结果
        if (result && result.success) {
          installResults.success.push(service)
          console.log(`Service ${service} installed successfully`)
          logs.value += `✅ ${getServiceDisplayName(service)} 安装成功\n`
        } else {
          installResults.failed.push(service)
          console.log(`Service ${service} installation failed`)
          logs.value += `❌ ${getServiceDisplayName(service)} 安装失败\n`
        }
      } catch (error: any) {
        installResults.failed.push(service)
        console.error(`Service ${service} installation error:`, error)
        logs.value += `❌ ${getServiceDisplayName(service)} 安装出错: ${error?.message || '未知错误'}\n`
      }
    }
  } catch (error: any) {
    console.error('安装过程发生错误:', error)
    logs.value += `\n❌ 安装过程发生错误: ${error?.message || '未知错误'}\n`
  } finally {
    // 确保无论成功或失败都重置标志
    isInstalling = false
  }
  
  // 显示安装结果汇总
  console.log('Installation results:', installResults)
  
  // 在操作日志中显示安装结果汇总
  const summaryMessage = generateInstallSummary(installResults)
  console.log('Installation summary:', summaryMessage)
  
  // 将汇总信息添加到操作日志中
  if (logs.value) {
    logs.value += summaryMessage
  }
  
  // 如果有失败的服务，显示警告
  if (installResults.failed.length > 0) {
    console.warn('Some services failed to install:', installResults.failed)
    // 在日志中显示失败警告
    if (logs.value) {
      logs.value += `\n⚠️ 警告: ${installResults.failed.length}个服务安装失败，请检查操作日志了解详细错误信息\n`
    }
  } else {
    // 所有服务都安装成功
    if (logs.value) {
      logs.value += `\n🎉 所有服务安装完成！系统已准备就绪。\n`
    }
  }
  
  // 重置安装标志和加载状态
  isInstalling = false
  loading.value = false
  
  console.log('All services installation completed')
}

async function executeServiceAction() {
  console.log('executeServiceAction called')
  console.log('serviceAction:', serviceAction.value)
  console.log('selectedRestartServices:', selectedRestartServices.value)
  console.log('selectedRestartServices.length:', selectedRestartServices.value.length)
  
  if (selectedRestartServices.value.length === 0) {
    console.log('No services selected for', serviceAction.value, 'returning')
    return
  }
  
  console.log('Starting', serviceAction.value, 'process')
  
  // 保存选中的服务，因为closeServiceManagementDialog会清空selectedRestartServices
  const servicesToProcess = [...selectedRestartServices.value]
  console.log('Services to', serviceAction.value, ':', servicesToProcess)
  
  // 立即关闭服务管理弹窗
  closeServiceManagementDialog()
  
  // 显示操作日志对话框
  showOperationLog.value = true
  loading.value = true
  opId.value = (serviceAction.value === 'restart' ? 'restart-' : 'stop-') + Date.now() // 生成唯一的操作ID
  logs.value = `开始${serviceAction.value === 'restart' ? '重启' : '关闭'}服务...\n`
  
  // 操作结果收集
  const actionResults = {
    success: [] as string[],
    failed: [] as string[]
  }
  
  // 根据选择的服务执行不同的操作
  for (const service of servicesToProcess) {
    console.log(serviceAction.value === 'restart' ? 'Restarting' : 'Stopping', 'service:', service)
    logs.value += `\n正在${serviceAction.value === 'restart' ? '重启' : '关闭'} ${getRestartServiceDisplayName(service)}...\n`
    
    try {
      let result
      const action = serviceAction.value === 'restart' ? 'restart' : 'stop'
      
      switch (service) {
        case 'mail':
          console.log(`Calling ${action}-mail`)
          result = await callWithoutPolling(serviceAction.value === 'restart' ? 'restart-mail' : 'stop-mail')
          break
        case 'database':
          console.log(`Calling ${action}-database`)
          result = await callWithoutPolling(serviceAction.value === 'restart' ? 'restart-database' : 'stop-database')
          break
        case 'dns':
          console.log(`Calling ${action}-dns`)
          result = await callWithoutPolling(serviceAction.value === 'restart' ? 'restart-dns' : 'stop-dns')
          break
        case 'security':
          console.log(`Calling ${action}-security`)
          result = await callWithoutPolling(serviceAction.value === 'restart' ? 'restart-security' : 'stop-security')
          break
        case 'dispatcher':
          console.log(`Calling ${action}-dispatcher`)
          result = await callWithoutPolling(serviceAction.value === 'restart' ? 'restart-dispatcher' : 'stop-dispatcher')
          break
      }
      
      // 检查重启结果
      if (result && result.success) {
        actionResults.success.push(service)
        console.log(`Service ${service} ${serviceAction.value}ed successfully`)
        logs.value += `✅ ${getRestartServiceDisplayName(service)} ${serviceAction.value === 'restart' ? '重启' : '关闭'}成功\n`
      } else {
        actionResults.failed.push(service)
        console.log(`Service ${service} ${serviceAction.value} failed`)
        logs.value += `❌ ${getRestartServiceDisplayName(service)} ${serviceAction.value === 'restart' ? '重启' : '关闭'}失败\n`
      }
    } catch (error) {
      actionResults.failed.push(service)
      console.error(`Service ${service} ${serviceAction.value} error:`, error)
      logs.value += `❌ ${getRestartServiceDisplayName(service)} ${serviceAction.value === 'restart' ? '重启' : '关闭'}出错: ${error.message}\n`
    }
  }
  
  // 显示操作结果汇总
  console.log('Action results:', actionResults)
  
  // 在操作日志中显示操作结果汇总
  const summaryMessage = generateServiceActionSummary(actionResults, serviceAction.value)
  console.log('Action summary:', summaryMessage)
  
  // 将汇总信息添加到操作日志中
  if (logs.value) {
    logs.value += summaryMessage
  }
  
  // 如果有失败的服务，显示警告
  if (actionResults.failed.length > 0) {
    console.warn('Some services failed to', serviceAction.value, ':', actionResults.failed)
    // 在日志中显示失败警告
    if (logs.value) {
      logs.value += `\n⚠️ 警告: ${actionResults.failed.length}个服务${serviceAction.value === 'restart' ? '重启' : '关闭'}失败，请检查操作日志了解详细错误信息\n`
    }
  } else {
    // 所有服务都操作成功
    if (logs.value) {
      logs.value += `\n🎉 所有服务${serviceAction.value === 'restart' ? '重启' : '关闭'}完成！系统已准备就绪。\n`
    }
  }
  
  // 关闭加载状态
  loading.value = false
  
  console.log('All services restart completed')
}

// 生成安装结果汇总
function generateInstallSummary(results: { success: string[], failed: string[] }) {
  const { success, failed } = results
  let summary = '\n=== 服务安装结果汇总 ===\n'
  
  if (success.length > 0) {
    summary += `✅ 安装成功的服务 (${success.length}个):\n`
    success.forEach(service => {
      const serviceName = getServiceDisplayName(service)
      summary += `   • ${serviceName}\n`
    })
  }
  
  if (failed.length > 0) {
    summary += `❌ 安装失败的服务 (${failed.length}个):\n`
    failed.forEach(service => {
      const serviceName = getServiceDisplayName(service)
      summary += `   • ${serviceName}\n`
    })
  }
  
  summary += '========================\n'
  return summary
}

// 获取服务显示名称
function getServiceDisplayName(service: string): string {
  const serviceNames: { [key: string]: string } = {
    'mail': '邮件服务 (Postfix + Dovecot)',
    'database': '数据库服务 (MariaDB)',
    'dns': 'DNS服务 (Bind)',
    'security': '安全加固服务'
  }
  return serviceNames[service] || service
}

function getRestartServiceDisplayName(service: string): string {
  const serviceNames: { [key: string]: string } = {
    'mail': '邮件服务 (Postfix + Dovecot)',
    'database': '数据库服务 (MariaDB)',
    'dns': 'DNS服务 (Bind)',
    'security': '安全加固服务',
    'dispatcher': '调度层服务 (API调度器)'
  }
  return serviceNames[service] || service
}

function generateServiceActionSummary(results: { success: string[], failed: string[] }, action: 'restart' | 'stop') {
  const { success, failed } = results
  const actionText = action === 'restart' ? '重启' : '关闭'
  let summary = `\n=== 服务${actionText}结果汇总 ===\n`
  
  if (success.length > 0) {
    summary += `✅ ${actionText}成功的服务 (${success.length}个):\n`
    success.forEach(service => {
      summary += `• ${getRestartServiceDisplayName(service)}\n`
    })
  }
  
  if (failed.length > 0) {
    summary += `❌ ${actionText}失败的服务 (${failed.length}个):\n`
    failed.forEach(service => {
      summary += `• ${getRestartServiceDisplayName(service)}\n`
    })
  }
  
  summary += '=======================\n'
  return summary
}

async function openConfigDialog() {
  // 先确保系统设置已加载
  await loadSystemSettings()
  
  configDomain.value = ''
  configStep.value = 1
  dnsType.value = 'bind'
  configType.value = 'system' // 默认选择系统基本信息配置
  
  // 从系统设置中读取值（确保使用最新的值）
  systemName.value = systemSettings.value.general?.systemName || 'XM邮件管理系统'
  adminEmail.value = systemSettings.value.general?.adminEmail || 'xm@localhost'
  
  console.log('打开配置对话框，管理员邮箱:', adminEmail.value)
  console.log('系统设置中的管理员邮箱:', systemSettings.value.general?.adminEmail)
  
  showConfigDialog.value = true
}

function closeConfigDialog() {
  showConfigDialog.value = false
}

// 垃圾邮件过滤相关函数
async function openSpamFilterDialog() {
  showSpamFilterDialog.value = true
  await loadSpamFilterConfig()
}

function closeSpamFilterDialog() {
  showSpamFilterDialog.value = false
}

// 广播相关函数
async function openBroadcastDialog() {
  showBroadcastDialog.value = true
  await loadBroadcast()
}

function closeBroadcastDialog() {
  showBroadcastDialog.value = false
  broadcastMessage.value = ''
}

// 加载当前广播消息
async function loadBroadcast() {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      console.error('未找到认证信息')
      return
    }
    
    const response = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success && data.settings) {
        currentBroadcast.value = data.settings.broadcast?.message || ''
        broadcastMessage.value = currentBroadcast.value
      }
    }
  } catch (error) {
    console.error('加载广播消息失败:', error)
  }
}

// 保存广播消息
async function saveBroadcast() {
  if (!broadcastMessage.value.trim()) {
    notice.value = '请输入广播消息内容'
    noticeType.value = 'error'
    return
  }
  
  broadcastSaving.value = true
  notice.value = ''
  noticeType.value = 'info'
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      throw new Error('未找到认证信息，请重新登录')
    }
    
    // 获取当前系统设置
    const settingsResponse = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    let currentSettings = {}
    if (settingsResponse.ok) {
      const settingsData = await settingsResponse.json()
      if (settingsData.success && settingsData.settings) {
        currentSettings = settingsData.settings
      }
    }
    
    // 更新广播消息
    const updatedSettings = {
      ...currentSettings,
      broadcast: {
        message: broadcastMessage.value.trim(),
        updatedAt: new Date().toISOString()
      }
    }
    
    const saveResponse = await fetch('/api/system-settings', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ settings: updatedSettings })
    })
    
    if (saveResponse.ok) {
      const saveData = await saveResponse.json()
      if (saveData.success) {
        currentBroadcast.value = broadcastMessage.value.trim()
        notice.value = '广播消息已发布，所有用户将在邮件页面看到此消息'
        noticeType.value = 'success'
        setTimeout(() => {
          closeBroadcastDialog()
        }, 2000)
      } else {
        throw new Error(saveData.message || '保存失败')
      }
    } else {
      throw new Error('保存失败')
    }
  } catch (error) {
    console.error('保存广播消息失败:', error)
    notice.value = `保存失败: ${error instanceof Error ? error.message : '未知错误'}`
    noticeType.value = 'error'
  } finally {
    broadcastSaving.value = false
  }
}

// 显示清除广播消息确认对话框
function showClearBroadcastConfirmDialog() {
  showClearBroadcastConfirm.value = true
}

// 确认清除广播消息
async function confirmClearBroadcast() {
  showClearBroadcastConfirm.value = false
  
  broadcastSaving.value = true
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      throw new Error('未找到认证信息，请重新登录')
    }
    
    // 获取当前系统设置
    const settingsResponse = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    let currentSettings = {}
    if (settingsResponse.ok) {
      const settingsData = await settingsResponse.json()
      if (settingsData.success && settingsData.settings) {
        currentSettings = settingsData.settings
      }
    }
    
    // 清除广播消息
    const updatedSettings = {
      ...currentSettings,
      broadcast: {
        message: '',
        updatedAt: new Date().toISOString()
      }
    }
    
    const saveResponse = await fetch('/api/system-settings', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ settings: updatedSettings })
    })
    
    if (saveResponse.ok) {
      const saveData = await saveResponse.json()
      if (saveData.success) {
        currentBroadcast.value = ''
        broadcastMessage.value = ''
        notice.value = '广播消息已清除'
        noticeType.value = 'success'
      } else {
        throw new Error(saveData.message || '清除失败')
      }
    } else {
      throw new Error('清除失败')
    }
  } catch (error) {
    console.error('清除广播消息失败:', error)
    notice.value = `清除失败: ${error instanceof Error ? error.message : '未知错误'}`
    noticeType.value = 'error'
  } finally {
    broadcastSaving.value = false
  }
}

// 加载垃圾邮件过滤配置
async function loadSpamFilterConfig() {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      console.error('未找到认证信息，使用默认配置')
      // 使用默认配置
      spamKeywords.value = [
        { text: '免费', lang: 'cn' },
        { text: '赚钱', lang: 'cn' },
        { text: '投资', lang: 'cn' },
        { text: 'viagra', lang: 'en' },
        { text: 'casino', lang: 'en' }
      ]
      spamDomains.value = ['xmtest.com']
      spamFilterConfig.value = { minBodyLines: 0, maxCapsRatio: 0.8, maxExclamation: 6, maxSpecialChars: 8 }
      return
    }
    
    const response = await fetch('/api/spam-filter/config', {
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (!response.ok) {
      const errorText = await response.text()
      console.error('加载失败，响应状态:', response.status, '响应内容:', errorText)
      throw new Error(`HTTP ${response.status}: ${errorText}`)
    }
    
    const data = await response.json()
    console.log('加载响应数据:', data)
    
    if (data.success && data.data) {
      // 加载关键词
      const chineseKeywords = data.data.keywords?.chinese || []
      const englishKeywords = data.data.keywords?.english || []
      spamKeywords.value = [
        ...chineseKeywords.map((k: string) => ({ text: k, lang: 'cn' })),
        ...englishKeywords.map((k: string) => ({ text: k, lang: 'en' }))
      ]
      
      // 加载域名黑名单
      spamDomains.value = data.data.domainBlacklist || []
      
      // 加载过滤规则
      if (data.data.rules) {
        spamFilterConfig.value = {
          minBodyLines: data.data.rules.minContentLines || 0,
          maxCapsRatio: data.data.rules.uppercaseRatio || 0.8,
          maxExclamation: data.data.rules.maxExclamationMarks || 6,
          maxSpecialChars: data.data.rules.maxSpecialChars || 8
        }
      }
      
      console.log('垃圾邮件过滤配置加载成功:', {
        keywords: spamKeywords.value.length,
        domains: spamDomains.value.length,
        rules: spamFilterConfig.value
      })
    } else {
      throw new Error(data.message || '加载配置失败')
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
    spamDomains.value = ['xmtest.com']
    spamFilterConfig.value = { minBodyLines: 0, maxCapsRatio: 0.8, maxExclamation: 6, maxSpecialChars: 8 }
  }
}

// 添加垃圾邮件关键词
function addSpamKeyword() {
  if (newSpamKeyword.value.trim()) {
    spamKeywords.value.push({
      text: newSpamKeyword.value.trim(),
      lang: newSpamKeywordLang.value
    })
    newSpamKeyword.value = ''
  }
}

// 删除垃圾邮件关键词
function removeSpamKeyword(index: number) {
  spamKeywords.value.splice(index, 1)
}

// 添加垃圾邮件域名
function addSpamDomain() {
  if (newSpamDomain.value.trim()) {
    spamDomains.value.push(newSpamDomain.value.trim())
    newSpamDomain.value = ''
  }
}

// 删除垃圾邮件域名
function removeSpamDomain(index: number) {
  spamDomains.value.splice(index, 1)
}

// 保存垃圾邮件过滤配置
async function saveSpamFilterConfig() {
  spamFilterSaving.value = true
  notice.value = ''
  noticeType.value = 'info'
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      throw new Error('未找到认证信息，请重新登录')
    }
    
    // 准备配置数据
    const keywords = {
      chinese: spamKeywords.value.filter(k => k.lang === 'cn').map(k => k.text),
      english: spamKeywords.value.filter(k => k.lang === 'en').map(k => k.text)
    }
    
    const configData = {
      keywords,
      domainBlacklist: spamDomains.value || [],
      emailBlacklist: [], // 暂时不支持邮箱黑名单
      rules: {
        minContentLines: spamFilterConfig.value.minBodyLines || 0,
        uppercaseRatio: spamFilterConfig.value.maxCapsRatio || 0.8,
        maxExclamationMarks: spamFilterConfig.value.maxExclamation || 6,
        maxSpecialChars: spamFilterConfig.value.maxSpecialChars || 8
      }
    }
    
    console.log('[保存配置] 准备保存的数据:', JSON.stringify(configData, null, 2))
    console.log('[保存配置] 关键词数量 - 中文:', keywords.chinese.length, '英文:', keywords.english.length)
    console.log('[保存配置] 域名黑名单数量:', configData.domainBlacklist.length)
    
    // 显示保存中提示
    notice.value = '正在保存配置...'
    noticeType.value = 'info'
    
    const response = await fetch('/api/spam-filter/config', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify(configData)
    })
    
    console.log('[保存配置] HTTP响应状态:', response.status, response.statusText)
    
    // 获取响应文本（可能是JSON或错误文本）
    const responseText = await response.text()
    console.log('[保存配置] 响应内容:', responseText)
    
    if (!response.ok) {
      // 尝试解析为JSON
      let errorMessage = responseText
      try {
        const errorData = JSON.parse(responseText)
        errorMessage = errorData.message || errorData.error || responseText
      } catch (e) {
        // 如果不是JSON，直接使用响应文本
      }
      console.error('[保存配置] 保存失败:', {
        status: response.status,
        statusText: response.statusText,
        message: errorMessage
      })
      throw new Error(`保存失败 (${response.status}): ${errorMessage}`)
    }
    
    // 解析响应JSON
    let data
    try {
      data = JSON.parse(responseText)
    } catch (e) {
      console.error('[保存配置] 解析响应JSON失败:', e)
      throw new Error('服务器响应格式错误')
    }
    
    console.log('[保存配置] 解析后的响应数据:', data)
    
    if (data.success) {
      // 显示成功消息
      notice.value = '垃圾邮件过滤配置保存成功！'
      noticeType.value = 'success'
      console.log('[保存配置] 保存成功')
      
      // 延迟关闭对话框，让用户看到成功消息
      setTimeout(() => {
        closeSpamFilterDialog()
        // 3秒后清除通知
        setTimeout(() => {
          notice.value = ''
        }, 3000)
      }, 1500)
    } else {
      const errorMsg = data.message || data.error || '保存失败'
      console.error('[保存配置] 服务器返回失败:', errorMsg)
      throw new Error(errorMsg)
    }
  } catch (error) {
    console.error('[保存配置] 异常捕获:', error)
    console.error('[保存配置] 错误堆栈:', error instanceof Error ? error.stack : '无堆栈信息')
    
    // 显示详细的错误信息
    let errorMessage = '保存失败'
    if (error instanceof Error) {
      errorMessage = error.message
    } else if (typeof error === 'string') {
      errorMessage = error
    } else {
      errorMessage = '未知错误: ' + JSON.stringify(error)
    }
    
    notice.value = `保存失败: ${errorMessage}`
    noticeType.value = 'error'
    
    // 5秒后清除错误消息
    setTimeout(() => {
      if (noticeType.value === 'error') {
        notice.value = ''
      }
    }, 5000)
  } finally {
    spamFilterSaving.value = false
  }
}

// 测试垃圾邮件过滤
async function testSpamFilter() {
  try {
    const auth = sessionStorage.getItem('apiAuth')
    if (!auth) {
      throw new Error('未找到认证信息')
    }
    
    // 测试邮件内容
    const testData = {
      subject: '免费赚钱！投资机会！',
      content: '这是一个测试邮件，包含垃圾邮件关键词：免费、赚钱、投资。',
      from: 'test@spam.com',
      to: 'test@example.com'
    }
    
    const response = await fetch('/api/spam-filter/check', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${auth}`
      },
      body: JSON.stringify(testData)
    })
    
    const data = await response.json()
    if (data.success) {
      if (data.isSpam) {
        const violations = data.violations?.map((v: any) => v.message).join('\n') || '无'
        const keywords = data.detectedKeywords?.join(', ') || '无'
        notice.value = `垃圾邮件检测成功！\n\n检测结果：垃圾邮件\n垃圾邮件评分：${data.spamScore}\n违规详情：${violations}\n检测到的关键词：${keywords}`
        noticeType.value = 'warning'
      } else {
        notice.value = '垃圾邮件检测成功！\n\n检测结果：正常邮件'
        noticeType.value = 'success'
      }
    } else {
      throw new Error(data.message || '测试失败')
    }
  } catch (error) {
    console.error('测试垃圾邮件过滤失败:', error)
    notice.value = '测试失败，请重试: ' + (error instanceof Error ? error.message : '未知错误')
    noticeType.value = 'error'
  }
}

function proceedConfigNext() {
  if (!configDomain.value) return
  configStep.value = 2
}

async function executeConfigure() {
  console.log('executeConfigure called')
  console.log('configType:', configType.value)
  console.log('dnsType:', dnsType.value)
  console.log('configDomain:', configDomain.value)
  
  // 立即关闭配置弹窗
  showConfigDialog.value = false
  
  // 显示操作日志对话框
  showOperationLog.value = true
  loading.value = true
  opId.value = 'configure-' + Date.now() // 生成唯一的操作ID
  
  if (configType.value === 'system') {
    // 系统基本信息配置
    logs.value = '开始配置系统基本信息...\n'
    
    try {
      logs.value += `系统名称: ${systemName.value.trim()}\n`
      logs.value += `管理员邮箱: ${adminEmail.value.trim()}\n`
      
      // 调用系统设置API
      const response = await fetch('/api/system-settings', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
        },
        body: JSON.stringify({
          settings: {
            general: {
              systemName: systemName.value.trim(),
              adminEmail: adminEmail.value.trim()
            }
          }
        })
      })
      
      const result = await response.json()
      if (result.success) {
        logs.value += `\n✅ 系统基本信息配置成功！\n`
        notice.value = '系统基本信息配置成功！'
        noticeType.value = 'success'
        
        // 更新本地设置
        systemSettings.value.general.systemName = systemName.value.trim()
        systemSettings.value.general.adminEmail = adminEmail.value.trim()
        
        // 重新加载系统设置以确保前端显示最新的管理员邮箱（现在后端会从数据库读取）
        try {
          await loadSystemSettings()
          logs.value += `\n✅ 系统设置已重新加载，管理员邮箱: ${systemSettings.value.general?.adminEmail}\n`
        } catch (reloadError) {
          logs.value += `\n⚠️ 系统设置重新加载失败，但本地已更新\n`
          console.warn('系统设置重新加载失败:', reloadError)
        }
      } else {
        throw new Error((result as any).error || '系统配置失败')
      }
    } catch (error) {
      logs.value += `\n❌ 系统配置失败: ${error.message}\n`
      console.error('System configuration failed:', error)
      notice.value = '系统配置失败'
      noticeType.value = 'error'
    } finally {
      loading.value = false
    }
  } else if (configType.value === 'dns') {
    // DNS配置
    logs.value = '开始配置DNS服务...\n'
    
    try {
      // 根据DNS类型调用不同的配置方法
      if (dnsType.value === 'bind') {
        console.log('Configuring bind DNS')
        logs.value += `\n正在配置本地DNS (Bind)...\n`
        
        // 获取当前服务器IP
        const serverIp = await getServerIP()
        
        if (!serverIp) {
          logs.value += `\n❌ 无法自动获取服务器IP地址，请手动输入\n`
          notice.value = '无法自动获取服务器IP地址，请手动输入服务器IP'
          noticeType.value = 'error'
          return
        }
        
        logs.value += `\n✅ 获取到服务器IP: ${serverIp}\n`
        
        // 直接调用DNS配置API
        const dnsResponse = await fetch('/api/dns/configure', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
          },
          body: JSON.stringify({
            domain: configDomain.value.trim(),
            serverIp: serverIp,
            adminEmail: `xm@${configDomain.value.trim()}`,
            enableRecursion: true,
            enableForwarding: true,
            upstreamDns: '8.8.8.8, 1.1.1.1'
          })
        })
        
        const dnsResult = await dnsResponse.json()
        if (!dnsResult.success) {
          throw new Error(dnsResult.error || 'DNS配置失败')
        }
        
        logs.value += `\nDNS配置API调用成功，操作ID: ${dnsResult.opId}\n`
        
        // 等待DNS配置脚本执行完成
        if (dnsResult.opId) {
          logs.value += `\n正在等待DNS配置脚本执行...\n`
          
          // 轮询检查执行状态
          const maxWaitTime = 60000 // 60秒
          const checkInterval = 2000 // 2秒检查一次
          let waitTime = 0
          
          while (waitTime < maxWaitTime) {
            await new Promise(resolve => setTimeout(resolve, checkInterval))
            waitTime += checkInterval
            
            try {
              const logResponse = await fetch(`/api/ops/${dnsResult.opId}/log`, {
                headers: {
                  'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
                }
              })
              const logContent = await logResponse.text()
              
              // 更新日志显示
              logs.value = logContent
              
              // 检查是否完成
              if (logContent.includes('OPERATION_END') ||
                  logContent.includes('DNS配置完成') ||
                  logContent.includes('脚本执行完成') ||
                  logContent.includes('Bind DNS配置完成')) {
                logs.value += `\n✅ DNS配置完成！\n`
                // DNS配置成功后刷新管理员邮箱显示
                if ((window as any).refreshAdminEmail) {
                  (window as any).refreshAdminEmail()
                }
                break
              }
              
              // 检查是否有严重错误（只检查退出码，忽略警告信息）
              // 如果日志中包含"Exit code: 1"且不是警告信息，则判定为失败
              if (logContent.includes('OPERATION_END') && logContent.includes('Exit code: 1')) {
                // 检查是否在OPERATION_END行中，而不是警告信息中
                const operationEndMatch = logContent.match(/\[OPERATION_END\].*Exit code: (\d+)/);
                if (operationEndMatch && operationEndMatch[1] === '1') {
                  logs.value += `\n❌ DNS配置失败（退出码: 1）\n`
                  break
                }
              }
              
            } catch (logError) {
              console.error('获取日志失败:', logError)
              logs.value += `\n获取执行日志失败: ${logError.message}\n`
            }
          }
          
          if (waitTime >= maxWaitTime) {
            logs.value += `\n⚠️ DNS配置超时，请检查系统状态\n`
          }
        }
        
        console.log('DNS configuration completed')
      } else if (dnsType.value === 'public') {
        console.log('Configuring public DNS')
        logs.value += `\n正在配置公网DNS...\n`
        
        // 获取当前服务器IP
        const serverIp = await getServerIP()
        
        if (!serverIp) {
          logs.value += `\n❌ 无法自动获取服务器IP地址，请手动输入\n`
          notice.value = '无法自动获取服务器IP地址，请手动输入服务器IP'
          noticeType.value = 'error'
          return
        }
        
        logs.value += `\n✅ 获取到服务器IP: ${serverIp}\n`
        
        // 调用公网DNS配置API
        const publicDnsResponse = await fetch('/api/dns/public-configure', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
          },
          body: JSON.stringify({
            domain: configDomain.value.trim(),
            serverIp: serverIp
          })
        })
        
        const publicDnsResult = await publicDnsResponse.json()
        if (!publicDnsResult.success) {
          throw new Error(publicDnsResult.error || '公网DNS配置失败')
        }
        
        logs.value += `\n公网DNS配置API调用成功，操作ID: ${publicDnsResult.opId}\n`
        
        // 等待公网DNS配置脚本执行完成
        if (publicDnsResult.opId) {
          logs.value += `\n正在等待公网DNS配置脚本执行...\n`
          
          // 轮询检查执行状态
          const maxWaitTime = 60000 // 60秒
          const checkInterval = 2000 // 2秒检查一次
          let waitTime = 0
          
          while (waitTime < maxWaitTime) {
            await new Promise(resolve => setTimeout(resolve, checkInterval))
            waitTime += checkInterval
            
            try {
              const logResponse = await fetch(`/api/ops/${publicDnsResult.opId}/log`, {
                headers: {
                  'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
                }
              })
              const logContent = await logResponse.text()
              
              // 更新日志显示
              logs.value = logContent
              
              // 检查是否完成
              if (logContent.includes('OPERATION_END') ||
                  logContent.includes('公网DNS配置完成') ||
                  logContent.includes('脚本执行完成') ||
                  logContent.includes('Apache配置更新完成')) {
                logs.value += `\n✅ 公网DNS配置完成！\n`
                // 公网DNS配置成功后刷新管理员邮箱显示
                if ((window as any).refreshAdminEmail) {
                  (window as any).refreshAdminEmail()
                }
                break
              }
              
              // 检查是否有严重错误
              if (logContent.includes('Exit code: 1') || 
                  logContent.includes('公网DNS配置失败') ||
                  logContent.includes('脚本执行失败')) {
                logs.value += `\n❌ 公网DNS配置失败\n`
                break
              }
              
            } catch (logError) {
              console.error('获取日志失败:', logError)
              logs.value += `\n获取执行日志失败: ${logError.message}\n`
            }
          }
          
          if (waitTime >= maxWaitTime) {
            logs.value += `\n⚠️ 公网DNS配置超时，请检查系统状态\n`
          }
        }
        
        console.log('Public DNS configuration completed')
      }
    } catch (error) {
      logs.value += `\n❌ DNS配置失败: ${error.message}\n`
      console.error('DNS configuration failed:', error)
    } finally {
      // 关闭加载状态
      loading.value = false
    }
  }
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

// 获取服务器IP地址
async function getServerIP() {
  try {
    const response = await fetch('/api/system-status', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    const data = await response.json()
    
    if (data.success && data.data?.systemInfo?.serverIP) {
      console.log('获取到服务器IP:', data.data.systemInfo.serverIP)
      return data.data.systemInfo.serverIP
    } else {
      console.warn('API响应中没有服务器IP信息:', data)
      // 尝试使用备用方法获取IP
      return await getServerIPFallback()
    }
  } catch (error) {
    console.error('获取服务器IP失败:', error)
    // 尝试使用备用方法获取IP
    return await getServerIPFallback()
  }
}

// 备用方法获取服务器IP
async function getServerIPFallback() {
  try {
    // 尝试从系统设置API获取
    const response = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    const data = await response.json()
    
    if (data.success && data.settings?.dns?.bind?.serverIp) {
      console.log('从系统设置获取到服务器IP:', data.settings.dns.bind.serverIp)
      return data.settings.dns.bind.serverIp
    }
  } catch (error) {
    console.error('备用方法获取服务器IP失败:', error)
  }
  
  // 如果所有方法都失败，返回null让用户手动输入
  console.error('无法自动获取服务器IP，请手动输入')
  return null
}

</script>

<style scoped>
/* 浮动动画 */
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

/* 系统管理按钮专用动画 */
@keyframes bounce-in {
  0% { 
    opacity: 0; 
    transform: scale(0.3) translateY(-50px); 
  }
  50% { 
    opacity: 1; 
    transform: scale(1.05) translateY(0px); 
  }
  70% { 
    transform: scale(0.95); 
  }
  100% { 
    opacity: 1; 
    transform: scale(1); 
  }
}

.animate-bounce-in {
  animation: bounce-in 0.6s ease-out forwards;
}

/* 淡入上移动画 */
@keyframes fade-in-up {
  0% {
    opacity: 0;
    transform: translateY(30px);
  }
  100% {
    opacity: 1;
    transform: translateY(0);
  }
}

/* 从左滑入动画 */
@keyframes slide-in-left {
  0% {
    opacity: 0;
    transform: translateX(-30px);
  }
  100% {
    opacity: 1;
    transform: translateX(0);
  }
}

/* 网格背景 */
.bg-grid-pattern {
  background-image: 
    linear-gradient(rgba(0, 0, 0, 0.1) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 0, 0, 0.1) 1px, transparent 1px);
  background-size: 20px 20px;
}

/* 应用动画类 */
.animate-float {
  animation: float 6s ease-in-out infinite;
}

.animate-float-delayed {
  animation: float-delayed 8s ease-in-out infinite;
}

.animate-float-slow {
  animation: float-slow 10s ease-in-out infinite;
}

.animate-float-reverse {
  animation: float-reverse 7s ease-in-out infinite;
}

.animate-fade-in-up {
  animation: fade-in-up 0.8s ease-out;
}

.animate-slide-in-left {
  animation: slide-in-left 0.6s ease-out;
}

/* 按钮悬停效果 */
.group:hover svg {
  transform: scale(1.1);
  transition: transform 0.3s ease;
}

/* 卡片悬停效果 */
.bg-white\/80:hover {
  transform: translateY(-2px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
  transition: all 0.3s ease;
}

/* 淡入动画 */
@keyframes fade-in {
  0% { opacity: 0; }
  100% { opacity: 1; }
}

/* 缩放进入动画 */
@keyframes scale-in {
  0% {
    opacity: 0;
    transform: scale(0.9);
  }
  100% {
    opacity: 1;
    transform: scale(1);
  }
}

/* 应用动画类 */
.animate-fade-in {
  animation: fade-in 0.3s ease-out;
}

.animate-scale-in {
  animation: scale-in 0.3s ease-out;
}

/* 按钮组悬停效果 */
.group:hover {
  transform: translateY(-1px);
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
}

/* 高级功能卡片悬停效果 - 现代简洁风格 */
.advanced-feature-card {
  position: relative;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  overflow: hidden;
}

/* 背景装饰图案 - 使用::after伪元素 */
.advanced-feature-card::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  opacity: 0.04;
  background-image: 
    repeating-linear-gradient(
      45deg,
      transparent,
      transparent 10px,
      currentColor 10px,
      currentColor 11px
    ),
    repeating-linear-gradient(
      -45deg,
      transparent,
      transparent 10px,
      currentColor 10px,
      currentColor 11px
    );
  background-size: 40px 40px;
  pointer-events: none;
  z-index: 0;
  transition: opacity 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  mask-image: radial-gradient(ellipse at center, black 40%, transparent 70%);
  -webkit-mask-image: radial-gradient(ellipse at center, black 40%, transparent 70%);
}

.advanced-feature-card-amber::after {
  color: #f59e0b;
}

.advanced-feature-card-green::after {
  color: #10b981;
}

.advanced-feature-card-blue::after {
  color: #3b82f6;
}

.advanced-feature-card-purple::after {
  color: #8b5cf6;
}

.advanced-feature-card-orange::after {
  color: #f97316;
}

.advanced-feature-card-blue::after {
  color: #3b82f6;
}

.advanced-feature-card:hover::after {
  opacity: 0.08;
}

/* 顶部渐变条 - 使用::before伪元素 */
.advanced-feature-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 3px;
  transform-origin: left;
  transform: scaleX(0);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  z-index: 1;
  border-radius: 0.75rem 0.75rem 0 0;
}

.advanced-feature-card-amber::before {
  background: linear-gradient(to right, #f59e0b, #f97316);
}

.advanced-feature-card-green::before {
  background: linear-gradient(to right, #10b981, #14b8a6);
}

.advanced-feature-card-blue::before {
  background: linear-gradient(to right, #3b82f6, #2563eb);
}

.advanced-feature-card-purple::before {
  background: linear-gradient(to right, #8b5cf6, #a855f7);
}

.advanced-feature-card-orange::before {
  background: linear-gradient(to right, #f97316, #ef4444);
}

.advanced-feature-card-blue::before {
  background: linear-gradient(to right, #3b82f6, #2563eb);
}

/* 卡片悬停效果 */
.advanced-feature-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.15), 0 10px 10px -5px rgba(0, 0, 0, 0.1);
}

.advanced-feature-card-amber:hover {
  border-color: #f59e0b;
  background: white;
}

.advanced-feature-card-green:hover {
  border-color: #10b981;
  background: white;
}

.advanced-feature-card-blue:hover {
  border-color: #3b82f6;
  background: white;
}

.advanced-feature-card-purple:hover {
  border-color: #8b5cf6;
  background: white;
}

.advanced-feature-card-orange:hover {
  border-color: #f97316;
  background: white;
}

.advanced-feature-card-blue:hover {
  border-color: #3b82f6;
  background: white;
}

.advanced-feature-card:hover::before {
  transform: scaleX(1);
}

/* 图标容器 */
.advanced-feature-icon-wrapper {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.advanced-feature-card:hover .advanced-feature-icon-wrapper {
  transform: scale(1.1);
}

/* 图标旋转缩放 */
.advanced-feature-icon {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.advanced-feature-card:hover .advanced-feature-icon {
  transform: rotate(10deg);
}

/* 文字放大 */
.advanced-feature-text {
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1), color 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.advanced-feature-card:hover .advanced-feature-text {
  transform: scale(1.05);
}

.advanced-feature-card-amber:hover .advanced-feature-text {
  color: #f59e0b;
}

.advanced-feature-card-green:hover .advanced-feature-text {
  color: #10b981;
}

.advanced-feature-card-blue:hover .advanced-feature-text {
  color: #3b82f6;
}

.advanced-feature-card-purple:hover .advanced-feature-text {
  color: #8b5cf6;
}

.advanced-feature-card-orange:hover .advanced-feature-text {
  color: #f97316;
}

.advanced-feature-card-blue:hover .advanced-feature-text {
  color: #3b82f6;
}

/* 禁用状态 */
.advanced-feature-card:disabled:hover {
  transform: none;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  border-color: #e5e7eb;
  background: white;
}

.advanced-feature-card:disabled:hover::before {
  transform: scaleX(0);
}

.advanced-feature-card:disabled:hover .advanced-feature-icon-wrapper {
  transform: none;
  background: #f9fafb;
}

.advanced-feature-card:disabled:hover .advanced-feature-icon {
  transform: none;
}

.advanced-feature-card:disabled:hover .advanced-feature-text {
  transform: none;
  color: #9ca3af;
}

/* 状态指示器动画 */
@keyframes pulse-dot {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.5; }
}

.animate-pulse-dot {
  animation: pulse-dot 2s ease-in-out infinite;
}
</style>

