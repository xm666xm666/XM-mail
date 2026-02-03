<template>
  <Layout>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 via-blue-50 to-purple-50 py-4 sm:py-8">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <!-- 页面标题 -->
        <div class="mb-4 sm:mb-8">
          <h1 class="text-xl sm:text-2xl lg:text-3xl font-bold text-gray-900 flex items-center">
            <div class="p-2 sm:p-3 bg-gradient-to-r from-purple-500 to-pink-500 rounded-lg sm:rounded-xl mr-2 sm:mr-4">
              <svg class="h-5 w-5 sm:h-6 sm:w-6 lg:h-8 lg:w-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
              </svg>
            </div>
            系统设置
          </h1>
          <p class="text-gray-600 mt-1 sm:mt-2 text-xs sm:text-sm">配置系统参数和高级选项</p>
        </div>

        <!-- 加载状态 -->
        <div v-if="settingsLoading" class="flex items-center justify-center py-12">
          <svg class="animate-spin h-12 w-12 text-purple-600" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <span class="ml-3 text-gray-600 text-lg">加载设置中...</span>
        </div>

        <!-- 错误提示 -->
        <div v-if="settingsError" class="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
          <div class="flex items-center">
            <svg class="h-5 w-5 text-red-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <span class="text-sm text-red-600">{{ settingsError }}</span>
          </div>
        </div>

        <!-- 成功提示 -->
        <div v-if="settingsSuccess" class="mb-6 p-4 bg-green-50 border border-green-200 rounded-lg">
          <div class="flex items-center">
            <svg class="h-5 w-5 text-green-400 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
            </svg>
            <span class="text-sm text-green-600">设置保存成功！</span>
          </div>
        </div>

        <!-- 设置内容 -->
        <div v-if="!settingsLoading" class="space-y-4 sm:space-y-6">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 sm:gap-6">
            <!-- 常规设置 -->
            <div class="bg-gradient-to-br from-blue-50 to-indigo-50 p-4 sm:p-6 rounded-lg sm:rounded-xl border border-blue-200 shadow-lg">
              <div class="flex items-center mb-3 sm:mb-4">
                <div class="p-1.5 sm:p-2 bg-blue-100 rounded-lg">
                  <svg class="h-5 w-5 sm:h-6 sm:w-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                  </svg>
                </div>
                <h4 class="ml-2 sm:ml-3 text-base sm:text-lg font-semibold text-gray-900">常规设置</h4>
              </div>
              
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">系统名称</label>
                  <input :value="systemSettings.general.systemName" type="text" readonly disabled class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-600 cursor-not-allowed">
                  <p class="text-xs text-gray-500 mt-1">系统名称不可修改</p>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">管理员邮箱</label>
                  <input v-model="systemSettings.general.adminEmail" type="email" readonly class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100 text-gray-600 cursor-not-allowed">
                  <p class="text-xs text-gray-500 mt-1">管理员邮箱由系统自动设置</p>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">用户分页大小</label>
                  <div class="relative">
                    <select v-model="systemSettings.general.userPageSize" @change.stop="handleUserPageSizeChange" @input.stop="handleUserPageSizeChange" @click.stop :disabled="settingsSaving" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed cursor-pointer">
                      <option value="5">5 条/页</option>
                      <option value="10">10 条/页</option>
                      <option value="15">15 条/页</option>
                      <option value="20">20 条/页</option>
                      <option value="25">25 条/页</option>
                      <option value="50">50 条/页</option>
                    </select>
                    <div v-if="settingsSaving" class="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                      <svg class="animate-spin h-4 w-4 text-blue-600" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                    </div>
                  </div>
                  <p class="text-xs text-gray-500 mt-1">
                    <span v-if="settingsSaving" class="text-blue-600">正在保存设置...</span>
                    <span v-else>设置用户列表每页显示的用户数量</span>
                  </p>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">时区</label>
                  <div class="relative">
                    <select v-model="systemSettings.general.timezone" @change.stop="onTimezoneChange" @input.stop="onTimezoneChange" @click.stop :disabled="timezoneSaving" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed cursor-pointer">
                      <optgroup v-for="(timezones, region) in availableTimezones" :key="region" :label="region">
                        <option v-for="timezone in timezones" :key="timezone" :value="timezone">{{ timezone }}</option>
                      </optgroup>
                    </select>
                    <div v-if="timezoneLoading || timezoneSaving" class="absolute right-3 top-1/2 transform -translate-y-1/2 pointer-events-none">
                      <svg class="animate-spin h-4 w-4 text-blue-600" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                    </div>
                  </div>
                  <p class="text-xs text-gray-500 mt-1">
                    <span v-if="timezoneSaving" class="text-blue-600">正在修改时区，请稍候...</span>
                    <span v-else>当前系统时区: {{ currentSystemTimezone }}</span>
                  </p>
                </div>
                
                <!-- 备案号设置 -->
                <div class="pt-4 border-t border-blue-200">
                  <div class="flex items-center justify-between mb-3">
                    <div>
                      <label class="text-sm font-medium text-gray-700">显示备案号</label>
                      <p class="text-xs text-gray-500">在页面底部显示ICP备案号</p>
                    </div>
                    <label class="relative inline-flex items-center cursor-pointer">
                      <input v-model="systemSettings.general.icp.enabled" 
                             @change="saveSystemSettings()"
                             type="checkbox" 
                             class="sr-only peer">
                      <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                    </label>
                  </div>
                  <div v-if="systemSettings.general.icp.enabled" class="space-y-3">
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">备案号</label>
                      <input v-model="systemSettings.general.icp.number" 
                             @change="saveSystemSettings()"
                             @blur="saveSystemSettings()"
                             type="text" 
                             placeholder="例如：京ICP备12345678号"
                             class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                      <p class="text-xs text-gray-500 mt-1">
                        <span v-if="settingsSaving" class="text-blue-600">正在保存设置...</span>
                        <span v-else>请输入完整的ICP备案号</span>
                      </p>
                    </div>
                    <div>
                      <label class="block text-sm font-medium text-gray-700 mb-1">备案号链接</label>
                      <input v-model="systemSettings.general.icp.url" 
                             @change="saveSystemSettings()"
                             @blur="saveSystemSettings()"
                             type="url" 
                             placeholder="https://beian.miit.gov.cn/"
                             class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                      <p class="text-xs text-gray-500 mt-1">
                        <span v-if="settingsSaving" class="text-blue-600">正在保存设置...</span>
                        <span v-else>点击备案号时跳转的链接地址（默认：工信部备案查询网站）</span>
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            
            <!-- 安全设置 -->
            <div class="bg-gradient-to-br from-red-50 to-pink-50 p-4 sm:p-6 rounded-lg sm:rounded-xl border border-red-200 shadow-lg">
              <div class="flex items-center mb-3 sm:mb-4">
                <div class="p-1.5 sm:p-2 bg-red-100 rounded-lg">
                  <svg class="h-5 w-5 sm:h-6 sm:w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
                  </svg>
                </div>
                <h4 class="ml-2 sm:ml-3 text-base sm:text-lg font-semibold text-gray-900">安全设置</h4>
              </div>
              
              <div class="space-y-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">会话超时（分钟）</label>
                  <input v-model.number="systemSettings.security.sessionTimeout" 
                         @change="saveSystemSettings()"
                         @blur="saveSystemSettings()"
                         type="number" 
                         min="5" 
                         max="1440" 
                         class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent">
                  <p class="text-xs text-gray-500 mt-1">
                    <span v-if="settingsSaving" class="text-blue-600">正在保存设置...</span>
                    <span v-else>用户无操作后自动登出的时间（5-1440分钟）</span>
                  </p>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">最大登录尝试次数</label>
                  <input v-model.number="systemSettings.security.maxLoginAttempts" 
                         @change="saveSystemSettings()"
                         @blur="saveSystemSettings()"
                         type="number" 
                         min="3" 
                         max="20" 
                         class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent">
                  <p class="text-xs text-gray-500 mt-1">
                    <span v-if="settingsSaving" class="text-blue-600">正在保存设置...</span>
                    <span v-else>超过此次数后账户将被临时锁定（3-20次）</span>
                  </p>
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-1">密码最小长度</label>
                  <input v-model.number="systemSettings.security.passwordMinLength" 
                         @change="saveSystemSettings()"
                         @blur="saveSystemSettings()"
                         type="number" 
                         min="6" 
                         max="32" 
                         class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent">
                  <p class="text-xs text-gray-500 mt-1">
                    <span v-if="settingsSaving" class="text-blue-600">正在保存设置...</span>
                    <span v-else>用户密码的最小字符数（6-32个字符）</span>
                  </p>
                </div>
                
                <div class="flex items-center justify-between">
                  <div>
                    <label class="text-sm font-medium text-gray-700">要求特殊字符</label>
                    <p class="text-xs text-gray-500">密码必须包含大小写字母、数字和特殊字符</p>
                  </div>
                  <label class="relative inline-flex items-center cursor-pointer">
                    <input v-model="systemSettings.security.requireSpecialChars" 
                           @change="saveSystemSettings()"
                           type="checkbox" 
                           class="sr-only peer">
                    <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-red-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-red-600"></div>
                  </label>
                </div>
                
              </div>
            </div>
          </div>
          
          <!-- 邮件设置 -->
          <div class="bg-gradient-to-br from-green-50 to-emerald-50 p-6 rounded-xl border border-green-200 shadow-lg">
            <div class="flex items-center mb-4">
              <div class="p-2 bg-green-100 rounded-lg">
                <svg class="h-6 w-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
                </svg>
              </div>
              <h4 class="ml-3 text-lg font-semibold text-gray-900">邮件设置</h4>
            </div>
            
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">邮件分页大小</label>
                <div class="relative">
                  <select v-model="systemSettings.mail.pageSize" @change="saveMailSettings" :disabled="mailSettingsSaving" class="mt-1 block w-full border border-gray-300 rounded-md px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed">
                    <option value="5">5 条/页</option>
                    <option value="8">8 条/页</option>
                    <option value="10">10 条/页</option>
                    <option value="15">15 条/页</option>
                    <option value="20">20 条/页</option>
                    <option value="25">25 条/页</option>
                  </select>
                  <div v-if="mailSettingsSaving" class="absolute right-3 top-1/2 transform -translate-y-1/2">
                    <svg class="animate-spin h-4 w-4 text-green-600" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  <span v-if="mailSettingsSaving" class="text-green-600">正在保存设置...</span>
                  <span v-else>设置邮件列表每页显示的邮件数量</span>
                </p>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">最大邮箱大小（MB）</label>
                <div class="relative">
                  <input v-model.number="systemSettings.mail.maxMailboxSize" @change="saveMailSettings" :disabled="mailSettingsSaving" type="number" min="100" max="10000" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed">
                  <div v-if="mailSettingsSaving" class="absolute right-3 top-1/2 transform -translate-y-1/2">
                    <svg class="animate-spin h-4 w-4 text-green-600" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  <span v-if="mailSettingsSaving" class="text-green-600">正在应用设置...</span>
                  <span v-else>设置单个用户邮箱的最大存储空间</span>
                </p>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">最大邮件大小（MB）</label>
                <div class="relative">
                  <input v-model.number="systemSettings.mail.maxMessageSize" @change="saveMailSettings" :disabled="mailSettingsSaving" type="number" min="1" max="100" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed">
                  <div v-if="mailSettingsSaving" class="absolute right-3 top-1/2 transform -translate-y-1/2">
                    <svg class="animate-spin h-4 w-4 text-green-600" fill="none" viewBox="0 0 24 24">
                      <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                      <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                  </div>
                </div>
                <p class="text-xs text-gray-500 mt-1">
                  <span v-if="mailSettingsSaving" class="text-green-600">正在应用设置...</span>
                  <span v-else>设置单封邮件的最大大小限制</span>
                </p>
              </div>
              
              <!-- 域名管理 -->
              <div class="border-t border-green-200 pt-4">
                <div class="flex items-center justify-between mb-3">
                  <h5 class="text-sm font-medium text-gray-700">邮件域名管理</h5>
                  <button @click="showAddDomain = !showAddDomain" 
                          class="text-xs px-3 py-1 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors">
                    {{ showAddDomain ? '取消' : '添加域名' }}
                  </button>
                </div>
                
                <!-- 添加域名表单 -->
                <div v-if="showAddDomain" class="mb-4 p-4 bg-gradient-to-r from-green-50 to-blue-50 rounded-lg border border-green-200 shadow-sm">
                  <div class="flex items-center space-x-3">
                    <div class="flex-1 relative">
                      <input v-model="newDomain" 
                             type="text" 
                             placeholder="输入域名，如: example.com" 
                             :disabled="domainAdding"
                             class="w-full px-4 py-3 border border-gray-300 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-transparent disabled:bg-gray-100 disabled:cursor-not-allowed transition-all duration-200"
                             @click.stop
                             @focus.stop
                             @input.stop>
                    </div>
                    <button @click="addDomain" 
                            :disabled="!newDomain || domainAdding"
                            class="px-6 py-3 bg-gradient-to-r from-green-600 to-green-700 text-white text-sm font-medium rounded-lg hover:from-green-700 hover:to-green-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-md hover:shadow-lg">
                      <svg v-if="domainAdding" class="animate-spin -ml-1 mr-2 h-4 w-4 text-white inline" fill="none" viewBox="0 0 24 24">
                        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      {{ domainAdding ? '添加中...' : '添加域名' }}
                    </button>
                  </div>
                  
                  <!-- 错误提示 -->
                  <div v-if="domainError" class="mt-3 p-3 bg-red-50 border border-red-200 rounded-lg">
                    <div class="flex items-center">
                      <svg class="w-5 h-5 text-red-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                      </svg>
                      <span class="text-sm text-red-700 font-medium">{{ domainError }}</span>
                    </div>
                  </div>
                  
                  <!-- 成功提示 -->
                  <div v-if="domainSuccess" class="mt-3 p-3 bg-green-50 border border-green-200 rounded-lg">
                    <div class="flex items-center">
                      <svg class="w-5 h-5 text-green-500 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
                      </svg>
                      <span class="text-sm text-green-700 font-medium">{{ domainSuccess }}</span>
                    </div>
                  </div>
                  
                  <p class="text-xs text-gray-600 mt-2 flex items-center">
                    <svg class="w-4 h-4 text-blue-500 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                    </svg>
                    只有添加的域名才能接收邮件，其他域名将被拒绝
                  </p>
                </div>
                
                <!-- 域名列表 -->
                <div class="space-y-3">
                  <div v-for="domain in (systemSettings.mail.domains || [])" :key="domain.id" 
                       class="group flex items-center justify-between p-4 bg-white rounded-lg border border-gray-200 hover:border-green-300 hover:shadow-md transition-all duration-200">
                    <div class="flex items-center space-x-3">
                      <div class="flex-shrink-0">
                        <div class="w-8 h-8 bg-gradient-to-r from-green-500 to-blue-500 rounded-full flex items-center justify-center">
                          <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                          </svg>
                        </div>
                      </div>
                      <div class="flex-1">
                        <span class="text-sm font-semibold text-gray-800">{{ domain.name }}</span>
                        <div class="flex items-center space-x-2 mt-1">
                          <span v-if="domain.isDefault" class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-green-100 text-green-800">
                            <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                            </svg>
                            默认域名
                          </span>
                          <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                            <svg class="w-3 h-3 mr-1" fill="currentColor" viewBox="0 0 20 20">
                              <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"></path>
                              <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"></path>
                            </svg>
                            邮件接收
                          </span>
                        </div>
                      </div>
                    </div>
                    <button @click="showDeleteDomainConfirm(domain.id)" 
                            :disabled="domain.isDefault || domain.isDnsDomain"
                            class="p-2 text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition-all duration-200 disabled:opacity-50 disabled:cursor-not-allowed"
                            :title="domain.isDnsDomain ? 'DNS配置的域名不能删除' : (domain.isDefault ? '默认域名不能删除' : '删除域名')">
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                      </svg>
                    </button>
                  </div>
                  
                  <div v-if="!systemSettings.mail.domains || systemSettings.mail.domains.length === 0" class="text-center py-8">
                    <div class="flex flex-col items-center">
                      <svg class="w-12 h-12 text-gray-400 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9v-9m0-9v9"></path>
                      </svg>
                      <p class="text-gray-500 text-sm">暂无配置的邮件域名</p>
                      <p class="text-gray-400 text-xs mt-1">点击上方"添加域名"按钮开始配置</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <!-- 操作按钮 -->
        <div v-if="!settingsLoading" class="mt-8 flex items-center justify-end space-x-3 relative z-10">
          <button @click.stop="resetSystemSettings" type="button" class="px-6 py-2.5 bg-white border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 transition-all duration-200 shadow-sm hover:shadow-md cursor-pointer">
            重置
          </button>
          <button @click.stop="saveSystemSettings(true)" type="button" :disabled="settingsSaving" class="px-6 py-2.5 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg hover:from-purple-700 hover:to-pink-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 shadow-lg hover:shadow-xl cursor-pointer">
            <svg v-if="settingsSaving" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline" fill="none" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            {{ settingsSaving ? '保存中...' : '保存设置' }}
          </button>
        </div>
        
        <!-- 删除域名确认弹窗 -->
        <div v-if="showDeleteConfirm" class="fixed inset-0 z-50 overflow-y-auto">
          <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
            <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="cancelDeleteDomain"></div>
            <div class="inline-block align-bottom bg-white rounded-lg text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
              <div class="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                <div class="sm:flex sm:items-start">
                  <div class="mx-auto flex-shrink-0 flex items-center justify-center h-12 w-12 rounded-full bg-red-100 sm:mx-0 sm:h-10 sm:w-10">
                    <svg class="h-6 w-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
                    </svg>
                  </div>
                  <div class="mt-3 text-center sm:mt-0 sm:ml-4 sm:text-left">
                    <h3 class="text-lg leading-6 font-medium text-gray-900">确认删除域名</h3>
                    <div class="mt-2">
                      <p class="text-sm text-gray-500">
                        确定要删除域名 <span class="font-semibold text-gray-900">{{ domainToDelete?.name }}</span> 吗？
                      </p>
                      <p class="text-xs text-red-600 mt-2">此操作不可撤销，删除后该域名将无法接收邮件。</p>
                    </div>
                  </div>
                </div>
              </div>
              <div class="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                <button @click="confirmDeleteDomain" 
                        :disabled="domainDeleting"
                        class="w-full inline-flex justify-center rounded-md border border-transparent shadow-sm px-4 py-2 bg-red-600 text-base font-medium text-white hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed">
                  <svg v-if="domainDeleting" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  {{ domainDeleting ? '删除中...' : '确认删除' }}
                </button>
                <button @click="cancelDeleteDomain" 
                        :disabled="domainDeleting"
                        class="mt-3 w-full inline-flex justify-center rounded-md border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm disabled:opacity-50 disabled:cursor-not-allowed">
                  取消
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </Layout>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import Layout from '../components/Layout.vue'

// 系统设置相关状态
const systemSettings = ref({
  general: {
    systemName: 'XM邮件管理系统',
    adminEmail: 'xm@localhost',
    timezone: 'Asia/Shanghai',
    language: 'zh-CN',
    logRetention: 30,
    userPageSize: 10,
    icp: {
      enabled: false,
      number: '',
      url: 'https://beian.miit.gov.cn/'
    }
  },
  security: {
    enableSSL: true,
    forceHTTPS: true,
    sessionTimeout: 30,
    maxLoginAttempts: 5,
    passwordMinLength: 8,
    requireSpecialChars: false  // 默认关闭
  },
  mail: {
    maxMailboxSize: 1024,
    maxMessageSize: 25,
    enableSpamFilter: true,
    enableVirusScan: true,
    quarantineDays: 7,
    autoDeleteSpam: false,
    pageSize: 8,
    domains: []
  },
  dns: {
    bind: {
      domain: '',
      serverIp: '',
      adminEmail: 'xm@localhost',
      enableRecursion: true,
      enableForwarding: true,
      upstreamDns: '8.8.8.8, 1.1.1.1'
    }
  }
})

const settingsLoading = ref(false)
const settingsSaving = ref(false)
const settingsError = ref(null)
const settingsSuccess = ref(false)

// 时区相关状态
const availableTimezones = ref({})
const currentSystemTimezone = ref('')
const timezoneLoading = ref(false)
const timezoneSaving = ref(false)

// 邮件设置相关状态
const mailSettingsSaving = ref(false)

// 域名管理相关状态
const showAddDomain = ref(false)
const newDomain = ref('')
const domainAdding = ref(false)
const domainError = ref('')
const domainSuccess = ref('')

// 删除域名确认状态
const showDeleteConfirm = ref(false)
const domainToDelete = ref<any>(null)
const domainDeleting = ref(false)

// 加载时区列表
const loadTimezones = async () => {
  timezoneLoading.value = true
  try {
    const response = await fetch('/api/timezones', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`)
    }
    
    const data = await response.json()
    if (!data.success) {
      throw new Error(data.error || data.message || '获取时区列表失败')
    }
    
    // 确保时区数据存在且有效
    if (data.timezones && typeof data.timezones === 'object' && Object.keys(data.timezones).length > 0) {
      availableTimezones.value = data.timezones
      currentSystemTimezone.value = data.currentTimezone || 'Asia/Shanghai'
      console.log('时区列表加载成功:', data.timezones)

      // 如果当前选择的时区为空或不存在于可用列表，则回退为当前系统时区
      try {
        const allTimezones = new Set(
          Object.values(data.timezones).flat()
        )
        const selectedTz = systemSettings.value?.general?.timezone
        if (!selectedTz || !allTimezones.has(selectedTz)) {
          if (!systemSettings.value.general) systemSettings.value.general = {}
          systemSettings.value.general.timezone = data.currentTimezone || 'Asia/Shanghai'
          console.log('未找到已选时区，回退为当前系统时区:', data.currentTimezone)
        }
      } catch (e) {
        console.warn('验证时区列表失败:', e)
      }
    } else {
      // 如果时区数据无效，使用默认时区列表
      console.warn('时区数据无效，使用默认时区列表')
      availableTimezones.value = {
        'Asia': ['Asia/Shanghai', 'Asia/Tokyo', 'Asia/Hong_Kong', 'Asia/Singapore', 'Asia/Seoul'],
        'Europe': ['Europe/London', 'Europe/Paris', 'Europe/Berlin', 'Europe/Moscow'],
        'America': ['America/New_York', 'America/Chicago', 'America/Denver', 'America/Los_Angeles'],
        'UTC': ['UTC']
      }
      currentSystemTimezone.value = data.currentTimezone || 'Asia/Shanghai'
    }
  } catch (error: any) {
    console.error('加载时区列表失败:', error)
    // 使用默认时区列表作为后备方案
    availableTimezones.value = {
      'Asia': ['Asia/Shanghai', 'Asia/Tokyo', 'Asia/Hong_Kong', 'Asia/Singapore', 'Asia/Seoul'],
      'Europe': ['Europe/London', 'Europe/Paris', 'Europe/Berlin', 'Europe/Moscow'],
      'America': ['America/New_York', 'America/Chicago', 'America/Denver', 'America/Los_Angeles'],
      'UTC': ['UTC']
    }
    currentSystemTimezone.value = 'Asia/Shanghai'
    settingsError.value = `加载时区列表失败: ${error.message || '未知错误'}，已使用默认时区列表`
    setTimeout(() => {
      settingsError.value = null
    }, 5000)
  } finally {
    timezoneLoading.value = false
  }
}

// 用户分页大小变更处理
const handleUserPageSizeChange = async (event: any) => {
  console.log('用户分页大小选择器被触发, event:', event)
  const pageSize = event?.target?.value || systemSettings.value.general?.userPageSize
  console.log('选中的分页大小:', pageSize)
  if (pageSize) {
    systemSettings.value.general.userPageSize = parseInt(pageSize, 10)
    console.log('用户分页大小已更改为:', systemSettings.value.general.userPageSize)
    // 调用保存函数（使用防抖）
    await saveSystemSettings()
  }
}

// 时区变更处理
const onTimezoneChange = async (event: any) => {
  console.log('时区选择器被触发, event:', event)
  const selectedTimezone = event?.target?.value || event
  console.log('选中的时区:', selectedTimezone)
  if (selectedTimezone && (typeof selectedTimezone === 'string' ? selectedTimezone.includes('/') : true)) {
    systemSettings.value.general.timezone = selectedTimezone
    console.log('时区已更改为:', selectedTimezone)
    
    // 显示保存状态
    timezoneSaving.value = true
    
    try {
      await saveSystemSettings()
      console.log('时区设置已保存并应用')
      
      // 等待一下让系统时区生效
      await new Promise(resolve => setTimeout(resolve, 1500))
      
      // 重新加载时区信息以更新显示
      await loadTimezones()
    } catch (error) {
      console.error('保存时区设置失败:', error)
    } finally {
      timezoneSaving.value = false
    }
  }
}

// 保存系统设置（支持防抖和立即执行）
const saveSystemSettings = async (immediate = false) => {
  console.log('saveSystemSettings 被调用, immediate:', immediate, 'userPageSize:', systemSettings.value.general?.userPageSize)
  // 如果是立即执行（手动点击保存按钮），清除防抖并立即执行
  if (immediate) {
    if ((saveSystemSettings as any).timeout) {
      clearTimeout((saveSystemSettings as any).timeout)
      ;(saveSystemSettings as any).timeout = null
    }
    await executeSaveSystemSettings()
    return
  }
  
  // 自动保存使用防抖，避免频繁保存
  if ((saveSystemSettings as any).timeout) {
    clearTimeout((saveSystemSettings as any).timeout)
  }
  
  ;(saveSystemSettings as any).timeout = setTimeout(async () => {
    await executeSaveSystemSettings()
    ;(saveSystemSettings as any).timeout = null
  }, 500) // 500ms防抖
}

// 执行保存系统设置
const executeSaveSystemSettings = async (silent: boolean = false) => {
  settingsSaving.value = true
  settingsError.value = null
  if (!silent) {
    settingsSuccess.value = false
  }
  
  try {
    // 验证安全设置
    if (systemSettings.value.security) {
      // 验证会话超时
      if (systemSettings.value.security.sessionTimeout) {
        const timeout = parseInt(String(systemSettings.value.security.sessionTimeout), 10)
        if (isNaN(timeout) || timeout < 5 || timeout > 1440) {
          settingsError.value = '会话超时时间必须在5-1440分钟之间'
          settingsSaving.value = false
          return
        }
      }
      
      // 验证最大登录尝试次数
      if (systemSettings.value.security.maxLoginAttempts) {
        const attempts = parseInt(String(systemSettings.value.security.maxLoginAttempts), 10)
        if (isNaN(attempts) || attempts < 3 || attempts > 20) {
          settingsError.value = '最大登录尝试次数必须在3-20次之间'
          settingsSaving.value = false
          return
        }
      }
      
      // 验证密码最小长度
      if (systemSettings.value.security.passwordMinLength) {
        const minLength = parseInt(String(systemSettings.value.security.passwordMinLength), 10)
        if (isNaN(minLength) || minLength < 6 || minLength > 32) {
          settingsError.value = '密码最小长度必须在6-32个字符之间'
          settingsSaving.value = false
          return
        }
      }
    }
    
    // 如果general.adminEmail存在，同步更新notifications.alertEmail
    if (systemSettings.value.general?.adminEmail) {
      if (!systemSettings.value.notifications) {
        systemSettings.value.notifications = {}
      }
      ;(systemSettings.value.notifications as any).alertEmail = systemSettings.value.general.adminEmail
      console.log('已同步更新报警邮箱:', systemSettings.value.general.adminEmail)
    }
    
    // 从general设置中删除备份相关字段（备份功能已移至Dashboard）
    const settingsToSave = JSON.parse(JSON.stringify(systemSettings.value))
    if (settingsToSave.general) {
      delete settingsToSave.general.autoBackup
      delete settingsToSave.general.backupInterval
    }
    
    // 保存其他系统设置
    const response = await fetch('/api/system-settings', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      },
      body: JSON.stringify({
        settings: settingsToSave
      })
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 保存分页设置到localStorage
        localStorage.setItem('mailPageSize', systemSettings.value.mail.pageSize.toString())
        
        settingsSaving.value = false
        if (!silent) {
          settingsSuccess.value = true
          
          console.log('系统设置保存成功:', data.message)
          
          // 3秒后隐藏成功提示
          setTimeout(() => {
            settingsSuccess.value = false
          }, 3000)
        } else {
          console.log('系统设置自动保存成功（静默模式）:', data.message)
        }
      } else {
        throw new Error(data.error || '保存设置失败')
      }
    } else {
      const errorData = await response.json()
      throw new Error(errorData.error || '保存设置失败')
    }
    
  } catch (error: any) {
    console.error('保存系统设置失败:', error)
    settingsError.value = error.message || '保存设置失败'
    settingsSaving.value = false
  }
}

// 重置系统设置
const resetSystemSettings = () => {
  console.log('重置按钮被点击')
  if (confirm('确定要重置所有设置到默认值吗？此操作不可撤销。')) {
    // 重置为默认值
    systemSettings.value = {
      general: {
        systemName: 'XM邮件管理系统',
        adminEmail: 'admin@example.com',
        timezone: 'Asia/Shanghai',
        language: 'zh-CN',
        logRetention: 30,
        userPageSize: 10
      },
      security: {
        enableSSL: true,
        forceHTTPS: true,
        sessionTimeout: 30,
        maxLoginAttempts: 5,
        passwordMinLength: 8,
        requireSpecialChars: false  // 默认关闭，需要管理员手动开启
      },
      mail: {
        maxMailboxSize: 1024,
        maxMessageSize: 25,
        enableSpamFilter: true,
        enableVirusScan: true,
        quarantineDays: 7,
        autoDeleteSpam: false,
        pageSize: 8,
        domains: []
      },
      dns: {
        bind: {
          domain: '',
          serverIp: '',
          adminEmail: 'xm@localhost',
          enableRecursion: true,
          enableForwarding: true,
          upstreamDns: '8.8.8.8, 1.1.1.1'
        }
      }
    }
  }
}

// 加载系统设置
const loadSystemSettings = async () => {
  console.log('开始加载系统设置')
  settingsLoading.value = true
  settingsError.value = null
  
  try {
    const response = await fetch('/api/system-settings', {
      headers: {
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      }
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        // 从后端设置中删除备份相关字段（备份功能已移至Dashboard）
        const backendSettings = { ...data.settings }
        if (backendSettings.general) {
          delete backendSettings.general.autoBackup
          delete backendSettings.general.backupInterval
        }
        
        // 优先使用后端返回的配置，只在后端没有返回时才使用默认值
        systemSettings.value = {
          // 确保general配置字段正确合并（优先使用后端值）
          general: {
            systemName: backendSettings.general?.systemName || 'XM邮件管理系统',
            adminEmail: backendSettings.general?.adminEmail || 'xm@localhost',
            timezone: backendSettings.general?.timezone || 'Asia/Shanghai',
            language: backendSettings.general?.language || 'zh-CN',
            logRetention: backendSettings.general?.logRetention ?? 30,
            userPageSize: backendSettings.general?.userPageSize ?? 10,
            icp: {
              enabled: backendSettings.general?.icp?.enabled ?? false,
              number: backendSettings.general?.icp?.number || '',
              url: backendSettings.general?.icp?.url || 'https://beian.miit.gov.cn/'
            }
          },
          // 确保security配置字段正确合并（优先使用后端值）
          security: {
            enableSSL: backendSettings.security?.enableSSL ?? true,
            forceHTTPS: backendSettings.security?.forceHTTPS ?? true,
            sessionTimeout: backendSettings.security?.sessionTimeout ?? 30,
            maxLoginAttempts: backendSettings.security?.maxLoginAttempts ?? 5,
            passwordMinLength: backendSettings.security?.passwordMinLength ?? 8,
            requireSpecialChars: backendSettings.security?.requireSpecialChars ?? false
          },
          // 确保mail配置字段正确合并，特别是domains字段（优先使用后端值）
          mail: {
            maxMailboxSize: backendSettings.mail?.maxMailboxSize ?? 1024,
            maxMessageSize: backendSettings.mail?.maxMessageSize ?? 25,
            enableSpamFilter: backendSettings.mail?.enableSpamFilter ?? true,
            enableVirusScan: backendSettings.mail?.enableVirusScan ?? true,
            quarantineDays: backendSettings.mail?.quarantineDays ?? 7,
            autoDeleteSpam: backendSettings.mail?.autoDeleteSpam ?? false,
            pageSize: backendSettings.mail?.pageSize ?? 8,
            domains: backendSettings.mail?.domains || []
          },
          // 确保notifications配置字段正确合并（优先使用后端值）
          notifications: {
            enabled: backendSettings.notifications?.enabled ?? true,
            alertEmail: backendSettings.notifications?.alertEmail || 'xm@localhost',
            cpuThreshold: backendSettings.notifications?.cpuThreshold ?? 80,
            memoryThreshold: backendSettings.notifications?.memoryThreshold ?? 80,
            diskThreshold: backendSettings.notifications?.diskThreshold ?? 80,
            networkThreshold: backendSettings.notifications?.networkThreshold ?? 80
          },
          // 确保performance配置字段正确合并（优先使用后端值）
          performance: {
            maxConnections: backendSettings.performance?.maxConnections ?? 100,
            timeout: backendSettings.performance?.timeout ?? 30,
            cacheSize: backendSettings.performance?.cacheSize ?? 256
          },
          // 确保DNS配置字段正确合并（优先使用后端值）
          dns: {
            type: backendSettings.dns?.type || null,
            bind: {
              domain: backendSettings.dns?.bind?.domain || '',
              serverIp: backendSettings.dns?.bind?.serverIp || '',
              adminEmail: backendSettings.dns?.bind?.adminEmail || 'xm@localhost',
              enableRecursion: backendSettings.dns?.bind?.enableRecursion ?? true,
              enableForwarding: backendSettings.dns?.bind?.enableForwarding ?? true,
              upstreamDns: backendSettings.dns?.bind?.upstreamDns || '8.8.8.8, 1.1.1.1'
            },
            public: {
              domain: backendSettings.dns?.public?.domain || '',
              serverIp: backendSettings.dns?.public?.serverIp || '',
              adminEmail: backendSettings.dns?.public?.adminEmail || 'xm@localhost',
              enableRecursion: backendSettings.dns?.public?.enableRecursion ?? true,
              enableForwarding: backendSettings.dns?.public?.enableForwarding ?? true,
              upstreamDns: backendSettings.dns?.public?.upstreamDns || '8.8.8.8, 1.1.1.1'
            }
          }
        }
        
        console.log('系统设置加载完成，域名列表:', systemSettings.value.mail?.domains)
        console.log('域名列表数量:', systemSettings.value.mail?.domains?.length || 0)
        
        // 确保domains数组存在且是数组类型
        if (!Array.isArray(systemSettings.value.mail.domains)) {
          console.warn('domains不是数组，重置为空数组')
          systemSettings.value.mail.domains = []
        }
        
        // 标记DNS配置的域名
        const dnsDomain = systemSettings.value.dns?.bind?.domain || (systemSettings.value.dns as any)?.public?.domain
        if (dnsDomain && systemSettings.value.mail.domains) {
          systemSettings.value.mail.domains.forEach((domain: any) => {
            domain.isDnsDomain = dnsDomain.toLowerCase() === domain.name.toLowerCase()
            // DNS配置的域名为默认域名
            if (domain.isDnsDomain) {
              domain.isDefault = true
            }
          })
          console.log('DNS域名标记完成，DNS域名:', dnsDomain)
        }
        
        // 自动同步general.adminEmail到dns.bind.adminEmail（如果dns.bind.adminEmail为空或为默认值）
        if (systemSettings.value.general?.adminEmail) {
          const generalEmail = systemSettings.value.general.adminEmail
          const bindEmail = systemSettings.value.dns?.bind?.adminEmail
          
          if (!bindEmail || 
              bindEmail === 'admin@example.com' || 
              bindEmail === 'admin@skills.com' || 
              bindEmail === 'xm@localhost') {
            if (!systemSettings.value.dns) systemSettings.value.dns = { bind: {} }
            if (!systemSettings.value.dns.bind) systemSettings.value.dns.bind = {}
            systemSettings.value.dns.bind.adminEmail = generalEmail
            console.log('自动同步adminEmail到DNS配置:', generalEmail)
          }
        }
        
        console.log('系统设置加载成功:', data.settings)
        
        // 加载时区信息以更新当前系统时区显示
        await loadTimezones()
      } else {
        console.error('API返回失败:', data.error)
        throw new Error(data.error || '加载设置失败')
      }
    } else {
      console.error('HTTP请求失败:', response.status, response.statusText)
      throw new Error('获取系统设置失败')
    }
    
    settingsLoading.value = false
    console.log('系统设置加载完成')
  } catch (error: any) {
    console.error('加载系统设置失败:', error)
    settingsError.value = error.message || '加载设置失败'
    settingsLoading.value = false
  }
}

// 邮件设置实时保存
const saveMailSettings = async () => {
  mailSettingsSaving.value = true
  try {
    const response = await fetch('/api/system-settings', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${sessionStorage.getItem('apiAuth')}`
      },
      body: JSON.stringify({ settings: systemSettings.value })
    })
    
    if (response.ok) {
      const data = await response.json()
      if (data.success) {
        console.log('邮件设置已保存并应用')
        // 保存分页设置到localStorage
        localStorage.setItem('mailPageSize', systemSettings.value.mail.pageSize.toString())
      }
    }
  } catch (error) {
    console.error('保存邮件设置失败:', error)
  } finally {
    mailSettingsSaving.value = false
  }
}

// 添加域名
const addDomain = async () => {
  if (!newDomain.value.trim()) return
  
  // 清除之前的提示
  domainError.value = ''
  domainSuccess.value = ''
  domainAdding.value = true
  
  try {
    // 验证域名格式
    const domainRegex = /^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$/
    if (!domainRegex.test(newDomain.value.trim())) {
      domainError.value = '请输入有效的域名格式，如: example.com'
      return
    }
    
    // 检查域名是否已存在
    const exists = systemSettings.value.mail.domains.some((domain: any) => 
      domain.name.toLowerCase() === newDomain.value.trim().toLowerCase()
    )
    
    if (exists) {
      domainError.value = '该域名已存在，请选择其他域名'
      return
    }
    
    // 调用后端API
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch('/api/system/domains', {
      method: 'POST',
      headers: {
        'Authorization': `Basic ${auth}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        domain: newDomain.value.trim()
      })
    })
    
    if (response.ok) {
      const result = await response.json()
      if (result.success) {
        const addedDomain = newDomain.value.trim()
        domainSuccess.value = `域名 ${addedDomain} 添加成功！`
        newDomain.value = ''
        
        // 重新从数据库加载域名列表（确保获取最新数据）
        await loadSystemSettings()
        
        // 等待一下确保数据已加载
        await new Promise(resolve => setTimeout(resolve, 500))
        
        // 再次验证域名是否已添加到列表
        const domainAdded = systemSettings.value.mail.domains?.some(
          (d: any) => d.name.toLowerCase() === addedDomain.toLowerCase()
        )
        
        if (!domainAdded) {
          // 如果还是没有，再次尝试加载
          console.warn('域名可能未正确添加，重新加载设置...')
          await loadSystemSettings()
        } else {
          console.log('域名已成功添加到列表:', addedDomain)
        }
        
        // 3秒后自动关闭表单
        setTimeout(() => {
          showAddDomain.value = false
          domainSuccess.value = ''
        }, 3000)
      } else {
        domainError.value = result.message || '域名添加失败，请重试'
      }
    } else {
      const errorData = await response.json().catch(() => ({}))
      domainError.value = (errorData as any).message || `服务器错误 (${response.status})，请重试`
    }
    
  } catch (error: any) {
    console.error('添加域名失败:', error)
    domainError.value = error.message || '网络连接失败，请检查网络后重试'
  } finally {
    domainAdding.value = false
  }
}

// 显示删除确认弹窗
const showDeleteDomainConfirm = (domainId: number) => {
  const domain = systemSettings.value.mail.domains.find((d: any) => d.id === domainId)
  if (!domain) return
  
  domainToDelete.value = domain
  showDeleteConfirm.value = true
}

// 确认删除域名
const confirmDeleteDomain = async () => {
  if (!domainToDelete.value) return
  
  domainDeleting.value = true
  
  try {
    const auth = sessionStorage.getItem('apiAuth')
    const response = await fetch(`/api/system/domains/${domainToDelete.value.id}`, {
      method: 'DELETE',
      headers: {
        'Authorization': `Basic ${auth}`
      }
    })
    
    if (response.ok) {
      const result = await response.json()
      if (result.success) {
        // 重新从数据库加载域名列表
        await loadSystemSettings()
        
        // 显示成功消息
        domainSuccess.value = `域名 ${domainToDelete.value.name} 删除成功！`
        setTimeout(() => {
          domainSuccess.value = ''
        }, 3000)
      } else {
        domainError.value = result.message || '域名删除失败，请重试'
        setTimeout(() => {
          domainError.value = ''
        }, 3000)
      }
    } else {
      const errorData = await response.json().catch(() => ({}))
      domainError.value = (errorData as any).message || '域名删除失败，请重试'
      setTimeout(() => {
        domainError.value = ''
      }, 3000)
    }
    
  } catch (error: any) {
    console.error('删除域名失败:', error)
    domainError.value = '删除域名失败，请重试'
    setTimeout(() => {
      domainError.value = ''
    }, 3000)
  } finally {
    domainDeleting.value = false
    showDeleteConfirm.value = false
    domainToDelete.value = null
  }
}

// 取消删除
const cancelDeleteDomain = () => {
  showDeleteConfirm.value = false
  domainToDelete.value = null
}

onMounted(async () => {
  await loadSystemSettings()
})
</script>

<style scoped>
/* 样式将在后续添加 */
</style>

