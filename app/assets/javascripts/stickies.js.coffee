@goBackOneMonth = () ->
  now = new Date $('#selected_date').val()
  now = new Date() if isNaN(now.getFullYear())
  new_month = new Date now.getFullYear(), now.getMonth()-1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#selected_date').change()

@goForwardOneMonth = () ->
  now = new Date $('#selected_date').val()
  now = new Date() if isNaN(now.getFullYear())
  new_month = new Date now.getFullYear(), now.getMonth()+1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#selected_date').change()

@getToday = () ->
  now = new Date()
  $('#selected_date').val((now.getMonth() + 1) + "/" + now.getDate() + "/" + now.getFullYear())
  $('#selected_date').change()

@activateCalendarStickyPopups = () ->
  $(".sticky_popup")
    .draggable(
      revert: 'invalid'
      helper: 'clone'
    )

@activateCalendarDroppables = () ->
  $(".droppable").droppable(
    hoverClass: "hover",
    drop: ( event, ui ) ->

      date = $(this).attr('data-due-date').replace(/day_/, '').replace(/_/g, '/')
      element_id = ui.draggable.attr('id')
      sticky_id = element_id.replace(/sticky_/, '').replace(/_popup/,'')

      $('#move_sticky_date').val(date)
      $('#move_sticky_element_id').val('#' + element_id)
      $('#move_sticky_id').val(sticky_id)

      if $(ui.draggable).data('grouped') == 'grouped'
        $('#move-group-dialog').modal('show')
        return false

      if $(element_id).parent().children(".sticky_popup").size() == 2
        $(element_id).parent().remove()
      else
        $(element_id).remove()
      $.post(root_url + 'stickies/' + sticky_id + '/move', "due_date="+date, null, "script");
      false
    accept: ( draggable ) ->
      $(this).data('due-date') != draggable.data('due-date')
  )

@completeStickyGroupMove = (shift) ->
  $('#move-group-dialog').modal('hide')
  date = $('#move_sticky_date').val()
  element_id = $('#move_sticky_element_id').val()
  sticky_id = $('#move_sticky_id').val()
  if $(element_id).parent().children(".sticky_popup").size() == 1
    $(element_id).parent().remove()
  else
    $(element_id).remove()
  $.post(root_url + "stickies/#{sticky_id}/move", "due_date=#{date}&shift=#{shift}", null, "script");


@resetFilters = () ->
  $('#search').val('')
  $('#project_id').val('')
  $('#owner_id').val('')
  $('#unassigned').attr('checked','checked')
  $('#due_date_start_date').val('')
  $('#due_date_end_date').val('')
  $('#status_planned').attr('checked','checked')
  $('#status_completed').attr('checked','checked')
  $('#tag_filter').val('any')
  uncheckAllWithSelector('.tag-box')
  $('#stickies_search').submit()

@openCalendarPopup = (selected_date) ->
  if $('#welcome-dialog').length > 0
    $('#welcome-dialog').modal('toggle')
  else
    $('#initial_due_date').val(selected_date)
    $('#sticky_due_date').val(selected_date)
    # $('#new-sticky-or-group-dialog').modal( dynamic: true )
    $.get(root_url + "stickies/new", "sticky[due_date]=#{selected_date}&from_calendar=1", null, "script")

@markCompletion = (sticky_id, completed) ->
  if completed
    $("#sticky_#{sticky_id}_row").removeClass('sticky-not-completed')
    $("#sticky_#{sticky_id}_row").addClass('sticky-completed')
  else
    $("#sticky_#{sticky_id}_row").removeClass('sticky-completed')
    $("#sticky_#{sticky_id}_row").addClass('sticky-not-completed')
  $("[data-object~='sticky-checkbox'][data-sticky-id='#{sticky_id}']").data('completed', completed)

@markCalendarCompletion = (sticky_id, completed, icon_html) ->
  if completed
    $("#sticky_#{sticky_id}_name").css('text-decoration', 'line-through')
    $("#sticky_#{sticky_id}_icon").html(icon_html)
    # $("#sticky_#{sticky_id}_description").css('color', '#999')
  else
    $("#sticky_#{sticky_id}_name").css('text-decoration', 'none')
    $("#sticky_#{sticky_id}_icon").html(icon_html)
    # $("#sticky_#{sticky_id}_description").css('color', 'inherit')

@initializeCompletionButtons = () ->
  stickies_completed = []
  stickies_not_completed = []
  $.each($('[data-object~="sticky-checkbox"]:checked'), (index, element) ->
    if $(element).data('completed')
      stickies_completed.push($(element).data('sticky-id'))
    else
      stickies_not_completed.push($(element).data('sticky-id'))
  )
  # alert "     completed: " + stickies_completed.length + " \nnot completed: " + stickies_not_completed.length
  if stickies_completed.length > 0
    $('[data-object~="set-stickies-status"][data-undo=true]').show()
  else
    $('[data-object~="set-stickies-status"][data-undo=true]').hide()
  if stickies_not_completed.length > 0
    $('[data-object~="set-stickies-status"][data-undo=false]').show()
  else
    $('[data-object~="set-stickies-status"][data-undo=false]').hide()
  if stickies_completed.length + stickies_not_completed.length > 0
    $('[data-object~="delete-stickies"]').show()
  else
    $('[data-object~="delete-stickies"]').hide()


@showStickyModal = () ->
  $("#sticky-backdrop").show()
  $("#sticky_modal_wrapper").show()
  $('html, body').animate({ scrollTop: $("#sticky_modal_wrapper").offset().top - 40 }, 'fast');

@hideStickyModal = () ->
  $("#sticky-backdrop").hide()
  $("#sticky_modal_wrapper").hide()

@loadNewStickyModal = () ->
  if $('#welcome-dialog').length > 0
    $('#welcome-dialog').modal('toggle')
  else
    $('#new-sticky-button').click()
  false

@clearSearchValues = () ->
  $('#project_search').val('')
  $('#search').val('')
  $('#group_search').val('')
  $('[data-object~="tag-select"]').parent().removeClass('active')
  $('#tag_ids').val('')

@resetSubmitButtons = () ->
  $('[data-object~="sticky-submit"]').removeAttr('disabled')

jQuery ->
  $("#sticky_calendar_form")
    .on("change", (event) ->
      $.get($("#sticky_calendar_form").attr("action"), $("#sticky_calendar_form").serialize(), null, "script")
    )

  $(document)
    .on('click', '[data-object~="calendar-next-month"]', () ->
      goForwardOneMonth()
      false
    )
    .on('click', '[data-object~="calendar-previous-month"]', () ->
      goBackOneMonth()
      false
    )
    .on('click', '[data-object~="calendar-today"]', () ->
      getToday()
      false
    )
    .on('click', '[data-object~="export"]', () ->
      window.location = $('#stickies_search').attr('action') + '.' + $(this).data('format') + '?' + $('#stickies_search').serialize()
    )
    .on('click', '[data-object~="stickies-reset-to-default"]', () ->
      resetFilters()
      false
    )
    .on('click', '[data-object~="expand-details"]', () ->
      $('[data-object~="expand-details"]').show()
      $('[data-object~="stickyshortdetails"]').show()
      $($(this).data('selector-two')).hide()
      $('[data-object~="' + $(this).data('selector') + '"]').hide()
      $($(this).data('target')).show()
    )
    .on('click', '#assigned-to-me-btn', () ->
      $(this).button('toggle')
      if $(this).hasClass('active')
        $('#assigned_to_me').val('1')
      else
        $('#assigned_to_me').val('0')
      setBoardNames()
      $('#stickies_search').submit()
    )
    .on('click', '#all-stickies', () ->
      $('#status_planned').val('planned')
      $('#status_completed').val('completed')
      $('#stickies_search').submit()
    )
    .on('click', '#not-completed-stickies', () ->
      $('#status_planned').val('planned')
      $('#status_completed').val('')
      $('#stickies_search').submit()
    )
    .on('click', '[data-object~="shift-sticky"]', () ->
      completeStickyGroupMove($(this).data('shift'))
      false
    )
    .on('click', "[data-link]", (e) ->
      if nonStandardClick(e)
        window.open($(this).data("link"))
        return false
      else
        if $(this).data('remote')
          if $(this).data('method') == 'get'
            $.get($(this).data("link"), null, null, "script")
          else
            $.post($(this).data("link"), null, null, "script")
        else
          window.location = $(this).data("link")
    )
    .on('click', "#sticky-backdrop", (e) ->
      hideStickyModal() if e.target.id == "sticky-backdrop"
    )
    .on('click', '[data-object~="hide-sticky-modal"]', () ->
      hideStickyModal()
      false
    )
    .on('click', '[data-object~="set-stickies-status"]', (e) ->
      sticky_ids = []
      $.each($('[data-object~="sticky-checkbox"]:checked'), (index, element) -> sticky_ids.push($(element).data('sticky-id')))
      $.post($(this).data("url"), "sticky_ids=#{sticky_ids.join(',')}", null, "script")
      false
    )
    .on('click', '[data-object~="sticky-checkbox"]', (e) ->
      last_checked = "#sticky_#{window.$lastStickyChecked}_row"
      current_checked = "#sticky_#{$(this).data('sticky-id')}_row"

      add_checks = $(this).is(':checked')

      if e.shiftKey and $(last_checked).length > 0 and last_checked != current_checked
        if $(current_checked).prevAll(last_checked).length != 0
          if add_checks
            $(current_checked).prevUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").attr('checked','checked')
            $(last_checked).find("[data-object~='sticky-checkbox']").attr('checked','checked')
          else
            $(current_checked).prevUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").removeAttr('checked')
            $(last_checked).find("[data-object~='sticky-checkbox']").removeAttr('checked')
        else
          if add_checks
            $(current_checked).nextUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").attr('checked','checked')
            $(last_checked).find("[data-object~='sticky-checkbox']").attr('checked','checked')
          else
            $(current_checked).nextUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").removeAttr('checked')
            $(last_checked).find("[data-object~='sticky-checkbox']").removeAttr('checked')

      window.$lastStickyChecked = $(this).data('sticky-id')
      initializeCompletionButtons()
    )
    .on('click', '[data-object~="delete-stickies"]', () ->
      sticky_ids = []
      $.each($('[data-object~="sticky-checkbox"]:checked'), (index, element) -> sticky_ids.push($(element).data('sticky-id')))

      if confirm("Are you sure you want to delete #{if sticky_ids.length == 1 then 'this Sticky' else sticky_ids.length.toString() + ' Stickies' }?")
        $.post($(this).data("url"), "sticky_ids=#{sticky_ids.join(',')}", null, "script")
      false
    )
    .on('click', '[data-object~="load-new-sticky"]', () ->
      $.get(root_url + 'stickies/new', "sticky[project_id]=#{$('#group_project_id').val()}&sticky[due_date]=#{$('#group_initial_due_date').val()}&sticky[board_id]=#{$('#group_board_id').val()}&"+$('#from_calendar').serialize(), null, "script")
      false
    )
    .on('change', '#sticky_repeat', () ->
      if $(this).val() != 'none'
        $('[data-object~="repeat-options"]').show()
      else
        $('[data-object~="repeat-options"]').hide()
    )
    .on('click', '#set_time', () ->
      if $(this).is(':checked')
        $('[data-object~="time-options"]').hide()
      else
        $('[data-object~="time-options"]').show()
    )
    .on('click', '[data-object~="sticky-submit"]', () ->
      $('[data-object~="sticky-submit"]').attr('disabled', 'disabled')
      $($(this).data('target')).submit()
      false
    )
