# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

# Nome da aplicação e repositório
set :application, 'candeiasesperanca'
set :repo_url, 'git@github.com:modusss/social_project.git'

# Configurações de deploy
set :deploy_to, '/var/www/candeiasesperanca'
set :branch, 'main'  # ou 'master', dependendo da sua branch principal

# Configurações do rbenv/rvm
# set :rbenv_type, :user
#set :rbenv_ruby, '3.2.2' # sua versão do Ruby

# Configurações padrão
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/master.key')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system', 'public/uploads')

# Manter últimas 5 releases
set :keep_releases, 5

# Configurações do Puma
set :puma_threads, [4, 16]
set :puma_workers, 2
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.access.log"
set :puma_error_log, "#{release_path}/log/puma.error.log"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for default_env is {}
set :default_env, { path: "/usr/local/bin/bundle:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
