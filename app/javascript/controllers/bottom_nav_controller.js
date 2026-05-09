import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { threshold: { type: Number, default: 12 } }

  connect() {
    this.update = this.update.bind(this)
    this.scheduleUpdate = this.scheduleUpdate.bind(this)
    this.update()
    window.addEventListener("scroll", this.scheduleUpdate, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.scheduleUpdate)
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  scheduleUpdate() {
    if (this.frame) return

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.update()
    })
  }

  update() {
    const visible = window.scrollY > this.thresholdValue

    this.element.classList.toggle("is-visible", visible)
    this.element.setAttribute("aria-hidden", visible ? "false" : "true")

    this.element.querySelectorAll("a, button").forEach((control) => {
      control.tabIndex = visible ? 0 : -1
    })
  }
}
