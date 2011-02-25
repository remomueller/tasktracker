class ProjectUser < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  after_update :notify_user
  
  private
  
  def notify_user
    UserMailer.user_added_to_project(self).deliver
  end
  
end
