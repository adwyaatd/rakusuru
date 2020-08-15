class ChangeDataPriceS1Switches < ActiveRecord::Migration[6.0]
	def change
		change_column :s1_switches, :price, :string
  end
end
