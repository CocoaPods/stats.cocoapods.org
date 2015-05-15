require 'app/models/pod'
require 'segment/analytics'

module Pod
  class PodAnalytics

    key = ENV["SEGMENT_WRITE_KEY"] || ""
    Analytics = Segment::Analytics.new(
        write_key: key,
        on_error: Proc.new { |status, msg| print msg }
    )
    
    def self.track(options)
      Analytics.track options
    end
    
    def self.identify(options)
      Analytics.identify options
    end
  end    
end
