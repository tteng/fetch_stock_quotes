require 'capistrano/ext/multistage'
require "whenever/capistrano"

set :repository,  ""
set :scm, :subversion
set :use_sudo, false
set :rake, "/usr/local/bin/rake"
set :whenever, "/usr/local/ruby/bin/whenever"
#set :rails_env, "production"
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :stages, %w{default}
set :default_stage, "default"

set :scm_username, "somename"
set :scm_password, "pwd"
set :deploy_via,   :copy

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

 namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "sh #{File.join(current_path,'bin','forever_stop.sh')}"
     run "sleep 5 && sh #{File.join(current_path,'bin','forever_start.sh')}"
   end

end
