require File.dirname(__FILE__) + '/../test_helper'

class ProjectsControllerTest < ActionController::TestCase
  fixtures :projects, :versions, :users, :roles, :members, :member_roles, :issues, :journals, :journal_details,
    :trackers, :projects_trackers, :issue_statuses, :enabled_modules, :enumerations, :boards, :messages,
    :attachments, :custom_fields, :custom_values, :time_entries

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_should_see_tag_field_in_project_form
    @request.session[:user_id] = 1

    get :add
    assert_response :success
    assert_select 'label[for=project_tag_list]', 'Tags'
    assert_select 'input[id=project_tag_list][size=60]', ''
  end

  def test_project_tag_list_empty
    @request.session[:user_id] = 1

    p=Project.find(1)
    p.tag_list='Java, C++'
    assert p.save
    get :settings, :id => p
    assert_response :success
    assert_select 'label[for=project_tag_list]', 'Tags'
    assert_select 'input[id=project_tag_list][size=60][value="Java, C++"]'
  end

  def test_cloud_no_tags
    Tag.destroy(Tag.all)
    @request.session[:user_id] = 1
    get :index
    assert_select 'div#wrapper div#main div#content div#tags-cloud', 'No tags to show'
  end
end
