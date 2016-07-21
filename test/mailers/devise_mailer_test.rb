# frozen_string_literal: true

require 'test_helper'

# Test to make sure devise emails generate correctly.
class DeviseMailerTest < ActionMailer::TestCase
  test 'reset password email' do
    valid = users(:valid)
    mail = Devise::Mailer.reset_password_instructions(valid, 'faketoken')
    assert_equal [valid.email], mail.to
    assert_equal 'Reset password instructions', mail.subject
    assert_match(%r{#{ENV['website_url']}/password/edit\?reset_password_token=faketoken}, mail.body.encoded)
  end
end
