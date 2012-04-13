class Tag < ActiveRecord::Base
  # Named Scopes
  scope :current, conditions: { deleted: false }
  scope :with_project, lambda { |*args| { conditions: ["tags.project_id IN (?) or (tags.project_id IS NULL and tags.user_id = ?)", args.first, args[1]] } }
  scope :search, lambda { |*args| { conditions: [ 'LOWER(tags.name) LIKE ? or LOWER(tags.description) LIKE ?', '%' + args.first.downcase.split(' ').join('%') + '%', '%' + args.first.downcase.split(' ').join('%') + '%' ] } }

  # Model Validation
  validates_presence_of :name, :project_id
  validates_uniqueness_of :name, scope: :project_id

  # Model Relationships
  belongs_to :user
  belongs_to :project
  has_and_belongs_to_many :stickies

  # Model Relationships
  def destroy
    update_attribute :deleted, true
  end

end
