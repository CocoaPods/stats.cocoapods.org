require_relative '../config/init'
require_relative 'models/stats_metrics'

module PodStats

  class StatsCoordinator

    def loop_pods
      ["Expecta", "ORStackView"].each do |pod|
        stat = stat_for_pod pod
      end
    end
    
    def stat_for_pod pod
      result = StatsMetrics.find(:pod_id => @pod.id)
      
    end
    
    def get_download_data pod
      
    end

  end
  
  stats = StatsCoordinator.new
  stats.loop_pods
  
end