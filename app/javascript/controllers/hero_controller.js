import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

const PREVIEW_URL_KEY = "unizone:hero-preview-url"

export default class extends Controller {
  connect() {
    this.gsapContext = gsap.context(() => {
      this.resetAnimatedTargets()
      this.element.classList.add("hero-ready")

      if (this.shouldSkipIntro()) return

      window.requestAnimationFrame(() => this.animateIntro())
    }, this.element)
  }

  disconnect() {
    this.timeline?.kill()
    this.clearAnimatedProps()
    this.gsapContext?.revert()
  }

  resetAnimatedTargets() {
    gsap.set(this.animatedTargets, {
      clearProps: "opacity,visibility,transform,translate,rotate,scale,filter,willChange"
    })
  }

  animateIntro() {
    this.timeline?.kill()

    const lines = this.lineTargets
    const ambientTargets = Array.from(
      this.element.querySelectorAll(".hero-orb, .hero-ribbon, .hero-stage-wash, .hero-glow-field")
    )

    gsap.set(lines, {
      autoAlpha: 0,
      yPercent: 118,
      rotate: 1.8,
      transformOrigin: "left bottom",
      willChange: "transform, opacity"
    })

    gsap.set([this.logoTarget, this.formTarget].filter(Boolean), {
      autoAlpha: 0,
      y: 18,
      willChange: "transform, opacity"
    })

    this.timeline = gsap.timeline({
      defaults: { ease: "power4.out" },
      onComplete: () => this.clearAnimatedProps()
    })

    this.timeline
      .fromTo(
        ambientTargets,
        { autoAlpha: 0.62, scale: 0.98, filter: "saturate(0.92)" },
        {
          autoAlpha: 1,
          scale: 1,
          filter: "saturate(1)",
          duration: 1.35,
          stagger: 0.035,
          clearProps: "opacity,visibility,transform,filter"
        },
        0
      )
      .to(
        this.logoTarget,
        {
          autoAlpha: 1,
          y: 0,
          duration: 0.58,
          ease: "back.out(1.45)"
        },
        0.04
      )
      .to(
        lines,
        {
          autoAlpha: 1,
          yPercent: 0,
          rotate: 0,
          duration: 0.96,
          stagger: 0.13,
          ease: "expo.out"
        },
        0.12
      )
      .to(
        this.formTarget,
        {
          autoAlpha: 1,
          y: 0,
          duration: 0.76,
          ease: "power3.out"
        },
        0.86
      )
  }

  clearAnimatedProps() {
    gsap.set(this.animatedTargets, {
      clearProps: "opacity,visibility,transform,translate,rotate,scale,filter,willChange"
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
    return Array.from(
      this.element.querySelectorAll('[data-hero-target]:not([data-hero-target="subtitle"])')
    )
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
