class S1SwitchesController < ApplicationController

	def index
		@price = S1Switch.last
	end

	def create
		price = S1Switch.scr1
		price = S1Switch.new(price: price)
		if price.save
			flash[:notice] = "スクレイピング成功"
			redirect_to s1_switches_url
		else
			render :index
		end
	end
end
