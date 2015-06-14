require 'sinatra/base'
require 'app/models/pod'
require 'app/models/target'
require 'app/analytics'

module PodStats
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
        targets = targets.map { |t| Target.from_dict(t) }
        
        targets.each do |target|
          
          # Each target is a "user"
          PodAnalytics.identify(
            :user_id => target.uuid,
            :traits => {
              :product_type => target.type,
              :cocoapods_version => install_data["cocoapods_version"],
              :platform => target.platform
            })
                    
          target.pods.each do |pod|
            
            PodAnalytics.track(
              :user_id => target.uuid,
              :event => "install",
              :properties => {
                :product_type => target.type,
                :pod_try => install_data["pod_try"],
                :platform => target.platform,
                :dependency => {
                  :name => pod.name,
                  :version => pod.version
                }
              }
            )
          end
          
        end
      
        json_message( 200,
          :ok => "OK"
        )
      end
    end
  end
end
