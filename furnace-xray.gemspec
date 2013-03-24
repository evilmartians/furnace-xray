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

  gem.add_dependency 'sinatra'
  gem.add_dependency 'trollop'
  gem.add_dependency 'activesupport'

  gem.add_dependency 'haml',                      '3.1.7'
  gem.add_dependency 'sass',                      '3.2.5'
  gem.add_dependency 'sprockets',                 '2.8.2'
  gem.add_dependency 'sprockets-sass',            '0.9.1'
  gem.add_dependency 'sprockets-helpers',         '0.8.0'
  gem.add_dependency 'coffee-script'
  gem.add_dependency 'compass'
end
