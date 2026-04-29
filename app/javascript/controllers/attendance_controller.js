import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "count", "meter", "spots", "toast"]
  static values = {
    url: String,
    signedIn: Boolean,
    capacity: Number
  }

  async update(event) {
    const button = event.currentTarget

    if (!this.signedInValue) {
      window.location.href = "/users/sign_in"
      return
    }

    const status = button.dataset.attendanceStatus

    this.setActiveState(status)

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ status })
      })

      const data = await response.json()

      if (!response.ok || data.status !== "success") {
        this.showToast(data.message || "RSVP güncellenemedi.", true)
        return
      }

      this.updateMetrics(data)

      this.showToast(this.messageFor(status))
    } catch (_error) {
      this.showToast("RSVP güncellenemedi.", true)
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
    clearTimeout(this.hideTimeout)
  }

  setActiveState(activeStatus) {
    this.buttonTargets.forEach((button) => {
      const isActive = button.dataset.attendanceStatus === activeStatus
      const activeClasses = this.classesFrom(button.dataset.attendanceActiveClass, ["border-stone-950", "bg-stone-950", "text-white"])
      const inactiveClasses = this.classesFrom(button.dataset.attendanceInactiveClass, ["border-stone-200", "bg-white", "text-stone-800"])
      const state = button.querySelector("[data-attendance-state]")
      const classesToAdd = isActive ? activeClasses : inactiveClasses

      if (activeClasses.length) button.classList.remove(...activeClasses)
      if (inactiveClasses.length) button.classList.remove(...inactiveClasses)
      if (classesToAdd.length) button.classList.add(...classesToAdd)
      button.setAttribute("aria-pressed", isActive ? "true" : "false")

      if (state) {
        state.textContent = isActive
          ? button.dataset.attendanceSelectedLabel || button.dataset.attendanceDefaultLabel || state.textContent
          : button.dataset.attendanceDefaultLabel || state.textContent
      }
    })
  }

  updateMetrics(data) {
    this.countTargets.forEach((target) => {
      const key = target.dataset.attendanceCountKey || "attendees_count"
      if (Object.prototype.hasOwnProperty.call(data, key)) {
        target.textContent = data[key]
      }
    })

    if (!this.hasCapacityValue || this.capacityValue <= 0 || !Object.prototype.hasOwnProperty.call(data, "attendees_count")) return

    const goingCount = Number(data.attendees_count)
    const spotsLeft = Math.max(this.capacityValue - goingCount, 0)
    const percent = Math.min(Math.max(Math.round((goingCount / this.capacityValue) * 100), 0), 100)

    this.meterTargets.forEach((target) => {
      target.style.width = `${percent}%`
    })
    this.spotsTargets.forEach((target) => {
      target.textContent = spotsLeft
    })
  }

  classesFrom(value, fallback) {
    if (value === "") return []
    return (value || fallback.join(" ")).split(" ").filter(Boolean)
  }

  messageFor(status) {
    switch (status) {
      case "going":
        return "Gidiyorum olarak kaydedildi."
      case "interested":
        return "İlgileniyorum olarak kaydedildi."
      default:
        return "Gitmiyorum olarak kaydedildi."
    }
  }

  showToast(message, error = false) {
    if (!this.hasToastTarget) return

    const toast = this.toastTarget
    toast.textContent = message
    toast.className = `mt-3 rounded-lg px-4 py-3 text-sm ${error ? "bg-rose-50 text-rose-700" : "bg-emerald-50 text-emerald-700"}`
    toast.classList.remove("hidden")

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      toast.classList.add("hidden")
    }, 2500)
  }
}
