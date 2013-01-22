require 'sinatra/base'

require 'sprockets-vendor_gems/extend_all'
require 'sinatra/sprockets'

require 'haml'
require 'sprockets-sass'
require 'sass'
require 'compass'
require 'coffee-script'

module Foundry
  module Xray
    class App < Sinatra::Base
      register Sinatra::Sprockets

      Compass.configuration do |config|
        config.project_path = File.dirname(__FILE__)
        config.sass_dir     = 'assets/stylesheets'
      end

      use Module.new {
        def self.new(app)
          Rack::Builder.new(app) do
            map('/assets') { run Sinatra::Sprockets.environment }
          end
        end
      }

      set :static,        true
      set :public_folder, File.expand_path('..', __FILE__)

      def self.run!(json, options={})
        set :foundry_json, json
        super options
      end

      get '/' do
        haml :index
      end
    end
  end
end
