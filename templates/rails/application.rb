# This needs to be called after one of the gemfile templates

apply 'http://datamapper.org/templates/rails/config.rb'
apply 'http://datamapper.org/templates/rails/database.yml.rb'

inject_into_file  'app/controllers/application_controller.rb',
                  "require 'dm-rails/middleware/identity_map'\n",
                  :before => 'class ApplicationController'

inject_into_class 'app/controllers/application_controller.rb',
                  'ApplicationController',
                  "  use Rails::DataMapper::Middleware::IdentityMap\n"

initializer 'jruby_monkey_patch.rb', <<-CODE
if RUBY_PLATFORM =~ /java/
  # ignore the anchor to allow this to work with jruby:
  # http://jira.codehaus.org/browse/JRUBY-4649
  class Rack::Mount::Strexp

    class << self
      alias :compile_old :compile
      def compile(str, requirements, separators, anchor)
        self.compile_old(str, requirements, separators)
      end
    end
  end
end
CODE

say ''
say '---------------------------------------------------------------------------'
say 'Have a look at the dm-rails README:   http://github.com/datamapper/dm-rails'
say '---------------------------------------------------------------------------'
say 'Have a look at available rake tasks:  rake -T'
say 'Generate a simple scaffold:           rails g scaffold Person name:string'
say 'Create, automigrate and seed the DB:  rake db:setup'
say 'Start the server:                     script/rails server'
say '---------------------------------------------------------------------------'
say 'After the server booted, point your browser at http://localhost:3000/people'
say '---------------------------------------------------------------------------'
say ''
