# config valid only for Capistrano 3.1
lock '3.11.0'

set :application, 'siblksdb'
set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :repo_url, 'https://github.com/edpratomo/siblksdb.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/apps/siblksdb'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/system}
# set :linked_dirs, fetch(:linked_dirs, []).push('public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :puma_user, fetch(:user)
set :puma_role, :web

set :puma_pid, "/home/apps/#{fetch(:application)}/shared/tmp/pids/puma.pid"
set :puma_state, "/home/apps/#{fetch(:application)}/shared/tmp/pids/puma.state"

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:web), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, "/tmp/restart_puma_#{fetch(:full_app_name)}.txt"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
