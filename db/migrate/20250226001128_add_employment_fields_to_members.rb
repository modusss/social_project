class AddEmploymentFieldsToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :profession, :string
    add_column :members, :employed, :boolean, default: false
    add_column :members, :income, :decimal, precision: 10, scale: 2
    add_column :members, :has_benefit, :boolean, default: false
    add_column :members, :benefit_value, :decimal, precision: 10, scale: 2
  end
end