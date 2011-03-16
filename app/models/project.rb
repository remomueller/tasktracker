class Project < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_user, lambda { |*args| { :conditions => ["projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.allow_editing IN (?))", args.first, args.first, args[1]] } }

  # Model Validation
  validates_presence_of :name


  # Model Relationships
  belongs_to :user
  has_many :project_users
  has_many :users, :through => :project_users, :conditions => { :deleted => false }, :order => 'last_name, first_name'
  has_many :editors, :through => :project_users, :source => :user, :conditions => ['project_users.allow_editing = ? and users.deleted = ?', true, false]
  has_many :viewers, :through => :project_users, :source => :user, :conditions => ['project_users.allow_editing = ? and users.deleted = ?', false, false]
  has_many :stickies, :conditions => { :deleted => false }, :order => 'stickies.created_at desc'

  def destroy
    update_attribute :deleted, true
  end
  
  def comments(limit = nil)
    Comment.current.with_object_model(self.class.name).with_object_id(self.id).order('created_at desc').limit(limit)
  end
  
  def related_sticky_comments(limit = nil)
    Comment.current.with_object_model('Sticky').with_object_id(self.stickies.collect{|sticky| sticky.id}).order('created_at desc').limit(limit)
  end
  
  def all_comments(limit = nil)
    (comments(limit) | related_sticky_comments(limit)).sort{|a,b| b.created_at <=> a.created_at}[0..((limit || 1).to_i-1)]
  end
  
  def new_comment(current_user, description)
    Comment.create(:object_model => self.class.name, :object_id => self.id, :user_id => current_user.id, :description => description)
  end

end
