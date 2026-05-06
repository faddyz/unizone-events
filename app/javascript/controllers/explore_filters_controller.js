import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "mobileToggle", "panel", "sentinel", "submit"]

  connect() {
    this.floatQuery = window.matchMedia("(min-width: 1024px)")
    this.mobileQuery = window.matchMedia("(max-width: 1023px)")
    this.handleFloatMediaChange = this.handleFloatMediaChange.bind(this)
    this.updateFloatingSpace = this.updateFloatingSpace.bind(this)

    this.floatQuery.addEventListener("change", this.handleFloatMediaChange)
    this.mobileQuery.addEventListener("change", this.handleFloatMediaChange)
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
    this.mobileQuery?.removeEventListener("change", this.handleFloatMediaChange)
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
    const desktopEnabled = shouldFloat && this.floatQuery.matches
    const mobileEnabled = shouldFloat && this.mobileQuery.matches
    this.panelTarget.classList.toggle("is-floating", desktopEnabled)
    this.panelTarget.classList.toggle("is-mobile-sticky", mobileEnabled)
    this.element.classList.toggle("is-mobile-sticky", mobileEnabled)

    if (!mobileEnabled) {
      this.panelTarget.classList.remove("is-mobile-expanded")
    }

    this.syncMobileToggle()

    if (desktopEnabled || mobileEnabled) {
      this.updateFloatingSpace()
    } else {
      this.clearFloatingSpace()
    }
  }

  updateFloatingSpace() {
    if (
      !this.hasPanelTarget ||
      (!this.panelTarget.classList.contains("is-floating") &&
        !this.panelTarget.classList.contains("is-mobile-sticky"))
    ) {
      return
    }

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

    if (!this.mobileQuery.matches && this.hasPanelTarget) {
      this.panelTarget.classList.remove("is-mobile-sticky", "is-mobile-expanded")
      this.element.classList.remove("is-mobile-sticky")
    }

    this.syncMobileToggle()
  }

  toggleMobile(event) {
    if (this.mobileToggleDragged) {
      event.preventDefault()
      this.mobileToggleDragged = false
      return
    }

    if (!this.panelTarget.classList.contains("is-mobile-sticky")) return
    this.panelTarget.classList.toggle("is-mobile-expanded")
    this.syncMobileToggle()
    this.updateFloatingSpace()
  }

  startMobileToggleDrag(event) {
    this.mobileToggleStartY = event.clientY
    this.mobileToggleDragged = false
  }

  finishMobileToggleDrag(event) {
    if (this.mobileToggleStartY == null || !this.panelTarget.classList.contains("is-mobile-sticky")) return

    const deltaY = event.clientY - this.mobileToggleStartY
    this.mobileToggleStartY = null

    if (Math.abs(deltaY) < 24) return

    this.mobileToggleDragged = true
    this.panelTarget.classList.toggle("is-mobile-expanded", deltaY > 0)
    this.syncMobileToggle()
    this.updateFloatingSpace()
  }

  cancelMobileToggleDrag() {
    this.mobileToggleStartY = null
  }

  syncMobileToggle() {
    if (!this.hasMobileToggleTarget || !this.hasPanelTarget) return

    const expanded = this.panelTarget.classList.contains("is-mobile-expanded")
    this.mobileToggleTarget.setAttribute("aria-expanded", expanded ? "true" : "false")
  }
}
