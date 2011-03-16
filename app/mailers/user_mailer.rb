class UserMailer < ActionMailer::Base
  default :from => ActionMailer::Base.smtp_settings[:user_name]
  
  def notify_system_admin(system_admin, user)
    setup_email
    @system_admin = system_admin
    @user = user
    mail(:to => system_admin.email,
         :subject => @subject + "#{user.name} Signed Up",
         :reply_to => user.email)
  end
  
  def user_added_to_project(project_user)
    setup_email
    @project_user = project_user
    mail(:to => project_user.user.email,
         :subject => @subject + "#{project_user.project.user.name} allows you to #{project_user.allow_editing? ? 'edit' : 'view'} #{project_user.project.name}",
         :reply_to => project_user.project.user.email)
  end
  
  def comment_by_mail(comment, object, recipient)
    setup_email
    @comment = comment
    @object = object
    @recipient = recipient
    mail(:to => recipient.email,
         :subject => @subject + "#{comment.user.name} commented on #{object.class.name} #{object.name}",
         :reply_to => comment.user.email)    
  end
  
  def sticky_by_mail(sticky, recipient)
    setup_email
    @sticky = sticky
    @recipient = recipient
    mail(:to => recipient.email,
         :subject => @subject + "#{sticky.user.name} Added a Sticky to Project #{sticky.project.name}",
         :reply_to => sticky.user.email)    
  end
  
  def status_activated(user)
    setup_email
    @user = user
    mail(:to => user.email,
         :subject => @subject + "#{user.name}'s Account Activated") #,
#         :reply_to => user.email)
  end
  
  protected
  
  def setup_email
    @subject = "[#{DEFAULT_APP_NAME.downcase}#{'-development' if Rails.env == 'development'}] "
  end
end
