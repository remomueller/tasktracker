class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  # Model Validation
  validates_presence_of     :first_name
  validates_presence_of     :last_name

  # Model Relationships
  has_many :authentications
    

  def name
    "#{first_name} #{last_name}"
  end
  
  def rev_name
    "#{last_name}, #{first_name}"
  end
  
  def apply_omniauth(omniauth)
    self.email = omniauth['user_info']['email'] if email.blank?
    self.first_name =  omniauth['user_info']['first_name'] if first_name.blank?
    self.last_name =  omniauth['user_info']['last_name'] if last_name.blank?
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

  def password_required?
    (authentications.empty? || !password.blank?) && super
  end
end
