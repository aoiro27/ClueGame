import QRCode from 'qrcode'

export async function makeQrDataUrl(payload: string): Promise<string> {
  return QRCode.toDataURL(payload, {
    width: 640,
    margin: 1,
    errorCorrectionLevel: 'M',
    color: {
      dark: '#1a1238',
      light: '#fffdf4',
    },
  })
}
