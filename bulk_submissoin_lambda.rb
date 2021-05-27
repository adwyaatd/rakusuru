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
    pp 'No matching instance found.'
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

def stop_nat_instance
  instance_id = 'i-091e840cd26a70c13'
  region = 'ap-northeast-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  pp "Stop NatInstance."
  begin
    ec2_client.stop_instances(instance_ids: [instance_id])
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

def bulk_submit(d,wait,shops_info_array,sender_info_hash)
  submitted_shop_id_array = []

  shops_info_array.each_with_index do |shop, i|
    d.navigate.to shop["contact_url"]

    # Base以外のサイトに入った場合
    unless check_element(d,:xpath,"//a[contains(@href,'base')]")
      pp "Base以外に入った"
      next
    end

    shop_name = d.title
    unless shop_name.include?(shop["shop_name"])
      pp "ショップ名不一致"
      pp "取得したショップ名：#{shop_name}"
      pp "用意していたショップ名：#{shop["shop_name"]}"
      next
    end

    # 各欄に受け取った値を入力
    name_element = d.find_element(:id,"ShopInquiryName")
    name_element.send_key(sender_info_hash["sender_name"])

    tel_element = d.find_element(:id,"ShopInquiryTel")
    tel_element.send_key(sender_info_hash["tel"])

    email_element = d.find_element(:id,"ShopInquiryMailAddress")
    email_element.send_key(sender_info_hash["email"])

    title_element = d.find_element(:id,"ShopInquiryTitle")
    title_element.send_key(sender_info_hash["title"])

    content_element = d.find_element(:id,"ShopInquiryInquiry")
    content_element.send_key(sender_info_hash["content"])

		# 「確認する」をクリック
		d.find_element(:id,"buttonLeave").click

    unless check_element(d,:id, "inquiryConfirmSection")
      pp "確認ページ以外に入った shop名:#{shop["shop_name"]} "
      next
    end


    # 「送信する」をクリック
    d.find_element(:id,"buttonLeave").click

    # 送信完了ページへ
    if check_element(d,:id,"inquiryCompleteSection")
			submitted_shop_id_array.push(shop["id"])
		else
      pp "完了ページ以外に入った  shop名:#{shop["shop_name"]}"
      next
    end
    pp "問い合わせ操作#{i+1}完了 shop名:#{shop["shop_name"]}"
  end

  pp "全問い合わせ操作完了"
	return submitted_shop_id_array
end

def check_element(d,attri,val,text="")
	wait = Selenium::WebDriver::Wait.new(:timeout => 2)
	retry_cnt = 0
	ret = true
	begin
		element = wait.until{ d.find_element(attri,val) }
	rescue
		if retry_cnt <= 4
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

def error_notification(e)
  puts "Error! #{e.message},#{e.backtrace.join("\n")}"
  send_line_notification("\n Error! bulk_submission \n #{get_current_time} \n #{e.message} \n #{e.backtrace.join("\n")}")
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

def save_to_db(submitted_shop_id_array)
  client = Mysql2::Client.new(
    host: ENV["DB_HOST"],
    username: ENV["DB_USER"],
    password: ENV["DB_PASSWORD"],
    database: ENV["DB_NAME"],
    port: 3306
  )

  ids = submitted_shop_id_array.join(",") #"1,2,3"

  pp "ids:#{ids}"

  update_q = "update s3bases set submit_status = 1,submit_at = NOW() where id in (#{ids})"
  stmt = client.prepare(update_q)
  stmt.execute

  pp  "=========================DB格納成功=========================="
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
  nat_instance_id = ENV["NAT_INSTANCE_ID"]
  app_instance_id = ENV["APP_INSTANCE_ID"]
  @ec2_client = Aws::EC2::Client.new(region: ENV["REGION"])
  @instance_name =""
  @instance_status = ""
  begin
    check_and_start_instance(nat_instance_id)
    check_and_start_instance(app_instance_id)

    begin
      sqs_message_hash = JSON.parse(event["Records"][0]["body"])
    rescue
      pp "テスト"
      sqs_message_hash = event
      pp sqs_message_hash
    end

    shops_info_array = sqs_message_hash["shops_info_array"]
    sender_info_hash = sqs_message_hash["sender_info_hash"]

    d = setup_driver
    wait = setup_wait

    submitted_shop_id_array = bulk_submit(d,wait,shops_info_array,sender_info_hash)
    pp "submitted_shop_id_array:#{submitted_shop_id_array}"
    d.quit

    if !submitted_shop_id_array.empty?
      save_to_db(submitted_shop_id_array)
    else
      puts "==========================submit失敗=========================="
      puts "shops_info_array:#{shops_info_array}, \n sender_info_hash:#{sender_info_hash}"
      send_line_notification("\n bulk_submit 失敗 \n #{get_current_time}")
      return
    end
  rescue => e
    error_notification(e)
  else
    send_line_notification("\n bulk_submission 全処理成功 \n #{get_current_time} \n 処理時間:#{get_processing_time(start_time)} \n #{ENV["CFBS_URL"]}")
    return "All OK"
  end
end
