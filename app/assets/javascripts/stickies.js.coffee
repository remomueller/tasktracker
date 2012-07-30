@toggleSticky = (element) ->
  $(element).toggle()
  $(element+'_short_description').toggle()
  $(element+'_description').toggle('slide', { direction: 'up' })

@goBackOneMonth = () ->
  now = new Date $('#selected_date').val()
  now = new Date() if isNaN(now.getFullYear())
  new_month = new Date now.getFullYear(), now.getMonth()-1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#direction').val(-1)
  $('#selected_date').change()

@goForwardOneMonth = () ->
  now = new Date $('#selected_date').val()
  now = new Date() if isNaN(now.getFullYear())
  new_month = new Date now.getFullYear(), now.getMonth()+1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#direction').val(1)
  $('#selected_date').change()

@getToday = () ->
  now = new Date()
  $('#selected_date').val((now.getMonth() + 1) + "/" + now.getDate() + "/" + now.getFullYear())
  $('#direction').val(0)
  $('#selected_date').change()

@activateCalendarStickyPopups = () ->
  $(".sticky_popup").each( (index, element) ->
    $(element).qtip(
      content:
        text: '<div id="' + element.id + '_text"><center><img src=\"' + root_url + 'assets/contour/ajax-loader.gif\" align=\"absmiddle\" alt=\"...\" /></center></div>'
        ajax:
          url: $(element).attr('rel')
          type: 'POST'
          success: (data, status) -> eval(data)
        title:
          text: $(element).attr('data-title')
      show:
        event: 'mouseenter'
      hide:
        event: 'mouseleave'
      position:
        my: 'left top'
        at: 'right center'
        viewport: $(window)
      style:
        classes: 'ui-tooltip-shadow ui-tooltip-yellow'
    )
    $(element).draggable({ revert: 'invalid', helper: "clone" });
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
    $('#welcome-dialog').modal('toggle');
  else
    $('#initial_due_date').val(selected_date)
    $('#sticky_due_date').val(selected_date)
    $('#new-sticky-or-group-dialog').modal( dynamic: true )

jQuery ->
  $("#sticky_calendar_form")
    .on("change", (event) ->
      $.get($("#sticky_calendar_form").attr("action"), $("#sticky_calendar_form").serialize(), null, "script")
    )

  $(document)
    .keydown( (e) ->
      if $("input, textarea").is(":focus") then return
      if e.which == 37
        goBackOneMonth()
      if e.which == 39
        goForwardOneMonth()
    )
    .on('click', '[data-object~="sticky-toggle"]', () ->
      toggleSticky($(this).data('target'))
      false
    )
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
    )
    .on('click', '#all-stickies', () ->
      $('#status_planned').val('planned')
      $('#status_completed').val('completed')
    )
    .on('click', '#not-completed-stickies', () ->
      $('#status_planned').val('planned')
      $('#status_completed').val('')
    )
    .on('click', '[data-object~="shift-sticky"]', () ->
      completeStickyGroupMove($(this).data('shift'))
    )
