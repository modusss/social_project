class AddFoodBasketStatusToFamilies < ActiveRecord::Migration[7.2]
  def change
    add_column :families, :food_basket_status, :string, default: "não_receberam"
    add_index :families, :food_basket_status
  end
end
