import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input", "results", "familyForm" ]

  search() {
    const query = this.inputTarget.value
    fetch(`/families/search?query=${query}`)
      .then(response => response.json())
      .then(data => {
        this.resultsTarget.innerHTML = this.buildResultsHtml(data)
        this.resultsTarget.style.display = 'block'
      })
  }

  selectFamily(event) {
    const familyId = event.target.value
    // Preencher os campos do formulário com os dados da família selecionada
    // Você precisará implementar esta lógica com base na estrutura dos seus dados
  }

  showNewFamilyForm() {
    this.familyFormTarget.style.display = 'block'
  }

  buildResultsHtml(families) {
    return families.map(family => `
      <div>
        <input type="radio" name="family_id" value="${family.id}" onchange="this.selectFamily(event)">
        ${family.reference_name}
      </div>
    `).join('')
  }
}