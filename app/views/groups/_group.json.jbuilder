json.extract! group, :id, :creator_name, :group_link, :description, :project_id, :template_id, :board_id, :initial_due_date, :user_id, :created_at, :updated_at
json.template do |json|
  json.partial! 'templates/template', template: group.template
end
json.stickies group.stickies do |json, sticky|
  json.partial! 'stickies/sticky', sticky: sticky
end
