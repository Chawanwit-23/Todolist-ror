import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.currentX = 50
    this.currentY = 50
    this.targetX = 50
    this.targetY = 50
    this.animationFrame = null
    this.canTrackPointer = window.matchMedia("(pointer: fine)").matches &&
      !window.matchMedia("(prefers-reduced-motion: reduce)").matches

    if (!this.canTrackPointer) return

    this.handlePointerMove = this.handlePointerMove.bind(this)
    this.handlePointerLeave = this.handlePointerLeave.bind(this)
    this.render = this.render.bind(this)

    this.element.addEventListener("pointermove", this.handlePointerMove, { passive: true })
    this.element.addEventListener("pointerleave", this.handlePointerLeave, { passive: true })
  }

  disconnect() {
    if (!this.canTrackPointer) return

    this.element.removeEventListener("pointermove", this.handlePointerMove)
    this.element.removeEventListener("pointerleave", this.handlePointerLeave)

    if (this.animationFrame) cancelAnimationFrame(this.animationFrame)
  }

  handlePointerMove(event) {
    if (event.pointerType === "touch") return

    const bounds = this.element.getBoundingClientRect()
    this.targetX = ((event.clientX - bounds.left) / bounds.width) * 100
    this.targetY = ((event.clientY - bounds.top) / bounds.height) * 100
    this.element.style.setProperty("--card-glow-opacity", "1")
    this.startAnimation()
  }

  handlePointerLeave() {
    this.element.style.setProperty("--card-glow-opacity", "0")
  }

  startAnimation() {
    if (this.animationFrame) return

    this.animationFrame = requestAnimationFrame(this.render)
  }

  render() {
    this.currentX += (this.targetX - this.currentX) * 0.2
    this.currentY += (this.targetY - this.currentY) * 0.2

    this.element.style.setProperty("--card-pointer-x", `${this.currentX}%`)
    this.element.style.setProperty("--card-pointer-y", `${this.currentY}%`)

    const isSettled = Math.abs(this.targetX - this.currentX) < 0.08 &&
      Math.abs(this.targetY - this.currentY) < 0.08

    if (isSettled) {
      this.currentX = this.targetX
      this.currentY = this.targetY
      this.animationFrame = null
      return
    }

    this.animationFrame = requestAnimationFrame(this.render)
  }
}
