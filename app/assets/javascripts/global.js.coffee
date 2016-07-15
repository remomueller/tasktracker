
# Global functions referenced from HTML
@checkAllWithSelector = (selector) ->
  elements = $(selector).each( ->
    $(this).prop('checked', true)
  )

@uncheckAllWithSelector = (selector) ->
  elements = $(selector).each( ->
    $(this).prop('checked', false)
  )

@enableAllWithSelector = (selector) ->
  elements = $(selector).each( ->
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

@loadColorSelectors = ->
  $('[data-object~="color-selector"]').each( ->
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

@loadDatePicker = ->
  $(".datepicker").datepicker('remove')
  $(".datepicker").datepicker( autoclose: true )

  $(".datepicker").change( ->
    try
      $(this).val($.datepicker.formatDate('mm/dd/yy', $.datepicker.parseDate('mm/dd/yy', $(this).val())))
    catch error
      # Nothing
  )

@initializeTypeahead = ->
  $('[data-object~="typeahead"]').each( ->
    $this = $(this)
    $this.typeahead(
      local: $this.data('local')
    )
  )

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@ready = ->
  window.$isDirty = false
  contourReady()
  boardsReady()
  stickiesReady()
  tagsReady()
  templatesReady()
  projectsReady()
  initializeTypeahead()
  # TODO: Put these in correct coffee files
  $("#comments_search input").change( ->
    $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script")
    false
  )
  $("#stickies_search select").change( ->
    $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), null, "script")
    false
  )

$(window).onbeforeunload = -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(ready)
$(document)
  .on('turbolinks:load', ready)
  .on('turbolinks:click', -> confirm("You haven't saved your changes.") if window.$isDirty)
  .on('change', ':input', ->
    if $("#isdirty").val() == '1'
      window.$isDirty = true
  )
  .on('click', '[data-object~="suppress-click"]', -> false)
  .on('click', '[data-object~="remove"]', ->
    $($(this).data('target')).remove()
    false
  )
  .on('click', '[data-object~="modal-hide"]', ->
    $($(this).data('target')).modal('hide');
    $('.' + $(this).data('remove-class')).removeClass($(this).data('remove-class'))
    false
  )
  .on('click', '[data-object~="submit"]', ->
    $($(this).data('target')).submit();
    false
  )
  .on('click', '[data-object~="reset-filters"]', ->
    $('[data-object~="filter"]').val('')
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="check"]', ->
    checkAllWithSelector($(this).data('target'))
    false
  )
  .on('click', '[data-object~="uncheck"]', ->
    uncheckAllWithSelector($(this).data('target'))
    false
  )
  .on('click', '[data-object~="settings-save"]', ->
    window.$isDirty = false
    $($(this).data('target')).submit()
    false
  )
  .on('click', '[data-object~="modal-show"]', ->
    $($(this).data('target')).modal('show')
    false
  )
  .keydown( (e) ->
    if e.target.id == "project_search" and e.which == 13
      $("#search").val($("#project_search").val())
      $("#group_search").val($("#project_search").val())
      if templateSelected()
        $("#groups_search").submit()
      else
        # selectBoard('all')
        $('#stickies_search').submit()
  )
  .on('click', '#global-search', (e) ->
    e.stopPropagation()
    false
  )
  .on('change', "#sticky_project_id", ->
    $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize() + "&" + $("#sticky_board_id").serialize(), null, "script")
    false
  )
