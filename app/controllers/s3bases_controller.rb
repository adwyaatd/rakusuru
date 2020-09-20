class S3basesController < ApplicationController
	def index
		@shop_datas = S3base.all
  end

	def create
		datas = S3base.scr3

		datas.each do |data|
			# データベース上にdata[:shop_name]またはdata[:shop_url]があるか検索
			# result = S3base.where(shop_name: data[:shop_name]).or(S3base.where(shop_url: data[:shop_url]))
			# pp "result:#{result}"

			if S3base.find_by(shop_name: data[:shop_name]) || S3base.find_by(shop_url: data[:shop_url])
				# ある=登録済みなのでデータ更新
				pp "#{data[:shop_name]}:データ更新"
				d = S3base.find_by(shop_name: data[:shop_name])
				pp "id:#{d.id}"
				d.update(
					shop_no: data[:shop_no],
					shop_name: data[:shop_name],
					about_shop: data[:about_shop],
					contact_url: data[:contact_url],
					shop_url: data[:shop_url]
				)
				pp "更新成功"

			else
				# ない=未登録なので新規登録
				pp "#{data[:shop_name]}:新規登録"
				d = S3base.new(
					shop_no: data[:shop_no],
					shop_name: data[:shop_name],
					about_shop: data[:about_shop],
					contact_url: data[:contact_url],
					shop_url: data[:shop_url]
				)
				if d.save
					pp "保存成功"
					flash[:notice] = "保存成功"
				else
					pp "失敗"
					flash[:notice] = "失敗"
				end
			end
		end
		redirect_to s3bases_url
	end

	# # 重複データの確認
	# duplicate_shop_names = S3base.group(:shop_name).having('count(*) >= 2').pluck(:shop_name)
	# duplicate_shops = S3base.where(shop_name: duplicate_shop_names)

  # # 重複データの削除
  # hash = S3base.group(:shop_name).having('count(*) >= 2').maximum(:created_at)
  # shop_ids = S3base.where(shop_name: hash.keys, created_at: hash.values).pluck(:id)
  # S3base.where(shop_name: hash.keys).where.not(id: shop_ids).destroy_all

	# private
	# 	def shop_params
	# 		params.require(:s3base).permit(
	# 			shop_no: data[:shop_no],
	# 			shop_name: data[:shop_name],
	# 			contact_url: data[:contact_url],
	# 			shop_url: data[:shop_url]
	# 		)
	# 	end
end
