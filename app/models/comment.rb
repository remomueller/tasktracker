class Comment < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_class_name, lambda { |*args|  { conditions: ["comments.class_name IN (?)", args.first] } }
  scope :with_class_id, lambda { |*args|  { conditions: ["comments.class_id IN (?)", args.first] } }
  scope :with_two_class_names_and_ids, lambda { |*args|  { conditions: ["(comments.class_name IN (?) and comments.class_id IN (?)) or (comments.class_name IN (?) and comments.class_id IN (?))", args[0], args[1], args[2], args[3]] } }
  scope :search, lambda { |*args| {conditions: [ 'LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :with_creator, lambda { |*args|  { conditions: ["comments.user_id IN (?)", args.first] } }
  scope :with_date_for_calendar, lambda { |*args| { conditions: ["DATE(comments.created_at) >= ? and DATE(comments.created_at) <= ?", args.first, args[1]]}}

  after_create :send_email

  # Model Validation
  validates_presence_of :description

  # Model Relationships
  belongs_to :user

  def name
    "ID ##{self.id}"
  end

  def destroy
    update_attribute :deleted, true
  end

  def comments(limit = nil)
    Comment.current.with_class_name(self.class.name).with_class_id(self.id).order('created_at desc').limit(limit)
  end

  def new_comment(current_user, description)
    Comment.create(class_name: self.class.name, class_id: self.id, user_id: current_user.id, description: description)
  end

  # Currently owner and user is the same (for stickies it's different)
  def owner
    self.user
  end

  def users_to_email(action, project_id, object)
    result = (object.comments.collect{|c| c.user} + [object.user, object.owner]).compact.uniq
    result = result.select{|u| u.active_for_authentication? and u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{project_id}") and u.email_on?("project_#{project_id}_#{action}") }
  end

  private

  def send_email
    @object = self.class_name.constantize.find_by_id(self.class_id)

    all_users = []
    if self.class_name == 'Project'
      all_users = users_to_email(:project_comments, self.class_id, @object)
    elsif self.class_name == 'Sticky'
      all_users = users_to_email(:sticky_comments, Sticky.find_by_id(self.class_id).project_id, @object)
    elsif self.class_name == 'Comment'
      all_users = users_to_email(:comment_comments, nil, @object)
    end

    all_users = all_users - [self.user]

    all_users.each do |user_to_email|
      UserMailer.comment_by_mail(self, @object, user_to_email).deliver if Rails.env.production?
    end
  end

end
