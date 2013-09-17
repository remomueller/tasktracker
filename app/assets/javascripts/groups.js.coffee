# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@loadNewGroupModal = () ->
  $('#new-group-button').click()
  false

jQuery ->
  $(document)
    .on('click', '[data-object~="group-select"]', (e) ->
      return true if nonStandardClick(e)

      $('[data-object~="group-select"]').removeClass('active')
      $(this).addClass('active')

      url = $(this).attr("href")
      $.get(url, null, null, "script")

      false
    )
    .on('change', '#group_project_id', () ->
      $.post(root_url + 'groups/project_selection', $("#group_project_id").serialize(), null, "script")
      false
    )
    .on('click', '[data-object~="load-new-group"]', (e) ->
      $.get(root_url + 'groups/new', "group[project_id]=#{$('#sticky_project_id').val()}&group[initial_due_date]=#{$('#sticky_due_date').val()}&group[board_id]=#{$('#sticky_board_id').val()}&"+$('#from_calendar').serialize(), null, "script")
      false
    )
