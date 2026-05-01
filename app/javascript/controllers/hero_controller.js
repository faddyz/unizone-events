import { Controller } from "@hotwired/stimulus"

const PREVIEW_URL_KEY = "unizone:hero-preview-url"

export default class extends Controller {
  connect() {
    this.resetAnimatedTargets()
    this.element.classList.add("hero-ready")

    if (this.shouldSkipIntro()) return

    window.requestAnimationFrame(() => this.animateIntro())
  }

  resetAnimatedTargets() {
    this.animatedTargets.forEach((target) => {
      target.style.removeProperty("opacity")
      target.style.removeProperty("transform")
      target.style.removeProperty("translate")
      target.style.removeProperty("rotate")
      target.style.removeProperty("scale")
      target.style.removeProperty("will-change")
    })
  }

  animateIntro() {
    const animations = this.animatedTargets.map((target, index) => {
      target.style.willChange = "transform, opacity"

      return target.animate(
        [
          { opacity: 0.82, transform: "translate3d(0, 14px, 0)" },
          { opacity: 1, transform: "translate3d(0, 0, 0)" }
        ],
        {
          duration: 620,
          delay: index * 75,
          easing: "cubic-bezier(0.16, 1, 0.3, 1)"
        }
      )
    })

    Promise.all(animations.map((animation) => animation.finished.catch(() => {}))).then(() => {
      this.animatedTargets.forEach((target) => target.style.removeProperty("will-change"))
    })
  }

  shouldSkipIntro() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return true

    if (document.documentElement.hasAttribute("data-turbo-preview")) {
      this.writeStorage(PREVIEW_URL_KEY, window.location.href)
      return true
    }

    if (this.readStorage(PREVIEW_URL_KEY) === window.location.href) {
      this.removeStorage(PREVIEW_URL_KEY)
      return true
    }

    return false
  }

  get animatedTargets() {
    return Array.from(this.element.querySelectorAll("[data-hero-target]"))
  }

  readStorage(key) {
    try {
      return window.sessionStorage.getItem(key)
    } catch (_error) {
      return null
    }
  }

  writeStorage(key, value) {
    try {
      window.sessionStorage.setItem(key, value)
    } catch (_error) {
      // Session storage can be unavailable in some privacy modes.
    }
  }

  removeStorage(key) {
    try {
      window.sessionStorage.removeItem(key)
    } catch (_error) {
      // Session storage can be unavailable in some privacy modes.
    }
  }
}
