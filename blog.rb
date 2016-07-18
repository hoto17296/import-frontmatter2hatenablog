require 'selenium-webdriver'
require 'dotenv'
require 'yaml'
require './imagepathconverter'

Dotenv.load

@driver = Selenium::WebDriver.for :chrome
@wait = Selenium::WebDriver::Wait.new(:timeout => 10)

def login(id, password)
  @driver.navigate.to 'https://www.hatena.ne.jp/login'
  form = @driver.find_element(:css, 'form[action="/login"]')
  form.find_element(:css, 'input[name="name"]').send_keys(id)
  form.find_element(:css, 'input[name="password"]').send_keys(password)
  form.find_element(:css, 'input[type="submit"]').click
  @wait.until { @driver.current_url == 'http://www.hatena.ne.jp/' }
end

def post(title, body, date, url, eyecatch=nil, description=nil)
  @driver.navigate.to "http://blog.hatena.ne.jp/#{ENV['HATENA_ID']}/#{ENV['HATENA_BLOG_ID']}/edit"
  form = @driver.find_element(:id, 'edit-form')
  form.find_element(:css, '[data-support-type="editor-option"]').click
  form.find_element(:id, 'title').send_keys(title)
  form.find_element(:id, 'body').send_keys(body)
  form.find_element(:id, 'datetime-input-date').send_keys(date)
  form.find_element(:id, 'customurl-input').send_keys(url)
  form.find_element(:id, 'ogimage-input').send_keys(eyecatch) if eyecatch
  form.find_element(:id, 'og-description-input').send_keys(description) if description
  form.find_element(:id, 'submit-button').click
  @wait.until { @driver.find_element(:css, '.edit-done') }
end

login(ENV['HATENA_ID'], ENV['HATENA_PASSWORD'])

image = ImagePathConverter.new('./images.tsv')

ARGV.each do |filepath|
  next if File::ftype(filepath) == "directory"
  opts = YAML.load_file(filepath)
  puts opts
  File.open(filepath) do |file|
    body = file.read.sub(/---(.|\n)*?---/, '')
    body = body.gsub("\t", '  ')
    body = body.gsub(/!\[.*?\]\(\/images\/(.+?)\)/) do
      if image[$1]
        "[#{image[$1][:id]}]"
      else
        puts "Error: Image '#{$1}' is not uploaded."
      end
    end
    url = File.basename(filepath, '.*').sub(/^\d{4}-\d{2}-\d{2}-(.+)$/) { $1 }
    eyecatch = image[opts['image']] ? image[opts['image']][:url] : nil
    post(opts['title'], body, opts['date'], url, eyecatch, opts['description'])
  end
end

@driver.quit
