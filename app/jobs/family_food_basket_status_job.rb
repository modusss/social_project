# Atualiza o status da cesta básica das famílias diariamente
class FamilyFoodBasketStatusJob
  include Sidekiq::Job

  def perform
    # Busca famílias que estão recebendo e cujo período acabou
    Family.where(food_basket_status: 'recebendo').find_each do |family|
      if family.food_basket_start_date && family.food_basket_duration_months
        end_date = family.food_basket_start_date + family.food_basket_duration_months.months
        if Date.today > end_date
          family.update!(food_basket_status: 'repescagem')
        end
      end
    end
  end
end 