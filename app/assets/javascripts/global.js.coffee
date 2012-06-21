# Global functions referenced from HTML
@increaseSelectedIndex = (element, el_out) ->
  element = $(element)
  num_options = element.find('option').size()
  if element.prop('selectedIndex') <= 0
    return false
  else
    element.prop('selectedIndex', element.prop('selectedIndex') - 1)
    $(el_out).html($(element).find('option:selected').text() + " <span class='caret'></span>")
    $('#direction').val(1)
    element.change()

@decreaseSelectedIndex = (element, el_out) ->
  element = $(element)
  num_options = element.find('option').size()
  if element.prop('selectedIndex') < num_options - 1
    element.prop('selectedIndex', element.prop('selectedIndex') + 1)
    $(el_out).html($(element).find('option:selected').text() + " <span class='caret'></span>")
    $('#direction').val(-1)
    element.change()
  else
    return false

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

jQuery ->
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
    $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize() + "&" + $("#sticky_frame_id").serialize(), null, "script")
    false
  )

  $(document).keydown( (e) ->
    if $("input, textarea").is(":focus") then return
    if e.which == 37
      decreaseSelectedIndex('#frame_id', '#frame_name');
    if e.which == 39
      increaseSelectedIndex('#frame_id', '#frame_name');
  )
