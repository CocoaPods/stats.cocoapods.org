require_relative '../config/init'
require_relative 'stats_coordinator'
require_relative 'google_coordinator'

require_relative '../lib/pod_metrics'
require_relative '../app/models/pod'

require 'benchmark'
require 'legato'

module PodStats
  puts Benchmark.measure {


    # stats = StatsCoordinator.new
    # stats.connect

    # Pod.where(:deleted => false).each do |pod|
    #   # data = stats.stat_for_pod pod.id, pod.name
    #   # stats.update_pod pod.id, data
    #
    #   puts "#{pod.name} - "
    #
    # end

    ga = GoogleCoordinator.new
    token = ga.authenticate
    
    user = Legato::User.new(token)
    profile = user.profiles.detect { |profile| profile.web_property_id == "UA-29866548-1" }
    puts profile.name
    
    
    class AnalyticsPage
      extend Legato::Model

      metrics :pageviews
      dimensions :page_path
      filter :page_path, &lambda { contains(:page_path, "/pods/") }
      filter :page_path, &lambda { does_not_contain(:page_path, "?q=") }
    end
    
    results = AnalyticsPage.results(profile, :start_date => 30.days.ago, :end_date => 1.day.ago)
    puts results.count
  }.to_s
end
