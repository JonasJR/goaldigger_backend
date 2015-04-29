require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  test "should get search_friends" do
    get :search_friends
    assert_response :success
  end

end
