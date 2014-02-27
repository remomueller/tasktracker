# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document)
  .on('click', '[data-object~="group-select"]', (e) ->
    return true if nonStandardClick(e)
    $('[data-object~="group-select"]').removeClass('active')
    $(this).addClass('active')
    url = $(this).attr("href")
    $.get(url, null, null, "script")
    false
  )
