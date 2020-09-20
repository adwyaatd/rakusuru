class AddShopnoToS3bases < ActiveRecord::Migration[6.0]
  def change
    add_column :s3bases, :shop_no, :integer
    add_column :s3bases, :shop_url, :text
  end
end
