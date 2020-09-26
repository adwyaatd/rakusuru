class S2dmm < ApplicationRecord
	def self.scr2

		array = []

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)
		retry_cnt = 0

		begin
			begin
				# require 'open_uri'
				# pp "headlessモード"
				# options = Selenium::WebDriver::Chrome::Options.new
				# options.add_argument('--headless')
				# d = Selenium::WebDriver.for :chrome, options: options

				pp "通常モード"
				d = Selenium::WebDriver.for :chrome

				pp "検索ページへ遷移"
				d.navigate.to 'https://www.google.co.jp/imghp?hl=ja&tab=ri&authuser=0&ogbl'
			rescue => e
				logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
				sleep(1)
				retry_cnt += 1
				pp retry_cnt
				retry if retry_cnt <= 5
			end

			pp"入力した内容を検索バーに入力して検索"
			search_bar = wait.until{ d.find_element(:name,"q") }
			search_bar.send_key("レモン", :enter)

			pp "ライセンスフリーの画像に絞り込む（「ツール」→「ライセンス」→「再使用が許可された画像」を選択）"
			pp "ツールをクリック"
			tool = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[1]/div/div[1]/div[2]/div[2]/div/div") }
			tool.click

			sleep(2)

			pp "ライセンスをクリック"
			pull_down = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[2]/c-wiz[1]/div/div/div[1]/div/div[5]/div/div[1]") }

			begin
				pull_down.click
			rescue
				pp __LINE__
				d.navigate.refresh
				tool = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[1]/div/div[1]/div[2]/div[2]/div/div") }
				tool.click
				sleep(3)
				pull_down = wait.until{ d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[2]/c-wiz[1]/div/div/div[1]/div/div[5]/div/div[1]") }
				pull_down.click
			end

			pp "プルダウンから「クリエイティブ・コモンズ ライセンス」を選択"
			l = wait.until{ d.find_element(:link_text,"クリエイティブ・コモンズ ライセンス") }
			l.click

			pp "画像要素を取得"
			imgs = wait.until{ d.find_elements(:xpath,"id('islrg')//img") }

			imgs.each_with_index do |i,n|
				img_src = i.attribute('src')
				array[n] = img_src
			end

			# array = array.delete_if(&:empty?)
			array = array.compact

			pp "AllOK"
			d.quit
			return array
		rescue => e
			pp "エラー発生"
			logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
			d.quit
			return array
		end
	end
end
