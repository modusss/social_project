import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener('input', this.handleInput.bind(this))
  }

  handleInput(event) {
    let value = event.target.value.replace(/\D/g, '')
    
    if (value.length <= 10) {
      // Formato: (XX) XXXX-XXXX
      value = value.replace(/^(\d{2})(\d{4})(\d{4}).*/, '($1) $2-$3')
    } else {
      // Formato: (XX) X XXXX-XXXX
      value = value.replace(/^(\d{2})(\d{1})(\d{4})(\d{4}).*/, '($1) $2 $3-$4')
    }
    
    event.target.value = value
  }
}
