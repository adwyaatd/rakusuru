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

	def self.search(search)
		shop_datas = S3base.where(["about_shop LIKE ?","%#{search}%"])
	end

	def self.scr3(search_word)
		page = 1

		datas = []

		n = 1

		retry_cnt = 0

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)

		begin
			begin
				if Rails.env.development? || Rails.env.test?
					logger.debug( "通常モード")
					d = Selenium::WebDriver.for :chrome
				else
					logger.debug( "headlessモード")
					options = Selenium::WebDriver::Chrome::Options.new
					options.add_argument('--headless')
					d = Selenium::WebDriver.for :chrome, options: options
				end

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
			search_bar.send_key("site:*.thebase.in #{search_word}", :enter)

			sleep(1)

			top_url = d.current_url

			# グーグルの検索結果10ページ目まで処理を繰り返す
			while page <= 2
				# 各ショップサイトのURLを取得
				elements = wait.until{ d.find_elements(:xpath,"id('rso')/div/div/div[1]/a")}
				urls = elements.map{|element| element.attribute("href")}

				urls.each do |url|
					logger.debug("サイトページへ")
					begin
						d.navigate.to url
					rescue => e
						logger.debug("d.navigate.to urlエラー 次のショップへスキップ")
						logger.debug(e)
						next
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

					# logger.debug("shop_no:#{shop_no}")

					shop_data = {shop_no:shop_no,shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

					datas.push(shop_data)

					n += 1
				end
				# logger.debug("datas")
				# logger.debug(datas)

				d.navigate.to top_url

				# 次のページに遷移(10ページ目まで)
				page += 1
				logger.debug("page:#{page}")
				wait.until{d.find_element(:link_text,page)}.click
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

	def self.bulk_submission(sender_info,shops)

		logger.debug("sender_info:#{sender_info.inspect}")
		logger.debug("shops:#{shops.inspect}")

		core = Core.new

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)

    begin
      d = core.get_driver

      shops.each_with_index do |shop, i|
        logger.debug("問い合わせURLにアクセス")
        d.navigate.to shop.contact_url

        # Base以外のサイトに入った場合
        unless core.check_element(d,:id, "baseMenu")
          logger.debug("Base以外に入った")
          next
        end

        shop_name = wait.until{ d.title }
        unless shop_name.include?(shop.shop_name)
          logger.debug("ショップ名不一致")
          logger.debug("取得したショップ名：　　#{shop_name}")
          logger.debug("用意していたショップ名：#{shop.shop_name}")
          next
        end

        # 各欄に受け取った値を入力
        name_element = d.find_element(:id,"ShopInquiryName")
        name_element.send_key(sender_info.sender_name)

        tel_element = d.find_element(:id,"ShopInquiryTel")
        tel_element.send_key(sender_info.tel)

        email_element = d.find_element(:id,"ShopInquiryMailAddress")
        email_element.send_key(sender_info.email)

        title_element = d.find_element(:id,"ShopInquiryTitle")
        title_element.send_key(sender_info.title)

        content_element = d.find_element(:id,"ShopInquiryInquiry")
        content_element.send_key("#{sender_info.content}")

				d.find_element(:id,"buttonLeave").click

        unless core.check_element(d,:id, "inquiryConfirmSection")
          logger.debug("確認ページ以外に入った")
					sleep(10)
          next
        end

        # d.find_element(:id,"buttonLeave").click
        if core.check_element(d,:id,"buttonLeave")
					pp "成功！"
					shop.submit_status = 1
        end

        # unless core.check_element(d,:id, "inquiryCompleteSection")
        #   logger.debug("完了ページ以外に入った")
        #   next
        # end


        logger.debug("問い合わせ操作#{i}完了")
      end

      logger.debug("全問い合わせ操作完了")

      d.quit

			logger.debug("shops:#{shops}")
			return shops
    rescue => e
      logger.debug("エラー発生")
			logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
			d.quit
			return shops
    end
	end
end
