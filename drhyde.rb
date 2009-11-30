#!/usr/bin/ruby
# drhyde.rb
# Jonathan D. Stott <jonathan.stott@gmail.com>

require 'sinatra'
require 'jekyll'
require 'net/http'

# reopen albino
class Albino
  def initialize(target, lexer = :text, format = :html)
    @target  = File.exists?(target) ? File.read(target) : target rescue target
    @options = { :l => lexer, :f => format, :O => 'encoding=utf-8' }
  end

  def colorize(options={})
    html  = Net::HTTP.post_form(URI.parse('http://pygments.appspot.com/'), {'lang'=> @options[:l], 'code' => @target}).body
    puts html
    # Work around an RDiscount bug: http://gist.github.com/97682
    html.to_s.sub(%r{</pre></div>\Z}, "</pre>\n</div>")
  end
  alias_method :to_s, :colorize
end

set :app, __FILE__
set :jekyll_config, proc { Jekyll.configuration('source' => Sinatra::Application.root, 'server' => false, 'markdown'     => 'rdiscount') }
set :jekyll, proc {
  j = Jekyll::Site.new(Sinatra::Application.jekyll_config)
  j.read_layouts
  j
}
disable :static
disable :logging # avoid double logging with webrick

not_found do
  send_file(File.join(options.root, '404.html'))
end

# if it starts with an underscore, don't find it
get %r{/_.*} do
  not_found
end

get %r{^.*$} do
  # taken from sinatra.  check against traversal attacks.
  root = File.expand_path(options.root)
  path = File.expand_path(root + unescape(request.path_info))
  pass if path[0, root.length] != root
  unescaped_path = path.dup
  unescaped_path[0, root.length + 1] = ""

  # deal with root dir or dirs without slashes.
  if File.directory?(path) or unescaped_path == ""
    unescaped_path << "/"
  end

  if unescaped_path[-1, 1] == "/"
    dir = unescaped_path
    base = "index"
    ext = ".html"
  else

    # find the file extension and base
    dir = File.dirname(unescaped_path)
    ext = File.extname(unescaped_path)
    base = File.basename(unescaped_path, ".*")
  end
#  p dir, base, ext

#  p File.join(dir,(base + '.markdown')), File.exist?(File.join(dir,(base + '.markdown')))

  case ext
  when "", ".htm", ".html"
    if File.file?(path)
      send_file(path, :disposition => nil)
    elsif File.exist?(file = File.join(dir,(base + '.markdown')))
      content_type "text/html"
#      last_modified File.mtime(file)
      j = Jekyll::Page.new(options.jekyll, root, dir, base + '.markdown')
      p options.jekyll.layouts, options.jekyll.site_payload
      j.render(options.jekyll.layouts, options.jekyll.site_payload)
      j.output
    else
      not_found
    end
  else 
    send_file(path)
  end
end
