# Use to configure basic appearance of template
Contour.setup do |config|

  # Enter your application name here. The name will be displayed in the title of all pages, ex: AppName - PageTitle
  config.application_name = DEFAULT_APP_NAME

  # If you want to style your name using html you can do so here, ex: <b>App</b>Name
  # config.application_name_html = ''

  # Enter your application version here. Do not include a trailing backslash. Recommend using a predefined constant
  config.application_version = Notes::VERSION::STRING

  # Enter your application header background image here.
  config.header_background_image = ''

  # Enter your application header title image here.
  # config.header_title_image = 'stylefile.png'

  # Enter the items you wish to see in the menu
  config.menu_items = [
    {
      name: 'Login', display: 'not_signed_in', path: 'new_user_session_path', position: 'right',
      links: [{ name: 'Sign Up', path: 'new_user_registration_path' },
              { divider: true },
              { authentications: true }]
    },
    {
      name: 'image_tag(current_user.avatar_url(18, "blank"), class: "img-rounded")+" "+current_user.name', eval: true, display: 'signed_in', path: 'settings_path', position: 'right',
      links: [{ html: '"<div class=\"small\" style=\"color:#bbb\">"+current_user.email+"</div>"', eval: true },
              { name: 'Settings', path: 'settings_path' },
              { name: 'Authentications', path: 'authentications_path', condition: 'not PROVIDERS.blank?' },
              { divider: true },
              { name: 'Logout', path: 'destroy_user_session_path' }]
    },
    {
      name: 'Calendar', display: 'signed_in', path: 'calendar_stickies_path', position: 'left',
      links: []
    },
    {
      name: 'Stickies', display: 'signed_in', path: 'stickies_path', position: 'left',
      links: [{ name: 'Create', path: 'new_sticky_path' }]
    },
    {
      name: 'Projects', display: 'signed_in', path: 'projects_path', position: 'left',
      links: [{ name: 'Create', path: 'new_project_path' }]
    },
    {
      name: 'Users', display: 'signed_in', name: 'Users', path: 'users_path', position: 'left', condition: 'current_user.system_admin?',
      links: [{ name: 'Overall Graph', path: 'overall_graph_users_path', condition: 'current_user.system_admin?' }]
    },
    {
      name: 'About', display: 'always', path: 'about_path', position: 'left',
      links: []
    }
  ]

  # Enter an address of a valid RSS Feed if you would like to see news on the sign in page.
  config.news_feed = 'https://sleepepi.partners.org/category/informatics/task-tracker/feed/rss'

  # Enter the max number of items you want to see in the news feed.
  config.news_feed_items = 3

  # An array of hashes that specify additional fields to add to the sign up form
  # An example might be [ { attribute: 'first_name', type: 'text_field' }, { attribute: 'last_name', type: 'text_field' } ]
  config.sign_up_fields = [ { attribute: 'first_name', type: 'text_field' }, { attribute: 'last_name', type: 'text_field' } ]
end
