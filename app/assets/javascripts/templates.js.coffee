@templateSelected = () ->
  parseInt($('#template_id').val()) > 0

@deselectTemplate = () ->
  $('#template_id').val('none')
  $('[data-object~="template-select"]').removeClass('active')

@selectTemplate = (template_id) ->
  template = $('[data-object~="template-select"][data-template-id='+template_id+']')

  $('#board_id').val('none')
  $('[data-object~="board-select"]').removeClass('active')

  $('#tag_ids').val('')
  $('[data-object~="tag-select"]').removeClass('active')

  $('[data-object~="template-select"]').removeClass('active')
  $(template).addClass('active')
  $('#template_id').val(template_id)
  true

@templatesReady = () ->
  $('#items_container[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

$(document)
  .on('change', '#template_project_id', () ->
    $.post(root_url + 'templates/items', $("form").serialize() + "&_method=post", null, "script")
    false
  )
  .on('click', '#add_more_items', () ->
    $.post(root_url + 'templates/add_item', $("form").serialize() + "&_method=post", null, "script")
    false
  )
  .on('change', '#group_template_id', () ->
    $.post(root_url + 'templates/selection', $("#group_template_id").serialize(), null, "script")
    false
  )
  .on('click', '[data-object~="expand-item-details"]', () ->
    $('[data-object~="' + $(this).data('selector') + '"]').hide()
    $($(this).data('target')).show()
  )
  .on('click', '[data-object~="noclickbubble"]', (event) ->
    event.cancelBubble = true
    event.stopPropagation() if event.stopPropagation
    false
  )
  .on('click', '[data-object~="template-select"]', (e) ->
    return true if nonStandardClick(e)

    url = $(this).attr("href")

    if $('#template_id').val().toString() == $(this).data('template-id').toString()
      selectTemplate($(this).data('template-id'))
      $("#groups_search").submit()
    else
      selectTemplate($(this).data('template-id'))

      $.get($("#groups_search").attr("action"), $("#groups_search").serialize(), ((data) ->
        if browserSupportsPushState
          history.pushState({ page:url, tasktracker: true, template_id: $('#template_id').val() }, null, url)
      ), "script")
    false
  )
