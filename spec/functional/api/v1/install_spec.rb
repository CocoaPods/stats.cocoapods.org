require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/api_controller', __FILE__)

module PodStats
  describe StatsApp, '/api/v1/install/' do

    before do
      @data = 
      { 
        "targets" => [
          {
            "uuid" => "342F9334FD3CCD087D0AB434",
            "type" => "com.apple.product-type.application",
            "pods" => [
              { "name" => "ORStackView", "version" => "2.0.1" },
              { "name" => "ARAnalytics", "version" => "2.2.1" }
            ]
          },
          {
            'uuid' => "342F9064DCA552635C1452CD",
            "type" => "com.apple.product-type.bundle.unit-test",
            "pods" => [
              { "name" => "Specta", 'version' => "1.0.1" },
              { "name" => "Expecta", "version" => "0.8.9a" }
            ]
          }
        ],
        'cocoapods_version' => "0.37.0"
      }
      
    end

    it 'gives an ok to posting correct data' do
      PodAnalytics.stubs(:identify)
      PodAnalytics.stubs(:track)
      
      post "/api/v1/install", @data.to_json,  'HTTPS' => 'on'
    
      last_response.status.should == 200
      last_response.content_type.should == 'application/json'
    
      JSON.parse(last_response.body).should == { 'ok' => "OK" }
    end
  
    it 'creates the right analytics events' do
      # We make two analytics calls per target
      # For the App:
      PodAnalytics.expects(:identify).with( 
        :user_id => '342F9334FD3CCD087D0AB434', 
        :traits => {
          :product_type => "com.apple.product-type.application",
          :cocoapods_version => '0.37.0'
        }
      )
      
      PodAnalytics.expects(:track).with( 
        :user_id => '342F9334FD3CCD087D0AB434', 
        :event => 'install',
        :properties => {
          :product_type => "com.apple.product-type.application",
          "ORStackView" => '2.0.1',
          "ARAnalytics" => '2.2.1',
        }
      )
      
      # For the Unit Tests Target    
      PodAnalytics.expects(:identify).with(
        :user_id => '342F9064DCA552635C1452CD', 
        :traits => {
          :product_type => 'com.apple.product-type.bundle.unit-test',
          :cocoapods_version => '0.37.0'
        }
      )
    
      PodAnalytics.expects(:track).with( 
        :user_id => '342F9064DCA552635C1452CD', 
        :event => 'install',
        :properties => {
          :product_type => 'com.apple.product-type.bundle.unit-test',
          "Specta" => '1.0.1', 
          "Expecta" => '0.8.9a',
        }
      )
      
      post "/api/v1/install", @data.to_json,  'HTTPS' => 'on'
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