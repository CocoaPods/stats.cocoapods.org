module PodStats
  class Stat
      attr_accessor :pod_name, :download_total, :download_week, :download_month, :app_total, 
:app_week, :tests_total, :tests_week, :extension_keyboard_total, :extension_keyboard_week, :extension_action_total, :extension_action_week, :extension_share_total, :extension_share_week, :extension_watch_total, :extension_watch_week, :extension_today_total, :extension_today_week

    # Creates an object with corrosponing hash keys to properties
    def initialize(*h)
      if h.length == 1 && h.first.is_a?(Hash)
        h.first.each { |k, v| send("#{k}=", v) }
      end
    end
  end
  
  class StatsCoordinator

    def loop_pods
      ["Expecta", "ORStackView"].each do |pod|
        stat = stat_for_pod pod
      end
    end
    
    def stat_for_pod pod
      # create or find?
      Stat.new { :pod_name => pod }
    end
    
    def get_download_data pod
      
    end

  end
end