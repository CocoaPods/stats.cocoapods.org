require 'app/models/pod'

module Pod
  class Target
    attr_accessor :uuid, :pods, :type
    
    def self.from_dict(dict)
      t = Target.new
      t.uuid = dict["uuid"]
      t.type = dict["type"]
      t.pods = dict["pods"].map { |p| Pod.from_dict(p) }
      t
    end
  end    
end
