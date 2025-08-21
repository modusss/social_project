class RemoveLivesWithPartnerFromMembers < ActiveRecord::Migration[7.2]
  def change
    remove_column :members, :lives_with_partner, :boolean
  end
end
