class AddMunicipalitiesToS4tunos < ActiveRecord::Migration[6.0]
  def change
    add_column :s4tunos, :municipalites, :string
  end
end
