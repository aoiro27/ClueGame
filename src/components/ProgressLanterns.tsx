interface ProgressLanternsProps {
  total: number
  current: number
}

export function ProgressLanterns({ total, current }: ProgressLanternsProps) {
  return (
    <ol className="lantern-path" aria-label={`いま ${current} ばんめ、ぜんぶで ${total} こ`}>
      {Array.from({ length: total }, (_, offset) => {
        const index = offset + 1
        const state = index < current ? 'done' : index === current ? 'now' : 'next'
        return (
          <li key={index} className={`lantern ${state}`}>
            <span className="lantern-glow" />
            <span className="lantern-body">{index}</span>
          </li>
        )
      })}
    </ol>
  )
}
