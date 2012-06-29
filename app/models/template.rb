class Template < ActiveRecord::Base
  attr_accessible :name, :project_id, :item_tokens, :avoid_weekends, :items

  serialize :items, Array
  attr_reader :item_tokens

  # Named Scopes
  scope :none, conditions: ["1 = 0"]
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["templates.project_id IN (?) or (templates.project_id IS NULL and templates.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| {conditions: [ 'LOWER(name) LIKE ? or LOWER(items) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :project_id, :items
  validates_uniqueness_of :name, scope: [:deleted, :project_id]

  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, conditions: { deleted: false }

  def copyable_attributes
    self.attributes.reject{|key, val| ['id', 'user_id', 'deleted', 'created_at', 'updated_at'].include?(key.to_s)}
  end

  def full_name
    [self.name, (self.project ? self.project.name : nil)].compact.join(' - ')
  end

  def destroy
    update_attribute :deleted, true
    # self.stickies.update_all(frame_id: nil)
  end

  def item_tokens=(tokens)
    self.items = []
    tokens.each_pair do |key, item_hash|
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
    self.items.sort!{|a,b| a.symbolize_keys[:interval].to_i.send(a.symbolize_keys[:units]) <=> b.symbolize_keys[:interval].to_i.send(b.symbolize_keys[:units])}
  end

  def generate_stickies!(current_user, frame_id, initial_date = Date.today, additional_text = nil)
    group = current_user.groups.create({ project_id: self.project_id, description: additional_text, template_id: self.id })
    self.sorted_items.each_with_index do |item|
      item = item.symbolize_keys
      due_date = (initial_date == nil ? nil : initial_date + item[:interval].send(item[:units]))
      if self.avoid_weekends? and due_date
        due_date -= 1.day if due_date.saturday? # Change to Friday
        due_date += 1.day if due_date.sunday?   # Change to Monday
      end

      all_day = begin
        unless item[:due_at_string].blank?
          t = Time.parse(item[:due_at_string])
          due_date = Time.parse(due_date.strftime("%Y-%m-%d ") + item[:due_at_string])
          false
        else
          true
        end
      rescue
        true
      end

      current_user.stickies.create({  group_id:       group.id,
                                      project_id:     self.project_id,
                                      frame_id:       frame_id,
                                      owner_id:       item[:owner_id],
                                      description:    item[:description].to_s,
                                      tag_ids:        (item[:tag_ids] || []),
                                      completed:      false,
                                      due_date:       due_date,
                                      all_day:        all_day,
                                      duration:       item[:duration].to_i.abs,
                                      duration_units: item[:duration_units].blank? ? 'hours' : item[:duration_units]
                                    })
    end
    group.reload

    all_users = self.project.users_to_email(:sticky_creation) - [current_user]
    all_users.each do |user_to_email|
      UserMailer.group_by_mail(group, user_to_email).deliver if Rails.env.production?
    end

    group
  end

  def sorted_items
    self.items.sort{|a,b| a.symbolize_keys[:interval].to_i.send(a.symbolize_keys[:units]) <=> b.symbolize_keys[:interval].to_i.send(b.symbolize_keys[:units])}
  end
end
