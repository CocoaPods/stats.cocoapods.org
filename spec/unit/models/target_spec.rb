require 'app/models/target'

module Pod::StatsApp
  describe Target do
    describe 'data mapping' do

      it 'makes an object from json' do
        dict = {
          "uuid" => "342F9334FD3CCD087D0AB434",
          "pods" => [
            { "name" => "ORStackView", "version" => "2.0.1" },
            { "name" => "ARAnalytics", "version" => "2.2.1" }
          ]
        }
        target = Target.from_dict dict
        target.uuid.should == "342F9334FD3CCD087D0AB434"
        target.pods.length.should == 2
      end

    end
  end
end