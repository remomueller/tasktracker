jQuery ->
  $(document)
    # .on('click', '.last-month', () -> goBackOneMonth())
    # .on('click', '.next-month', () -> goForwardOneMonth())
    .keydown( (e) ->
      if $("input, textarea").is(":focus") then return
      if e.which == 37
        goBackOneMonth()
      if e.which == 39
        goForwardOneMonth()
    )

  $("#sticky_calendar_form")
    .on("change", (event) ->
      $.get($("#sticky_calendar_form").attr("action"), $("#sticky_calendar_form").serialize(), null, "script")
    )

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
