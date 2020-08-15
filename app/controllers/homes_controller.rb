class HomesController < ApplicationController
	# require	"selenium-webdriver"
	# require 'pry'

	def top
	end

	def scr2
		require 'open_uri'
		# # headlessモード
		# options = Selenium::WebDriver::Chrome::Options.new
		# options.add_argument('--headless')
		# d = Selenium::WebDriver.for :chrome, options: options

		#通常モード
		d = Selenium::WebDriver.for :chrome

		# 検索ページへ遷移
		d.navigate.to 'https://www.google.co.jp/imghp?hl=ja&tab=ri&authuser=0&ogbl'

		#入力した内容を検索バーに入力

		# search_bar = d.find_element(:xapth,"id('sbtc')//input[contains(@title,'検索')]")
		search_bar = d.find_element(:name,"q")
		# search_bar.send_key(params[:word], :enter)
		search_bar.send_key("レモン", :enter)
		sleep(1)

		#検索
		# search_bar.submit
		# sleep(2)

		#ライセンスフリーの画像に絞り込む（「ツール」→「ライセンス」→「再使用が許可された画像」を選択）
		#ツールをクリック
		tool = d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[1]/div/div[1]/div[2]/div[2]/div/div")
		tool.click
		#ライセンスをクリック
		begin
			pp "①"
			pull_down = d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[2]/c-wiz[1]/div/div/div[1]/div/div[3]/div/div[1]")
		rescue
			pp "①NG"
		end

		begin
			pp "②"
			pull_down = d.find_element(:xpath,"id('yDmH0d')//div[contains(@aria-label,'ライセンス')")
		rescue
			pp "②NG"
		end
		pull_down.click

		#プルダウンから再使用が許可された画像を選択
		l = d.find_element(:link_text,"再使用が許可された画像")
		l.click
		sleep(2)

		#画像要素を取得
		imgs = d.find_elements(:xpath,"id('islrg')/div[1]/div/a[1]/div[1]/img")
		imgs = d.find_elements(:xpath,"id('islrg')//img")

		#取得した要素から画像を繰り返し処理で1つずつデータベースに保管
		n = 1
		imgs.each do |img|
			img_url = img.attribute('href')
			File.open(params[:word]+n,"wb") do |file|
				open(img_url) do |i|
					file.puts i.read
				end
			end
			n += 1
		end

		#終了？
		d.quit
	end
end
