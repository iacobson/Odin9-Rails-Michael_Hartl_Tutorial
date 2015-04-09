require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:dorian)
    @non_admin = users(:matza)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    # go to the index
    get users_path
    # assert the index template is loading
    assert_template 'users/index'
    # assert that there is a div with a class "pagination"
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      # assert that each user has a path to its show page
      assert_select 'a[href=?]', user_path(user), text: user.name
      # skip the assert if the user is the admin (if the user is the admin, there is no delete button)
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete',
                                                    method: :delete
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    # non admins users should not have the delete link available in the index
    assert_select 'a', text: 'delete', count: 0
  end

end
