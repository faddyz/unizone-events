import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "tab", "next", "previous", "progress", "submit", "current", "total", "stepTitle", "stepSummary"]

  connect() {
    this.index = 0
    this.show()
    this.refresh()
  }

  next(event) {
    event?.preventDefault()
    this.index = Math.min(this.index + 1, this.stepTargets.length - 1)
    this.show()
  }

  previous(event) {
    event?.preventDefault()
    this.index = Math.max(this.index - 1, 0)
    this.show()
  }

  go(event) {
    event.preventDefault()
    const nextIndex = Number(event.currentTarget.dataset.wizardIndex)
    if (Number.isNaN(nextIndex)) return

    this.index = nextIndex
    this.show()
  }

  keydown(event) {
    if (!["ArrowRight", "ArrowDown", "ArrowLeft", "ArrowUp", "Home", "End"].includes(event.key)) return

    event.preventDefault()
    const lastIndex = this.tabTargets.length - 1

    if (event.key === "Home") {
      this.index = 0
    } else if (event.key === "End") {
      this.index = lastIndex
    } else if (event.key === "ArrowRight" || event.key === "ArrowDown") {
      this.index = this.index === lastIndex ? 0 : this.index + 1
    } else {
      this.index = this.index === 0 ? lastIndex : this.index - 1
    }

    this.show()
    this.tabTargets[this.index]?.focus()
  }

  refresh() {
    this.tabTargets.forEach((tab, index) => {
      tab.classList.toggle("is-complete", this.stepComplete(index))
    })
  }

  show() {
    this.stepTargets.forEach((step, index) => {
      step.hidden = index !== this.index
    })

    this.tabTargets.forEach((tab, index) => {
      const active = index === this.index
      tab.classList.toggle("is-active", active)
      tab.setAttribute("aria-current", active ? "step" : "false")
      tab.setAttribute("aria-selected", active ? "true" : "false")
      tab.tabIndex = active ? 0 : -1
    })

    if (this.hasPreviousTarget) {
      const disabled = this.index === 0
      this.previousTarget.disabled = disabled
      this.previousTarget.classList.toggle("opacity-40", disabled)
    }

    if (this.hasNextTarget) {
      this.nextTarget.hidden = this.index === this.stepTargets.length - 1
    }

    if (this.hasSubmitTarget) {
      this.submitTarget.hidden = this.index !== this.stepTargets.length - 1
    }

    if (this.hasProgressTarget) {
      const progress = ((this.index + 1) / this.stepTargets.length) * 100
      this.progressTarget.style.width = `${progress}%`
    }

    if (this.hasCurrentTarget) this.currentTarget.textContent = this.index + 1
    if (this.hasTotalTarget) this.totalTarget.textContent = this.stepTargets.length

    const activeTab = this.tabTargets[this.index]
    if (this.hasStepTitleTarget && activeTab?.dataset.wizardTitle) {
      this.stepTitleTarget.textContent = activeTab.dataset.wizardTitle
    }
    if (this.hasStepSummaryTarget && activeTab?.dataset.wizardSummary) {
      this.stepSummaryTarget.textContent = activeTab.dataset.wizardSummary
    }

    this.refresh()
  }

  stepComplete(index) {
    const step = this.stepTargets[index]
    if (!step) return false

    const requiredFields = Array.from(step.querySelectorAll("[data-wizard-required='true']"))
    if (requiredFields.length === 0) return false

    return requiredFields.every((field) => {
      if (field.type === "checkbox" || field.type === "radio") return field.checked
      return field.value.trim().length > 0
    })
  }
}
