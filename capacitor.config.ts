import type { CapacitorConfig } from '@capacitor/cli'

const config: CapacitorConfig = {
  appId: 'com.cluegame.takarasagashi',
  appName: 'たからさがし',
  webDir: 'dist',
  backgroundColor: '#12082a',
  ios: {
    contentInset: 'never',
    preferredContentMode: 'mobile',
    scheme: 'TakaraSagashi',
  },
  plugins: {
    SplashScreen: {
      backgroundColor: '#12082a',
      launchAutoHide: true,
      launchShowDuration: 400,
      showSpinner: false,
    },
    StatusBar: {
      style: 'DARK',
    },
  },
}

export default config
