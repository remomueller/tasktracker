# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@loadNewGroupModal = () ->
  if $('#welcome-dialog').length > 0
    $('#welcome-dialog').modal('toggle')
  else
    $('#new-group-button').click()
  false

jQuery ->
  $(document)
    .on('click', '[data-object~="group-select"]', (e) ->
      return true if nonStandardClick(e)

      $('[data-object~="group-select"]').parent().removeClass('active')
      $(this).parent().addClass('active')

      url = $(this).attr("href")
      $.get(url, null, null, "script")

      false
    )
    .on('change', '#group_project_id', () ->
      $.post(root_url + 'groups/project_selection', $("#group_project_id").serialize() + "&" + $("#group_board_id").serialize() + "&" + $("#group_template_id").serialize(), null, "script")
      false
    )
