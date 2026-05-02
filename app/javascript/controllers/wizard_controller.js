import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

export default class extends Controller {
  static targets = ["step", "tab", "next", "previous", "progress", "submit", "current", "total", "stepTitle", "stepSummary"]

  connect() {
    this.index = 0
    this.show({ animate: false })
    this.refresh()
  }

  disconnect() {
    gsap.killTweensOf(this.stepTargets)
  }

  next(event) {
    event?.preventDefault()
    this.moveTo(Math.min(this.index + 1, this.stepTargets.length - 1))
  }

  previous(event) {
    event?.preventDefault()
    this.moveTo(Math.max(this.index - 1, 0))
  }

  go(event) {
    event.preventDefault()
    const nextIndex = Number(event.currentTarget.dataset.wizardIndex)
    if (Number.isNaN(nextIndex)) return

    this.moveTo(nextIndex)
  }

  keydown(event) {
    if (!["ArrowRight", "ArrowDown", "ArrowLeft", "ArrowUp", "Home", "End"].includes(event.key)) return

    event.preventDefault()
    const lastIndex = this.tabTargets.length - 1

    let nextIndex
    if (event.key === "Home") {
      nextIndex = 0
    } else if (event.key === "End") {
      nextIndex = lastIndex
    } else if (event.key === "ArrowRight" || event.key === "ArrowDown") {
      nextIndex = this.index === lastIndex ? 0 : this.index + 1
    } else {
      nextIndex = this.index === 0 ? lastIndex : this.index - 1
    }

    this.moveTo(nextIndex)
    this.tabTargets[this.index]?.focus()
  }

  refresh() {
    this.tabTargets.forEach((tab, index) => {
      tab.classList.toggle("is-complete", this.stepComplete(index))
    })
  }

  moveTo(nextIndex) {
    const boundedIndex = Math.max(0, Math.min(nextIndex, this.stepTargets.length - 1))
    if (boundedIndex === this.index) return

    this.previousIndex = this.index
    this.index = boundedIndex
    this.show({ animate: true })
  }

  show({ animate = true } = {}) {
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

    if (animate) this.animateActiveStep()
  }

  animateActiveStep() {
    if (this.shouldSkipMotion()) return

    const step = this.stepTargets[this.index]
    if (!step) return

    const direction = this.previousIndex == null || this.index >= this.previousIndex ? 1 : -1
    const children = Array.from(step.querySelectorAll(".event-form-step-intro, .event-form-grid > *"))

    gsap.killTweensOf([step, ...children])
    gsap.fromTo(
      step,
      { autoAlpha: 0, x: direction * 16 },
      {
        autoAlpha: 1,
        x: 0,
        duration: 0.28,
        ease: "power3.out",
        clearProps: "opacity,visibility,transform"
      }
    )
    gsap.fromTo(
      children,
      { autoAlpha: 0, y: 10 },
      {
        autoAlpha: 1,
        y: 0,
        duration: 0.32,
        stagger: 0.025,
        ease: "power3.out",
        clearProps: "opacity,visibility,transform"
      }
    )
  }

  shouldSkipMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
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
