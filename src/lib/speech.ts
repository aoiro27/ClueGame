let cachedVoice: SpeechSynthesisVoice | null = null

export function speakJapanese(text: string): void {
  if (typeof window === 'undefined' || !window.speechSynthesis) {
    return
  }

  window.speechSynthesis.cancel()
  const utterance = new SpeechSynthesisUtterance(text)
  utterance.lang = 'ja-JP'
  utterance.rate = 0.92
  utterance.pitch = 1.12
  const voice = cachedVoice ?? pickJapaneseVoice()
  if (voice) {
    cachedVoice = voice
    utterance.voice = voice
  }
  window.speechSynthesis.speak(utterance)
}

export function stopSpeech(): void {
  if (typeof window === 'undefined' || !window.speechSynthesis) {
    return
  }
  window.speechSynthesis.cancel()
}

function pickJapaneseVoice(): SpeechSynthesisVoice | null {
  const voices = window.speechSynthesis.getVoices()
  const japanese = voices.filter((voice) => voice.lang.toLowerCase().startsWith('ja'))
  if (japanese.length === 0) {
    return null
  }
  return (
    japanese.find((voice) => /kyoko|nanami|otoya|google/i.test(voice.name)) ??
    japanese[0] ??
    null
  )
}

if (typeof window !== 'undefined' && window.speechSynthesis) {
  cachedVoice = pickJapaneseVoice()
  window.speechSynthesis.addEventListener('voiceschanged', () => {
    cachedVoice = pickJapaneseVoice()
  })
}
