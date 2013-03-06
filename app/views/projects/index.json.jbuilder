json.array!(@projects) do |project|
  json.partial! 'projects/project', project: project

  json.path project_path( project, format: :json )
  # json.url project_url( project, format: :json )
end
