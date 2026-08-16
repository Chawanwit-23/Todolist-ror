import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.updateToggle()
  }

  toggle() {
    const dark = !document.documentElement.classList.contains("dark")

    document.documentElement.classList.toggle("dark", dark)
    try {
      localStorage.setItem("todo-theme", dark ? "dark" : "light")
    } catch (_error) {
      // The theme still works for this page when storage is unavailable.
    }
    this.updateToggle()

    document.documentElement.animate(
      [{ opacity: 0.88 }, { opacity: 1 }],
      { duration: 220, easing: "ease-out" }
    )
  }

  updateToggle() {
    if (!this.hasToggleTarget) return

    const dark = document.documentElement.classList.contains("dark")
    const label = dark ? "เปลี่ยนเป็นโหมดสว่าง" : "เปลี่ยนเป็นโหมดมืด"

    this.toggleTarget.setAttribute("aria-label", label)
    this.toggleTarget.setAttribute("title", label)
    this.toggleTarget.setAttribute("aria-pressed", dark.toString())
  }
}
