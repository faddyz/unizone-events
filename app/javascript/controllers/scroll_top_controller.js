import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.update = this.update.bind(this)
    this.update()
    window.addEventListener("scroll", this.update, { passive: true })
  }

  disconnect() {
    window.removeEventListener("scroll", this.update)
  }

  scroll() {
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  update() {
    const visible = window.scrollY > 420
    this.buttonTarget.classList.toggle("is-visible", visible)
    this.buttonTarget.setAttribute("aria-hidden", visible ? "false" : "true")
    this.buttonTarget.tabIndex = visible ? 0 : -1
  }
}
