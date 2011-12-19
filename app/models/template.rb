class Template < ActiveRecord::Base

  serialize :items, Array
  attr_reader :item_tokens

  # Named Scopes
  scope :current, :conditions => { :deleted => false }
  scope :with_project, lambda { |*args| { :conditions => ["templates.project_id IN (?) or (templates.project_id IS NULL and templates.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| {:conditions => [ 'LOWER(name) LIKE ? or LOWER(items) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :project_id, :items
  
  # Model Relationships
  belongs_to :project
  belongs_to :user
  has_many :stickies, :conditions => { :deleted => false }

  def destroy
    update_attribute :deleted, true
    # self.stickies.update_all(:frame_id => nil)
  end

  def item_tokens=(tokens)
    self.items = []
    tokens.each_pair do |key, item_hash|
      self.items << { description: item_hash[:description],
                      interval: item_hash[:interval].to_i,
                      units: (['days','weeks','months','years'].include?(item_hash[:units]) ? item_hash[:units] : 'days'),
                      owner_id: item_hash[:owner_id]
                    } unless item_hash[:description].blank?
    end
  end
  
  def generate_stickies!(current_user, frame_id, initial_date = Date.today, additional_text = nil)
    group = current_user.groups.create({ project_id: self.project_id, description: additional_text, template_id: self.id })
    self.items.each_with_index do |item|
      item = item.symbolize_keys
      current_user.stickies.create({ group_id: group.id, project_id: self.project_id, frame_id: frame_id, owner_id: item[:owner_id], description: item[:description].to_s, status: 'ongoing', due_date: (initial_date == nil ? nil : initial_date + item[:interval].send(item[:units])) })
    end
    group.reload
    
    all_users = (self.project.users + [self.project.user]).uniq - [current_user]
    all_users.each do |user_to_email|
      UserMailer.group_by_mail(group, user_to_email).deliver if user_to_email.active_for_authentication? and user_to_email.email_on?(:send_email) and user_to_email.email_on?(:sticky_creation) and user_to_email.email_on?("project_#{self.project.id}") and Rails.env.production?
    end
    
    group
  end
end
