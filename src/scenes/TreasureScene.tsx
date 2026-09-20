import { useEffect, useRef } from 'react'
import * as THREE from 'three'

interface TreasureSceneProps {
  hue: number
  open: boolean
}

export function TreasureScene({ hue, open }: TreasureSceneProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const openRef = useRef(open)
  openRef.current = open

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) {
      return
    }

    const renderer = new THREE.WebGLRenderer({
      canvas,
      antialias: true,
      alpha: true,
    })
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
    renderer.outputColorSpace = THREE.SRGBColorSpace
    renderer.toneMapping = THREE.ACESFilmicToneMapping
    renderer.toneMappingExposure = 1.15

    const scene = new THREE.Scene()
    scene.fog = new THREE.FogExp2(0x12082a, 0.045)

    const camera = new THREE.PerspectiveCamera(42, 1, 0.1, 40)
    camera.position.set(2.4, 2.1, 4.2)
    camera.lookAt(0, 0.6, 0)

    scene.add(new THREE.AmbientLight(0x6b5aa8, 0.55))
    const moon = new THREE.DirectionalLight(0xb9d4ff, 0.7)
    moon.position.set(-3, 5, 2)
    scene.add(moon)
    const lantern = new THREE.PointLight(0xffc56a, 0, 12)
    lantern.position.set(0, 1.4, 1.2)
    scene.add(lantern)

    const floor = new THREE.Mesh(
      new THREE.CircleGeometry(3.2, 48),
      new THREE.MeshStandardMaterial({
        color: 0x24143d,
        roughness: 0.95,
        metalness: 0,
      }),
    )
    floor.rotation.x = -Math.PI / 2
    scene.add(floor)

    const wood = new THREE.MeshStandardMaterial({
      color: 0x6b3a1f,
      roughness: 0.62,
      metalness: 0.08,
    })
    const gold = new THREE.MeshStandardMaterial({
      color: 0xe0b13a,
      roughness: 0.28,
      metalness: 0.82,
    })

    const chest = new THREE.Group()
    const body = new THREE.Mesh(new THREE.BoxGeometry(1.7, 0.9, 1.1), wood)
    body.position.y = 0.45
    const band = new THREE.Mesh(new THREE.BoxGeometry(1.78, 0.12, 1.18), gold)
    band.position.y = 0.45
    const lock = new THREE.Mesh(new THREE.BoxGeometry(0.22, 0.28, 0.12), gold)
    lock.position.set(0, 0.72, 0.56)
    chest.add(body, band, lock)

    const lidPivot = new THREE.Group()
    lidPivot.position.set(0, 0.9, -0.55)
    const lid = new THREE.Mesh(new THREE.BoxGeometry(1.74, 0.2, 1.14), wood)
    lid.position.set(0, 0.1, 0.55)
    const lidBand = new THREE.Mesh(new THREE.BoxGeometry(1.82, 0.08, 1.2), gold)
    lidBand.position.set(0, 0.1, 0.55)
    lidPivot.add(lid, lidBand)
    chest.add(lidPivot)
    scene.add(chest)

    const gemColor = new THREE.Color().setHSL(hue / 360, 0.7, 0.55)
    const gem = new THREE.Mesh(
      new THREE.OctahedronGeometry(0.38),
      new THREE.MeshStandardMaterial({
        color: gemColor,
        emissive: gemColor,
        emissiveIntensity: 0.35,
        metalness: 0.35,
        roughness: 0.18,
      }),
    )
    gem.position.set(0, 0.55, 0)
    gem.scale.setScalar(0.01)
    scene.add(gem)

    const sparkleCount = 90
    const sparkleGeo = new THREE.BufferGeometry()
    const sparklePositions = new Float32Array(sparkleCount * 3)
    for (let i = 0; i < sparkleCount; i += 1) {
      sparklePositions[i * 3] = (Math.random() - 0.5) * 3
      sparklePositions[i * 3 + 1] = Math.random() * 3
      sparklePositions[i * 3 + 2] = (Math.random() - 0.5) * 3
    }
    sparkleGeo.setAttribute('position', new THREE.BufferAttribute(sparklePositions, 3))
    const sparkles = new THREE.Points(
      sparkleGeo,
      new THREE.PointsMaterial({
        color: 0xffe7a3,
        size: 0.05,
        transparent: true,
        opacity: 0.0,
      }),
    )
    scene.add(sparkles)

    const setSize = () => {
      const width = canvas.clientWidth
      const height = canvas.clientHeight
      renderer.setSize(width, height, false)
      camera.aspect = width / Math.max(height, 1)
      camera.updateProjectionMatrix()
    }
    setSize()
    const observer = new ResizeObserver(setSize)
    observer.observe(canvas)

    let frame = 0
    const clock = new THREE.Clock()
    let lidAngle = 0
    let gemScale = 0.01

    const animate = () => {
      const delta = clock.getDelta()
      const targetLid = openRef.current ? -1.85 : 0
      lidAngle += (targetLid - lidAngle) * (1 - Math.exp(-delta * 3.2))
      lidPivot.rotation.x = lidAngle
      lantern.intensity = openRef.current ? 4.8 : 1.1
      const sparkleMat = sparkles.material
      if (sparkleMat instanceof THREE.PointsMaterial) {
        sparkleMat.opacity += ((openRef.current ? 0.9 : 0) - sparkleMat.opacity) * 0.05
      }
      const targetScale = openRef.current ? 1 : 0.01
      gemScale += (targetScale - gemScale) * (1 - Math.exp(-delta * 2.4))
      gem.scale.setScalar(gemScale)
      gem.position.y = 0.7 + (openRef.current ? 0.85 : 0) + Math.sin(clock.elapsedTime * 2) * 0.06
      gem.rotation.y += delta * 1.2
      chest.rotation.y = Math.sin(clock.elapsedTime * 0.35) * 0.12
      sparkles.rotation.y += delta * 0.15
      renderer.render(scene, camera)
      frame = requestAnimationFrame(animate)
    }
    frame = requestAnimationFrame(animate)

    return () => {
      cancelAnimationFrame(frame)
      observer.disconnect()
      sparkleGeo.dispose()
      wood.dispose()
      gold.dispose()
      floor.geometry.dispose()
      ;(floor.material as THREE.Material).dispose()
      body.geometry.dispose()
      band.geometry.dispose()
      lock.geometry.dispose()
      lid.geometry.dispose()
      lidBand.geometry.dispose()
      gem.geometry.dispose()
      ;(gem.material as THREE.Material).dispose()
      ;(sparkles.material as THREE.Material).dispose()
      renderer.dispose()
    }
  }, [hue])

  return <canvas ref={canvasRef} className="treasure-canvas" />
}
