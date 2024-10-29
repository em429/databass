import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  dismiss(event) {
    const flashElement = event.target.closest('[role="alert"]')
    if (flashElement) {
      flashElement.remove()
    }
  }
}
