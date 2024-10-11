class CreatePendingNeeds < ActiveRecord::Migration[7.2]
  def change
    create_table :pending_needs do |t|
      t.references :visit, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
