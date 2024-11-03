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
end
