class S2dmm < ApplicationRecord
	def self.scr2

		array = []

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)
		retry_cnt = 0

		begin
			begin
				logger.debug( "headlessモード")
				options = Selenium::WebDriver::Chrome::Options.new
				options.add_argument('--headless')
				d = Selenium::WebDriver.for :chrome, options: options

				# logger.debug( "通常モード")
				# d = Selenium::WebDriver.for :chrome

				logger.debug( "検索ページへ遷移")
				d.navigate.to 'https://www.google.co.jp/imghp?hl=ja&tab=ri&authuser=0&ogbl'
			rescue => e
				logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
				sleep(1)
				retry_cnt += 1
				logger.debug( retry_cnt)
				retry if retry_cnt <= 5
			end

			logger.debug("入力した内容を検索バーに入力して検索")
			search_bar = wait.until{ d.find_element(:name,"q") }
			search_bar.send_key("レモン", :enter)

			logger.debug( "ライセンスフリーの画像に絞り込む（「ツール」→「ライセンス」→「再使用が許可された画像」を選択）")
			logger.debug( "ツールをクリック")
			tool = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[1]/div/div[1]/div[2]/div[2]/div/div") }
			tool.click

			sleep(2)

			logger.debug( "ライセンスをクリック")
			pull_down = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[2]/c-wiz[1]/div/div/div[1]/div/div[5]/div/div[1]") }

			begin
				pull_down.click
			rescue
				logger.debug( __LINE__)
				d.navigate.refresh
				tool = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[1]/div/div[1]/div[2]/div[2]/div/div") }
				tool.click
				sleep(3)
				pull_down = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[2]/c-wiz[1]/div/div/div[1]/div/div[5]/div/div[1]") }
				pull_down.click
			end

			logger.debug( "プルダウンから「クリエイティブ・コモンズ ライセンス」を選択")
			l = wait.until{ d.find_element(:link_text,"クリエイティブ・コモンズ ライセンス") }
			l.click

			logger.debug( "画像要素を取得")
			imgs = wait.until{ d.find_elements(:xpath,"id('islrg')//img") }

			imgs.each_with_index do |i,n|
				img_src = i.attribute('src')
				array[n] = img_src
			end

			# array = array.delete_if(&:empty?)
			array = array.compact

			logger.debug( "AllOK")
			d.quit
			return array
		rescue => e
			logger.debug( "エラー発生")
			logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
			d.quit
			return array
		end
	end
end
