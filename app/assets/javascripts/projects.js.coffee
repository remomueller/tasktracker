# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $(document)
    .on('click', '[data-object~="modal-show"]', () ->
      $('#sticky_project_id').val($(this).data('project-id'))
      $('#group_project_id').val($(this).data('project-id'))
      $('#sticky_frame_id').val($("#frame_id").val())
      $('#group_frame_id').val($("#frame_id").val())
      $('#sticky_project_id').change()
      $('#group_project_id').change()
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
    .on('click', '[data-object~="frames-select"]', () ->
      $('#frame_name').html($(this).data('frame-name'))
      $('#frame_id').val($(this).data('frame-id'))
      $($(this).data('target')).submit()
      false
    )

  $(document).on('change', '#sticky_frame_id, #group_frame_id', () ->
    $('[data-frame-id~="' + ($(this).val() || '0') + '"]').click()
    false
  )
