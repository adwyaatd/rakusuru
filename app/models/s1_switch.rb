class S1Switch < ApplicationRecord
	def self.scr1
		if Rails.env.development? || Rails.env.test?
			logger.debug( "通常モード")
			d = Selenium::WebDriver.for :chrome
		else
			logger.debug( "headlessモード")
			options = Selenium::WebDriver::Chrome::Options.new
			options.add_argument('--headless')
			d = Selenium::WebDriver.for :chrome, options: options
		end

		d.navigate.to 'https://kakaku.com/game/game-console/itemlist.aspx?pdf_se=16'

		sleep(2)

		# content = d.find_element(:xpath,'//*[@id="main"]/div[2]/div[1]/div/table/tbody/tr[2]/td[1]')
		content = d.find_elements(:class,'itemPrice')[0]
		price = content.text

		d.quit
		return price
	end

end
