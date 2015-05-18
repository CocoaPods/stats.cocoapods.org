module PodStats
  class PodVersion
    attr_accessor :name, :version
    
    def self.from_dict(dict)
      t = PodVersion.new
      t.name = dict["name"]
      t.version = dict["version"]
      t
    end
  end

end
