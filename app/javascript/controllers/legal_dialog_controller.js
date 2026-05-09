import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["terms", "privacy"]

  openTerms(event) {
    event.preventDefault()
    this.open(this.termsTarget)
  }

  openPrivacy(event) {
    event.preventDefault()
    this.open(this.privacyTarget)
  }

  close(event) {
    event.preventDefault()
    event.currentTarget.closest("dialog")?.close()
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) {
      event.currentTarget.close()
    }
  }

  open(dialog) {
    if (typeof dialog.showModal === "function") {
      dialog.showModal()
      return
    }

    dialog.setAttribute("open", "")
  }
}
