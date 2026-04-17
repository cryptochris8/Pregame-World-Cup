import { useThree } from '@react-three/fiber'
import { useTexture, Environment } from '@react-three/drei'
import { useEffect, Component, type ReactNode } from 'react'
import { EquirectangularReflectionMapping, Euler } from 'three'

// Rotate the skybox so the pitch/field is the backdrop behind the goal,
// not the stands. Adjust this Y-rotation value to fine-tune the view.
// 0 = default, Math.PI = 180°, Math.PI/2 = 90° etc.
const SKYBOX_Y_ROTATION = Math.PI * 0.5  // 90° rotation

const SKYBOX_IMAGE = `${import.meta.env.BASE_URL}skyboxes/soccer.jpg`

function SkyboxLoader() {
  const { scene: threeScene } = useThree()
  const texture = useTexture(SKYBOX_IMAGE)

  useEffect(() => {
    texture.mapping = EquirectangularReflectionMapping
    threeScene.background = texture
    threeScene.environment = texture
    threeScene.backgroundBlurriness = 0
    threeScene.backgroundIntensity = 1
    threeScene.backgroundRotation = new Euler(0, SKYBOX_Y_ROTATION, 0)
    threeScene.environmentRotation = new Euler(0, SKYBOX_Y_ROTATION, 0)

    return () => {
      threeScene.background = null
      threeScene.environment = null
      texture.dispose()
    }
  }, [texture, threeScene])

  return null
}

interface FallbackProps {
  children: ReactNode
}

interface FallbackState {
  hasError: boolean
}

class SkyboxErrorBoundary extends Component<FallbackProps, FallbackState> {
  state: FallbackState = { hasError: false }

  static getDerivedStateFromError(): FallbackState {
    return { hasError: true }
  }

  render() {
    if (this.state.hasError) {
      return <Environment preset="park" />
    }
    return this.props.children
  }
}

export function Skybox() {
  return (
    <SkyboxErrorBoundary>
      <SkyboxLoader />
    </SkyboxErrorBoundary>
  )
}
