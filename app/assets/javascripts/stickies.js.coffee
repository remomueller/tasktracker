jQuery ->
  $(document)
    .on('click', '.last-month', () -> goBackOneMonth())
    .on('click', '.next-month', () -> goForwardOneMonth())
    .keydown( (e) ->
      if $("input, select, textarea").is(":focus")
        return
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

# @goBackOneYear = () -> 
#   year_selector = $('#year')
#   year_selector.val(year_selector.val() - 1)
#   $('#direction').val(-1)
#   year_selector.change()
# 
# @goForwardOneYear = () ->
#   year_selector = $('#year')
#   num_years = $(year_selector).find('option').size()
#   if parseInt(year_selector.val()) != num_years - 1
#     year_selector.val(parseInt(year_selector.val()) + 1)
#     $('#direction').val(1)
#     year_selector.change()

@goBackOneMonth = () ->
  now = new Date $('#selected_date').val()
  new_month = new Date 1900+now.getYear(), now.getMonth()-1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#direction').val(-1)
  $('#selected_date').change()

@goForwardOneMonth = () ->
  now = new Date $('#selected_date').val()
  new_month = new Date 1900+now.getYear(), now.getMonth()+1, 1
  $('#selected_date').val((new_month.getMonth() + 1) + "/" + new_month.getDate() + "/" + new_month.getFullYear())
  $('#direction').val(1)
  $('#selected_date').change()
  

# @goBackOneMonth = () ->
#   month_selector = $("#month")
#   year_selector = $("#year")
#   if month_selector.val() == '1'
#     if year_selector.val() != '1'
#       month_selector.val('12')
#       year_selector.val(year_selector.val() - 1)
#   else
#     month_selector.val(month_selector.val() - 1)
#   $('#direction').val(-1)
#   month_selector.change()
# 
# @goForwardOneMonth = () ->
#   month_selector = $('#month')
#   year_selector = $('#year')
#   num_years = $(year_selector).find('option').size()
#   if month_selector.val() == '12'
#     if year_selector.val() != num_years - 1
#       month_selector.val('1')
#       year_selector.val(parseInt(year_selector.val()) + 1)
#   else
#     month_selector.val(parseInt(month_selector.val()) + 1)
#   $('#direction').val(1)
#   month_selector.change()

@goToCurrentMonth = () ->
  month_selector = $('#month')
  year_selector = $('#year')
  today = new Date()
  month_selector.attr('selectedIndex', today.getMonth())
  available_years = new Array()
  available_years.push(item.value) for item in year_selector.options
  year_selector.attr('selectedIndex', available_years.indexOf(today.getFullYear().toString(10)))
  $('#direction').val(0)