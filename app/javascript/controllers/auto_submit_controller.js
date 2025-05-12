import { Controller } from "@hotwired/stimulus"

// Form içinde seçildiğinde veya değiştirildiğinde formun otomatik gönderilmesini sağlar
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
} 