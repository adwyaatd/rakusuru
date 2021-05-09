class ChangeIsActiveDefaultOnS3SenderInfos < ActiveRecord::Migration[6.1]
  def change
		change_column_default :s3_sender_infos, :is_active, from: 1, to: 0
  end
end
