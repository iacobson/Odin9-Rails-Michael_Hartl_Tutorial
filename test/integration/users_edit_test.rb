require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:dorian)
  end

  test "unsuccessful edit" do
    # first log in as the user
    # log_in_as method is defined in the test_helper
    log_in_as(@user)
    # get the edit page
    get edit_user_path(@user)
    # check that the correct template is rendered
    assert_template 'users/edit'
    # use "patch" action for updating user
    patch user_path(@user), user: { name:  "",
                                    email: "a@b",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    # if you initially try to visit edit page without being logged in, after the login assert that you will be redirected to the edit not to the show page
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    # name and email will be used below to validate if they saved properly in the DB
    name = "darth vader"
    email = "vader@deathstar.info"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "" }
    # there should be a flash message after update
    assert_not flash.empty?
    # assert redirecting to the user show
    assert_redirected_to @user

    # relaod the user with information from DB
    @user.reload
    # assert if the info from the DB are the same with the ones we updated above
    assert_equal @user.name,  name
    assert_equal @user.email, email

  end


end
