import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "title",
    "category",
    "date",
    "city",
    "location",
    "price",
    "capacity",
    "ticketUrl",
    "description",
    "imageInput",
    "previewTitle",
    "previewCategory",
    "previewDate",
    "previewMonth",
    "previewDay",
    "previewCity",
    "previewLocation",
    "previewPrice",
    "previewCapacity",
    "previewTicket",
    "previewDescription",
    "previewImage",
    "previewFallback",
    "checkItem"
  ]

  connect() {
    this.refresh()
  }

  disconnect() {
    this.revokeObjectUrl()
  }

  refresh() {
    const title = this.valueFor("title")
    const description = this.valueFor("description")
    const city = this.cityLabel()
    const location = this.valueFor("location")
    const category = this.categoryLabel()
    const parsedDate = this.parsedDate()
    const price = this.priceLabel()
    const capacity = this.capacityLabel()
    const ticket = this.ticketLabel()

    this.setText("previewTitle", title || "Etkinlik adı burada parlayacak")
    this.setText("previewCategory", category || "Community")
    this.setText("previewDate", parsedDate ? this.longDate(parsedDate) : "Tarih seçilmedi")
    this.setText("previewMonth", parsedDate ? this.month(parsedDate) : "Ay")
    this.setText("previewDay", parsedDate ? String(parsedDate.getDate()) : "--")
    this.setText("previewCity", city || "Şehir seçilmedi")
    this.setText("previewLocation", location || "Konum seçilmedi")
    this.setText("previewPrice", price)
    this.setText("previewCapacity", capacity)
    this.setText("previewTicket", ticket)
    this.setText("previewDescription", this.shortText(description) || "Etkinliğin atmosferi, akışı ve katılımcıların ne bekleyebileceği burada canlanacak.")

    this.refreshImage()
    this.refreshChecklist({
      title: Boolean(title) && this.hasCategoryTarget,
      date: Boolean(parsedDate),
      location: Boolean(city) && Boolean(location),
      story: description.length >= 24,
      image: this.hasImageInputTarget && (this.imageInputTarget.files.length > 0 || this.imageInputTarget.dataset.existing === "true")
    })
  }

  valueFor(name) {
    const hasTarget = this[`has${this.capitalize(name)}Target`]
    if (!hasTarget) return ""

    return this[`${name}Target`].value.trim()
  }

  setText(name, value) {
    const hasTarget = this[`has${this.capitalize(name)}Target`]
    if (!hasTarget) return

    this[`${name}Targets`].forEach((target) => {
      target.textContent = value
    })
  }

  categoryLabel() {
    if (!this.hasCategoryTarget) return ""

    return this.categoryTarget.selectedOptions[0]?.textContent.trim() || ""
  }

  cityLabel() {
    if (!this.hasCityTarget) return ""

    return this.cityTarget.selectedOptions[0]?.textContent.trim() || ""
  }

  parsedDate() {
    const value = this.valueFor("date")
    if (!value) return null

    const date = new Date(value)
    return Number.isNaN(date.getTime()) ? null : date
  }

  longDate(date) {
    return new Intl.DateTimeFormat("tr-TR", {
      dateStyle: "medium",
      timeStyle: "short"
    }).format(date)
  }

  month(date) {
    return new Intl.DateTimeFormat("tr-TR", { month: "short" }).format(date)
  }

  priceLabel() {
    const rawPrice = this.valueFor("price").replace(",", ".")
    if (!rawPrice) return "Ücretsiz"

    const price = Number(rawPrice)
    if (Number.isNaN(price) || price <= 0) return "Ücretsiz"

    return new Intl.NumberFormat("tr-TR", {
      style: "currency",
      currency: "TRY",
      maximumFractionDigits: price % 1 === 0 ? 0 : 2
    }).format(price)
  }

  capacityLabel() {
    const capacity = this.valueFor("capacity")
    return capacity ? `${capacity} kişi` : "Kontenjan açık"
  }

  ticketLabel() {
    return this.valueFor("ticketUrl") ? "Dış kayıt hazır" : "Unizone RSVP"
  }

  shortText(text) {
    if (text.length <= 130) return text

    return `${text.slice(0, 127).trim()}...`
  }

  refreshImage() {
    if (!this.hasImageInputTarget || !this.hasPreviewImageTarget) return

    const file = this.imageInputTarget.files[0]
    if (!file || file === this.lastFile) return

    this.revokeObjectUrl()
    this.lastFile = file
    this.objectUrl = URL.createObjectURL(file)
    this.previewImageTarget.src = this.objectUrl
    this.previewImageTarget.classList.remove("hidden")

    if (this.hasPreviewFallbackTarget) {
      this.previewFallbackTarget.classList.add("hidden")
    }
  }

  refreshChecklist(states) {
    this.checkItemTargets.forEach((item) => {
      item.classList.toggle("is-done", Boolean(states[item.dataset.check]))
    })
  }

  revokeObjectUrl() {
    if (!this.objectUrl) return

    URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
  }

  capitalize(value) {
    return `${value.charAt(0).toUpperCase()}${value.slice(1)}`
  }
}
