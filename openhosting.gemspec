lib = "openhosting"
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1

Gem::Specification.new do |gem|
  gem.name          = lib
  gem.version       = version
  gem.authors       = ["Lee Azzarello"]
  gem.email         = ["lee@openhosting.com"]
  gem.description   = "This is a library which implements the Open Hosting API. It can be used to create, modify and delete virtual servers, drives and associated resources like IP addresses and vlans. It can also be used as a general purpose upload/download interface for the contents of virtual drives. It is based on the Elastic Hosts API."
  gem.summary       = "Open Hosting API client library"
  gem.homepage      = "https://code.seriesdigital.com/lee/openhosting-api-clients/tree/master/oh-api-ruby"
  gem.license       = "GPLv3"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.cert_chain  = ['certs/lazzarello.pem']
  gem.signing_key = File.expand_path("~/etc/gem-private_key.pem") if $0 =~ /gem\z/

  #gem.add_dependency = 'faraday', '>= 0.9.1'
  #gem.add_development_dependency 'bundler', '~> 1.0'
end
