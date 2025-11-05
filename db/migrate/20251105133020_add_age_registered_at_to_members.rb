class AddAgeRegisteredAtToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :age_registered_at, :date
  end
end
