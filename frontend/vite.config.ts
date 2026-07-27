import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import tailwindcss from '@tailwindcss/vite'
import fs from 'fs'
import path from 'path'

// 读取端口配置
function getPortConfig() {
  const portConfigFile = path.join(__dirname, '..', 'config', 'port-config.json')
  let devPort = 5173 // 默认端口
  
  try {
    if (fs.existsSync(portConfigFile)) {
      const portConfig = JSON.parse(fs.readFileSync(portConfigFile, 'utf8'))
      if (portConfig.frontend && portConfig.frontend.devPort) {
        devPort = parseInt(portConfig.frontend.devPort, 10)
      }
    }
  } catch (error) {
    console.warn('读取端口配置失败，使用默认端口 5173:', error.message)
  }
  
  return devPort
}

// 读取 API 端口
function getApiPort() {
  const portConfigFile = path.join(__dirname, '..', 'config', 'port-config.json')
  try {
    if (fs.existsSync(portConfigFile)) {
      const portConfig = JSON.parse(fs.readFileSync(portConfigFile, 'utf8'))
      if (portConfig.api && portConfig.api.port) {
        return parseInt(portConfig.api.port, 10)
      }
    }
  } catch {
    // ignore
  }
  return 8081
}

export default defineConfig({
  plugins: [tailwindcss(), vue()],
  base: './',
  server: {
    port: getPortConfig(),
    host: true,
    proxy: {
      '/api': {
        target: `http://127.0.0.1:${getApiPort()}`,
        changeOrigin: true
      }
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})
