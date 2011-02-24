class Project < ActiveRecord::Base

  STATUS = ["planned", "ongoing", "completed"].collect{|i| [i,i]}

  # Named Scopes
  scope :current, :conditions => { :deleted => false }

  # Model Relationships
  belongs_to :user

  def destroy
    update_attribute :deleted, true
  end

end
