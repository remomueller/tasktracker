source 'http://rubygems.org'

gem 'rails', '3.1.0'

# Database Adapter
gem 'mysql2', '0.3.7',          :platforms => [:ruby]
gem 'sqlite3',                  :platforms => [:mswin, :mingw]
gem 'mongrel', '>= 1.2.0.pre2', :platforms => [:mswin, :mingw]

# Gems used by project
gem 'contour', '~> 0.5.0'          # Basic Layout and Assets
gem 'devise',  '~> 1.4.4'          # User Authorization
gem 'omniauth',   '0.2.6'          # User Multi-Authentication
gem 'kaminari'                     # Pagination
gem 'mail'                         # Emails

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"    # Compiles CSS
  gem 'coffee-rails', "~> 3.1.0"    # Compiles JavaScript
  gem 'uglifier'                       # Minimizes and obscures JS and CSS
end

gem 'jquery-rails'                     # JavaScript Engine

# Testing
group :test do
  # Pretty printed test output
  gem 'win32console', :platforms => [:mswin, :mingw]
  gem 'turn'
end