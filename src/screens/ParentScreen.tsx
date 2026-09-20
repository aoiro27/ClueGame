import { OwlMascot } from '../components/OwlMascot'
import { useGameStore } from '../store/gameStore'

export function ParentScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const beginSetup = useGameStore((state) => state.beginSetup)
  const reviewQr = useGameStore((state) => state.reviewQr)
  const abandonHunt = useGameStore((state) => state.abandonHunt)
  const goTo = useGameStore((state) => state.goTo)
  const practiceMode = useGameStore((state) => state.practiceMode)
  const setPracticeMode = useGameStore((state) => state.setPracticeMode)

  const hasActive = hunt !== null && hunt.status !== 'cleared'

  return (
    <section className="screen parent">
      <header className="topbar">
        <button type="button" className="btn text" onClick={() => goTo('home')}>
          もどる
        </button>
        <h1>おとなのメニュー</h1>
      </header>
      <OwlMascot mood="sleep" className="tiny-owl" />
      <p className="lead quiet">
        QRを1〜5まい用意して、家のどこかにかくします。ヒントを書いたら、こどもにタブレットをわたしてください。
      </p>
      <div className="actions stack">
        <button
          type="button"
          className="btn primary"
          data-testid="begin-setup"
          onClick={() => {
            if (hasActive && !window.confirm('いまのぼうけんをやめて、新しく作る？')) {
              return
            }
            beginSetup()
          }}
        >
          あたらしいぼうけんをつくる
        </button>
        {hunt ? (
          <button type="button" className="btn secondary" onClick={reviewQr}>
            QRコードをひょうじする
          </button>
        ) : null}
        {hasActive ? (
          <button type="button" className="btn danger" onClick={abandonHunt}>
            いまのぼうけんをやめる
          </button>
        ) : null}
        <label className="check-row">
          <input
            type="checkbox"
            checked={practiceMode}
            onChange={(event) => setPracticeMode(event.target.checked)}
          />
          おなじタブレットでためす（カメラなし）
        </label>
      </div>
    </section>
  )
}
