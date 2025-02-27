class AddAdditionalFieldsToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :can_read, :boolean, default: false
    add_column :members, :lives_in_house, :boolean, default: true
    add_column :members, :lives_with_partner, :boolean, default: false
    add_column :members, :cpf, :string
  end
end