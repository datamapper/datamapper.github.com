
begin
  require 'webby'
rescue LoadError
  require 'rubygems'
  require 'webby'
end

SITE = Webby.site

SITE.page_defaults = {
  'extension' => 'html',
  'layout'    => 'default'
}

SITE.host       = 'datamapper@datamapper.org'
SITE.remote_dir = 'site'
SITE.rsync_args = %w(-av --delete)

require 'lib/dochelper.rb'

# Load the other rake files in the tasks folder
Dir.glob('tasks/*.rake').sort.each {|fn| import fn}

# EOF
