# workaround <<-GEMFILE wanting to
# execute the string subsitution
DATAMAPPER = '#{DATAMAPPER}'
RSPEC      = '#{RSPEC}'

remove_file 'Gemfile'
create_file 'Gemfile' do
<<-GEMFILE
source 'http://rubygems.org'

RAILS_VERSION = '~> 3.0.0.beta3'

DM_VERSION    = '~> 1.0.0.rc3'

RSPEC_VERSION = '~> 2.0.0.beta.9'

gem 'activesupport',      RAILS_VERSION, :require => 'active_support'
gem 'actionpack',         RAILS_VERSION, :require => 'action_pack'
gem 'actionmailer',       RAILS_VERSION, :require => 'action_mailer'
gem 'railties',           RAILS_VERSION, :require => 'rails'

gem 'dm-rails',             DM_VERSION
gem 'dm-sqlite-adapter',    DM_VERSION

# You can use any of the other available database adapters.
# This is only a small excerpt of the list of all available adapters
# Have a look at
#
#  http://wiki.github.com/datamapper/dm-core/adapters
#  http://wiki.github.com/datamapper/dm-core/community-plugins
#
# for a rather complete list of available datamapper adapters and plugins

# gem 'dm-mysql-adapter',     DM_VERSION
# gem 'dm-postgres-adapter',  DM_VERSION
# gem 'dm-oracle-adapter',    DM_VERSION
# gem 'dm-sqlserver-adapter', DM_VERSION

gem 'dm-migrations',        DM_VERSION
gem 'dm-types',             DM_VERSION
gem 'dm-validations',       DM_VERSION
gem 'dm-constraints',       DM_VERSION
gem 'dm-transactions',      DM_VERSION
gem 'dm-aggregates',        DM_VERSION
gem 'dm-timestamps',        DM_VERSION
gem 'dm-observer',          DM_VERSION

group(:test) do

  gem 'rspec',              RSPEC_VERSION
  gem 'rspec-core',         RSPEC_VERSION, :require => 'rspec/core'
  gem 'rspec-expectations', RSPEC_VERSION, :require => 'rspec/expectations'
  gem 'rspec-mocks',        RSPEC_VERSION, :require => 'rspec/mocks'
  gem 'rspec-rails',        '~> 2.0.0.beta.9.1'

end

# ------------------------------------------------------------------------------

# These gems are only listed here in the Gemfile because we want to pin them
# to the github repositories for as long as no stable version has been released.
# The dm-core gem is a hard dependency for dm-rails so it would get pulled in by
# simply adding dm-rails. The dm-do-adapter gem is a hard dependency for any of
# the available dm-xxx-adapters. Once we have stable gems available, pinning these
# gems to github will be optional.

gem 'dm-core',              DM_VERSION
gem 'dm-do-adapter',        DM_VERSION
gem 'dm-active_model',      DM_VERSION
GEMFILE
end
