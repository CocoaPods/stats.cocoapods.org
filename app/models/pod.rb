module Pod
  class Pod
    attr_accessor :name, :version
    
    def self.from_dict(dict)
      t = Pod.new
      t.name = dict["name"]
      t.version = dict["version"]
      t
    end
  end

end
