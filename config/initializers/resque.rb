require 'resque/server'
require 'resque/scheduler/server'
require 'active_scheduler'

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

resque_config = YAML.load_file(rails_root + '/config/resque.yml')
Resque.redis = resque_config[rails_env]

yaml_schedule    = YAML.load_file("#{Rails.root}/config/resque_schedule.yaml") || {}
wrapped_schedule = ActiveScheduler::ResqueWrapper.wrap yaml_schedule
Resque.schedule  = wrapped_schedule