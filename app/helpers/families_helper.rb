module FamiliesHelper
  def housing_type_options
    [
      ['Casa própria', 'own'],
      ['Casa alugada', 'rented']
    ]
  end

  def format_housing_status(family)
    status = []
    case family.housing_type
    when 'own'
      status << "Própria"
    when 'rented'
      status << "Alugada"
    end
    status << "Financiada" if family.financed_house
    status.join(" / ")
  end

  def status_label(status)
    case status
    when "recebendo"
      "Recebendo"
    when "lista_de_espera"
      "Lista de Espera"
    when "repescagem"
      "Repescagem"
    when "nao_necessita"
      "Não Necessita"
    else
      status.humanize
    end
  end
  
  def status_badge(status)
    base_class = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    
    case status
    when "recebendo"
      "#{base_class} bg-green-100 text-green-800"
    when "lista_de_espera"
      "#{base_class} bg-yellow-100 text-yellow-800"
    when "repescagem"
      "#{base_class} bg-purple-100 text-purple-800"
    when "nao_necessita"
      "#{base_class} bg-gray-100 text-gray-800"
    else
      "#{base_class} bg-blue-100 text-blue-800"
    end
  end

  def food_basket_status_badge(status)
    return content_tag(:span, "Não definido", class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800") unless status.present?
    
    label = food_basket_status_label(status)
    css_class = case status.to_s
                when "recebendo"
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800"
                when "lista_de_espera"
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800"
                when "repescagem"
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-purple-100 text-purple-800"
                when "nao_necessita"
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800"
                else
                  "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                end
    
    content_tag(:span, label, class: css_class)
  end
  
  def food_basket_status_label(status)
    case status.to_s
    when "recebendo"
      "Recebendo"
    when "lista_de_espera"
      "Lista de Espera"
    when "repescagem"
      "Repescagem"
    when "nao_necessita"
      "Não Necessita"
    else
      status.to_s.humanize
    end
  end
end
