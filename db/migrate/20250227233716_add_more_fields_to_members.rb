class AddMoreFieldsToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :attends_church, :boolean, default: false
    add_column :members, :has_disability, :boolean, default: false
    add_column :members, :clothing_size, :string
    add_column :members, :shoe_size, :string
  end
end