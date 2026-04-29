import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["line", "subtitle", "form", "logo", "eyebrow"]

  async connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    const navigationEntry = performance.getEntriesByType("navigation")[0]
    const isHardRefresh = navigationEntry?.type === "reload"
    if (!isHardRefresh && sessionStorage.getItem("unizone-hero-played")) return

    const gsap = await this.loadGsap()
    if (!gsap) return

    sessionStorage.setItem("unizone-hero-played", "1")

    const revealTargets = [
      ...this.lineTargets,
      this.hasSubtitleTarget ? this.subtitleTarget : null,
      this.hasFormTarget ? this.formTarget : null,
    ].filter(Boolean)

    gsap.set(revealTargets, { opacity: 0, y: 28 })

    if (this.hasEyebrowTarget) {
      gsap.set(this.eyebrowTarget, { opacity: 0, y: 16 })
    }

    if (this.hasLogoTarget) {
      gsap.set(this.logoTarget, { opacity: 0, scale: 0.96 })
    }

    const timeline = gsap.timeline({ defaults: { ease: "power3.out" } })

    if (this.hasLogoTarget) {
      timeline.to(this.logoTarget, { opacity: 1, scale: 1, duration: 0.5, delay: 0.1 })
    }

    if (this.hasEyebrowTarget) {
      timeline.to(this.eyebrowTarget, { opacity: 1, y: 0, duration: 0.45 }, "-=0.22")
    }

    timeline
      .to(this.lineTargets, { opacity: 1, y: 0, duration: 0.75, stagger: 0.12 }, "-=0.1")
      .to(this.subtitleTarget, { opacity: 1, y: 0, duration: 0.6 }, "-=0.38")
      .to(this.formTarget, { opacity: 1, y: 0, duration: 0.5 }, "-=0.28")
  }

  async loadGsap() {
    try {
      const module = await import("gsap")
      return module.gsap || module.default
    } catch (_error) {
      return null
    }
  }
}
