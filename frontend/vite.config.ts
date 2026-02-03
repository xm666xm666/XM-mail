import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
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

export default defineConfig({
  plugins: [vue()],
  base: './',
  server: {
    port: getPortConfig(),
    host: true
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets'
  }
})
