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
      if $(ui.draggable).parent().children(".sticky_popup").size() == 2
        $(ui.draggable).parent().remove()
      else
        $(ui.draggable).remove()
      $.post(root_url + 'stickies/' + sticky_id + '/move', "due_date="+date, null, "script");
      false
  )

@resetFilters = () ->
  $('#search').val('')
  $('#project_id').val('')
  $('#owner_id').val('')
  $('#unnassigned').attr('checked','checked')
  $('#due_date_start_date').val('')
  $('#due_date_end_date').val('')
  $('#status_planned').attr('checked','checked')
  $('#status_completed').attr('checked','checked')
  $('#tag_filter').val('any')
  uncheckAllWithSelector('.tag-box')
  $('#stickies_search').submit()

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
