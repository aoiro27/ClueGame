import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import { applyScan, createHunt, markReady, setStageHint, startHunt } from '../lib/hunt'
import { awardTreasure } from '../lib/treasures'
import type { CollectedTreasure, Hunt, ScanResult, Screen } from '../types/game'

const INITIAL_SCREEN: Screen = 'home'

interface GameState {
  screen: Screen
  hunt: Hunt | null
  setupIndex: number
  collection: CollectedTreasure[]
  lastAwardedId: string | null
  scanResult: ScanResult | null
  practiceMode: boolean
  goTo: (screen: Screen) => void
  beginSetup: () => void
  chooseStageCount: (count: number) => void
  updateCurrentHint: (hint: string) => void
  nextSetupStage: () => void
  prevSetupStage: () => void
  finishSetup: () => void
  startAdventure: () => void
  openScan: () => void
  closeScan: () => void
  scanPayload: (payload: string) => ScanResult | null
  clearScanResult: () => void
  openCollection: () => void
  finishClear: () => void
  abandonHunt: () => void
  setPracticeMode: (value: boolean) => void
  reviewQr: () => void
}

export const useGameStore = create<GameState>()(
  persist(
    (set, get) => ({
      screen: INITIAL_SCREEN,
      hunt: null,
      setupIndex: 1,
      collection: [],
      lastAwardedId: null,
      scanResult: null,
      practiceMode: false,
      goTo: (screen) => set({ screen, scanResult: null }),
      beginSetup: () =>
        set({
          screen: 'setup-count',
          hunt: null,
          setupIndex: 1,
          scanResult: null,
        }),
      chooseStageCount: (count) =>
        set({
          hunt: createHunt(count),
          setupIndex: 1,
          screen: 'setup-stage',
        }),
      updateCurrentHint: (hint) => {
        const { hunt, setupIndex } = get()
        if (!hunt) {
          return
        }
        set({ hunt: setStageHint(hunt, setupIndex, hint) })
      },
      nextSetupStage: () => {
        const { hunt, setupIndex } = get()
        if (!hunt) {
          return
        }
        if (setupIndex >= hunt.stageCount) {
          get().finishSetup()
          return
        }
        set({ setupIndex: setupIndex + 1 })
      },
      prevSetupStage: () => {
        const { setupIndex } = get()
        if (setupIndex <= 1) {
          set({ screen: 'setup-count' })
          return
        }
        set({ setupIndex: setupIndex - 1 })
      },
      finishSetup: () => {
        const { hunt } = get()
        if (!hunt) {
          return
        }
        try {
          set({ hunt: markReady(hunt), screen: 'setup-ready' })
        } catch {
          set({ screen: 'setup-stage' })
        }
      },
      startAdventure: () => {
        const { hunt } = get()
        if (!hunt) {
          return
        }
        if (hunt.status === 'playing') {
          set({ screen: 'play', scanResult: null })
          return
        }
        set({
          hunt: startHunt(hunt),
          screen: 'play',
          scanResult: null,
        })
      },
      openScan: () => set({ screen: 'scan', scanResult: null }),
      closeScan: () => set({ screen: 'play', scanResult: null }),
      scanPayload: (payload) => {
        const { hunt, collection } = get()
        if (!hunt) {
          return null
        }
        const { hunt: nextHunt, result } = applyScan(hunt, payload)
        if (result.kind === 'cleared') {
          const awarded = awardTreasure(collection, nextHunt.id, new Date().toISOString())
          const alreadyInList = collection.some((item) => item.id === awarded.id)
          set({
            hunt: nextHunt,
            scanResult: result,
            screen: 'clear',
            lastAwardedId: awarded.id,
            collection: alreadyInList ? collection : [...collection, awarded],
          })
          return result
        }
        if (result.kind === 'advanced') {
          set({
            hunt: nextHunt,
            scanResult: result,
            screen: 'play',
          })
          return result
        }
        set({ scanResult: result })
        return result
      },
      clearScanResult: () => set({ scanResult: null }),
      openCollection: () => set({ screen: 'collection', scanResult: null }),
      finishClear: () => set({ screen: 'collection' }),
      abandonHunt: () =>
        set({
          hunt: null,
          screen: 'parent',
          setupIndex: 1,
          scanResult: null,
          lastAwardedId: null,
        }),
      setPracticeMode: (value) => set({ practiceMode: value }),
      reviewQr: () => {
        const { hunt } = get()
        if (!hunt) {
          return
        }
        set({ screen: 'setup-ready', setupIndex: 1 })
      },
    }),
    {
      name: 'cluegame-v1',
      partialize: (state) => ({
        hunt: state.hunt,
        collection: state.collection,
        screen: state.screen === 'scan' ? 'play' : state.screen,
        setupIndex: state.setupIndex,
        lastAwardedId: state.lastAwardedId,
        practiceMode: state.practiceMode,
      }),
    },
  ),
)
