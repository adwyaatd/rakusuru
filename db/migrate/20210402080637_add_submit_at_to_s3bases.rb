class AddSubmitAtToS3bases < ActiveRecord::Migration[6.0]
  def change
    add_column :s3bases, :submit_at, :datetime
  end
end
