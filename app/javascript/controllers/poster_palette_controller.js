import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  connect() {
    this.applyPalette = this.applyPalette.bind(this)
    this.image = this.imageTargets[0]
    if (!this.image) return

    if (this.image.complete && this.image.naturalWidth) {
      this.applyPalette()
    } else {
      this.image.addEventListener("load", this.applyPalette, { once: true })
    }
  }

  disconnect() {
    this.image?.removeEventListener("load", this.applyPalette)
  }

  applyPalette() {
    const palette = this.extractPalette(this.image)
    if (!palette) return

    this.element.style.setProperty("--poster-primary-rgb", this.rgbValue(palette.primary))
    this.element.style.setProperty("--poster-secondary-rgb", this.rgbValue(palette.secondary))
    this.element.style.setProperty("--poster-shadow-rgb", this.rgbValue(palette.shadow))
    this.element.dataset.paletteReady = "true"
  }

  extractPalette(image) {
    const canvas = document.createElement("canvas")
    const size = 36
    canvas.width = size
    canvas.height = size

    const context = canvas.getContext("2d", { willReadFrequently: true })
    if (!context) return null

    try {
      context.drawImage(image, 0, 0, size, size)
      const data = context.getImageData(0, 0, size, size).data
      const buckets = new Map()

      for (let index = 0; index < data.length; index += 16) {
        const red = data[index]
        const green = data[index + 1]
        const blue = data[index + 2]
        const alpha = data[index + 3]
        if (alpha < 128) continue

        const hsl = this.rgbToHsl(red, green, blue)
        if (hsl.lightness < 0.08 || hsl.lightness > 0.94 || hsl.saturation < 0.08) continue

        const key = [
          Math.round(hsl.hue / 18) * 18,
          Math.round(hsl.saturation * 5),
          Math.round(hsl.lightness * 5)
        ].join(":")
        const bucket = buckets.get(key) || {
          count: 0,
          red: 0,
          green: 0,
          blue: 0,
          hue: hsl.hue,
          score: 0
        }

        bucket.count += 1
        bucket.red += red
        bucket.green += green
        bucket.blue += blue
        bucket.score += hsl.saturation * 1.7 + (1 - Math.abs(hsl.lightness - 0.52)) * 0.8
        buckets.set(key, bucket)
      }

      const sorted = Array.from(buckets.values())
        .map((bucket) => ({
          ...bucket,
          color: [
            Math.round(bucket.red / bucket.count),
            Math.round(bucket.green / bucket.count),
            Math.round(bucket.blue / bucket.count)
          ],
          weight: bucket.count * bucket.score
        }))
        .sort((a, b) => b.weight - a.weight)

      if (!sorted.length) return null

      const primaryBucket = sorted[0]
      const secondaryBucket =
        sorted.find((bucket) => this.hueDistance(bucket.hue, primaryBucket.hue) > 42) ||
        sorted[1] ||
        primaryBucket

      return {
        primary: primaryBucket.color,
        secondary: secondaryBucket.color,
        shadow: this.mix(primaryBucket.color, [8, 8, 10], 0.62)
      }
    } catch (error) {
      return null
    }
  }

  rgbToHsl(red, green, blue) {
    const r = red / 255
    const g = green / 255
    const b = blue / 255
    const max = Math.max(r, g, b)
    const min = Math.min(r, g, b)
    const lightness = (max + min) / 2
    const delta = max - min

    if (delta === 0) return { hue: 0, saturation: 0, lightness }

    const saturation = delta / (1 - Math.abs(2 * lightness - 1))
    let hue = 0

    if (max === r) {
      hue = ((g - b) / delta) % 6
    } else if (max === g) {
      hue = (b - r) / delta + 2
    } else {
      hue = (r - g) / delta + 4
    }

    return {
      hue: (hue * 60 + 360) % 360,
      saturation,
      lightness
    }
  }

  hueDistance(first, second) {
    const distance = Math.abs(first - second)
    return Math.min(distance, 360 - distance)
  }

  mix(color, target, amount) {
    return color.map((channel, index) => Math.round(channel * (1 - amount) + target[index] * amount))
  }

  rgbValue(color) {
    return color.join(", ")
  }
}
