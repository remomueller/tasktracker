$(document)
  .on('click', '[data-object~="group-select"]', (e) ->
    return true if nonStandardClick(e)
    $('[data-object~="group-select"]').removeClass('active')
    $(this).addClass('active')
    url = $(this).attr("href")
    $.get(url, null, null, "script")
    false
  )
