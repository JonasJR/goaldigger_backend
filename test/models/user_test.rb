require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert tru
  # end

  def setup
    @user = User.new(name: "Jerry", email: "jerry.ck.pedersen@gmail.com",
                      password: "nisse123", password_confirmation: "nisse123")
  end

  test "user should be valid" do
    assert @user.valid?
  end

  test "create user" do
    before = User.count
    @user.save
    assert_equal before + 1, User.count
  end

  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end

  test "email should be unique" do 
    @user.save
    user = @user.dup
    assert_not user.valid?
  end
end
