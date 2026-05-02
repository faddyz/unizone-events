import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

export default class extends Controller {
  static targets = ["dialog", "image"]

  connect() {
    this.restoreAfterClose = this.restoreAfterClose.bind(this)
    this.handleCancel = this.handleCancel.bind(this)
    if (this.hasDialogTarget) this.dialogTarget.addEventListener("close", this.restoreAfterClose)
    if (this.hasDialogTarget) this.dialogTarget.addEventListener("cancel", this.handleCancel)
  }

  disconnect() {
    if (this.hasDialogTarget) this.dialogTarget.removeEventListener("close", this.restoreAfterClose)
    if (this.hasDialogTarget) this.dialogTarget.removeEventListener("cancel", this.handleCancel)
    this.killTweens()
    document.documentElement.classList.remove("poster-lightbox-open")
  }

  open(event) {
    event?.preventDefault()
    if (!this.hasDialogTarget) return

    this.opener = event?.currentTarget
    document.documentElement.classList.add("poster-lightbox-open")
    this.loadImage()

    if (this.dialogTarget.open) return

    if (this.dialogTarget.showModal) {
      this.dialogTarget.showModal()
    } else {
      this.dialogTarget.setAttribute("open", "")
    }

    requestAnimationFrame(async () => {
      await this.animateOpen()
      this.dialogTarget.querySelector("button")?.focus({ preventScroll: true })
    })
  }

  close(event) {
    event?.preventDefault()
    this.closeDialog()
  }

  closeFromBackdrop(event) {
    if (event.target !== this.dialogTarget) return
    this.closeDialog()
  }

  closeDialog() {
    if (!this.hasDialogTarget || !this.dialogTarget.open || this.isClosing) return

    this.isClosing = true
    this.animateClose().then(() => {
      this.isClosing = false

      if (!this.dialogTarget.open) return

      if (this.dialogTarget.close) {
        this.dialogTarget.close()
      } else {
        this.dialogTarget.removeAttribute("open")
        this.restoreAfterClose()
      }
    })
  }

  restoreAfterClose() {
    document.documentElement.classList.remove("poster-lightbox-open")
    this.killTweens()
    this.clearAnimatedProps()
    this.opener?.focus({ preventScroll: true })
  }

  handleCancel(event) {
    event.preventDefault()
    this.closeDialog()
  }

  animateOpen() {
    if (this.shouldSkipMotion()) return Promise.resolve()

    const panel = this.panel
    const media = this.media
    const closeButton = this.dialogTarget.querySelector("button")
    const animatedItems = [panel, media, closeButton].filter(Boolean)

    this.killTweens()

    gsap.set(panel, {
      autoAlpha: 0,
      y: 24,
      scale: 0.975,
      rotateX: 2,
      transformOrigin: "center center",
      willChange: "transform, opacity"
    })
    gsap.set([media, closeButton].filter(Boolean), { autoAlpha: 0, y: 12 })

    return gsap.timeline({
      defaults: { ease: "power4.out" },
      onComplete: () => gsap.set(animatedItems, { clearProps: "opacity,visibility,transform,willChange" })
    })
      .to(panel, { autoAlpha: 1, y: 0, scale: 1, rotateX: 0, duration: 0.42 }, 0)
      .to(media, { autoAlpha: 1, y: 0, duration: 0.4 }, 0.12)
      .to(closeButton, { autoAlpha: 1, y: 0, duration: 0.28 }, 0.16)
      .then()
  }

  animateClose() {
    if (this.shouldSkipMotion()) return Promise.resolve()

    const panel = this.panel
    if (!panel) return Promise.resolve()

    this.killTweens()

    return gsap.to(panel, {
      autoAlpha: 0,
      y: 18,
      scale: 0.985,
      duration: 0.18,
      ease: "power2.in"
    }).then()
  }

  killTweens() {
    gsap.killTweensOf([this.panel, this.media, this.dialogTarget?.querySelector("button")].filter(Boolean))
  }

  clearAnimatedProps() {
    gsap.set([this.panel, this.media, this.dialogTarget?.querySelector("button")].filter(Boolean), {
      clearProps: "opacity,visibility,transform,willChange"
    })
  }

  shouldSkipMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  loadImage() {
    if (!this.hasImageTarget) return

    const source = this.imageTarget.dataset.posterLightboxSrc
    if (!source || this.imageTarget.src === source) return

    this.imageTarget.src = source
  }

  get panel() {
    return this.dialogTarget?.querySelector(".event-poster-lightbox-panel")
  }

  get media() {
    return this.dialogTarget?.querySelector(".event-poster-lightbox-media")
  }
}
