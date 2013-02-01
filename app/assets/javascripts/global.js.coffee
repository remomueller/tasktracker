
# Global functions referenced from HTML
@checkAllWithSelector = (selector) ->
  elements = $(selector).each( () ->
    $(this).attr('checked','checked')
  )

@uncheckAllWithSelector = (selector) ->
  elements = $(selector).each( () ->
    $(this).removeAttr('checked')
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
      $(this).attr('checked','checked')
      $(this).removeAttr('disabled')
    else
      $(this).removeAttr('checked')
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
  $(".datepicker").datepicker(
    showOtherMonths: true
    selectOtherMonths: true
    changeMonth: true
    changeYear: true
    onClose: (text, inst) -> $(this).focus()
  )
  $(".datepicker").change( () ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))
    catch error
      # Nothing
  )

jQuery ->

  window.$isDirty = false
  msg = 'You haven\'t saved your changes.'

  $(document).on('change', ':input', () ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )

  $(document).ready( () ->
    window.onbeforeunload = (el) ->
      if window.$isDirty
        return msg
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
      return if $("input, textarea").is(":focus")
      increaseSelectedIndex('#board_id', '#board_name') if e.which == 37
      decreaseSelectedIndex('#board_id', '#board_name') if e.which == 39
      goBackOneMonth() if e.which == 37
      goForwardOneMonth() if e.which == 39
      if $("#sticky-backdrop").is(':visible')
        hideStickyModal()               if e.which == 27
      else
        loadNewStickyModal() if e.which == 83
        loadNewGroupModal()  if e.which == 71
      # P will enter the search box
      if e.which == 80 and not $("input, textarea").is(":focus")
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
    source: (query, process) ->
      return $.get(root_url + 'search', { q: query }, (data) -> return process(data))
    updater: (item) ->
      $("#global-search").val(item)
      $("#global-search-form").submit()
      return item
  )

  loadColorSelectors()

  $('#welcome-dialog').modal()
