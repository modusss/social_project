import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

  connect() {
    console.log("Controlador member-numbering conectado")
    // Atualizar números iniciais quando o controlador conecta
    setTimeout(() => this.updateNumbers(), 100)
    // Mostrar campos personalizados se "outros" estiver selecionado
    setTimeout(() => this.initializeCustomRoleFields(), 100)
  }

  // Inicializar campos personalizados para membros existentes
  initializeCustomRoleFields() {
    const memberContainers = document.querySelectorAll('[data-member-container]')
    memberContainers.forEach(container => {
      const outrosRadio = container.querySelector('input[type="radio"][value="outros"]')
      if (outrosRadio && outrosRadio.checked) {
        const customRoleField = container.querySelector('.custom-role-field')
        if (customRoleField) {
          customRoleField.style.display = 'block'
        }
      }
    })
  }
  
  // Método chamado quando um novo membro é adicionado
  memberAdded(event) {
    console.log("Membro adicionado")
    setTimeout(() => this.updateNumbers(), 100)
  }
  
  // Método chamado quando um membro é removido
  memberRemoved(event) {
    console.log("Membro removido")
    setTimeout(() => this.updateNumbers(), 100)
  }
  
  // Método para atualizar os números quando o formulário é carregado
  updateNumbers() {
    console.log("Atualizando números dos membros")
    
    // Selecionar todos os contêineres de membros
    const memberContainers = document.querySelectorAll('[data-member-container]')
    console.log(`Encontrados ${memberContainers.length} membros`)
    
    // Atualizar os números
    memberContainers.forEach((container, index) => {
      const numberElement = container.querySelector('.member-number')
      if (numberElement) {
        numberElement.textContent = index + 1
        console.log(`Membro ${index + 1} atualizado: ${numberElement.textContent}`)
      } else {
        console.log(`Elemento .member-number não encontrado para o membro ${index + 1}`)
      }
    })
  }

  // Mostrar campo de papel personalizado
  showCustomRole(event) {
    const memberCard = event.target.closest('[data-member-container]')
    if (memberCard) {
      const customRoleField = memberCard.querySelector('.custom-role-field')
      if (customRoleField) {
        customRoleField.style.display = 'block'
      }
    }
  }

  // Ocultar campo de papel personalizado
  hideCustomRole(event) {
    const memberCard = event.target.closest('[data-member-container]')
    if (memberCard) {
      const customRoleField = memberCard.querySelector('.custom-role-field')
      if (customRoleField) {
        customRoleField.style.display = 'none'
        // Limpar o valor do campo quando oculto
        const customRoleInput = customRoleField.querySelector('input[type="text"]')
        if (customRoleInput) {
          customRoleInput.value = ''
        }
      }
    }
  }
} 