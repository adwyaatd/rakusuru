class S3SenderInfosController < ApplicationController
  def index
		@active_sender_info = S3SenderInfo.where(
			disable:0,
			is_active:1
		)
		@sender_infos = S3SenderInfo.where(
			disable:0,
			is_active:0
		)
  end

	def new
		@sender_info = S3SenderInfo.new
	end

	def create
		pp "sender_info_params:#{sender_info_params}"
		sender_info = S3SenderInfo.new(sender_info_params)
		if sender_info.save
			redirect_to s3_sender_infos_url,notice: "作成完了"
		else
			flash[:notice] = "作成出来ませんでした"
			redner :new
		end
	end

	def edit
		@sender_info =S3SenderInfo.find_by(id: params[:id])
	end

	def update
		sender_info = S3SenderInfo.find_by(id: params[:id])
		sender_info.update(sender_info_params)
		if sender_info.save
     	redirect_to s3_sender_infos_url,notice: "編集しました"
		else
			render :edit
		end
	end

	def activate
		pp "入った！！！！！！！！！！！！"
		pp params
		activated_sender_info = S3SenderInfo.find_by(is_active: 1)
		activated_sender_info.update(
			is_active: 0
		)
		sender_info = S3SenderInfo.find_by(id: params[:id])
		sender_info.update(
			is_active: 1
		)
		if sender_info.save || activated_sender_info.save
     	redirect_to s3_sender_infos_url,notice: "有効にしました"
		else
			render :index
		end
	end

	private
	def sender_info_params
    params.require(:s3_sender_info).permit(:sender_name,:tel,:email,:title,:content,:disable,:is_active)
  end
end
