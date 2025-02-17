class UpdateHousingFieldsInFamilies < ActiveRecord::Migration[7.2]
  def up
    # Adiciona o novo campo
    add_column :families, :housing_type, :string

    # Migra os dados existentes
    Family.find_each do |family|
      if family.own_house
        family.update_column(:housing_type, 'own')
      elsif family.rented_house
        family.update_column(:housing_type, 'rented')
      end
    end

    # Remove os campos antigos
    remove_column :families, :own_house
    remove_column :families, :rented_house
  end

  def down
    # Adiciona os campos antigos de volta
    add_column :families, :own_house, :boolean, default: false
    add_column :families, :rented_house, :boolean, default: false

    # Migra os dados de volta
    Family.find_each do |family|
      case family.housing_type
      when 'own'
        family.update_columns(own_house: true, rented_house: false)
      when 'rented'
        family.update_columns(own_house: false, rented_house: true)
      end
    end

    # Remove o novo campo
    remove_column :families, :housing_type
  end
end