json.array!(@projects) do |project|
  json.extract! project, :id, :name, :description, :status, :start_date, :end_date, :user_id, :created_at, :updated_at, :project_link, :tags

  json.color project.color(current_user)

  project_favorite = project.project_favorites.find_by_user_id(current_user.id)
  json.favorited (not project_favorite.blank? and project_favorite.favorite?)

  json.path project_path( project, format: :json )
  # json.url project_url( project, format: :json )
end
