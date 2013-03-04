# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every 1.day, :at => "09:00" do
  command "wget http://localhost:8888/verify_proxies"
end

every 1.day :at => "09:30, 14:00, 17:00" do
  command "wget http://localhost:8888/tags_weibo_score"
end

every 1.day :at => "09:40, 14:10, 17:10" do
  command "wget http://localhost:8888/tags_google_score"
end

every 1.day :at => "09:50, 14:20, 17:20" do
  command "wget http://localhost:8888/tags_cn21_score"
end

every 1.day :at => "09:40, 14:10, 17:10" do
  command "wget http://localhost:8888/calc_top_hundred_weibo_score"
end
every 1.day :at => "09:50, 14:20, 17:20" do
  command "wget http://localhost:8888/calc_top_hundred_google_score"
end
every 1.day :at => "10:20, 14:50, 17:50" do
  command "wget http://localhost:8888/calc_top_hundred_cn21_score"
end
