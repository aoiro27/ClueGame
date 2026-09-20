let sharedContext: AudioContext | null = null

function getContext(): AudioContext | null {
  if (typeof window === 'undefined') {
    return null
  }
  const AudioCtor = window.AudioContext || (window as Window & { webkitAudioContext?: typeof AudioContext }).webkitAudioContext
  if (!AudioCtor) {
    return null
  }
  if (!sharedContext) {
    sharedContext = new AudioCtor()
  }
  return sharedContext
}

function tone(
  ctx: AudioContext,
  frequency: number,
  start: number,
  duration: number,
  type: OscillatorType,
  gainValue: number,
) {
  const oscillator = ctx.createOscillator()
  const gain = ctx.createGain()
  oscillator.type = type
  oscillator.frequency.setValueAtTime(frequency, start)
  gain.gain.setValueAtTime(0.0001, start)
  gain.gain.exponentialRampToValueAtTime(gainValue, start + 0.02)
  gain.gain.exponentialRampToValueAtTime(0.0001, start + duration)
  oscillator.connect(gain).connect(ctx.destination)
  oscillator.start(start)
  oscillator.stop(start + duration + 0.02)
}

export async function playFanfare(): Promise<void> {
  const ctx = getContext()
  if (!ctx) {
    return
  }
  await ctx.resume()
  const now = ctx.currentTime
  const notes = [523.25, 659.25, 783.99, 1046.5]
  notes.forEach((frequency, index) => {
    tone(ctx, frequency, now + index * 0.11, 0.42, 'triangle', 0.09)
  })
}

export async function playSuccess(): Promise<void> {
  const ctx = getContext()
  if (!ctx) {
    return
  }
  await ctx.resume()
  const now = ctx.currentTime
  tone(ctx, 880, now, 0.16, 'triangle', 0.07)
  tone(ctx, 1320, now + 0.1, 0.22, 'triangle', 0.07)
}

export async function playOops(): Promise<void> {
  const ctx = getContext()
  if (!ctx) {
    return
  }
  await ctx.resume()
  const now = ctx.currentTime
  tone(ctx, 320, now, 0.18, 'sine', 0.05)
  tone(ctx, 220, now + 0.12, 0.22, 'sine', 0.05)
}
