require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # the purpose is to verify the content of the DataBase, to see if users are created or not

  def setup
    # because the deliveries array is global, we have to reset it in the setup method to prevent our code from breaking if any other tests deliver email 
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    # assert that there will be no difference in the users count before and after the test, meaning that test passed if no user is saved, because fo invalid name, mail and passowrd
    assert_no_difference 'User.count' do
      # use post function to create a new user (post user_path is equivalent to create method)
      post users_path, user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    # assert that after failing creating new user, it is redirecting to the "new" template
    assert_template 'users/new'
    # assert error messages
    # assert that you will have a div with id "error_explanation" defined in views/shared/_error_messages.html.slim
    assert_select 'div#error_explanation'
    # CSS class for field with error
    assert_select 'div.alert-danger'
  end

  test "valid signup information with account activation" do
    get signup_path
    # assert that after the test, there should be a difference of "1" between initial user count and final user count
    assert_difference 'User.count', 1 do
      # post_via_redirect arranges to follow the redirect after submission, resulting in a rendering of the ’users/show’ template
      post users_path, user: { name:  "ion neculce",
                               email: "Ion@Email.COM",
                               password:              "password",
                               password_confirmation: "password" }

    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token and mail
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!

    assert_template 'users/show'
    # assert that after user creation and activation is automatically logged in
    # is_logged_in? method is defined in the test_helper.rb
    assert is_logged_in?

  end

end
