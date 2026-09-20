import type { ScanResult } from '../types/game'

export function scanSpeech(result: ScanResult): string {
  switch (result.kind) {
    case 'advanced':
      return `やったあ。つぎのヒントだよ。${result.nextHint}`
    case 'cleared':
      return 'クリア！たからをゲットしたよ'
    case 'wrong_order':
      return `まだだよ。いまは${result.expected}ばんをさがしてね`
    case 'already_found':
      return 'それはもうみつけたよ。つぎをさがしてね'
    case 'unknown':
      return 'このぼうけんのQRじゃないみたい'
    case 'already_cleared':
      return 'このぼうけんはもうクリアだよ'
    case 'not_playing':
      return 'まだぼうけんははじまっていないよ'
  }
}

export function scanTitle(result: ScanResult): string {
  switch (result.kind) {
    case 'advanced':
      return 'みつけた！'
    case 'cleared':
      return 'クリア！'
    case 'wrong_order':
      return 'まだだよ'
    case 'already_found':
      return 'もうみたよ'
    case 'unknown':
      return 'あれれ？'
    case 'already_cleared':
      return 'おわりだよ'
    case 'not_playing':
      return 'まってね'
  }
}

export function rarityLabel(rarity: 'common' | 'rare' | 'legendary'): string {
  switch (rarity) {
    case 'common':
      return 'ふつう'
    case 'rare':
      return 'レア'
    case 'legendary':
      return 'でんせつ'
  }
}
