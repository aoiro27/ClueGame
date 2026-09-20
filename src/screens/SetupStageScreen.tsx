import { encodeQrPayload, MAX_HINT_LENGTH } from '../lib/hunt'
import { QrCard } from '../components/QrCard'
import { useGameStore } from '../store/gameStore'

export function SetupStageScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const setupIndex = useGameStore((state) => state.setupIndex)
  const updateCurrentHint = useGameStore((state) => state.updateCurrentHint)
  const nextSetupStage = useGameStore((state) => state.nextSetupStage)
  const prevSetupStage = useGameStore((state) => state.prevSetupStage)

  if (!hunt) {
    return null
  }

  const stage = hunt.stages.find((item) => item.index === setupIndex)
  if (!stage) {
    return null
  }

  const isLast = setupIndex === hunt.stageCount
  const canNext = stage.hint.length > 0

  return (
    <section className="screen setup">
      <header className="topbar">
        <button type="button" className="btn text" onClick={prevSetupStage}>
          まえへ
        </button>
        <p className="step">
          {setupIndex} / {hunt.stageCount}
        </p>
      </header>
      <h1>かくして、ヒントをかいてね</h1>
      <p className="lead">
        このQRを印刷するか画面に出して、家のどこかにかくします。かくした場所をこども向けの言葉で書いてください。
      </p>
      <QrCard
        large
        payload={encodeQrPayload(hunt, setupIndex)}
        label={`${setupIndex}まいめ`}
        hint={stage.hint || undefined}
      />
      <label className="field">
        <span>かくしたばしょのヒント</span>
        <textarea
          value={stage.hint}
          maxLength={MAX_HINT_LENGTH}
          rows={3}
          placeholder="れい：リビングのソファのした"
          data-testid="hint-input"
          onChange={(event) => updateCurrentHint(event.target.value)}
        />
        <small>
          {stage.hint.length}/{MAX_HINT_LENGTH}
        </small>
      </label>
      <button
        type="button"
        className="btn primary huge"
        disabled={!canNext}
        data-testid="setup-next"
        onClick={nextSetupStage}
      >
        {isLast ? 'QRをそろえる' : 'つぎのQRへ'}
      </button>
    </section>
  )
}
