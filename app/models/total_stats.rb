require_relative '../../lib/pod_metrics'

class TotalStats < Sequel::Model(:total_stats)
  include PodMetrics
end
