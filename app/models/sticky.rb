class Sticky < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "resolved", "completed"].collect{|i| [i,i]}
  STICKY_TYPE = ["generic", "action item", "goal", "roadblock"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }

  # Model Relationships
  belongs_to :user

  def destroy
    update_attribute :deleted, true
  end

end
