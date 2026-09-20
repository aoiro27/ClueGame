import { useEffect, useState, lazy, Suspense } from 'react'
import { ConfettiBurst } from '../components/ConfettiBurst'
import { OwlMascot } from '../components/OwlMascot'
import { TreasureArt } from '../components/TreasureArt'
import { playFanfare } from '../lib/audio'
import { rarityLabel } from '../lib/messages'
import { speakJapanese, stopSpeech } from '../lib/speech'
import { getTreasure } from '../lib/treasures'
import { useGameStore } from '../store/gameStore'

const TreasureScene = lazy(async () => {
  const module = await import('../scenes/TreasureScene')
  return { default: module.TreasureScene }
})

export function ClearScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const lastAwardedId = useGameStore((state) => state.lastAwardedId)
  const collection = useGameStore((state) => state.collection)
  const finishClear = useGameStore((state) => state.finishClear)
  const [open, setOpen] = useState(false)

  const awarded = collection.find((item) => item.id === lastAwardedId)
  const treasure = awarded ? getTreasure(awarded.treasureId) : getTreasure('star-drop')

  useEffect(() => {
    const openTimer = window.setTimeout(() => setOpen(true), 500)
    const speakTimer = window.setTimeout(() => {
      void playFanfare()
      speakJapanese(`クリア！${treasure.name}をゲットしたよ`)
    }, 900)
    return () => {
      window.clearTimeout(openTimer)
      window.clearTimeout(speakTimer)
      stopSpeech()
    }
  }, [treasure.name])

  return (
    <section className="screen clear">
      <ConfettiBurst active={open} />
      <div className="clear-stage">
        <Suspense fallback={<div className="treasure-canvas" />}>
          <TreasureScene hue={treasure.hue} open={open} />
        </Suspense>
      </div>
      <div className="clear-copy">
        <OwlMascot mood="yay" className="tiny-owl" />
        <p className="eyebrow">ぼうけんクリア</p>
        <h1 className="display">たからを GET！</h1>
        <div className="get-card">
          <TreasureArt treasure={treasure} className="get-art" />
          <p className="rarity">{rarityLabel(treasure.rarity)}</p>
          <h2 data-testid="treasure-name">{treasure.name}</h2>
          <p>{treasure.flavor}</p>
        </div>
        {hunt ? <p className="quiet">QRを{hunt.stageCount}まい、ぜんぶみつけたよ</p> : null}
        <button type="button" className="btn primary huge" data-testid="finish-clear" onClick={finishClear}>
          たからばこをみる
        </button>
      </div>
    </section>
  )
}
