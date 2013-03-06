json.extract! @group, :id, :template, :creator_name, :group_link, :description, :project_id, :template_id, :board_id, :initial_due_date, :user_id, :created_at, :updated_at
json.stickies @group.stickies do |json, sticky|
  json.partial! 'stickies/sticky', sticky: sticky
end
