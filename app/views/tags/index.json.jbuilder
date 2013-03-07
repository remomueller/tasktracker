json.array!(@tags) do |tag|
  json.partial! 'tags/tag', tag: tag
  json.path tag_path( tag, format: :json )
  # json.url tag_url( tag, format: :json )
end
