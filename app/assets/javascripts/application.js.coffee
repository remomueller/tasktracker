
jQuery ->
  
  $('#menu').waypoint( (event, direction) ->
    $(this).toggleClass('sticky', direction == "down")
    $(this).css( left: $("#header").position().left )
    event.stopPropagation()
  )