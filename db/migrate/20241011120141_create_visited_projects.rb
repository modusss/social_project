class CreateVisitedProjects < ActiveRecord::Migration[7.2]
  def change
    create_table :visited_projects do |t|
      t.references :visit, null: false, foreign_key: true
      t.references :project, null: false, foreign_key: true
      t.references :region, null: false, foreign_key: true

      t.timestamps
    end
  end
end
