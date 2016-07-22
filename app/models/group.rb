# frozen_string_literal: true

# Allows a set of tasks to be grouped together.
class Group < ActiveRecord::Base
  attr_accessor :board_id, :initial_due_date

  # Concerns
  include Deletable, Filterable, Forkable

  # Named Scopes
  scope :search, -> (arg) { where('LOWER(description) LIKE ? or groups.template_id IN (select templates.id from templates where LOWER(templates.name) LIKE ?)', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')).references(:templates) }

  # Model Validation
  validates :project_id, presence: true

  # Model Relationships
  belongs_to :user
  belongs_to :template
  belongs_to :project
  has_many :stickies, -> { current.order(:due_date) }

  def name
    "##{id}"
  end

  def short_description(fallback = "Group #{name}")
    result = description.to_s.split(/[\r\n]/).collect(&:strip).find(&:present?)
    result = fallback unless result
    result
  end

  def short_description_second_half
    description.to_s.strip.gsub(short_description, '').strip
  end

  def destroy
    stickies.destroy_all
    super
  end

  def send_email_in_background
    fork_process(:send_email)
  end

  private

  def send_email
    return unless EMAILS_ENABLED
    all_users = project.users_to_email - [user]
    all_users.each do |user_to_email|
      UserMailer.group_by_mail(self, user_to_email).deliver_now
    end
  end
end
