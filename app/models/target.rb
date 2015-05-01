require 'app/models/pod'

module Pod
  module StatsApp

    class Target
      attr_accessor :uuid, :pods
      
      def self.from_dict(dict)
        t = Target.new
        t.uuid = dict["uuid"]
        t.pods = dict["pods"].map { |p| Pod.from_dict(p) }
        t
      end
    end
    
  end
end
