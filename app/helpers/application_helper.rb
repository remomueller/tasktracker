module ApplicationHelper

  def cancel
    link_to image_tag('contour/cross.png', :alt => '') + 'Cancel', URI.parse(request.referer.to_s).path.blank? ? root_path : (URI.parse(request.referer.to_s).path), :class => 'button negative'
  end

  def colors(index)
    # colors = ['#92A8CD', '#AA4643', '#89A54E', '#4572A7', '#80699B', '#3D96AE', '#DB843D', '#A47D7C', '#B5CA92', '#058DC7', '#50B432', '#ED561B', '#DDDF00', '#24CBE5', '#64E572', '#FF9655', '#FFF263', '#6AF9C4']
    # colors = ["#AC725E", "rgb(208, 107, 100)", "rgb(248, 58, 34)", "rgb(250, 87, 60)", "rgb(255, 117, 55)", "#FFAD46", "rgb(66, 214, 146)", "rgb(22, 167, 101)", "rgb(123, 209, 72)", "rgb(179, 220, 108)", "rgb(251, 233, 131)", "rgb(250, 209, 101)", "rgb(146, 225, 192)", "rgb(159, 225, 231)", "rgb(159, 198, 231)", "rgb(73, 134, 231)", "rgb(154, 156, 255)", "rgb(185, 154, 255)", "rgb(194, 194, 194)", "rgb(202, 189, 191)", "rgb(204, 166, 172)", "#F691B2", "rgb(205, 116, 230)", "rgb(164, 122, 226)"]
    colors = ["#4733e6", "rgb(123, 209, 72)", "#bfbf0d", "rgb(154, 156, 255)", "rgb(22, 167, 101)", "rgb(73, 134, 231)", "rgb(205, 116, 230)", "#9f33e6", "rgb(255, 117, 55)", "rgb(146, 225, 192)", "rgb(208, 107, 100)", "rgb(159, 198, 231)", "rgb(194, 194, 194)", "rgb(250, 87, 60)", "#AC725E", "rgb(204, 166, 172)", "rgb(185, 154, 255)", "rgb(248, 58, 34)", "rgb(66, 214, 146)", "#F691B2", "rgb(164, 122, 226)", "#FFAD46", "rgb(179, 220, 108)"] # "rgb(251, 233, 131)"
    colors[index % colors.size]
  end

  # Prints out '6 hours ago, Yesterday, 2 weeks ago, 5 months ago, 1 year ago'
  def recent_activity(past_time)
    return '' unless past_time.kind_of?(Time)
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

  def information(message = ' Press Enter to Search')
    "<span class=\"quiet small\">#{image_tag('contour/information.png', :alt => '', :style=>'vertical-align:text-bottom')}#{message}</span>".html_safe
  end

  def simple_date(past_date)
    return '' if past_date.blank?
    if past_date == Date.today
      'Today'
    elsif past_date == Date.today - 1.day
      'Yesterday'
    elsif past_date == Date.today + 1.day
      'Tomorrow'
    elsif past_date.year == Date.today.year
      past_date.strftime("%b %d")
    else
      past_date.strftime("%b %d, %Y")
    end
  end
  
  def simple_weekday(date)
    return '' unless date.kind_of?(Time) or date.kind_of?(Date)
    date.strftime("%A")
  end
  
  def simple_date_and_weekday(date)
    [simple_date(date), simple_weekday(date)].select{|i| not i.blank?}.join(', ')
  end
  
  def simple_time(past_time)
    return '' if past_time.blank?
    if past_time.to_date == Date.today
      past_time.strftime("at %I:%M %p")
    elsif past_time.year == Date.today.year
      past_time.strftime("on %b %d at %I:%M %p")
    else
      past_time.strftime("on %b %d, %Y at %I:%M %p")
    end
  end
  
  def display_status(status)
    result = '<table class="status-table"><tr>'
    case status when 'planned'
      result << "<td><div class=\"status_marked planned\" title=\"Planned\">P</div></td><td><div class=\"status_unmarked\" title=\"Ongoing\">O</div></td><td><div class=\"status_unmarked\" title=\"Completed\">C</div></td>"
    when 'ongoing'
      result << "<td><div class=\"status_marked planned\" title=\"Planned\">P</div></td><td><div class=\"status_marked ongoing\" title=\"Ongoing\">O</div></td><td><div class=\"status_unmarked\" title=\"Completed\">C</div></td>"
    when 'completed'
      result << "<td><div class=\"status_marked planned\" title=\"Planned\">P</div></td><td><div class=\"status_marked ongoing\" title=\"Ongoing\">O</div></td><td><div class=\"status_marked completed\" title=\"Completed\">C</div></td>"
    end
    result << '</tr></table>'
    result.html_safe
  end
  
  def display_single_status(status)
    result = '<table class="status-table"><tr>'
    case status when 'planned'
      result << "<td><div class=\"status_marked planned\" title=\"Planned\">P</div></td>"
    when 'ongoing'
      result << "<td><div class=\"status_marked ongoing\" title=\"Ongoing\">O</div></td>"
    when 'completed'
      result << "<td><div class=\"status_marked completed\" title=\"Completed\">C</div></td>"
    end
    result << '</tr></table>'
    result.html_safe
  end
  
  def sort_field_helper(order, sort_field, display_name, search_form_id  = 'search_form')
    result = ''
    if order == sort_field
      result = "<span class='selected' style='color:#DD6767;'>#{display_name} #{ link_to_function('&raquo;'.html_safe, "$('#order').val('#{sort_field} DESC');$('##{search_form_id}').submit();", :style => 'text-decoration:none')}</span>"
    elsif order == sort_field + ' DESC' or order.split(' ').first != sort_field
      result = "<span class='selected' #{'style="color:#DD6767;"' if order == sort_field + ' DESC'}>#{display_name} #{link_to_function((order == sort_field + ' DESC' ? '&laquo;'.html_safe : '&laquo;&raquo;'.html_safe), "$('#order').val('#{sort_field}');$('##{search_form_id}').submit();", :style => 'text-decoration:none')}</span>"
    end
    result
  end
  
  def draw_chart(chart_api, chart_type, values, chart_element_id, chart_params, categories)
    if chart_api == 'highcharts'
      highcharts_chart(chart_type, values, chart_element_id, chart_params, categories)
    end
  end
  
  def highcharts_chart(chart_type, values, chart_element_id, chart_params, categories)
    @values = values
    @chart_element_id = chart_element_id
    @chart_type = chart_type
    @chart_params = chart_params
    @categories = categories
    render :partial => 'charts/highcharts_chart'
  end
end
