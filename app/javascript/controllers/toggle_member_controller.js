import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "status"]

  toggle(event) {
    event.preventDefault()
    
    const memberId = event.target.dataset.memberId
    const familyId = event.target.dataset.familyId
    const checked = event.target.checked

    // Atualiza a UI imediatamente
    this.statusTarget.textContent = checked ? "Sim" : "Não"

    fetch(`/families/${familyId}/members/${memberId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector("[name='csrf-token']").content,
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
      },
      body: JSON.stringify({
        member: {
          firm_in_faith: checked
        }
      })
    })
    .then(response => {
      if (!response.ok) {
        // Reverte apenas se houver erro
        this.checkboxTarget.checked = !checked
        this.statusTarget.textContent = !checked ? "Sim" : "Não"
        throw new Error('Erro na atualização')
      }
      return response.json()
    })
    .catch(error => {
      console.error('Erro:', error)
      // Reverte em caso de erro
      this.checkboxTarget.checked = !checked
      this.statusTarget.textContent = !checked ? "Sim" : "Não"
    })
  }
} 