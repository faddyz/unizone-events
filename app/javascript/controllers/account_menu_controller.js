import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener("click", this.closeOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
  }

  closeOnOutsideClick(event) {
    if (!this.element.open) return
    if (this.element.contains(event.target)) return

    this.element.open = false
  }

  keydown(event) {
    if (event.key !== "Escape") return

    this.element.open = false
    event.currentTarget.blur()
  }
}
