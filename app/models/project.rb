class Project < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}
  serialize :tags, Array
  attr_reader :tag_tokens

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_user, lambda { |*args| { :conditions => ["projects.user_id = ? or projects.id in (select project_users.project_id from project_users where project_users.user_id = ? and project_users.allow_editing IN (?))", args.first, args.first, args[1]] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(name) LIKE ? or LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # scope :by_favorite, lambda { |*args| {:include => :project_favorites, :conditions => ["project_favorites.user_id = ? or project_favorites.user_id IS NULL", args.first], :order => "(project_favorites.favorite = 0) ASC" } }
  scope :by_favorite, lambda { |*args| {:joins => "LEFT JOIN project_favorites ON project_favorites.project_id = projects.id and project_favorites.user_id = #{args.first}"}} #, :order => "(project_favorites.favorite = 1) DESC"

  # Model Validation
  validates_presence_of :name


  # Model Relationships
  belongs_to :user
  has_many :project_favorites
  has_many :project_users
  has_many :users, :through => :project_users, :conditions => { :deleted => false }, :order => 'last_name, first_name'
  has_many :editors, :through => :project_users, :source => :user, :conditions => ['project_users.allow_editing = ? and users.deleted = ?', true, false]
  has_many :viewers, :through => :project_users, :source => :user, :conditions => ['project_users.allow_editing = ? and users.deleted = ?', false, false]
  has_many :stickies, :conditions => { :deleted => false } #, :order => 'stickies.created_at desc'
  has_many :frames, :conditions => { :deleted => false }, :order => 'frames.end_date desc'

  def color(current_user)
    current_user.colors["project_#{self.id}"].blank? ? colors(Project.pluck(:id).index(self.id)) : current_user.colors["project_#{self.id}"]
  end

  def tag_tokens
    self.tags.join(',')
  end

  def tag_tokens=(ids)
    self.tags = ids.to_s.split(',').collect{|t| t.strip}
  end

  def destroy
    self.comments.destroy_all
    self.stickies.destroy_all
    self.frames.destroy_all
    update_attribute :deleted, true
  end
  
  def comments(limit = nil)
    Comment.current.with_class_name(self.class.name).with_class_id(self.id).order('created_at desc').limit(limit)
  end

  def new_comment(current_user, description)
    Comment.create(:class_name => self.class.name, :class_id => self.id, :user_id => current_user.id, :description => description)
    self.touch
  end

  # Currently owner and user is the same (for stickies it's different)
  def owner
    self.user
  end

  def users_to_email(action)
    result = (self.users + [self.user]).uniq
    result = result.select{|u| u.active_for_authentication? and u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{self.id}") and u.email_on?("project_#{self.id}_#{action}") }
  end

  private
  
  def colors(index)
    # colors = ['#92A8CD', '#AA4643', '#89A54E', '#4572A7', '#80699B', '#3D96AE', '#DB843D', '#A47D7C', '#B5CA92', '#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
    # colors = ["#AC725E", "rgb(208, 107, 100)", "rgb(248, 58, 34)", "rgb(250, 87, 60)", "rgb(255, 117, 55)", "#FFAD46", "rgb(66, 214, 146)", "rgb(22, 167, 101)", "rgb(123, 209, 72)", "rgb(179, 220, 108)", "rgb(251, 233, 131)", "rgb(250, 209, 101)", "rgb(146, 225, 192)", "rgb(159, 225, 231)", "rgb(159, 198, 231)", "rgb(73, 134, 231)", "rgb(154, 156, 255)", "rgb(185, 154, 255)", "rgb(194, 194, 194)", "rgb(202, 189, 191)", "rgb(204, 166, 172)", "#F691B2", "rgb(205, 116, 230)", "rgb(164, 122, 226)"]
    colors = ["#4733e6", "rgb(123, 209, 72)", "#bfbf0d", "rgb(154, 156, 255)", "rgb(22, 167, 101)", "rgb(73, 134, 231)", "rgb(205, 116, 230)", "#9f33e6", "rgb(255, 117, 55)", "rgb(146, 225, 192)", "rgb(208, 107, 100)", "rgb(159, 198, 231)", "rgb(194, 194, 194)", "rgb(250, 87, 60)", "#AC725E", "rgb(204, 166, 172)", "rgb(185, 154, 255)", "rgb(248, 58, 34)", "rgb(66, 214, 146)", "#F691B2", "rgb(164, 122, 226)", "#FFAD46", "rgb(179, 220, 108)"] # "rgb(251, 233, 131)"
    colors[index.to_i % colors.size]
  end

end
