import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport"]

  connect() {
    this.update = this.update.bind(this)
    this.update()
    this.viewportTarget?.addEventListener("scroll", this.update, { passive: true })
    window.addEventListener("resize", this.update)
  }

  disconnect() {
    this.viewportTarget?.removeEventListener("scroll", this.update)
    window.removeEventListener("resize", this.update)
    window.clearTimeout(this.glidingTimeout)
  }

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
    window.clearTimeout(this.glidingTimeout)
    this.glidingTimeout = window.setTimeout(() => {
      this.element.classList.remove("is-gliding")
      this.update()
    }, 420)
  }

  update() {
    if (!this.hasViewportTarget) return

    const viewport = this.viewportTarget
    const maxScroll = Math.max(viewport.scrollWidth - viewport.clientWidth, 0)
    const tolerance = 4
    const canScroll = maxScroll > tolerance
    const atStart = !canScroll || viewport.scrollLeft <= tolerance
    const atEnd = !canScroll || viewport.scrollLeft >= maxScroll - tolerance

    this.element.classList.toggle("is-at-start", atStart)
    this.element.classList.toggle("is-at-end", atEnd)
    this.element.classList.toggle("is-scrollable", canScroll)
  }
}
