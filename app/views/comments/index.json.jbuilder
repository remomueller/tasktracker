json.array!(@comments) do |comment|
  json.extract! comment, :description, :user_id, :sticky_id, :created_at, :updated_at
  json.path comment_path( comment, format: :json )
  # json.url comment_url( comment, format: :json )
end
