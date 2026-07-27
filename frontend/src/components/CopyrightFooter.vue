<script setup lang="ts">
import { computed } from 'vue'

export type IcpInfo = {
  enabled: boolean
  number: string
  url: string
}

const props = withDefaults(
  defineProps<{
    icp: IcpInfo
    version?: string
    /** 管理后台底栏 / 登录注册固定底栏 / 首页与更新日志内嵌 */
    variant?: 'dashboard' | 'auth' | 'marketing'
  }>(),
  {
    version: '',
    variant: 'dashboard'
  }
)

const showVersion = computed(() => Boolean(props.version && props.version.trim().length > 0))

const rootTag = computed(() => (props.variant === 'marketing' ? 'div' : 'footer'))

const rootAttrs = computed(() =>
  props.variant === 'marketing' ? { role: 'contentinfo' as const } : {}
)
</script>

<template>
  <component :is="rootTag" v-bind="rootAttrs" class="cf-root" :data-variant="variant">
    <div class="cf-glow-line" aria-hidden="true" />

    <div class="cf-inner">
      <div class="cf-primary">
        <span class="cf-symbol" aria-hidden="true">©</span>
        <span class="cf-years">2024–2026</span>
        <span class="cf-divider" aria-hidden="true" />
        <span class="cf-brand">XM</span>
        <a
          v-if="icp.enabled && icp.number"
          :href="icp.url"
          class="cf-icp"
          target="_blank"
          rel="noopener noreferrer"
        >
          {{ icp.number }}
        </a>
      </div>

      <p class="cf-tagline">
        <span class="cf-tagline-main">XM 邮件管理平台</span>
        <span class="cf-tagline-dot" aria-hidden="true">◆</span>
        <span class="cf-tagline-sub">智能无限，邮件无界</span>
      </p>

      <p v-if="showVersion" class="cf-build">
        <span class="cf-build-label">Powered by</span>
        <span class="cf-build-brand">XM</span>
        <span class="cf-build-ver">{{ version }}</span>
      </p>
    </div>
  </component>
</template>

<style scoped>
/* ========== 共享结构 ========== */
.cf-root {
  --cf-amber: #f59e0b;
  --cf-amber-soft: rgba(245, 158, 11, 0.35);
  --cf-cyan: rgba(34, 211, 238, 0.45);
  position: relative;
  overflow: hidden;
}

.cf-glow-line {
  height: 2px;
  width: 100%;
  margin-bottom: 1.25rem;
  background: linear-gradient(
    90deg,
    transparent 0%,
    var(--cf-cyan) 18%,
    var(--cf-amber-soft) 50%,
    var(--cf-cyan) 82%,
    transparent 100%
  );
  opacity: 0.9;
  box-shadow: 0 0 20px rgba(245, 158, 11, 0.15);
}

.cf-inner {
  max-width: 56rem;
  margin: 0 auto;
  text-align: center;
}

.cf-primary {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 0.5rem 0.75rem;
  margin-bottom: 0.65rem;
}

.cf-symbol {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--cf-amber);
  text-shadow: 0 0 24px rgba(245, 158, 11, 0.35);
}

.cf-years {
  font-size: 0.8125rem;
  font-weight: 500;
  letter-spacing: 0.12em;
  text-transform: uppercase;
  font-variant-numeric: tabular-nums;
}

.cf-divider {
  width: 4px;
  height: 4px;
  border-radius: 50%;
  background: linear-gradient(135deg, var(--cf-amber), #22d3ee);
  opacity: 0.85;
}

.cf-brand {
  font-size: 0.9375rem;
  font-weight: 800;
  letter-spacing: 0.28em;
  text-indent: 0.28em;
  background: linear-gradient(120deg, #fbbf24 0%, #f59e0b 45%, #22d3ee 100%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.cf-icp {
  margin-left: 0.25rem;
  display: inline-flex;
  align-items: center;
  padding: 0.2rem 0.65rem;
  font-size: 0.7rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-decoration: none;
  border-radius: 9999px;
  border: 1px solid rgba(245, 158, 11, 0.25);
  background: rgba(245, 158, 11, 0.06);
  transition:
    border-color 0.2s ease,
    background 0.2s ease,
    transform 0.2s ease;
}

.cf-icp:hover {
  border-color: rgba(245, 158, 11, 0.5);
  background: rgba(245, 158, 11, 0.12);
  transform: translateY(-1px);
}

.cf-tagline {
  margin: 0 0 0.5rem;
  font-size: 0.8125rem;
  font-weight: 500;
  line-height: 1.5;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 0.35rem 0.5rem;
}

.cf-tagline-dot {
  font-size: 0.35rem;
  color: rgba(245, 158, 11, 0.65);
  vertical-align: middle;
}

.cf-build {
  margin: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 0.35rem 0.5rem;
  font-size: 0.75rem;
}

.cf-build-label {
  opacity: 0.55;
  font-weight: 500;
}

.cf-build-brand {
  font-weight: 700;
  color: var(--cf-amber);
}

.cf-build-ver {
  font-family:
    ui-monospace,
    SFMono-Regular,
    Menlo,
    Monaco,
    Consolas,
    monospace;
  font-size: 0.7rem;
  font-weight: 600;
  padding: 0.15rem 0.5rem;
  border-radius: 0.375rem;
  border: 1px solid rgba(245, 158, 11, 0.22);
  background: rgba(245, 158, 11, 0.08);
}

/* ========== Dashboard（管理后台，浅色/深色） ========== */
.cf-root[data-variant='dashboard'] {
  padding: 0 1.5rem 1.35rem;
  background: rgb(249 250 251);
  border-top: 1px solid rgb(229 231 235);
}

.cf-root[data-variant='dashboard'] .cf-years {
  color: rgb(55 65 81);
}

.cf-root[data-variant='dashboard'] .cf-tagline-main,
.cf-root[data-variant='dashboard'] .cf-tagline-sub {
  color: rgb(107 114 128);
}

.cf-root[data-variant='dashboard'] .cf-icp {
  color: rgb(75 85 99);
  border-color: rgba(245, 158, 11, 0.3);
}

.cf-root[data-variant='dashboard'] .cf-build-label {
  color: rgb(107 114 128);
}

/* ========== Auth（登录 / 注册 / 重置） ========== */
.cf-root[data-variant='auth'] {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
  padding: max(1.1rem, env(safe-area-inset-top)) max(1.5rem, env(safe-area-inset-right))
    max(1.1rem, env(safe-area-inset-bottom)) max(1.5rem, env(safe-area-inset-left));
  background: linear-gradient(180deg, rgba(15, 23, 42, 0.88) 0%, rgba(12, 14, 20, 0.96) 100%);
  backdrop-filter: blur(20px) saturate(1.2);
  -webkit-backdrop-filter: blur(20px) saturate(1.2);
  border-top: 1px solid rgba(245, 158, 11, 0.14);
  box-shadow: 0 -12px 40px rgba(0, 0, 0, 0.35);
}

.cf-root[data-variant='auth'] .cf-glow-line {
  margin-bottom: 1rem;
  opacity: 1;
}

.cf-root[data-variant='auth'] .cf-years {
  color: rgba(248, 250, 252, 0.78);
}

.cf-root[data-variant='auth'] .cf-tagline-main,
.cf-root[data-variant='auth'] .cf-tagline-sub {
  color: rgba(248, 250, 252, 0.52);
}

.cf-root[data-variant='auth'] .cf-icp {
  color: rgba(248, 250, 252, 0.72);
  border-color: rgba(248, 250, 252, 0.12);
  background: rgba(255, 255, 255, 0.04);
}

.cf-root[data-variant='auth'] .cf-icp:hover {
  color: #fcd34d;
  border-color: rgba(251, 191, 36, 0.45);
  background: rgba(251, 191, 36, 0.08);
}

.cf-root[data-variant='auth'] .cf-build-label {
  color: rgba(248, 250, 252, 0.45);
}

/* ========== Marketing（首页 / 更新日志 内嵌） ========== */
.cf-root[data-variant='marketing'] {
  padding-top: 0.25rem;
}

.cf-root[data-variant='marketing'] .cf-glow-line {
  margin-bottom: 1.1rem;
}

.cf-root[data-variant='marketing'] .cf-years {
  color: rgba(248, 250, 252, 0.78);
}

.cf-root[data-variant='marketing'] .cf-tagline-main,
.cf-root[data-variant='marketing'] .cf-tagline-sub {
  color: rgba(248, 250, 252, 0.52);
}

.cf-root[data-variant='marketing'] .cf-icp {
  color: rgba(248, 250, 252, 0.72);
  border-color: rgba(255, 255, 255, 0.12);
  background: rgba(255, 255, 255, 0.04);
}

.cf-root[data-variant='marketing'] .cf-icp:hover {
  color: #fcd34d;
  border-color: rgba(251, 191, 36, 0.45);
}

.cf-root[data-variant='marketing'] .cf-build-label {
  color: rgba(248, 250, 252, 0.45);
}

@media (max-width: 768px) {
  .cf-root[data-variant='auth'] {
    padding: 0.85rem 1rem max(0.85rem, env(safe-area-inset-bottom));
  }

  .cf-primary {
    gap: 0.35rem 0.5rem;
  }

  .cf-brand {
    font-size: 0.8125rem;
    letter-spacing: 0.22em;
    text-indent: 0.22em;
  }

  .cf-tagline {
    font-size: 0.75rem;
  }

  .cf-build {
    font-size: 0.7rem;
  }
}
</style>

<!-- 深色模式：与 Layout 相同，主题类挂在 document.documentElement（html.dark）。
     放在非 scoped 中，避免 scoped+:global(.dark) 组合在部分构建下无法命中根节点 class。 -->
<style>
html.dark .cf-root[data-variant='dashboard'] {
  background: rgb(17 24 39);
  border-top-color: rgba(245, 158, 11, 0.12);
}

html.dark .cf-root[data-variant='dashboard'] .cf-years {
  color: rgb(209 213 219);
}

html.dark .cf-root[data-variant='dashboard'] .cf-tagline-main,
html.dark .cf-root[data-variant='dashboard'] .cf-tagline-sub {
  color: rgb(156 163 175);
}

html.dark .cf-root[data-variant='dashboard'] .cf-icp {
  color: rgb(209 213 219);
}

html.dark .cf-root[data-variant='dashboard'] .cf-build-label {
  color: rgb(156 163 175);
}

html.dark .cf-root[data-variant='dashboard'] .cf-build-ver {
  color: #fbbf24;
  border-color: rgba(251, 191, 36, 0.55);
  background: rgba(251, 191, 36, 0.14);
  box-shadow:
    0 0 0 1px rgba(251, 191, 36, 0.12),
    0 0 18px rgba(245, 158, 11, 0.22);
  text-shadow: 0 0 12px rgba(251, 191, 36, 0.35);
}
</style>
