class UpdateFoodBasketStatusesJob < ApplicationJob
  queue_as :default

  def perform
    # Find all families with food basket information
    Family.where.not(food_basket_start_date: nil)
          .where.not(food_basket_duration_months: nil)
          .find_each do |family|
      family.update_food_basket_status!
    end
    
    # Log completion for monitoring
    Rails.logger.info "Completed updating food basket statuses at #{Time.current}"
  end
end 