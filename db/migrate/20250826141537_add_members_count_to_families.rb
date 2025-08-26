class AddMembersCountToFamilies < ActiveRecord::Migration[7.2]
  def change
    add_column :families, :members_count, :integer, default: 0, null: false
    
    # Populate existing records
    reversible do |dir|
      dir.up do
        Family.reset_column_information
        Family.find_each do |family|
          family.update_column(:members_count, family.members.count)
        end
      end
    end
  end
end
