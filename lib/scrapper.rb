require "nokogiri"
require 'selenium-webdriver'

BASE_URL = "https://www.google.com/search".freeze

print "Введите ключевое слово для поиска: "
KEYWORD = gets.chomp

print "Введите прокси (или оставьте пустым для пропуска): "
proxy = gets.chomp

options = Selenium::WebDriver::Chrome::Options.new
options.add_argument('--headless')
if proxy && !proxy.empty?
  options.add_argument("--proxy-server=#{proxy}")
end

driver = Selenium::WebDriver.for :chrome, options: options

def parse_links(raw_data)
  doc = Nokogiri::HTML(raw_data)
  doc.css('a[jsname="UWckNb"]').map { |a| a['href'] }
end

encoded_key = URI.encode_www_form(q: KEYWORD)
url = "#{BASE_URL}?#{encoded_key}&num=50"

# selenium_moment - гугл за раз отдает не больше 10 ответов, остальные 40 он подгружает через js,
# поэтому тут пришлось использовать селениум для полной прогрузки результатов
driver.get(url)
sleep(5)
html = driver.page_source
html ?  results = parse_links(html) : results = []
results.each {| result | puts result}
driver.quit

