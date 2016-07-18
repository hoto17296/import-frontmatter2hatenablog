require 'base64'
require 'oauth'
require 'dotenv'

Dotenv.load

@consumer = OAuth::Consumer.new(
  ENV['CONSUMER_KEY'],
  ENV['CONSUMER_SECRET'],
  site: 'http://f.hatena.ne.jp'
)

@access_token = OAuth::AccessToken.new(
  @consumer,
  ENV['ACCESS_TOKEN'],
  ENV['ACCESS_TOKEN_SECRET'],
)

def upload(filepath)
  res = {}
  res[:type] = File.extname(filepath).sub(/\./, 'image/').sub(/jpg$/, 'jpeg')
  header = {'Accept'=>'application/xml', 'Content-Type' => 'application/xml'}
  content = Base64.encode64(open(filepath).read)
  body =<<-"EOF"
<entry xmlns=http://purl.org/atom/ns>
  <title></title>
  <content mode='base64' type='#{res[:type]}'>#{content}</content>
</entry>
  EOF

  response = @access_token.request(:post, '/atom/post', body, header)
  response.body =~ /<hatena:imageurl>(.*?)<\/hatena:imageurl>/
  res[:url] = $1
  response.body =~ /<hatena:syntax>(.*?)<\/hatena:syntax>/
  res[:id] = $1

  return res
end

ARGV.each do |filepath|
  next if File::ftype(filepath) == "directory"
  res = upload(filepath)
  puts "#{res[:type]}\t#{res[:url]}\t#{res[:id]}\t#{filepath}"
end
