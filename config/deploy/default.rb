set :deploy_to, "/var/www/apps/itools"
set :host, "jupiter"
set :application, "itools"
set :user, "sgfdeployer"
server host, :web, :app, :db, :primary => true

namespace :deploy do

  desc "Update the crontab file"
  task :update_crontab, :roles => :app do
    run "cd #{release_path} && #{whenever} --update-crontab #{application} -f config/schedule.rb"
  end

  #after "deploy:symlink", "deploy:update_crontab"

end
