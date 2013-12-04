
# Global functions referenced from HTML
@checkAllWithSelector = (selector) ->
  elements = $(selector).each( () ->
    $(this).prop('checked', true)
  )

@uncheckAllWithSelector = (selector) ->
  elements = $(selector).each( () ->
    $(this).prop('checked', false)
  )

@enableAllWithSelector = (selector) ->
  elements = $(selector).each( () ->
    enable = true
    classList = $(this).attr('class').split(/\s+/)
    $.each(classList, (index, c) ->
      if $('.' + c + '_parent').is(':checkbox')
        enable = false unless $('.' + c + '_parent').is(':checked')
    )
    if enable
      $(this).prop('checked', true)
      $(this).removeAttr('disabled')
    else
      $(this).prop('checked', false)
      $(this).attr('disabled', 'disabled')
  )

@loadColorSelectors = () ->
  $('[data-object~="color-selector"]').each( () ->
    $this = $(this)
    $this.ColorPicker(
      color: $this.data('color')
      onShow: (colpkr) ->
        $(colpkr).fadeIn(500)
        return false
      onHide: (colpkr) ->
        $(colpkr).fadeOut(500)
        $($this.data('form')).submit()
        return false
      onChange: (hsb, hex, rgb) ->
        $($this.data('target')).val('#' + hex)
        $($this.data('target')+"_display").css('backgroundColor', '#' + hex)
      onSubmit: (hsb, hex, rgb, el) ->
        $(el).ColorPickerHide();
    )
  )

@loadDatePicker = () ->
  $(".datepicker").datepicker('remove')
  $(".datepicker").datepicker( autoclose: true )

  $(".datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))
    catch error
      # Nothing
  )

@initializeTypeahead = () ->
  $('[data-object~="typeahead"]').each( () ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )

@ready = () ->
  contourReady()
  initializeTypeahead()
  loadColorSelectors()
  window.$isDirty = false
  msg = "You haven't saved your changes."
  window.onbeforeunload = (el) -> return msg if window.$isDirty

$(document).ready(ready)
$(document).on('page:load', ready)

jQuery ->

  $(document).on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

  # <a href='#' data-object="remove" data-target="abc"></a>
  # <div id="abc">
  # Removes a data-target id when a node with data-object="remove" is clicked
  $(document)
    .on('click', '[data-object~="remove"]', () ->
      $($(this).data('target')).remove()
      false
    )
    .on('click', '[data-object~="modal-hide"]', () ->
      $($(this).data('target')).modal('hide');
      $('.' + $(this).data('remove-class')).removeClass($(this).data('remove-class'))
      false
    )
    .on('click', '[data-object~="submit"]', () ->
      $($(this).data('target')).submit();
      false
    )
    .on('click', '[data-object~="reset-filters"]', () ->
      $('[data-object~="filter"]').val('')
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="check"]', () ->
      checkAllWithSelector($(this).data('target'))
      false
    )
    .on('click', '[data-object~="uncheck"]', () ->
      uncheckAllWithSelector($(this).data('target'))
      false
    )
    .on('click', '[data-object~="settings-save"]', () ->
      window.$isDirty = false
      $($(this).data('target')).submit()
      false
    )
    .on('click', '[data-object~="suppress-click"]', () ->
      false
    )
    .on('click', '[data-object~="modal-show"]', () ->
      $($(this).data('target')).modal('show')
      false
    )

  # TODO: Put these in correct coffee files
  $("#comments_search input").change( () ->
    $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script")
    false
  )

  $("#stickies_search select").change( () ->
    $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), null, "script")
    false
  )

  $(document)
    .keydown( (e) ->
      if e.target.id == "project_search" and e.which == 13
        $("#search").val($("#project_search").val())
        $("#group_search").val($("#project_search").val())
        if templateSelected()
          $("#groups_search").submit()
        else
          # selectBoard('all')
          $('#stickies_search').submit()
      if $("#global-search").is(':focus') and e.which == 27
        $("#global-search").blur()
        return
      return if $("input, textarea, select, a").is(":focus")
      # P will enter the search box
      if e.which == 80
        $("#global-search").focus()
        e.preventDefault()
    )
    .on('click', '#global-search', (e) ->
      e.stopPropagation()
      false
    )
    .on('change', "#sticky_project_id", () ->
      $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize() + "&" + $("#sticky_board_id").serialize(), null, "script")
      false
    )

  $("#global-search").typeahead(
    remote: root_url + 'search?q=%QUERY'
  )

  $(document).on('typeahead:selected', "#global-search", (event, datum) ->
    $(this).val(datum['value'])
    $("#global-search-form").submit()
  )
  .on('keydown', "#global-search", (e) ->
    $("#global-search-form").submit() if e.which == 13
  )
