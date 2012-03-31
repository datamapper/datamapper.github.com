gsub_file 'config/application.rb', /require 'rails\/all'/ do
<<-RUBY
# Comment out the frameworks you don't want (if you don't want ActionMailer,
# make sure to comment out the `config.action_mailer` lines in your
# config/environments/development.rb and config/environments/test.rb files):
require 'action_controller/railtie'
require 'dm-rails/railtie'
require 'sprockets/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'
RUBY
end
