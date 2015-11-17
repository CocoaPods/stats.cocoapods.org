require_relative '../config/init'
require_relative '../app/models/stats_metrics'
require 'pg'

module PodStats

  class StatsCoordinator
    attr_accessor :connection

    def connect
      unless @connection
        db = URI(ENV["ANALYTICS_SQL_URL"])
        @connection = PGconn.new(db.host, db.port, '', '', db.path[1..-1], db.user, db.password)
      end

      @connection.exec "set search_path to #{ ENV["ANALYTICS_DB_SCHEMA"] };"
    end

    def metrics_for_pod name
      {
        :download_total => total_installs(name),
        :download_week => weekly_installs(name),
        :download_month => monthly_installs(name),
        :app_total => target_total_installs(name, :application),
        :app_week => target_weekly_installs(name, :application),
        :tests_total => target_total_installs(name, :unit_test_bundle),
        :tests_week => target_weekly_installs(name, :unit_test_bundle),
        :extension_total => target_total_installs(name, :app_extension),
        :extension_week => target_weekly_installs(name, :app_extension),
        :watch_total => target_total_installs(name, :watch_extension),
        :watch_week => target_weekly_installs(name, :watch_extension),
        :pod_try_total => total_pod_tries(name),
        :pod_try_week => weekly_pod_tries(name),
      }
    end

    def stat_for_pod pod_id, name
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

    def target_total_installs name, product_type
      installs = targets_total.try(:[], name).try(:[], PRODUCT_TYPE_UTI[product_type]).try(:to_i)
      installs || 0
    end

    def target_weekly_installs name, product_type
      installs = targets_week.try(:[], name).try(:[], PRODUCT_TYPE_UTI[product_type]).try(:to_i)
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

    def targets_total
      return @targets_total if @targets_total
      result = Hash.new { |h, k| h[k] = {} }

      targets.each do |row|
        name = row['dependency_name']
        product_type = row['product_type']
        result[name][product_type] = row['installs']
      end
      @targets_total = result
    end

    def targets_week
      return @targets_week if @targets_week
      result = Hash.new { |h, k| h[k] = {} }

      targets('7 days').each do |row|
        name = row['dependency_name']
        product_type = row['product_type']
        result[name][product_type] = row['installs']
      end
      @targets_week = result
    end

    def installs time = nil
      where = ''
      where = "WHERE sent_at >= current_date - interval '#{time}'" if time
      query = <<-SQL
        SELECT dependency_name,
               count(CASE WHEN pod_try THEN 1 ELSE null END) AS pod_tries,
               count(CASE WHEN pod_try THEN null ELSE 1 END) AS downloads
        FROM install
        #{where}
        GROUP BY dependency_name
      SQL

      @connection.exec(query)
    end

    def targets time = nil
      where = ''
      where = "AND sent_at >= current_date - interval '#{time}'" if time

      query = <<-SQL
        SELECT dependency_name, product_type, COUNT(DISTINCT(user_id)) AS installs
        FROM install
        WHERE pod_try = false #{where}
        GROUP BY dependency_name, product_type
      SQL

      @connection.exec(query)
    end
  end
end
