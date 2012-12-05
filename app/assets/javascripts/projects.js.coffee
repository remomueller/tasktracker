# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    .on('click', '[data-object~="modal-show"]', () ->
      $('#sticky_project_id').val($(this).data('project-id'))
      $('#group_project_id').val($(this).data('project-id'))
      $('#sticky_board_id').val($("#board_id").val())
      $('#group_board_id').val($("#board_id").val())
      $('#sticky_project_id').change()
      $('#group_project_id').change()
      $($(this).data('target')).modal({ dynamic: true })
      false
    )
    .on('click', '[data-object~="boards-previous"]', () ->
      increaseSelectedIndex('#board_id', '#board_name')
      false
    )
    .on('click', '[data-object~="boards-next"]', () ->
      decreaseSelectedIndex('#board_id', '#board_name')
      false
    )
    .on('click', '[data-object~="boards-select"]', () ->
      $('#board_name').html($(this).data('board-name'))
      $('#board_id').val($(this).data('board-id'))
      $($(this).data('target')).submit()
      false
    )
    .on('change', '#sticky_board_id, #group_board_id', () ->
      $('[data-board-id~="' + ($(this).val() || '0') + '"]').click()
      false
    )
    .on('click', '[data-object~="set-scope"]', () ->
      $("#scope").val($(this).data('value'))
      $("#stickies_search").submit()
      setBoardNames()
      false
    )
