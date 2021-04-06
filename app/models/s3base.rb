class S3base < ApplicationRecord
	def self.scr3(search_word)
		page = 1
		datas = []
		wait = Selenium::WebDriver::Wait.new(:timeout => 5)
		core = Core.new

		begin
			d = core.get_driver

			logger.debug("検索ページへ遷移")
			d.navigate.to 'https://www.google.co.jp/'

			# logger.debug("入力した内容を検索バーに入力して検索")
			search_bar = d.find_element(:name,"q")
			# search_bar.send_key("site:*.thebase.in #{search_word}", :enter)
			search_bar.send_key("site:*base.shop #{search_word}", :enter)
			# search_bar.send_key("site:*.theshop.jp #{search_word}", :enter)

			top_url = d.current_url

			# グーグルの検索結果nページ目まで処理を繰り返す
			while page <= 1
				# 各ショップサイトのURLを取得
				elements = d.find_elements(:xpath,"id('rso')/div/div/div/div[1]/a")
				urls = elements.map{|element| element.attribute("href")}

				urls.each do |url|
					# logger.debug("サイトページへ")
					begin
						d.navigate.to url
					rescue => e
						# logger.debug("d.navigate.to urlエラー 次のショップへスキップ")
						logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
						next
					end

					#各サイト内の処理
					# Base以外のサイトに入った場合
					unless core.check_element(d,:xpath,"//a[contains(@href,'base')]")
						# logger.debug("Base以外に入った")
						next
					end

					# ショップ名取得
					begin
						current_url = d.current_url
						# ホーム以外のページの場合、ホームへ遷移
						if %r(^https?://.*/.+) =~ current_url
							home_url = current_url.slice(%r{^https?://.*?/})
							d.navigate.to home_url
							shop_url = home_url
						else
							shop_url = current_url
						end
						logger.debug("shop_url:#{shop_url}")

						shop_name = d.title
						logger.debug("ショップ名:#{shop_name}")

						about_shop = d.find_element(:name,"description").attribute("content")
						# logger.debug("about_shop:#{about_shop}")

						contact_url = d.find_element(:xpath, "//a[contains(@href,'/inquiry/')]").attribute("href")
						# logger.debug("contact_url:#{contact_url}")

						shop_data = {shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

						datas.push(shop_data)

						# logger.debug("次のショップへ")
					rescue => e
						logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
						next
					end
				end

				d.navigate.to top_url

				page += 1
				if core.check_element(d,:link_text,page)
					# logger.debug("次のページに遷移")
					d.find_element(:link_text,page).click
					# logger.debug("page:#{page}")
				else
					# logger.debug("次ページなし")
				end
			end

			datas.uniq!

			# logger.debug("全ページ完了 AllOK")

			d.quit
			return datas
		rescue => e
			logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
			d.quit
			return datas
		end
	end

	def self.bulk_submission(sender_info,shops)

		# logger.debug("sender_info:#{sender_info.inspect}")
		# logger.debug("shops:#{shops.inspect}")

		core = Core.new

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)

    begin
      d = core.get_driver

      shops.each_with_index do |shop, i|
        # logger.debug("問い合わせURLにアクセス")
        d.navigate.to shop.contact_url

        # Base以外のサイトに入った場合
        unless core.check_element(d,:xpath,"//a[contains(@href,'base')]")
          # logger.debug("Base以外に入った")
          next
        end

        shop_name = d.title
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
          next
        end

        # d.find_element(:id,"buttonLeave").click
        if core.check_element(d,:id,"buttonLeave")
					logger.debug("成功！")
					# shop.submit_status = 1
        end

        # unless core.check_element(d,:id, "inquiryCompleteSection")
        #   # logger.debug("完了ページ以外に入った")
        #   next
        # end


        logger.debug("問い合わせ操作#{i+1}完了")
      end

      logger.debug("全問い合わせ操作完了")

      d.quit

			# logger.debug("shops:#{shops}")
			return shops
    rescue => e
			logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
			d.quit
			return shops
    end
	end
end
