json.extract! sticky, :all_day, :completed, :created_at, :description, :due_date, :duration, :duration_units, :board_id, :group_id, :id, :owner_id, :project_id, :updated_at, :user_id, :group_description, :sticky_link

json.tags sticky.tags do |tag|
  json.partial! 'tags/tag', tag: tag
end

json.extract! sticky, :repeat, :repeat_amount
