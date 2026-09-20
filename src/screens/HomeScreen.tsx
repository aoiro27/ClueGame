import { HoldButton } from '../components/HoldButton'
import { OwlMascot } from '../components/OwlMascot'
import { useGameStore } from '../store/gameStore'

export function HomeScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const collectionCount = useGameStore((state) => state.collection.length)
  const startAdventure = useGameStore((state) => state.startAdventure)
  const goTo = useGameStore((state) => state.goTo)
  const openCollection = useGameStore((state) => state.openCollection)

  const canStart = hunt?.status === 'ready' || hunt?.status === 'playing'
  const isPlaying = hunt?.status === 'playing'
  const isCleared = hunt?.status === 'cleared'

  return (
    <section className="screen home">
      <div className="moon" aria-hidden="true" />
      <p className="eyebrow">よるの森のぼうけん</p>
      <h1 className="title display">たからさがし</h1>
      <OwlMascot mood={isCleared ? 'yay' : 'idle'} className="home-owl" />
      <p className="lead">
        {isPlaying
          ? 'ヒントをきいて、かくされたQRをみつけよう。'
          : isCleared
            ? 'このぼうけんはクリア！たからばこをみてみよう。'
            : canStart
              ? 'ホーちゃんといっしょに、QRをたどってたからをさがそう。'
              : 'おとなに、かくしものづくりをおねがいしてね。'}
      </p>
      <div className="actions">
        {canStart ? (
          <button
            type="button"
            className="btn primary huge"
            data-testid="start-adventure"
            onClick={startAdventure}
          >
            {isPlaying ? 'つづける' : 'ぼうけんスタート'}
          </button>
        ) : null}
        <button type="button" className="btn secondary" data-testid="open-collection" onClick={openCollection}>
          たからばこ
          {collectionCount > 0 ? <span className="badge">{collectionCount}</span> : null}
        </button>
      </div>
      <HoldButton className="btn ghost parent-entry" data-testid="parent-entry" onConfirm={() => goTo('parent')}>
        おとなのメニュー（長おし）
      </HoldButton>
    </section>
  )
}
