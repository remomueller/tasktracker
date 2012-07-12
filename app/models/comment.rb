class Comment < ActiveRecord::Base
  attr_accessible :description, :user_id

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :search, lambda { |*args| {conditions: [ 'LOWER(description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :with_creator, lambda { |*args|  { conditions: ["comments.user_id IN (?)", args.first] } }
  scope :with_date_for_calendar, lambda { |*args| { conditions: ["DATE(comments.created_at) >= ? and DATE(comments.created_at) <= ?", args.first, args[1]]}}
  scope :with_project, lambda { |*args| { conditions: ['comments.sticky_id in (select stickies.id from stickies where stickies.deleted = ? and stickies.project_id IN (?))', false, args.first] } }

  after_create :send_email

  # Model Validation
  validates_presence_of :description, :sticky_id, :user_id

  # Model Relationships
  belongs_to :user
  belongs_to :sticky, touch: true

  def name
    "##{self.id}"
  end

  def destroy
    update_attribute :deleted, true
  end

  def users_to_email(action, project_id, sticky)
    result = (sticky.comments.collect{|c| c.user} + [sticky.user, sticky.owner]).compact.uniq
    result = result.select{|u| u.email_on?(:send_email) and u.email_on?(action) and u.email_on?("project_#{project_id}") and u.email_on?("project_#{project_id}_#{action}") }
  end

  def project_id
    self.sticky.project_id if self.sticky
  end

  private

  def send_email
    all_users = []
    all_users = users_to_email(:sticky_comments, self.sticky.project_id, self.sticky) if self.sticky

    all_users = all_users - [self.user]

    all_users.each do |user_to_email|
      UserMailer.comment_by_mail(self, self.sticky, user_to_email).deliver if Rails.env.production?
    end
  end

end
