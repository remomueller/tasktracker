# Use to configure basic appearance of template
Contour.setup do |config|
  
  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME
  
  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Notes::VERSION::STRING
  
  # Enter your application header background image here.
  # config.header_background_image = 'rails.png'

  # Enter your application header title image here.
  # config.header_title_image = ''
  
  # Enter the items you wish to see in the menu
  # config.menu_items = [{
  #   :name => 'Login', :id => 'auth', :display => 'not_signed_in', :position => 'right', :position_class => 'right',
  #   :links => [{:name => 'Login', :path => 'new_user_session_path'}, {:html => "<hr>"}, {:name => 'Sign Up', :path => 'new_user_registration_path'}]
  # },
  # {
  #   :name => 'current_user.name', :eval => true, :id => 'auth', :display => 'signed_in', :position => 'right', :position_class => 'right',
  #   :links => [{:html => '"<div style=\"white-space:nowrap\">"+current_user.name+"</div>"', :eval => true}, {:html => '"<div class=\"small quiet\">"+current_user.email+"</div>"', :eval => true}, {:name => 'Authentications', :path => 'authentications_path'}, {:html => "<hr>"}, {:name => 'Logout', :path => 'destroy_user_session_path'}]
  # },
  # {
  #   :name => 'Home', :id => 'home', :display => 'always', :position => 'left', :position_class => 'left',
  #   :links => [{:name => 'Home', :path => 'root_path'}, {:html => "<hr>"}, {:name => 'About', :path => 'about_path'}]
  # }]
  
end