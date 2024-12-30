# frozen_string_literal: true

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
require "tzinfo"

set :output, "/partr/log/cron.log"
env :PATH, ENV["PATH"]
job_type :env_runner, "cd /partr && bin/rails runner ':task' :output"

def local(time)
  TZInfo::Timezone.get("America/Chicago").local_to_utc(Time.parse(time))
end

every :friday, at: local("8:30am") do
  env_runner "WeeklyAdditionalPartsJob.perform_later"
end

every 1.hour do
  command "/bin/date"
end
