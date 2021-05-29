class S3basesController < ApplicationController

	def index
	end

	def collect
		@collect_records = CollectHistory.all
	end

	def submit
		redirect_to new_s3_sender_info_path,notice: "問い合わせテンプレートを登録しましょう" unless S3SenderInfo.where(disable: 0).exists?

		if params[:search]
			@shop_datas = S3base.where(
				"(about_shop LIKE ?) OR (shop_name LIKE ?)",
				"%#{params[:search]}%","%#{params[:search]}%"
			)
			if @shop_datas.empty?
				flash[:notice] = "検索したキーワードに該当するショップはありませんでした"
			end
		elsif params[:id] == "all"
			@shop_datas = S3base.where(disable: 0)
		elsif params[:scraping_id] == "last"
			@shop_datas = S3base.where(
				scraping_id: S3base.maximum(:scraping_id),
				disable: 0
			)
		elsif params[:scraping_id]
			@shop_datas = S3base.where(
				scraping_id: params[:scraping_id],
				disable: 0
			)
		elsif params[:submit_status] == "0"
			@shop_datas = S3base.where(
				submit_status: 0,
				disable: 0
			)
		elsif params[:submit_status] == "1"
			@shop_datas = S3base.where(
				submit_status: 1,
				disable: 0
			)
		else
			@shop_datas = S3base.where(
				scraping_id: S3base.maximum(:scraping_id),
				disable: 0
			)
		end

		@active_sender_info = S3SenderInfo.find_by(
			disable:0,
			is_active:1
		)
  end

	def create
		start_time = Time.now
		result_datas = S3base.scr3(params[:search])
		pp "ーーーーーーーーーーーーーーーーー処理時間 #{Time.now - start_time}s"
		scraping_id = S3base.maximum(:scraping_id)+1

		existing_shop_count = 0
		new_shop_count = 0
		updated_shop_count = 0

		if !result_datas.empty?
			begin
				result_datas.each do |data|
					# データベース上に合致するデータがあるか検索
					record = S3base.where(
						"(shop_name LIKE ?) OR (shop_url LIKE ?) OR (contact_url LIKE ?)",
						"%#{data[:shop_name]}%","%#{data[:shop_url]}%","%#{data[:contact_url]}%"
					)

					record2 = S3base.find_by(
						shop_name: data[:shop_name],
						shop_url:data[:shop_url],
						contact_url: data[:contact_url]
					)

					if record.first == record2 # 登録データと完全一致なら何もしない
						existing_shop_count += 1
						logger.debug( "#{data[:shop_name]}:登録済み")
						next
					elsif record.empty? # ない=未登録なので新規登録
						logger.debug( "#{data[:shop_name]}:新規登録")
						S3base.create(
							shop_name: data[:shop_name],
							about_shop: data[:about_shop],
							contact_url: data[:contact_url],
							shop_url: data[:shop_url],
							scraping_id: scraping_id,
							disable: 0,
							submit_status: 0
						)
						new_shop_count += 1
					else #一部変更箇所があるので更新
						logger.debug( "#{data[:shop_name]}:データ更新")
						record.first.update(
							shop_name: data[:shop_name],
							about_shop: data[:about_shop],
							contact_url: data[:contact_url],
							shop_url: data[:shop_url]
						)
						updated_shop_count += 1
					end
				end # result_datas.each
			rescue => e
				logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
			else
				flash[:notice] = "取得成功！取得ショップ数 新規:#{new_shop_count}件/更新:#{updated_shop_count}件/既存:#{existing_shop_count}件"
				logger.debug( "==========================取得成功==========================")
			end
		else
			flash[:notice] = "取得失敗...！"
			logger.debug( "==========================失敗==========================")
		end # !result_datas.empty?

		redirect_to s3bases_url
	end

	def invoke_base_scraping_lambda
		scraping_id = (S3base.maximum(:scraping_id)+1).to_s
		site_domains = ["thebase.in","base.shop","base.ec","theshop.jp","buyshop.jp"]
		queue_name = "scr-queue.fifo"
		begin
			site_domains.each_with_index do |site_domain,i|
				sqs_message_json = {search_word: "#{params[:search_word]}",domain: "#{site_domain}",scraping_id: "#{scraping_id}"}.to_json
				Sqs.send_message(queue_name,sqs_message_json,i)
			end
		rescue => e
			logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
			flash[:notice] = "システムエラーです"
		else
			flash[:notice] = "スクレイピング実行中です。少々お待ち下さい。"
		end
		redirect_to collect_s3bases_url
	end

	def confirm
		@shops = S3base.where(id: params[:s3base][:shop_ids]).where(submit_status: 0)
		@shop_ids =  @shops.pluck(:id)
		@sender_info = S3SenderInfo.find_by(id: params[:s3base][:sender_info_id])
	end

	def invoke_bulk_submission_lambda
		if params[:back]
			pp "戻る"
			redirect_to submit_s3bases_url
			return
		elsif params[:shop_ids] && params[:sender_info_id]
			shops_info_array = []
			queue_name = "scr-queue.fifo"

			pluck_columns1 = [:id,:shop_name, :contact_url,:submit_status]
			S3base.where(id: params[:shop_ids]).where(submit_status: 0).pluck(*pluck_columns1).map do |b|
				one_shop_info_hash = pluck_columns1.zip(b).to_h
				shops_info_array.push(one_shop_info_hash)
			end

			pp shops_info_array

			shops_info_array.each do |s|
				pp s[:id]
				pp "shop_name:#{s[:shop_name]}"
				pp "contact_url:#{s[:contact_url]}"
				pp s[:submit_status]
			end

			if shops_info_array.empty?
				flash[:notice] = "未問い合わせのショップがありません"
				redirect_to s3bases_url
				return
			end

			pluck_columns2 = [:sender_name,:tel,:email,:title,:content]
			sender_info_array = S3SenderInfo.where("(id = ?) AND (disable = ?)", params[:sender_info_id],0).pluck(*pluck_columns2)
				# [["細田 来夢","09035380252","adwyaatd0601@gmail.com","ご提案","お世話になります。\r\n" + "株式会社HRの細田と申します。\r\n" + "\r\n" + "以下、本文"]]
			sender_info_hash = pluck_columns2.zip(sender_info_array[0]).to_h
				#{:sender_name=>"細田 来夢",:tel=>"09035380252",:email=>"adwyaatd0601@gmail.com",:title=>"ご提案",:content=>"お世話になります。\r\n" + "株式会社HRの細田と申します。\r\n" + "\r\n" + "以下、本文"}

			sqs_message_json = {shops_info_array: shops_info_array,sender_info_hash: sender_info_hash}.to_json
				#jsonの内容は"/storage/bulk_submission_sqs_example.rb"参照
			queue_name = "bulk_submission.fifo"

			begin
				if Rails.env.development? || Rails.env.test?
					# Sqs.send_message(queue_name,sqs_message_json) #ローカル環境では原則submitをしない
				else
					Sqs.send_message(queue_name,sqs_message_json)
				end
				pp "Success! send_message to SQS"
			rescue => e
				logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
				flash[:notice] = "システムエラーです"
			else
				flash[:notice] = "一括問い合わせ実行中です。少々お待ち下さい。"
			end

			redirect_to s3bases_url
		else
			pp "shop_idsとsender_info_idなし"
			pp "params:#{params}"
			redirect_to s3bases_url
		end
	rescue => e
		logger.error("----------------------[error]invoke_bulk_submission_lambda,error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
		redirect_to s3bases_url,notice: "エラーが発生しました"
	end

	def bulk_submission
		@shops = S3base.where(shop_name:params[:shop_name])
		@sender_info = S3SenderInfo.where("(is_active = ?) AND (id = ?)", 1,params[:sender_info_id])

		submitted_shop_id_array = S3base.bulk_submission(@sender_info,@shops)

		if !submitted_shop_id_array.empty?
			submitted_shops = S3base.where(id: submitted_shop_id_array)
			logger.debug( "submitted_shop_id_array:#{submitted_shop_id_array}")
			submitted_shops.update(
				submit_status: 1,
				submit_at: DateTime.current
			)
			logger.debug( "更新成功")
		else
			redirect_to s3bases_url,notice: "submit失敗"
			return
		end
		redirect_to s3bases_url,notice: "問い合わせ完了しました"
	end

	# private
	# 	pp __LINE__
	# 	params.require(:s3base).permit()
	# end

end
