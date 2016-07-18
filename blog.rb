require 'selenium-webdriver'
require 'dotenv'

Dotenv.load

driver = Selenium::WebDriver.for :chrome

# ログイン
driver.navigate.to 'https://www.hatena.ne.jp/login'
form = driver.find_element(:css, 'form[action="/login"]')
form.find_element(:css, 'input[name="name"]').send_keys(ENV['HATENA_ID'])
form.find_element(:css, 'input[name="password"]').send_keys(ENV['HATENA_PASSWORD'])
form.find_element(:css, 'input[type="submit"]').click
wait = Selenium::WebDriver::Wait.new(:timeout => 10)
wait.until { driver.current_url == 'http://www.hatena.ne.jp/' }

# 投稿
driver.navigate.to "http://blog.hatena.ne.jp/#{ENV['HATENA_ID']}/#{ENV['HATENA_BLOG_ID']}/edit"
form = driver.find_element(:id, 'edit-form')
form.find_element(:css, '[data-support-type="editor-option"]').click
form.find_element(:id, 'title').send_keys('タイトル')
form.find_element(:id, 'body').send_keys('本文')
form.find_element(:id, 'datetime-input-date').send_keys('2016-01-01')
form.find_element(:id, 'customurl-input').send_keys('test')

#driver.quit
