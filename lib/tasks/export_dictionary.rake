desc 'Export a dictionary CSV of the Project, Tags, and Users.'
task :export_dictionary => :environment do
  time_stamp = Time.now.strftime("%Y%m%d %Ih%M%p")
  @dictionary_export_file = "tmp/#{DEFAULT_APP_NAME.downcase.gsub(/[^\da-zAz]/, '_')}_dictionary_import_#{time_stamp}.csv"
  CSV.open(@dictionary_export_file, "wb") do |csv|
    csv << ["#URI", "Namespace", "Short Name", "Description", "Concept Type", "Units", "Terms", "Internal Terms", "Parents", "Children", "Equivalent Concepts", "Similar Concepts", "Field Values", "Sensitivity", "Display Name", "Commonly Used", "Folder", "Calculation", "Source Name", "Source File", "Source Description"]
    uri = SITE_URL
    namespace = "notes"

    csv << [uri, namespace, 'sticky_id', 'Task', 'identifier', '', 'study_id', 'id', '', '', '', '', '', 0, "Task", 1, "Tasks"]
    csv << [uri, namespace, 'sticky_status', 'Task Completed', 'boolean', '', 'completed', 'completed', '', '', '', '', '', 0, "Task Completed", 1, "Tasks"]
    csv << [uri, namespace, 'project_id', 'Project', 'categorical', '', 'project_id', 'project_id', '', '', '', '', '', 0, "Project", 1, "Tasks"]
    csv << [uri, namespace, 'tag_id', 'Tag', 'categorical', '', 'tag_id', 'tag_id', '', '', '', '', '', 0, "Tag", 1, "Tasks"]
    csv << [uri, namespace, 'due_date', 'Task Due Date', 'datetime', '', 'due_date', 'due_date', '', '', '', '', '', 0, "Task Due Date", 1, "Tasks"]
    csv << [uri, namespace, 'owner_id', 'Assigned To', 'categorical', '', 'owner_id', 'owner_id', '', '', '', '', '', 0, "Assigned To", 1, "Tasks"]
    csv << [uri, namespace, 'sticky_deleted', 'Task Deleted', 'boolean', '', 'deleted', 'deleted', '', '', '', '', '', 0, "Task Deleted", 1, "Tasks"]

    Tag.all.group_by(&:name).each do |tag_name, tags|
      csv << [uri, namespace, "tag_#{tags.first.id}", tag_name, 'boolean', '', tag_name, tags.collect{|t| t.id}.join('; '), '#tag_id', '', '', '', '', 0, tag_name, 0]
    end

    User.current.each do |user|
      csv << [uri, namespace, "user_#{user.id}", user.name, 'boolean', '', user.name, user.id, '#owner_id', '', '', '', '', 0, user.name, 0]
    end

    Project.current.each do |project|
      csv << [uri, namespace, "project_#{project.id}", project.name, 'boolean', '', project.name, project.id, '#project_id', '', '', '', '', 0, project.name, 0]
    end

  end

end
