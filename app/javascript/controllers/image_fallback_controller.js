import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    src: String
  }

  connect() {
    if (this.element.complete && this.element.naturalWidth === 0) this.recover()
  }

  recover() {
    if (this.recovered || !this.hasSrcValue || this.element.src === this.srcValue) return

    this.recovered = true
    this.element.src = this.srcValue
  }
}
