import { useEffect, useRef, useState, type PointerEvent, type ReactNode } from 'react'

interface HoldButtonProps {
  children: ReactNode
  onConfirm: () => void
  holdMs?: number
  className?: string
  tapsToUnlock?: number
  'data-testid'?: string
}

export function HoldButton({
  children,
  onConfirm,
  holdMs = 1300,
  className,
  tapsToUnlock = 5,
  'data-testid': testId,
}: HoldButtonProps) {
  const [progress, setProgress] = useState(0)
  const frame = useRef<number | null>(null)
  const startedAt = useRef<number | null>(null)
  const ignoreClick = useRef(false)
  const taps = useRef(0)
  const tapReset = useRef<number | null>(null)

  useEffect(() => {
    return () => {
      if (frame.current) {
        cancelAnimationFrame(frame.current)
      }
      if (tapReset.current) {
        window.clearTimeout(tapReset.current)
      }
    }
  }, [])

  const stop = () => {
    if (frame.current) {
      cancelAnimationFrame(frame.current)
    }
    startedAt.current = null
    setProgress(0)
  }

  const tick = (now: number) => {
    if (startedAt.current === null) {
      return
    }
    const ratio = Math.min(1, (now - startedAt.current) / holdMs)
    setProgress(ratio)
    if (ratio >= 1) {
      ignoreClick.current = true
      taps.current = 0
      stop()
      onConfirm()
      return
    }
    frame.current = requestAnimationFrame(tick)
  }

  const onPointerDown = (event: PointerEvent<HTMLButtonElement>) => {
    if (event.pointerType === 'touch') {
      event.preventDefault()
    }
    startedAt.current = performance.now()
    frame.current = requestAnimationFrame(tick)
  }

  const onClick = () => {
    if (ignoreClick.current) {
      ignoreClick.current = false
      return
    }
    taps.current += 1
    if (tapReset.current) {
      window.clearTimeout(tapReset.current)
    }
    tapReset.current = window.setTimeout(() => {
      taps.current = 0
    }, 2500)
    if (taps.current >= tapsToUnlock) {
      taps.current = 0
      onConfirm()
    }
  }

  return (
    <button
      type="button"
      className={className}
      data-testid={testId}
      onPointerDown={onPointerDown}
      onPointerUp={stop}
      onPointerCancel={stop}
      onPointerLeave={stop}
      onClick={onClick}
    >
      <span className="hold-label">{children}</span>
      <span className="hold-track" aria-hidden="true">
        <span className="hold-fill" style={{ transform: `scaleX(${progress})` }} />
      </span>
    </button>
  )
}
