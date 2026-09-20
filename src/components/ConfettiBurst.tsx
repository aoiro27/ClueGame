import { useEffect, useRef } from 'react'

interface ConfettiBurstProps {
  active: boolean
}

interface Particle {
  x: number
  y: number
  vx: number
  vy: number
  size: number
  color: string
  life: number
  rotation: number
  spin: number
}

const COLORS = ['#ffcb57', '#ff6f91', '#7ec8e3', '#7ddea5', '#fff3d6', '#c084fc']

export function ConfettiBurst({ active }: ConfettiBurstProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    if (!active) {
      return
    }
    const canvas = canvasRef.current
    if (!canvas) {
      return
    }
    const context = canvas.getContext('2d')
    if (!context) {
      return
    }

    const particles: Particle[] = Array.from({ length: 90 }, () => ({
      x: canvas.clientWidth * (0.3 + Math.random() * 0.4),
      y: canvas.clientHeight * 0.35,
      vx: (Math.random() - 0.5) * 9,
      vy: -Math.random() * 8 - 3,
      size: 6 + Math.random() * 8,
      color: COLORS[Math.floor(Math.random() * COLORS.length)]!,
      life: 1,
      rotation: Math.random() * Math.PI,
      spin: (Math.random() - 0.5) * 0.3,
    }))

    let frame = 0
    const resize = () => {
      canvas.width = canvas.clientWidth * window.devicePixelRatio
      canvas.height = canvas.clientHeight * window.devicePixelRatio
      context.setTransform(window.devicePixelRatio, 0, 0, window.devicePixelRatio, 0, 0)
    }
    resize()

    const tick = () => {
      context.clearRect(0, 0, canvas.clientWidth, canvas.clientHeight)
      let alive = false
      for (const particle of particles) {
        particle.vy += 0.18
        particle.x += particle.vx
        particle.y += particle.vy
        particle.rotation += particle.spin
        particle.life -= 0.008
        if (particle.life <= 0) {
          continue
        }
        alive = true
        context.save()
        context.translate(particle.x, particle.y)
        context.rotate(particle.rotation)
        context.globalAlpha = Math.max(0, particle.life)
        context.fillStyle = particle.color
        context.fillRect(-particle.size / 2, -particle.size / 4, particle.size, particle.size / 2)
        context.restore()
      }
      if (alive) {
        frame = requestAnimationFrame(tick)
      }
    }
    frame = requestAnimationFrame(tick)
    return () => cancelAnimationFrame(frame)
  }, [active])

  return <canvas ref={canvasRef} className="confetti-canvas" aria-hidden="true" />
}
