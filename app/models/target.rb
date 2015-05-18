require 'app/models/pod_version'

module PodStats
  class Target
    attr_accessor :uuid, :pods, :type
    
    def self.from_dict(dict)
      t = Target.new
      t.uuid = dict["uuid"]
      t.type = dict["type"]
      t.pods = dict["pods"].map { |p| PodVersion.from_dict(p) }
      t
    end
  end    
end
