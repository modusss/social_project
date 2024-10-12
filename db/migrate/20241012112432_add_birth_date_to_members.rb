class AddBirthDateToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :birth_date, :date
  end
end
