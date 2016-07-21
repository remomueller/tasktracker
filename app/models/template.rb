# frozen_string_literal: true

# Allows project to create templates for groups of tasks.
class Template < ActiveRecord::Base
  # attr_accessible :name, :project_id, :item_tokens, :avoid_weekends, :items

  serialize :items, Array
  attr_reader :item_tokens

  # Concerns
  include Deletable, Filterable, Searchable

  # Named Scopes

  # Model Validation
  validates :name, :project_id, :items, presence: true
  validates :name, uniqueness: { scope: [:deleted, :project_id] }

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, -> { current }

  def self.searchable_attributes
    %w(name items)
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

  def item_tokens=(tokens)
    self.items = []
    tokens.each do |item_hash|
      self.items << { description: item_hash[:description],
                      interval: item_hash[:interval].to_i,
                      units: (['days','weeks','months','years'].include?(item_hash[:units]) ? item_hash[:units] : 'days'),
                      owner_id: item_hash[:owner_id],
                      tag_ids: (item_hash[:tag_ids] || []),
                      due_at_string: item_hash[:due_at_string],
                      duration: item_hash[:duration].to_i.abs,
                      duration_units: (item_hash[:duration_units].blank? ? 'hours' : item_hash[:duration_units])
                    } unless item_hash[:description].blank?
    end
    self.items.sort!{|a,b| a.symbolize_keys[:interval].to_i.send(a.symbolize_keys[:units]).to_i <=> b.symbolize_keys[:interval].to_i.send(b.symbolize_keys[:units]).to_i }
  end

  def generate_stickies!(current_user, board_id, initial_date = Date.today, additional_text = nil)
    group = project.groups.create(user_id: current_user.id, description: additional_text, template_id: id)
    sorted_items.each_with_index do |item|
      item = item.symbolize_keys
      due_date = (initial_date.nil? ? nil : initial_date + item[:interval].send(item[:units]))
      if avoid_weekends? && due_date
        due_date -= 1.day if due_date.saturday? # Change to Friday
        due_date += 1.day if due_date.sunday?   # Change to Monday
      end

      due_time = item[:due_at_string]

      current_user.stickies.create(
        group_id:       group.id,
        project_id:     project_id,
        board_id:       board_id,
        owner_id:       item[:owner_id],
        description:    item[:description].to_s,
        tag_ids:        (item[:tag_ids] || []),
        completed:      false,
        due_date:       due_date,
        due_time:       due_time,
        all_day:        due_time.blank?,
        duration:       item[:duration].to_i.abs,
        duration_units: item[:duration_units].blank? ? 'hours' : item[:duration_units]
      )
    end
    group.reload

    group.send_email_in_background

    group
  end

  def sorted_items
    items.sort { |a,b| a.symbolize_keys[:interval].to_i.send(a.symbolize_keys[:units]).to_i <=> b.symbolize_keys[:interval].to_i.send(b.symbolize_keys[:units]).to_i }
  end
end
