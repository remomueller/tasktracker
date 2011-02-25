module ApplicationHelper

  def cancel
    link_to image_tag('icons/cross.png', :alt => '') + 'cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), :class => 'button negative'
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time
    seconds_ago = (Time.now - past_time)
    if seconds_ago < 60.minute then "<span style='color:#6DD1EC;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.minute).to_i, 'minute')} ago </span>".html_safe
    elsif seconds_ago < 1.day then "<span style='color:#ADDD1E;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.hour).to_i, 'hour')} ago </span>".html_safe
    elsif seconds_ago < 2.day then "<span style='color:#CEDC34;font-weight:bold;font-variant:small-caps;'>yesterday </span>".html_safe
    elsif seconds_ago < 1.week then "<span style='color:#CEDC34;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.day).to_i, 'day')} ago </span>".html_safe
    elsif seconds_ago < 1.month then "<span style='color:#DCAA24;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.week).to_i, 'week')} ago </span>".html_safe
    elsif seconds_ago < 1.year then "<span style='color:#C2692A;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.month).to_i, 'month')} ago </span>".html_safe
    else "<span style='color:#AA2D2F;font-weight:bold;font-variant:small-caps;'>#{pluralize((seconds_ago/1.year).to_i, 'year')} ago </span>".html_safe
    end
  end

end
