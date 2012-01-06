# Global functions referenced from HTML
@increaseSelectedIndex = (element) ->
  element = $(element)
  num_options = element.find('option').size()
  if element.prop('selectedIndex') <= 0
    return false
  else
    element.prop('selectedIndex', element.prop('selectedIndex') - 1)
    $('#direction').val(1)
    element.change()

@decreaseSelectedIndex = (element) ->
  element = $(element)
  num_options = element.find('option').size()
  if element.prop('selectedIndex') < num_options - 1
    element.prop('selectedIndex', element.prop('selectedIndex') + 1)
    $('#direction').val(-1)
    element.change()
  else
    return false

@toggleSticky = (element) ->
  $(element).toggle()
  $(element+'_description').toggleClass('collapsed')
  if $(element+'_link').html() == 'more...'
    $(element+'_link').html('less...')
  else if $(element+'_link').html() == 'less...'
    $(element+'_link').html('more...')

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
