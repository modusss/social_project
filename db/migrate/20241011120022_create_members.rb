class CreateMembers < ActiveRecord::Migration[7.2]
  def change
    create_table :members do |t|
      t.references :family, null: false, foreign_key: true
      t.string :name
      t.integer :age
      t.string :role
      t.boolean :firm_in_faith

      t.timestamps
    end
  end
end
