# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@setBoardNames = () ->
  $('[data-object~="board-select"]').each( () ->
    board_label = $(this).data('board-name')
    if parseInt($("#assigned_to_me").val()) == 1
      board_label += " (" + $(this).data('my-incomplete-count') + ")" if parseInt($(this).data('my-incomplete-count')) > 0
    else
      board_label += " (" + $(this).data('incomplete-count') + ")" if parseInt($(this).data('incomplete-count')) > 0
    $(this).html(board_label)
  )

jQuery ->
  $(document)
    .on('click', '[data-object~="create-new-board"]', () ->
      $("#create_new_board").val('1')
      $("#sticky_board_id_container").hide()
      $("#sticky_board_name_container").show()
      false
    )
    .on('click', '[data-object~="show-existing-boards"]', () ->
      $("#create_new_board").val('0')
      $("#sticky_board_name_container").hide()
      $("#sticky_board_id_container").show()
      false
    )
    .on('click', '[data-object~="board-select"]', () ->
      if parseInt($('#board_id').val()) == parseInt($(this).data('board-id'))
        $(this).parent().removeClass('active')
        $('#board_id').val('0')
        $('[data-object~="board-select"][data-board-id="0"]').parent().addClass('active')
      else
        $('[data-object~="board-select"]').parent().removeClass('active')
        $(this).parent().addClass('active')
        $('#board_id').val($(this).data('board-id'))
      $("#stickies_search").submit()
      false
    )
    .on('click', '[data-object~="tag-select"]', () ->
      if parseInt($('#tag_ids').val()) == parseInt($(this).data('tag-id'))
        $(this).parent().removeClass('active')
        $('#tag_ids').val('')
      else
        $('[data-object~="tag-select"]').parent().removeClass('active')
        $(this).parent().addClass('active')
        $('#tag_ids').val($(this).data('tag-id'))
      $("#stickies_search").submit()
      false
    )
    .on('click', '[data-object~="toggle-archived-boards"]', () ->
      if $("#archived_boards_container").is(":visible")
        $("#archived_boards_container").hide()
        $('[data-object~="board-select"]').parent().removeClass('active')
        $('#board_id').val('0')
        $('[data-object~="board-select"][data-board-id="0"]').parent().addClass('active')
        $(this).html("Show " + $(this).data('message'))
      else
        $('[data-object~="board-select"]').parent().removeClass('active')
        $('[data-object~="board-select"][data-board-id="'+ $(this).data('board-id') + '"]').parent().addClass('active')
        $('#board_id').val($(this).data('board-id'))
        $(this).html("Hide " + $(this).data('message'))
        $("#archived_boards_container").show()
      $("#stickies_search").submit()
      false
    )

    setBoardNames()
