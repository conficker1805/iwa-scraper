# config valid only for current version of Capistrano
lock '3.11.2'

set :application, 'iwa'
set :repo_url, 'git@github.com:conficker1805/iwa-scraper.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/iwa'

# set :linked_files, fetch(:linked_files, []).push("config/master.key")
set :linked_files, %w{config/master.key config/production.key}

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :rails_env, 'production'

set :user, "iwa"
set :use_sudo, false

set :passenger_restart_with_touch, true

# set :nvm_type, :user # or :system, depends on your nvm setup
# set :nvm_node, 'v8.16.0'
# set :nvm_map_bins, %w{node npm yarn}
# set :yarn_target_path, -> { release_path.join('client') } #
# set :yarn_flags, '--production --silent --no-progress' # default
# set :yarn_roles, :all # default
# set :yarn_env_variables, {}

set :default_env, {
  'NODE_ENV' => 'production',
  'RAILS_ENV' => 'production'
}


# before "webpacker:precompile", "deploy:yarn_install"
# after 'deploy:updated', 'assets:precompile'
after 'deploy:updated', 'webpacker:precompile'


namespace :deploy do
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  task :yarn_install do
    on roles(:web) do
      within release_path do
        execute("cd #{release_path} && yarn install")
      end
    end
  end
end
