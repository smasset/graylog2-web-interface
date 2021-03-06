require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class DashboardControllerTest < ActionController::TestCase

  context "overall dashboard" do

    should "show correct number of messages" do
      142.times { bm }
      MessageCount.make(:timestamp => 1.minute.ago, :total => 142)
      get :index

      assert_equal 142, assigns(:message_count)
    end

  end

  context "stream dashboard" do

    should "show correct number of messages" do
      stream = Stream.make
      20.times { bm(:streams => stream.id) }
      MessageCount.make(:timestamp => 1.minute.ago, :streams => { stream.id.to_s => 20 } )
      get :index, :stream_id => stream.id.to_s

      assert_equal 20, assigns(:message_count)
    end

    should "should show a stream dashboard not a overall dashboard" do
      20.times { bm }
      stream = Stream.make
      MessageCount.make(:timestamp => 1.minute.ago, :streams => { stream.id.to_s => 20 } )
      get :index, :stream_id => stream.id.to_s

      assert_not_nil assigns(:stream_title)
    end

    should "assign correct values if custom alarm values are set" do
      stream = Stream.make(:alarm_active => true, :alarm_limit => 500, :alarm_timespan => 30)
      20.times { bm(:streams => stream.id) }
      MessageCount.make(:timestamp => 1.minute.ago, :streams => { stream.id.to_s => 20 } )
      get :index, :stream_id => stream.id.to_s

      assert_equal 30, assigns(:timespan)
      assert_equal 500, assigns(:max_messages)
    end

    should "assign standard values if no custom alarm values are set" do
      stream = Stream.make(:alarm_active => false)
      20.times { bm(:streams => stream.id) }
      MessageCount.make(:timestamp => 1.minute.ago, :streams => { stream.id.to_s => 20 } )
      get :index, :stream_id => stream.id.to_s

      assert_equal DashboardController::STANDARD_TIMESPAN, assigns(:timespan)
      assert_equal DashboardController::STANDARD_MAX_MESSAGES, assigns(:max_messages)
    end

  end

end
