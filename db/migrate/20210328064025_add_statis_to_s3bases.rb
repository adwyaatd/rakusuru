class AddStatisToS3bases < ActiveRecord::Migration[6.0]
  def change
    add_column :s3bases, :scraping_id, :integer
    add_column :s3bases, :submit_status, :integer
    add_column :s3bases, :disable, :integer
  end
end
