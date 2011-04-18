class Comment < ActiveRecord::Base
  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_object_model, lambda { |*args|  { :conditions => ["comments.object_model IN (?)", args.first] } }
  scope :with_object_id, lambda { |*args|  { :conditions => ["comments.object_id IN (?)", args.first] } }
  scope :with_two_object_models_and_ids, lambda { |*args|  { :conditions => ["(comments.object_model IN (?) and comments.object_id IN (?)) or (comments.object_model IN (?) and comments.object_id IN (?))", args[0], args[1], args[2], args[3]] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  
  
  after_create :send_email
  
  # Model Validation
  validates_presence_of :description

  # Model Relationships
  belongs_to :user
  
  def name
    "ID ##{self.id}"
  end
  
  def friendly_date
    if self.created_at.to_date == Date.today
      self.created_at.strftime("at %I:%M %p")
    elsif self.created_at.year == Date.today.year
      self.created_at.strftime("on %b %d at %I:%M %p")
    else
      self.created_at.strftime("on %b %d, %Y at %I:%M %p")
    end
  end
  
  def destroy
    update_attribute :deleted, true
  end
  
  def comments(limit = nil)
    Comment.current.with_object_model(self.class.name).with_object_id(self.id).order('created_at desc').limit(limit)
  end
  
  def new_comment(current_user, description)
    Comment.create(:object_model => self.class.name, :object_id => self.id, :user_id => current_user.id, :description => description)
  end
  
  private
  
  def send_email
    @object = self.object_model.constantize.find_by_id(self.object_id)
    all_users = (@object.comments.collect{|c| c.user} + [@object.user, @object.owner]).compact.uniq - [self.user]
    all_users.each do |user_to_email|
      if user_to_email.active? and user_to_email.email_on?(:send_email) and
        ((self.object_model == 'Project' and user_to_email.email_on?(:project_comments) and user_to_email.email_on?("project_#{self.object_id}")) or
        (self.object_model == 'Sticky' and user_to_email.email_on?(:sticky_comments) and user_to_email.email_on?("project_#{Sticky.find_by_id(self.object_id).project.id}")))
        UserMailer.comment_by_mail(self, @object, user_to_email).deliver if Rails.env.production?
      end
    end
  end
  
end
