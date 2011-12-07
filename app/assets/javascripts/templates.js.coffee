jQuery ->
  $( "#dialog-form" ).dialog(
    autoOpen: false
    height: 300
    width: 500
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
    $.post(root_url + 'templates/items', $("form").serialize(), null, "script")
    false
  )