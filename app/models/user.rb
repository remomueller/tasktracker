class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :first_name, :last_name
  
  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
  has_many :projects, :conditions => {:deleted => false}, :order => 'name'
  has_many :stickies, :conditions => {:deleted => false}, :order => 'created_at'
  has_many :comments, :conditions => {:deleted => false}, :order => 'created_at'

  def destroy
    update_attribute :deleted, true
    update_attribute :status, 'inactive'
  end

  def all_projects
    @all_projects ||= begin
      if self.system_admin?
        Project.current.order('name')
      else
        self.projects
      end
    end
  end
  
  def all_stickies
    @all_stickies ||= begin
      if self.system_admin?
        Sticky.current.order('created_at')
      else
        self.stickies
      end
    end
  end
  
  def all_comments
    @all_comments ||= begin
      if self.system_admin?
        Comment.current.order('created_at')
      else
        self.comments
      end
    end
  end
  
  def system_admin?
    false
  end

  def name
    "#{first_name} #{last_name}"
  end
  
  def rev_name
    "#{last_name}, #{first_name}"
  end
  
  def apply_omniauth(omniauth)
    unless omniauth['user_info'].blank?
      self.email = omniauth['user_info']['email'] if email.blank?
      self.first_name = omniauth['user_info']['first_name'] if first_name.blank?
      self.last_name = omniauth['user_info']['last_name'] if last_name.blank?
    end
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
end
