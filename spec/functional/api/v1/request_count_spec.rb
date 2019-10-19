require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/api_controller', __FILE__)

module PodStats
  describe StatsApp, '/api/v1/request_xxx count/reset' do

    before do
      @data =
      {
        "targets" => [
          {
            "uuid" => "342F9334FD3CCD087D0AB434",
            "type" => "com.apple.product-type.application",
            "platform" => "ios",
            "pods" => [
              { "name" => "ORStackView", "version" => "2.0.1" },
              { "name" => "ARAnalytics", "version" => "2.2.1" }
            ]
          },
          {
            'uuid' => "342F9064DCA552635C1452CD",
            "type" => "com.apple.product-type.bundle.unit-test",
            "platform" => "ios",
            "pods" => [
              { "name" => "Specta", 'version' => "1.0.1" },
              { "name" => "Expecta", "version" => "0.8.9a" }
            ]
          }
        ],
        "cocoapods_version" => "0.37.0",
        "pod_try" => false

      }

    end

    it 'an install raises the request count' do
      post "/api/v1/install", @data.to_json,  'HTTPS' => 'on'
      last_response.status.should == 204
    end

    it 'it gives the right value to "/api/v1/recent_requests_count' do
      get "/api/v1/recent_requests_count", 'HTTPS' => 'on'
      last_response.body.should == "0"
    end

    it 'it reset the request count when recieving "/api/v1/reset_requests_count' do
      post "/api/v1/reset_requests_count", 'HTTPS' => 'on'
      last_response.body.should == "0"
    end
  end
end
