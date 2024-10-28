import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.outsideClickHandler = this.closeIfClickedOutside.bind(this)
    document.addEventListener('click', this.outsideClickHandler)
  }

  disconnect() {
    document.removeEventListener('click', this.outsideClickHandler)
  }

  toggle(event) {
    event.stopPropagation()
    
    // Close all other dropdowns first
    document.querySelectorAll('[data-dropdown-controller]').forEach(controller => {
      if (controller !== this.element) {
        controller.querySelector('[data-dropdown-target="menu"]').classList.add('hidden')
      }
    })
    
    this.menuTarget.classList.toggle('hidden')
  }

  closeIfClickedOutside(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add('hidden')
    }
  }
}
