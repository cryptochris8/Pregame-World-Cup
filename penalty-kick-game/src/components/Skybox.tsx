import { useThree } from '@react-three/fiber'
import { useTexture, Environment } from '@react-three/drei'
import { useEffect, Component, type ReactNode } from 'react'
import { EquirectangularReflectionMapping } from 'three'

const SKYBOX_IMAGE = '/skyboxes/soccer.jpg'

function SkyboxLoader() {
  const { scene: threeScene } = useThree()
  const texture = useTexture(SKYBOX_IMAGE)

  useEffect(() => {
    texture.mapping = EquirectangularReflectionMapping
    threeScene.background = texture
    threeScene.environment = texture
    threeScene.backgroundBlurriness = 0
    threeScene.backgroundIntensity = 1

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
