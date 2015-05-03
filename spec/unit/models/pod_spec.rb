require File.expand_path('../../spec_helper', __FILE__)
require 'app/models/pod'

module Pod::StatsApp
  describe Pod do
    describe 'data mapping' do

      it 'makes an object from json' do
        dict = { "name" => "ORStackView", "version" => "2.0.1" }
        pod = Pod.from_dict dict
        pod.name.should == "ORStackView"
        pod.version.should == "2.0.1"
      end

    end
  end
end