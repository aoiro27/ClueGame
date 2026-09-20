export async function shareQrPng(dataUrl: string, filename: string): Promise<void> {
  const response = await fetch(dataUrl)
  const blob = await response.blob()
  const file = new File([blob], filename, { type: 'image/png' })

  if (typeof navigator.canShare === 'function' && navigator.canShare({ files: [file] })) {
    await navigator.share({
      files: [file],
      title: filename.replace('.png', ''),
    })
    return
  }

  const link = document.createElement('a')
  link.href = dataUrl
  link.download = filename
  link.click()
}
