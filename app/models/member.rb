class Member < ApplicationRecord
  belongs_to :family
  
  attr_accessor :index  # Adiciona um atributo virtual que não é salvo no banco de dados

  validates :name, presence: true

  before_save :update_age_from_birth_date
  before_save :handle_age_without_birth_date
  before_save :clear_irrelevant_values
  before_save :set_gender_from_role
  after_save :update_family_totals
  after_destroy :update_family_totals

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
    now = Time.now.utc.to_date
    
    # Se tiver data de nascimento, calcular idade baseada nela
    if birth_date.present?
      return now.year - birth_date.year - (now.month > birth_date.month || (now.month == birth_date.month && now.day >= birth_date.day) ? 0 : 1)
    end
    
    # Se não tiver data de nascimento mas tiver idade registrada e data de registro
    if age.present? && age_registered_at.present?
      years_passed = now.year - age_registered_at.year - 
                     (now.month > age_registered_at.month || 
                      (now.month == age_registered_at.month && now.day >= age_registered_at.day) ? 0 : 1)
      return age + years_passed
    end
    
    # Se tiver apenas idade sem data de registro, retornar a idade armazenada
    age
  end

  private

  def update_age_from_birth_date
    # Se tiver data de nascimento, calcular idade e limpar age_registered_at
    if birth_date.present?
      self.age = calculate_age if birth_date_changed?
      self.age_registered_at = nil # Limpar data de registro se tiver data de nascimento
    end
  end

  def handle_age_without_birth_date
    # Se idade foi informada mas não há data de nascimento
    if age.present? && birth_date.blank?
      # Registrar a data atual se ainda não foi registrada ou se a idade mudou
      if age_registered_at.blank? || age_changed?
        self.age_registered_at = Date.current
      end
    end
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

  # Atualiza os totais da família quando um membro é alterado
  def update_family_totals
    family.update_members_count
    family.update_total_family_income
  end
end
