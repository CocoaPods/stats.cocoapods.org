require File.expand_path('../../../spec_helper', __FILE__)
require File.expand_path('../../../../app/models/stats_metrics', __FILE__)
require File.expand_path('../../../../app/models/pod', __FILE__)

describe Pod do

  describe 'StatsMetrics' do
    before do
      @pod = Pod.create(:name => 'TestPod1')
      @stats = StatsMetrics.create(
        :pod => @pod,
        :download_total => 1001,
        :download_week => 23
      )
    end
    
    it 'returns a combined model' do
      result = StatsMetrics.find(:pod_id => @pod.id)
      result.download_total.should == 1001
      result.download_week.should == 23
    end
    
    
    it 'defaults to zeros' do
      result = StatsMetrics.find(:pod_id => @pod.id)
      result.app_week.should == 0
    end
    
  end
end