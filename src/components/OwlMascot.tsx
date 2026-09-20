import type { OwlMood } from './owlMood'

interface OwlMascotProps {
  mood?: OwlMood
  className?: string
}

export function OwlMascot({ mood = 'idle', className }: OwlMascotProps) {
  return (
    <svg
      className={`owl ${mood} ${className ?? ''}`}
      viewBox="0 0 200 220"
      role="img"
      aria-label="ふくろうのホーちゃん"
    >
      <ellipse cx="100" cy="200" rx="46" ry="10" fill="rgba(10,6,24,0.35)" />
      <path
        d="M42 118c0-52 26-92 58-92s58 40 58 92c0 38-18 70-58 70s-58-32-58-70z"
        fill="#6b4a2b"
      />
      <path
        d="M58 122c8 28 24 48 42 48s34-20 42-48c-8 10-24 16-42 16s-34-6-42-16z"
        fill="#8a5e34"
      />
      <path d="M78 168h44c-4 18-14 26-22 26s-18-8-22-26z" fill="#f3d7a0" />
      <circle cx="72" cy="108" r="32" fill="#fff7e8" />
      <circle cx="128" cy="108" r="32" fill="#fff7e8" />
      <g className="owl-eyes">
        <circle cx="72" cy="110" r="14" fill="#1a1238" />
        <circle cx="128" cy="110" r="14" fill="#1a1238" />
        <circle cx="67" cy="104" r="5" fill="#fff" />
        <circle cx="123" cy="104" r="5" fill="#fff" />
      </g>
      <path d="M92 124l8 16 8-16c-4 6-12 6-16 0z" fill="#ffb04a" />
      <path d="M40 78c8-28 24-44 40-48-18 16-28 36-30 58z" fill="#5a3b22" />
      <path d="M160 78c-8-28-24-44-40-48 18 16 28 36 30 58z" fill="#5a3b22" />
      <circle cx="48" cy="86" r="7" fill="#ffcb57" />
      <circle cx="152" cy="86" r="7" fill="#ffcb57" />
      <path
        className="owl-wing left"
        d="M40 128c-18 8-26 28-18 42 14-8 28-8 40-4-6-14-10-26-22-38z"
        fill="#5a3b22"
      />
      <path
        className="owl-wing right"
        d="M160 128c18 8 26 28 18 42-14-8-28-8-40-4 6-14 10-26 22-38z"
        fill="#5a3b22"
      />
    </svg>
  )
}
