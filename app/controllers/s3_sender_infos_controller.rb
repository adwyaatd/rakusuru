class S3SenderInfosController < ApplicationController
  def index
		@sender_info = S3SenderInfo.new
		@sender_infos = S3SenderInfo.where(
			disable:0,
		)
  end

	def create
		sender_info = S3SenderInfo.new(
			sender_name: params[:s3_sender_info][:sender_name],
			tel: params[:s3_sender_info][:tel],
			email: params[:s3_sender_info][:email],
			title: params[:s3_sender_info][:title],
			content: params[:s3_sender_info][:content],
			disable:0
		)
		pp sender_info
		if sender_info.save
			flash[:notice] = "登録完了"
		else
			flash[:notice] = "登録出来ません"
		end
		redirect_to s3_sender_infos_path
	end
end
