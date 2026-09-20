import { describe, expect, it } from 'vitest'
import {
  applyScan,
  createHunt,
  encodeQrPayload,
  MAX_STAGES,
  parseQrPayload,
  setStageHint,
  startHunt,
} from './hunt'

function readyHunt(stageCount = 3) {
  let hunt = createHunt(stageCount, () => 'token-seed')
  for (let index = 1; index <= stageCount; index += 1) {
    hunt = setStageHint(hunt, index, `${index}ばんめはソファのした`)
  }
  return startHunt(hunt)
}

describe('createHunt', () => {
  it('1〜5枚のステージをユニークなトークン付きで作る', () => {
    const hunt = createHunt(3)
    expect(hunt.stageCount).toBe(3)
    expect(hunt.stages).toHaveLength(3)
    expect(hunt.status).toBe('draft')
    expect(hunt.currentStageIndex).toBe(1)
    const tokens = hunt.stages.map((stage) => stage.token)
    expect(new Set(tokens).size).toBe(3)
  })

  it('0枚と6枚は拒否する', () => {
    expect(() => createHunt(0)).toThrow(/1〜5/)
    expect(() => createHunt(MAX_STAGES + 1)).toThrow(/1〜5/)
    expect(() => createHunt(1.5)).toThrow(/1〜5/)
  })
})

describe('setStageHint', () => {
  it('ヒントをイミュータブルに更新する', () => {
    const hunt = createHunt(2)
    const next = setStageHint(hunt, 1, '  まどのそば  ')
    expect(next.stages[0]?.hint).toBe('まどのそば')
    expect(hunt.stages[0]?.hint).toBe('')
  })

  it('存在しないステージは拒否する', () => {
    const hunt = createHunt(1)
    expect(() => setStageHint(hunt, 2, 'だめ')).toThrow(/ステージ/)
  })
})

describe('QR payload', () => {
  it('エンコードとパースが往復する', () => {
    const hunt = createHunt(2)
    const payload = encodeQrPayload(hunt, 2)
    const parsed = parseQrPayload(payload)
    expect(parsed).toEqual({
      huntId: hunt.id,
      stageIndex: 2,
      token: hunt.stages[1]?.token,
    })
  })

  it('壊れた文字列は null を返す', () => {
    expect(parseQrPayload('https://example.com')).toBeNull()
    expect(parseQrPayload('cluehunt:v1:abc:x:tok')).toBeNull()
    expect(parseQrPayload('')).toBeNull()
  })
})

describe('startHunt', () => {
  it('未入力のヒントがあると始められない', () => {
    const hunt = setStageHint(createHunt(2), 1, 'つくえのした')
    expect(() => startHunt(hunt)).toThrow(/ヒント/)
  })

  it('全部そろったら playing で1ばんから始まる', () => {
    const hunt = readyHunt(2)
    expect(hunt.status).toBe('playing')
    expect(hunt.currentStageIndex).toBe(1)
  })
})

describe('applyScan', () => {
  it('今さがしているQRなら次のヒントへ進む', () => {
    const hunt = readyHunt(3)
    const { hunt: next, result } = applyScan(hunt, encodeQrPayload(hunt, 1))
    expect(result.kind).toBe('advanced')
    if (result.kind === 'advanced') {
      expect(result.nextStage).toBe(2)
      expect(result.nextHint).toContain('2ばんめ')
    }
    expect(next.currentStageIndex).toBe(2)
    expect(next.status).toBe('playing')
  })

  it('最後のQRならクリアになる', () => {
    let hunt = readyHunt(2)
    hunt = applyScan(hunt, encodeQrPayload(hunt, 1)).hunt
    const { hunt: cleared, result } = applyScan(hunt, encodeQrPayload(hunt, 2))
    expect(result.kind).toBe('cleared')
    expect(cleared.status).toBe('cleared')
  })

  it('先のQRは順番まちがいになる', () => {
    const hunt = readyHunt(3)
    const { result } = applyScan(hunt, encodeQrPayload(hunt, 3))
    expect(result).toEqual({
      kind: 'wrong_order',
      expected: 1,
      scanned: 3,
    })
  })

  it('すでに読んだQRは already_found になる', () => {
    let hunt = readyHunt(3)
    hunt = applyScan(hunt, encodeQrPayload(hunt, 1)).hunt
    const { result } = applyScan(hunt, encodeQrPayload(hunt, 1))
    expect(result).toEqual({ kind: 'already_found', scanned: 1 })
  })

  it('知らないQRは unknown になる', () => {
    const hunt = readyHunt(1)
    const { result } = applyScan(hunt, 'cluehunt:v1:other-hunt:1:zzzz')
    expect(result.kind).toBe('unknown')
  })

  it('クリア後のスキャンは already_cleared になる', () => {
    const hunt = readyHunt(1)
    const cleared = applyScan(hunt, encodeQrPayload(hunt, 1)).hunt
    const { result } = applyScan(cleared, encodeQrPayload(cleared, 1))
    expect(result.kind).toBe('already_cleared')
  })

  it('トークンが違うと同じ番号でも unknown になる', () => {
    const hunt = readyHunt(1)
    const { result } = applyScan(
      hunt,
      `cluehunt:v1:${hunt.id}:1:not-the-token`,
    )
    expect(result.kind).toBe('unknown')
  })
})
