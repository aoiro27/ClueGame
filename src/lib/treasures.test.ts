import { describe, expect, it } from 'vitest'
import { awardTreasure, TREASURES } from './treasures'

describe('awardTreasure', () => {
  it('まだ持っていない宝を優先して渡す', () => {
    const first = awardTreasure([], 'hunt-a', '2026-01-01T00:00:00.000Z')
    expect(TREASURES.some((item) => item.id === first.treasureId)).toBe(true)

    const owned = [first]
    const second = awardTreasure(owned, 'hunt-b', '2026-01-02T00:00:00.000Z')
    expect(second.treasureId).not.toBe(first.treasureId)
    expect(second.huntId).toBe('hunt-b')
  })

  it('全部集めたあとも宝は渡せる', () => {
    const owned = TREASURES.map((item, index) => ({
      id: `c-${index}`,
      treasureId: item.id,
      huntId: `h-${index}`,
      collectedAt: '2026-01-01T00:00:00.000Z',
    }))
    const extra = awardTreasure(owned, 'hunt-full', '2026-02-01T00:00:00.000Z')
    expect(TREASURES.some((item) => item.id === extra.treasureId)).toBe(true)
  })

  it('同じハントIDなら同じ宝になる', () => {
    const a = awardTreasure([], 'same-hunt', '2026-03-01T00:00:00.000Z')
    const b = awardTreasure([], 'same-hunt', '2026-03-02T00:00:00.000Z')
    expect(a.treasureId).toBe(b.treasureId)
  })
})
