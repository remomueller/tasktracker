jQuery ->
  $('#template_project_id').change( () ->
    $.post(root_url + 'templates/items', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_items').click( () ->
    $.post(root_url + 'templates/add_item', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $(document).on('change', '#group_template_id', () ->
    $.post(root_url + 'templates/selection', $("#group_template_id").serialize(), null, "script")
    false
  )

  $('#items_container[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $(document)
    .on('click', '[data-object~="expand-item-details"]', () ->
      $('[data-object~="' + $(this).data('selector') + '"]').hide()
      $($(this).data('target')).show()
    )
    .on('click', '[data-object~="noclickbubble"]', (event) ->
      event.cancelBubble = true
      event.stopPropagation() if event.stopPropagation
      false
    )
