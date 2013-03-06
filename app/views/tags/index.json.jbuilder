json.array!(@tags) do |tag|
  json.extract! tag, :name, :description, :color, :project_id, :user_id, :created_at, :updated_at
  json.path tag_path( tag, format: :json )
  # json.url tag_url( tag, format: :json )
end
