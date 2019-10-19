require 'sinatra/base'

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
      204
    end
  end
end
