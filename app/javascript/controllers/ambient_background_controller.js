import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.currentX = 72
    this.currentY = 14
    this.targetX = this.currentX
    this.targetY = this.currentY
    this.animationFrame = null

    this.canTrackPointer = window.matchMedia("(pointer: fine)").matches &&
      !window.matchMedia("(prefers-reduced-motion: reduce)").matches

    if (!this.canTrackPointer) return

    this.handlePointerMove = this.handlePointerMove.bind(this)
    this.handlePointerLeave = this.handlePointerLeave.bind(this)
    this.handlePointerDown = this.handlePointerDown.bind(this)
    this.handlePointerUp = this.handlePointerUp.bind(this)
    this.tick = this.tick.bind(this)

    window.addEventListener("pointermove", this.handlePointerMove, { passive: true })
    document.addEventListener("mouseleave", this.handlePointerLeave)
    window.addEventListener("blur", this.handlePointerLeave)
    window.addEventListener("pointerdown", this.handlePointerDown, { passive: true })
    window.addEventListener("pointerup", this.handlePointerUp, { passive: true })
    window.addEventListener("pointercancel", this.handlePointerUp, { passive: true })
  }

  disconnect() {
    if (!this.canTrackPointer) return

    window.removeEventListener("pointermove", this.handlePointerMove)
    document.removeEventListener("mouseleave", this.handlePointerLeave)
    window.removeEventListener("blur", this.handlePointerLeave)
    window.removeEventListener("pointerdown", this.handlePointerDown)
    window.removeEventListener("pointerup", this.handlePointerUp)
    window.removeEventListener("pointercancel", this.handlePointerUp)

    if (this.animationFrame) cancelAnimationFrame(this.animationFrame)
  }

  handlePointerMove(event) {
    if (event.pointerType === "touch") return

    this.targetX = (event.clientX / window.innerWidth) * 100
    this.targetY = (event.clientY / window.innerHeight) * 100
    this.element.style.setProperty("--ambient-opacity", "0.92")
    this.startAnimation()
  }

  handlePointerLeave() {
    this.element.style.setProperty("--ambient-opacity", "0.42")
    this.element.style.setProperty("--ambient-scale", "1")
  }

  handlePointerDown(event) {
    if (event.pointerType === "touch") return
    this.element.style.setProperty("--ambient-scale", "1.08")
  }

  handlePointerUp() {
    this.element.style.setProperty("--ambient-scale", "1")
  }

  startAnimation() {
    if (this.animationFrame) return
    this.animationFrame = requestAnimationFrame(this.tick)
  }

  tick() {
    const easing = 0.13
    const deltaX = this.targetX - this.currentX
    const deltaY = this.targetY - this.currentY

    this.currentX += deltaX * easing
    this.currentY += deltaY * easing

    this.element.style.setProperty("--cursor-x", `${this.currentX.toFixed(2)}%`)
    this.element.style.setProperty("--cursor-y", `${this.currentY.toFixed(2)}%`)

    if (Math.abs(deltaX) > 0.03 || Math.abs(deltaY) > 0.03) {
      this.animationFrame = requestAnimationFrame(this.tick)
    } else {
      this.animationFrame = null
    }
  }
}
