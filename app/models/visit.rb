class Visit < ApplicationRecord
  belongs_to :family
  belongs_to :user
  has_many :observations, dependent: :destroy
  has_many :needs, dependent: :destroy
  has_many :pending_needs, dependent: :destroy
  
end
