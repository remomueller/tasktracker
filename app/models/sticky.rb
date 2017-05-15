# frozen_string_literal: true

# Encapsulates a project task.
class Sticky < ApplicationRecord
  before_create :set_start_date
  after_save :clone_repeat
  before_save :set_end_date, :set_project_and_board

  REPEAT = %w(none day week month year).collect { |i| [i, i] }

  # Concerns
  include Deletable

  # Scopes
  scope :search, lambda { |arg| where('LOWER(stickies.description) LIKE ? or stickies.group_id IN (select groups.id from groups where LOWER(groups.description) LIKE ?)', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')).references(:groups) }
  scope :with_creator, lambda { |arg|  where( user_id: arg ) }
  scope :with_owner, lambda { |arg|  where("stickies.owner_id IN (?) or stickies.owner_id IS NULL", arg) }
  scope :with_board, lambda { |arg| where("stickies.board_id IN (?) or (stickies.board_id IS NULL and 0 IN (?))", arg, arg) }
  scope :updated_since, lambda { |arg| where("stickies.updated_at > ?", arg) }
  scope :with_date_for_calendar, lambda { |*args| where("DATE(stickies.created_at) >= ? and DATE(stickies.created_at) <= ?", args.first, args[1]) }

  # TODO: Deprecated this scope
  scope :with_due_date_for_calendar, lambda { |*args| where( due_date: args.first..args[1] ) }
  # END TODO

  scope :due_date_before, lambda { |arg| where("stickies.due_date < ?", arg+1.day) }
  scope :due_date_after, lambda { |arg| where("stickies.due_date >= ?", arg) }

  scope :due_date_before_or_blank, lambda { |arg| where("stickies.due_date < ? or stickies.due_date IS NULL", arg+1.day) }
  scope :due_date_after_or_blank, lambda { |arg| where("stickies.due_date >= ? or stickies.due_date IS NULL", arg) }

  scope :due_today,     -> { where(completed: false).where(due_date: Time.zone.today) }
  scope :past_due,      -> { where(completed: false).where('stickies.due_date < ?', Time.zone.today) }
  scope :due_upcoming,  -> { where(completed: false).where('stickies.due_date > ? and stickies.due_date <= ?', Time.zone.today, (Time.zone.today.friday? ? Date.tomorrow + 2.days : Date.tomorrow)) }
  scope :due_this_week, -> { where(completed: false).where(due_date: (Time.zone.today - Time.zone.today.wday.days)..(Time.zone.today + (6 - Time.zone.today.wday).days)) }

  scope :with_tag, lambda { |arg| where('stickies.id IN (SELECT stickies_tags.sticky_id from stickies_tags where stickies_tags.tag_id IN (?))', arg).references(:tags) }

  # Model Validation
  validates :description, :project_id, presence: true
  validates :repeat_amount, numericality: { only_integer: true, greater_than: 0 }

  # Model Relationships
  belongs_to :user
  belongs_to :project, touch: true
  belongs_to :group
  belongs_to :board
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  belongs_to :completer, class_name: 'User', foreign_key: 'completer_id'
  belongs_to :repeated_sticky, -> { current }, class_name: 'Sticky', foreign_key: 'repeated_sticky_id'
  has_and_belongs_to_many :tags
  has_many :comments, -> { current.order(created_at: :desc) }
  has_many :notifications

  # Panel returns 'completed', 'past_due', or 'upcoming'
  # Since both upcoming and past_due incomplete contain stickies
  # with "today's" due date or without a due date, these both get
  # placed into past_due
  def panel
    if completed?
      'completed'
    elsif due_date && due_date.to_date > Time.zone.today
      'upcoming'
    else
      'past_due'
    end
  end

  def modifiable_by?(current_user)
    # current_user.all_projects.pluck(:id).include?(self.project_id)
    project_id.blank? || project.modifiable_by?(current_user)
  end

  def tag_ids
    tags.order(:name, :id).pluck(:id)
  end

  def name
    "##{id}"
  end

  def full_description
    if group && group.description.present?
      "#{description}\n\n#{group.description}"
    else
      description
    end
  end

  def group_description
    group ? group.description : nil
  end

  def description_html
    result = full_description.to_s
    result += "\n\n<hr style=\"margin-top:5px;margin-bottom:5px\">"
    result += "<div style='white-space:nowrap'><strong>Assigned</strong> #{owner.name} <img alt='' src='#{owner.avatar_url(18, "identicon")}' class='img-rounded'></div>" if owner
    result += "<strong>Board</strong> #{board ? board.name : 'Holding Pen'}<br />" if project.boards.size > 0
    result += "<strong>Repeats</strong> #{repeat_amount} #{repeat}#{'s' if repeat_amount != 1} after due date<br />" if repeat != 'none'
    result
  end

  def shift_group(days_to_shift, shift)
    all_dates = []
    if days_to_shift != 0 && group && %w(incomplete all).include?(shift)
      sticky_scope = group.stickies.where.not(id: id)
      sticky_scope = sticky_scope.where(completed: false) if shift == 'incomplete'
      sticky_scope.where.not(due_date: nil).each do |s|
        all_dates << s.due_date
        s.update due_date: s.due_date + days_to_shift.days
        all_dates << s.due_date
      end
    end
    all_dates
  end

  def create_notifications_if_recently_completed!(current_user)
    if previous_changes[:completed] && previous_changes[:completed][1] == true
      update due_date: Time.zone.today if due_date.blank?
      update completer: current_user
      create_notifications!
    end
  end

  def create_notifications!
    users_to_notify.where.not(id: completer_id).find_each do |u|
      notification = u.notifications.where(project_id: project_id, sticky_id: id).first_or_create
      notification.mark_as_unread!
    end
  end

  def destroy
    super
    comments.destroy_all
    notifications.destroy_all
  end

  def users_to_notify
    project.all_members
  end

  private

  def clone_repeat
    if saved_changes[:completed] && self.saved_changes[:completed][1] == true && repeat != 'none' && repeated_sticky.blank? && due_date.present?
      new_sticky = user.stickies.new(attributes.reject { |key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at', 'start_date', 'end_date', 'repeated_sticky_id', 'completed'].include?(key.to_s) })
      new_sticky.due_date += (repeat_amount).send(new_sticky.repeat)
      new_sticky.tag_ids = tags.pluck(:id)
      new_sticky.save
      update_column :repeated_sticky_id, new_sticky.id
    end
  end

  def set_start_date
    self.start_date = Time.zone.today
  end

  def set_end_date
    return if completed? && saved_changes[:completed].nil?
    self.end_date = (saved_changes[:completed] && saved_changes[:completed][1] == true ? Time.zone.today : nil)
  end

  def set_project_and_board
    return unless group
    self.project_id = group.project_id
    if !(group.project.boards.pluck(:id) + [nil]).include?(board_id) && saved_changes[:board_id]
      self.board_id = saved_changes[:board_id][0]
    end
  end
end
