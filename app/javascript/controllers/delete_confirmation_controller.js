import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delete-confirmation"
export default class extends Controller {
  static targets = ["modal", "title", "message", "form", "cancelButton"]
  static values = {
    title: String,
    message: String,
    formUrl: String
  }

  connect() {
    // Modal kapatıcı işlevini ekle
    this.cancelButtonTarget.addEventListener("click", () => {
      this.hideModal()
    })

    // ESC tuşuyla kapatma
    document.addEventListener("keydown", this.handleKeydown.bind(this))
    
    // Arka plana tıklama ile kapatma
    this.modalTarget.addEventListener("click", (e) => {
      if (e.target === this.modalTarget) {
        this.hideModal()
      }
    })
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown)
  }

  handleKeydown(e) {
    if (e.key === "Escape" && !this.modalTarget.classList.contains("hidden")) {
      this.hideModal()
    }
  }

  showModal(event) {
    // Buton veya linkten data attribute'larını al
    if (event && event.currentTarget) {
      const dataUrl = event.currentTarget.getAttribute('data-url');
      const dataTitle = event.currentTarget.getAttribute('data-title');
      const dataMessage = event.currentTarget.getAttribute('data-message');

      // Debug için URL değerini göster
      console.log('Modal triggering with URL:', dataUrl);
      
      // Modal içeriğini güncelle
      if (dataTitle) {
        this.titleTarget.textContent = dataTitle;
        this.titleValue = dataTitle;
      }
      
      if (dataMessage) {
        this.messageTarget.textContent = dataMessage;
        this.messageValue = dataMessage;
      }
      
      // Form action'u ayarla (eğer varsa) - ÖNEMLİ SORUN BURADA!
      if (dataUrl && this.hasFormTarget) {
        // Tam URL değerini kullan
        this.formTarget.action = dataUrl;
        console.log('Form action set to:', this.formTarget.action);
      }
    }
    
    // Modal'ı göster
    this.modalTarget.classList.remove('hidden');
    document.body.classList.add('overflow-hidden');
  }

  hideModal() {
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
  }
} 