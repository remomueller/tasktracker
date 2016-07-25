# frozen_string_literal: true

# Allows project to create templates for groups of tasks.
class Template < ActiveRecord::Base
  attr_accessor :item_hashes
  after_save :set_items

  # Concerns
  include Deletable, Filterable, Searchable

  # Named Scopes

  # Model Validation
  validates :name, :project_id, :item_hashes, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, -> { current }
  has_many :template_items, -> { order :position }

  def self.searchable_attributes
    %w(name)
  end

  def copyable_attributes
    attributes.reject { |key, val| %w(id user_id deleted created_at updated_at).include?(key.to_s) }
  end

  def full_name
    [name, (project ? project.name : nil)].compact.join(' - ')
  end

  def self.natural_sort
    NaturalSort.sort where('').pluck(:name, :id)
  end

  def generate_stickies!(current_user, board_id, initial_date = Date.today, additional_text = nil)
    group = project.groups.create(user_id: current_user.id, description: additional_text, template_id: id)
    template_items.each do |template_item|
      due_date = (initial_date.nil? ? nil : initial_date + template_item.interval.send(template_item.interval_units))
      if avoid_weekends? && due_date
        due_date -= 1.day if due_date.saturday? # Change to Friday
        due_date += 1.day if due_date.sunday?   # Change to Monday
      end

      current_user.stickies.create(
        group_id:       group.id,
        project_id:     project_id,
        board_id:       board_id,
        owner_id:       template_item.owner_id,
        description:    template_item.description.to_s,
        tag_ids:        template_item.template_item_tags.pluck(:tag_id),
        completed:      false,
        due_date:       due_date,
        due_time:       template_item.due_time,
        all_day:        template_item.due_time.blank?,
        duration:       template_item.duration.abs,
        duration_units: template_item.duration_units
      )
    end
    group.reload

    group.send_email_in_background

    group
  end

  private

  def set_items
    return unless item_hashes && item_hashes.is_a?(Array)
    template_items.destroy_all
    sorted_item_hashes.each_with_index do |hash, index|
      template_item = template_items.create(
        position: index,
        description: hash[:description],
        interval: hash[:interval].to_i,
        interval_units: (%w(days weeks months years).include?(hash[:interval_units]) ? hash[:interval_units] : 'days'),
        owner_id: hash[:owner_id],
        due_time: hash[:due_time],
        duration: hash[:duration].to_i.abs,
        duration_units: (%w(minutes hours days weeks months years).include?(hash[:duration_units]) ? hash[:duration_units] : 'hours')
      )
      (hash[:tag_ids] || []).each do |tag_id|
        template_item.template_item_tags.where(tag_id: tag_id).first_or_create
      end
    end
  end

  def sorted_item_hashes
    item_hashes.sort do |a,b|
      a.symbolize_keys[:interval].to_i.send(a.symbolize_keys[:interval_units]).to_i <=> b.symbolize_keys[:interval].to_i.send(b.symbolize_keys[:interval_units]).to_i
    end
  end
end
