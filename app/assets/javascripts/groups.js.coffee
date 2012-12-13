# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $("#group_project_id").change( () ->
    $.post(root_url + 'groups/project_selection', $("#group_project_id").serialize() + "&" + $("#group_board_id").serialize() + "&" + $("#group_template_id").serialize(), null, "script")
    false
  )

  $(document)
    .on('click', '[data-object~="group-select"]', (e) ->
      return true if nonStandardClick(e)

      $('[data-object~="group-select"]').parent().removeClass('active')
      $(this).parent().addClass('active')

      url = $(this).attr("href")
      $.get(url, null, null, "script")



      # if $('#group_id').val().toString() == $(this).data('group-id').toString()
      #   selectGroup($(this).data('group-id'))
      #   $("#groups_search").submit()
      # else
      #   selectGroup($(this).data('group-id'))

      #   $.get($("#groups_search").attr("action"), $("#groups_search").serialize(), ((data) ->
      #     if browserSupportsPushState
      #       history.pushState({ page:url, tasktracker: true, group_id: $('#group_id').val() }, null, url)
      #   ), "script")
      false
  )
