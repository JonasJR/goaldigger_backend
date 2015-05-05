require 'test_helper'

class JsonsControllerTest < ActionController::TestCase

  test "should be able to login" do
    post :login, params: { email: "jerry.ck.pedersen@gmail.com", password: "nisse123" } 
    assert_response :success
  end

end

