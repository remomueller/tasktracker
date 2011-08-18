
jQuery ->
  
  $('#menu').waypoint( (event, direction) ->
    $(this).toggleClass('sticky', direction == "down")
    $(this).css( left: $("#header").offset().left )
    event.stopPropagation()
  )