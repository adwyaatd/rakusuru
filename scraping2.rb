require	"selenium-webdriver"

retry_cnt = 0

wait = Selenium::WebDriver::Wait.new(:timeout => 5)

datas = []
# begin

  begin
    # logger.debug("headlessモード")
    # options = Selenium::WebDriver::Chrome::Options.new
    # options.add_argument('--headless')
    # d = Selenium::WebDriver.for :chrome, options: options

    # logger.debug("通常モード")
    d = Selenium::WebDriver.for :chrome

    # logger.debug("検索ページへ遷移")
		pp "ページへ"
		d.navigate.to 'https://furusato.ana.co.jp/products/ranking.php'
  rescue => e
    # logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}-------------------")
    sleep(1)
    retry_cnt += 1
    # logger.debug(retry_cnt)
    retry if retry_cnt <= 5
	end

	# ランキング順位の取得
	pp "アイテムの数を取得"
	items = d.find_elements(:xpath,"//*[@id=\"ranking_weekly\"]/ul/li")
	items_count = items.count
	pp items_count

	# 繰り返し処理で、アイテムを1つずつ取得
	n = 1 #1から始める
	while n <= items_count
		pp "カウント：#{n}"
		begin
			item_element = d.find_element(:id ,"ranking_weekly_#{n}")
		rescue
			# 同率順位があって、アイテム数＞ランキング順位数の場合はスキップ
			pp "ランキングなし"
			next
		else
			ranking = n
			item_area = d.find_element(:xpath, "//*[@id=\"ranking_weekly_#{n}\"]/a/section/h3/span[1]") # 北海道紋別市
			item_area = item_area.text
			pp item_area
			item_name = d.find_element(:xpath, "//*[@id=\"ranking_weekly_#{n}\"]/a/section/h3/span[2]") #10-68 オホーツク産ホタテ玉冷大(1kg)
			item_name = item_name.text
			pp item_name
			item_price = d.find_element(:xpath, "//*[@id=\"ranking_weekly_#{n}\"]/a/section/span[2]") # 10,000
			item_price = item_price.text
			pp item_price

			# item_area = item_infos[0].text
			# //*[@id="ranking_weekly_1"]/a/section/h3/span[1]

			# item_name = item_infos[1].text
			# //*[@id="ranking_weekly_1"]/a/section/h3/span[2]

			# item_price = item_infos[2].text
			# //*[@id="ranking_weekly_1"]/a/section/span[2]

			item_data = {ranking:ranking,item_area:item_area,item_name:item_name,item_price:item_price}
			datas.push(item_data)
		end

		# # begin
		# 	item_name = item.find_element(:class, "as-item-name-inner") #10-68 オホーツク産ホタテ玉冷大(1kg)
		# # rescue
		# 	item_name = item.find_element(:xpath, "//*[@id=\"ranking_weekly_#{n}\"]/a/section/h3/span[2]") #10-68 オホーツク産ホタテ玉冷大(1kg)
		# # end

		# # begin
		# 	item_price = item.find_element(:class, "as-item-name-inner") #10-68 オホーツク産ホタテ玉冷大(1kg)
		# # rescue => exception

		# end
		n += 1
	end

	pp datas





  # logger.debug("全ページ完了")

  # logger.debug("AllOK")
  d.quit
  return datas
# rescue => e
#   logger.debug("エラー発生")
#   logger.error("----------------------[error]file:#{$0},line:#{__LINE__},error:#{e}---------------------------")
#   d.quit
#   return datas
# end
