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
    const animations = [
      this.revealSoftly(this.logoTarget, 0, { distance: 12, duration: 520 }),
      ...this.lineTargets.map((target, index) => this.revealLine(target, 90 + index * 145)),
      this.revealSoftly(this.subtitleTarget, 620, { distance: 18, duration: 640 }),
      this.revealSoftly(this.formTarget, 760, { distance: 16, duration: 640 })
    ].filter(Boolean)

    Promise.all(animations.map((animation) => animation.finished.catch(() => {}))).then(() => {
      this.animatedTargets.forEach((target) => target.style.removeProperty("will-change"))
    })
  }

  revealLine(target, delay) {
    target.style.willChange = "transform, opacity"

    return target.animate(
      [
        { opacity: 0.01, transform: "translate3d(0, 108%, 0) skewY(2deg)" },
        { opacity: 1, transform: "translate3d(0, 0, 0) skewY(0deg)" }
      ],
      {
        duration: 780,
        delay,
        easing: "cubic-bezier(0.16, 1, 0.3, 1)",
        fill: "backwards"
      }
    )
  }

  revealSoftly(target, delay, options = {}) {
    if (!target) return null

    const distance = options.distance || 14
    const duration = options.duration || 580
    target.style.willChange = "transform, opacity"

    return target.animate(
      [
        { opacity: 0, transform: `translate3d(0, ${distance}px, 0)` },
        { opacity: 1, transform: "translate3d(0, 0, 0)" }
      ],
      {
        duration,
        delay,
        easing: "cubic-bezier(0.16, 1, 0.3, 1)",
        fill: "backwards"
      }
    )
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

  get lineTargets() {
    return Array.from(this.element.querySelectorAll('[data-hero-target="line"]'))
  }

  get logoTarget() {
    return this.element.querySelector('[data-hero-target="logo"]')
  }

  get subtitleTarget() {
    return this.element.querySelector('[data-hero-target="subtitle"]')
  }

  get formTarget() {
    return this.element.querySelector('[data-hero-target="form"]')
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
