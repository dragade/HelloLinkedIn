require 'test_helper'

class LinkedInControllerTest < ActionController::TestCase
  test "should get intro" do
    get :intro
    assert_response :success
  end

  test "should get profile" do
    get :profile
    assert_response :success
  end

  test "should get apicall" do
    get :apicall
    assert_response :success
  end

end
