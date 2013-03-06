json.array!(@stickies) do |sticky|
  json.partial! 'stickies/sticky', sticky: sticky

  json.path sticky_path( sticky, format: :json )
  # json.url sticky_url( sticky, format: :json )
end
