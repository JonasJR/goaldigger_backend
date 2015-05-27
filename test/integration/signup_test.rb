require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    assert_no_difference 'User.count' do
      post '/api/v1/signup', { email: 'be',
                               password: '',
                               password_confirmatin: ''}

      assert_not json_response['success']
      assert json_response['errors'].length > 0
    end
  end

  test "valid signup information" do
    assert_difference 'User.count', 1 do
      post '/api/v1/signup', { name: 'Jerry Example',
                               email: 'jerry@example.com',
                               password: 'nisse123',
                               password_confirmation: 'nisse123'}
    end

    assert json_response['success']
  end

  def json_response
    ActiveSupport::JSON.decode @response.body
  end
end
