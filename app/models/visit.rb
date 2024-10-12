class Visit < ApplicationRecord
  belongs_to :family
  belongs_to :user
  has_many :observations, dependent: :destroy
  has_many :pending_needs, dependent: :destroy
  
  accepts_nested_attributes_for :family
  accepts_nested_attributes_for :observations, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :pending_needs, reject_if: :all_blank, allow_destroy: true

  validates :visit_date, presence: true
  validates :user_id, presence: true
end
