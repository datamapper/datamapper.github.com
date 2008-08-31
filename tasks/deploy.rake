
require 'rake/contrib/sshpublisher'

namespace :deploy do

  desc 'Deploy to the server using rsync'
  task :rsync do
    # cmd = "rsync #{SITE.rsync_args.join(' ')} "
    # cmd << "#{SITE.output_dir}/ #{SITE.host}:#{SITE.remote_dir}"
    # sh cmd
    raise "Don't deploy this way! Talk to someone from Wieck"
  end

  desc 'Deploy to the server using ssh'
  task :ssh do
    # Rake::SshDirPublisher.new(
    #     SITE.host, SITE.remote_dir, SITE.output_dir
    # ).upload
    raise
  end

end  # deploy

# EOF
