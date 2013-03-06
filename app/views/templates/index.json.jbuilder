json.array!(@templates) do |template|
  json.extract! template, :id, :full_name, :name, :project_id, :avoid_weekends, :items, :user_id, :created_at, :updated_at
  json.path template_path( template, format: :json )
  # json.url template_url( template, format: :json )
end
