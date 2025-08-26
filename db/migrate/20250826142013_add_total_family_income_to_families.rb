class AddTotalFamilyIncomeToFamilies < ActiveRecord::Migration[7.2]
  def change
    add_column :families, :total_family_income, :decimal, precision: 10, scale: 2, default: 0.0, null: false
    
    # Populate existing records with calculated total family income
    reversible do |dir|
      dir.up do
        Family.find_each do |family|
          total_income = family.members.sum(:income) || 0.0
          family.update_column(:total_family_income, total_income)
        end
      end
    end
  end
end
