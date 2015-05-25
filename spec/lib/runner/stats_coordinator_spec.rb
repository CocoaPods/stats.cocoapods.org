require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models/stats_metrics', __FILE__)
require File.expand_path('../../../../app/models/pod', __FILE__)
require File.expand_path('../../../../runner/stats_coordinator', __FILE__)

describe PodStats::StatsCoordinator do

    before do
      @stats = PodStats::StatsCoordinator.new
      @connection = mock("object")
      @stats.connection = @connection
    end

    it 'sets the schema' do
      ENV["ANALYTICS_DB_SCHEMA"] = 'Hello'

      @connection.expects(:exec).with("set search_path to 'Hello';")

      @stats.connect
    end

    # it 'gets stats for a pod' do
    #   @stats.stat_for_pod "23", "name"
    #   @stats.expects.(:download).with("name").returns(1)
    # end
    #
  end
