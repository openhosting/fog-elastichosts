require './fog/elasticstack/constants'

if e=ENV['ESAUTH']
  USERNAME,PASSWORD=e.split(/:/)
end

class ESConnection
  ENDPOINT="https://api-east1.openhosting.com"
  include Faraday
  # remember, this is a method, not a symbol and takes a symbol to a method as arguments!
  attr_accessor :connect

  @@conn = Faraday.new( :url => ENDPOINT, :headers => {"Content-Type" => "application/json", "Accept" => "application/json"}) do |faraday|
    # Prolly will be relevant!
    # https://github.com/lostisland/faraday/wiki/Setting-up-SSL-certificates
    faraday.ssl
    faraday.request :multipart
    faraday.request :url_encoded
    faraday.response :logger
    faraday.adapter :patron
    faraday.basic_auth USERNAME, PASSWORD
  end

  def self.connect
    return @@conn
  end
end
