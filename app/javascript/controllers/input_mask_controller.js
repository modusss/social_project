import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    type: String, // Tipo de máscara: cpf, phone, cep, etc.
    pattern: String // Padrão personalizado (opcional)
  }

  connect() {
    this.element.addEventListener('input', this.applyMask.bind(this))
  }

  disconnect() {
    this.element.removeEventListener('input', this.applyMask.bind(this))
  }

  applyMask(event) {
    const type = this.typeValue
    let value = event.target.value
    
    // Remove todos os caracteres não numéricos
    value = value.replace(/\D/g, '')
    
    switch (type) {
      case 'cpf':
        // Máscara de CPF: 000.000.000-00
        if (value.length <= 11) {
          value = value.replace(/(\d{3})(\d)/, '$1.$2')
          value = value.replace(/(\d{3})(\d)/, '$1.$2')
          value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2')
        }
        break
        
      case 'phone':
        // Máscara de telefone: (00) 00000-0000 ou (00) 0000-0000
        if (value.length <= 11) {
          if (value.length > 10) {
            // Celular com 9 dígitos: (00) 90000-0000
            value = value.replace(/(\d{2})(\d{5})(\d{4})/, '($1) $2-$3')
          } else {
            // Telefone fixo: (00) 0000-0000
            value = value.replace(/(\d{2})(\d{4})(\d{0,4})/, '($1) $2-$3')
          }
        }
        break
        
      case 'cep':
        // Máscara de CEP: 00000-000
        if (value.length <= 8) {
          value = value.replace(/(\d{5})(\d{0,3})/, '$1-$2')
        }
        break
        
      case 'date':
        // Máscara de data: 00/00/0000
        if (value.length <= 8) {
          value = value.replace(/(\d{2})(\d)/, '$1/$2')
          value = value.replace(/(\d{2})(\d)/, '$1/$2')
        }
        break
        
      case 'custom':
        // Usa o padrão personalizado se fornecido
        if (this.hasPatternValue) {
          const pattern = this.patternValue
          const digits = value.split('')
          let result = pattern
          
          // Substitui # por dígitos na ordem
          for (let i = 0; i < digits.length; i++) {
            result = result.replace('#', digits[i])
          }
          
          // Remove # restantes
          result = result.replace(/#/g, '')
          
          value = result
        }
        break
    }
    
    // Atualiza o valor do campo
    event.target.value = value
  }
} 