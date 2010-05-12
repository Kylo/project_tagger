require 'redmine'

require_dependency 'project_patch'

Redmine::Plugin.register :project_tagger do
  name 'ProjectTagger'
  author 'Krzysztof Kuźnik, Szymon Depta'
  description 'Plugin provides tagging for Redmine projects'
  version 'prototype'

  menu :admin_menu, :tags, { :controller => 'tags', :action => 'index' }, :caption => :tags_name
end

class TagField < Redmine::Hook::ViewListener
  render_on :view_projects_form, :partial => "tags/tag_field"
end

class ProjectTags < Redmine::Hook::ViewListener
  render_on :view_projects_show_right, :partial => "tags/project_tags"
end

class TagsCSS < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, :partial => "tags/css_header"
end