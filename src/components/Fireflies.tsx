import type { CSSProperties } from 'react'

export function Fireflies() {
  return (
    <div className="fireflies" aria-hidden="true">
      {Array.from({ length: 18 }, (_, index) => (
        <span key={index} className="firefly" style={{ '--i': String(index) } as CSSProperties} />
      ))}
    </div>
  )
}
