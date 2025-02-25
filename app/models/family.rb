class Family < ApplicationRecord
    include ActionView::Helpers
    include FamiliesHelper

    has_many :visits, dependent: :destroy
    has_many :members, dependent: :destroy
    has_many :needs, dependent: :destroy
    has_many :observations, through: :visits
    has_many :pending_needs, through: :visits
    accepts_nested_attributes_for :members, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :needs, reject_if: :all_blank, allow_destroy: true

    before_save :clear_irrelevant_housing_values

    def last_observation
        observations.order(created_at: :desc).first&.observation
    end

    def recent_pending_needs
        pending_needs.order(created_at: :desc).limit(3)
    end

    private

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
end
