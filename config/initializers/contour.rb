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
      name: 'Login', display: 'not_signed_in', path: 'new_user_session_path', position: 'right',
      links: [{ name: 'Sign Up', path: 'new_user_registration_path' }]
    },
    {
      name: 'current_user.name', eval: true, display: 'signed_in', path: 'user_path(current_user)', position: 'right',
      links: [{ html: '"<div class=\"small\" style=\"color:#bbb\">"+current_user.email+"</div>"', eval: true },
              { name: 'Settings', path: 'settings_path' },
              { name: 'Authentications', path: 'authentications_path', condition: 'not PROVIDERS.blank?' },
              { html: "<br />" },
              { name: 'Logout', path: 'destroy_user_session_path' }]
    },
    # {
    #   name: 'Frames', display: 'signed_in', path: 'frames_path', position: 'left',
    #   links: [{ name: '&raquo;New', path: 'new_frame_path' }]
    # },
    # {
    #   name: 'Stickies', display: 'signed_in', path: 'stickies_path', position: 'left',
    #   links: [{ name: '&raquo;New', path: 'new_sticky_path' },
    #           { name: '&raquo;Graphs', path: 'graph_user_path(current_user.id)' }]
    # },
    {
      name: 'About', display: 'not_signed_in', path: 'about_path', position: 'left',
      links: []
    },
    {
      name: 'Calendar', display: 'signed_in', path: 'calendar_stickies_path', position: 'left',
      links: [{ html: "<br />" },
              { name: 'About', path: 'about_path' }]
    },
    {
      name: '@project.name', eval: true, display: 'signed_in', path: 'project_path(@project)', position: 'left',
      condition: '@project and not @project.new_record?',
      links: [{ name: 'Frames', path: 'frames_path(project_id: @project.id)' },
              { name: 'Templates', path: 'templates_path(project_id: @project.id)' }]
    },
    # {
    #   name: 'Projects', display: 'signed_in', path: 'projects_path', position: 'left',
    #   links: [{ name: '&raquo;New', path: 'new_project_path' }]
    # },
    # {
    #   name: 'Templates', display: 'signed_in', path: 'templates_path', position: 'left',
    #   links: [{ name: '&raquo;New', path: 'new_template_path' }]
    # },
    # {
    #   name: 'Comments', display: 'signed_in', path: 'comments_path', position: 'left',
    #   links: [{ name: '&raquo;New', path: 'new_comment_path' }]
    # },
    {
      name: 'Users', display: 'signed_in', name: 'Users', path: 'users_path', position: 'left', condition: 'current_user.system_admin?',
      links: [{ name: 'Overall Graph', path: 'overall_graph_users_path', condition: 'current_user.system_admin?' }]
    }
  ]
  
  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  config.news_feed = 'https://sleepepi.partners.org/category/informatics/notes-project-management/feed/rss'
  
  # Enter the max number of items you want to see in the news feed.
  config.news_feed_items = 3 
end