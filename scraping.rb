# require	"selenium-webdriver"
# require 'pry'

d = Selenium::WebDriver.for :chrome

# switch_price

d.navigate.to 'https://kakaku.com/game/game-console/itemlist.aspx?pdf_se=16'

content = d.find_element(:xpath,'//*[@id="main"]/div[2]/div[1]/div/table/tbody/tr[2]/td[1]')
pp content.text

return content.text
d.quit
