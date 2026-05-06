import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "destination", "continueButton"]

  connect() {
    this.closeOnCancel = this.closeOnCancel.bind(this)
    if (this.hasDialogTarget) this.dialogTarget.addEventListener("cancel", this.closeOnCancel)
  }

  disconnect() {
    if (this.hasDialogTarget) this.dialogTarget.removeEventListener("cancel", this.closeOnCancel)
    document.documentElement.classList.remove("external-redirect-open")
  }

  open(event) {
    event.preventDefault()
    if (!this.hasDialogTarget) return

    this.url = event.params.url || event.currentTarget.href
    this.opener = event.currentTarget
    this.updateDestination()

    document.documentElement.classList.add("external-redirect-open")

    if (this.dialogTarget.showModal) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.setAttribute("open", "")
    }

    requestAnimationFrame(() => {
      if (this.hasContinueButtonTarget) this.continueButtonTarget.focus({ preventScroll: true })
    })
  }

  continue(event) {
    event.preventDefault()
    if (!this.url) return

    const opened = window.open(this.url, "_blank", "noopener")
    if (opened) opened.opener = null
    this.close()
  }

  close(event) {
    event?.preventDefault()
    if (!this.hasDialogTarget || !this.dialogTarget.open) return

    if (this.dialogTarget.close) {
      this.dialogTarget.close()
    } else {
      this.dialogTarget.removeAttribute("open")
    }

    document.documentElement.classList.remove("external-redirect-open")
    this.opener?.focus({ preventScroll: true })
  }

  closeFromBackdrop(event) {
    if (event.target !== this.dialogTarget) return
    this.close(event)
  }

  closeOnCancel(event) {
    event.preventDefault()
    this.close()
  }

  updateDestination() {
    if (!this.hasDestinationTarget || !this.url) return

    try {
      this.destinationTarget.textContent = new URL(this.url).hostname.replace(/^www\./, "")
    } catch {
      this.destinationTarget.textContent = "dış site"
    }
  }
}
