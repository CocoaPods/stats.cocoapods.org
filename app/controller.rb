require 'sinatra/base'

class StatsApp < Sinatra::Base
  set :protection, :except => :json_csrf
  
  before do
    type = content_type(:json)
  end

  def json_error(status, message)
    error(status, { 'error' => message }.to_json)
  end

  def json_message(status, content)
    halt(status, content.to_json)
  end

  get '/' do
    redirect '/api/v1/status'
  end

  get '/api/v1/status' do
    { :ok => "yep" }.to_json
  end

  post '/api/v1/install' do
    install_data = JSON.parse(request.body.read)
    
    if install_data["targets"] == nil || install_data["cocoapods_version"] == nil
      json_error(400, 'Did not get the correct JSON format.')
    else
      targets, version = install_data.values_at('targets', 'name')
      
      json_message( 200,
        :ok => "OK"
      )
    end
  end

end
