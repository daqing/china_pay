# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'china_pay/version'

Gem::Specification.new do |gem|
  gem.name          = "china_pay"
  gem.version       = ChinaPay::VERSION
  gem.authors       = ["Devin Zhang"]
  gem.email         = ["daqing1986@gmail.com"]
  gem.description   = %q{This gem can help you integrate Alipay, Tenpay and 99bill to your application.}
  gem.summary       = %q{A simple payment library for china payment gateways}
  gem.homepage      = "https://github.com/daqing/china_pay"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
