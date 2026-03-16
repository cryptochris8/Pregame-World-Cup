import { useRef, useEffect, useMemo } from 'react'
import { useGLTF, useAnimations, useTexture } from '@react-three/drei'
import * as THREE from 'three'
import { SkeletonUtils } from 'three-stdlib'
import type { AnimationState } from '../types'

const MODEL_PATH = '/models/player.gltf'
const DEFAULT_SKIN = '/skins/avatars/1.png'

const ANIMATION_MAP: Record<AnimationState, {
  upper: string; lower: string; loop: boolean; fullBody: boolean
}> = {
  idle: { upper: 'idle-upper', lower: 'idle-lower', loop: true, fullBody: false },
  walk: { upper: 'walk-upper', lower: 'walk-lower', loop: true, fullBody: false },
  run: { upper: 'run-upper', lower: 'run-lower', loop: true, fullBody: false },
  charge: { upper: 'combat-idle', lower: 'combat-idle', loop: true, fullBody: true },
  throw: { upper: 'bow-draw-shoot', lower: 'bow-draw-shoot', loop: false, fullBody: true },
  kick: { upper: 'sword-attack-1', lower: 'sword-attack-1', loop: false, fullBody: true },
  swing: { upper: 'sword-attack-upper', lower: 'sword-attack-upper', loop: false, fullBody: true },
  celebrate: { upper: 'emote-griddy', lower: 'emote-griddy', loop: false, fullBody: true },
  disappointed: { upper: 'emote-annoyed', lower: 'emote-annoyed', loop: false, fullBody: true },
  jump: { upper: 'jump-pre', lower: 'jump-pre', loop: false, fullBody: true },
  sit: { upper: 'sit-chair', lower: 'sit-chair', loop: true, fullBody: true },
  interact: { upper: 'simple-interact', lower: 'simple-interact', loop: false, fullBody: true },
}

function getAnimationConfig(state: AnimationState) {
  return ANIMATION_MAP[state] ?? ANIMATION_MAP.idle
}

function configureAvatarTexture(texture: THREE.Texture): void {
  texture.flipY = false
  texture.colorSpace = THREE.SRGBColorSpace
  texture.magFilter = THREE.NearestFilter
  texture.minFilter = THREE.NearestFilter
  texture.generateMipmaps = false
  texture.needsUpdate = true
}

function applyTextureToModel(model: THREE.Object3D, texture: THREE.Texture): void {
  model.traverse((node) => {
    if ((node as THREE.Mesh).isMesh) {
      const mesh = node as THREE.Mesh
      const mat = mesh.material as THREE.MeshStandardMaterial
      if (mat.isMeshStandardMaterial) {
        mat.map = texture
        mat.needsUpdate = true
      }
    }
  })
}

interface HytopiaAvatarProps {
  skinUrl?: string
  animation?: AnimationState
  scale?: number
}

export function HytopiaAvatar({
  skinUrl = DEFAULT_SKIN,
  animation = 'idle',
  scale = 1,
}: HytopiaAvatarProps) {
  const groupRef = useRef<THREE.Group>(null)
  const { scene, animations } = useGLTF(MODEL_PATH)
  const prevAnimRef = useRef<AnimationState>(animation)

  // Clone scene per instance with unique materials so skins don't conflict
  const clone = useMemo(() => {
    const cloned = SkeletonUtils.clone(scene)
    cloned.traverse((node) => {
      if ((node as THREE.Mesh).isMesh) {
        const mesh = node as THREE.Mesh
        mesh.castShadow = true
        mesh.receiveShadow = true
        if (mesh.material) {
          mesh.material = (mesh.material as THREE.Material).clone()
        }
      }
    })
    return cloned
  }, [scene])

  // Load and apply skin texture
  const skinTexture = useTexture(skinUrl)

  useEffect(() => {
    configureAvatarTexture(skinTexture)
    applyTextureToModel(clone, skinTexture)
  }, [clone, skinTexture])

  // Set up animation mixer
  const { actions } = useAnimations(animations, groupRef)

  // Start idle animation on mount
  useEffect(() => {
    const config = getAnimationConfig('idle')
    const upper = actions[config.upper]
    const lower = actions[config.lower]
    upper?.reset().play()
    if (!config.fullBody) lower?.reset().play()
  }, [actions])

  // Transition between animations
  useEffect(() => {
    if (animation === prevAnimRef.current) return
    prevAnimRef.current = animation

    const fadeDuration = 0.2
    const config = getAnimationConfig(animation)

    // Fade out all currently playing actions
    Object.values(actions).forEach((action) => {
      if (action && action.isRunning()) {
        action.fadeOut(fadeDuration)
      }
    })

    // Fade in new animations
    const upper = actions[config.upper]
    const lower = actions[config.lower]

    if (upper) {
      upper.reset()
      if (!config.loop) {
        upper.setLoop(THREE.LoopOnce, 1)
        upper.clampWhenFinished = true
      } else {
        upper.setLoop(THREE.LoopRepeat, Infinity)
      }
      upper.fadeIn(fadeDuration).play()
    }

    if (!config.fullBody && lower && lower !== upper) {
      lower.reset()
      if (!config.loop) {
        lower.setLoop(THREE.LoopOnce, 1)
        lower.clampWhenFinished = true
      } else {
        lower.setLoop(THREE.LoopRepeat, Infinity)
      }
      lower.fadeIn(fadeDuration).play()
    }
  }, [animation, actions])

  return (
    <group ref={groupRef} scale={scale} dispose={null}>
      <primitive object={clone} />
    </group>
  )
}

useGLTF.preload(MODEL_PATH)
