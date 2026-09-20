import { Capacitor } from '@capacitor/core'
import { SplashScreen } from '@capacitor/splash-screen'
import { StatusBar, Style } from '@capacitor/status-bar'

export function isNativeApp(): boolean {
  return Capacitor.isNativePlatform()
}

export async function initNativeApp(): Promise<void> {
  if (!isNativeApp()) {
    return
  }

  document.documentElement.classList.add('native-app')
  try {
    await StatusBar.setStyle({ style: Style.Dark })
    await StatusBar.setOverlaysWebView({ overlay: true })
  } catch {
    // StatusBar is unavailable in some simulators.
  }
  try {
    await SplashScreen.hide()
  } catch {
    // SplashScreen plugin may be absent during web preview.
  }
}
