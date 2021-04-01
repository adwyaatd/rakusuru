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

	def self.bulk_submission(sender_info,shops_info)

		sender_info  = {name:"細田",tel:"0123",email:"a@gmail.com",title:"件名",to:"株式会社細田　細田様",content:"お問い合わせ内容"}
		logger.debug("sender_info:#{sender_info}")
		shops_info = [{id:6,shop_name:"えにショップ",contact_url:"https://thebase.in/inquiry/eni0821",submit_status:0},{id:7,shop_name:"SHEER",contact_url:"https://thebase.in/inquiry/sheershop"submit_status:0}]
		logger.debug("shops_info:#{shops_info}")

		retry_cnt = 0

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)

    begin
      d = Core.get_driver

      shops_info.each_with_index do |shop_info, i|
        logger.debug("問い合わせURLにアクセス")
        d.navigate.to shop_info[contact_url]

        # Base以外のサイトに入った場合
        unless core.check_element(d,:id, "baseMenu")
          logger.debug("Base以外に入った")
          next
        end

        shop_name = wait.until{ d.title }
        unless shop_name.include?(shop_info[shop_name])
          logger.debug("ショップ名不一致")
          logger.debug("取得したショップ名：　　#{shop_name}")
          logger.debug("用意していたショップ名：#{shop_info[shop_name]}")
          next
        end

        # 各欄に受け取った値を入力
        name_element = d.find_element(:id,"ShopInquiryName")
        name_element.send_key(sender_info[name])

        tel_element = d.find_element(:id,"ShopInquiryTel")
        tel_element.send_key(sender_info[tel])

        email_element = d.find_element(:id,"ShopInquiryMailAddress")
        email_element.send_key(sender_info[email])

        title_element = d.find_element(:id,"ShopInquiryTitle")
        title_element.send_key(sender_info[title])

        content_element = d.find_element(:id,"ShopInquiryInquiry")
        content_element.send_key("#{shops_info[shop_name]}")
        content_element.send_keys(:return)
        content_element.send_keys(:return)
        content_element.send_key("#{sender_info[content]}")

        d.find_element(:id,"buttonLeave").click

        unless Core.check_element(d,:id, "inquiryConfirmSection")
          logger.debug("確認ページ以外に入った")
          next
        end

        d.find_element(:id,"buttonLeave").click

        unless Core.check_element(d,:id, "inquiryCompleteSection")
          logger.debug("完了ページ以外に入った")
          next
        end

        shop_info[submit_status] = 1

        logger.debug("問い合わせ操作完了")
      end

      logger.debug("全問い合わせ操作完了")

      d.quit

			logger.debug("shops_info:#{shops_info}")
			return shops_info
    rescue => e
      logger.debug("エラー発生")
			logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
			d.quit
			return shops_info
    end
	end
	# private_class_method :check_element
end
