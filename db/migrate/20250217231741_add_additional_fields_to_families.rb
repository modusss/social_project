class AddAdditionalFieldsToFamilies < ActiveRecord::Migration[7.2]
  def change
    add_column :families, :neighborhood, :string  # Bairro
    add_column :families, :own_house, :boolean, default: false  # Casa própria
    add_column :families, :financed_house, :boolean, default: false  # Casa financiada
    add_column :families, :financing_value, :decimal, precision: 10, scale: 2  # Valor do financiamento
    add_column :families, :rented_house, :boolean, default: false  # Casa alugada
    add_column :families, :rent_value, :decimal, precision: 10, scale: 2  # Valor do aluguel
    add_column :families, :has_loan, :boolean, default: false  # Tem empréstimo
    add_column :families, :loan_value, :decimal, precision: 10, scale: 2  # Valor do empréstimo
    add_column :families, :food_basket_start_date, :date  # Data início cesta básica
    add_column :families, :food_basket_duration_months, :integer  # Tempo liberado do benefício
    add_column :families, :family_income, :decimal, precision: 10, scale: 2  # Renda familiar
  end
end