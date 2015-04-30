require File.expand_path('../../../../spec_helper', __FILE__)
require File.expand_path('../../../../../app/controller', __FILE__)

describe StatsApp, '/api/v1/install/' do

  it 'returns the right details' do
    post "/api/v1/install", {},  'HTTPS' => 'on'
    
    last_response.status.should == 200
    last_response.content_type.should == 'application/json'
    
    JSON.parse(last_response.body).should == {
      'ok' => "OK"  
    }
  end

end
