import { encodeQrPayload } from '../lib/hunt'
import { QrCard } from '../components/QrCard'
import { useGameStore } from '../store/gameStore'

export function SetupReadyScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const startAdventure = useGameStore((state) => state.startAdventure)
  const goTo = useGameStore((state) => state.goTo)
  const practiceMode = useGameStore((state) => state.practiceMode)
  const setPracticeMode = useGameStore((state) => state.setPracticeMode)

  if (!hunt) {
    return null
  }

  return (
    <section className="screen setup ready">
      <header className="topbar">
        <button type="button" className="btn text" onClick={() => goTo('parent')}>
          もどる
        </button>
        <h1>かくしものセット</h1>
      </header>
      <p className="lead">QRを保存して印刷し、家のどこかにかくしたらスタート。</p>
      <div className="print-actions">
        <button type="button" className="btn secondary native-hide" onClick={() => window.print()}>
          全部いんさつ
        </button>
        <label className="check-row">
          <input
            type="checkbox"
            checked={practiceMode}
            data-testid="practice-toggle"
            onChange={(event) => setPracticeMode(event.target.checked)}
          />
          おなじタブレットでためす
        </label>
      </div>
      <div className="qr-grid print-area">
        {hunt.stages.map((stage) => (
          <QrCard
            key={stage.index}
            payload={encodeQrPayload(hunt, stage.index)}
            label={`${stage.index}まいめ`}
            hint={stage.hint}
          />
        ))}
      </div>
      <div className="actions">
        <button type="button" className="btn primary huge" data-testid="handoff-start" onClick={startAdventure}>
          こどもにわたしてスタート
        </button>
        <button type="button" className="btn ghost" onClick={() => goTo('home')}>
          ホームにもどる
        </button>
      </div>
    </section>
  )
}
