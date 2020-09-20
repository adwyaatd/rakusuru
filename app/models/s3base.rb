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
		# headlessモード
		# options = Selenium::WebDriver::Chrome::Options.new
		# options.add_argument('--headless')
		# d = Selenium::WebDriver.for :chrome, options: options

		#通常モード
		d = Selenium::WebDriver.for :chrome

		wait = Selenium::WebDriver::Wait.new(:timeout => 5)
		d.manage.timeouts.page_load = 10

		# 検索ページへ遷移
		d.navigate.to 'https://www.google.co.jp/'

		sleep(1)

		pp "入力した内容を検索バーに入力して検索"

		search_bar = d.find_element(:name,"q")
		search_bar.send_key("site:*.thebase.in", :enter)

		sleep(1)

		top_url = d.current_url

		elements = wait.until{ d.find_elements(:xpath,"id('rso')/div/div/div[1]/a")}
		urls = elements.map{|element| element.attribute("href")}

		datas = []
		n = 1

		urls.each do |url|
			pp "サイトページへ"
			d.navigate.to url

			#各サイト内の処理
			# Base以外のサイトに入った場合
			unless check_element(d,:id, "baseMenu")
				pp "Base以外に入った"
				next
			end

			# ショップ名取得
			shop_name = wait.until{ d.title }
			pp "ショップ名"
			pp shop_name

			about_shop = d.find_element(:name,"description").attribute("content")
			pp "about_shop:#{about_shop}"

			# retry_cnt = 0
			# if check_element(d,:link_text, "CONTACT")
			#   contact = d.find_element(:link_text, "CONTACT")
			#   pp "1"
			# elsif check_element(d,:partial_link_text, "ontact")
			#   contact = d.find_element(:partial_link_text, "ontact")
			#    pp "2"
			# # elsif check_element(d,:link_text, "contact")
			# #   contact = d.find_element(:link_text, "contact")
			# #   pp "3"
			# elsif check_element(d,:partail_link_text, "お問")
			#   contact = d.find_element(:partial_link_text, "お問")
			#   pp "3"
			# else
			#   contact = ""
			#   pp "contactなかった"
			# end

			# if contact == ""
			#   contact_url = contact
			#   pp　"なかった"
			# else
			#   contact_url = contact.attribute("href")
			#   pp __LINE__
			# end

			shop_url = d.current_url
			pp shop_url
			h = %r(https://)
			t = %r(.thebase.in/)
			w = %r(www.)
			j = %r(.jp/)
			shop = shop_url.gsub(h,"").gsub(t,"").gsub(w,"").gsub(j,"")
			pp shop
			contact_url = "https://thebase.in/inquiry/#{shop}"

			pp "問い合わせフォーム"
			pp contact_url

			shop_no = n

			shop_data = {shop_no:shop_no,shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

			datas.push(shop_data)

			n += 1
		end
		pp "datas"
		pp datas

		d.navigate.to top_url

		sleep(2)

		pp "AllOK"
		d.quit
		return datas
	end
	private_class_method :check_element
end
