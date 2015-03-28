require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    # users is the fixtures name (users.yml) and :dorian is defined inside
    @user = users(:dorian)
  end

  # test the login with invalid user info
  test "login with invalid information" do
    # Visit the login path
    get login_path
    # Verify that the new sessions form renders properly
    assert_template 'sessions/new'
    # Post to the sessions path with an invalid params hash
    post login_path, session: { email: "aaa@bb.cc", password: "abx" }
    # Verify that the new sessions form gets re-rendered and that a flash message appears
    assert_template 'sessions/new'
    assert_not flash.empty?, "Does not display error flash message on invalid login"
    # Visit another page (such as the Home page)
    get root_path
    # Verify that the flash message DOESN'T appear on the new page
    assert flash.empty?, "Flash message incorrectly appears also on home page"
  end

  # test the login with the valid @user defined above, then test the logout
  test "login with valid information" do
    # Visit the login path
    get login_path
    # Post to the sessions path with valid parameters
    post login_path, session: { email: @user.email, password: 'password' }
    # is_logged_in? method is defined in the test_helper.rb
    assert is_logged_in?
    # Check the right redirect target
    assert_redirected_to @user
    # Visit the redirect
    follow_redirect!
    # Verify that the user page renders properly
    assert_template 'users/show'
    # assert that the login button disappears (count: 0)
    assert_select "a[href=?]", login_path, count: 0
    # assert the logout link
    assert_select "a[href=?]", logout_path
    # assert the profile link
    assert_select "a[href=?]", user_path(@user)

    # test also logout
    # delete action (rest, method: "delete")
    delete logout_path
    # is_logged_in? method is defined in the test_helper.rb
    assert_not is_logged_in?
    # assert if after logout redirects to home
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    # go to home
    follow_redirect!
    # assert that there is a login link/button
    assert_select "a[href=?]", login_path
    # assert that logout disappeared
    assert_select "a[href=?]", logout_path,      count: 0
    # assert that user page disappeared
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_nil cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end

end
