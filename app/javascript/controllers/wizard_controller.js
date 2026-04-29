import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "tab", "next", "previous", "progress", "submit"]

  connect() {
    this.index = 0
    this.show()
  }

  next() {
    this.index = Math.min(this.index + 1, this.stepTargets.length - 1)
    this.show()
  }

  previous() {
    this.index = Math.max(this.index - 1, 0)
    this.show()
  }

  go(event) {
    const nextIndex = Number(event.currentTarget.dataset.wizardIndex)
    if (Number.isNaN(nextIndex)) return

    this.index = nextIndex
    this.show()
  }

  show() {
    this.stepTargets.forEach((step, index) => {
      step.hidden = index !== this.index
    })

    this.tabTargets.forEach((tab, index) => {
      const active = index === this.index
      tab.classList.toggle("bg-stone-950", active)
      tab.classList.toggle("text-white", active)
      tab.classList.toggle("bg-white", !active)
      tab.classList.toggle("text-stone-600", !active)
      tab.setAttribute("aria-current", active ? "step" : "false")
    })

    if (this.hasPreviousTarget) {
      this.previousTarget.disabled = this.index === 0
      this.previousTarget.classList.toggle("opacity-40", this.index === 0)
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
  }
}
