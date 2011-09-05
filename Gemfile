source 'http://rubygems.org'

gem 'rails', '3.1.0.rc6'
gem 'sprockets', '2.0.0.beta.13'

# Database Adapter
gem 'mysql2', '0.3.7',          :platforms => [:ruby]
gem 'sqlite3',                  :platforms => [:mswin, :mingw]
gem 'mongrel', '>= 1.2.0.pre2', :platforms => [:mswin, :mingw]

# Gems used by project
gem 'devise', '~> 1.3.4'           # User Authorization
gem 'kaminari'                     # Pagination
gem 'mail'                         # Emails
gem 'omniauth', '0.2.6'            # User Multi-Authentication

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0.rc"    # Compiles CSS
  gem 'coffee-rails', "~> 3.1.0.rc"    # Compiles JavaScript
  gem 'uglifier'                       # Minimizes and obscures JS and CSS
end

gem 'jquery-rails'                     # JavaScript Engine

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console', :platforms => [:mswin, :mingw]
  gem 'turn'
end