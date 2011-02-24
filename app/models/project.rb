class Project < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }

  # Model Relationships
  belongs_to :user
  has_many :project_users
  has_many :editors, :through => :project_users, :source => :user, :conditions => ['project_users.allow_editing = ?', true]
  has_many :viewers, :through => :project_users, :source => :user, :conditions => ['project_users.allow_editing = ?', false]

  def destroy
    update_attribute :deleted, true
  end

end
