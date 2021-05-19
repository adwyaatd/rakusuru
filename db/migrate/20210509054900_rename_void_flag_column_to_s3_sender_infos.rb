class RenameVoidFlagColumnToS3SenderInfos < ActiveRecord::Migration[6.1]
  def change
		rename_column :s3_sender_infos, :void_flag, :is_active
  end
end
