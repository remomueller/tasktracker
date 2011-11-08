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