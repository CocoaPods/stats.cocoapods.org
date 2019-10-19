require 'sinatra/base'
require 'app/models/pod'
require 'app/models/target'
require 'app/analytics'

module PodStats
  class StatsApp < Sinatra::Base
    set :protection, :except => :json_csrf
    set :request_count, 0

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

    get "/api/v1/recent_requests_count" do
      return 0
    end

    post "/api/v1/reset_requests_count" do
      return 0
    end

    post '/api/v1/install' do
      install_data = JSON.parse(request.body.read)

      if install_data["targets"] == nil || install_data["cocoapods_version"] == nil
        json_error(400, 'Did not recieve the correct JSON format.')
      else
        # NOOP checkout to 018dec2b0c5e1a98ddd028a93e0629ecd72c3f0e
        # if you'd like to see the old behavior
        204
      end
    end
  end
end
