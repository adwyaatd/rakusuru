class S3basesController < ApplicationController
	def index
		@shop_datas = S3base.all
  end

	def create
		datas = S3base.scr3

		if !datas.empty?
			datas.each do |data|
				# データベース上にdata[:shop_name]またはdata[:shop_url]があるか検索
				# result = S3base.where(shop_name: data[:shop_name]).or(S3base.where(shop_url: data[:shop_url]))
				# logger.debug( "result:#{result}")

				if S3base.find_by(shop_name: data[:shop_name]) || S3base.find_by(shop_url: data[:shop_url])
					# ある=登録済みなのでデータ更新
					logger.debug( "#{data[:shop_name]}:データ更新")
					d = S3base.find_by(shop_name: data[:shop_name])
					logger.debug( "id:#{d.id}")
					d.update(
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

end
