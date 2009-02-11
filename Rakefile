require 'grancher/task'
Grancher::Task.new do |g|
  g.branch = 'master'
  g.push_to = 'origin'
  g.repo = '.'          # defaults to '.'
  g.message = 'Updated website' # defaults to 'Updated files.'

  # Put the website-directory in the root
  g.directory 'output'

  # doc -> doc
  #g.directory 'doc', 'doc'

  # README -> README
  #g.file 'README'

  # AUTHORS -> authors.txt
  #g.file 'AUTHORS', 'authors.txt'

  # CHANGELOG -> doc/CHANGELOG
  #g.file 'CHANGELOG', 'doc/'
end

# index.txt is always dirty, so it's always rebuilt
task :publish => 'output/index.html'

file 'output/index.html' => FileList["content/**/*", "Sitefile"] do
  sh "webby build"
end
