import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.querySelectorAll("[data-hero-target]").forEach((target) => {
      target.style.removeProperty("opacity")
      target.style.removeProperty("transform")
      target.style.removeProperty("translate")
      target.style.removeProperty("rotate")
      target.style.removeProperty("scale")
    })

    this.element.classList.add("hero-ready")
  }
}
