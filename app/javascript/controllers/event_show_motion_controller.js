import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

export default class extends Controller {
  connect() {
    if (this.shouldSkipMotion()) return

    this.gsapContext = gsap.context(() => {
      this.animateHero()
      this.prepareScrollReveals()
    }, this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    this.gsapContext?.revert()
  }

  animateHero() {
    const backLink = this.element.querySelector(".hero-copy > a")
    const badges = this.element.querySelectorAll(".hero-copy .flex.flex-wrap > *")
    const title = this.element.querySelector(".event-show-title")
    const summary = this.element.querySelector(".event-show-title + p")
    const actions = this.element.querySelector(".event-hero-actions")
    const socialProof = this.element.querySelector(".event-hero-actions + div")
    const poster = this.element.querySelector(".event-show-poster-card")
    const posterFrame = this.element.querySelector(".event-show-poster-frame")
    const dateTicket = this.element.querySelector(".event-show-date-ticket")

    const copyItems = [backLink, ...badges, title, summary, actions, socialProof].filter(Boolean)
    const posterItems = [poster, posterFrame, dateTicket].filter(Boolean)

    gsap.set(copyItems, { autoAlpha: 0, y: 18, willChange: "transform, opacity" })
    gsap.set(title, { y: 28, filter: "blur(4px)" })
    gsap.set(poster, {
      autoAlpha: 0,
      y: 28,
      rotate: -1.4,
      scale: 0.975,
      transformOrigin: "center bottom",
      willChange: "transform, opacity"
    })
    gsap.set(dateTicket, { autoAlpha: 0, y: -12, rotate: 2, willChange: "transform, opacity" })

    gsap.timeline({ defaults: { ease: "power4.out" } })
      .to(backLink, { autoAlpha: 1, y: 0, duration: 0.44 }, 0.04)
      .to(badges, { autoAlpha: 1, y: 0, duration: 0.5, stagger: 0.045 }, 0.08)
      .to(title, { autoAlpha: 1, y: 0, filter: "blur(0px)", duration: 0.78, ease: "expo.out" }, 0.16)
      .to(summary, { autoAlpha: 1, y: 0, duration: 0.58 }, 0.42)
      .to(actions, { autoAlpha: 1, y: 0, duration: 0.58 }, 0.52)
      .to(socialProof, { autoAlpha: 1, y: 0, duration: 0.52 }, 0.62)
      .to(poster, { autoAlpha: 1, y: 0, rotate: 0, scale: 1, duration: 0.86, ease: "expo.out" }, 0.2)
      .to(dateTicket, { autoAlpha: 1, y: 0, rotate: 0, duration: 0.58, ease: "back.out(1.6)" }, 0.58)
      .set([...copyItems, ...posterItems], {
        clearProps: "opacity,visibility,transform,filter,willChange"
      })
  }

  prepareScrollReveals() {
    const revealItems = Array.from(
      this.element.querySelectorAll(
        [
          ".event-essential-card",
          ".event-signal-card",
          ".event-story-card",
          ".event-practical-card",
          ".event-action-card",
          ".event-compact-section",
          ".event-rsvp-aside .cinema-panel"
        ].join(",")
      )
    ).filter((item) => item.getBoundingClientRect().top > window.innerHeight * 0.72)

    if (revealItems.length === 0) return

    gsap.set(revealItems, {
      autoAlpha: 0,
      y: 24,
      scale: 0.985,
      transformOrigin: "center top",
      willChange: "transform, opacity"
    })

    this.observer = new IntersectionObserver((entries) => this.revealEntries(entries), {
      rootMargin: "0px 0px -10% 0px",
      threshold: 0.16
    })

    revealItems.forEach((item) => this.observer.observe(item))
  }

  revealEntries(entries) {
    entries.forEach((entry) => {
      if (!entry.isIntersecting) return

      this.observer.unobserve(entry.target)
      gsap.to(entry.target, {
        autoAlpha: 1,
        y: 0,
        scale: 1,
        duration: 0.66,
        ease: "power3.out",
        clearProps: "opacity,visibility,transform,scale,willChange"
      })
    })
  }

  shouldSkipMotion() {
    return (
      window.matchMedia("(prefers-reduced-motion: reduce)").matches ||
      document.documentElement.hasAttribute("data-turbo-preview")
    )
  }
}
