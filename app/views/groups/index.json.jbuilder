json.array!(@groups) do |group|
  json.extract! group, :id, :stickies, :template, :creator_name, :group_link, :description, :project_id, :template_id, :board_id, :initial_due_date, :user_id, :created_at, :updated_at
  json.path group_path( group, format: :json )
  # json.url group_url( group, format: :json )
end
