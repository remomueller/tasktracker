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

@setFocusToField = (element_id) ->
  val = $(element_id).val()
  $(element_id).focus().val('').val(val)

@nonStandardClick = (event) ->
  event.which > 1 or event.metaKey or event.ctrlKey or event.shiftKey or event.altKey

@extensionsReady = ->
  datepickerReady()
  tooltipsReady()
  typeaheadReady()

@turbolinksReady = ->
  window.$isDirty = false
  boardsReady()
  stickiesReady()
  tagsReady()
  templatesReady()
  projectsReady()
  # TODO: Remove form-load
  $('[data-object~="form-load"]').submit()
  # TODO: Put these in correct coffee files
  $("#comments_search input").change( ->
    $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script")
    false
  )
  $("#stickies_search select").change( ->
    $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), null, "script")
    false
  )
  extensionsReady()

# These functions only get called on the initial page visit (no turbolinks).
# Browsers that don't support turbolinks will initialize all functions in
# turbolinks on page load. Those that do support Turbolinks won't call these
# methods here, but instead will wait for `turbolinks:load` event to prevent
# running the functions twice.
@initialLoadReady = ->
  turbolinksReady() unless Turbolinks.supported

$(window).onbeforeunload = -> return "You haven't saved your changes." if window.$isDirty
$(document).ready(initialLoadReady)
$(document)
  .on('turbolinks:load', turbolinksReady)
  .on('turbolinks:before-visit', (event) ->
    event.preventDefault() if window.$isDirty and !confirm("You haven't saved your changes.")
  )
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
