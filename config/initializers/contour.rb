# Use to configure basic appearance of template
Contour.setup do |config|
  
  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME
  
  # If you want to style your name using html you can do so here, ex: <b>App</b>Name
  # config.application_name_html = ''

  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Notes::VERSION::STRING
  
  # Enter your application header background image here.
  config.header_background_image = 'brigham.png'

  # Enter your application header title image here.
  config.header_title_image = 'stylefile.png'
  
  # Enter the items you wish to see in the menu
  config.menu_items = [
    {
      name: 'Login', id: 'auth', display: 'not_signed_in', position: 'right', position_class: 'right',
      links: [{ name: 'Login', path: 'new_user_session_path' }, { html: "<hr>" }, { name: 'Sign Up', path: 'new_user_registration_path' }]
    },
    {
      name: 'current_user.name', eval: true, id: 'auth', display: 'signed_in', position: 'right', position_class: 'right',
      links: [{ html: '"<div style=\"white-space:nowrap\">"+current_user.name+"</div>"', eval: true },
              { html: '"<div class=\"small quiet\">"+current_user.email+"</div>"', eval: true },
              { name: 'Settings', path: 'settings_path' },
              { name: 'Authentications', path: 'authentications_path' },
              { html: "<hr>" },
              { name: 'Logout', path: 'destroy_user_session_path' }]
    },
    # {
    #   name: 'Frames', id: 'frames', display: 'signed_in', position: 'left', position_class: 'left_center',
    #   links: [{ name: 'Frames', path: 'frames_path' },
    #           { name: '&raquo;New', path: 'new_frame_path' }]
    # },
    # {
    #   name: 'Stickies', id: 'stickies', display: 'signed_in', position: 'left', position_class: 'left_center',
    #   links: [{ name: 'Stickies', path: 'stickies_path' },
    #           { name: '&raquo;New', path: 'new_sticky_path' },
    #           { name: '&raquo;Graphs', path: 'graph_user_path(current_user.id)' }]
    # },
    {
      name: 'Calendar', id: 'calendar', display: 'signed_in', position: 'left', position_class: 'left',
      links: [{ name: 'Calendar', path: 'calendar_stickies_path' },
              { name: 'Templates', path: 'templates_path' }]
    },
    {
      name: 'Projects', id: 'projects', display: 'always', position: 'left', position_class: 'left_center',
      links: [{ name: 'Projects', path: 'projects_path' },
              { name: '&raquo;New', path: 'new_project_path' },
              { html: "<hr>" },
              { name: 'About', path: 'about_path' }]
    },
    # {
    #   name: 'Templates', id: 'templates', display: 'signed_in', position: 'left', position_class: 'left_center',
    #   links: [{ name: 'Templates', path: 'templates_path' },
    #           { name: '&raquo;New', path: 'new_template_path' }]
    # },
    # {
    #   name: 'Comments', id: 'comments', display: 'signed_in', position: 'left', position_class: 'left_center',
    #   links: [{ name: 'Comments', path: 'comments_path' },
    #           { name: '&raquo;New', path: 'new_comment_path' }]
    # },
    {
      name: 'Users', id: 'users', display: 'signed_in', position: 'left', position_class: 'left_center', condition: 'current_user.system_admin?',
      links: [{ name: 'Users', path: 'users_path' },
              { name: '&raquo;Overall Graph', path: 'overall_graph_users_path', condition: 'current_user.system_admin?' }]
    }
  ]
  
  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  config.news_feed = 'https://sleepepi.partners.org/category/informatics/notes-project-management/feed/rss'
  
  # Enter the max number of items you want to see in the news feed.
  config.news_feed_items = 3 
end