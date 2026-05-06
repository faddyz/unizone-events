import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["city", "format", "category", "progress", "progressTitle", "progressStatus", "submitButton"]
  static growthCitySlugs = ["istanbul", "ankara", "izmir", "antalya", "bursa", "eskisehir", "balikesir", "adana", "mugla", "mersin", "kocaeli", "konya", "gaziantep"]
  static growthFormatSlugs = ["konser", "festival", "konferans", "kongre", "panel", "seminer", "soylesi", "zirve", "fuar", "webinar", "egitim", "atolye", "calistay", "sergi"]

  disconnect() {
    this.disableUnloadWarning()
  }

  scanStarted(event) {
    const submitter = event.detail?.formSubmission?.submitter
    const label = submitter?.dataset.scanActionLabel || "Tarama çalışıyor"

    if (this.hasProgressTarget) {
      this.progressTarget.classList.remove("hidden")
    }

    if (this.hasProgressTitleTarget) {
      this.progressTitleTarget.textContent = label
    }

    if (this.hasProgressStatusTarget) {
      this.progressStatusTarget.textContent = "API taranıyor. Sekmeyi açık bırak."
    }

    this.submitButtonTargets.forEach((button) => {
      button.disabled = true
      button.classList.add("is-busy")
      button.setAttribute("aria-disabled", "true")
    })

    this.enableUnloadWarning()
  }

  scanEnded(event) {
    this.disableUnloadWarning()

    if (event.detail?.success) return

    if (this.hasProgressStatusTarget) {
      this.progressStatusTarget.textContent = "Tarama tamamlanamadı. Tekrar deneyebilirsin."
    }

    this.submitButtonTargets.forEach((button) => {
      button.disabled = false
      button.classList.remove("is-busy")
      button.removeAttribute("aria-disabled")
    })
  }

  defaultScope() {
    this.setChecked(this.cityTargets, (checkbox) => checkbox.dataset.defaultSelected === "true")
    this.setChecked(this.formatTargets, (checkbox) => checkbox.dataset.defaultSelected === "true")
    this.setChecked(this.categoryTargets, false)
    this.markActive("default")
  }

  growthScope() {
    this.setChecked(this.cityTargets, (checkbox) => this.inList(checkbox.dataset.citySlug, this.constructor.growthCitySlugs))
    this.setChecked(this.formatTargets, (checkbox) => this.inList(checkbox.dataset.formatSlug, this.constructor.growthFormatSlugs))
    this.setChecked(this.categoryTargets, false)
    this.markActive("growth")
  }

  allCities() {
    this.setChecked(this.cityTargets, true)
    this.markActive("all_cities")
  }

  clearCities() {
    this.setChecked(this.cityTargets, false)
    this.markActive("clear_cities")
  }

  clearTaxonomy() {
    this.setChecked(this.formatTargets, false)
    this.setChecked(this.categoryTargets, false)
    this.markActive("clear_taxonomy")
  }

  setChecked(targets, valueOrCallback) {
    targets.forEach((checkbox) => {
      checkbox.checked = typeof valueOrCallback === "function" ? valueOrCallback(checkbox) : valueOrCallback
    })
  }

  inList(value, list) {
    return list.includes((value || "").toString())
  }

  markActive(mode) {
    this.element.querySelectorAll("[data-scan-preset]").forEach((button) => {
      button.classList.toggle("is-active", button.dataset.scanPreset === mode)
    })
  }

  enableUnloadWarning() {
    this.beforeUnloadHandler ||= (event) => {
      event.preventDefault()
      event.returnValue = ""
    }

    window.addEventListener("beforeunload", this.beforeUnloadHandler)
  }

  disableUnloadWarning() {
    if (!this.beforeUnloadHandler) return

    window.removeEventListener("beforeunload", this.beforeUnloadHandler)
  }
}
