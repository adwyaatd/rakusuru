require	"selenium-webdriver"
require "pp"
require "parallel"
require "aws-sdk-sqs"
require "json"


# h = {"search_word"=>"", "domain"=>"base.ec", "scraping_id"=>"25"}
# pp h["domain"]

# sqs = "search_word: '',domain: 'thebase.in',scraping_id: '25'"
# sqs = {search_word: '',domain: 'thebase.in',scraping_id: '25'}.to_json
# s = JSON.parse(sqs)[:domain]
# pp s

# search_word = sqs[:search_word]
# pp search_word
# domain = sqs[:domain]
# pp domain

# hash = {:key=>"Name", :value=>"tuno_lambda_nat_instance"}

# pp hash[:value]

# status = ["stopped","stopped"]
# message = '%s has already terminated'
# atest = "happy!!"
# puts sprintf("#{message}. status: %s test: %s", "Instance: 1",status,atest)

# queue_name = "scr-queue.fifo"

# sqs = Aws::SQS::Client.new(region: 'ap-northeast-1')

# # (
# # 	:access_key_id => "AKIAUJS2FOLWHFNMGYB4",
# # 	:secret_access_key => "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"
# # )

# begin
# 	queue_url = sqs.get_queue_url(queue_name: queue_name).queue_url
# 	# "https://sqs.ap-northeast-1.amazonaws.com/295468102380/scr-queue.fifo"
# 	pp "queue_url:#{queue_url}"

# 	msg_b = "#{DateTime.now.strftime("%Y年%-m月%-d日 %-H時%-M分%-S秒")}"
# 	pp "msg_b:#{msg_b}"

# 	send_message_result = sqs.send_message({
# 		queue_url: queue_url,
# 		message_group_id: "message_group_id-#{DateTime.now.strftime("%Y%m%d%H%M%S")}",
# 		message_body: msg_b,
# 		message_deduplication_id: "message_deduplication_id-#{DateTime.now.strftime("%Y%m%d%H%M%S")}"
# 		# message_attributes: {
# 		# 	"Title" => {
# 		# 		string_value: "The Whistler",
# 		# 		data_type: "String"
# 		# 	},
# 		# 	"Author" => {
# 		# 		string_value: "John Grisham",
# 		# 		data_type: "String"
# 		# 	},
# 		# 	"WeeksOn" => {
# 		# 		string_value: "6",
# 		# 		data_type: "Number"
# 		# 	}
# 		# }
# 	})
# rescue => e
# 	pp e
# else
# 	puts send_message_result.message_id
# 	# flash[:notice] = "キュー送信 内容：#{send_message_result.message_body}"
# 	# redirect_to s3bases_url
# end

# def check_element(d,attri,val,text="")
# 	wait = Selenium::WebDriver::Wait.new(:timeout => 2)
# 	pp text
# 	ret = true
# 	begin
# 		element = wait.until{ d.find_element(attri,val) }
# 	rescue
# 		ret = false
# 	else
# 		if !element.text.include?(text)
# 			ret = false
# 		end
# 	end
# 	return ret
# end

# def scr3(domain,search_word)
	begin
		page = 1
		datas = []
		wait = Selenium::WebDriver::Wait.new(:timeout => 5)

		d = Selenium::WebDriver.for :chrome

		pp "d:#{d}"

		d.quit

		pp "d:#{d}"

		# pp "検索ページへ遷移"
		# d.navigate.to 'https://www.google.co.jp/'

		# pp "入力した内容を検索バーに入力して検索"
		# search_bar = d.find_element(:name,"q")
		# search_bar.send_key("site:*.thebase.in", :enter)
		# # search_bar.send_key("site:*.#{domain} #{search_word}", :enter)
		# # search_bar.send_key("site:*.theshop.jp #{search_word}", :enter)

		# top_url = d.current_url

		# # グーグルの検索結果nページ目まで処理を繰り返す
		# while page <= 1
		# 	# 各ショップサイトのURLを取得
		# 	# elements = d.find_elements(:xpath,"id('rso')/div/div/div/div[1]/a")
		# 	elements = d.find_elements(:xpath,"//div[@class='yuRUbf']/a")

    #   if elements.empty?
    #     pp "なし"
    #   end
		# 	urls = elements.map{|element| element.attribute("href")}

		# 	urls.each do |url|
		# 		pp "サイトページへ"
		# 		begin
		# 			d.navigate.to url
		# 		rescue => e
		# 			pp "d.navigate.to urlエラー 次のショップへスキップ"
		# 			pp "----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------"
		# 			next
		# 		end
    #   end
    #   page += 1
    # end
    # pp "終了"
    # d.quit
	rescue => e
		pp "----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------"
    d.quit

	end


# 				#各サイト内の処理
# 				# Base以外のサイトに入った場合
# 				unless core.check_element(d,:xpath,"//a[contains(@href,'base')]")
# 					pp "Base以外に入った"
# 					next
# 				end

# 				# ショップ名取得
# 				begin
# 					current_url = d.current_url
# 					# ホーム以外のページの場合、ホームへ遷移
# 					if %r(^https?://.*/.+) =~ current_url
# 						home_url = current_url.slice(%r{^https?://.*?/})
# 						d.navigate.to home_url
# 						shop_url = home_url
# 					else
# 						shop_url = current_url
# 					end
# 					pp "shop_url:#{shop_url}"

# 					shop_name = d.title
# 					pp "ショップ名:#{shop_name}"

# 					about_shop = d.find_element(:name,"description").attribute("content")
# 					pp "about_shop:#{about_shop}"

# 					contact_url = d.find_element(:xpath, "//a[contains(@href,'/inquiry/')]").attribute("href")
# 					pp "contact_url:#{contact_url}"

# 					shop_data = {shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

# 					datas.push(shop_data)

# 					pp "次のショップへ"
# 				rescue => e
# 					pp e
# 					# logger.error("----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------")
# 					next
# 				end
# 			end

# 			d.navigate.to top_url

# 			page += 1
# 			if core.check_element(d,:link_text,page)
# 				pp "次のページに遷移"
# 				d.find_element(:link_text,page).click
# 				pp "page:#{page}"
# 			else
# 				pp "次ページなし"
# 			end
# 		end

# 		datas.uniq!

# 		pp "全ページ完了 AllOK"

# 		d.quit
# 		pp "datas:#{datas}"
# 		return datas
# 	rescue => e
# 		pp "----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------"
# 		d.quit
# 		return datas
# 	end
# end

# domains = ["thebase.in","base.shop","theshop.jp","base.ec"]
# search_word = "アクセサリー"

# Parallel.each(domains) do |domain|
# 	scr3(domain,search_word)
# end
