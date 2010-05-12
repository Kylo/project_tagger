require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < ActionController::TestCase
  fixtures :all
  
  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_tag_index_for_user
    @request.session[:user_id] = 2
    get :index
    assert_response 403
  end

  def test_tag_index_for_admin
    @request.session[:user_id] = 1
    get :index
    assert_response :success
    tags = Tag.all.to_a.map(&:name)
    assert_select 'ul#tag-list' do
      assert_select 'li.tag', Tag.count
      tags.each do |tag|
        assert_select 'span.tag-name', tag
      end
    end
  end

  def test_show_tag_for_user
    @request.session[:user_id] = 2
    get :show, :id => 1
    assert_response 403
  end

  def test_show_tag_for_admin
    @request.session[:user_id] = 1
    get :show, :id => 1
    assert_response :success
    tag = Tag.find(1)
    assert_select 'h2', Regexp.new(tag.name)
    assert_select 'ul.projects.root' do
      assert_select 'li', tag.projects.count
      tag.projects.each do |project|
        assert_select "a[href~=/projects/#{project.identifier}]", project.name
      end
    end
  end
end
