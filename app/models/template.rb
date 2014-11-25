class Template < ActiveRecord::Base
  # attr_accessible :name, :project_id, :item_tokens, :avoid_weekends, :items

  serialize :items, Array
  attr_reader :item_tokens

  # Concerns
  include Deletable, Filterable

  # Named Scopes
  scope :search, lambda { |arg| where('LOWER(name) LIKE ? or LOWER(items) LIKE ?', arg.to_s.downcase.gsub(/^| |$/, '%'), arg.to_s.downcase.gsub(/^| |$/, '%')) }

  # Model Validation
  validates_presence_of :name, :project_id, :items
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, -> { where deleted: false }

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  def full_name
    [self.name, (self.project ? self.project.name : nil)].compact.join(' - ')
  end

  def self.natural_sort
    NaturalSort::naturalsort self.where('').collect{|t| [t.name, t.id]}
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
    group = current_user.groups.create({ project_id: self.project_id, description: additional_text, template_id: self.id })
    self.sorted_items.each_with_index do |item|
      item = item.symbolize_keys
      due_date = (initial_date == nil ? nil : initial_date + item[:interval].send(item[:units]))
      if self.avoid_weekends? and due_date
        due_date -= 1.day if due_date.saturday? # Change to Friday
        due_date += 1.day if due_date.sunday?   # Change to Monday
      end

      due_time = item[:due_at_string]

      current_user.stickies.create({  group_id:       group.id,
                                      project_id:     self.project_id,
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
                                    })
    end
    group.reload

    all_users = self.project.users_to_email(:sticky_creation) - [current_user]
    all_users.each do |user_to_email|
      UserMailer.group_by_mail(group, user_to_email).deliver_later if Rails.env.production?
    end

    group
  end

  def sorted_items
    self.items.sort{|a,b| a.symbolize_keys[:interval].to_i.send(a.symbolize_keys[:units]).to_i <=> b.symbolize_keys[:interval].to_i.send(b.symbolize_keys[:units]).to_i }
  end
end
