@activateTagDroppables = ->
  $('[data-object~="tag-droppable"]').droppable(
    classes:
      'ui-droppable-hover': 'tag-droppable-hover'
    tolerance: "pointer"
    drop: ( event, ui ) ->
      tag_id = $(this).data('tag-id')
      project_id = $(this).data('project-id')
      sticky_id = ui['draggable'].data('sticky-id')
      $.post(root_url + 'tags/add_stickies', "project_id=#{project_id}&tag_id=#{tag_id}&sticky_ids=#{sticky_id}", null, "script")
  )

@tagsReady = ->
  activateTagDroppables()

$(document)
  .on('click', '.tag-checkbox', ->
    if $(this).children().is(':checked')
      $(this).addClass('tag-selected')
    else
      $(this).removeClass('tag-selected')
  )
