import { Fireflies } from './components/Fireflies'
import { ErrorBoundary } from './components/ErrorBoundary'
import { ClearScreen } from './screens/ClearScreen'
import { CollectionScreen } from './screens/CollectionScreen'
import { HomeScreen } from './screens/HomeScreen'
import { ParentScreen } from './screens/ParentScreen'
import { PlayScreen } from './screens/PlayScreen'
import { ScanScreen } from './screens/ScanScreen'
import { SetupCountScreen } from './screens/SetupCountScreen'
import { SetupReadyScreen } from './screens/SetupReadyScreen'
import { SetupStageScreen } from './screens/SetupStageScreen'
import { useGameStore } from './store/gameStore'

export default function App() {
  const screen = useGameStore((state) => state.screen)

  return (
    <div className="app-shell">
      <div className="sky" aria-hidden="true" />
      <Fireflies />
      <ErrorBoundary>
        <main className="stage">
          {screen === 'home' && <HomeScreen />}
          {screen === 'parent' && <ParentScreen />}
          {screen === 'setup-count' && <SetupCountScreen />}
          {screen === 'setup-stage' && <SetupStageScreen />}
          {screen === 'setup-ready' && <SetupReadyScreen />}
          {screen === 'play' && <PlayScreen />}
          {screen === 'scan' && <ScanScreen />}
          {screen === 'clear' && <ClearScreen />}
          {screen === 'collection' && <CollectionScreen />}
        </main>
      </ErrorBoundary>
    </div>
  )
}
