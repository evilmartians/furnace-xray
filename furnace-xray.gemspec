# encoding: utf-8 

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'furnace-xray/version'

Gem::Specification.new do |gem|
  gem.name          = 'furnace-xray'
  gem.version       = Furnace::Xray::VERSION
  gem.authors       = ['Boris Staal']
  gem.email         = ['staal@evl.ms']
  gem.description   = 'A visualizer for transformations of code in Static Single Assignment form based on the Furnace library.'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/evilmartians/furnace-xray'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'trollop'
  gem.add_dependency 'sprockets', '~> 2.0.0'
  gem.add_dependency 'sinatra'
  gem.add_dependency 'sinatra-sprockets-ext'
  gem.add_dependency 'activesupport'
  gem.add_dependency 'sprockets-vendor_gems'
  gem.add_dependency 'haml'
  gem.add_dependency 'sass'
  gem.add_dependency 'sprockets-sass'
  gem.add_dependency 'compass'
  gem.add_dependency 'coffee-script'
end
