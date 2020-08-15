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

d = Selenium::WebDriver.for :chrome

d.navigate.to 'https://kakaku.com/game/game-console/itemlist.aspx?pdf_se=16'

sleep(2)

# content = d.find_element(:xpath,'//*[@id="main"]/div[2]/div[1]/div/table/tbody/tr[2]/td[1]')
content = d.find_elements(:class,'itemPrice')[0]
@price = content.text

pp @price
d.quit
return @price
