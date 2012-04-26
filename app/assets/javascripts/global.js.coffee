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

@toggleSticky = (element) ->
  $(element).toggle()
  $(element+'_short_description').toggle()
  $(element+'_description').toggle('slide', { direction: 'up' })

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
