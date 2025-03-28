class Project < ApplicationRecord
    has_many :visited_projects, dependent: :destroy
    has_many :visits, through: :visited_projects
    has_many :families, through: :visits
end
