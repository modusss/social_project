class ChangeCanReadDefaultToTrue < ActiveRecord::Migration[7.2]
  def up
    change_column_default :members, :can_read, from: false, to: true
  end

  def down
    change_column_default :members, :can_read, from: true, to: false
  end
end