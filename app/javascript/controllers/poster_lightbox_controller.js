import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "image"]

  connect() {
    this.restoreAfterClose = this.restoreAfterClose.bind(this)
    if (this.hasDialogTarget) this.dialogTarget.addEventListener("close", this.restoreAfterClose)
  }

  disconnect() {
    if (this.hasDialogTarget) this.dialogTarget.removeEventListener("close", this.restoreAfterClose)
    document.documentElement.classList.remove("poster-lightbox-open")
  }

  open(event) {
    event?.preventDefault()
    if (!this.hasDialogTarget) return

    this.opener = event?.currentTarget
    document.documentElement.classList.add("poster-lightbox-open")
    this.loadImage()

    if (this.dialogTarget.open) return

    if (this.dialogTarget.showModal) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.setAttribute("open", "")
    }

    requestAnimationFrame(() => {
      this.dialogTarget.querySelector("button")?.focus({ preventScroll: true })
    })
  }

  close(event) {
    event?.preventDefault()
    this.closeDialog()
  }

  closeFromBackdrop(event) {
    if (event.target !== this.dialogTarget) return
    this.closeDialog()
  }

  closeDialog() {
    if (!this.hasDialogTarget || !this.dialogTarget.open) return

    if (this.dialogTarget.close) {
      this.dialogTarget.close()
    } else {
      this.dialogTarget.removeAttribute("open")
      this.restoreAfterClose()
    }
  }

  restoreAfterClose() {
    document.documentElement.classList.remove("poster-lightbox-open")
    this.opener?.focus({ preventScroll: true })
  }

  loadImage() {
    if (!this.hasImageTarget) return

    const source = this.imageTarget.dataset.posterLightboxSrc
    if (!source || this.imageTarget.src === source) return

    this.imageTarget.src = source
  }
}
