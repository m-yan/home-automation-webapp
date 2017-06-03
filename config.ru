# This file is used by Rack-based servers to start the application.

#require 'grape/jbuilder'

#use Rack::Config do |env|
#  env['api.tilt.root'] = '/opt/kohaku/app/views/api'
#end

require ::File.expand_path('../config/environment', __FILE__)
map ActionController::Base.config.relative_url_root || "/" do
  run Rails.application
end
