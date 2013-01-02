# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@activateTagDroppables = () ->
  $('[data-object~="tag-droppable"]').droppable(
    hoverClass: "tag-droppable-hover"
    tolerance: "pointer"
    drop: ( event, ui ) ->
      tag_id = $(this).data('tag-id')
      project_id = $(this).data('project-id')
      sticky_ids = []
      $.each($('[data-object~="sticky-checkbox"]:checked'), (index, element) -> sticky_ids.push($(element).data('sticky-id')))
      $.post(root_url + 'tags/add_stickies', "project_id=#{project_id}&tag_id=#{tag_id}&sticky_ids=#{sticky_ids.join(',')}", null, "script")
  )

jQuery ->
  # $(document).on(...)

  activateTagDroppables()
