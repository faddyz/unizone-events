import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "sentinel"]

  connect() {
    if (!this.hasPanelTarget || !this.hasSentinelTarget) return

    this.observer = new IntersectionObserver(
      ([entry]) => {
        this.panelTarget.classList.toggle("is-floating", !entry.isIntersecting)
      },
      { rootMargin: "-84px 0px 0px 0px", threshold: 0 },
    )
    this.observer.observe(this.sentinelTarget)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
