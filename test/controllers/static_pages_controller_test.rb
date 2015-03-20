require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  # assert that a link "home" is available
  test "should get home" do
    get :home
    assert_response :success
    # asesert that the page has a HTML tag <title>, taht contains the value "Home...."
    assert_select "title", "Ruby on Rails Tutorial Sample App"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | Ruby on Rails Tutorial Sample App"
  end

  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "About | Ruby on Rails Tutorial Sample App"
  end

end
