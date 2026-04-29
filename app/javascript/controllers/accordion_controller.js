import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel", "icon"]
  static values = { active: Number }

  connect() {
    this.sync()
  }

  toggle(event) {
    const index = Number(event.params.index)
    this.activeValue = this.activeValue === index ? 0 : index
    this.sync()
  }

  sync() {
    this.panelTargets.forEach((panel) => {
      const index = Number(panel.dataset.accordionIndex)
      panel.classList.toggle("hidden", index !== this.activeValue)
    })

    this.buttonTargets.forEach((button) => {
      const index = Number(button.dataset.accordionIndex)
      button.setAttribute("aria-expanded", index === this.activeValue ? "true" : "false")
    })

    this.iconTargets.forEach((icon) => {
      const index = Number(icon.dataset.accordionIndex)
      const isActive = index === this.activeValue
      icon.textContent = isActive ? "-" : "+"
      icon.classList.toggle("rotate-180", isActive)
    })
  }
}
