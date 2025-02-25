import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["ownRadio", "rentedRadio", "financedCheckbox", "financedSection", "financingValueSection", "rentValueSection"]

  connect() {
    this.toggle()
  }

  toggle() {
    const isOwn = this.ownRadioTarget.checked
    const isRented = this.rentedRadioTarget.checked
    
    // Mostrar/esconder seção de casa financiada
    this.financedSectionTarget.classList.toggle("hidden", !isOwn)
    
    // Mostrar/esconder valor do aluguel
    this.rentValueSectionTarget.classList.toggle("hidden", !isRented)
    
    // Verificar se precisa mostrar o valor do financiamento
    this.toggleFinancing()
  }

  toggleFinancing() {
    const isOwn = this.ownRadioTarget.checked
    const isFinanced = this.financedCheckboxTarget.checked
    
    // Mostrar/esconder valor do financiamento
    this.financingValueSectionTarget.classList.toggle("hidden", !(isOwn && isFinanced))
  }
} 