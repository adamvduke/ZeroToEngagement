#! /usr/bin/env ruby

require 'json'
require 'openssl'
require 'optparse'
require 'socket'

# ./push.rb -a 'Hello Philly Cocoa' -b 2 -s 'default' -t '399aac70e191943153a5c9c291fd75fda369c3c6d5c7c3eb77a8c2ae601bd6c5'
# ./push.rb -a 'Hello Philly Cocoa' -b 2 -s 'default' -t '399aac70e191943153a5c9c291fd75fda369c3c6d5c7c3eb77a8c2ae601bd6c5' -i '{"type":"chat", "user_id":12345}'

# Do some option parsing
options = {}
options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: push.rb [options]'

  opts.on('-a', '--alert TEXT required', 'The text of the alert to send') do |opt|
    options[:alert] = opt
  end
  
  opts.on('-b', '--badge INTEGER required', 'The badge number to set') do |opt|
    options[:badge] = opt.to_i
  end
  
  opts.on('-s', '--sound TEXT required', 'The sound to play along with the alert') do |opt|
    options[:sound] = opt
  end
  
  opts.on('-t', '--token TEXT required', 'The device token to notify') do |opt|
    options[:token] = opt
  end
  
  opts.on('-i', '--info JSON optional', 'Optional information to include in the notification') do |opt|
    options[:info] = opt
  end
end

options_parser.parse!

# check the required options
# strictly they aren't all required, but for the demo we'll treat them that way
[:alert, :badge, :sound, :token].each do |opt|
  if options[opt].nil?
    puts options_parser.help
    exit 1
  end
end

# Here's where we set up our connection to apples apn service
host = 'gateway.sandbox.push.apple.com'
port = 2195

# openssl pkcs12 -in mycert.p12 -out client-cert.pem -nodes -clcerts
pem = "/path/to/your/demo.pem"
pass = nil
raise "The path to your pem file is not set." unless pem
raise "The path to your pem file does not exist!" unless File.exist?(pem)

# setup an SSL context
context      = OpenSSL::SSL::SSLContext.new
context.cert = OpenSSL::X509::Certificate.new(File.read(pem))
context.key  = OpenSSL::PKey::RSA.new(File.read(pem), pass)

# create a socket with the context
sock         = TCPSocket.new(host, port)
ssl          = OpenSSL::SSL::SSLSocket.new(sock,context)
ssl.connect

# start getting our notification together

# remove the device token from the parsed options and hold on to it
device_token = options.delete(:token)

info_string = options.delete(:info) if options[:info]

# wrap our notification params in the required 'aps' dictionary
payload_hash = {aps: options}

# if there is extra info remove it from 
if info_string
  info = JSON.parse(info_string)
  payload_hash[:info] = info
end
payload = JSON.dump(payload_hash)

identifier = 0
expiry_epoch_time = 0
device_token_length = 32
notification_bytes = [ 1,
                       identifier,
                       expiry_epoch_time,
                       device_token_length,
                       device_token,
                       payload.bytesize,
                       payload
                     ].pack('CNNnH64nA*')
                     
ssl.write(notification_bytes)
ssl.close
sock.close

puts "Sent:\n #{payload} \n to device: #{device_token}"