class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :visits, dependent: :destroy
  
  # Associação para todas as famílias cadastradas por este usuário
  has_many :created_families, class_name: 'Family', foreign_key: 'created_by_user_id'
end
