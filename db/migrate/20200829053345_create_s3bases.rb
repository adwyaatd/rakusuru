class CreateS3bases < ActiveRecord::Migration[6.0]
  def change
    create_table :s3bases do |t|
      t.string :shop_name
      t.text :contact_url

      t.timestamps
    end
  end
end
