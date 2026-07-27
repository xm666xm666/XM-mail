<template>
  <div class="animated-bg" :class="variant">
    <!-- 动态渐变基底 -->
    <div class="bg-gradient-mesh"></div>
    
    <!-- 极光流动层 -->
    <div class="aurora aurora-1"></div>
    <div class="aurora aurora-2"></div>
    <div class="aurora aurora-3"></div>
    
    <!-- 发光球体 -->
    <div class="glow-orb orb-1"></div>
    <div class="glow-orb orb-2"></div>
    <div class="glow-orb orb-3"></div>
    <div class="glow-orb orb-4"></div>
    
    <!-- 流星/彗星 -->
    <div v-for="i in 5" :key="'meteor-' + i" class="meteor" :style="getMeteorStyle(i)"></div>
    
    <!-- 动态网格 -->
    <div class="grid-layer"></div>
    
    <!-- 粒子群 -->
    <div class="particles">
      <div v-for="i in 80" :key="i" class="particle" :style="getParticleStyle(i)"></div>
    </div>
    
    <!-- 光晕扫描线 -->
    <div class="scan-line"></div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  variant?: 'default' | 'login' | 'register' | 'reset'
}>()

const getParticleStyle = (index: number) => {
  const size = Math.random() * 2 + 0.5
  const duration = 15 + Math.random() * 25
  const delay = Math.random() * 20
  const x = Math.random() * 100
  return {
    width: `${size}px`,
    height: `${size}px`,
    left: `${x}%`,
    animationDuration: `${duration}s`,
    animationDelay: `${delay}s`
  }
}

const getMeteorStyle = (index: number) => {
  const delay = index * 8 + Math.random() * 15
  const duration = 2 + Math.random() * 1.5
  const left = 10 + index * 18 + Math.random() * 10
  return {
    animationDelay: `${delay}s`,
    animationDuration: `${duration}s`,
    left: `${left}%`
  }
}
</script>

<style scoped>
.animated-bg {
  position: fixed;
  inset: 0;
  z-index: 0;
  overflow: hidden;
  background: #050608;
}

/* 动态渐变网格基底 */
.bg-gradient-mesh {
  position: absolute;
  inset: 0;
  background: 
    radial-gradient(ellipse 120% 80% at 20% 20%, rgba(245, 158, 11, 0.15) 0%, transparent 50%),
    radial-gradient(ellipse 100% 60% at 80% 80%, rgba(6, 182, 212, 0.12) 0%, transparent 50%),
    radial-gradient(ellipse 80% 100% at 50% 50%, rgba(139, 92, 246, 0.08) 0%, transparent 50%);
  animation: gradientShift 15s ease-in-out infinite alternate;
}

@keyframes gradientShift {
  0% { opacity: 1; transform: scale(1) rotate(0deg); }
  100% { opacity: 0.9; transform: scale(1.1) rotate(2deg); }
}

/* 极光流动效果 */
.aurora {
  position: absolute;
  inset: -50%;
  filter: blur(80px);
  animation: auroraFlow 14s ease-in-out infinite;
}

.aurora-1 {
  animation-delay: 0s;
  background: linear-gradient(
    135deg,
    transparent 0%,
    rgba(245, 158, 11, 0.06) 25%,
    rgba(6, 182, 212, 0.05) 50%,
    rgba(139, 92, 246, 0.04) 75%,
    transparent 100%
  );
}

.aurora-2 {
  animation-delay: -5s;
  animation-duration: 18s;
  background: linear-gradient(
    225deg,
    transparent 0%,
    rgba(6, 182, 212, 0.06) 30%,
    rgba(245, 158, 11, 0.05) 60%,
    transparent 100%
  );
}

.aurora-3 {
  animation-delay: -10s;
  animation-duration: 22s;
  background: linear-gradient(
    315deg,
    transparent 0%,
    rgba(139, 92, 246, 0.05) 40%,
    rgba(245, 158, 11, 0.04) 70%,
    transparent 100%
  );
}

@keyframes auroraFlow {
  0%, 100% {
    opacity: 0.5;
    transform: translate(0, 0) scale(1);
  }
  33% {
    opacity: 0.9;
    transform: translate(5%, -8%) scale(1.15);
  }
  66% {
    opacity: 0.7;
    transform: translate(-8%, 5%) scale(1.05);
  }
}

/* 发光球体 */
.glow-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  animation: orbFloat 20s ease-in-out infinite;
}

.orb-1 {
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, rgba(245, 158, 11, 0.5) 0%, rgba(251, 191, 36, 0.15) 40%, transparent 70%);
  top: -100px;
  right: -80px;
  animation-delay: 0s;
  box-shadow: 0 0 120px rgba(245, 158, 11, 0.3);
}

.orb-2 {
  width: 350px;
  height: 350px;
  background: radial-gradient(circle, rgba(6, 182, 212, 0.4) 0%, transparent 60%);
  bottom: -80px;
  left: -100px;
  animation-delay: -5s;
  box-shadow: 0 0 100px rgba(6, 182, 212, 0.25);
}

.orb-3 {
  width: 280px;
  height: 280px;
  background: radial-gradient(circle, rgba(139, 92, 246, 0.3) 0%, transparent 60%);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  animation-delay: -10s;
  animation-duration: 25s;
}

.orb-4 {
  width: 200px;
  height: 200px;
  background: radial-gradient(circle, rgba(245, 158, 11, 0.35) 0%, transparent 70%);
  top: 70%;
  right: 20%;
  animation-delay: -15s;
  animation-duration: 18s;
}

@keyframes orbFloat {
  0%, 100% {
    transform: translate(0, 0) scale(1);
    opacity: 0.8;
  }
  25% {
    transform: translate(40px, -30px) scale(1.15);
    opacity: 1;
  }
  50% {
    transform: translate(-20px, 40px) scale(0.95);
    opacity: 0.9;
  }
  75% {
    transform: translate(-30px, -20px) scale(1.05);
    opacity: 1;
  }
}

.orb-3 {
  animation-name: orbFloatCenter;
}

@keyframes orbFloatCenter {
  0%, 100% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0.6;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.2);
    opacity: 1;
  }
}

/* 流星效果 */
.meteor {
  position: absolute;
  width: 2px;
  height: 2px;
  background: rgba(255, 255, 255, 0.9);
  border-radius: 50%;
  box-shadow: 
    0 0 6px 2px rgba(255, 255, 255, 0.8),
    0 0 20px 4px rgba(245, 158, 11, 0.4);
  animation: meteorFall linear infinite;
  top: -20px;
}

.meteor::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  width: 60px;
  height: 1px;
  background: linear-gradient(90deg, rgba(255,255,255,0.6), transparent);
  transform: translate(-100%, -50%);
}

@keyframes meteorFall {
  0% {
    transform: translateY(0) translateX(0);
    opacity: 1;
  }
  70% {
    opacity: 1;
  }
  100% {
    transform: translateY(100vh) translateX(-200px);
    opacity: 0;
  }
}

/* 动态网格 */
.grid-layer {
  position: absolute;
  inset: 0;
  background-image: 
    linear-gradient(rgba(245, 158, 11, 0.06) 1px, transparent 1px),
    linear-gradient(90deg, rgba(245, 158, 11, 0.06) 1px, transparent 1px);
  background-size: 50px 50px;
  animation: gridPulse 4s ease-in-out infinite;
  mask-image: radial-gradient(ellipse 80% 80% at 50% 50%, black 20%, transparent 70%);
}

@keyframes gridPulse {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

/* 粒子 */
.particles {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.particle {
  position: absolute;
  background: rgba(251, 191, 36, 0.9);
  border-radius: 50%;
  box-shadow: 0 0 8px 2px rgba(245, 158, 11, 0.5);
  animation: particleRise linear infinite;
  bottom: -10px;
}

@keyframes particleRise {
  0% {
    transform: translateY(0) translateX(0) scale(1);
    opacity: 0;
  }
  5% {
    opacity: 0.8;
  }
  95% {
    opacity: 0.6;
  }
  100% {
    transform: translateY(-100vh) translateX(30px) scale(0.5);
    opacity: 0;
  }
}

/* 扫描线光效 */
.scan-line {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(
    90deg,
    transparent,
    rgba(245, 158, 11, 0.3),
    rgba(6, 182, 212, 0.3),
    transparent
  );
  animation: scanMove 8s linear infinite;
  box-shadow: 0 0 20px rgba(245, 158, 11, 0.2);
}

@keyframes scanMove {
  0% { top: 0; opacity: 0.5; }
  10% { opacity: 1; }
  90% { opacity: 1; }
  100% { top: 100%; opacity: 0.5; }
}

/* 变体：登录页偏金色 */
.animated-bg.login .orb-2 {
  background: radial-gradient(circle, rgba(245, 158, 11, 0.35) 0%, transparent 60%);
}

/* 变体：注册页偏青色 */
.animated-bg.register .orb-1 {
  background: radial-gradient(circle, rgba(6, 182, 212, 0.4) 0%, transparent 60%);
}

/* 变体：重置页偏琥珀 */
.animated-bg.reset .orb-1 {
  background: radial-gradient(circle, rgba(251, 146, 60, 0.45) 0%, transparent 60%);
}
</style>
