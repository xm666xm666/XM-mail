// 简单 CSRF Token 工具（前端生成并通过自定义请求头发送）
// 说明：
// - Token 存在于 sessionStorage，仅在当前浏览器会话内有效
// - 后端应在非 GET/HEAD/OPTIONS 请求中校验此头是否存在（例如 X-CSRF-Token）

const CSRF_TOKEN_KEY = 'csrfToken'

function generateToken (): string {
  // 简单随机串（足够防止猜测，不用于密码学场景）
  const array = new Uint8Array(16)
  if (window.crypto && window.crypto.getRandomValues) {
    window.crypto.getRandomValues(array)
  } else {
    for (let i = 0; i < array.length; i++) {
      array[i] = Math.floor(Math.random() * 256)
    }
  }
  return Array.from(array).map(b => b.toString(16).padStart(2, '0')).join('')
}

export function getCsrfToken (): string {
  let token = sessionStorage.getItem(CSRF_TOKEN_KEY)
  if (!token) {
    token = generateToken()
    try {
      sessionStorage.setItem(CSRF_TOKEN_KEY, token)
    } catch {
      // 忽略存储错误（例如隐私模式），直接使用内存中的 token
    }
  }
  return token
}

export function csrfHeader (): Record<string, string> {
  return {
    'X-CSRF-Token': getCsrfToken()
  }
}

