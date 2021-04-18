require "logger"
require "pp"
require "selenium-webdriver"
require "parallel"

class Core

	def initialize
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
			Rails.logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
			sleep(1)
			retry_cnt += 1
			Rails.logger.debug(retry_cnt)
			retry if retry_cnt <= 1
		end
	end

	def check_element(d,attri,val,text="")
		wait = Selenium::WebDriver::Wait.new(:timeout => 2)

		ret = true
		begin
			element = wait.until{ d.find_element(attri,val) }
		rescue
			ret = false
		else
			if !element.text.include?(text)
				ret = false
			end
		end
		return ret
	end

	def check_base(d)
		ret = true
		begin
			element = d.find_element(:name,"copyright").attribute("content")
		rescue
			ret = false
		else
			if !element.include?("BASE")
				ret = false
			end
		end
		return ret
	end

end
