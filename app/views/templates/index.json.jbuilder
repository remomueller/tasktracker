json.array!(@templates) do |template|
  json.partial! 'templates/template', template: template
  json.path template_path( template, format: :json )
  # json.url template_url( template, format: :json )
end
