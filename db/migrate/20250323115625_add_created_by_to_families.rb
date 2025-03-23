class AddCreatedByToFamilies < ActiveRecord::Migration[7.2]
  def change
    # Adiciona a coluna created_by_user_id à tabela families
    add_reference :families, :created_by_user, foreign_key: { to_table: :users }
  end
end
