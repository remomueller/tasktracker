require 'test_helper'

class FrameTest < ActiveSupport::TestCase
  test "get short time for frame from this year" do
    date = Date.today
    frame = Frame.new(start_date: date, end_date: date)
    assert_equal "#{date.strftime('%m/%d')} to #{date.strftime('%m/%d')}", frame.short_time
  end
  
  test "get short time for frame from last year" do
    date = Date.today - 1.year
    frame = Frame.new(start_date: date, end_date: date)
    assert_equal "#{date.strftime('%m/%d/%Y')} to #{date.strftime('%m/%d/%Y')}", frame.short_time
  end
  
  test "get long time for frame from this year" do
    date = Date.today
    frame = Frame.new(start_date: date, end_date: date)
    assert_equal "#{date.strftime('%b %d (%a)')} to #{date.strftime('%b %d (%a)')}", frame.long_time
  end
  
  test "get long time for frame from last year" do
    date = Date.today - 1.year
    frame = Frame.new(start_date: date, end_date: date)
    assert_equal "#{date.strftime('%b %d, %Y (%a)')} to #{date.strftime('%b %d, %Y (%a)')}", frame.long_time
  end
end
