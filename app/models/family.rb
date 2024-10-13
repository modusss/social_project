class Family < ApplicationRecord
    has_many :visits, dependent: :destroy
    has_many :members, dependent: :destroy
    has_many :needs, dependent: :destroy
    has_many :observations, through: :visits
    has_many :pending_needs, through: :visits
    accepts_nested_attributes_for :members, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :needs, reject_if: :all_blank, allow_destroy: true

    def last_observation
        observations.order(created_at: :desc).first&.observation
    end

    def recent_pending_needs
        pending_needs.order(created_at: :desc).limit(3)
    end
end
