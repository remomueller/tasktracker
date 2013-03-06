require 'test_helper'

class StickyTest < ActiveSupport::TestCase
  test "should be in completed panel" do
    assert 'completed', Sticky.new(completed: true).panel
  end

  test "should be in upcoming panel" do
    assert 'upcoming', Sticky.new(due_date: Date.tomorrow).panel
  end

  test "should be in past_due panel" do
    assert 'past_due', Sticky.new(due_date: Date.yesterday).panel
  end
end
