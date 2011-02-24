class UserMailer < ActionMailer::Base
  default :from => ActionMailer::Base.smtp_settings[:user_name]
  
  # def notification_by_mail(user, notification)
  #   @url = SITE_URL # + "/settings"
  #   @user = user
  #   @notification = notification
  #   mail(:to => user.email, :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{notification.subject}", :reply_to => notification.user.email)
  # end
  
  # def test_mail
  #   mail(:to => 'rmueller@rics.bwh.harvard.edu', :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] Test Mail", :reply_to => 'rmueller@partners.org')
  # end
end
