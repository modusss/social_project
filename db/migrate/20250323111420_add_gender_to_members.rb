class AddGenderToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :gender, :string
    add_index :members, :gender
  end
end
