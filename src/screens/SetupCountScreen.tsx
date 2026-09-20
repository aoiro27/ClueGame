import { MAX_STAGES } from '../lib/hunt'
import { useGameStore } from '../store/gameStore'

export function SetupCountScreen() {
  const chooseStageCount = useGameStore((state) => state.chooseStageCount)
  const goTo = useGameStore((state) => state.goTo)

  return (
    <section className="screen setup">
      <header className="topbar">
        <button type="button" className="btn text" onClick={() => goTo('parent')}>
          もどる
        </button>
        <h1>なんまい使う？</h1>
      </header>
      <p className="lead">かくすQRコードの枚数をえらんでね。さいだい5まい。</p>
      <div className="count-grid">
        {Array.from({ length: MAX_STAGES }, (_, offset) => {
          const count = offset + 1
          return (
            <button
              key={count}
              type="button"
              className="count-orb"
              data-testid={`count-${count}`}
              onClick={() => chooseStageCount(count)}
            >
              <span className="count-num">{count}</span>
              <span className="count-unit">まい</span>
            </button>
          )
        })}
      </div>
    </section>
  )
}
