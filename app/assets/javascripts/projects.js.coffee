# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document)
  .on('click', '[data-object~="set-scope"]', () ->
    $("#scope").val($(this).data('value'))
    $("#stickies_search").submit()
    setBoardNames()
    false
  )
  .on('click', '[data-object~="toggle-scope-direction"]', () ->
    if $("#scope_direction").val() == 'reverse'
      $("#scope_direction").val('forward')
      $("#scope-direction-icon").html("")
    else
      $("#scope_direction").val('reverse')
      $("#scope-direction-icon").html("&larr;")
    $("#stickies_search").submit()
    false
  )
