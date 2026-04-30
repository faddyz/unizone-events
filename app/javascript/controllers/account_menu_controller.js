import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileSheet", "mobilePanel", "mobileTrigger"]

  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    this.closeOnEscape = this.closeOnEscape.bind(this)
    document.addEventListener("click", this.closeOnOutsideClick)
    document.addEventListener("keydown", this.closeOnEscape)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
    document.removeEventListener("keydown", this.closeOnEscape)
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

    this.mobileSheetTarget.classList.remove("is-open")
    this.mobileSheetTarget.hidden = true
    document.documentElement.classList.remove("mobile-account-open")
    this.setMobileTriggerState(false)
    this.lastMobileTrigger?.focus({ preventScroll: true })
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
