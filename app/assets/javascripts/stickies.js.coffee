@addOrUpdateSticky = (sticky_id, due_date, completed, tag_ids, list_element, list_element_with_header, month_element, month_element_with_header) ->
  if $("#list_sticky_#{sticky_id}").length == 1
    $("#list_sticky_#{sticky_id}").replaceWith(list_element)
  else if $(".sticky-list[data-due-date='#{due_date}'][data-completed='#{completed}']").length == 1
    $(".sticky-list[data-due-date='#{due_date}'][data-completed='#{completed}']").append(list_element)
  else if $("#sticky-day-lists").length == 1
    $("#sticky-day-lists").append(list_element_with_header)
    sortDays()

  if $("#list_sticky_#{sticky_id}").length == 1 or $(".sticky-list[data-due-date='#{due_date}'][data-completed='#{completed}']").length == 1 or $("#sticky-day-lists").length == 1
    activateStickyDraggables()

  if $("#sticky_#{sticky_id}_popup").length == 1
    $("#sticky_#{sticky_id}_popup").replaceWith(month_element)
  else if $("#day_#{due_date}_tag_container_#{tag_ids}").length == 1
    $("#day_#{due_date}_tag_container_#{tag_ids}").append(month_element)
  else if $("#day_#{due_date}").length == 1
    $("#day_#{due_date}").append(month_element_with_header)

  if $("#sticky_#{sticky_id}_popup").length == 1 or $("#day_#{due_date}_tag_container_#{tag_ids}").length == 1 or $("#day_#{due_date}").length == 1
    activateCalendarStickyPopups()
    setProjectColors()

  $("#list_sticky_#{sticky_id}, #sticky_#{sticky_id}_popup").effect("highlight", {}, 3000)

@removeSticky = (sticky_id) ->
  if $("#list_sticky_#{sticky_id}").length == 1 and $("#list_sticky_#{sticky_id}").siblings().length == 1
    $("#list_sticky_#{sticky_id}").parent().remove()
  else if $("#list_sticky_#{sticky_id}").length == 1
    $("#list_sticky_#{sticky_id}").remove()
  if $("#sticky_#{sticky_id}_popup").length == 1 and $("#sticky_#{sticky_id}_popup").siblings().length == 1
    $("#sticky_#{sticky_id}_popup").parent().remove()
  else if $("#sticky_#{sticky_id}_popup").length == 1
    $("#sticky_#{sticky_id}_popup").remove()


@sortdates = (a, b) ->
  parta = parseInt($(a).data('sort'))
  partb = parseInt($(b).data('sort'))
  return (parta - partb)

@sortDays = () ->
  new_array = $("#sticky-day-lists .sticky-list").sort(sortdates)
  $('#sticky-day-lists').html('')
  new_array.each( (index, element) ->
    $('#sticky-day-lists').append(element)
  )

@showFilters = () ->
  $('[data-object~="visible-sticky"]').hide()
  $('[data-object~="visible-filter"]').show()
  false

@hideFilters = () ->
  $('[data-object~="visible-filter"]').hide()
  $('[data-object~="visible-sticky"]').show()
  false

@resetStickyFilters = () ->
  url = $("#filters-form").attr('action')
  window.location = url
  false

@saveFilters = () ->
  project_ids = $("[name='project_ids[]']:checked").map( () -> $(this).val() ).get()
  tags = $("[name='tag_names[]']:checked").map( () -> $(this).val() ).get()
  owners = $("[name='user_names[]']:checked").map( () -> $(this).val() ).get()
  url = $("#filters-form").attr('action')
  url = url + "&project_ids=#{project_ids}" unless project_ids.length == 0
  url = url + "&owners=#{owners}" unless owners.length == 0
  url = url + "&tags=#{tags}" unless tags.length == 0
  window.location = url
  false

@activateCalendarStickyPopups = () ->
  $(".sticky_popup")
    .draggable(
      revert: 'invalid'
      helper: 'clone'
    )
  $('[rel~="popover"]').popover( trigger: 'hover' )

@activateCalendarDroppables = () ->
  $(".droppable").droppable(
    hoverClass: "hover",
    drop: ( event, ui ) ->

      date = $(this).data('due-date').replace(/day_/, '') #.replace(/_/g, '/')
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
      $.post(root_url + 'stickies/' + sticky_id + '/move', "due_date=#{date}&from=move", null, "script");
      false
    accept: ( draggable ) ->
      $(this).data('due-date') != draggable.data('due-date')
  )

@setProjectColors = () ->
  $("[data-object~='project-color']").each( () ->
    $(".project_#{$(this).data('project-id')}_color").animate( color: $(this).data('color') )
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
  $.post(root_url + "stickies/#{sticky_id}/move", "due_date=#{date}&shift=#{shift}&from=move", null, "script");


@resetFilters = () ->
  $('#search').val('')
  $('#project_id').val('')
  $('#owner_id').val('')
  $('#unassigned').prop('checked', true)
  $('#due_date_start_date').val('')
  $('#due_date_end_date').val('')
  $('#status_planned').prop('checked', true)
  $('#status_completed').prop('checked', true)
  $('#tag_filter').val('any')
  uncheckAllWithSelector('.tag-box')
  $('#stickies_search').submit()

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
  # $('html, body').animate({ scrollTop: $("#sticky_modal_wrapper").offset().top - 40 }, 'fast');

@hideStickyModal = () ->
  $("#sticky-backdrop").hide()
  $("#sticky_modal_wrapper").hide()

@loadNewStickyModal = () ->
  $('#new-sticky-button').click()
  false

@clearSearchValues = () ->
  $('#project_search').val('')
  $('#search').val('')
  $('#group_search').val('')
  $('[data-object~="tag-select"]').removeClass('active')
  $('#tag_ids').val('')

@resetSubmitButtons = () ->
  $('[data-object~="sticky-submit"]').removeAttr('disabled')

jQuery ->
  $("#sticky_calendar_form")
    .on("change", (event) ->
      $.get($("#sticky_calendar_form").attr("action"), $("#sticky_calendar_form").serialize(), null, "script")
    )

  $(document)
    .on('click', '[data-object~="export"]', () ->
      window.location = $('#stickies_search').attr('action') + '.' + $(this).data('format') + '?' + $('#stickies_search').serialize()
      false
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
      if $(this).hasClass('active')
        $('#assigned_to_me').prop('checked', false)
      else
        $('#assigned_to_me').prop('checked', true)
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
            $(current_checked).prevUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").prop('checked', true)
            $(last_checked).find("[data-object~='sticky-checkbox']").prop('checked', true)
          else
            $(current_checked).prevUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").prop('checked', false)
            $(last_checked).find("[data-object~='sticky-checkbox']").prop('checked', false)
        else
          if add_checks
            $(current_checked).nextUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").prop('checked', true)
            $(last_checked).find("[data-object~='sticky-checkbox']").prop('checked', true)
          else
            $(current_checked).nextUntil(last_checked).andSelf().find("[data-object~='sticky-checkbox']").prop('checked', false)
            $(last_checked).find("[data-object~='sticky-checkbox']").prop('checked', false)

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
      $.get(root_url + 'stickies/new', "sticky[project_id]=#{$('#group_project_id').val()}&sticky[due_date]=#{$('#group_initial_due_date').val()}&sticky[board_id]=#{$('#group_board_id').val()}&"+$('#from').serialize(), null, "script")
      false
    )
    .on('change', '#sticky_repeat', () ->
      if $(this).val() != 'none'
        $('[data-object~="repeat-options"]').show()
      else
        $('[data-object~="repeat-options"]').hide()
    )
    .on('click', '#sticky_all_day', () ->
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
    .on('click', '[data-object~="show-filters"]', () ->
      showFilters()
      false
    )
    .on('click', '[data-object~="cancel-filters"]', () ->
      hideFilters()
      false
    )
    .on('click', '[data-object~="save-filters"]', () ->
      saveFilters()
      false
    )
    .on('click', '[data-object~="reset-filters"]', () ->
      resetStickyFilters()
      false
    )
    .on('dblclick', '[data-object~="create-sticky"]', () ->
      params = {}
      params.from = $(this).data('from')
      params.due_date = $(this).data('due-date')
      $.get(root_url + 'stickies/new', params, null, "script")
      false
    )
    .on('click', '[data-object~="quick-complete"]', () ->
      $.post(root_url + "stickies/#{$(this).data('sticky-id')}", "sticky[completed]=#{$(this).data('completed')}&from=checkbox&_method=patch", null, "script")
      false
    )

  $('#filter_selection a').click( (e) ->
    e.preventDefault()
    $(this).tab('show')
  )

  if $("[data-object='load-month-popovers']").length > 0
    setProjectColors()
    activateCalendarStickyPopups()
    activateCalendarDroppables()

