<template>
  <div v-if="visible" class="terminal-container">
    <!-- 工具栏 -->
    <div class="terminal-toolbar">
      <div class="toolbar-left">
        <button @click="newTab" class="toolbar-btn" title="新建标签">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
          </svg>
          <span class="ml-1">新建</span>
        </button>
        <button 
          @click="closeTab" 
          class="toolbar-btn" 
          v-if="tabs.length > 1"
          title="关闭当前标签"
        >
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
          <span class="ml-1">关闭</span>
        </button>
      </div>
      
      <div class="toolbar-center">
        <div class="tabs-container">
          <div 
            v-for="(tab, index) in tabs" 
            :key="tab.id"
            :class="['tab', { active: activeTabId === tab.id }]"
            @click="switchTab(tab.id)"
          >
            <span>{{ tab.title }}</span>
            <button 
              @click.stop="closeTabById(tab.id)" 
              class="tab-close"
              v-if="tabs.length > 1"
              title="关闭标签"
            >×</button>
          </div>
        </div>
      </div>
      
      <div class="toolbar-right">
        <button @click="copySelection" class="toolbar-btn" title="复制选中内容">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"></path>
          </svg>
          <span class="ml-1">复制</span>
        </button>
        <button @click="pasteText" class="toolbar-btn" title="粘贴">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
          </svg>
          <span class="ml-1">粘贴</span>
        </button>
        <button @click="clearTerminal" class="toolbar-btn" title="清屏">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
          </svg>
          <span class="ml-1">清屏</span>
        </button>
        <button @click="showSettings = !showSettings" class="toolbar-btn" title="设置">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"></path>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
          </svg>
          <span class="ml-1">设置</span>
        </button>
        <button @click="closeTerminal" class="toolbar-btn" title="关闭终端">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
          <span class="ml-1">关闭</span>
        </button>
      </div>
    </div>

    <!-- 设置面板 -->
    <div v-if="showSettings" class="settings-panel">
      <div class="settings-content">
        <h3 class="settings-title">终端设置</h3>
        <div class="settings-item">
          <label>字体大小</label>
          <input 
            type="number" 
            v-model.number="fontSize" 
            min="10" 
            max="24"
            @change="updateTerminalSettings"
          />
        </div>
        <div class="settings-item">
          <label>主题</label>
          <select v-model="theme" @change="updateTerminalSettings">
            <option value="dark">深色</option>
            <option value="light">浅色</option>
            <option value="green">绿色</option>
          </select>
        </div>
        <button @click="showSettings = false" class="settings-close">关闭</button>
      </div>
    </div>

    <!-- 终端内容区 -->
    <div class="terminal-content">
      <div 
        v-for="tab in tabs" 
        :key="tab.id"
        :class="['terminal-pane', { active: activeTabId === tab.id }]"
      >
        <div :ref="el => setTerminalRef(el, tab.id)" class="terminal-wrapper"></div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick, watch } from 'vue'
import { Terminal } from '@xterm/xterm'
import { FitAddon } from '@xterm/addon-fit'
import { WebLinksAddon } from '@xterm/addon-web-links'
import { SearchAddon } from '@xterm/addon-search'
import '@xterm/xterm/css/xterm.css'

const props = defineProps<{
  visible: boolean
}>()

const emit = defineEmits(['close'])

// 终端状态
interface Tab {
  id: string
  title: string
  terminal: Terminal | null
  socket: WebSocket | null
  fitAddon: FitAddon | null
}

const tabs = ref<Tab[]>([])
const activeTabId = ref<string>('')
const terminals = new Map<string, Terminal>()
const sockets = new Map<string, WebSocket>()
const showSettings = ref(false)
const fontSize = ref(14)
const theme = ref('dark')

// 创建新标签页
const newTab = async () => {
  const id = `tab-${Date.now()}`
  const tab: Tab = {
    id,
    title: `终端 ${tabs.value.length + 1}`,
    terminal: null,
    socket: null,
    fitAddon: null
  }
  tabs.value.push(tab)
  activeTabId.value = id
  // 等待 DOM 完全渲染后再初始化终端
  await nextTick()
  // 再等待一小段时间确保 ref 回调已执行
  await new Promise(resolve => setTimeout(resolve, 100))
  initTerminal(id)
}

// 初始化终端
const initTerminal = async (tabId: string) => {
  const tab = tabs.value.find(t => t.id === tabId)
  if (!tab) return

  const terminal = new Terminal({
    cursorBlink: true,
    fontSize: fontSize.value,
    fontFamily: 'Consolas, "Courier New", monospace',
    theme: getThemeConfig(theme.value),
    rows: 24,
    cols: 80,
    allowTransparency: true
  })

  const fitAddon = new FitAddon()
  const webLinksAddon = new WebLinksAddon()
  const searchAddon = new SearchAddon()

  terminal.loadAddon(fitAddon)
  terminal.loadAddon(webLinksAddon)
  terminal.loadAddon(searchAddon)

  // 等待 DOM 更新后再查找元素，可能需要多次尝试
  let wrapper: HTMLElement | null = null
  let attempts = 0
  const maxAttempts = 10
  
  while (!wrapper && attempts < maxAttempts) {
    await nextTick()
    // 尝试多种方式查找元素
    const tabElement = document.querySelector(`[data-tab-id="${tabId}"]`)
    if (tabElement) {
      wrapper = tabElement.querySelector('.terminal-wrapper') as HTMLElement
    }
    
    // 如果还是找不到，尝试直接通过 tab 的索引查找
    if (!wrapper) {
      const tabIndex = tabs.value.findIndex(t => t.id === tabId)
      if (tabIndex >= 0) {
        const allPanes = document.querySelectorAll('.terminal-pane')
        if (allPanes[tabIndex]) {
          wrapper = allPanes[tabIndex].querySelector('.terminal-wrapper') as HTMLElement
        }
      }
    }
    
    if (!wrapper) {
      attempts++
      // 等待一小段时间后重试
      await new Promise(resolve => setTimeout(resolve, 50))
    }
  }
  
  if (!wrapper) {
    console.error(`[TERMINAL] Cannot find wrapper for tab ${tabId} after ${maxAttempts} attempts`)
    console.error(`[TERMINAL] Available tabs:`, tabs.value.map(t => t.id))
    console.error(`[TERMINAL] Available elements:`, document.querySelectorAll('.terminal-pane').length)
    return
  }
  
  console.log(`[TERMINAL] Opening terminal in wrapper for tab ${tabId}`)
  terminal.open(wrapper)
  fitAddon.fit()
  
  // 确保终端获得焦点
  terminal.focus()
  
  // 处理终端大小变化
  const resizeObserver = new ResizeObserver(() => {
    fitAddon.fit()
    const socket = sockets.get(tabId)
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send(JSON.stringify({ 
        type: 'resize', 
        cols: terminal.cols, 
        rows: terminal.rows 
      }))
    }
  })
  resizeObserver.observe(wrapper)

  // 连接 WebSocket
  const socket = connectWebSocket(tabId, terminal)
  
  tab.terminal = terminal
  tab.socket = socket
  tab.fitAddon = fitAddon
  terminals.set(tabId, terminal)
  sockets.set(tabId, socket)

  // 处理终端输入
  terminal.onData((data) => {
    console.log(`[TERMINAL] Input received, socket:`, socket ? 'exists' : 'null', `readyState:`, socket?.readyState)
    if (socket && socket.readyState === WebSocket.OPEN) {
      console.log(`[TERMINAL] Sending input:`, JSON.stringify({ type: 'input', data: data.substring(0, 20) }))
      socket.send(JSON.stringify({ type: 'input', data }))
    } else {
      console.warn(`[TERMINAL] Cannot send input: socket=${socket ? 'exists' : 'null'}, readyState=${socket?.readyState}`)
    }
  })

  // 处理终端选择
  terminal.onSelectionChange(() => {
    // 可以在这里添加选择变化处理
  })
}

// 获取主题配置
const getThemeConfig = (themeName: string) => {
  const themes: Record<string, any> = {
    dark: {
      background: '#1e1e1e',
      foreground: '#d4d4d4',
      cursor: '#aeafad',
      selection: '#264f78'
    },
    light: {
      background: '#ffffff',
      foreground: '#000000',
      cursor: '#000000',
      selection: '#add6ff'
    },
    green: {
      background: '#0c0c0c',
      foreground: '#00ff00',
      cursor: '#00ff00',
      selection: '#003366'
    }
  }
  return themes[themeName] || themes.dark
}

// 连接 WebSocket
const connectWebSocket = (tabId: string, terminal: Terminal) => {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:'
  
  // 获取认证信息
  const auth = sessionStorage.getItem('apiAuth')
  if (!auth) {
    terminal.write('\r\n\x1b[31m错误: 未找到认证信息，请重新登录\x1b[0m\r\n')
    return null
  }
  
  // 通过子协议传递认证信息（WebSocket 不支持自定义 headers）
  const wsUrl = `${protocol}//${window.location.host}/api/terminal/ws`
  const socket = new WebSocket(wsUrl, [`auth.${auth}`])

  let authSent = false
  let initSent = false

  socket.onopen = () => {
    terminal.writeln('\r\n\x1b[32m✓ 已连接到服务器，正在认证...\x1b[0m\r\n')
    // 先发送认证信息
    socket.send(JSON.stringify({ type: 'auth', token: auth }))
    authSent = true
  }

  socket.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data)
      
      if (data.type === 'auth' && data.success) {
        // 认证成功，初始化终端
        terminal.writeln('\x1b[32m✓ 认证成功\x1b[0m\r\n')
        if (!initSent) {
          socket.send(JSON.stringify({ type: 'init' }))
          initSent = true
        }
      } else if (data.type === 'output') {
        console.log(`[TERMINAL] Received output, length: ${data.data.length}, preview: ${data.data.substring(0, 50)}`)
        terminal.write(data.data)
      } else if (data.type === 'error') {
        terminal.write(`\r\n\x1b[31m错误: ${data.message}\x1b[0m\r\n`)
        if (data.message === 'Authentication failed' || data.message === 'Not authenticated') {
          terminal.writeln('\x1b[31m认证失败，连接已关闭\x1b[0m\r\n')
        }
      } else if (data.type === 'exit') {
        terminal.write(`\r\n\x1b[33m进程已退出，退出码: ${data.code}\x1b[0m\r\n`)
      }
    } catch (error) {
      // 如果不是JSON，直接输出
      terminal.write(event.data)
    }
  }

  socket.onerror = (error) => {
    terminal.write('\r\n\x1b[31mWebSocket 连接错误\x1b[0m\r\n')
    console.error('WebSocket error:', error)
  }

  socket.onclose = () => {
    terminal.write('\r\n\x1b[33m连接已断开\x1b[0m\r\n')
  }

  return socket
}

// 切换标签页
const switchTab = (tabId: string) => {
  activeTabId.value = tabId
  nextTick(() => {
    const tab = tabs.value.find(t => t.id === tabId)
    if (tab) {
      if (tab.fitAddon) {
        tab.fitAddon.fit()
      }
      // 确保切换标签时终端获得焦点
      if (tab.terminal) {
        tab.terminal.focus()
      }
    }
  })
}

// 关闭标签页
const closeTab = () => {
  if (tabs.value.length > 1) {
    closeTabById(activeTabId.value)
  }
}

const closeTabById = (tabId: string) => {
  const index = tabs.value.findIndex(t => t.id === tabId)
  if (index === -1) return

  // 清理资源
  const socket = sockets.get(tabId)
  if (socket) {
    socket.close()
    sockets.delete(tabId)
  }

  const terminal = terminals.get(tabId)
  if (terminal) {
    terminal.dispose()
    terminals.delete(tabId)
  }

  tabs.value.splice(index, 1)
  
  if (activeTabId.value === tabId && tabs.value.length > 0) {
    activeTabId.value = tabs.value[Math.max(0, index - 1)].id
  }
}

// 工具栏功能
const copySelection = () => {
  const terminal = terminals.get(activeTabId.value)
  if (terminal) {
    const selection = terminal.getSelection()
    if (selection) {
      navigator.clipboard.writeText(selection).then(() => {
        // 可以显示提示
      })
    }
  }
}

const pasteText = async () => {
  try {
    // 检查 clipboard API 是否可用
    if (!navigator.clipboard || !navigator.clipboard.readText) {
      console.warn('剪贴板 API 不可用，可能需要 HTTPS 或用户交互')
      // 尝试使用传统的 execCommand 方法
      const textarea = document.createElement('textarea')
      textarea.style.position = 'fixed'
      textarea.style.opacity = '0'
      document.body.appendChild(textarea)
      textarea.focus()
      const success = document.execCommand('paste')
      const text = success ? textarea.value : ''
      document.body.removeChild(textarea)
      
      if (text) {
        const terminal = terminals.get(activeTabId.value)
        if (terminal) {
          terminal.paste(text)
        }
      }
      return
    }
    
    const text = await navigator.clipboard.readText()
    const terminal = terminals.get(activeTabId.value)
    if (terminal) {
      terminal.paste(text)
    }
  } catch (error) {
    console.error('粘贴失败:', error)
    // 尝试使用传统的 execCommand 方法作为后备
    try {
      const textarea = document.createElement('textarea')
      textarea.style.position = 'fixed'
      textarea.style.opacity = '0'
      document.body.appendChild(textarea)
      textarea.focus()
      const success = document.execCommand('paste')
      const text = success ? textarea.value : ''
      document.body.removeChild(textarea)
      
      if (text) {
        const terminal = terminals.get(activeTabId.value)
        if (terminal) {
          terminal.paste(text)
        }
      }
    } catch (fallbackError) {
      console.error('备用粘贴方法也失败:', fallbackError)
    }
  }
}

const clearTerminal = () => {
  const terminal = terminals.get(activeTabId.value)
  if (terminal) {
    terminal.clear()
  }
}

const updateTerminalSettings = () => {
  tabs.value.forEach(tab => {
    if (tab.terminal) {
      tab.terminal.options.fontSize = fontSize.value
      tab.terminal.options.theme = getThemeConfig(theme.value)
      if (tab.fitAddon) {
        tab.fitAddon.fit()
      }
    }
  })
}

const closeTerminal = () => {
  // 触发关闭事件，watch 会处理资源清理
  emit('close')
}

// 设置终端引用
const setTerminalRef = (el: any, tabId: string) => {
  if (el) {
    const parent = el.closest('.terminal-pane')
    if (parent) {
      parent.setAttribute('data-tab-id', tabId)
      console.log(`[TERMINAL] Set ref for tab ${tabId}, element:`, el)
    }
  }
}

// 监听 visible 变化
watch(() => props.visible, async (newVal) => {
  if (newVal) {
    // 如果终端被重新打开，确保清理旧资源并创建新标签
    if (tabs.value.length === 0) {
      await newTab()
    } else {
      // 如果已有标签但WebSocket未连接，重新初始化
      const activeTab = tabs.value.find(t => t.id === activeTabId.value)
      if (activeTab && (!activeTab.socket || activeTab.socket.readyState !== WebSocket.OPEN)) {
        console.log('[TERMINAL] Reinitializing terminal for existing tab')
        // 清理旧的终端实例
        if (activeTab.terminal) {
          activeTab.terminal.dispose()
        }
        if (activeTab.socket) {
          activeTab.socket.close()
        }
        // 重新初始化
        await initTerminal(activeTabId.value)
      }
    }
  } else {
    // 当终端关闭时，清理所有资源
    console.log('[TERMINAL] Terminal hidden, cleaning up resources')
    sockets.forEach((socket, tabId) => {
      if (socket && socket.readyState === WebSocket.OPEN) {
        console.log(`[TERMINAL] Closing WebSocket for tab ${tabId}`)
        socket.close()
      }
    })
    sockets.clear()
    
    terminals.forEach((terminal, tabId) => {
      if (terminal) {
        console.log(`[TERMINAL] Disposing terminal for tab ${tabId}`)
        terminal.dispose()
      }
    })
    terminals.clear()
    
    // 清理标签页引用，但保留标签页数据结构
    tabs.value.forEach(tab => {
      tab.terminal = null
      tab.socket = null
      tab.fitAddon = null
    })
  }
})

onMounted(() => {
  if (props.visible && tabs.value.length === 0) {
    newTab()
  }
})

onUnmounted(() => {
  sockets.forEach(socket => socket.close())
  terminals.forEach(terminal => terminal.dispose())
})
</script>

<style scoped>
.terminal-container {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: #1e1e1e;
  z-index: 1000;
  display: flex;
  flex-direction: column;
}

.terminal-toolbar {
  display: flex;
  align-items: center;
  padding: 8px 16px;
  background: #252526;
  border-bottom: 1px solid #3e3e42;
  gap: 12px;
  min-height: 48px;
}

.toolbar-left,
.toolbar-right {
  display: flex;
  gap: 8px;
  align-items: center;
}

.toolbar-center {
  flex: 1;
  display: flex;
  justify-content: center;
  overflow-x: auto;
}

.tabs-container {
  display: flex;
  gap: 4px;
  align-items: center;
}

.tab {
  display: flex;
  align-items: center;
  padding: 6px 16px;
  background: #2d2d30;
  color: #cccccc;
  border-radius: 4px 4px 0 0;
  cursor: pointer;
  gap: 8px;
  white-space: nowrap;
  transition: all 0.2s;
  min-width: 100px;
}

.tab:hover {
  background: #37373d;
}

.tab.active {
  background: #1e1e1e;
  color: #ffffff;
  border-bottom: 2px solid #007acc;
}

.tab-close {
  background: none;
  border: none;
  color: #cccccc;
  cursor: pointer;
  padding: 0 4px;
  font-size: 18px;
  line-height: 1;
  border-radius: 2px;
  transition: all 0.2s;
}

.tab-close:hover {
  color: #ffffff;
  background: #3e3e42;
}

.toolbar-btn {
  display: flex;
  align-items: center;
  padding: 6px 12px;
  background: #3e3e42;
  color: #cccccc;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 13px;
}

.toolbar-btn:hover {
  background: #505050;
  color: #ffffff;
}

.toolbar-btn svg {
  flex-shrink: 0;
}

.settings-panel {
  position: absolute;
  top: 48px;
  right: 16px;
  background: #252526;
  border: 1px solid #3e3e42;
  border-radius: 4px;
  padding: 16px;
  z-index: 1001;
  min-width: 250px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
}

.settings-title {
  color: #ffffff;
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
}

.settings-item {
  margin-bottom: 16px;
}

.settings-item label {
  display: block;
  color: #cccccc;
  font-size: 13px;
  margin-bottom: 6px;
}

.settings-item input,
.settings-item select {
  width: 100%;
  padding: 6px 8px;
  background: #3e3e42;
  color: #ffffff;
  border: 1px solid #3e3e42;
  border-radius: 4px;
  font-size: 13px;
}

.settings-item input:focus,
.settings-item select:focus {
  outline: none;
  border-color: #007acc;
}

.settings-close {
  width: 100%;
  padding: 8px;
  background: #007acc;
  color: #ffffff;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 13px;
  margin-top: 8px;
}

.settings-close:hover {
  background: #005a9e;
}

.terminal-content {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.terminal-pane {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  display: none;
}

.terminal-pane.active {
  display: block;
}

.terminal-wrapper {
  width: 100%;
  height: 100%;
  padding: 16px;
}
</style>

