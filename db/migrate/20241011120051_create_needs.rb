class CreateNeeds < ActiveRecord::Migration[7.2]
  def change
    create_table :needs do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name
      t.string :beneficiary
      t.boolean :attended

      t.timestamps
    end
  end
end
