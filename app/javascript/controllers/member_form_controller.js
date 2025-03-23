// Controlador para o formulário de membros
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["roleRadio", "genderField"]

  connect() {
    // Adicionar classe para indicar que o controlador está conectado
    this.element.classList.add('member-form-connected');
    
    // Inicializa o estado dos campos de sexo baseado nos valores atuais
    this.updateGenderFieldVisibility();
    
    // Adiciona event listeners aos radio buttons
    const radios = this.element.querySelectorAll('.role-radio');
    radios.forEach(radio => {
      radio.addEventListener('change', this.updateGenderFieldVisibility.bind(this));
    });
  }

  updateGenderFieldVisibility() {
    // Obtém o ID ou índice do membro do formulário
    const formId = this.element.querySelector('input[type="radio"][name*="[role]"]')?.name.match(/\[(\d+)\]/);
    const memberIndex = formId ? formId[1] : 'new';
    
    // Encontra o radio button selecionado
    const selectedRole = this.element.querySelector('.role-radio:checked');
    
    // Localiza o campo de gênero dentro do mesmo container
    const genderField = this.element.querySelector('[id^="gender-field"]');
    
    // Verifica se o elemento existe antes de modificá-lo
    if (genderField) {
      if (selectedRole && selectedRole.classList.contains('gender-neutral')) {
        // Mostrar campo de sexo para papéis que não determinam gênero
        genderField.classList.remove('hidden');
      } else {
        // Esconder campo de sexo para papéis que determinam gênero
        genderField.classList.add('hidden');
      }
    }
  }
} 