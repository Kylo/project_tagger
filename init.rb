require 'redmine'
require 'dispatcher'
require 'project_patch'

Redmine::Plugin.register :project_tagger do
  name 'ProjectTagger'
  author 'Krzysztof Kuźnik, Szymon Depta'
  description 'Plugin provides tagging for Redmine projects'
  version '1.0'

  menu :admin_menu, :tags, { :controller => 'tags', :action => 'index' }, :caption => :tags_name
end

Dispatcher.to_prepare do
  Project.send(:include, ProjectPatch)
end


# This class is for registering partials rendered in Redmine hooks
class ProjectTaggerHooks < Redmine::Hook::ViewListener
  render_on :view_projects_form, :partial => "tags/tag_field"
  render_on :view_projects_show_right, :partial => "tags/project_tags"
  render_on :view_layouts_base_html_head, :partial => "tags/css_header"
end