require_relative '../config/init'
require_relative '../app/models/stats_metrics'
require 'pg'
require 'oauth2'

module PodStats

  # We use Legato to grab pageview stats for the last month then throw them into 
  # the metrics db
  
  # For generating a token, see: https://github.com/tpitale/legato/wiki/OAuth2-and-Google
  # For docs on anything legato: https://github.com/tpitale/legato/wiki

  class GoogleCoordinator
    attr_accessor :connection

    def authenticate
      client = OAuth2::Client.new(ENV['LEGATO_OAUTH_CLIENT_ID'], ENV['LEGATO_OAUTH_SECRET_KEY'], {
        :authorize_url => 'https://accounts.google.com/o/oauth2/auth',
        :token_url => 'https://accounts.google.com/o/oauth2/token'
      })
      client.auth_code.authorize_url({
        :scope => 'https://www.googleapis.com/auth/analytics.readonly',
        :redirect_uri => 'http://localhost',
        :access_type => 'offline'
      })
      access_token = client.auth_code.get_token(ENV['LEGATO_OAUTH_AUTH_CODE'], :redirect_uri => 'http://localhost')
    end
    
  end
end
