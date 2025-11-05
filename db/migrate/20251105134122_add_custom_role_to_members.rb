class AddCustomRoleToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :custom_role, :string
  end
end
