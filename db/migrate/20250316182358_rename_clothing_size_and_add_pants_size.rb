class RenameClothingSizeAndAddPantsSize < ActiveRecord::Migration[7.2]
  def change
    # Renomear clothing_size para shirt_size
    rename_column :members, :clothing_size, :shirt_size
    
    # Adicionar campo pants_size (numérico)
    add_column :members, :pants_size, :integer
  end
end