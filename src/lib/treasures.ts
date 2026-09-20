import type { CollectedTreasure, Treasure } from '../types/game'
import { createId, hashString } from './ids'

export const TREASURES: Treasure[] = [
  {
    id: 'star-drop',
    name: 'ほしのしずく',
    flavor: 'よるの空からおちてきた、ひかりのかけら。',
    rarity: 'rare',
    shape: 'gem',
    hue: 210,
  },
  {
    id: 'gold-acorn',
    name: 'きんのドングリ',
    flavor: 'もりのみずかみが、だいじにとっておいたおやつ。',
    rarity: 'common',
    shape: 'acorn',
    hue: 38,
  },
  {
    id: 'moon-pendant',
    name: 'つきのペンダント',
    flavor: 'みかづきが、小さなアクセサリーになったよ。',
    rarity: 'rare',
    shape: 'medal',
    hue: 48,
  },
  {
    id: 'rainbow-orb',
    name: 'にじのたま',
    flavor: 'てにすると、へやのなかがにじいろにひかる。',
    rarity: 'legendary',
    shape: 'orb',
    hue: 280,
  },
  {
    id: 'tiny-crown',
    name: 'ちいさなおうかん',
    flavor: 'だれでも、きょうだけはおうさま。',
    rarity: 'rare',
    shape: 'crown',
    hue: 46,
  },
  {
    id: 'magic-key',
    name: 'まほうのカギ',
    flavor: 'まだみたことのないとびらが、どこかにあるらしい。',
    rarity: 'common',
    shape: 'key',
    hue: 28,
  },
  {
    id: 'owl-medal',
    name: 'ふくろうのメダル',
    flavor: 'かしこいぼうけんかだけがもらえるしるし。',
    rarity: 'rare',
    shape: 'medal',
    hue: 25,
  },
  {
    id: 'sea-pearl',
    name: 'うみのパール',
    flavor: 'しずかなうみが、まるめてくれたたま。',
    rarity: 'common',
    shape: 'orb',
    hue: 180,
  },
  {
    id: 'dragon-scale',
    name: 'りゅうのウロコ',
    flavor: 'やさしいりゅうが、おみやげにくれたひとかけ。',
    rarity: 'legendary',
    shape: 'gem',
    hue: 150,
  },
  {
    id: 'secret-map',
    name: 'ひみつのちず',
    flavor: 'つぎのぼうけんが、うすくかいてある。',
    rarity: 'common',
    shape: 'map',
    hue: 32,
  },
  {
    id: 'fairy-feather',
    name: 'フェアリーのはね',
    flavor: 'かぜにのると、すこしだけうかびそう。',
    rarity: 'rare',
    shape: 'feather',
    hue: 310,
  },
  {
    id: 'ruby-shard',
    name: 'ルビーのかけら',
    flavor: 'あかくて、あったかい。てのひらがにえるみたい。',
    rarity: 'common',
    shape: 'gem',
    hue: 0,
  },
  {
    id: 'gold-compass',
    name: 'きんのコンパス',
    flavor: 'いつも、たのしいほうをさす。',
    rarity: 'rare',
    shape: 'medal',
    hue: 42,
  },
  {
    id: 'star-bottle',
    name: 'ほしのビン',
    flavor: 'ふたをあけると、小さな夜がもれるよ。',
    rarity: 'legendary',
    shape: 'bottle',
    hue: 255,
  },
  {
    id: 'lucky-cat',
    name: 'まねきねこ',
    flavor: 'みぎてをふって、つぎのたからをよんでいる。',
    rarity: 'common',
    shape: 'cat',
    hue: 12,
  },
]

export function getTreasure(treasureId: string): Treasure {
  return TREASURES.find((item) => item.id === treasureId) ?? TREASURES[0]!
}

export function pickTreasureId(ownedTreasureIds: string[], huntId: string): string {
  const uniqueOwned = new Set(ownedTreasureIds)
  const unowned = TREASURES.filter((item) => !uniqueOwned.has(item.id))
  const pool = unowned.length > 0 ? unowned : TREASURES
  return pool[hashString(huntId) % pool.length]!.id
}

export function awardTreasure(
  collection: CollectedTreasure[],
  huntId: string,
  collectedAt: string,
): CollectedTreasure {
  const already = collection.find((item) => item.huntId === huntId)
  if (already) {
    return already
  }
  const treasureId = pickTreasureId(
    collection.map((item) => item.treasureId),
    huntId,
  )
  return {
    id: createId(),
    treasureId,
    huntId,
    collectedAt,
  }
}

export function uniqueCollected(collection: CollectedTreasure[]): Treasure[] {
  const seen = new Set<string>()
  const items: Treasure[] = []
  for (const entry of collection) {
    if (seen.has(entry.treasureId)) {
      continue
    }
    seen.add(entry.treasureId)
    items.push(getTreasure(entry.treasureId))
  }
  return items
}
