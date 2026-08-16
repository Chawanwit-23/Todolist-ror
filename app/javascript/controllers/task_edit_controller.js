import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["summary", "panel", "title"]

  open() {
    this.summaryTargets.forEach((target) => { target.hidden = true })
    this.panelTarget.hidden = false
    this.panelTarget.animate(
      [
        { opacity: 0, transform: "translateY(-5px) scale(.99)" },
        { opacity: 1, transform: "translateY(0) scale(1)" }
      ],
      { duration: 200, easing: "cubic-bezier(.2,.8,.2,1)" }
    )
    this.titleTarget.focus()
    this.titleTarget.select()
  }

  close() {
    this.panelTarget.hidden = true
    this.summaryTargets.forEach((target) => { target.hidden = false })
  }

  closeOnEscape(event) {
    if (event.key === "Escape") this.close()
  }
}
