class S2dmmsController < ApplicationController
	def index
		@img_srcs = S2dmm.all
	end

	def create
		array = S2dmm.scr2

		if !array.empty?
			#空（scr2でエラーだった）ではない
			array.each_with_index do |img_src,n|
				if S2dmm.find_by(image_url: img_src)
					pp "image_url取得済み"
					# d = S2dmm.find_by(image_url: array[:image_src])
					# pp "id:#{d.id}"
					# d.update(
					# 	image_url: array[:image_src]
					# )
				else
					# ない=未登録なので新規登録
					pp "image_url:新規登録"
					l = S2dmm.create(
						name: "レモン#{n}",
						image_url: img_src
					)
				end
			end
			flash[:notice] = "検索成功！"
			pp "==========================検索成功=========================="
		else
			flash[:notice] = "検索失敗...！"
			pp "==========================失敗=========================="
		end

		redirect_to s2dmms_url
	end
end
