require 'rswag/ui/middleware'
require 'rswag/ui/basic_auth'

module Rswag
  module Ui
    class Engine < ::Rails::Engine
      isolate_namespace Rswag::Ui

      initializer 'rswag-ui.initialize' do |app|
        middleware.use Rswag::Ui::Middleware, Rswag::Ui.config

        if Rswag::Ui.config.basic_auth_enabled
          c = Rswag::Ui.config
          app.middleware.use Rswag::Ui::BasicAuth do |username, password|
            c.config_object[:urls] = c.config_object[:urls_sample]
            auth = { username: username, password: password }
            users = c.config_object[:basic_auth].select { |basic_auth| basic_auth == auth }
            urls = c.config_object[:urls].select{ |url| url[:url].include?(username) }
            c.config_object[:urls] = urls if urls.any?

            users.any?
          end
        end
      end

      rake_tasks do
        load File.expand_path('../../../tasks/rswag-ui_tasks.rake', __FILE__)
      end
    end
  end
end
