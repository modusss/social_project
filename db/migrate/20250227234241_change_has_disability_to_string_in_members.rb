class ChangeHasDisabilityToStringInMembers < ActiveRecord::Migration[7.2]
  def up
    # Primeiro, renomeamos a coluna para evitar conflitos
    rename_column :members, :has_disability, :has_disability_old
    
    # Adicionamos a nova coluna como string
    add_column :members, :disability, :string
    
    # Copiamos os dados (convertendo boolean para string)
    execute <<-SQL
      UPDATE members 
      SET disability = CASE WHEN has_disability_old = true THEN 'Sim' ELSE NULL END
    SQL
    
    # Removemos a coluna antiga
    remove_column :members, :has_disability_old
  end

  def down
    # Primeiro, renomeamos a coluna para evitar conflitos
    add_column :members, :has_disability, :boolean, default: false
    
    # Copiamos os dados (convertendo string para boolean)
    execute <<-SQL
      UPDATE members 
      SET has_disability = CASE WHEN disability IS NOT NULL AND disability != '' THEN true ELSE false END
    SQL
    
    # Removemos a coluna antiga
    remove_column :members, :disability
  end
end