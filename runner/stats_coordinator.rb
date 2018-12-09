require_relative '../config/init'
require_relative '../app/models/stats_metrics'
require 'pg'

module PodStats

  class StatsCoordinator
    attr_accessor :connection

    def connect
      unless @connection
        @connection = PG::connect(ENV["AGGREGATES_SQL_URL"])
      end

      @connection.exec "set search_path to #{ ENV["AGGREGATES_DB_SCHEMA"] };"
    end

    def metrics_for_pod name
      {
        :download_total => total_installs(name),
        :download_week => weekly_installs(name),
        :download_month => monthly_installs(name),
        :pod_try_total => total_pod_tries(name),
        :pod_try_week => weekly_pod_tries(name),
      }
    end

    def stat_for_pod pod_id, name
      print(".")
      metrics = metrics_for_pod name
      metrics.merge({
        :pod_id => pod_id,
        :is_active => metrics.any? { |_, installs| installs.nonzero? },
        :updated_at => Time.now
      })
    end

    def update_pod pod_id, data
      result = StatsMetrics.find(:pod_id => pod_id)
      if result
        StatsMetrics.where(id: result.id).update(data)
      else
        data[:created_at] = Time.now
        StatsMetrics.insert(data)
      end
    end

    def total_installs name
      installs = installs_total.try(:[], name).try(:[], 'downloads').try(:to_i)
      installs || 0
    end

    def weekly_installs name
      installs = installs_week.try(:[], name).try(:[], 'downloads').try(:to_i)
      installs || 0
    end

    def monthly_installs name
      installs = installs_month.try(:[], name).try(:[], 'downloads').try(:to_i)
      installs || 0
    end

    def total_pod_tries name
      installs = installs_total.try(:[], name).try(:[], 'pod_tries').try(:to_i)
      installs || 0
    end

    def weekly_pod_tries name
      installs = installs_week.try(:[], name).try(:[], 'pod_tries').try(:to_i)
      installs || 0
    end

    def installs_total
      @installs_total ||= Hash[installs.map { |row| [row['dependency_name'], row] }]
    end

    def installs_week
      @installs_week ||= Hash[installs('7 days').map { |row| [row['dependency_name'], row] }]
    end

    def installs_month
      @installs_month ||= Hash[installs('30 days').map { |row| [row['dependency_name'], row] }]
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
end
