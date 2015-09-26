require_relative '../config/init'
require_relative '../app/models/total_stats'
require 'pg'

module PodStats

  class TotalStatsCoordinator
    attr_accessor :connection

    def get_all_targets type
      type_id = PRODUCT_TYPE_UTI[type]

      query = <<-SQL
        SELECT COUNT(DISTINCT(user_id))
        FROM install
        WHERE product_type = $1
        AND pod_try = false
      SQL
      @connection.exec(query, [type_id])[0]["count"].to_i || 0
    end

    def get_all_podfiles
      query = <<-SQL
        SELECT COUNT(DISTINCT(user_id))
        FROM install
      SQL
      @connection.exec(query)[0]["count"].to_i || 0
    end

    def get_all_downloads
      query = <<-SQL
        SELECT COUNT(user_id)
        FROM install
      SQL
      @connection.exec(query)[0]["count"].to_i || 0
    end

    def get_all_extensions
      query = <<-SQL
        SELECT COUNT(DISTINCT(user_id))
        FROM install
        WHERE product_type LIKE '%extension%'
      SQL
      @connection.exec(query)[0]["count"].to_i || 0
    end

    def grab_stats
      {
        :projects_total => get_all_podfiles,
        :download_total => get_all_downloads,
        :app_total => get_all_targets(:application),
        :tests_total => get_all_targets(:unit_test_bundle),
        :extensions_total => get_all_extensions,
        :created_at => Time.now,
        :updated_at => Time.now
      }
    end

    def update_total_stats_for_today
      stats = grab_stats
      TotalStats.insert(stats)
    end

  end
end
