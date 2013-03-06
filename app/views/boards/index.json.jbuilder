json.array!(@boards) do |board|
  json.extract! board, :name, :description, :archived, :project_id, :user_id, :created_at, :updated_at
  json.path board_path( board, format: :json )
  # json.url board_url( board, format: :json )
end
