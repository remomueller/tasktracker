jQuery ->
  $( "#dialog-form" ).dialog(
    autoOpen: false
    height: 190
    width: 350
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