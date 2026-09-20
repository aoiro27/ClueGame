import { beforeEach, describe, expect, it } from 'vitest'
import { encodeQrPayload } from './hunt'
import { useGameStore } from '../store/gameStore'

describe('gameStore adventure flow', () => {
  beforeEach(() => {
    localStorage.clear()
    useGameStore.setState({
      screen: 'home',
      hunt: null,
      setupIndex: 1,
      collection: [],
      lastAwardedId: null,
      scanResult: null,
      practiceMode: true,
    })
  })

  it('ヒントをそろえてスキャンすると宝がふえる', () => {
    const store = useGameStore.getState()
    store.chooseStageCount(2)
    store.updateCurrentHint('まどのそば')
    store.nextSetupStage()
    store.updateCurrentHint('ソファのした')
    store.nextSetupStage()
    expect(useGameStore.getState().screen).toBe('setup-ready')

    store.startAdventure()
    const hunt = useGameStore.getState().hunt
    expect(hunt?.status).toBe('playing')
    expect(useGameStore.getState().screen).toBe('play')

    store.scanPayload(encodeQrPayload(hunt!, 2))
    expect(useGameStore.getState().scanResult?.kind).toBe('wrong_order')

    store.scanPayload(encodeQrPayload(hunt!, 1))
    expect(useGameStore.getState().hunt?.currentStageIndex).toBe(2)

    store.scanPayload(encodeQrPayload(hunt!, 2))
    const cleared = useGameStore.getState()
    expect(cleared.screen).toBe('clear')
    expect(cleared.collection).toHaveLength(1)
    expect(cleared.hunt?.status).toBe('cleared')
  })
})
