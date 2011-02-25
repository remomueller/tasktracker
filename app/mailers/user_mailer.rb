class UserMailer < ActionMailer::Base
  default :from => ActionMailer::Base.smtp_settings[:user_name]
    
  # def notification_by_mail(user, notification)
  #   @url = SITE_URL # + "/settings"
  #   @user = user
  #   @notification = notification
  #   mail(:to => user.email, :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{notification.subject}", :reply_to => notification.user.email)
  # end
  
  def test_mail
    mail(:to => 'rmueller@rics.bwh.harvard.edu', :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] Test Mail", :reply_to => 'rmueller@partners.org')
  end
  
  def notify_system_admin(system_admin, user)
    @system_admin = system_admin
    @user = user
    mail(:to => system_admin.email,
         :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{user.name} Signed Up",
         :reply_to => user.email)
  end
  
  def user_added_to_project(project_user)
    @project_user = project_user
    mail(:to => project_user.user.email,
         :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{project_user.project.user.name} allows you to #{project_user.allow_editing? ? 'edit' : 'view'} #{project_user.project.name}",
         :reply_to => project_user.project.user.email)
  end
  
  def comment_by_mail(comment, object)
    @comment = comment
    @object = object
    mail(:to => @object.user.email,
         :subject => "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] #{comment.user.name} commented on your #{object.class.name} #{object.name}",
         :reply_to => comment.user.email)    
  end
end
