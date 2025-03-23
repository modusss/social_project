class Member < ApplicationRecord
  belongs_to :family
  
  attr_accessor :index  # Adiciona um atributo virtual que não é salvo no banco de dados

  validates :name, presence: true

  before_save :update_age_from_birth_date
  before_save :clear_irrelevant_values
  before_save :set_gender_from_role

  # Mapeamento de papéis para gêneros
  ROLE_GENDER_MAPPING = {
    "pai" => "masculino",
    "marido" => "masculino",
    "filho" => "masculino",
    "mãe" => "feminino",
    "esposa" => "feminino",
    "filha" => "feminino",
    "acompanhante" => nil,
    "paciente" => nil,
    "" => nil
  }

  # Override do método role= para atualizar gender quando role é alterado
  def role=(new_role)
    write_attribute(:role, new_role)
    if ROLE_GENDER_MAPPING.key?(new_role) && ROLE_GENDER_MAPPING[new_role].present?
      write_attribute(:gender, ROLE_GENDER_MAPPING[new_role])
    end
  end

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

  # Define o gênero baseado no papel familiar se não for explicitamente definido
  def set_gender_from_role
    if role.present? && ROLE_GENDER_MAPPING.key?(role) && ROLE_GENDER_MAPPING[role].present?
      self.gender = ROLE_GENDER_MAPPING[role]
    end
  end
end
