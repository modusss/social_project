class CreateObservations < ActiveRecord::Migration[7.2]
  def change
    create_table :observations do |t|
      t.references :visit, null: false, foreign_key: true
      t.text :observation

      t.timestamps
    end
  end
end
