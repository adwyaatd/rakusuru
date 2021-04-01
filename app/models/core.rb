require "logger"
require "pp"
require "selenium-webdriver"

class Core

	def initialize
	end

	def check_element(d,attri,val)
		wait = Selenium::WebDriver::Wait.new(:timeout => 1)
		ret = true
		begin
			wait.until{ d.find_element(attri,val) }
		rescue
			ret = false
		end
		return ret
	end

	def get_driver
		retry_cnt = 0

		begin
			if Rails.env.development? || Rails.env.test?
				Rails.logger.debug( "通常モード")
				d = Selenium::WebDriver.for :chrome
			else
				Rails.logger.debug( "headlessモード")
				options = Selenium::WebDriver::Chrome::Options.new
				options.add_argument('--headless')
				d = Selenium::WebDriver.for :chrome, options: options
			end

			return d
		rescue => e
			Rails.logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}-------------------")
			sleep(1)
			retry_cnt += 1
			Rails.logger.debug(retry_cnt)
			retry if retry_cnt <= 2
		end
	end
end
