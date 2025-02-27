class Member < ApplicationRecord
  belongs_to :family
  
  attr_accessor :index  # Adiciona um atributo virtual que não é salvo no banco de dados

  before_save :update_age_from_birth_date
  before_save :clear_irrelevant_values

  def calculate_age
    return nil if birth_date.nil?
    now = Time.now.utc.to_date
    now.year - birth_date.year - (now.month > birth_date.month || (now.month == birth_date.month && now.day >= birth_date.day) ? 0 : 1)
  end

  private

  def update_age_from_birth_date
    self.age = calculate_age if birth_date_changed?
  end
  
  def clear_irrelevant_values
    # Se não estiver empregado, limpar renda
    self.income = nil unless employed
    
    # Se não possuir benefício, limpar valor do benefício
    self.benefit_value = nil unless has_benefit
  end
end
