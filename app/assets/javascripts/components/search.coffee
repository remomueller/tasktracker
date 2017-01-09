$(document)
  .on('click', '[data-object~="show-search-bar"]', ->
    $('.tiny-search-icon').hide()
    $('.full-search-bar').show()
    setFocusToField('#navigation-search')
    false
  )
  .on('mousedown', '#navigation-form-search-btn', ->
    $('#navigation-search-form').submit() unless $('#navigation-search').val() == ''
    false
  )
  .on('blur', '#navigation-search-form', (e) ->
    $('.full-search-bar').hide()
    $('.tiny-search-icon').show()
  )
