# frozen_string_literal: true

require "sidekiq/api"

task sidekiq_stats: [:environment] do
  stats = Sidekiq::Stats.new

  puts "Queues: #{stats.queues}"

  puts "Enqueued: #{stats.enqueued}"

  puts "Processed: #{stats.processed}"

  puts "Failed: #{stats.failed}"

  Sidekiq::ScheduledSet.new

  Sidekiq::RetrySet.new

  default_queue = Sidekiq::Queue.new("default")

  default_queue.each do | job |
    class_arg = job.args[0].split("-").select { | arg  | arg.match(" !ruby/class")  }[0]

    p class_arg.split[1].delete "'" unless class_arg.nil?
  end
end
