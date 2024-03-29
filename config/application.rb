require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ReminderBot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.time_zone = 'Moscow'
    config.i18n.default_locale = :ru
    config.active_record.default_timezone = :local
    config.active_job.queue_adapter = :good_job
    config.telegram_updates_controller.session_store = :file_store, Rails.root.join('tmp/session_store')
    config.good_job.enable_cron = true
    config.good_job.cron = { example: { cron: '0 9 * * *', class: 'BirthdayJob'  } }
  end
end
