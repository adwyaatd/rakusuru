class ChangeDateImageUrlToS2dmms < ActiveRecord::Migration[6.0]
	def change
		change_column :s2dmms, :image_url, :text
  end
end
