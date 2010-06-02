# TODO think about a better way
db_name = app_path.split('/').last

remove_file 'config/database.yml'
create_file 'config/database.yml' do
<<-YAML
defaults: &defaults
  adapter: sqlite3

development:
  database: #{db_name}_development.db
  <<: *defaults

  # Add more repositories
  # repositories:
  #   repo1:
  #     adapter:  postgresql
  #     database: sample_development
  #     username: the_user
  #     password: secrets
  #     host:     localhost
  #   repo2:
  #     ...

test:
  database: #{db_name}_app_test.db
  <<: *defaults
production:
  database: #{db_name}_app_production.db
  <<: *defaults
YAML
end
