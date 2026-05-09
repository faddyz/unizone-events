import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["city", "format", "category", "progress", "progressTitle", "progressStatus", "submitButton"]
  static growthCitySlugs = ["istanbul", "ankara", "izmir", "antalya", "bursa", "eskisehir", "balikesir", "adana", "mugla", "mersin", "kocaeli", "konya", "gaziantep"]
  static growthFormatSlugs = ["konser", "festival", "konferans", "kongre", "panel", "seminer", "soylesi", "zirve", "fuar", "webinar", "egitim", "atolye", "calistay", "sergi"]
  static growthUnizoneCategories = ["music", "festival", "art_exhibition", "culture", "conference", "workshop", "networking", "technology", "education", "business", "career", "food_lifestyle", "nightlife", "sports_wellness"]

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
    this.setChecked(this.categoryTargets, (checkbox) => this.inList(checkbox.dataset.unizoneCategory, this.constructor.growthUnizoneCategories))
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

  categoryScope(event) {
    const category = event.currentTarget.dataset.unizoneCategory
    if (!category) return

    const matchingCategories = this.categoryTargets.filter((checkbox) => checkbox.dataset.unizoneCategory === category)
    const shouldSelect = matchingCategories.some((checkbox) => !checkbox.checked)

    this.setChecked(matchingCategories, shouldSelect)
    event.currentTarget.classList.toggle("is-active", shouldSelect)
  }

  categoryChanged() {
    this.syncCategoryPresetStates()
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

    this.syncCategoryPresetStates()
  }

  syncCategoryPresetStates() {
    this.element.querySelectorAll("[data-unizone-category]").forEach((button) => {
      const category = button.dataset.unizoneCategory
      const matchingCategories = this.categoryTargets.filter((checkbox) => checkbox.dataset.unizoneCategory === category)
      button.classList.toggle("is-active", matchingCategories.length > 0 && matchingCategories.every((checkbox) => checkbox.checked))
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
