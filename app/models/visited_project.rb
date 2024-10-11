class VisitedProject < ApplicationRecord
  belongs_to :visit
  belongs_to :project
  belongs_to :region
end
