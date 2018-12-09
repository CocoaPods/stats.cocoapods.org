require_relative '../config/init'
require_relative '../app/models/stats_metrics'
require 'pg'
require 'securerandom'

module PodStats

  class AggregationCoordinator
    attr_accessor :connection

    def connect
      unless @qconn
        @qconn = PG::connect(ENV['ANALYTICS_SQL_URL'])
        @qconn.exec "set search_path to #{ ENV["ANALYTICS_DB_SCHEMA"] };"
      end

      unless @iconn
        @iconn = PG::connect(ENV['AGGREGATES_SQL_URL'])
        @iconn.exec "set search_path to #{ ENV["AGGREGATES_DB_SCHEMA"] };"
      end
    end

    def installations_by_day(pod_name, since: nil)
      where = "AND sent_at >= current_date - interval '#{since}'" if since
      query = <<-SQL
        SELECT dependency_name,
               dependency_version,
               to_char(sent_at, 'YYYY-MM-DD') AS rollup_date,
               count(CASE WHEN pod_try THEN 1 ELSE null END) AS pod_tries,
               count(CASE WHEN pod_try THEN null ELSE 1 END) AS downloads
        FROM install
        WHERE dependency_name = '#{pod_name}'
        #{where}
        AND sent_at <= current_date - interval '1 day'
        GROUP BY rollup_date, dependency_name, dependency_version
      SQL

      @qconn.exec(query)
    end

    def pods_usage_by_version_and_day(since: nil)
      where = "AND sent_at >= current_date - interval '#{since}'" if since
      query = <<-SQL
        SELECT cocoapods_version,
               to_char(sent_at, 'YYYY-MM-DD') AS rollup_date,
               count(1) AS usages
        FROM identifies
        WHERE sent_at <= current_date - interval '1 day'
        #{where}
        GROUP BY rollup_date, cocoapods_version
      SQL

      @qconn.exec(query)
    end

    def upsert_version_data(data)
      @iconn.transaction do |tconn|
        enco = PG::TextEncoder::CopyRow.new
        tconn.copy_data "COPY usage FROM STDIN", enco do
          data.each do |row|
            tconn.put_copy_data [
              SecureRandom.uuid(), row["rollup_date"],
              row["cocoapods_version"], row["usages"]
            ]
          end
        end
      end
    end

    def drop_historic_data_for_pod(name)
      @qconn.exec <<-SQL
      DELETE FROM install WHERE dependency_name = '#{name}' AND sent_at <= current_date - interval '1 day';
      SQL
      @qconn.exec <<-SQL
      DELETE FROM install_light WHERE dependency_name = '#{name}' AND sent_at <= current_date - interval '1 day';
      SQL
    end

    def upsert_data(data)
      @iconn.transaction do |tconn|
        enco = PG::TextEncoder::CopyRow.new
        tconn.copy_data "COPY downloads FROM STDIN", enco do
          data.each do |row|
            tconn.put_copy_data [SecureRandom.uuid(), row["rollup_date"], row["pod_id"], row["dependency_name"], row["dependency_version"], row["pod_tries"], row["downloads"]]
          end
        end
      end
    end
  end
end
