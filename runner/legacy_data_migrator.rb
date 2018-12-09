require_relative '../config/init'
require_relative '../lib/pod_metrics'
require_relative '../app/models/pod'
require_relative 'aggregation_coordinator'
require 'parallel'

module PodStats

  class LegacyCoordinator
    attr_accessor :connection

    def connect
      unless @connection
        @connection = PG::connect(ENV["AGGREGATES_SQL_URL"])
      end

      @connection.exec "set search_path to #{ ENV["AGGREGATES_DB_SCHEMA"] };"
    end

    def metrics_by_pod_id
      @metrics_by_pod_id ||= StatsMetrics.as_hash(:pod_id, [:pod_id, :download_total, :pod_try_total])
    end

    def current_data_for_pod pod
      result = metrics_by_pod_id[pod.id]
      return nil unless result
      new_aggregation = {
        'pod_id' => result[0],
        'dependency_name' => pod.name,
        'dependency_version' => "UNKNOWN",
        'downloads' => result[1],
        'pod_tries' => result[2],
        'rollup_date' => '2018-01-01',
      }
      new_aggregation
    end

    def insert data
      @connection.transaction do |tconn|
        enco = PG::TextEncoder::CopyRow.new
        tconn.copy_data "COPY downloads FROM STDIN", enco do
          data.each do |row|
            print "."
            tconn.put_copy_data [SecureRandom.uuid(), row["rollup_date"], row["pod_id"], row["dependency_name"], row["dependency_version"], row["pod_tries"], row["downloads"]]
          end
        end
      end
    end

    def installs time = nil
      where = ''
      where = "WHERE rollup_date >= current_date - interval '#{time}'" if time
      query = <<-SQL
        SELECT dependency_name,
               SUM(pod_tries) as pod_tries,
               SUM(downloads) as downloads
        FROM downloads
        #{where}
        GROUP BY dependency_name;
      SQL

      @connection.exec(query)
    end
  end

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

  stats = LegacyCoordinator.new
  stats.connect

  puts "Fetching Pods"
  pods = Pod.where(:deleted => false).map { |row| row }

  puts "Warming cache"
  warm_cache = stats.metrics_by_pod_id

  data = Parallel.map(pods, in_threads: 8) do |p|
    puts "Pod: #{p.name}"
    stats.current_data_for_pod(p)
  end.compact

  stats.insert(data)
end
