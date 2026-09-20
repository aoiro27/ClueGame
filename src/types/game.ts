export const MIN_STAGES = 1
export const MAX_STAGES = 5
export const MAX_HINT_LENGTH = 80

export type HuntStatus = 'draft' | 'ready' | 'playing' | 'cleared'

export type Screen =
  | 'home'
  | 'parent'
  | 'setup-count'
  | 'setup-stage'
  | 'setup-ready'
  | 'play'
  | 'scan'
  | 'clear'
  | 'collection'

export interface Stage {
  index: number
  hint: string
  token: string
}

export interface Hunt {
  id: string
  createdAt: string
  stageCount: number
  stages: Stage[]
  currentStageIndex: number
  status: HuntStatus
}

export interface ParsedQr {
  huntId: string
  stageIndex: number
  token: string
}

export type ScanResult =
  | { kind: 'advanced'; nextStage: number; nextHint: string }
  | { kind: 'cleared' }
  | { kind: 'wrong_order'; expected: number; scanned: number }
  | { kind: 'already_found'; scanned: number }
  | { kind: 'unknown' }
  | { kind: 'already_cleared' }
  | { kind: 'not_playing' }

export type TreasureRarity = 'common' | 'rare' | 'legendary'
export type TreasureShape =
  | 'gem'
  | 'orb'
  | 'crown'
  | 'key'
  | 'medal'
  | 'map'
  | 'feather'
  | 'acorn'
  | 'bottle'
  | 'cat'

export interface Treasure {
  id: string
  name: string
  flavor: string
  rarity: TreasureRarity
  shape: TreasureShape
  hue: number
}

export interface CollectedTreasure {
  id: string
  treasureId: string
  huntId: string
  collectedAt: string
}
