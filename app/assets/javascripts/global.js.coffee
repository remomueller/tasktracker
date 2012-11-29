# Global functions referenced from HTML
@increaseSelectedIndex = (element, el_out) ->
  element = $(element)
  num_options = element.find('option').size()

  new_index = element.prop('selectedIndex') - 1
  new_index = num_options - 1 if new_index < 0

  element.prop('selectedIndex', new_index)
  $(el_out).html($(element).find('option:selected').text() + " <span class='caret'></span>")
  $('#direction').val(-1)
  element.change()

@decreaseSelectedIndex = (element, el_out) ->
  element = $(element)
  num_options = element.find('option').size()

  new_index = element.prop('selectedIndex') + 1
  new_index = 0 if new_index >= num_options

  element.prop('selectedIndex', new_index)
  $(el_out).html($(element).find('option:selected').text() + " <span class='caret'></span>")
  $('#direction').val(1)
  element.change()

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

  $("#sticky_project_id").change( () ->
    $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize() + "&" + $("#sticky_board_id").serialize(), null, "script")
    false
  )

  $(document).keydown( (e) ->
    if $("input, textarea").is(":focus") then return
    if e.which == 37
      increaseSelectedIndex('#board_id', '#board_name');
    if e.which == 39
      decreaseSelectedIndex('#board_id', '#board_name');
  )

  loadColorSelectors()

  $('#welcome-dialog').modal()
