class Family < ApplicationRecord
    include ActionView::Helpers
    include FamiliesHelper

    # Modificação da associação para evitar conflito com helpers
    belongs_to :creator_user, class_name: 'User', foreign_key: 'created_by_user_id', optional: true
    
    has_many :visits, dependent: :destroy
    has_many :members, dependent: :destroy
    has_many :needs, dependent: :destroy
    has_many :observations, through: :visits
    has_many :pending_needs, through: :visits
    
    # Rejeita membros sem nome na criação e marca para exclusão na edição
    accepts_nested_attributes_for :members, 
                                 reject_if: ->(attributes) { attributes['name'].blank? && attributes['id'].blank? }, 
                                 allow_destroy: true
    accepts_nested_attributes_for :needs, reject_if: :all_blank, allow_destroy: true

    before_save :clear_irrelevant_housing_values
    before_save :calculate_total_income
    before_save :mark_empty_name_members_for_destruction
    after_save :update_members_count, :update_total_family_income

    # Define the class method before using it in validation
    def self.valid_food_basket_statuses
        %w[recebendo lista_de_espera repescagem nao_necessita]
    end

    # Campo opcional: permite nil ou vazio. Também normalizamos o valor padrão do BD.
    before_validation :normalize_optional_food_basket
    validates :food_basket_status, inclusion: { in: valid_food_basket_statuses }, allow_nil: true, allow_blank: true

    def last_observation
        observations.order(created_at: :desc).first&.observation
    end

    def recent_pending_needs
        pending_needs.order(created_at: :desc).limit(3)
    end

    def calculate_total_income
        # Soma todas as rendas dos membros
        member_income = members.sum do |member|
            (member.income || 0) + (member.has_benefit ? (member.benefit_value || 0) : 0)
        end
        
        # Atualiza a renda familiar com a soma calculada
        self.family_income = member_income
    end

    def update_food_basket_status!
        today = Date.today
        
        if food_basket_start_date.present? && food_basket_duration_months.present?
            end_date = food_basket_start_date + food_basket_duration_months.months
            
            new_status = if food_basket_start_date <= today && today <= end_date
                           "recebendo"
                         elsif food_basket_start_date > today
                           "lista_de_espera"
                         elsif today > end_date
                           "repescagem"
                         end
            
            # Only update if the status has changed
            update(food_basket_status: new_status) if food_basket_status != new_status
        else
            # If no dates are set and auto-update was requested, mark as "não_receberam"
            update(food_basket_status: "não_receberam") if food_basket_status != "não_receberam"
        end
    end


    # Marca membros com nome vazio para exclusão
    def mark_empty_name_members_for_destruction
        members.each do |member|
            member.mark_for_destruction if member.name.blank?
        end
    end

    def clear_irrelevant_housing_values
        # Se for casa própria, limpar valor do aluguel
        if housing_type == 'own'
            self.rent_value = nil
        end
        
        # Se for casa alugada, limpar valor do financiamento e desmarcar financiada
        if housing_type == 'rented'
            self.financing_value = nil
            self.financed_house = false
        end
        
        # Se não for financiada, limpar valor do financiamento
        if !financed_house
            self.financing_value = nil
        end
    end

    def update_members_count
        update_column(:members_count, members.count) if persisted?
    end

    def update_total_family_income
        total_income = members.sum(:income) || 0.0
        update_column(:total_family_income, total_income) if persisted?
    end

    private

    # Transforma o default do BD ("não_receberam") ou vazio em nil, tornando o campo realmente opcional
    def normalize_optional_food_basket
        self.food_basket_status = nil if food_basket_status.blank? || food_basket_status == "não_receberam"
    end

    def mark_empty_name_members_for_destruction
        members.each do |member|
            if member.name.blank? && member.persisted?
                member.mark_for_destruction
            end
        end
    end

    def calculate_total_income
        # Este método pode ser removido se não estiver sendo usado
        # pois agora usamos o campo total_family_income
    end

    def clear_irrelevant_housing_values
        # Se for casa própria, limpar valor do aluguel
        if housing_type == 'own'
            self.rent_value = nil
        end
        
        # Se for casa alugada, limpar valor do financiamento e desmarcar financiada
        if housing_type == 'rented'
            self.financing_value = nil
            self.financed_house = false
        end
        
        # Se não for financiada, limpar valor do financiamento
        if !financed_house
            self.financing_value = nil
        end
    end

    # Transforma o default do BD ("não_receberam") ou vazio em nil, tornando o campo realmente opcional
    def normalize_optional_food_basket
        self.food_basket_status = nil if food_basket_status.blank? || food_basket_status == "não_receberam"
    end
end
