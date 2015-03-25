require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # the purpose is to verify the content of the DataBase, to see if users are created or not

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
  end

  test "valid signup information" do
    get signup_path
    # assert that after the test, there should be a difference of "1" between initial user count and final user count
    assert_difference 'User.count', 1 do
      # post_via_redirect arranges to follow the redirect after submission, resulting in a rendering of the ’users/show’ template
      post_via_redirect users_path, user: { name:  "ion neculce",
                               email: "Ion@Email.COM",
                               password:              "password",
                               password_confirmation: "password" }

    end
    assert_template 'users/show'
  end


end
