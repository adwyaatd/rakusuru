require	"selenium-webdriver"
require "logger"
require "pp"

def check_element(d,attri,val,text="")
	wait = Selenium::WebDriver::Wait.new(:timeout => 2)
	pp text
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

# def check_base(d)
# 	ret = true
# 	begin
# 		element = d.find_element(:name,"copyright").attribute("content")
# 	rescue
# 		ret = false
# 	else
# 		if !element.include?("BASE")
# 			ret = false
# 		end
# 	end
# 	return ret
# end

wait = Selenium::WebDriver::Wait.new(:timeout => 5)

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
d = Selenium::WebDriver.for :chrome, options: options
# d = Selenium::WebDriver.for :chrome

page = 1

# logger.debug("検索ページへ遷移")
d.navigate.to 'https://nanakurakomb.thebase.in/items/2845878'

# d.navigate.to 'https://www.google.co.jp/'

# search_bar = d.find_element(:name,"q")
# search_bar.send_key("site:*.thebase.in ファッション", :enter)

# contact_url = d.find_element(:xpath, "//a[contains(@href,'/inquiry/')]").attribute("href")
# pp contact_url

# current_url = d.current_url
# pp current_url

# if %r(^https?://.*/.+) =~ current_url
# 	home_url = current_url.slice(%r{^https?://.*?/})
# 	pp home_url
# 	d.navigate.to home_url
# end


# contact_url = d.find_element(:xpath, "//a[contains(@href,'/inquiry/')]").attribute("href")
# pp contact_url

# shop_url = d.current_url
# pp shop_url

# unless check_element(d,:xpath,"/html/head","BASE")
# 	pp "Base以外に入った"
# else
# 	pp __LINE__
# end

# page += 1
# if check_element(d,:link_text,page)
# 	d.find_element(:link_text,page).click
# else
# 	pp "次ページなし"
# end

pp check_element(d,:xpath,"//a[contains(@href,'base')]")

d.quit
return

# current_url = "https://kyodophoto.thebase.in/items/32068688"


# if %r(^https?://.*/.+) =~ current_url
# 	home_url = current_url.slice(%r{^https?://.*?/})
# 	d.navigate.to home_url
# end

# r = t.slice(%r{^https?://.*?/})
# pp r
