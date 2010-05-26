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

  def test_delete_tag
    @request.session[:user_id] = 1
    get :show, :id => 1
    assert_response :success
    assert_select 'div#wrapper div#main div#content a[href=/tags/delete/1]'
    get :delete, :id => 1
    assert_raise(ActiveRecord::RecordNotFound) {Tag.find 1}
  end

  def test_edit_tag_for_user
    @request.session[:user_id] = 2
    get :edit, :id => Tag.find(1)
    assert_response 403
  end

  def test_edit_tag_for_admin
    @request.session[:user_id] = 1
    t = Tag.find(1)
    get :edit, :id => t
    assert_response :success
    assert_select "label[for=tag_name]"
    assert_select "input[type=text][value=#{t.name}]"
    assert_select "input[type=submit][value=Save]"
  end

  def test_tag_update_must_be_post
    @request.session[:user_id] = 1
    t = Tag.find(1)
    get :update, :id => t
    assert_response 404
  end

  def test_successful_tag_update
    @request.session[:user_id] = 1
    t = Tag.find(1)
    assert_no_difference('Tag.count') {
      post :update, :id => t, :tag => { :id => t.id, :name => t.name+"_new" }
    }
    assert_redirected_to :action => "show", :id => t
    assert_equal('Tag successfully updated', flash[:notice])
  end

  def test_unsuccessful_tag_update
    @request.session[:user_id] = 1
    t = Tag.find(1)
    assert_no_difference('Tag.count') {
      post :update, :id => t, :tag => { :id => t.id, :name => "" }
    }
    assert_template 'edit'
    assert_select 'div#errorExplanation'
  end

  def test_successful_tag_merge
    @request.session[:user_id] = 1
    t = Tag.find(1)
    assert_difference('Tag.count',-1) {
      post :update, :id => t, :tag => { :id => t.id, :name => Tag.find(2).name }
    }
    assert_redirected_to :action => "show", :id => Tag.find(2)
    assert_equal('Tag successfully updated', flash[:notice])
  end

  def test_autocomplete_get
    get :complete_tags
    assert_response 404
  end

  def test_autocomplete_post
    post :complete_tags, :tag => 'ja'
    assert_response :success
    assert_select 'ul', 1
    assert_select 'li', 1
    assert_select 'ul li span.value', 'Java'
    assert_select 'ul li span.informal', 'Projects: 2'
  end

  def test_autocomplete_special_chars
    post :complete_tags, :tag => '++'
    assert_response :success
  end
end
