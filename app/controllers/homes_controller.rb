class HomesController < ApplicationController
	# require	"selenium-webdriver"
	# require 'pry'

	def top
	end

	def foo
		"テスト"
	end

	def scr2

	end


	def scr
		d = Selenium::WebDriver.for :chrome

		# switch_price

		d.navigate.to 'https://kakaku.com/game/game-console/itemlist.aspx?pdf_se=16'

		@content = d.find_element(:xpath,'//*[@id="main"]/div[2]/div[1]/div/table/tbody/tr[2]/td[1]')
		@text=@content.text
		@test="テスト"
		# pp @content.text

		# sleep(10)
		d.quit
	end
end
