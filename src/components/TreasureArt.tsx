import type { Treasure, TreasureShape } from '../types/game'

interface TreasureArtProps {
  treasure: Treasure
  className?: string
}

export function TreasureArt({ treasure, className }: TreasureArtProps) {
  const fill = `hsl(${treasure.hue} 72% 58%)`
  const shine = `hsl(${treasure.hue} 90% 78%)`
  return (
    <svg className={className} viewBox="0 0 160 160" aria-hidden="true">
      <defs>
        <radialGradient id={`g-${treasure.id}`} cx="35%" cy="30%">
          <stop offset="0%" stopColor={shine} />
          <stop offset="70%" stopColor={fill} />
          <stop offset="100%" stopColor={`hsl(${treasure.hue} 55% 32%)`} />
        </radialGradient>
      </defs>
      <ellipse cx="80" cy="138" rx="38" ry="8" fill="rgba(12,8,28,0.28)" />
      {renderShape(treasure.shape, `url(#g-${treasure.id})`, fill)}
    </svg>
  )
}

function renderShape(shape: TreasureShape, gradient: string, fill: string) {
  switch (shape) {
    case 'gem':
      return <polygon points="80,18 132,70 80,142 28,70" fill={gradient} />
    case 'orb':
      return <circle cx="80" cy="78" r="48" fill={gradient} />
    case 'crown':
      return (
        <g>
          <path d="M28 92l18-40 18 28 16-44 16 44 18-28 18 40v18H28z" fill={gradient} />
          <rect x="28" y="108" width="104" height="14" rx="4" fill={fill} />
        </g>
      )
    case 'key':
      return (
        <g fill={gradient}>
          <circle cx="52" cy="58" r="22" />
          <circle cx="52" cy="58" r="8" fill="#1a1238" />
          <rect x="70" y="52" width="62" height="12" rx="4" />
          <rect x="114" y="64" width="10" height="18" rx="3" />
          <rect x="96" y="64" width="10" height="14" rx="3" />
        </g>
      )
    case 'medal':
      return (
        <g>
          <path d="M58 20h44l-10 36H68z" fill="#d94b6b" />
          <circle cx="80" cy="92" r="40" fill={gradient} />
          <circle cx="80" cy="92" r="22" fill="none" stroke="#fff8" strokeWidth="4" />
        </g>
      )
    case 'map':
      return (
        <g>
          <path d="M30 40l30-8 40 10 30-8v88l-30 8-40-10-30 8z" fill={gradient} />
          <path d="M60 48v82M100 42v84" stroke="#fff6" strokeWidth="3" />
        </g>
      )
    case 'feather':
      return (
        <path
          d="M118 24c-40 8-70 48-78 108 28-18 62-26 86-22-18-28-16-60-8-86z"
          fill={gradient}
        />
      )
    case 'acorn':
      return (
        <g>
          <ellipse cx="80" cy="58" rx="36" ry="18" fill="#7a4a22" />
          <ellipse cx="80" cy="96" rx="32" ry="40" fill={gradient} />
          <rect x="76" y="28" width="8" height="18" rx="3" fill="#5a3418" />
        </g>
      )
    case 'bottle':
      return (
        <g>
          <rect x="68" y="18" width="24" height="22" rx="6" fill="#cfd8e6" />
          <path d="M50 48h60l-8 84H58z" fill={gradient} />
          <circle cx="80" cy="92" r="10" fill="#fff8" />
        </g>
      )
    case 'cat':
      return (
        <g fill={gradient}>
          <path d="M46 58l-8-28 28 16z" />
          <path d="M114 58l8-28-28 16z" />
          <ellipse cx="80" cy="88" rx="44" ry="40" />
          <ellipse cx="80" cy="122" rx="36" ry="22" />
          <circle cx="64" cy="84" r="6" fill="#1a1238" />
          <circle cx="96" cy="84" r="6" fill="#1a1238" />
        </g>
      )
  }
}
