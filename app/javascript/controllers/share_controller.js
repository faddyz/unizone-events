import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "toast"]
  static values = {
    title: String,
    text: String,
    url: String
  }

  async share() {
    const payload = {
      title: this.titleValue,
      text: this.textValue,
      url: this.urlValue || window.location.href
    }

    try {
      if (navigator.share) {
        await navigator.share(payload)
        this.showFeedback("Paylaşım açıldı.")
        return
      }

      await this.copyUrl(payload.url)
      this.showFeedback("Bağlantı kopyalandı.")
    } catch (error) {
      if (error?.name === "AbortError") return
      this.showFeedback("Bağlantı kopyalanamadı.", true)
    }
  }

  async copyUrl(url) {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(url)
      return
    }

    const field = document.createElement("textarea")
    field.value = url
    field.setAttribute("readonly", "")
    field.style.position = "fixed"
    field.style.top = "-9999px"
    document.body.appendChild(field)
    field.select()
    document.execCommand("copy")
    field.remove()
  }

  showFeedback(message, error = false) {
    this.labelTargets.forEach((target) => {
      target.textContent = message
    })

    if (this.hasToastTarget) {
      this.toastTarget.textContent = message
      this.toastTarget.classList.toggle("hidden", false)
      this.toastTarget.classList.toggle("bg-rose-700", error)
    }

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.labelTargets.forEach((target) => {
        target.textContent = "Paylaş"
      })
      if (this.hasToastTarget) this.toastTarget.classList.add("hidden")
    }, 2200)
  }
}
