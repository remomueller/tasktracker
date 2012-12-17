# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    # From old project page
    .on('click', '[data-object~="modal-show"]', () ->
    #   $('#sticky_project_id').val($(this).data('project-id'))
    #   $('#group_project_id').val($(this).data('project-id'))
    #   $('#sticky_board_id').val($("#board_id").val())
    #   $('#group_board_id').val($("#board_id").val())
    #   $('#sticky_project_id').change()
    #   $('#group_project_id').change()
      $($(this).data('target')).modal({ dynamic: true })
      false
    )
    # .on('click', '[data-object~="boards-select"]', () ->
    #   $('#board_name').html($(this).data('board-name'))
    #   $('#board_id').val($(this).data('board-id'))
    #   $($(this).data('target')).submit()
    #   false
    # )
    # .on('change', '#sticky_board_id, #group_board_id', () ->
    #   $('[data-board-id~="' + ($(this).val() || '0') + '"]').click()
    #   false
    # )
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
