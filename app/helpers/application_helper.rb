module ApplicationHelper
  def flash_message
    return unless flash[:notice] || flash[:alert]

    message = flash[:notice] || flash[:alert]
    content_tag(:p, message, class: "py-2 px-3 bg-green-50 mb-5 text-green-500 font-medium rounded-lg inline-block", id: "flash-message")
  end

  def whatsapp_link(phone_number)
    return '' if phone_number.blank?
    
    # Remove caracteres não numéricos
    formatted_number = phone_number.gsub(/[^\d]/, '')
    # Adiciona o código do país (55 para Brasil) se não existir
    formatted_number = "55#{formatted_number}" unless formatted_number.start_with?('55')
    
    link_to(phone_number, 
           "https://wa.me/#{formatted_number}", 
           target: '_blank',
           class: "text-blue-600 hover:text-blue-800 hover:underline transition duration-300 ease-in-out",
           title: "Abrir WhatsApp")
  end

  def phone_links(phone_number)
    return '' if phone_number.blank?
    
    # Remove caracteres não numéricos
    formatted_number = phone_number.gsub(/[^\d]/, '')
    # Adiciona o código do país (55 para Brasil) se não existir
    formatted_number = "55#{formatted_number}" unless formatted_number.start_with?('55')
    
    links = []
    
    # Link para ligação
    links << link_to(
      raw('<i class="fas fa-phone text-green-600"></i>'),
      "tel:+#{formatted_number}",
      class: "mr-2 hover:text-green-800",
      title: "Ligar"
    )

    # Link para WhatsApp
    links << link_to(
      raw('<i class="fab fa-whatsapp text-green-600"></i>'),
      "https://wa.me/#{formatted_number}",
      target: '_blank',
      class: "hover:text-green-800",
      title: "Abrir WhatsApp"
    )

    # Número do telefone
    links << content_tag(:span, phone_number, class: "ml-2 text-gray-600")

    safe_join(links, ' ')
  end
end
