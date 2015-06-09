require_relative '../config/init'
require_relative '../app/models/stats_metrics'
require 'pg'

module PodStats

  class StatsCoordinator
    attr_accessor :connection

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

    def connect
      unless @connection
        db = URI(ENV["ANALYTICS_SQL_URL"])
        @connection = PGconn.new(db.host, db.port, '', '', db.path[1..-1], db.user, db.password)
      end

      @connection.exec "set search_path to '#{ENV["ANALYTICS_DB_SCHEMA"]}';"
    end

    def stat_for_pod pod_id, name
      {
        :pod_id => pod_id,
        :download_total => download(name),
        :download_week => download(name, "7 days"),
        :download_month => download(name, "30 days"),
        :app_total => target(name, :application),
        :app_week => target(name, :application, "7 days"),
        :tests_total => target(name, :unit_test_bundle),
        :tests_week => target(name, :unit_test_bundle, "7 days"),
        :extension_total => target(name, :app_extension),
        :extension_week => target(name, :app_extension, "7 days"),
        :watch_total => target(name, :watch_extension),
        :watch_week => target(name, :watch_extension, "7 days"),
        :updated_at => Time.new
      }
    end

    def update_pod pod_id, data
      result = StatsMetrics.find(:pod_id => pod_id)
      if result
        StatsMetrics.where(id: result.id).update(data)
      else
        data[:created_at] = Time.new
        StatsMetrics.insert(data)
      end
    end

    def download pod_name, time=nil
      query = <<-eos
        SELECT COUNT(dependency_name)
        FROM install
        WHERE dependency_name = '#{pod_name}'
      eos
      query += "AND sent_at >= current_date - interval '#{time}'" if time

      @connection.exec(query)[0]["count"].to_i || 0
    end

    def target pod_name, type, time=nil
      type_id = PRODUCT_TYPE_UTI[type]

      query = <<-eos
        SELECT COUNT(DISTINCT(user_id))
        FROM install
        WHERE dependency_name = '#{pod_name}'
        AND product_type = '#{type_id}'
      eos
      query += "AND sent_at >= current_date - interval '#{time}'" if time

      @connection.exec(query)[0]["count"].to_i || 0
    end

  end
end
