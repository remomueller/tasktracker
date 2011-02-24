module ApplicationHelper

  def cancel
    link_to image_tag('icons/cross.png', :alt => '') + 'cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), :class => 'button negative'
  end

end
