json.array!(@stickies) do |sticky|
  json.extract! sticky, :all_day, :completed, :created_at, :description, :due_date, :duration, :duration_units, :board_id, :group_id, :id, :owner_id, :project_id, :updated_at, :user_id, :group_description, :sticky_link, :tags, :repeat, :repeat_amount

  json.path sticky_path( sticky, format: :json )
  # json.url sticky_url( sticky, format: :json )
end
