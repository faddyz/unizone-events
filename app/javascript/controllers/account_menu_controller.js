import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileSheet", "mobilePanel", "mobileTrigger"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    this.dragMobile = this.dragMobile.bind(this)
    this.endMobileDrag = this.endMobileDrag.bind(this)
    this.cancelMobileDrag = this.cancelMobileDrag.bind(this)
    document.addEventListener("click", this.closeOnOutsideClick)
    document.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    document.removeEventListener("keydown", this.closeOnEscape)
    window.removeEventListener("pointermove", this.dragMobile)
    window.removeEventListener("pointerup", this.endMobileDrag)
    window.removeEventListener("pointercancel", this.cancelMobileDrag)
  }

  closeOnOutsideClick(event) {
    if (!this.isDetailsMenu) return
    if (!this.element.open) return
    if (this.element.contains(event.target)) return

    this.element.open = false
  }

  keydown(event) {
    if (event.key !== "Escape") return

    if (this.isDetailsMenu) this.element.open = false
    this.closeMobile()
    event.currentTarget.blur()
  }

  closeOnEscape(event) {
    if (event.key !== "Escape") return

    if (this.isDetailsMenu && this.element.open) {
      this.element.open = false
    }

    this.closeMobile()
  }

  openMobile(event) {
    event.preventDefault()
    if (!this.hasMobileSheetTarget) return

    this.resetMobileDrag()
    this.lastMobileTrigger = event.currentTarget
    this.mobileSheetTarget.hidden = false
    this.mobileSheetTarget.classList.add("is-open")
    document.documentElement.classList.add("mobile-account-open")
    this.setMobileTriggerState(true)
    this.mobilePanelTarget?.focus({ preventScroll: true })
  }

  closeMobile(event) {
    event?.preventDefault()
    if (!this.hasMobileSheetTarget || this.mobileSheetTarget.hidden) return

    this.resetMobileDrag()
    this.mobileSheetTarget.classList.remove("is-open")
    this.mobileSheetTarget.hidden = true
    document.documentElement.classList.remove("mobile-account-open")
    this.setMobileTriggerState(false)
    this.lastMobileTrigger?.focus({ preventScroll: true })
  }

  startMobileDrag(event) {
    if (!this.hasMobilePanelTarget || !this.hasMobileSheetTarget || this.mobileSheetTarget.hidden) return
    if (event.pointerType === "mouse" && event.button !== 0) return
    if (!event.target.closest(".mobile-account-handle, .mobile-account-head")) return
    if (event.target.closest("button, a, input, select, textarea")) return

    this.mobileDragStartY = event.clientY
    this.mobileDragCurrentY = event.clientY
    this.mobileDragPointerId = event.pointerId
    this.mobilePanelTarget.classList.add("is-dragging")
    this.mobilePanelTarget.setPointerCapture?.(event.pointerId)

    window.addEventListener("pointermove", this.dragMobile)
    window.addEventListener("pointerup", this.endMobileDrag)
    window.addEventListener("pointercancel", this.cancelMobileDrag)
  }

  dragMobile(event) {
    if (event.pointerId !== this.mobileDragPointerId || !this.hasMobilePanelTarget) return

    this.mobileDragCurrentY = event.clientY
    const offset = Math.max(0, event.clientY - this.mobileDragStartY)
    this.mobilePanelTarget.style.transform = `translateY(${offset}px)`

    if (offset > 6) event.preventDefault()
  }

  endMobileDrag(event) {
    if (event.pointerId !== this.mobileDragPointerId || !this.hasMobilePanelTarget) return

    const offset = Math.max(0, this.mobileDragCurrentY - this.mobileDragStartY)
    const shouldClose = offset > Math.min(150, this.mobilePanelTarget.offsetHeight * 0.28)

    this.removeMobileDragListeners()
    this.mobilePanelTarget.releasePointerCapture?.(event.pointerId)
    this.mobilePanelTarget.classList.remove("is-dragging")

    if (shouldClose) {
      this.closeMobile(event)
    } else {
      this.mobileDragStartY = null
      this.mobileDragCurrentY = null
      this.mobileDragPointerId = null
      this.mobilePanelTarget.style.transform = ""
    }
  }

  cancelMobileDrag(event) {
    if (event.pointerId !== this.mobileDragPointerId) return

    this.resetMobileDrag()
  }

  resetMobileDrag() {
    this.removeMobileDragListeners()
    this.mobileDragStartY = null
    this.mobileDragCurrentY = null
    this.mobileDragPointerId = null

    if (!this.hasMobilePanelTarget) return

    this.mobilePanelTarget.classList.remove("is-dragging")
    this.mobilePanelTarget.style.transform = ""
  }

  removeMobileDragListeners() {
    window.removeEventListener("pointermove", this.dragMobile)
    window.removeEventListener("pointerup", this.endMobileDrag)
    window.removeEventListener("pointercancel", this.cancelMobileDrag)
  }

  setMobileTriggerState(expanded) {
    this.mobileTriggerTargets.forEach((trigger) => {
      trigger.setAttribute("aria-expanded", expanded ? "true" : "false")
    })
  }

  get isDetailsMenu() {
    return this.element.tagName === "DETAILS"
  }
}
