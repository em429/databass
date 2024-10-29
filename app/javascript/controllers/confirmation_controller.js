import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "confirmButton", "cancelButton", "message"]
  static values = {
    message: String,
    confirmPath: String,
    confirmMethod: String
  }

  connect() {
    // Ensure modal is hidden by default
    if (this.hasModalTarget) {
      this.modalTarget.classList.add('hidden')
    }
  }

  showModal(event) {
    event.preventDefault()
    const link = event.currentTarget
    
    this.confirmPathValue = link.getAttribute('href')
    this.confirmMethodValue = link.dataset.method || 'delete'
    this.messageValue = link.dataset.confirmMessage || 'Are you sure?'
    
    if (this.hasMessageTarget) {
      this.messageTarget.textContent = this.messageValue
    }
    
    this.modalTarget.classList.remove('hidden')
  }

  hideModal() {
    this.modalTarget.classList.add('hidden')
  }

  async confirm(event) {
    event.preventDefault()
    
    try {
      const response = await fetch(this.confirmPathValue, {
        method: this.confirmMethodValue,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml'
        },
        credentials: 'same-origin'
      })

      if (response.ok) {
        const contentType = response.headers.get('Content-Type')
        if (contentType && contentType.includes('text/vnd.turbo-stream.html')) {
          const html = await response.text()
          Turbo.renderStreamMessage(html)
        } else {
          Turbo.visit(response.url)
        }
      }
    } catch (error) {
      console.error('Error during confirmation:', error)
    }

    this.hideModal()
  }

  // Close modal if clicking outside of it
  closeBackground(event) {
    if (event.target === this.modalTarget) {
      this.hideModal()
    }
  }
}
