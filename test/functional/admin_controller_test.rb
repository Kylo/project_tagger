require File.dirname(__FILE__) + '/../test_helper'

class AdminControllerTest < ActionController::TestCase
  fixtures :all

  def setup
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_admin_menu
    @request.session[:user_id] = 1
    get :index
    assert_response :success
    assert_select "ul li a[href=/tags]", "Tags"
  end
end
