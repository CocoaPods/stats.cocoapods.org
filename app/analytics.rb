require 'app/models/pod'
require 'segment/analytics'

module Pod
  class Analytics
    def self.track(options)
      # Segment::Analytics.track options
    end
    
    def self.identify(options)
      # Segment::Analytics.identify options
    end
  end    
end
