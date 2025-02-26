import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggle() {
    const showElementId = this.checkboxTarget.dataset.toggleShow
    const showElement = document.getElementById(showElementId)
    
    if (showElement) {
      showElement.classList.toggle("hidden", !this.checkboxTarget.checked)
    }
  }
} 