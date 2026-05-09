import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.onDocumentClick = this.handleDocumentClick.bind(this)
    this.onDocumentKeydown = this.handleDocumentKeydown.bind(this)
    this.close = this.close.bind(this)
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("keydown", this.onDocumentKeydown)
    document.addEventListener("turbo:before-cache", this.close)
    document.addEventListener("turbo:before-visit", this.close)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onDocumentKeydown)
    document.removeEventListener("turbo:before-cache", this.close)
    document.removeEventListener("turbo:before-visit", this.close)
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

  close() {
    this.element.open = false
  }
}
