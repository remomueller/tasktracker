# frozen_string_literal: true

require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test 'get second half of group description' do
    assert 'Second Part', groups(:four).short_description_second_half
  end
end
