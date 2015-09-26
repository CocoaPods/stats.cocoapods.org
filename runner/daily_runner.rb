require_relative 'stats_coordinator'
require_relative 'total_stats_coordinator'
require_relative '../config/init'
require_relative '../lib/pod_metrics'
require_relative '../app/models/pod'

require 'benchmark'

module PodStats

  PRODUCT_TYPE_UTI = {
    :application       => 'com.apple.product-type.application',
    :framework         => 'com.apple.product-type.framework',
    :dynamic_library   => 'com.apple.product-type.library.dynamic',
    :static_library    => 'com.apple.product-type.library.static',
    :bundle            => 'com.apple.product-type.bundle',
    :unit_test_bundle  => 'com.apple.product-type.bundle.unit-test',
    :app_extension     => 'com.apple.product-type.app-extension',
    :command_line_tool => 'com.apple.product-type.tool',
    :watch_app         => 'com.apple.product-type.application.watchapp',
    :watch_extension   => 'com.apple.product-type.watchkit-extension',
  }.freeze

  puts Benchmark.measure {

    stats = StatsCoordinator.new
    stats.connect

    Pod.where(:deleted => false).each do |pod|
      puts "Grabbing stats for: #{pod.name}"
      data = stats.stat_for_pod pod.id, pod.name
      stats.update_pod pod.id,data
    end

    total = TotalStatsCoordinator.new
    total.connection = stats.connection
    total.update_total_stats_for_today

  }.to_s
end
