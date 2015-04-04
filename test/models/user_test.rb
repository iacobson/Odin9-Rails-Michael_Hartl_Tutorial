require 'test_helper'

class UserTest < ActiveSupport::TestCase

  #define a generic valid @user
  def setup
    @user = User.new(name: "Example User", email: "user@example.com", password: "password", password_confirmation: "password")
  end

  # test initial @user validity
  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
	  # if name is blank
    @user.name = "     "
    # pass the test if @user is NOT VALID
    assert_not @user.valid?
  end

  test "email should be present" do
    # if name is blank
    @user.email = "     "
    # pass the test if @user is NOT VALID
    assert_not @user.valid?
  end

  test "name should be less than 50 characters" do
    @user.name = "a" * 51
    # fail if 51 chars
    assert_not @user.valid?
  end

  test "email should be less than 255 characters" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  # test email validation with some valid addresses
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # assert with custom error message
      # .inspect method returns a string with a literal representation of the object it’s called on
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # test email validation with some invalid addresses
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  # assert uniqueness of e-mail address
  test "email addresses should be unique" do
    # create a duplicated user
    duplicate_user = @user.dup
    # test that is not affected by letter case
    duplicate_user.email = @user.email.upcase
    # initial user created in setup method, must be saved, so the e-mail will be already in the DB
    @user.save
    assert_not duplicate_user.valid?
  end

  # assert if the e-mails are saved in the database as lower-case
  test "email addresses should be saved as lower-case" do
    #test with mix case
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    # assert if mail provided converted to downcase is equal (==) to the email saved and reloaded from the database (.reload)
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # password should be minimum 6 characters
  test "password should have a minimum length" do
    # multiple assignment a = b = c
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

end
