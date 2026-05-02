import { Controller } from "@hotwired/stimulus"
import { gsap } from "gsap"

export default class extends Controller {
  static targets = [
    "copyButton",
    "copyLabel",
    "label",
    "panel",
    "popover",
    "shareLink",
    "status",
    "toast",
    "trigger",
    "urlPreview"
  ]

  static values = {
    title: String,
    text: String,
    url: String
  }

  connect() {
    this.closeOnDocumentClick = this.closeOnDocumentClick.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)
    this.reposition = this.reposition.bind(this)
    this.defaultLabels = new Map(this.labelTargets.map((target) => [target, target.textContent]))
    this.defaultCopyLabel = this.hasCopyLabelTarget ? this.copyLabelTarget.textContent : ""
    this.defaultStatus = this.hasStatusTarget ? this.statusTarget.textContent : ""

    this.updateShareLinks()
  }

  disconnect() {
    this.removeGlobalListeners()
    this.killPopoverTweens()
    clearTimeout(this.feedbackTimeout)
    clearTimeout(this.copyTimeout)
  }

  async share(event) {
    event?.preventDefault()

    const payload = this.payload

    if (this.shouldUseNativeShare(payload)) {
      try {
        await navigator.share(payload)
        this.showFeedback("Paylaşım açıldı.")
      } catch (error) {
        if (error?.name !== "AbortError") this.open(event?.currentTarget)
      }

      return
    }

    if (this.hasPopoverTarget && this.hasPanelTarget) {
      this.open(event?.currentTarget)
      return
    }

    try {
      await this.copyUrl(payload.url)
      this.showFeedback("Bağlantı kopyalandı.")
    } catch (error) {
      this.showFeedback("Bağlantı kopyalanamadı.", true)
    }
  }

  async copy(event) {
    event?.preventDefault()

    this.setCopyState("copying")

    try {
      await this.copyUrl(this.payload.url)
      this.setCopyState("copied")
    } catch (error) {
      this.setCopyState("error")
    }
  }

  close(event) {
    event?.preventDefault()
    this.hidePopover(true)
  }

  closeSoon() {
    setTimeout(() => this.hidePopover(false), 120)
  }

  open(trigger) {
    if (!this.hasPopoverTarget || !this.hasPanelTarget) return

    this.activeTrigger = trigger || this.activeTrigger
    this.updateShareLinks()
    this.resetCopyState()

    this.popoverTarget.hidden = false
    this.popoverTarget.setAttribute("aria-hidden", "false")
    this.panelTarget.setAttribute("aria-modal", this.isSheetLayout ? "true" : "false")
    this.popoverTarget.classList.add("is-open")
    this.setExpandedTrigger(this.activeTrigger)
    this.reposition()
    this.addGlobalListeners()
    this.animatePopoverIn()

    requestAnimationFrame(() => {
      this.focusableElements[0]?.focus({ preventScroll: true })
    })
  }

  hidePopover(restoreFocus = true) {
    if (!this.hasPopoverTarget || this.popoverTarget.hidden || this.isClosingPopover) return

    this.isClosingPopover = true
    this.popoverTarget.classList.remove("is-open")
    this.popoverTarget.setAttribute("aria-hidden", "true")
    this.setExpandedTrigger(null)
    this.removeGlobalListeners()

    this.animatePopoverOut().then(() => {
      this.isClosingPopover = false
      this.popoverTarget.hidden = true
      if (restoreFocus) this.activeTrigger?.focus({ preventScroll: true })
    })
  }

  updateShareLinks() {
    if (!this.hasShareLinkTarget && !this.hasUrlPreviewTarget) return

    const urls = this.shareUrls

    this.shareLinkTargets.forEach((link) => {
      const channel = link.dataset.shareChannel
      if (urls[channel]) link.href = urls[channel]
    })

    if (this.hasUrlPreviewTarget) {
      this.urlPreviewTarget.textContent = this.compactUrl(this.payload.url)
    }
  }

  shouldUseNativeShare(payload) {
    if (!navigator.share) return false
    if (navigator.canShare && !navigator.canShare(payload)) return false

    const userAgent = navigator.userAgent || ""
    const platform = navigator.userAgentData?.platform || navigator.platform || ""
    const hasTouch = navigator.maxTouchPoints > 1
    const coarsePointer = window.matchMedia("(pointer: coarse)").matches
    const noHover = window.matchMedia("(hover: none)").matches
    const compactViewport = window.matchMedia("(max-width: 900px)").matches
    const mobileUserAgent = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(userAgent)
    const iPadDesktopUserAgent = platform === "MacIntel" && hasTouch

    return mobileUserAgent || iPadDesktopUserAgent || (hasTouch && coarsePointer && noHover && compactViewport)
  }

  async copyUrl(url) {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(url)
      return
    }

    const field = document.createElement("textarea")
    field.value = url
    field.setAttribute("readonly", "")
    field.style.position = "fixed"
    field.style.top = "-9999px"
    document.body.appendChild(field)
    field.select()
    const copied = document.execCommand("copy")
    field.remove()

    if (!copied) throw new Error("Copy command rejected")
  }

  showFeedback(message, error = false) {
    this.labelTargets.forEach((target) => {
      target.textContent = message
    })

    this.toastTargets.forEach((target) => {
      target.textContent = message
      target.classList.toggle("hidden", false)
      target.classList.toggle("bg-rose-700", error)
    })

    clearTimeout(this.feedbackTimeout)
    this.feedbackTimeout = setTimeout(() => {
      this.labelTargets.forEach((target) => {
        target.textContent = this.defaultLabels.get(target) || "Paylaş"
      })
      this.toastTargets.forEach((target) => target.classList.add("hidden"))
    }, 2200)
  }

  setCopyState(state) {
    if (!this.hasCopyButtonTarget) return

    clearTimeout(this.copyTimeout)

    this.copyButtonTarget.classList.toggle("is-copied", state === "copied")
    this.copyButtonTarget.classList.toggle("is-error", state === "error")

    if (state === "copying") {
      this.copyLabelTarget.textContent = "Kopyalanıyor"
      this.statusTarget.textContent = "Bağlantı hazırlanıyor."
      return
    }

    if (state === "copied") {
      this.copyLabelTarget.textContent = "Link kopyalandı"
      this.statusTarget.textContent = "Bağlantı panoya eklendi."
    } else {
      this.copyLabelTarget.textContent = "Kopyalanamadı"
      this.statusTarget.textContent = "Tarayıcı izin vermedi."
    }

    this.copyTimeout = setTimeout(() => this.resetCopyState(), 2400)
  }

  resetCopyState() {
    if (!this.hasCopyButtonTarget) return

    clearTimeout(this.copyTimeout)
    this.copyButtonTarget.classList.remove("is-copied", "is-error")
    this.copyLabelTarget.textContent = this.defaultCopyLabel
    this.statusTarget.textContent = this.defaultStatus
  }

  animatePopoverIn() {
    if (this.shouldSkipMotion()) return

    const items = this.panelItems
    this.killPopoverTweens()

    gsap.set(this.panelTarget, {
      autoAlpha: 0,
      y: this.isSheetLayout ? 28 : 12,
      scale: this.isSheetLayout ? 1 : 0.975,
      transformOrigin: this.isSheetLayout ? "bottom center" : "top right",
      willChange: "transform, opacity"
    })
    gsap.set(items, { autoAlpha: 0, y: 10 })

    if (this.backdropVisible) {
      gsap.fromTo(this.backdrop, { autoAlpha: 0 }, { autoAlpha: 1, duration: 0.2, ease: "power2.out" })
    }

    gsap.timeline({
      defaults: { ease: "power3.out" },
      onComplete: () => gsap.set([this.panelTarget, ...items], { clearProps: "opacity,visibility,transform,willChange" })
    })
      .to(this.panelTarget, { autoAlpha: 1, y: 0, scale: 1, duration: 0.28 }, 0)
      .to(items, { autoAlpha: 1, y: 0, duration: 0.28, stagger: 0.035 }, 0.08)
  }

  animatePopoverOut() {
    if (this.shouldSkipMotion()) return Promise.resolve()

    this.killPopoverTweens()

    const tweens = [
      gsap.to(this.panelTarget, {
        autoAlpha: 0,
        y: this.isSheetLayout ? 20 : 10,
        scale: this.isSheetLayout ? 1 : 0.985,
        duration: 0.16,
        ease: "power2.in"
      })
    ]

    if (this.backdropVisible) {
      tweens.push(gsap.to(this.backdrop, { autoAlpha: 0, duration: 0.16, ease: "power2.in" }))
    }

    return Promise.all(tweens.map((tween) => tween.then()))
  }

  killPopoverTweens() {
    if (!this.hasPanelTarget) return

    gsap.killTweensOf([this.panelTarget, this.backdrop, ...this.panelItems].filter(Boolean))
  }

  shouldSkipMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  closeOnDocumentClick(event) {
    if (this.popoverTarget.hidden) return
    if (this.panelTarget.contains(event.target)) return
    if (this.triggerTargets.some((trigger) => trigger.contains(event.target))) return

    this.hidePopover(false)
  }

  handleKeydown(event) {
    if (this.popoverTarget.hidden) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.hidePopover(true)
      return
    }

    if (event.key !== "Tab") return

    const focusableElements = this.focusableElements
    if (!focusableElements.length) return

    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]

    if (event.shiftKey && document.activeElement === firstElement) {
      event.preventDefault()
      lastElement.focus()
    } else if (!event.shiftKey && document.activeElement === lastElement) {
      event.preventDefault()
      firstElement.focus()
    } else if (!this.panelTarget.contains(document.activeElement)) {
      event.preventDefault()
      firstElement.focus()
    }
  }

  reposition() {
    if (!this.activeTrigger || this.isSheetLayout) return

    const triggerRect = this.activeTrigger.getBoundingClientRect()
    const panelRect = this.panelTarget.getBoundingClientRect()
    const margin = 16
    const gap = 12
    const panelWidth = panelRect.width || 360
    const panelHeight = panelRect.height || 420
    const maxLeft = window.innerWidth - panelWidth - margin
    const preferredLeft = triggerRect.right - panelWidth
    const left = Math.max(margin, Math.min(preferredLeft, maxLeft))
    const bottomTop = triggerRect.bottom + gap
    const top = bottomTop + panelHeight > window.innerHeight - margin
      ? Math.max(margin, triggerRect.top - panelHeight - gap)
      : bottomTop

    this.popoverTarget.style.setProperty("--share-popover-left", `${left}px`)
    this.popoverTarget.style.setProperty("--share-popover-top", `${top}px`)
  }

  addGlobalListeners() {
    document.addEventListener("click", this.closeOnDocumentClick)
    document.addEventListener("keydown", this.handleKeydown)
    window.addEventListener("resize", this.reposition)
    window.addEventListener("scroll", this.reposition, true)
  }

  removeGlobalListeners() {
    document.removeEventListener("click", this.closeOnDocumentClick)
    document.removeEventListener("keydown", this.handleKeydown)
    window.removeEventListener("resize", this.reposition)
    window.removeEventListener("scroll", this.reposition, true)
  }

  setExpandedTrigger(activeTrigger) {
    this.triggerTargets.forEach((trigger) => {
      trigger.setAttribute("aria-expanded", trigger === activeTrigger ? "true" : "false")
    })
  }

  compactUrl(url) {
    try {
      const parsedUrl = new URL(url)
      return `${parsedUrl.host}${parsedUrl.pathname}`
    } catch (error) {
      return url
    }
  }

  get payload() {
    return {
      title: this.titleValue,
      text: this.shareText,
      url: this.urlValue || window.location.href
    }
  }

  get shareText() {
    return this.textValue || `${this.titleValue} etkinliğine göz at.`
  }

  get shareUrls() {
    const encodedUrl = encodeURIComponent(this.payload.url)
    const encodedText = encodeURIComponent(this.shareText)
    const encodedSubject = encodeURIComponent(this.titleValue || "Unizone etkinliği")
    const encodedBody = encodeURIComponent(`${this.shareText}\n\n${this.payload.url}`)

    return {
      x: `https://twitter.com/intent/tweet?text=${encodedText}&url=${encodedUrl}`,
      whatsapp: `https://wa.me/?text=${encodedBody}`,
      linkedin: `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`,
      email: `mailto:?subject=${encodedSubject}&body=${encodedBody}`,
      telegram: `https://t.me/share/url?url=${encodedUrl}&text=${encodedText}`
    }
  }

  get focusableElements() {
    return Array.from(
      this.panelTarget.querySelectorAll(
        'a[href], button:not([disabled]), [tabindex]:not([tabindex="-1"])'
      )
    ).filter((element) => element.offsetParent !== null)
  }

  get isSheetLayout() {
    return window.matchMedia("(max-width: 639px), (max-height: 520px)").matches
  }

  get panelItems() {
    if (!this.hasPanelTarget) return []

    return Array.from(
      this.panelTarget.querySelectorAll(
        ".event-share-header, .event-share-url-card, .event-share-copy, .event-share-option"
      )
    )
  }

  get backdrop() {
    return this.popoverTarget?.querySelector(".event-share-backdrop")
  }

  get backdropVisible() {
    return this.backdrop && window.getComputedStyle(this.backdrop).display !== "none"
  }
}
