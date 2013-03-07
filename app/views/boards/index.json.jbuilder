json.array!(@boards) do |board|
  json.partial! 'boards/board', board: board

  json.path board_path( board, format: :json )
  # json.url board_url( board, format: :json )
end
