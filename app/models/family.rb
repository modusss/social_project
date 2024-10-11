class Family < ApplicationRecord
    has_many :members, dependent: :destroy
    has_many :needs, dependent: :destroy
    has_many :visits, dependent: :destroy
end
