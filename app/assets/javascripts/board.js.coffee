# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@activateStickyDraggables = () ->
  $('[data-object~="sticky-draggable"]').draggable(
    revert: 'invalid'
    helper: () ->
      count = $('[data-object~="sticky-checkbox"]:checked').length
      if count > 1
        "<div class='sticky-box'>&equiv;&nbsp;&nbsp;#{count} Stickies Selected</div>"
      else
        "<div class='sticky-box'>"+$(this).children('[data-object~="sticky-helper"]').first().html()+"</div>"
    cursorAt: { left: 10 }
  )

@activateBoardDroppables = () ->
  $('[data-object~="board-droppable"]').droppable(
    hoverClass: "board-droppable-hover"
    tolerance: "pointer"
    drop: ( event, ui ) ->
      sticky_id = ui.draggable.data('sticky-id')
      board_id = $(this).data('board-id')
      project_id = $(this).data('project-id')
      # $.post(root_url + 'stickies/' + sticky_id + '/move_to_board', "board_id="+board_id, null, "script")
      sticky_ids = []
      $.each($('[data-object~="sticky-checkbox"]:checked'), (index, element) -> sticky_ids.push($(element).data('sticky-id')))
      $.post(root_url + 'boards/add_stickies', "project_id=#{project_id}&board_id=#{board_id}&sticky_ids=#{sticky_ids.join(',')}", null, "script")
    accept: ( draggable ) ->
      $('[data-object~="sticky-checkbox"]:checked').length > 1 or ($(this).data('board-id') != draggable.data('board-id') and $.inArray('sticky-draggable', draggable.data('object').split(" ")) != -1)
  )

@activateBoardDraggables = () ->
  $('[data-object~="board-draggable"]').draggable(
    revert: 'invalid'
    helper: () ->
      "<div class='sticky-box'>"+$('[data-object~="board-helper"][data-board-id="'+$(this).data('board-id')+'"]').first().html()+"</div>"
    cursorAt: { left: 10 }
  )

@activateBoardArchiveDroppable = () ->
  $('[data-object~="board-archive-droppable"]').droppable(
    activeClass: "archive-droppable-active"
    tolerance: "pointer"
    drop: ( event, ui ) ->
      board_id = ui.draggable.data('board-id')
      archived = $(this).data('archived')
      $.post(root_url + 'boards/' + board_id + '/archive', "archived="+archived, null, "script")
    accept: ( draggable ) ->
      $.inArray('board-draggable', draggable.data('object').split(" ")) != -1 and $(this).data('archived') != draggable.data('archived')
  )

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
    .on('click', '[data-object~="board-select"]', (e) ->
      return true if nonStandardClick(e)

      url = $(this).attr("href")

      if $('#board_id').val().toString() == $(this).data('board-id').toString()
        selectBoard($(this).data('board-id'))
        $("#stickies_search").submit()
      else
        selectBoard($(this).data('board-id'))

        $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), ((data) ->
          if browserSupportsPushState #history.pushState
            history.pushState({ page:url, tasktracker: true, board_id: $('#board_id').val() }, null, url)
          # if history.replaceState
          #   history.replaceState(null, null, url)
        ), "script")
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
      if $(this).data('visible')
        $('[data-object~="board-select"][data-archived="true"]').hide()
        $('[data-object~="board-select"]').parent().removeClass('active')
        $('[data-object~="board-select"][data-board-id="0"]').click();
        $('[data-object~="board-select"][data-board-id="0"]').parent().addClass('active')
        $(this).html("Show " + $(this).data('message'))
        $(this).data('visible', false)
      else
        $('[data-object~="board-select"][data-archived="true"]').show()
        $('[data-object~="board-select"]').parent().removeClass('active')
        $('[data-object~="board-select"][data-board-id="'+ $(this).data('board-id') + '"]').parent().addClass('active')
        $('[data-object~="board-select"][data-board-id="'+$(this).data('board-id')+'"]').click();
        $(this).html("Hide " + $(this).data('message'))
        $(this).data('visible', true)
      $("#stickies_search").submit()
      false
    )
    .on('click', '[data-object~="create-board"]', () ->
      window.location = $(this).data("url")
    )
    .on('mousedown', '[data-object~="sticky-draggable"]', () ->
      unless $('[data-object~="sticky-checkbox"][data-sticky-id="'+$(this).data('sticky-id')+'"]').is(':checked')
        $('[data-object~="sticky-checkbox"]').removeAttr('checked')
        $('[data-object~="sticky-checkbox"][data-sticky-id="'+$(this).data('sticky-id')+'"]').attr('checked','checked')
    )
    .on('click', '[data-object~="check-all-stickies"]', () ->
      if $(this).is(':checked')
        $('[data-object~="sticky-checkbox"]').attr('checked','checked')
      else
        $('[data-object~="sticky-checkbox"]').removeAttr('checked')
    )
    # .on('click', '[data-object~="count-stickies"]', () ->
    #   alert $('[data-object~="sticky-checkbox"]:checked').length
    #   false
    # )


    setBoardNames()
    activateBoardDraggables()
    activateBoardDroppables()
    activateBoardArchiveDroppable()
