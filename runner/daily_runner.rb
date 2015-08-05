require_relative 'stats_coordinator'
require_relative '../config/init'
require_relative '../lib/pod_metrics'
require_relative '../app/models/pod'

require 'benchmark'

module PodStats
  puts Benchmark.measure {

    stats = StatsCoordinator.new
    stats.connect

    Pod.where(:deleted => false).each do |pod|
      puts "Grabbing stats for: #{pod.name}"
      data = stats.stat_for_pod pod.id, pod.name
      stats.update_pod pod.id,data
    end

  }.to_s
end
