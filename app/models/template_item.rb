# frozen_string_literal: true

# Defines a templated task.
class TemplateItem < ActiveRecord::Base
  # Model Validation
  validates :description, :template_id, presence: true

  # Model Relationships
  belongs_to :template
  belongs_to :owner, class_name: 'User', foreign_key: 'owner_id'
  has_many :template_item_tags

  # Model Methods
  def destroy
    template_item_tags.destroy_all
    super
  end
end
