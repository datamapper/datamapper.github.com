# Sinatra app to display a jekyll site.
# TODO:
# * implement posts
# * Add Cache-Control
# * test on heroku

require 'sinatra'
require 'jekyll'
require 'net/http'

# reopen albino
class Albino
  def colorize(options={})
    html  = Net::HTTP.post_form(URI.parse('http://pygments.appspot.com/'), {'lang'=> @options[:l], 'code' => @target}).body
    # Work around an RDiscount bug: http://gist.github.com/97682
    html.to_s.sub(%r{</pre></div>\Z}, "</pre>\n</div>")
  end
  alias_method :to_s, :colorize
end

set :app, __FILE__
set :jekyll_config, proc { Jekyll.configuration('source' => Sinatra::Application.root, 'server' => false) }
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


  # deal with dirs
  if File.directory?(path)
    # add a slash if we don't have one on the end.
    path << "/" if path[-1, 1] != "/"

    # look for the index
    path << "index.html"
  end

  # split things out for jekyll
  dir = path.dup
  dir[0, root.length + 1] = ""
  filename = File.basename(dir)
  dir = File.dirname(dir)


  # if it's a file, serve it.
  if File.file?(path)
    content_type(media_type(File.extname(path)) || 'application/octet-stream' )
    last_modified(File.mtime(path))
    first3 = File.open(path) { |fd| fd.read(3) }

    if first3 == "---"
      # page has a yaml header, process as page
      j = Jekyll::Page.new(options.jekyll, root, dir, filename)
      j.render(options.jekyll.layouts, options.jekyll.site_payload)
      j.output
    else
      send_file path, :disposition => nil
    end
  elsif File.file?(path.sub(/html$/,'markdown')) # look for a markdown page
    content_type "text/html", :charset => 'utf-8'
    j = Jekyll::Page.new(options.jekyll, root, dir, filename.sub(/html$/,'markdown'))
    j.render(options.jekyll.layouts, options.jekyll.site_payload)
    j.output
  else
    not_found
  end
end
