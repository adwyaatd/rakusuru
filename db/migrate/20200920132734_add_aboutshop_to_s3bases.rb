class AddAboutshopToS3bases < ActiveRecord::Migration[6.0]
  def change
    add_column :s3bases, :about_shop, :text
  end
end
