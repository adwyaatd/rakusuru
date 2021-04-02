class RemoveShopNoFromS3bases < ActiveRecord::Migration[6.0]
  def change
    remove_column :s3bases, :shop_no, :integer
  end
end
