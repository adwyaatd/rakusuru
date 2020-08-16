class S2dmmsController < ApplicationController
	def index
		@img_srcs = S2dmm.last(10)
	end

	def create
		array = S2dmm.scr2

		n = 1
		array.each do |img_src|

			l = S2dmm.new(
				name: "レモン#{n}",
				image_url: img_src
			)

			l.save
			n += 1
			# if n==11
			# 	break
			# end
		end
		flash[:notice] = "検索成功"
		redirect_to s2dmms_url
	end
end
