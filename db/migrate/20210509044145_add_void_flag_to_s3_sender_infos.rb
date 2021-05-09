class AddVoidFlagToS3SenderInfos < ActiveRecord::Migration[6.1]
  def change
    add_column :s3_sender_infos, :void_flag, :integer, default: 1
  end
end
