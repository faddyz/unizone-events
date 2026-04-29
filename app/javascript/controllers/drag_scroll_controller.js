import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.cancelClick = this.cancelClick.bind(this)
  }

  start(event) {
    if (event.button !== undefined && event.button !== 0) return

    this.dragging = true
    this.dragged = false
    this.pointerId = event.pointerId
    this.startX = event.clientX
    this.startScrollLeft = this.element.scrollLeft
    this.element.classList.add("is-dragging")
    this.element.setPointerCapture?.(event.pointerId)
  }

  move(event) {
    if (!this.dragging) return

    const delta = event.clientX - this.startX
    if (Math.abs(delta) > 4) {
      this.dragged = true
      event.preventDefault()
    }

    this.element.scrollLeft = this.startScrollLeft - delta
  }

  stop(event) {
    if (!this.dragging) return

    this.dragging = false
    this.element.classList.remove("is-dragging")
    this.element.releasePointerCapture?.(this.pointerId || event.pointerId)

    if (this.dragged) {
      this.element.addEventListener("click", this.cancelClick, { capture: true, once: true })
    }
  }

  cancelClick(event) {
    event.preventDefault()
    event.stopPropagation()
  }

  preventNativeDrag(event) {
    event.preventDefault()
  }
}
