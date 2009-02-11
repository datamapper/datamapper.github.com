require 'grancher'

# index.txt is always dirty, so it's always rebuilt
desc 'Publish the website by committing on the master branch'
task :publish => 'output/.published'

file 'output/index.html' => FileList["content/**/*", "Sitefile"] do
  sh "webby build"
end

file 'output/.published' => 'output/index.html' do
  touch 'output/.published'
  grancher = Grancher.new do |g|
    g.branch = 'master'
    g.push_to = 'origin'
    g.repo = '.'          # defaults to '.'
    g.message = 'Updated website' # defaults to 'Updated files.'

    # Put the website-directory in the root
    g.directory 'output'
  end

  grancher.commit
end
