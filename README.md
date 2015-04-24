# Task Tracker

[![Build Status](https://travis-ci.org/remomueller/tasktracker.svg?branch=master)](https://travis-ci.org/remomueller/tasktracker)
[![Dependency Status](https://gemnasium.com/remomueller/tasktracker.svg)](https://gemnasium.com/remomueller/tasktracker)
[![Code Climate](https://codeclimate.com/github/remomueller/tasktracker/badges/gpa.svg)](https://codeclimate.com/github/remomueller/tasktracker)

Manage multiple projects, view tasks in a calendar, receive reminder emails for tasks due, assign project members to
tasks, create templates for series of tasks, receive emails and updates as tasks and groups of tasks are completed,
assign project specific tags to tasks, generate reports on task tags. Using Rails 4.2+ and Ruby 2.2+.

## Installation

[Prerequisites Install Guide](https://github.com/remomueller/documentation): Instructions for installing prerequisites like Ruby, Git, JavaScript compiler, etc.

Once you have the prerequisites in place, you can proceed to install bundler which will handle most of the remaining dependencies.

```
gem install bundler
```

This readme assumes the following installation directory: `/var/www/tasktracker`

```
cd /var/www

git clone https://github.com/remomueller/tasktracker.git

cd tasktracker

bundle install
```

Install default configuration files for database connection, email server connection, server url, and application name.

```
ruby lib/initial_setup.rb

bundle exec rake db:migrate RAILS_ENV=production

bundle exec rake assets:precompile RAILS_ENV=production
```

Run Rails Server (or use Apache or nginx)

```
rails s -p80
```

Open a browser and go to: [http://localhost](http://localhost)

All done!

## Setting up Daily Tasks Due Emails

Edit Cron Jobs `sudo crontab -e` to run the task `lib/tasks/reminder_email.rake`

```
SHELL=/bin/bash
0 1 * * * source /etc/profile.d/rvm.sh && cd /var/www/tasktracker && /usr/local/rvm/gems/ruby-2.2.2/bin/bundle exec rake reminder_email RAILS_ENV=production
```

## Exporting the Task Tracker Data Dictionary for use by the [Sleep Portal](https://github.com/sleepepi/sleepportal) for dynamic reporting and searches

Edit Cron Jobs `sudo crontab -e` to export the data dictionary

```
SHELL=/bin/bash
30 1 * * * source /etc/profile.d/rvm.sh && cd /var/www/tasktracker && /usr/local/rvm/gems/ruby-2.2.2/bin/bundle exec rake export_dictionary RAILS_ENV=production
```

## Task Tracker API (RESTFUL JSON)

If you need to communicate with an instance of Task Tracker programmatically, take a look at the [API Documentation](https://github.com/remomueller/tasktracker/blob/master/API.md) for examples.

## Contributing to Task Tracker

- Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright [![Creative Commons 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png)](http://creativecommons.org/licenses/by-nc-sa/3.0)

Copyright (c) 2014 Remo Mueller. See [LICENSE](https://github.com/remomueller/tasktracker/blob/master/LICENSE) for further details.

