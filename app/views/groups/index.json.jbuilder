json.array!(@groups) do |group|
  json.partial! 'groups/group', group: group
  json.path group_path( group, format: :json )
  # json.url group_url( group, format: :json )
end
