class CreateFamilies < ActiveRecord::Migration[7.2]
  def change
    create_table :families do |t|
      t.string :reference_name
      t.string :street
      t.string :house_number
      t.string :city
      t.string :state
      t.string :phone1
      t.string :phone2

      t.timestamps
    end
  end
end
