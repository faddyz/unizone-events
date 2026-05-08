import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.classify = this.classify.bind(this)

    if (this.element.complete) {
      this.classify()
    } else {
      this.element.addEventListener("load", this.classify, { once: true })
    }
  }

  disconnect() {
    this.element.removeEventListener("load", this.classify)
  }

  classify() {
    const { naturalWidth, naturalHeight } = this.element
    if (!naturalWidth || !naturalHeight) return

    this.element.classList.toggle("is-landscape-poster", naturalWidth > naturalHeight)
    this.element.classList.toggle("is-portrait-poster", naturalWidth <= naturalHeight)
  }
}
