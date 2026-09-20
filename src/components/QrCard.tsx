import { useEffect, useState } from 'react'
import { makeQrDataUrl } from '../lib/qr'
import { shareQrPng } from '../lib/shareQr'

interface QrCardProps {
  payload: string
  label: string
  hint?: string
  large?: boolean
}

export function QrCard({ payload, label, hint, large = false }: QrCardProps) {
  const [src, setSrc] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false
    void makeQrDataUrl(payload).then((url) => {
      if (!cancelled) {
        setSrc(url)
      }
    })
    return () => {
      cancelled = true
    }
  }, [payload])

  return (
    <article className={`qr-card ${large ? 'large' : ''}`}>
      <p className="qr-label">{label}</p>
      {src ? (
        <img className="qr-image" src={src} alt={`${label}のQRコード`} />
      ) : (
        <div className="qr-image skeleton" aria-hidden="true" />
      )}
      {hint ? <p className="qr-hint">かくしばしょ：{hint}</p> : null}
      {src ? (
        <button
          type="button"
          className="btn secondary qr-save"
          onClick={() => {
            void shareQrPng(src, `${label}.png`)
          }}
        >
          保存して印刷
        </button>
      ) : null}
    </article>
  )
}
