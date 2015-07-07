#!/usr/bin/env ruby

gem 'nap'
require 'rest'
require 'timeout'

begin
  port = ENV["PORT"]
  get_url = "http://localhost:#{port}/api/v1/recent_pods_count"
  reset_url = "http://localhost:#{port}/api/v1/reset_pods_count"

  number = REST.get(get_url).response.body
  puts "Sending #{number} pods to Status.io"

  api_key = ENV['STATUS_IO_API_KEY']
  page_id = ENV['STATUS_IO_PAGE_ID']
  metric_id = ENV['STATUS_IO_METRIC_ID']
  api_base = 'https://api.statuspage.io/v1'

  dhash = {
    :timestamp => Time.now.to_i,
    :value => number.to_i
  }

  REST.post("#{api_base}/pages/#{page_id}/metrics/#{metric_id}/data.json",  :headers => { 'Authorization' => "OAuth #{api_key}" }, :body => { :data => dhash } )

  REST.get(reset_url)
  sleep 1

rescue Exception => e
  puts "Exception: #{e}"
end
