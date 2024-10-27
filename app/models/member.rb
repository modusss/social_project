class Member < ApplicationRecord
  belongs_to :family

  before_save :update_age_from_birth_date

  def calculate_age
    return nil if birth_date.nil?
    now = Time.now.utc.to_date
    now.year - birth_date.year - (now.month > birth_date.month || (now.month == birth_date.month && now.day >= birth_date.day) ? 0 : 1)
  end

  private

  def update_age_from_birth_date
    self.age = calculate_age if birth_date_changed?
  end
end
