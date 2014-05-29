## 0.28.6

### Enhancements
- Use of Ruby 2.1.2 is now recommended
- **Gem Changes**
  - Updated to rails 4.1.1
  - Updated to contour 2.5.0
  - Removed turn, and replaced with minitest and minitest-reporters
  - Removed Windows-specific gems

## 0.28.5 (March 5, 2014)

### Enhancements
- Use of Ruby 2.1.1 is now recommended
- Enabled turbolinks
- Removed Screen dependencies and service accounts
- Search box now redirects to tasks list if nothing is found
- Tasks with comments now highlight the number of comments in blue for visibility
- **Gem Changes**
  - Updated to rails 4.0.3
  - Updated to contour 2.4.0.beta3
  - Updated to kaminari 0.15.1

## 0.28.4 (January 7, 2014)

### Enhancements
- Use of Ruby 2.1.0 is now recommended
- **Gem Changes**
  - Updated to pg 0.17.1
  - Updated to jbuilder 2.0
  - Updated to contour 2.2.1

## 0.28.3 (December 5, 2013)

### Enhancements
- Use of Ruby 2.0.0-p353 is now recommended

## 0.28.2 (December 4, 2013)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.0.2
  - Updated to contour 2.2.0.rc2
  - Updated to kaminari 0.15.0
  - Updated to coffee-rails 4.0.1
  - Updated to sass-rails 4.0.1
  - Updated to simplecov 0.8.2

### Bug Fix
- Creating a task or group from the week view now correctly keeps the selected date (reported by @lisamoore)

## 0.28.1 (October 4, 2013)

### Enhancements
- **Task Changes**
  - Reassigning tasks in bulk:
    - Tasks can now be reassigned filtered by a specific tag
    - Unassigned tasks can now be reassigned to a user
    - Assigned tasks can be reassigned to no one being assigned

## 0.28.0 (September 30, 2013)

### Enhancements

- **Calendar Changes**
  - Default view is now the week view
  - Two new views added, week, and day views, and the tasks' list view has been updated and simplified
  - The month, week, day, and list views can now be filtered by Tags, Users, Projects, and Status
- **General Changes**
  - Per user statistics added to show breakdown of task completion by tag and by project
  - Button added to clear a repeat amount for a task
- **Gem Changes**
  - Updated to contour 2.2.0.beta2
  - Updated to pg 0.17.0
- Removed support for Ruby 1.9.3
- Removed support for ICS format
- Removed system admin graphs

### Bug Fix
- Fixed a bug that reset a project's color if a user selected the color box and then closed it without changing the color
- Tasks in a group are now order by due date

## 0.27.2 (September 16, 2013)

### Bug Fix
- Fixed the welcome dialog popup to use Boostrap 3 styling
- Fixed the delete task in group dialog to use Bootstrap 3 styling
- Fixed styling on user edit page

## 0.27.1 (September 9, 2013)

### Enhancements
- **General Changes**
  - The interface now uses [Bootstrap 3](http://getbootstrap.com/)
  - Reorganized Menu
- **Gem Changes**
  - Updated to contour 2.1.0.rc2
  - Updated mail_view to 2.0.1

## 0.27.0 (July 29, 2013)

### Enhancements
- **Project Changes**
  - Project Editors can now add or remove a team member to multiple projects from the user's page
- Simplified the login page
- **Gem Changes**
  - Updated to contour 2.0.0
  - Updated to pg 0.16.0
  - Updated to redcarpet 3.0.0

## 0.26.6 (July 9, 2013)

### Enhancements
- Use of Ruby 2.0.0-p247 is now recommended
- **Gem Changes**
  - Updated to rails 4.0.0
  - Updated redcarpet to 2.3.0

## 0.26.5 (June 7, 2013)

### Enhancements
- Use of Ruby 2.0.0-p195 is now recommended

## 0.26.4 (May 14, 2013)

### Enhancements
- **Gem Changes**
  - Updated to rails 4.0.0.rc1
  - Updated to contour 2.0.0.beta.8
  - Updated to pg 0.15.1

## 0.26.3 (March 20, 2013)

### Enhancements
- **Gem Changes**
  - Updated to Contour 2.0.0.beta.4

## 0.26.2 (March 19, 2013)

### Enhancements
- Use of Ruby 2.0.0-p0 is now recommended

## 0.26.1 (March 13, 2013)

### Bug Fix
- Tasks without a due date are now set to midnight of the current date when they are completed, as opposed to the current time

## 0.26.0 (March 13, 2013)

### Enhancements
- **Gem Changes**
  - Updated to Rails 4.0.0.beta1
  - Updated to Contour 2.0.0.beta.3
- Comment descriptions on the comment show page now render using Markdown to match the way they are displayed on tasks
- Tasks without a due date are now set to the current date when they are completed

### Bug Fix
- Editing and removing the due date of a task from the calendar view now correctly removes the task
- Fixed display of apostrophes and other special HTML characters in shortened task descriptions and emails
- Fixed a bug on the project show page where clicking on a task checkbox would prevent other events from being able to affect the checkbox
- Tasks now stay in place on the calendar when marked as completed instead of jumping to the bottom of the calendar date

### Refactoring
- Removed `old_tags` from schema which aided in upgrading from older versions of Task Tracker up through version 0.25.6

## 0.25.6 (February 25, 2013)

### Bug Fix
- Task hover descriptions using Markdown no longer incorrectly render html tags

## 0.25.5 (February 25, 2013)

### Enhancements
- Added redesigned task hover popups back to the calendar view

## 0.25.4 (February 20, 2013)

### Enhancements
- The `Add Comment` button is now disabled while a comment is being submitted
- Added timepicker when selecting time for task
- Removed calendar popups to reduce dependency on external JavaScripts
- Markdown format can now be used in project and task descriptions along with comments
- Dragging tasks on the calendar to their current due date no longer triggers an AJAX request in the background
- **Gem Changes**
  - Updated to Contour 1.2.1

### Bug Fix
- Fixed `Searchable` concern when searching through joined tables

## 0.25.3 (February 15, 2013)

### Security Fix
- Fixed a bug that could cause a service account user to log in an incorrect user when passing the user's token as `nil` via the JSON message

## 0.25.2 (February 14, 2013)

### Security Fix
- Updated Rails to 3.2.12

### Enhancements
- ActionMailer can now also be configured to send email through NTLM
  - `ActionMailer::Base.smtp_settings` now requires an `:email` field

## 0.25.1 (February 6, 2013)

### Enhancements
- Comment Emails now include the full time the comment was made to provide better information when looking at older comment emails
- Acceptable Use Policy added

### Bug Fix
- Default colors for project are now correctly based on the order in which the project was created

## 0.25.0 (February 5, 2013)

### Breaking Change
- Database default updated to use PostgreSQL
  - Instructions [MIGRATING_TO_POSTGRESQL](https://github.com/remomueller/documentation/blob/master/MIGRATING_TO_POSTGRESQL.md)

### Enhancements
- **Project Changes**
  - Project description added to the bottom of the redesigned project page
  - Clarified template clear filter button to say 'clear' instead of '-'
  - Links added to project page to edit existing templates and groups
- **Task Changes**
  - Styling updated for selecting tags when creating/updating tasks
  - Creating tasks from the calendar no longer displays the task show popup
  - HTML task description markup no longer shows up on the calendar
  - Clicking on links in comments now opens up a new window or tab
  - Task and group creation buttons are now disabled after they are clicked to prevent two identical tasks from being created
- **Email Changes**
  - Task comment emails are now sent to everyone on the project unless they have selected not to receive task comment emails for that project
  - Comment emails now contain previous comments and the description of the task
  - HTML markup in task descriptions and comments no longer shows up in the Daily Digest
  - Daily Digests no longer repeat Recently Completed tasks in the Recently Added tasks section
  - Users are now more consistently notified when they are added to a project
- **New Search Feature**
  - Quick project and group search added in the top navigation bar
  - Shortcut key 'p' will set focus on the search box
  - Entering a project name will jump to that project
  - With multiple results, the user will be directed to a search results page

### Bug Fix
- Board counts are now updated when marking/unmarking tasks as completed

## 0.24.5 (January 22, 2013)

### Enhancements
- Task duration and duration_units are now included in the CSV export

### Bug Fix
- Setting an invalid repeat_amount and then changing the task to repeat "none" no longer causes a validation error on the repeat_amount

## 0.24.4 (January 11, 2013)

### Enhancements
- Gravatars are now displayed on the user index

### Refactoring
- Added Searchable and Deletable ActiveSupport::Concerns to appropriate models

### Testing
- Added mail_view gem for easier email templating

## 0.24.3 (January 8, 2013)

### Security Fix
- Updated Rails to 3.2.11

## 0.24.2 (January 3, 2013)

### Enhancements
- Updated to Contour 1.1.2
- Removed deprecated Group Creation JSON API, Groups can now be created by specifying:
  - `group[project_id]`
  - `group[template_id]`
  - `group[initial_due_date] (optional, defaults to today)`
  - `group[description] (optional)`
  - `group[board_id] (optional)`
- Task addition/completion emails simplified

### Bug Fix
- Task popups now display the `repeat_amount` (1,2,3) along with the `repeat_unit` (day,week,month,year) for repeating tasks

## 0.24.1 (January 3, 2013)

### Security Fix
- Updated Rails to 3.2.10

## 0.24.0 (January 2, 2013)

### Enhancements
- **Project Changes**
  - Major rework of the project show page to better reflect boards and tags
    - This rework is aimed at improving the flexibility of the project page in order to discourage users from using tasks index
    - Contains three views
      - Completed: Completed sorted by due date due date descending, (today into the past)
      - Past due: Not completed sorted by due date due date descending, (today into the past)
      - Upcoming: Not completed sorted by due date ascending, (today into the future)
      - Direction of these views can be reversed, useful to see tasks with no due date assigned
    - Tasks can be dragged onto different boards
    - Tasks can be tagged by dragging tasks onto tags
- **Calendar Changes**
  - Task editing and viewing from the calendar has changed to use an redesigned popup similar to the one used on the new project page
- **Task Changes**
  - Multiple tasks completed at once will now send out a single email per user
  - Tasks can now be repeated daily, weekly, monthly, or yearly
    - Upon completing a task that has either day, week, month, or year set, a new copy of that task is created 1 [day, week, month, year] later
    - The number can also be set, so a task could be done every 2 days
- **Group Changes**
  - New Boards can now be created when creating a group
- Updated to Contour 1.1.2.pre

### Bug Fix
- Fixed a bug that prevented grouped tasks assigned to a board from being moved back to the holding pen
- Fixed a bug that sent task completion emails out by who it was assigned to as opposed to who marked the task as completed

## 0.23.10 (December 12, 2012)

### Bug Fix
- Creating a group from the calendar with a preselected project now correctly popuplates that project's boards and templates

## 0.23.9 (December 4, 2012)

### Enhancements
- Project show page will now default to displaying the first alphabetically unarchived board by default
- New boards can now be created when tasks are created
- HTML Markup no longer shows up in a tasks short description
- HTML Links in task descriptions now automatically have target="_blank" added as an attribute
- Gravatar image's are now used for task comments

### Bug Fix
- User activation emails are no longer sent out when a user's status is changed from pending to inactive
- Task tooltips no longer show up over a new task popup

## 0.23.8 (November 29, 2012)

### Bug Fix
- Users with no projects favorited should still be able to create tasks

## 0.23.7 (November 29, 2012)

### Enhancements
- Frames have been renamed to Boards
  - Boards no longer include start and end dates
  - Boards can be archived
  - Project pages now only show tasks of active boards
- Task completion emails on groups now highlight the task that was completed on the group

### Bug Fix
- Pagination now works correctly on group pages where groups have more than 50 tasks

## 0.23.6 (November 28, 2012)

### Enhancements
- Gem updates including Rails 3.2.9 and Ruby 1.9.3-p327
- Updated to Contour 1.1.1 and replaced inline JavaScript with Unobtrusive JavaScript

## 0.23.5 (October 1, 2012)

### Enhancements
- Project JSON API returns whether or not the project has been favorited
- Project JSON API returns project specific tags

### Bug Fix
- Task links no longer overlap the complete task checkmark box on the calendar view
- When deleting boards, tags, and templates, the user is now redirected to the project specific boards, tags, or templates index
- Boards now correctly retain the dropdown arrow when switching by selecting a new board from the dropdown
- Editing template input fields and dropdowns no longer causes the input field to become unselected in IE

## 0.23.4 (September 12, 2012)

### Enhancements
- Project JSON API returns color
- User JSON API returns user authentication_token, first_name, last_name, email, and id on successful login
- Increased width of description text areas to be consistent with other text areas

## 0.23.3 (August 13, 2012)

### Bug Fix
- Dragging groups now correctly prompts user to select all, completed, or single task
  - Due to a change in Rails 3.2.7 to Rails 3.2.8 how data attributes are specified in divs

## 0.23.2 (August 13, 2012)

### Enhancements
- Updated to Rails 3.2.8

## 0.23.1 (July 31, 2012)

### Enhancements
- Task JSON API filters
  - owner_id: me, returns tasks assigned to the current user
  - unassigned: 1, returns tasks that are not assigned to a specific user
  - due_date_start_date and due_date_end_date can be specified as mm/dd/yy or mm/dd/yyyy
- Task JSON API returns group_description
- Updated to Rails 3.2.7
  - Removed deprecated use of update_attribute for Rails 4.0 compatibility
- Daily Digest emails now include tasks created/completed, and comments created over the weekend in the monday digest
- Project invites now display the invite url, and display who invited the user by mousing over the email

### Bug Fix
- Height of the drop down menu for task exports is now consistent with other drop down menus
- Tags filters on tasks page no longer use colors for deleted tags

### Testing
- Use ActionDispatch for Integration tests instead of ActionController

## 0.23.0 (July 16, 2012)

### Enhancements
- Daily digest emails are now available for users who prefer a digest of the previous day included tasks added, completed, and comments made
- Tasks can now be reassigned to another user in bulk from the project page
- Users can now be added by email to projects without requiring the user to be signed up
- **Calendar Changes**
  - Calendar filters have been simplified and given a consistent look
  - Task popups are now cleaner and no longer display the words, 'description', 'project', or 'tags' as these can be deduced by context
  - Dragging grouped tasks on the calendar now prompts whether to move the invidual task, all incomplete tasks in the group, or all the tasks in the group

## 0.22.6 (July 2, 2012)

### Enhancements
- Mass-assignment attr_accessible and params slicing implemented to leverage Rails 3.2.6 configuration defaults
- The About page now references the Task Tracker forum and contact information
- **Task Changes**
  - Creating a group of tasks from the project page now refreshes and shows the newly created tasks
  - Cleaned up lists of tasks by changing how they expand when clicking on them
- **Template Changes**
  - Boards and Templates now require unique names per project
  - Templates can now be copied
    - Note: Tags and owners aren't copied to new templates
  - Compact editing of templates added
    - Template items can be reordered by dragging tasks
  - Generating a new group from a template now requires the project to be specified to limit the number of templates that are displayed
- **Email Changes**
  - Default application name is now added to the from: field for emails
  - Email subjects no longer include the application name
- New Registration Changes
  - Users without projects will now be prompted when they view the calendar to create a project
  - Default new user settings updated to also show completed tasks

### Refactoring
- Comments no longer use class_name or class_id and now require to be part of a sticky_id
- Removed unused project position
- Tasks no longer have a status, or due_at columns
  - Note: due_date includes the due_at time along with timezone information
- Consistent sorting and display of model counts used across all objects, (projects, tasks, tags, templates, users, etc)

### Bug Fix
- Creating a tag with the same name as a deleted tag no longer throws the error 'tag name has already been taken' (reported by @lisamoore)
- Clicking on 'Days Left' no longer triggers an AJAX pagination request

## 0.22.5 (June 21, 2012)

### Enhancements
- Creating a task from the project page will
  - default the new task to the currently selected board
  - refresh the list of tasks when the task is created
- Switching boards in the task popup will now reflect on the underlying project page
- Update to Rails 3.2.6 and Contour 1.0.2
- Links with confirm: now use data: { confirm: } to account for deprecations in Rails 4.0
- Boards are now ordered by end date descending by default on boards index

### Bug Fix
- Links from email to tasks past due, due today, or upcoming now properly reset other filters

## 0.22.4 (June 6, 2012)

### Enhancements
- Update to Rails 3.2.5 and Contour 1.0.1
- Updated Devise configuration files for devise 2.1.0

### Bug Fix
- Timeouts no longer cause an error when trying to login again
- Creating a group without specifying a template now correctly highlights an error on the required template name field

## 0.22.3 (May 8, 2012)

### Enhancements
- Fixed the way popups appear on smaller devices

## 0.22.2 (May 4, 2012)

### Enhancements
- Use Contour for User account Confirmations and Unlocks

## 0.22.1 (May 4, 2012)

### Enhancements
- Editing tasks from the task list or project page now redirects back to the task list or project page, respectively, after the task is updated
- Template creation page cleaned up
- Table Headers now use the same styling
- Tags updated so the bottom is not cut off
- Tags in emails now have the text displayed in white to match the way they are displayed in the web application

### Bug Fix
- Fix Registration page to use new Contour login attributes

## 0.22.0 (April 27, 2012)

### Enhancements
- Using Contour 1.0.0.beta with Twitter-Bootstrap CSS and JS
- Task filters can now be reset
- Groups can now be created from the project page
- Default calendar options added when user registers

## 0.21.0 (April 13, 2012)

### Enhancements
- Tasks can now be completed with one click on the calendar
- Task filters are now saved and navigating to and from the task list will retain selected filters
- API expanded and now allows tasks index to be retrieved as JSON objects
  - Task JSON API actions for create, update, show, and index now available
- Using Rails 3.2.3

### Refactoring
- Comments model simplified and deprecated ability to comment on projects or other comments

### Bug Fix
- Fixed graphical bug that caused table rows borders to disappear in Google Chrome
- Fixed bug where task description would shift after completing an inline task and moving the mouse
- Fixed bug in display of overall graph for users with identical names
- Fixed bug where selecting too many tags for task filters would generate a slow search

## 0.20.0 (March 30, 2012)

### Enhancements
- Tasks can now be marked as complete directly in the list view
- Service Accounts can now be used by other applications to authenticate users through the use of application specific tokens
  - Allows authenticated applications to view templates and create new groups
- Using Rails 3.2.3.rc2

## 0.19.0 (March 19, 2012)

### Enhancements
- Service Accounts added to provide interface for other web applications
- Export Dictionary rake task added for automated integration with the Hybrid Sleep Portal

### Bug Fix
- Due Times corrected to account for Daylight Savings Time

## 0.18.0 (March 7, 2012)

### Enhancements
- Templates can now specify that generated tasks avoid weekends
- **Calendar Changes**
  - Tasks can now be dragged to a new date
  - Improved performance using a combination of caching and AJAX
- **Email Changes**
  - Daily Tasks Due now also includes tasks due the following day (or the following Monday)
  - Daily Tasks Due now includes an ICS file to allow syncing with an external calendar
- **Task Changes**
  - Tasks can be exported to an ICS calendar format from the tasks list
  - Updated GUI for task show page and comments
  - Tasks in lists can now be deleted inline
- Using Rails 3.2.2 and Contour 0.10.2

### Bug Fix
- Viewers can now remove themselves from projects to which they've been added
- Users assigned to tasks that have been removed from a project are no longer removed as task owner if the task is updated
  - NOTE: Unless of course, the task is assigned to someone else

## 0.17.2 (February 13, 2012)

### Enhancements
- Using Contour-Minimalist for styling

## 0.17.1 (February 10, 2012)

### Enhancements
- ICS files are also included in emails for tasks with a due date but no due time

### Bug Fix
- Due Date Changed email no longer triggers when a task with a due time is created

## 0.17.0 (February 10, 2012)

### Enhancements
- Task filters now combine duplicate tags
- Minor graphical tag changes on calendar
- Tasks and templates can now have a due time and duration
- Task emails are now sent if the task due time is changed
- Task and group creation emails now include an ICS event file if a due date time is set
- Calendar now sorts tasks by project, then by tags, then by due date time
- Task tags have minor GUI update in emails

### Bug Fix
- Email setting checkboxes for project notifications are no longer incorrectly disabled

## 0.16.2 (February 2, 2012)

### Bug Fix
- Removed "assigned to me" option for task list page as it was redundant
- "Assigned to Me" now correctly saves user settings on calendar

## 0.16.1 (February 1, 2012)

### Bug Fix
- Tasks on calendar view are now correctly grouped by tags

## 0.16.0 (February 1, 2012)

### Enhancements
- **Calendar Changes**
  - Saves checked 'completed' or 'not completed' filters on calendar
  - Displays tasks in the following or preceding month
  - Can filter tasks assigned to the user
- Project selection dropdowns are now sorted by favorites first
- Tasks search now allows users to filter unassigned tasks
- Email settings page now prompts user if the user navigates away without saving updated settings
- **Tagging Changes**
  - Task list page can now filter tasks which contain at least one, or all selected tags
  - Tags can now be given an additional color and description
  - Task list page tag filters now only shows tags for the selected project

### Bug Fix
- Generating a template from the calendar view now correctly updates the selected templates available project boards
- Daily Tasks Due email no longer includes tasks from projects that have email delivery off

### Refactoring
- Updated to Rails 3.2.1 and fixed Devise 2.0.0 locales file

## 0.15.3 (January 23, 2012)

### Refactoring
- Removed initializer fix for Rack that is now handled by Contour

## 0.15.2 (January 23, 2012)

### Refactoring
- Gem dependencies updated:
  - Rails 3.2.0
  - Contour ~> 0.9.3
- Devise migration and configuration file updated
- RSS feed has moved to Task Tracker
- Environment files updated to be in sync with Rails 3.2.0

## 0.15.1 (January 12, 2012)

### Bug Fix
- Fixed default colors specified in RGB format from loading properly in the color picker

## 0.15.0 (January 11, 2012)

### Enhancements
- Groups of tasks can now have their due dates shifted by editing a single task in the group and selecting either 'incomplete' to shift all other not completed tasks, or 'all' to shift all the tasks in the group
- **Calendar Changes**
  - Tasks are now displayed under their tags
  - Tasks can now be displayed or hidden per project
  - Project colors can now be personalized
- Task list page has the following improvements:
  - Tasks can now be filtered and downloaded in a CSV file
  - Cleaner layout of search filters
- Items on template index are now aligned across various templates
- Emails for group creation and task completion now display:
  - Group Template name
  - Tasks now have first 16 characters of description

### Bug Fix
- Minor table GUI fix when expanding a task
- Templates page is now sortable by name
- Searching and filtering is now possible in the groups list view
- Tags can now be cleared when updating a task

### Refactoring
- Removed unused task attributes task type, task position, and task parent
- Link to template removed from the groups list page to avoid confusion

### Testing
- Added tests for sending email for task creation and task completion
- Added tests for sending email for project comments and task comments

## 0.14.1 (January 6, 2012)

### Bug Fix
- Use update_column instead of update_attribute to avoid emails being sent out during a migration

## 0.14.0 (January 6, 2012)

### Enhancements
- Tasks no longer have status of 'planned', 'ongoing', 'completed', and now are either completed or not completed
  - NOTE: Tasks can have tags added to them on a per project basis if more fine-grained labeling is required
- Task edit page now contains:
  - Group description if the task is part of a group
  - Comments that may have been added to task
- Tasks on the task list page:
  - Can now be filtered by:
    - Project
    - Assigned To
    - Due Date
    - Status
  - Display the total count of filtered tasks
  - Contain a link to the group if grouped with other tasks
- Template show page has been improved
  - Items listed in a template are now sorted by their offset from the initial due date
  - Items are now displayed more succinctly
- Using Rails 3.2.0.rc2 and Contour 0.8.1
- Calendar updated have consistent look across browsers and operating systems
- Templates can now have default task tags assigned to each item
- Projects emails can now be fine-tuned to receive only certain types of updates on a per-project basis

### Refactoring
- qTip2 is now provided by Contour 0.8.1

## 0.13.0 (December 20, 2011)

### Enhancements
- **Calendar Changes**
  - Double clicking on calendar allows creation of a task or a task group
  - Today's Date and Mouse Hover colors have been lightened
- **Task Groups**
  - Deleting a grouped task now prompts the user to delete:
    - a single task
    - all following
    - or all tasks in the group
  - Grouped tasks can now be moved to a different project by editing the group
- Navigation
  - Creating, Updating, and Deleting tasks from the calendar has been improved
  - Viewing a project now adds a menu item to that project's templates and boards
- **Task Tags**
  - Project specific tags can be assigned to tasks
- Email layout has improved
  - Daily Tasks Due are now grouped by project
  - Task Completion emails now list additional tasks in the group
  - Due Date, Tags, and Group information added across task emails
- Templates can now have negative due date offsets

### Bug Fix
- Daily tasks due email fixed to include weekday for items past due
- Creating a task that's already marked as completed now only sends out a "task completion" email
- Validation errors when creating or updating tasks now correctly remember the project, board, and tag selections

## 0.12.1 (December 19, 2011)

### Bug Fix
- Project Viewers are now correctly redirected to the task show page from the calendar view

## 0.12.0 (December 13, 2011)

### Enhancements
- Emails for Tasks generated by Templates are now sent out in a single email as opposed to an email per task
- Task Due Dates are now included in emails
- Tasks that are generated together from a template are now grouped together
- Groups of tasks can be deleted, and can have a general group description
- Using Contour 0.7.0 with Menu enhancements and broader browser compatibility, specifically IE7+

### Bug Fix
- New tasks that are created and already marked as completed now correctly set a Task ID in the email

## 0.11.1 (December 9, 2011)

### Bug Fix
- Rake task now correctly sends out reminder emails (except weekend)

## 0.11.0 (December 9, 2011)

### Enhancements
- Adding support for templates
  - Templates define a series of tasks
  - Once created a template can Generate Tasks for the project with:
    - Due Date (+1.day, +2.weeks, +5.months)
    - Assigned user
    - Additional information attached to each task
- Calendar View is now available for Tasks with a Due Date
  - New Tasks with Due Date can be created directly from Due Date calendar by hovering over the date and clicking the new task icon
- Emails are sent out to inform users if a task assigned to them is due that day or is past due
- Menu Streamlined, Emphasis on Calendar, Projects, and Templates

### Bug Fix
- Graphs now render correctly in IE7 and IE8

### Testing
- Test Coverage at 100%

## 0.10.0 (December 2, 2011)

### Enhancements
- Tasks can now have Due Dates
- Task start date and task end date are now automatically set
  - Start Date set when the task is created
  - End Date set when the task status is changed from planned or ongoing to completed
  - End Date is cleared when status is changed from completed to planned or ongoing
- Tasks can now be sorted by id, status, and due date
- Projects Index has been simplified and now displays:
  - Number of tasks that are past due, due today, and due this week
  - Owner, editors, and viewers on project
- Using Rails 3.1.3 and Contour ~> 0.6.0

## 0.9.0 (November 8, 2011)

### Enhancements
- Using Rails 3.1.1, Ruby 1.9.3.p0, and Contour 0.5.6
- Email Updates:
  - Consistent subjects lines
  - Task Added email now displays who is assigned to the task
- Right and Left Keyboard clicks now navigate between boards on the project show page

### Bug Fix
- Deleting a board now moves the associated tasks to the project holding pen

### Testing
- Analyzing test coverage using SimpleCov gem, test coverage now at 92%

## 0.8.0 (September 21, 2011)

### Enhancements
- Emails are now sent for tasks when they are completed, can be disabled in user settings
- Owners who can edit a project or a task can now
  - delete comments attached to the project or task
  - move comments to another between project or task

## 0.7.3 (September 9, 2011)

### Refactoring
- Updating to Contour version 0.5.0

## 0.7.2 (September 7, 2011)

### Refactoring
- Updating to Contour version 0.4.0

## 0.7.1 (September 6, 2011)

### Refactoring
- Updating static image links for Contour version 0.3.2

## 0.7.0 (September 5, 2011)

### Enhancements
- Overall Graph is now available for system administrators
- The currently active board is now set initially on the project page
- Application layout, registration, and authentication now provided by Contour gem

### Refactoring
- Changed object_id to class_id and object_model to class_name to avoid conflicts with Rails
- JavaScript rewritten using CoffeeScript

### Bug Fixes
- Graphs now properly render when displaying project names that contain apostrophes
- JavaScript for the arrows next to the board selection fixed, boards now change correctly

## 0.6.1 (August 18, 2011)

### Enhancements
- Menu bar now sticks to the top of the window when the user scrolls down the page

## 0.6.0 (August 15, 2011)

### Enhancements
- Update Rails to 3.1
- Update Devise to 1.3.4 and Omniauth 0.2.6
- Modified the authentication system so that it can authenticate correctly when behind a reverse proxy and within a firewall
- Updated layout for consistency across projects

### Testing
- Updated base test coverage for all unit and functional tests

## 0.5.0 (May 2, 2011)

## 0.4.0 (April 22, 2011)

## 0.3.0 (April 8, 2011)

## 0.2.0 (March 25, 2011)

## 0.1.0 (March 16, 2011)

