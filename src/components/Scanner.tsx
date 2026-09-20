import { useEffect, useRef } from 'react'
import jsQR from 'jsqr'

interface ScannerProps {
  onDetect: (text: string) => void
  onError: (message: string) => void
}

export function Scanner({ onDetect, onError }: ScannerProps) {
  const videoRef = useRef<HTMLVideoElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const onDetectRef = useRef(onDetect)
  const onErrorRef = useRef(onError)

  onDetectRef.current = onDetect
  onErrorRef.current = onError

  useEffect(() => {
    const video = videoRef.current
    const canvas = canvasRef.current
    if (!video || !canvas) {
      return
    }

    let stream: MediaStream | null = null
    let frame = 0
    let stopped = false
    const context = canvas.getContext('2d', { willReadFrequently: true })

    const loop = () => {
      if (stopped) {
        return
      }
      if (context && video.readyState >= 2) {
        const scale = 480 / Math.max(video.videoWidth, 1)
        const width = Math.max(1, Math.floor(video.videoWidth * scale))
        const height = Math.max(1, Math.floor(video.videoHeight * scale))
        canvas.width = width
        canvas.height = height
        context.drawImage(video, 0, 0, width, height)
        const image = context.getImageData(0, 0, width, height)
        const code = jsQR(image.data, width, height)
        if (code?.data) {
          onDetectRef.current(code.data)
        }
      }
      frame = requestAnimationFrame(loop)
    }

    const start = async () => {
      try {
        try {
          stream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: { ideal: 'environment' } },
            audio: false,
          })
        } catch {
          stream = await navigator.mediaDevices.getUserMedia({
            video: true,
            audio: false,
          })
        }
        video.setAttribute('playsinline', 'true')
        video.setAttribute('webkit-playsinline', 'true')
        video.muted = true
        video.playsInline = true
        video.srcObject = stream
        await video.play()
        frame = requestAnimationFrame(loop)
      } catch {
        onErrorRef.current('カメラが使えないよ。おとなにカメラの許可をたのんでね。')
      }
    }

    void start()

    return () => {
      stopped = true
      cancelAnimationFrame(frame)
      stream?.getTracks().forEach((track) => track.stop())
    }
  }, [])

  return (
    <div className="scanner">
      <video ref={videoRef} className="scanner-video" playsInline muted />
      <canvas ref={canvasRef} className="scanner-canvas" />
      <div className="viewfinder" aria-hidden="true" />
    </div>
  )
}
