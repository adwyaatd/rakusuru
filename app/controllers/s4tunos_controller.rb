class S4tunosController < ApplicationController
	def index
		@gifts_datas = S4tuno.all
  end
end
