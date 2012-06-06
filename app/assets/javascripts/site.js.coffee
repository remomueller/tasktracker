jQuery ->
  # $(".datepicker").datepicker
  #   showOtherMonths: true
  #   selectOtherMonths: true
  #   changeMonth: true
  #   changeYear: true

  # $("#ui-datepicker-div").hide()

  # $(".pagination a, .page a, .next a, .prev a").live("click", () ->
  #   return false if $(this).parent().is('.active, .disabled, .per_page')
  #   $.get(this.href, null, null, "script")
  #   false
  # )

  # $(".per_page a").live("click", () ->
  #   object_class = $(this).data('object')
  #   # showWaiting(this, '', false)
  #   $.get($("#"+object_class+"_search").attr("action"), $("#"+object_class+"_search").serialize() + "&"+object_class+"_per_page="+ $(this).data('count'), null, "script")
  #   false
  # )

  $("#comments_search input").change( () ->
    $.get($("#comments_search").attr("action"), $("#comments_search").serialize(), null, "script")
    false
  )

  $("#stickies_search select").change( () ->
    $.get($("#stickies_search").attr("action"), $("#stickies_search").serialize(), null, "script")
    false
  )

  $("#sticky_project_id").change( () ->
    $.post(root_url + 'projects/selection', $("#sticky_project_id").serialize(), null, "script")
    false
  )

  $(document).keydown( (e) ->
    if $("input, textarea").is(":focus") then return
    if e.which == 37
      decreaseSelectedIndex('#frame_id', '#frame_name');
    if e.which == 39
      increaseSelectedIndex('#frame_id', '#frame_name');
  )
