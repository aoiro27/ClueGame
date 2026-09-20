import { createId, createToken } from './ids'
import type { Hunt, ParsedQr, ScanResult } from '../types/game'
import { MAX_HINT_LENGTH, MAX_STAGES, MIN_STAGES } from '../types/game'

export { MAX_HINT_LENGTH, MAX_STAGES, MIN_STAGES }

export const QR_PREFIX = 'cluehunt:v1'

export function createHunt(
  stageCount: number,
  makeToken: () => string = createToken,
): Hunt {
  if (!Number.isInteger(stageCount) || stageCount < MIN_STAGES || stageCount > MAX_STAGES) {
    throw new Error(`QRは${MIN_STAGES}〜${MAX_STAGES}枚にしてね`)
  }

  const stages = Array.from({ length: stageCount }, (_, offset) => {
    const index = offset + 1
    return {
      index,
      hint: '',
      token: `${makeToken()}${index}`,
    }
  })

  return {
    id: createId(),
    createdAt: new Date().toISOString(),
    stageCount,
    stages,
    currentStageIndex: 1,
    status: 'draft',
  }
}

export function setStageHint(hunt: Hunt, stageIndex: number, hint: string): Hunt {
  const stage = hunt.stages.find((item) => item.index === stageIndex)
  if (!stage) {
    throw new Error('そのステージはないよ')
  }

  const trimmed = hint.trim().slice(0, MAX_HINT_LENGTH)
  return {
    ...hunt,
    stages: hunt.stages.map((item) =>
      item.index === stageIndex ? { ...item, hint: trimmed } : item,
    ),
  }
}

export function missingHintIndexes(hunt: Hunt): number[] {
  return hunt.stages.filter((stage) => stage.hint.length === 0).map((stage) => stage.index)
}

export function markReady(hunt: Hunt): Hunt {
  if (missingHintIndexes(hunt).length > 0) {
    throw new Error('ヒントがまだ足りないよ')
  }
  return { ...hunt, status: 'ready' }
}

export function startHunt(hunt: Hunt): Hunt {
  const withHints = hunt.status === 'draft' ? markReady(hunt) : hunt
  if (missingHintIndexes(withHints).length > 0) {
    throw new Error('ヒントがまだ足りないよ')
  }
  return {
    ...withHints,
    status: 'playing',
    currentStageIndex: 1,
  }
}

export function encodeQrPayload(hunt: Hunt, stageIndex: number): string {
  const stage = hunt.stages.find((item) => item.index === stageIndex)
  if (!stage) {
    throw new Error('そのステージはないよ')
  }
  return `${QR_PREFIX}:${hunt.id}:${stageIndex}:${stage.token}`
}

export function parseQrPayload(raw: string): ParsedQr | null {
  const text = raw.trim()
  const parts = text.split(':')
  if (parts.length !== 5) {
    return null
  }
  const [scheme, version, huntId, stageRaw, token] = parts
  if (scheme !== 'cluehunt' || version !== 'v1' || !huntId || !token) {
    return null
  }
  const stageIndex = Number(stageRaw)
  if (!Number.isInteger(stageIndex) || stageIndex < MIN_STAGES || stageIndex > MAX_STAGES) {
    return null
  }
  return { huntId, stageIndex, token }
}

export function currentHint(hunt: Hunt): string {
  return hunt.stages.find((stage) => stage.index === hunt.currentStageIndex)?.hint ?? ''
}

export function applyScan(hunt: Hunt, payload: string): { hunt: Hunt; result: ScanResult } {
  if (hunt.status === 'cleared') {
    return { hunt, result: { kind: 'already_cleared' } }
  }
  if (hunt.status !== 'playing') {
    return { hunt, result: { kind: 'not_playing' } }
  }

  const parsed = parseQrPayload(payload)
  if (!parsed || parsed.huntId !== hunt.id) {
    return { hunt, result: { kind: 'unknown' } }
  }

  const stage = hunt.stages.find((item) => item.index === parsed.stageIndex)
  if (!stage || stage.token !== parsed.token) {
    return { hunt, result: { kind: 'unknown' } }
  }

  if (parsed.stageIndex > hunt.currentStageIndex) {
    return {
      hunt,
      result: {
        kind: 'wrong_order',
        expected: hunt.currentStageIndex,
        scanned: parsed.stageIndex,
      },
    }
  }

  if (parsed.stageIndex < hunt.currentStageIndex) {
    return {
      hunt,
      result: { kind: 'already_found', scanned: parsed.stageIndex },
    }
  }

  const isLast = parsed.stageIndex === hunt.stageCount
  if (isLast) {
    return {
      hunt: { ...hunt, status: 'cleared' },
      result: { kind: 'cleared' },
    }
  }

  const nextStage = parsed.stageIndex + 1
  const nextHint = hunt.stages.find((item) => item.index === nextStage)?.hint ?? ''
  return {
    hunt: { ...hunt, currentStageIndex: nextStage },
    result: { kind: 'advanced', nextStage, nextHint },
  }
}
