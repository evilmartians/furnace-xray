require 'sinatra/base'

require 'haml'
require 'sass'
require 'sprockets'
require 'sprockets/sass'
require 'sprockets/helpers'
require 'compass'
require 'coffee-script'

require_relative '../lib/jst_pages'

Compass.configuration do |config|
  config.project_path = File.dirname(__FILE__)
  config.sass_dir     = 'assets/stylesheets'
end

module Furnace
  module Xray
    class App < Sinatra::Base
      register Sinatra::JstPages

      set :static, true
      set :public_folder, File.expand_path('../public', __FILE__)
      set :sprockets, Sprockets::Environment.new(root)
      set :assets_types, %w(javascripts stylesheets images)

      def self.run!(file, options={})
        set :json_location, file
        assets_types.map{|x| sprockets.append_path ("#{root}/assets/#{x}") }
        super options
      end

      serve_jst '/jst.js'

      use Module.new {
        def self.new(app)
          Rack::Builder.new(app) do
            map('/assets') { run App.sprockets }
          end
        end
      }

      get '/' do
        haml :index
      end
    end
  end
end
