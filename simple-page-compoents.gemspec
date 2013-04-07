# coding: utf-8
Gem::Specification.new do |s|
  s.name          = 'simple-page-compoents'
  s.version       = '0.0.7.3'
  s.platform      = Gem::Platform::RUBY
  s.date          = '2013-03-11'
  s.summary       = 'simple page compoents'
  s.description   = 'to add some ui compoents for rails3.'
  s.authors       = 'ben7th'
  s.email         = 'ben7th@sina.com'
  s.homepage      = 'https://github.com/mindpin/simple-images'
  s.licenses      = 'MIT'

  s.files         = Dir.glob("lib/**/*") + Dir.glob("vendor/**/*") + %w(README.md)
  s.require_paths = ['lib']
  
end