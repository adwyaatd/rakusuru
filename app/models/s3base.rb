class S3base < ApplicationRecord

	def self.check_element(d,attri,val)
		wait = Selenium::WebDriver::Wait.new(:timeout => 1)
		ret = true
		begin
			wait.until{ d.find_element(attri,val) }
		rescue
			ret = false
		end
		return ret
	end

	def self.scr3
		page = 1

		datas = []

		n = 1

		retry_cnt = 0

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)

		begin
			begin
				logger.debug("headlessモード")
				options = Selenium::WebDriver::Chrome::Options.new
				options.add_argument('--headless')
				d = Selenium::WebDriver.for :chrome, options: options

				# logger.debug("通常モード")
				# d = Selenium::WebDriver.for :chrome

				logger.debug("検索ページへ遷移")
				d.navigate.to 'https://www.google.co.jp/'
			rescue => e
				logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}-------------------")
				sleep(1)
				retry_cnt += 1
				logger.debug(retry_cnt)
				retry if retry_cnt <= 5
			end

			logger.debug("入力した内容を検索バーに入力して検索")
			search_bar = d.find_element(:name,"q")
			search_bar.send_key("site:*.thebase.in", :enter)

			sleep(1)

			top_url = d.current_url

			# グーグルの検索結果10ページ目まで処理を繰り返す
			while page <= 3
				# 各ショップサイトのURLを取得
				elements = wait.until{ d.find_elements(:xpath,"id('rso')/div/div/div[1]/a")}
				urls = elements.map{|element| element.attribute("href")}

				urls.each do |url|
					logger.debug("サイトページへ")
					begin
						logger.debug(__LINE__)
						d.navigate.to url
						logger.debug(__LINE__)
					rescue => e
						logger.debug(__LINE__)
						logger.debug(e)
						d.navigate.refresh
					end

					#各サイト内の処理
					# Base以外のサイトに入った場合
					unless check_element(d,:id, "baseMenu")
						logger.debug("Base以外に入った")
						next
					end

					# ショップ名取得
					shop_name = wait.until{ d.title }
					logger.debug("ショップ名")
					logger.debug(shop_name)

					about_shop = d.find_element(:name,"description").attribute("content")
					logger.debug("about_shop:#{about_shop}")

					shop_url = d.current_url
					logger.debug(shop_url)
					h = %r(https://)
					t = %r(.thebase.in/)
					w = %r(www.)
					j = %r(.jp/)
					shop = shop_url.gsub(h,"").gsub(t,"").gsub(w,"").gsub(j,"")
					logger.debug(shop)
					contact_url = "https://thebase.in/inquiry/#{shop}"

					logger.debug("問い合わせフォーム")
					logger.debug(contact_url)

					shop_no = n

					shop_data = {shop_no:shop_no,shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

					datas.push(shop_data)

					n += 1
				end
				logger.debug("datas")
				logger.debug(datas)

				d.navigate.to top_url

				# 次のページに遷移(10ページ目まで)
				page += 1
				if page <= 10
					wait.until{d.find_element(:link_text,page)}.click
				end
				logger.debug("page:#{page}")
			end

			logger.debug("全ページ完了")

			logger.debug("AllOK")
			d.quit
			return datas
		rescue => e
			logger.debug("エラー発生")
			logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
			d.quit
			return datas
		end
	end

	private_class_method :check_element
end