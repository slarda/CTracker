# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'champtracker'
set :repo_url, 'git@github.com:wtfiwtz/champtracker.git'
set :git_strategy, RemoteCacheWithProjectRootStrategy
set :project_root, 'ctbe'
set :rails_env, 'staging'
set :pty, true

# Default branch is :master
set :branch, ENV['REVISION'] || ENV['BRANCH'] || 'develop'
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/champtracker'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/environments/staging.rb',
                                                 'config/environments/production.rb', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle',
                                               'public/system', 'public/uploads')
set :bundle_binstubs, nil

set :rvm_type, :user
set :rvm_ruby_version, '2.2.3'


# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3

# namespace :load do
#   task :defaults do
#     #set :my_file, release_path.join('my_file')
#   end
# end

namespace :deploy do

  desc 'Restart nginx'
  task :restart do
    on roles(:app), in: :sequence, wait: 1 do
      execute :sudo, 'service nginx restart'
    end
  end

end

after 'deploy:publishing', 'deploy:restart'

set :sidekiq_env, fetch(:stage)
set :sidekiq_options_per_process, ["--queue mailers --queue default"]