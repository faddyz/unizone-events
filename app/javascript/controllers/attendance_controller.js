import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "count", "toast"]
  static values = {
    url: String,
    signedIn: Boolean
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

      if (this.hasCountTarget) {
        this.countTarget.textContent = data.attendees_count
      }

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
      button.classList.toggle("border-stone-950", isActive)
      button.classList.toggle("bg-stone-950", isActive)
      button.classList.toggle("text-white", isActive)
      button.classList.toggle("border-stone-200", !isActive)
      button.classList.toggle("bg-white", !isActive)
      button.classList.toggle("text-stone-800", !isActive)
      button.setAttribute("aria-pressed", isActive ? "true" : "false")
    })
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
