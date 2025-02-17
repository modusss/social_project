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
end
