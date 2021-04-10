require "google_drive"
require "googleauth"
require	"selenium-webdriver"
require "aws-sdk-sqs"
require 'aws-sdk-ec2'

def start_nat_instance
  instance_id = 'i-01459d20b44a7c3fd'
  region = 'ap-northeast-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  pp "Start NatInstance."
  begin
    ec2_client.start_instances(instance_ids: [instance_id])
    ec2_client.wait_until(:instance_running, instance_ids: [instance_id])
  rescue => e
    pp "Error! Instance startup failure: #{e.message},#{e.backtrace.join("\n")}"
		exit
  else
    pp 'Success! Instance started.'
  end
end

def stop_nat_instance
  instance_id = 'i-01459d20b44a7c3fd'
  region = 'ap-northeast-1'

  ec2_client = Aws::EC2::Client.new(region: region)
  pp "Stop NatInstance."
  begin
    ec2_client.stop_instances(instance_ids: [instance_id])
  rescue => e
    pp "Error! Instance stop failure: #{e}"
  else
    pp 'Success! Instance stopped.'
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

def scraping(d,wait,page,datas)
	pp "検索ページへ遷移"
	begin
		d.navigate.to 'https://www.google.co.jp/'

		# pp "入力した内容を検索バーに入力して検索"
		search_bar = d.find_element(:name,"q")
		search_bar.send_key("site:*.base.shop", :enter)

		top_url = d.current_url

		# グーグルの検索結果nページ目まで処理を繰り返す
		while page <= 1
			# 各ショップサイトのURLを取得
			elements = d.find_elements(:xpath,"id('rso')/div/div/div/div[1]/a")
			urls = elements.map{|element| element.attribute("href")}

			urls.each do |url|
				# pp "サイトページへ"
				begin
					d.navigate.to url
				rescue => e
					pp "----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------"
					next
				end

				#各サイト内の処理
				# Base以外のサイトに入った場合
				unless check_element(d,:xpath,"//a[contains(@href,'base')]")
					pp "Base以外に入った"
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

					shop_data = {shop_name:shop_name,about_shop:about_shop,contact_url:contact_url,shop_url:shop_url}

					datas.push(shop_data)

					# pp "次のショップへ"
				rescue => e
					pp "----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------"
					next
				end
			end

			d.navigate.to top_url

			page += 1
			if check_element(d,:link_text,page)
				pp "次のページに遷移"
				d.find_element(:link_text,page).click
				# pp "page:#{page}"
			else
				pp "次ページなし"
			end
		end
	rescue => e
		pp "----------------------[error]line:#{__LINE__},error:#{e.message},#{e.backtrace.join("\n")} ---------------------------"
	else
		pp "全ページ完了 AllOK"
	end
	datas.uniq!
	return datas
end

def check_element(d,attri,val,text="")
	wait = Selenium::WebDriver::Wait.new(:timeout => 2)

	ret = true
	begin
		element = wait.until{ d.find_element(attri,val) }
	rescue
		ret = false
	else
		if !element.text.include?(text)
			ret = false
		end
	end
	return ret
end

def get_session
  pp "セッション開始"
  credentials = Google::Auth::UserRefreshCredentials.new(
    client_id: "1020131189820-qpkqecfpalhcunv6q27619kdlm0sknrk.apps.googleusercontent.com",
    client_secret: "5z63V5xd5fwBNPcoqv4s4Bna",
    scope: [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/"
    ],
    refresh_token: "1//0edw4khTfQ532CgYIARAAGA4SNwF-L9IrwnThPxdOJKcylIZGXlIg1EJg78_Cczdo7RQ5uHQG-RW2SAXWeogtgCp-ETnbWbLWyEA"
  )
  # session = GoogleDrive::Session.from_config("config.json") #config.jsonを使う場合
  GoogleDrive::Session.from_credentials(credentials)
end

def lambda_handler(event:, context:)
  pp "処理開始"

  start_nat_instance

	d = setup_driver
	wait = setup_wait

  page = 1
  datas = []

	scraping(d,wait,page,datas)

	d.quit

	stop_nat_instance
	return datas
end
