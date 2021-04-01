class CreateS3SenderInfos < ActiveRecord::Migration[6.0]
  def change
    create_table :s3_sender_infos do |t|
      t.string :sender_name
      t.string :tel
      t.string :email
      t.text :title
      t.text :content
      t.integer :user_group_id
      t.integer :disable

      t.timestamps
    end
  end
end
