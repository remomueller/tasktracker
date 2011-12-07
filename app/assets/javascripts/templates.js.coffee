jQuery ->
  $( "#dialog-form" ).dialog(
    autoOpen: false
    height: 310
    width: 520
    modal: true
    buttons:
      "Create Stickies": () ->
        $('#template_frame_form').submit()
        $( this ).dialog( "close" )
      Cancel: () ->
        $( this ).dialog( "close" )
  )
    
  $( "#generate-stickies" )
    # .button()
    .click( () ->
      $( "#dialog-form" ).dialog( "open" )
  )
  
  $('#template_project_id').change( () ->
    $.post(root_url + 'templates/items', $("form").serialize() + "&_method=post", null, "script")
    false
  )
  
  $('#add_more_items').click( () ->
    $.post(root_url + 'templates/add_item', $("form").serialize() + "&_method=post", null, "script")
    false
  )