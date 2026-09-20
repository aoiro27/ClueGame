import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import '@fontsource/m-plus-rounded-1c/japanese-400.css'
import '@fontsource/m-plus-rounded-1c/japanese-700.css'
import '@fontsource/m-plus-rounded-1c/japanese-800.css'
import '@fontsource/yusei-magic/japanese-400.css'
import './index.css'
import App from './App.tsx'
import { initNativeApp } from './lib/native.ts'

await initNativeApp()

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
