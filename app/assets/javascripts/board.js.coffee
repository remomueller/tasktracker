# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@setBoardNames = () ->
  $('[data-object~="board-select"]').each( () ->
    board_label = $(this).data('board-name')
    scope = ""
    if $("#scope").val() == 'past_due'
      scope = 'past'
    else if $("#scope").val() == 'upcoming'
      scope = 'future'
    if scope != ""
      if parseInt($("#assigned_to_me").val()) == 1
        board_label += " (" + $(this).data('my-'+scope+'-incomplete') + ")" if parseInt($(this).data('my-'+scope+'-incomplete')) > 0
      else
        board_label += " (" + $(this).data(scope+'-incomplete') + ")" if parseInt($(this).data(scope+'-incomplete')) > 0
    $(this).html(board_label)
  )

@selectBoard = (board_id) ->
  board = $('[data-object~="board-select"][data-board-id='+board_id+']')

  $('[data-object~="board-select"]').parent().removeClass('active')
  $(board).parent().addClass('active')
  $('#board_id').val(board_id)
  true


@browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined

# if browserSupportsPushState
#   window.addEventListener 'popstate', (event) ->
#     # state = event.originalEvent.state;
#     # window.history.back() if event.state
#     # window.replaceState(event.state.position, ) if event.state?.tasktracker

@updateSite = (currentPage, data) ->
  # load your pages using the currentPage variable. To test it first, add an alert function like:
  # alert(currentPage + data.page)
  # $('[data-object~="board-select"][data-board-id="'+data.board_id+'"]').click()
  selectBoard(data.board_id)
  $("#stickies_search").submit()
  false

if browserSupportsPushState
  $(window).bind("popstate", (e) ->
    state = event.state
    if state and state?.tasktracker
      updateSite(state.page, state)
    # else
      # updateSite("home", { page: 'home', tasktracker: false })
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

      return true if nonStandardClick(event)


      url = $(this).attr("href")

      return false if $('#board_id').val().toString() == $(this).data('board-id').toString()

      selectBoard($(this).data('board-id'))

      $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), ((data) ->
        if browserSupportsPushState #history.pushState
          history.pushState({ page:url, tasktracker: true, board_id: $('#board_id').val() }, null, url)
        # if history.replaceState
        #   history.replaceState(null, null, url)
      ), "script")

      # $("#stickies_search").submit()
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
    .on('click', '[data-object~="clear-tags"]', () ->
      $('[data-object~="tag-select"]').parent().removeClass('active')
      $('#tag_ids').val('')
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
