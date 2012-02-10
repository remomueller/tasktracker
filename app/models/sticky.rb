class Sticky < ActiveRecord::Base
  serialize :old_tags, Array # Deprecated however used to migrate from old schema to new tag framework

  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["stickies.project_id IN (?) or (stickies.project_id IS NULL and stickies.user_id = ?)", args.first, args[1]] } }
  scope :with_creator, lambda { |*args|  { conditions: ["stickies.user_id IN (?)", args.first] } }
  scope :with_owner, lambda { |*args|  { conditions: ["stickies.owner_id IN (?) or stickies.owner_id IS NULL", args.first] } }
  scope :with_frame, lambda { |*args| { conditions: ["stickies.frame_id IN (?) or (stickies.frame_id IS NULL and 0 IN (?))", args.first, args.first] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(description) LIKE ? or stickies.group_id IN (select groups.id from groups where LOWER(groups.description) LIKE ?)', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }
  scope :updated_since, lambda { |*args| { conditions: ["stickies.updated_at > ?", args.first] }}
  scope :with_date_for_calendar, lambda { |*args| { conditions: ["DATE(stickies.created_at) >= ? and DATE(stickies.created_at) <= ?", args.first, args[1]]}}

  scope :with_due_date_for_calendar, lambda { |*args| { conditions: ["DATE(stickies.due_date) >= ? and DATE(stickies.due_date) <= ?", args.first, args[1]]}}

  scope :due_date_within, lambda { |*args| { conditions: ["(DATE(stickies.due_date) >= ? or ? IS NULL) and (DATE(stickies.due_date) <= ? or ? IS NULL)", args.first, args.first, args[1], args[1]] }}


  scope :with_start_date_for_calendar, lambda { |*args| { conditions: ["DATE(stickies.start_date) >= ? and DATE(stickies.start_date) <= ?", args.first, args[1]]}}
  scope :with_end_date_for_calendar, lambda { |*args| { conditions: ["DATE(stickies.end_date) >= ? and DATE(stickies.end_date) <= ?", args.first, args[1]]}}
  # scope :with_due_date_for_calendar, lambda { |*args| { conditions: ["DATE(stickies.due_date) >= ? and DATE(stickies.due_date) <= ? or (stickies.due_date IS NULL and stickies.frame_id in (select frames.id from frames where DATE(frames.end_date) >= ? and DATE(frames.end_date) <= ?))", args.first, args[1], args.first, args[1]]}}

  scope :due_today,     lambda { |*args| { conditions: ["stickies.completed = ? and DATE(stickies.due_date) = ?", false, Date.today]}}
  scope :past_due,      lambda { |*args| { conditions: ["stickies.completed = ? and DATE(stickies.due_date) < ?", false, Date.today]}}
  scope :due_this_week, lambda { |*args| { conditions: ["stickies.completed = ? and DATE(stickies.due_date) > ? and DATE(stickies.due_date) < ?", false, Date.today, Date.today + (7-Date.today.wday).days]}}

  scope :with_tag, lambda { |*args| { conditions: [ "stickies.id IN (SELECT stickies_tags.sticky_id from stickies_tags where stickies_tags.tag_id IN (?))", args.first ] } }
  scope :with_tag_name, lambda { |*args| { conditions: [ "stickies.id IN (SELECT stickies_tags.sticky_id from stickies_tags, tags where stickies_tags.tag_id = tags.id and tags.name IN (?))", args.first ] } }

  before_create :set_start_date
  after_create :send_email

  before_save :set_end_date, :set_project_and_frame
  after_save :send_completion_email, :send_due_at_updated

  # Model Validation
  validates_presence_of :description, :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project, touch: true
  belongs_to :group
  belongs_to :frame
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_and_belongs_to_many :tags

  def due_at_string
    due_at.blank? ? '' : due_at.localtime.strftime("%l:%M %p").strip
  end

  def due_at_string_short
    self.due_at_string.gsub(':00', '').gsub(' AM', '').gsub(' PM', 'p')
  end

  def due_at_end_string
    (due_at.blank? or self.duration <= 0) ? '' : (due_at + self.duration.send(self.duration_units)).localtime.strftime("%l:%M %p").strip
  end

  def due_at_end_string_short
    self.due_at_end_string.gsub(':00', '').gsub(' AM', '').gsub(' PM', 'p')
  end

  def due_at_end_string_with_duration
    (due_at.blank? or self.duration <= 0) ? '' : self.due_at_end_string + " (#{self.duration} #{self.duration_units})"
  end

  def due_at_range_short
    self.due_at_string_short + (self.due_at_end_string_short.blank? ? '' : '-' + self.due_at_end_string_short)
  end

  def due_at_range
    self.due_at_string + (self.due_at_end_string.blank? ? '' : ' to ' + self.due_at_end_string)
  end

  def due_at_string=(due_at_str)
    self.due_at = Time.parse(due_at_str)
  rescue
    self.due_at = nil
  end

  def due_date_time_start
    Time.zone.parse(self.due_date.to_s + " " + self.due_at_string)
  end

  def due_date_time_end
    Time.zone.parse((self.due_date_time_start + self.duration.send(self.duration_units)).to_s + " " + self.due_at_end_string)
  end

  def export_ics
    RiCal.Calendar do |cal|
      self.export_ics_block_evt(cal)
    end.to_s
  end

  def export_ics_block_evt(cal)
    cal.event do |evt|
      evt.summary     = self.full_description.truncate(27)
      evt.description = self.ics_description
      evt.dtstart     = self.due_date_time_start unless self.due_at.blank?
      evt.dtend       = self.due_date_time_end   unless self.due_at.blank? or self.duration <= 0
      evt.uid         = "#{SITE_URL}/stickies/#{self.id}"
    end
  end

  def include_ics?
    not self.due_at.blank? and not self.due_date.blank?
  end

  def tag_ids
    self.tags.order('tags.name').pluck('tags.id')
  end

  def name
    "ID ##{self.id}"
  end

  def destroy
    self.comments.destroy_all
    update_attribute :deleted, true
  end

  def comments(limit = nil)
    Comment.current.with_class_name(self.class.name).with_class_id(self.id).order('created_at desc').limit(limit)
  end

  def new_comment(current_user, description)
    Comment.create(class_name: self.class.name, class_id: self.id, user_id: current_user.id, description: description)
    self.touch
  end

  def full_description
    @full_description ||= begin
      if self.group and not self.group.description.blank?
        self.description + "\n\n" + self.group.description
      else
        self.description
      end
    end
  end

  def ics_description
    result = ''
    result << "To Update Sticky: #{SITE_URL}/stickies/#{self.id}\n\n"
    result << "Status: #{self.completed? ? 'Completed' : 'Not Completed'}\n\n"
    result << "Assigned To: #{self.owner.name}\n\n" if self.owner
    result << "Project: #{self.project.name}\n\n"
    result << self.full_description + "\n\n"
    result << "Tags: #{self.tags.collect{|t| t.name}.join(', ')}\n\n" if self.tags.size > 0
    result
  end

  def shift_group(days_to_shift, shift)
    if days_to_shift != 0 and self.group and ['incomplete', 'all'].include?(shift)
      sticky_scope = self.group.stickies.where("stickies.id != ?", self.id)
      sticky_scope = sticky_scope.where(completed: false) if shift == 'incomplete'
      sticky_scope.select{ |s| not s.due_date.blank? }.each{ |s| s.update_attribute :due_date, s.due_date + days_to_shift.days }
    end
  end

  private

  def send_email
    if not self.group and not self.completed?
      all_users = self.project.users_to_email(:sticky_creation) - [self.user]
      all_users.each do |user_to_email|
        UserMailer.sticky_by_mail(self, user_to_email).deliver if Rails.env.production?
      end
    end
  end

  # TODO: Currently assumes that the owner marks the sticky as completed.
  def send_completion_email
    if self.changes[:completed] and self.changes[:completed][1] == true and self.owner
      all_users = self.project.users_to_email(:sticky_completion) - [self.owner]
      all_users.each do |user_to_email|
        UserMailer.sticky_completion_by_mail(self, user_to_email).deliver if Rails.env.production?
      end
    end
  end

  # Only send if completion email was not sent
  def send_due_at_updated
    if self.changes[:due_at] and not self.changes[:completed] and self.created_at != self.updated_at
      first_time = Time.parse(self.changes[:due_at][0].to_s).strftime("%r") rescue ""
      last_time = Time.parse(self.changes[:due_at][1].to_s).strftime("%r") rescue ""
      unless first_time == last_time
        all_users = self.project.users_to_email(:sticky_due_time_changed) - [self.owner]
        all_users.each do |user_to_email|
          UserMailer.sticky_due_at_changed_by_mail(self, user_to_email).deliver if Rails.env.production?
        end
      end
    end
  end

  def set_start_date
    self.start_date = Date.today
  end

  def set_end_date
    self.end_date = ((self.changes[:completed] and self.changes[:completed][1] == true) ? Date.today : nil) unless self.completed? and self.changes[:completed] == nil
  end

  def set_project_and_frame
    if self.group
      self.project_id = self.group.project_id
      if not self.group.project.frames.collect{|f| f.id}.include?(self.frame_id) and self.changes[:frame_id]
        self.frame_id = self.changes[:frame_id][0]
      end
    end
  end

end
