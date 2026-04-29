import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "panel", "sentinel", "submit"]

  connect() {
    this.floatQuery = window.matchMedia("(min-width: 1024px)")
    this.handleFloatMediaChange = this.handleFloatMediaChange.bind(this)
    this.updateFloatingSpace = this.updateFloatingSpace.bind(this)

    this.floatQuery.addEventListener("change", this.handleFloatMediaChange)
    window.addEventListener("resize", this.updateFloatingSpace)

    if (!this.hasPanelTarget || !this.hasSentinelTarget) return

    this.observer = new IntersectionObserver(
      ([entry]) => {
        this.setFloating(!entry.isIntersecting)
      },
      { rootMargin: "-84px 0px 0px 0px", threshold: 0 },
    )
    this.observer.observe(this.sentinelTarget)
  }

  disconnect() {
    this.observer?.disconnect()
    this.floatQuery?.removeEventListener("change", this.handleFloatMediaChange)
    window.removeEventListener("resize", this.updateFloatingSpace)
    window.clearTimeout(this.submitTimeout)
    this.clearFloatingSpace()
  }

  submit(event) {
    if (!this.hasFormTarget) return
    if (event?.target?.matches("input[type='text'], input[type='search']")) {
      this.queueSubmit()
      return
    }

    this.requestSubmit()
  }

  queueSubmit() {
    window.clearTimeout(this.submitTimeout)
    this.submitTimeout = window.setTimeout(() => this.requestSubmit(), 520)
  }

  requestSubmit() {
    if (!this.hasFormTarget) return

    this.hasSubmitTarget && this.submitTarget.classList.add("is-loading")

    if (this.formTarget.requestSubmit) {
      this.formTarget.requestSubmit()
    } else {
      this.formTarget.submit()
    }
  }

  setFloating(shouldFloat) {
    const enabled = shouldFloat && this.floatQuery.matches
    this.panelTarget.classList.toggle("is-floating", enabled)

    if (enabled) {
      this.updateFloatingSpace()
    } else {
      this.clearFloatingSpace()
    }
  }

  updateFloatingSpace() {
    if (!this.hasPanelTarget || !this.panelTarget.classList.contains("is-floating")) return

    this.element.style.minHeight = `${this.panelTarget.offsetHeight}px`
  }

  clearFloatingSpace() {
    this.element.style.minHeight = ""
  }

  handleFloatMediaChange() {
    if (!this.floatQuery.matches) {
      if (this.hasPanelTarget) {
        this.panelTarget.classList.remove("is-floating")
      }
      this.clearFloatingSpace()
    }
  }
}
