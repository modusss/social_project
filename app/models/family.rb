class Family < ApplicationRecord
    has_many :visits
    has_many :members, dependent: :destroy
    has_many :needs, dependent: :destroy
    accepts_nested_attributes_for :members, reject_if: :all_blank, allow_destroy: true
    accepts_nested_attributes_for :needs, reject_if: :all_blank, allow_destroy: true

    validates :reference_name, presence: true
    validates :phone1, presence: true
end
