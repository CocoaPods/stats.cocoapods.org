require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)

module Pod
  describe StatsApp, '/api/v1/install/' do

    it 'gives an ok to posting correct data' do
      data = 
      { 
        "targets" => [
          {
            "uuid" => "342F9334FD3CCD087D0AB434",
            "pods" => [
              { "name" => "ORStackView", "version" => "2.0.1" },
              { "name" => "ARAnalytics", "version" => "2.2.1" }
            ]
          },
          {
            'uuid' => "342F9064DCA552635C1452CD",
            "pods" => [
              { "name" => "Specta", 'version' => "1.0.1" },
              { "name" => "Expecta", "version" => "0.8.9a" }
            ]
          }
        ],
        'cocoapods_version' => "0.37.0"
      }
    
      post "/api/v1/install", data.to_json,  'HTTPS' => 'on'
    
      last_response.status.should == 200
      last_response.content_type.should == 'application/json'
    
      JSON.parse(last_response.body).should == { 'ok' => "OK" }
    end
  
    it 'gives an error when posting incorrect data' do
      data =  { 
        "targes" => [""],
        "n" => "0.37.1"
      }
    
      post "/api/v1/install", data.to_json,  'HTTPS' => 'on'
    
      last_response.status.should == 400
      last_response.content_type.should == 'application/json'
    
      JSON.parse(last_response.body).should == { 'error' => "Did not get the correct JSON format." }
    end

  end
end