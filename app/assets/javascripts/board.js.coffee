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
      board_id = $(this).data('board-id')
      project_id = $(this).data('project-id')
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
    scope = $("#scope").val().replace(/_/, '-')
    if scope != ""
      if parseInt($("#assigned_to_me").val()) == 1
        board_label += " (" + $(this).data('my-'+scope+'-count') + ")" if parseInt($(this).data('my-'+scope+'-count')) > 0
      else
        board_label += " (" + $(this).data(scope+'-count') + ")" if parseInt($(this).data(scope+'-count')) > 0
    $(this).html(board_label)
  )

@selectBoard = (board_id) ->
  board = $('[data-object~="board-select"][data-board-id='+board_id+']')

  showArchivedBoards() if board.data('archived').toString() == 'true'

  deselectTemplate()

  $('[data-object~="board-select"]').parent().removeClass('active')
  $(board).parent().addClass('active')
  $('#board_id').val(board_id)
  true

@selectTag = (tag_id) ->
  tag = $('[data-object~="tag-select"][data-tag-id='+tag_id+']')

  deselectTemplate()

  $('[data-object~="tag-select"]').parent().removeClass('active')
  $(tag).parent().addClass('active')
  $('#tag_ids').val(tag_id)
  true

@browserSupportsPushState =
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined

@updateSite = (currentPage, data) ->
  if parseInt(data.template_id) > 0
    selectTemplate(data.template_id)
    $("#groups_search").submit()
  else
    selectBoard(data.board_id)
    $("#stickies_search").submit()
  false

@hideArchivedBoards = () ->
  archive_button = $('[data-object~="toggle-archived-boards"]')
  $('[data-object~="board-select"][data-archived="true"]').hide()
  $(archive_button).html("Show " + $(archive_button).data('message'))
  $(archive_button).data('visible', false)
  # Select the Holding Pen if an archived board was selected
  if $("[data-object~='board-select'][data-board-id='#{$("#board_id").val()}']").data('archived').toString() == 'true'
    $('[data-object~="board-select"]').parent().removeClass('active')
    $('[data-object~="board-select"][data-board-id="0"]').click()
    $('[data-object~="board-select"][data-board-id="0"]').parent().addClass('active')
    $("#stickies_search").submit()


@showArchivedBoards = () ->
  archive_button = $('[data-object~="toggle-archived-boards"]')
  $('[data-object~="board-select"][data-archived="true"]').show()
  $(archive_button).html("Hide " + $(archive_button).data('message'))
  $(archive_button).data('visible', true)


if browserSupportsPushState
  $(window).bind("popstate", (e) ->
    state = event.state
    if state and state?.tasktracker
      updateSite(state.page, state)
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
          if browserSupportsPushState
            history.pushState({ page:url, tasktracker: true, board_id: $('#board_id').val() }, null, url)
        ), "script")
      false
    )
    .on('click', '[data-object~="tag-select"]', () ->
      if parseInt($('#tag_ids').val()) == parseInt($(this).data('tag-id'))
        $(this).parent().removeClass('active')
        $('#tag_ids').val('')
      else
        selectTag($(this).data('tag-id'))
        if $("#board_id").val() == 'none' or $("#board_id").val() == ''
          $('[data-object~="board-select"][data-board-id="all"]').click()
          return false
      $("#stickies_search").submit()
      false
    )
    .on('click', '[data-object~="clear-tags"]', () ->
      $('#project_search').val('')
      $('#search').val('')
      $('#group_search').val('')
      $('[data-object~="tag-select"]').parent().removeClass('active')
      $('#tag_ids').val('')
      if templateSelected()
        $("#groups_search").submit()
      else
        $("#stickies_search").submit()
      false
    )
    .on('click', '[data-object~="toggle-archived-boards"]', () ->
      if $(this).data('visible')
        hideArchivedBoards()
      else
        showArchivedBoards()
      false
    )
    .on('click', '[data-object~="create-board"]', () ->
      window.location = $(this).data("url")
    )
    .on('mousedown', '[data-object~="sticky-draggable"]', () ->
      unless $('[data-object~="sticky-checkbox"][data-sticky-id="'+$(this).data('sticky-id')+'"]').is(':checked')
        $('[data-object~="sticky-checkbox"]').removeAttr('checked')
        $('[data-object~="sticky-checkbox"][data-sticky-id="'+$(this).data('sticky-id')+'"]').attr('checked','checked')
        initializeCompletionButtons()
    )
    .on('click', '[data-object~="check-all-stickies"]', () ->
      if $(this).is(':checked')
        $('[data-object~="sticky-checkbox"]').attr('checked','checked')
      else
        $('[data-object~="sticky-checkbox"]').removeAttr('checked')
      initializeCompletionButtons()
    )


    setBoardNames()
    activateBoardDraggables()
    activateBoardDroppables()
    activateBoardArchiveDroppable()
