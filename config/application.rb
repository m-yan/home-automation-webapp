require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'action_dispatch/xml_params_parser'

module Kohaku
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Tokyo'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = :ja

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # to auto load lib/ directory
    config.eager_load_paths += %W(#{config.root}/lib #{config.root}/app/validators/ #{config.root}/app/parameters/)

    config.middleware.insert_after ActionDispatch::ParamsParser, ActionDispatch::XmlParamsParser
    config.active_job.queue_adapter = :sidekiq

    #grape
    config.paths.add File.join('app', 'api'), glob: File.join('**', '*.rb')
    config.eager_load_paths += Dir[Rails.root.join('app', 'api', '*')]
    config.middleware.use(Rack::Config) do |env|
      env['api.tilt.root'] = Rails.root.join "app", "views", "api"
    end    
   
    #ParseError対策 
    config.middleware.insert_before ActionDispatch::ParamsParser, 'RescueJsonParseErrors'


  end
end
