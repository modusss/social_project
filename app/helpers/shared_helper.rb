module SharedHelper
  def path_with_params(**new_params)
    if current_page?(families_path)
      families_path(new_params)
    elsif current_page?(visits_path)
      visits_path(new_params)
    else
      # Fallback based on controller
      case controller_name
      when 'families'
        families_path(new_params)
      when 'visits'
        visits_path(new_params)
      else
        families_path(new_params)
      end
    end
  end

  def search_url_for_context
    case controller_name
    when 'families'
      search_families_path
    when 'visits'
      search_visits_path
    else
      search_families_path
    end
  end

  def search_type_for_context
    case controller_name
    when 'families'
      'famílias'
    when 'visits'
      'visitas'
    else
      'famílias'
    end
  end
end
