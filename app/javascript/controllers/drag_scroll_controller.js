import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.cancelClick = this.cancelClick.bind(this)
  }

  start(event) {
    if (event.button !== undefined && event.button !== 0) return

    this.tracking = true
    this.dragged = false
    this.pointerId = event.pointerId
    this.startX = event.clientX
    this.startScrollLeft = this.element.scrollLeft
  }

  move(event) {
    if (!this.tracking) return

    const delta = event.clientX - this.startX
    if (Math.abs(delta) > 8) {
      this.dragged = true
      this.element.classList.add("is-dragging")
      this.element.setPointerCapture?.(event.pointerId)
      event.preventDefault()
      this.element.scrollLeft = this.startScrollLeft - delta
    }
  }

  stop(event) {
    if (!this.tracking) return

    this.tracking = false
    this.element.classList.remove("is-dragging")
    if (this.dragged) {
      this.element.releasePointerCapture?.(this.pointerId || event.pointerId)
    }

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
