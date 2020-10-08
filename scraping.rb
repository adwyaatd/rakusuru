require	"selenium-webdriver"
# require 'pry'

# d = Selenium::WebDriver.for :chrome

# d.navigate.to 'https://kakaku.com/game/game-console/itemlist.aspx?pdf_se=16'

# sleep(2)

# # content = d.find_element(:xpath,'//*[@id="main"]/div[2]/div[1]/div/table/tbody/tr[2]/td[1]')
# content = d.find_elements(:class,'itemPrice')[0]
# @price = content.text

# pp @price

# # sleep(10)
# d.quit

# d = Selenium::WebDriver.for :chrome

# d.navigate.to 'https://kakaku.com/game/game-console/itemlist.aspx?pdf_se=16'

# sleep(2)

# # content = d.find_element(:xpath,'//*[@id="main"]/div[2]/div[1]/div/table/tbody/tr[2]/td[1]')
# content = d.find_elements(:class,'itemPrice')[0]
# @price = content.text

# pp @price
# d.quit
# return @price

# d = Selenium::WebDriver.for :chrome

# # 検索ページへ遷移
# d.navigate.to 'https://www.google.co.jp/imghp?hl=ja&tab=ri&authuser=0&ogbl'

# sleep(2)

# #入力した内容を検索バーに入力

# # search_bar = d.find_element(:xapth,"id('sbtc')//input[contains(@title,'検索')]")
# search_bar = d.find_element(:name,"q")
# # search_bar.send_key(params[:word], :enter)
# search_bar.send_key("レモン", :enter)
# sleep(2)

# #検索
# # search_bar.submit
# # sleep(2)

# #ライセンスフリーの画像に絞り込む（「ツール」→「ライセンス」→「再使用が許可された画像」を選択）
# #ツールをクリック
# tool = d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[1]/div/div[1]/div[2]/div[2]/div/div")
# tool.click
# #ライセンスをクリック
# begin
# 	pp "①"
# 	pull_down = d.find_element(:xpath,"//*[@id=\"yDmH0d\"]/div[2]/c-wiz/div[2]/c-wiz[1]/div/div/div[1]/div/div[3]/div/div[1]")
# rescue
# 	pp "①NG"
# end

# begin
# 	pp "②"
# 	pull_down = d.find_element(:xpath,"id('yDmH0d')//div[contains(@aria-label,'ライセンス')")
# rescue
# 	pp "②NG"
# end
# pull_down.click
# sleep(2)

# #プルダウンから再使用が許可された画像を選択
# l = d.find_element(:link_text,"再使用が許可された画像")
# l.click
# sleep(2)

# #画像要素を取得
# # imgs = d.find_elements(:xpath,"id('islrg')/div[1]/div/a[1]/div[1]/img")
# pp __LINE__
# begin
#   pp "①"
# 	imgs = d.find_elements(:xpath,"id('islrg')//img")
# rescue
#   pp "①NG"
# end
# pp "ok"
# sleep(5)

# n=1
# array = []
# imgs.each do |i|
# 	imgsrc = i.attribute('src')
# 	pp imgsrc
# 	array[n-1] = imgsrc
# 	pp __LINE__
# 	pp array

# 	n +=1
# 	if n == 11
# 		break
# 	end
# end

# #取得した要素から画像を繰り返し処理で1つずつデータベースに保管

# # imgs.each do |img|
# # 	img_url = img.attribute('href')
# # 	File.open(params[:name]+n,"wb") do |file|
# # 		open(img_url) do |i|
# # 			file.puts i.read
# # 		end
# # 	end
# # 	n += 1
# # 	if n==31
# # 		break
# # 	end
# # end

# #終了？
# d.quit

# require 'open_uri'
# # headlessモード
# options = Selenium::WebDriver::Chrome::Options.new
# options.add_argument('--headless')
# d = Selenium::WebDriver.for :chrome, options: options

#通常モード
d = Selenium::WebDriver.for :chrome

# 検索ページへ遷移
d.navigate.to 'https://www.google.co.jp/imghp?hl=ja&tab=ri&authuser=0&ogbl'

sleep(2)

#入力した内容を検索バーに入力

# search_bar = d.find_element(:xapth,"id('sbtc')//input[contains(@title,'検索')]")
search_bar = d.find_element(:name,"q")
# search_bar.send_key(params[:word], :enter)
search_bar.send_key("レモン", :enter)
sleep(2)

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
sleep(2)

#プルダウンから再使用が許可された画像を選択
l = d.find_element(:link_text,"再使用が許可された画像")
l.click
sleep(2)

#画像要素を取得
# imgs = d.find_elements(:xpath,"id('islrg')/div[1]/div/a[1]/div[1]/img")
pp __LINE__
begin
	pp "①"
	imgs = d.find_elements(:xpath,"id('islrg')//img")
rescue
	pp "①NG"
end
pp "ok"
sleep(5)

n=1
array = []
imgs.each do |i|
	img_src = i.attribute('src')
	array[n-1] = img_src

	n +=1
	if n == 11
		pp "OKOK"
		break
	end
end

# n=1
# imgs.each do |i|
# 	@imgsrc = i.attribute('src')
# 	pp imgsrc
# 	n +=1
# 	if n == 11
# 		break
# 	end
# end

#取得した要素から画像を繰り返し処理で1つずつデータベースに保管

# imgs.each do |img|
# 	img_url = img.attribute('href')
# 	File.open(params[:name]+n,"wb") do |file|
# 		open(img_url) do |i|
# 			file.puts i.read
# 		end
# 	end
# 	n += 1
# 	if n==31
# 		break
# 	end
# end

#終了？
pp "AllOK"
return array
d.quit




######
