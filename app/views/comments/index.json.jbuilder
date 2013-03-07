json.array!(@comments) do |comment|
  json.partial! 'comments/comment', comment: comment
  json.path comment_path( comment, format: :json )
  # json.url comment_url( comment, format: :json )
end
