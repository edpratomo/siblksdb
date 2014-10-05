require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Siblksdb
  class Application < Rails::Application
    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Jakarta'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    config.i18n.default_locale = :id

    config.generators do |g|
      g.template_engine = :erb
    end

    config.action_view.field_error_proc = Proc.new do |html_tag, instance|
      html = %(<div class="field_with_errors">#{html_tag}</div>).html_safe
      # add nokogiri gem to Gemfile
      elements = Nokogiri::HTML::DocumentFragment.parse(html_tag).css "label, input"
      elements.each do |e|
        if e.node_name.eql? 'label'
          # html = %(<div class="clearfix error">#{e}</div>).html_safe
          html = "#{e}".html_safe
        elsif e.node_name.eql? 'input'
          if instance.error_message.kind_of?(Array)
            html = %(<div class="field_with_errors">#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message.join(',')}</span></div>).html_safe
          else
            html = %(<div class="field_with_errors">#{html_tag}<span class="help-inline">&nbsp;#{instance.error_message}</span></div>).html_safe
          end
        end
      end
      html
    end
  end
end
