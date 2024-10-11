class Project < ApplicationRecord
    has_many :visited_projects, dependent: :destroy
end
