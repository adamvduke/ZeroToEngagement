#! /usr/bin/env ruby

require 'json'
require 'openssl'
require 'optparse'
require 'socket'

# ./ios_push.rb -a 'Hello Baltimore Cocoa' -b 2 -s 'default' -t 'e0d55aff8ccfb9335304bb220b51281cca442735ecb776f53201242827531c57'
# ./ios_push.rb -a 'Hello Baltimore Cocoa' -b 2 -s 'default' -t 'e0d55aff8ccfb9335304bb220b51281cca442735ecb776f53201242827531c57' -i '{"type":"chat", "user_id":12345}'

# Do some option parsing
options = {}
options_parser = OptionParser.new do |opts|
  opts.banner = 'Usage: ios_push.rb [options]'

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

p12 = "/Users/adamd/Desktop/ZeroPushDemo.p12"
pass = nil
raise "The path to your pem file is not set." unless p12
raise "The path to your pem file does not exist!" unless File.exist?(p12)

# setup an SSL context
context      = OpenSSL::SSL::SSLContext.new
pkcs12       = OpenSSL::PKCS12.new(File.read(p12), nil)
context.cert = OpenSSL::X509::Certificate.new(pkcs12.certificate.to_pem)
context.key  = OpenSSL::PKey::RSA.new(pkcs12.key.to_s)

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
