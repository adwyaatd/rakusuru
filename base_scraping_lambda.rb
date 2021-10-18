require "google_drive"
require "googleauth"
require	"selenium-webdriver"
require "aws-sdk-sqs"
require 'aws-sdk-ec2'
require "json"
require 'mysql2'
require 'net/http'
require 'uri'

def check_and_start_instance(instance_id)
  response = @ec2_client.describe_instances(
    instance_ids: [instance_id]
  )

  if response.count.zero?
    puts 'No matching instance found.'
    exit
  else
    @instance_status = response.reservations[0].instances[0].state.name
    @instance_name = response.reservations[0].instances[0].tags[0][:value]
    pp "The instance:'#{@instance_name}' is '#{@instance_status}'."

    if @instance_status == "stopped" || @instance_status == "stopping" || @instance_status == "pending"
    	start_nat_instance(instance_id)
    elsif @instance_status == "shutting-down"
    	exit
    end
  end
end

def start_nat_instance(instance_id)
  begin
  	if @instance_status == "stopping"
  		pp "wait for stopping #{@instance_name}"
  		@ec2_client.wait_until(:instance_stopped, instance_ids: [instance_id])
  		@ec2_client.start_instances(instance_ids: [instance_id])
  	end
  	if @instance_status == "stopped"
  		pp "Start #{@instance_name}."
    	@ec2_client.start_instances(instance_ids: [instance_id])
    end
    @ec2_client.wait_until(:instance_running, instance_ids: [instance_id])
  rescue => e
  	error_notification(e)
		exit
  else
    pp "Success! #{@instance_name} started."
  end
end

def stop_nat_instance(instance_id)
  pp "Stop #{@instance_name}."

  begin
    @ec2_client.stop_instances(instance_ids: [instance_id])
  rescue => e
    error_notification(e)
  else
    pp "Success! #{@instance_name} stopped."
  end
end

def setup_driver
  service = Selenium::WebDriver::Service.chrome(path: '/opt/bin/chromedriver')
  # service = Selenium::WebDriver::Service.chrome(path: './bin/chromedriver') #ローカルDocker用

  Selenium::WebDriver.for :chrome, service: service, options: driver_options
  # Selenium::WebDriver.for :chrome, options: driver_options #ローカルスクレイピング用
end

def driver_options
  options = Selenium::WebDriver::Chrome::Options.new(binary: '/opt/bin/headless-chromium')
  # options = Selenium::WebDriver::Chrome::Options.new(binary: './bin/headless-chromium') #ローカルDocker用
  # options = Selenium::WebDriver::Chrome::Options.new #ローカルスクレイピング用

  arguments = ["--headless", "--disable-gpu", "--window-size=1280x1696", "--disable-application-cache", "--disable-infobars", "--no-sandbox", "--hide-scrollbars", "--enable-logging", "--log-level=0", "--single-process", "--ignore-certificate-errors" "--homedir=/tmp"]
  arguments.each do |argument|
    options.add_argument(argument)
  end
  options
end

def setup_wait
	wait = Selenium::WebDriver::Wait.new(binary: '/opt/bin/headless-chromium',timeout: 5)
	# wait = Selenium::WebDriver::Wait.new(binary: './bin/headless-chromium',timeout: 5) #ローカルDocker用
	# wait = Selenium::WebDriver::Wait.new(timeout: 5) #ローカルスクレイピング用wait = Selenium::WebDriver::Wait.new(:timeout => 5)
end

def scraping(d,wait,page_num,max_page_num)
	pp "検索ページへ遷移"
	shop_array = []
	scr_err_cnt = 0
	begin
		d.navigate.to 'https://www.google.co.jp/'

		pp "入力した内容を検索バーに入力して検索"
		search_bar = d.find_element(:name,"q")
		search_bar.send_key("site:*.#{@domain} #{@search_word}", :enter)

		top_url = d.current_url
		pp "top_url:#{top_url}"

		if top_url.include?("https://www.google.com/sorry/index")
			pp "google アクセスブロック 処理終了"
			send_line_notification("\n googleアクセスブロック! base_scraping \n #{get_current_time} \n search_word:#{@search_word} \n domain:#{@domain}")
			return shop_array
		end

		# pp "グーグルの検索結果nページ目まで処理を繰り返す"
		while page_num <= max_page_num
			# pp "各ショップサイトのURLを取得"
			elements = d.find_elements(:xpath,"//div[@class='yuRUbf']/a")

			if elements.empty?
				pp "Google検索ページのPath変更の可能性あり"
			else
				urls = elements.map{|element| element.attribute("href")}

				urls.each do |url|
					# pp "サイトページへ"
					if url.include?("developers.thebase.in") || url.include?("design.thebase.in")
						pp "BASEのサイトに入ったので次のショップへ遷移"
						next
					end

					begin
						d.navigate.to url
					rescue => e
						pp "エラー! navigate.to url:#{url} 次のショップへ遷移"
						error_notification(e)
						next
					end

					# 各サイト内の処理
					# Base以外のサイトに入った場合
					unless check_element(d,:xpath,"//a[contains(@href,'base')]")
						pp "Base以外のサイトに入ったので次のショップへ遷移"
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
						# pp "shop_url:#{shop_url}"

						shop_name = d.title
						pp "ショップ名:#{shop_name}"

						about_shop = d.find_element(:name,"description").attribute("content")
						# pp "about_shop:#{about_shop}"

						contact_url = d.find_element(:xpath, "//a[contains(@href,'/inquiry/')]").attribute("href")
						# pp "contact_url:#{contact_url}"

						shop_hash = {shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

						shop_array.push(shop_hash)

					# 	pp "次のショップへ"
					rescue => e
						pp "スクレイピングエラー ショップ名:#{shop_name},URL:#{shop_url} 次のショップへ"
						pp e.message
						scr_err_cnt += 1
						next
					end
				end
			end

			d.navigate.to top_url

			page_num += 1
			pp "page_num:#{page_num}"
			if check_element(d,:link_text,page_num)
				pp "次のページに遷移"
				d.find_element(:link_text,page_num).click
			else
				pp "次ページなし break"
				break
			end
		end
	rescue => e
		error_notification(e)
	else
		pp "全ページスクレイピング完了"
	end

	shop_array.uniq!

	return shop_array,scr_err_cnt
end

def check_element(d,attri,val,text="")
	wait = Selenium::WebDriver::Wait.new(:timeout => 2)
	retry_cnt = 0
	ret = true
	begin
		element = wait.until{ d.find_element(attri,val) }
	rescue
		if retry_cnt <= 3
			retry_cnt += 1
			retry
		end
		ret = false
	else
		if !element.text.include?(text)
			ret = false
		end
	end
	return ret
end

def save_to_db(scraping_result_array,scraping_id)
	existing_shop_count = 0
  new_shop_count = 0
  updated_shop_count = 0

  client = Mysql2::Client.new(
    host: ENV["DB_HOST"],
    username: ENV["DB_USER"],
    password: ENV["DB_PASSWORD"],
    database: ENV["DB_NAME"],
    port: 3306
  )

  scraping_result_array.each do |hash|
    # データベース上に合致するデータがあるか検索
    q = "select * from s3bases where shop_name like ? or shop_url like ? or contact_url like ?"
    stmt = client.prepare(q)
    record = stmt.execute("%#{hash[:shop_name]}%","%#{hash[:shop_url]}%","%#{hash[:contact_url]}%")

    q2 = "select * from s3bases where shop_name = ? and shop_url = ? and contact_url = ?"
    stmt = client.prepare(q2)
    record2 = stmt.execute(hash[:shop_name],hash[:shop_url],hash[:contact_url])

    if record2.first # 登録データと完全一致なら何もしない
      existing_shop_count += 1
      pp  "#{hash[:shop_name]}:登録済み"
      next
    elsif record.count == 0 # ない=未登録なので新規登録
      pp  "#{hash[:shop_name]}:新規登録"
      insert_shop_q = "insert into s3bases (shop_name,about_shop,contact_url,shop_url,scraping_id,disable,submit_status,created_at,updated_at) values(?,?,?,?,?,0,0,NOW(),NOW())"
      stmt = client.prepare(insert_shop_q)
      stmt.execute(hash[:shop_name],hash[:about_shop],hash[:contact_url],hash[:shop_url],scraping_id)
      new_shop_count += 1
    else #一部変更箇所があるので更新
      pp  "#{hash[:shop_name]}:データ更新"
      update_q = "update s3bases set shop_name = ?,about_shop = ?,contact_url = ?,shop_url = ? where id = ?"
      stmt2 = client.prepare(update_q)
      stmt2.execute(hash[:shop_name],hash[:about_shop],hash[:contact_url],hash[:shop_url],record.first["id"])
      updated_shop_count += 1
    end
  end # scraping_result_array.each

  insert_collect_history_q = "insert into collect_histories (scraping_id,search_word,domain,existing_shop_count,new_shop_count,updated_shop_count,created_at,updated_at) values(?,?,?,?,?,?,NOW(),NOW())"
  stmt3 = client.prepare(insert_collect_history_q)
  stmt3.execute(scraping_id,@search_word,@domain,existing_shop_count,new_shop_count,updated_shop_count)

  pp  "=========================DB格納成功=========================="
end

def error_notification(e)
  puts "Error! #{e.message},#{e.backtrace.join("\n")}"
  send_line_notification("\n Error! base_scraping \n #{get_current_time} \n search_word:#{@search_word} \n domain:#{@domain} \n #{e.message} \n #{e.backtrace.join("\n")}")
end

def simple_error_notification(e)
  puts "Error! #{e.message},#{e.backtrace.join("\n")}"
  send_line_notification("\n Scraping_warning base_scraping \n #{get_current_time} \n search_word:#{@search_word} \n domain:#{@domain} \n #{e.message}")
end

def get_current_time
	week = %w(日 月 火 水 木 金 土)[Date.today.wday] #日
	current_time = Time.now.strftime("%Y/%m/%d(#{week}) %T") #2021/01/01(日) 01:23:45
end

def send_line_notification(msg)
  uri = URI.parse(ENV["LINE_API_URI"])

  request = make_request(msg,uri)
  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |https|
    https.request(request)
  end
end

def make_request(msg,uri)
  request = Net::HTTP::Post.new(uri)
  request["Authorization"] = "Bearer #{ENV["LINE_API_TOKEN"]}"
  request.set_form_data(message: msg)
  request
end

def get_processing_time(start_time)
  process_seconds = Time.now - start_time
  time = process_seconds.round
  sec = time % 60
  time /= 60
  mins = time % 60
  return "#{mins}分#{sec}秒"
end

def lambda_handler(event:, context:)
  pp "処理開始"
  start_time = Time.now # 処理時間計測開始
  begin
	  nat_instance_id = ENV["NAT_INSTANCE_ID"]
	  app_instance_id = ENV["APP_INSTANCE_ID"]
	  @ec2_client = Aws::EC2::Client.new(region: ENV["REGION"])
	  @instance_name =""
	  @instance_status = ""
	  page_num = 1
	  max_page_num = 5

	  if !event.empty?
	  	pp "メッセージあり"
	  	sqs_message_hash = JSON.parse(event["Records"][0]["body"],{symbolize_names: true})
		  @search_word = sqs_message_hash[:search_word]
		  pp @search_word
		  @domain = sqs_message_hash[:domain]
		  pp @domain
		  scraping_id = sqs_message_hash[:scraping_id]
		  pp scraping_id
		else #テスト用
			pp "テスト"
			@search_word = ""
			@domain = "buyshop.jp"
			scraping_id = 0
	  end

		check_and_start_instance(nat_instance_id)
		check_and_start_instance(app_instance_id)

		d = setup_driver
		wait = setup_wait
		scraping_result_array,scr_err_cnt = scraping(d,wait,page_num,max_page_num)
		d.quit

		if !scraping_result_array.empty?
			save_to_db(scraping_result_array,scraping_id)
		else
    	puts  "==========================スクレイピング失敗=========================="
    	send_line_notification("\n base_scraping スクレイピング失敗 \n #{get_current_time} \
			\n search_word:#{@search_word} \n domain:#{@domain}")
    	return
  	end
	rescue => e
		error_notification(e)
	else
		send_line_notification("\n base_scraping 全処理成功 \n #{get_current_time} \n 処理時間:#{get_processing_time(start_time)} \n search_word:#{@search_word} \n domain:#{@domain} \n#{ENV["CFBS_URL"]} \n scr_err:#{scr_err_cnt}")
		# stop_nat_instance(i)
		return "All OK"
	end
end
