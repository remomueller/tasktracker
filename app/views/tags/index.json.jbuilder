json.array!(@tags) do |tag|
  json.partial! 'tag/tag', tag: tag
  json.path tag_path( tag, format: :json )
  # json.url tag_url( tag, format: :json )
end
