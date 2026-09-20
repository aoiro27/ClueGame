import { useEffect, useRef } from 'react'
import { HoldButton } from '../components/HoldButton'
import { OwlMascot } from '../components/OwlMascot'
import { ProgressLanterns } from '../components/ProgressLanterns'
import { currentHint } from '../lib/hunt'
import { speakJapanese, stopSpeech } from '../lib/speech'
import { useGameStore } from '../store/gameStore'

export function PlayScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const openScan = useGameStore((state) => state.openScan)
  const goTo = useGameStore((state) => state.goTo)
  const lastSpoken = useRef<string>('')

  useEffect(() => {
    return () => stopSpeech()
  }, [])

  useEffect(() => {
    if (!hunt || hunt.status !== 'playing') {
      return
    }
    const hint = currentHint(hunt)
    const key = `${hunt.id}:${hunt.currentStageIndex}:${hint}`
    if (lastSpoken.current === key) {
      return
    }
    lastSpoken.current = key
    const intro =
      hunt.currentStageIndex === 1
        ? `さあ、ぼうけんのはじまりだよ。ヒントです。${hint}`
        : `つぎのヒントです。${hint}`
    speakJapanese(intro)
  }, [hunt])

  if (!hunt || hunt.status !== 'playing') {
    return null
  }

  const hint = currentHint(hunt)

  return (
    <section className="screen play">
      <header className="topbar">
        <HoldButton className="btn text" onConfirm={() => goTo('parent')}>
          おとな
        </HoldButton>
        <ProgressLanterns total={hunt.stageCount} current={hunt.currentStageIndex} />
      </header>
      <OwlMascot mood="talk" />
      <p className="eyebrow">{hunt.currentStageIndex}ばんめのヒント</p>
        <blockquote className="hint-bubble" data-testid="hint-bubble">
        <p>{hint}</p>
      </blockquote>
      <div className="actions">
        <button type="button" className="btn secondary" onClick={() => speakJapanese(hint)}>
          もういちどきく
        </button>
        <button type="button" className="btn primary huge" data-testid="open-scan" onClick={openScan}>
          QRをよむ
        </button>
      </div>
    </section>
  )
}
