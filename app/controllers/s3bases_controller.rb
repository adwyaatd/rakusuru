class S3basesController < ApplicationController
	def index
		@shop_datas = S3base.where(scraping_id: S3base.maximum(:scraping_id))
  end

	def create
		datas = S3base.scr3(params[:search])

		if !datas.empty?
			datas.each do |data|
				# データベース上にdata[:shop_name]またはdata[:shop_url]があるか検索
				# result = S3base.where(shop_name: data[:shop_name]).or(S3base.where(shop_url: data[:shop_url]))
				# logger.debug( "result:#{result}")
				record1 = S3base.find_by(shop_name: data[:shop_name])
				record2 = S3base.find_by(shop_url: data[:shop_url])

				if record1 || record2
					# ある=登録済みなのでデータ更新
					logger.debug( "#{data[:shop_name]}:データ更新")
					logger.debug( "id:#{d.id}")
					record1.update(
						shop_no: data[:shop_no],
						shop_name: data[:shop_name],
						about_shop: data[:about_shop],
						contact_url: data[:contact_url],
						shop_url: data[:shop_url]
					)
					logger.debug( "更新成功")

				else
					# ない=未登録なので新規登録
					logger.debug( "#{data[:shop_name]}:新規登録")
					S3base.create(
						shop_no: data[:shop_no],
						shop_name: data[:shop_name],
						about_shop: data[:about_shop],
						contact_url: data[:contact_url],
						shop_url: data[:shop_url]
					)
				end
			end # datas.each
			flash[:notice] = "検索成功！"
			logger.debug( "==========================検索成功==========================")
		else
			flash[:notice] = "検索失敗...！"
			logger.debug( "==========================失敗==========================")
		end # !datas.empty?

		redirect_to s3bases_url
	end

	def search
		@shop_datas = S3base.search(params[:search])
		pp "@shop_datas:#{@shop_datas.inspect}"
		if @shop_datas == nil
			flash[:notice] = "検索したキーワードに該当するショップはありませんでした"
		end
		redirect_to s3bases_url
	end

	def bulk_submission
		pp "id:#{params[:ids]}"
		@shops = S3base.where(id:params[:ids])
		@sender_info = S3SenderInfo.last
		pp "sender_info:#{@sender_info.inspect}"

		@shops.each do |s|
			pp "shop_name:#{s.shop_name}"
		end
		result = S3base.bulk_submission(@sender_info,@shops)
		result.each do |r|
			logger.debug( "#{r[:shop_name]}:データ更新")
			s = S3base.find_by(id: r[:id])
			logger.debug( "id:#{r.id}")
			s.update(
				submit_status: r[:submit_status]
			)
			logger.debug( "更新成功")
		end
		redirect_to s3bases_url
	end

end
