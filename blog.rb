require 'selenium-webdriver'
require 'dotenv'

Dotenv.load

@driver = Selenium::WebDriver.for :chrome

def login(id, password)
  @driver.navigate.to 'https://www.hatena.ne.jp/login'
  form = @driver.find_element(:css, 'form[action="/login"]')
  form.find_element(:css, 'input[name="name"]').send_keys(id)
  form.find_element(:css, 'input[name="password"]').send_keys(password)
  form.find_element(:css, 'input[type="submit"]').click
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  wait.until { @driver.current_url == 'http://www.hatena.ne.jp/' }
end

def post(title, body, date, url)
  @driver.navigate.to "http://blog.hatena.ne.jp/#{ENV['HATENA_ID']}/#{ENV['HATENA_BLOG_ID']}/edit"
  form = @driver.find_element(:id, 'edit-form')
  form.find_element(:css, '[data-support-type="editor-option"]').click
  form.find_element(:id, 'title').send_keys(title)
  form.find_element(:id, 'body').send_keys(body)
  form.find_element(:id, 'datetime-input-date').send_keys(date)
  form.find_element(:id, 'customurl-input').send_keys(url)
  # TODO submit
end

login(ENV['HATENA_ID'], ENV['HATENA_PASSWORD'])
post('タイトル', '本文', '2016-01-01', 'test')

#@driver.quit
