source 'https://rubygems.org'
ruby '2.1.3'

gem 'activesupport'
gem 'i18n'
gem 'json', '~> 1.8'
gem 'nap'
gem 'pg'
gem 'sequel'
gem 'sinatra'
gem 'analytics-ruby', '~> 2.0.0', :require => 'segment/analytics'
gem 'parallel'

group :rake do
  gem 'rake'
  gem 'terminal-table'
end

group :development do
  gem 'kicker'
  gem 'pry'
end

group :development, :production do
  gem 'foreman'
  gem 'thin'
end

group :test do
  gem 'bacon'
  gem 'mocha-on-bacon'
  gem 'nokogiri'
  gem 'prettybacon'
  gem 'rack-test'
  gem 'rubocop'
  gem 'webmock'
end
