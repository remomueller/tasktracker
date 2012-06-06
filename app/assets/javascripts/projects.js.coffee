# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    .on('click', '[data-object~="modal-show"]', () ->
      $('#sticky_project_id').val($(this).data('project-id'))
      $('#sticky_project_id').change()
      $($(this).data('target')).modal({ dynamic: true })
      false
    )
    .on('click', '[data-object~="frames-previous"]', () ->
      decreaseSelectedIndex('#frame_id', '#frame_name')
      false
    )
    .on('click', '[data-object~="frames-next"]', () ->
      increaseSelectedIndex('#frame_id', '#frame_name')
      false
    )
