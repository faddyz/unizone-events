import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onDocumentClick = this.handleDocumentClick.bind(this)
    this.onDocumentKeydown = this.handleDocumentKeydown.bind(this)
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("keydown", this.onDocumentKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onDocumentKeydown)
  }

  handleDocumentClick(event) {
    if (!this.element.open) return
    if (this.element.contains(event.target)) return
    this.element.open = false
  }

  handleDocumentKeydown(event) {
    if (event.key !== "Escape") return
    if (!this.element.open) return
    this.element.open = false
  }
}
