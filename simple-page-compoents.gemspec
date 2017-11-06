# coding: utf-8
Gem::Specification.new do |s|
  s.name          = 'simple-page-compoents'
  s.version       = '0.0.8.3'
  s.platform      = Gem::Platform::RUBY
  s.date          = '2017-08-25'
  s.summary       = 'simple page compoents'
  s.description   = 'to add some ui compoents for rails3.'
  s.authors       = 'ben7th'
  s.email         = 'ben7th@sina.com'
  s.homepage      = 'https://github.com/ahdingyantech/simple-page-compoents'
  s.licenses      = 'MIT'

  s.files         = Dir.glob("lib/**/*") + Dir.glob("vendor/**/*") + %w(README.md)
  s.require_paths = ['lib']
  
end