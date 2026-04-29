import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport"]

  next() {
    this.scroll(1)
  }

  previous() {
    this.scroll(-1)
  }

  scroll(direction) {
    if (!this.hasViewportTarget) return

    const behavior = window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth"
    this.element.classList.add("is-gliding")
    this.viewportTarget.scrollBy({
      left: direction * Math.max(this.viewportTarget.clientWidth * 0.82, 280),
      behavior,
    })
    window.setTimeout(() => this.element.classList.remove("is-gliding"), 420)
  }
}
