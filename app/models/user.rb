class User < ApplicationRecord
    has_many :visits, dependent: :destroy
end
