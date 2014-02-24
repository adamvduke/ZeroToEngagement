#! /usr/bin/env ruby

require 'json'
require 'openssl'
require 'optparse'
require 'securerandom'
require 'socket'

# Here's where we set up our connection to apples apn service
host = 'gateway.push.apple.com'
port = 2195

p12 = "/Users/adamd/Desktop/WebsitePush.p12"
pass = nil
raise "The path to your pem file is not set." unless p12
raise "The path to your pem file does not exist!" unless File.exist?(p12)

# setup an SSL context
context      = OpenSSL::SSL::SSLContext.new
pkcs12 = OpenSSL::PKCS12.new(File.read(p12), nil)
context.cert = OpenSSL::X509::Certificate.new(pkcs12.certificate.to_pem)
context.key  = OpenSSL::PKey::RSA.new(pkcs12.key.to_s)

# create a socket with the context
sock         = TCPSocket.new(host, port)
ssl          = OpenSSL::SSL::SSLSocket.new(sock, context)
ssl.connect

device_token = 'DBBA3D7E190F9C998D485BB04EE62CDD50D06379712B1D92D3DC68B626AC60A6'.downcase

options = {
  "alert" => {
    "title" => "This is a test.",
    "body" => "If this had been an actual emergency...",
    "action" => "Activate"
  },
  "url-args" => ["message_id", SecureRandom.urlsafe_base64(15).tr('-_lIO0', 'qrsxyz')]
}

# wrap our notification params in the required 'aps' dictionary
payload_hash = {aps: options}

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
