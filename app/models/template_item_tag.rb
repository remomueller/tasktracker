# frozen_string_literal: true

# Defines a tag on a templated task.
class TemplateItemTag < ActiveRecord::Base
  # Model Validation
  validates :template_item_id, :tag_id, presence: true

  # Model Relationships
  belongs_to :tag
  belongs_to :template_item
end
