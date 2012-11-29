# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#group_project_id").change( () ->
    $.post(root_url + 'groups/project_selection', $("#group_project_id").serialize() + "&" + $("#group_board_id").serialize() + "&" + $("#group_template_id").serialize(), null, "script")
    false
  )
