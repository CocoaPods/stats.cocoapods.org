require_relative '../config/init'
require_relative '../lib/pod_metrics'
require_relative '../app/models/pod'
require_relative 'aggregation_coordinator'
require 'parallel'

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

  stats = AggregationCoordinator.new
  stats.connect

  cocapods_version_data = stats.pod_usage_version_by_day
  stats.upsert_version_data cocoapods_version_data

  Pod.where(:deleted => false).each do |pod|
    puts "[#{pod.name}] Beginning"
    data = stats.installations_by_day pod.name
    meta = {"pod_id"=>pod.id}
    h = data.map do |row|
      meta.merge(row.to_h)
    end
    puts "[#{pod.name}] Upserting #{h.size} rows"
    stats.upsert_data(h)
    puts "[#{pod.name}] Done"
    stats.drop_historic_data_for_pod pod.name
  end
end
