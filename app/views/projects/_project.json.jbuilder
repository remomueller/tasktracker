json.extract! project, :id, :name, :description, :status, :start_date, :end_date, :user_id, :created_at, :updated_at, :project_link

json.tags project.tags do |json, tag|
  json.partial! 'tags/tag', tag: tag
end

json.color project.color(current_user)

json.favorited project.favorited_by?(current_user)
