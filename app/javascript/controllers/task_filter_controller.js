import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "item", "empty", "clear", "result"]

  connect() {
    this.filter()
  }

  itemTargetConnected() {
    if (this.hasInputTarget) requestAnimationFrame(() => this.filter())
  }

  filter() {
    const query = this.normalizedQuery
    let visibleCount = 0

    this.itemTargets.forEach((item) => {
      const title = (item.dataset.searchText || "").toLocaleLowerCase("th")
      const matches = query.length === 0 || title.includes(query)

      this.setItemVisibility(item, matches)
      if (matches) visibleCount += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visibleCount > 0 || query.length === 0
    if (this.hasClearTarget) this.clearTarget.hidden = query.length === 0
    if (this.hasResultTarget) {
      this.resultTarget.textContent = query.length > 0 ? `พบ ${visibleCount} งาน` : ""
    }
  }

  clear() {
    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.filter()
  }

  clearOnEscape(event) {
    if (event.key === "Escape" && this.inputTarget.value.length > 0) this.clear()
  }

  get normalizedQuery() {
    return this.inputTarget.value.trim().toLocaleLowerCase("th")
  }

  setItemVisibility(item, visible) {
    if (visible && item.hidden) {
      item.hidden = false
      item.animate(
        [
          { opacity: 0, transform: "translateY(6px)" },
          { opacity: 1, transform: "translateY(0)" }
        ],
        { duration: 180, easing: "cubic-bezier(.2,.8,.2,1)" }
      )
    } else if (!visible) {
      item.hidden = true
    }
  }
}
