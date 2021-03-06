require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/api_controller', __FILE__)

module PodStats

  describe StatsApp, '/api/v1/status' do

    it 'returns the right amount' do
      get '/api/v1/status'
      last_response.status.should == 200
      JSON.parse(last_response.body).should == {
        "ok" => "yep"
      }
    end

  end
end