jQuery ->
  $(document)
    .on('click', '.last-month', () -> goBackOneMonth())
    .on('click', '.next-month', () -> goForwardOneMonth())
    .keydown( (e) ->
      if $("input, textarea").is(":focus") then return
      if e.which == 37
        goBackOneMonth()
      if e.which == 39
        goForwardOneMonth()
    )
  
  $("#sticky_calendar_form")
    .on("change", (event) -> 
      $.get($("#sticky_calendar_form").attr("action"), $("#sticky_calendar_form").serialize(), null, "script")
    )
  
  $.get($("#sticky_calendar_form").attr("action"), $("#sticky_calendar_form").serialize(), null, "script");

@goBackOneMonth = () ->
  now = new Date $('#selected_date').val()
  now = new Date() if isNaN(now.getFullYear())
  new_month = new Date 1900+now.getYear(), now.getMonth()-1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#direction').val(-1)
  $('#selected_date').change()

@goForwardOneMonth = () ->
  now = new Date $('#selected_date').val()
  now = new Date() if isNaN(now.getFullYear())
  new_month = new Date 1900+now.getYear(), now.getMonth()+1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#direction').val(1)
  $('#selected_date').change()

@getToday = () ->
  now = new Date()
  $('#selected_date').val((now.getMonth() + 1) + "/" + now.getDate() + "/" + now.getFullYear())
  $('#direction').val(0)
  $('#selected_date').change()