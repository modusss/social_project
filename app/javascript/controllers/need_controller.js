import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleCheckbox(event) {
    // Não dispara se o clique foi diretamente no checkbox
    if (event.target.type !== 'checkbox') {
      const checkbox = event.currentTarget.querySelector('input[type="checkbox"]')
      checkbox.checked = !checkbox.checked
      checkbox.dispatchEvent(new Event('change'))
    }
  }

  updateBeneficiaries(event) {
    const checkboxes = event.target.closest('.my-5').querySelectorAll('input[type="checkbox"]')
    const hiddenField = event.target.closest('.my-5').querySelector('input[type="hidden"]')
    
    const selectedNames = Array.from(checkboxes)
      .filter(cb => cb.checked)
      .map(cb => cb.value)
    
    hiddenField.value = selectedNames.join(', ')
  }
} 