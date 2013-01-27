require 'sinatra/base'

require 'sprockets-vendor_gems/extend_all'
require 'sinatra/sprockets'

require 'haml'
require 'sprockets-sass'
require 'sass'
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
      def self.run!(file, options={})
        set :json_location, file
        super options
      end

      #
      # Sprockets
      #
      register Sinatra::Sprockets
      use Module.new {
        def self.new(app)
          Rack::Builder.new(app) do
            map('/assets') { run Sinatra::Sprockets.environment }
          end
        end
      }

      #
      # JST
      #
      register Sinatra::JstPages
      serve_jst '/jst.js'

      #
      # App
      #
      enable :static
      set :public_folder, File.expand_path('../public', __FILE__)

      get '/' do
        haml :index
      end
    end
  end
end
