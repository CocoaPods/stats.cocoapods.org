require File.expand_path('../../../spec_helper', __FILE__)
require 'app/models/target'

module PodStats
  describe Target do
    describe 'data mapping' do

      it 'makes an object from json' do
        dict = {
          "uuid" => "342F9334FD3CCD087D0AB434",
          "pods" => [],
          "type" => "Hello"
        }
        target = Target.from_dict dict
        target.uuid.should == "342F9334FD3CCD087D0AB434"
        target.pods.length.should == 0
        target.type.should == "Hello"
      end

      it 'correctly makes pods' do
        dict = {
          "uuid" => "342F9334FD3CCD087D0AB434",
          "pods" => [
            { "name" => "ORStackView", "version" => "2.0.1" },
            { "name" => "ARAnalytics", "version" => "2.2.1" }
          ]
        }
        target = Target.from_dict dict
        target.pods[0].name.should == "ORStackView"
        target.pods[1].name.should == "ARAnalytics"
        
        target.pods[0].version.should == "2.0.1"
        target.pods[1].version.should == "2.2.1"
      end

    end
  end
end