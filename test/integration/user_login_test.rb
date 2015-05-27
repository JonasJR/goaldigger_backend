require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:jerry)
  end

  test "login with invalid username/password should generate error message" do
    @user.name = ""
    @user.password = ""

    post '/api/v1/login'
    assert_not json_response['success']
    assert_equal json_response['message'], 'Invalid username or password'
  end

  test "login with correct username/password" do
    @user.save
    post '/api/v1/login', { email: @user.email, password: 'nisse123' }
    assert json_response['success']
  end

  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
