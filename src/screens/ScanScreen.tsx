import { useEffect, useRef } from 'react'
import { encodeQrPayload } from '../lib/hunt'
import { playOops, playSuccess } from '../lib/audio'
import { scanSpeech, scanTitle } from '../lib/messages'
import { speakJapanese, stopSpeech } from '../lib/speech'
import { OwlMascot } from '../components/OwlMascot'
import { Scanner } from '../components/Scanner'
import { useGameStore } from '../store/gameStore'
import type { OwlMood } from '../components/owlMood'

export function ScanScreen() {
  const hunt = useGameStore((state) => state.hunt)
  const scanResult = useGameStore((state) => state.scanResult)
  const practiceMode = useGameStore((state) => state.practiceMode)
  const scanPayload = useGameStore((state) => state.scanPayload)
  const closeScan = useGameStore((state) => state.closeScan)
  const clearScanResult = useGameStore((state) => state.clearScanResult)
  const lastPayload = useRef('')

  useEffect(() => {
    return () => stopSpeech()
  }, [])

  useEffect(() => {
    if (!scanResult) {
      lastPayload.current = ''
      return
    }
    if (scanResult.kind === 'advanced' || scanResult.kind === 'cleared') {
      return
    }
    void playOops()
    speakJapanese(scanSpeech(scanResult))
  }, [scanResult])

  if (!hunt) {
    return null
  }

  const handleDetect = (payload: string) => {
    if (scanResult || lastPayload.current === payload) {
      return
    }
    lastPayload.current = payload
    const result = scanPayload(payload)
    if (result?.kind === 'advanced' || result?.kind === 'cleared') {
      void playSuccess()
    }
  }

  const mood: OwlMood =
    !scanResult ? 'talk' : scanResult.kind === 'advanced' || scanResult.kind === 'cleared' ? 'yay' : 'oops'

  return (
    <section className="screen scan">
      <header className="topbar overlay">
        <button type="button" className="btn secondary" onClick={closeScan} data-testid="close-scan">
          とじる
        </button>
        <p>わくのなかにQRを入れてね</p>
      </header>
      <Scanner
        onDetect={handleDetect}
        onError={(message) => {
          if (!practiceMode) {
            window.alert(message)
          }
        }}
      />
      {practiceMode ? (
        <div className="practice-row">
          {hunt.stages.map((stage) => (
            <button
              key={stage.index}
              type="button"
              className="btn practice"
              data-testid={`practice-${stage.index}`}
              onClick={() => handleDetect(encodeQrPayload(hunt, stage.index))}
            >
              {stage.index}ばんをよむ
            </button>
          ))}
        </div>
      ) : null}
      {scanResult && scanResult.kind !== 'advanced' && scanResult.kind !== 'cleared' ? (
        <div className="scan-toast" role="alert">
          <OwlMascot mood={mood} className="tiny-owl" />
          <div>
            <p className="toast-title">{scanTitle(scanResult)}</p>
            <p>{scanSpeech(scanResult)}</p>
          </div>
          <button type="button" className="btn primary" onClick={clearScanResult}>
            もういちど
          </button>
        </div>
      ) : null}
    </section>
  )
}
