<template>
  <div ref="container" class="three-avatar" aria-label="3D avatar model">
    <div v-if="loadError" class="model-fallback">
      <span>GLB</span>
      <small>{{ modelUrl }}</small>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, ref } from 'vue'
import * as THREE from 'three'
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js'

const container = ref(null)
const loadError = ref(false)
const modelUrl = import.meta.env.VITE_AVATAR_GLB || `${import.meta.env.BASE_URL}models/base_basic_shaded.glb`

let animationId
let mixer
let model
let observer
let renderer
let scene
let camera
let targetRotationX = 0
let targetRotationY = -0.24

function fitRenderer() {
  if (!container.value || !renderer || !camera) return

  const { width, height } = container.value.getBoundingClientRect()
  renderer.setSize(width, height, false)
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
  camera.aspect = width / height
  camera.updateProjectionMatrix()
}

function frameModel(target) {
  const box = new THREE.Box3().setFromObject(target)
  const center = box.getCenter(new THREE.Vector3())
  const size = box.getSize(new THREE.Vector3())
  const maxAxis = Math.max(size.x, size.y, size.z) || 1

  target.position.sub(center)
  target.position.y -= size.y * 0.01
  target.scale.setScalar(2.36 / maxAxis)
}

onMounted(() => {
  scene = new THREE.Scene()
  camera = new THREE.PerspectiveCamera(35, 1, 0.1, 100)
  camera.position.set(0, 1.0, 7.55)

  renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true })
  renderer.outputColorSpace = THREE.SRGBColorSpace
  renderer.toneMapping = THREE.ACESFilmicToneMapping
  renderer.toneMappingExposure = 1.08
  container.value.appendChild(renderer.domElement)

  const keyLight = new THREE.DirectionalLight(0xffffff, 3.4)
  keyLight.position.set(3.2, 4.4, 5)
  scene.add(keyLight)

  const fillLight = new THREE.DirectionalLight(0x8b5cf6, 1.3)
  fillLight.position.set(-4, 1.6, 3)
  scene.add(fillLight)

  scene.add(new THREE.HemisphereLight(0xdff9ff, 0x22112f, 2.1))

  new GLTFLoader().load(
    modelUrl,
    (gltf) => {
      model = gltf.scene
      frameModel(model)
      model.rotation.y = targetRotationY
      scene.add(model)

      if (gltf.animations.length) {
        mixer = new THREE.AnimationMixer(model)
        mixer.clipAction(gltf.animations[0]).play()
      }
    },
    undefined,
    () => {
      loadError.value = true
    },
  )

  const clock = new THREE.Clock()
  const animate = () => {
    animationId = window.requestAnimationFrame(animate)
    const delta = clock.getDelta()
    mixer?.update(delta)

    if (model) {
      const idle = Math.sin(clock.elapsedTime * 0.8) * 0.035
      model.rotation.y = THREE.MathUtils.lerp(model.rotation.y, targetRotationY + idle, 0.08)
      model.rotation.x = THREE.MathUtils.lerp(model.rotation.x, targetRotationX, 0.08)
    }

    renderer.render(scene, camera)
  }

  fitRenderer()
  observer = new ResizeObserver(fitRenderer)
  observer.observe(container.value)
  window.addEventListener('pointermove', handlePointerMove)
  animate()
})

onUnmounted(() => {
  window.cancelAnimationFrame(animationId)
  observer?.disconnect()
  window.removeEventListener('pointermove', handlePointerMove)
  renderer?.dispose()
  container.value?.replaceChildren()
})

function handlePointerMove(event) {
  const x = event.clientX / window.innerWidth - 0.5
  const y = event.clientY / window.innerHeight - 0.5

  targetRotationY = THREE.MathUtils.clamp(-0.24 + x * 1.55, -1.08, 0.62)
  targetRotationX = THREE.MathUtils.clamp(y * 0.1, -0.04, 0.04)
}
</script>
