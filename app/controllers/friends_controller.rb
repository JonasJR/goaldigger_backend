class FriendsController < ApplicationController

  before_action :check_logged_in
  before_action :set_default_response_format

  def create
    friend = User.find_by(email: params[:friend_email])
    @friendship = @user.friendships.build(:friend_id => friend.id)

    if @friendship.save
      response = { success: true, message: "Friend #{friend.name} added" }
    else
      response = { success: false, message: "Could not add friend" }
    end
    render json: response
  end

  def index
    friends = @user.friends
    response = []

    friends.each do |friend|
      response << { id: friend.id, name: friend.name, email: friend.email }
    end
    render json: response
  end

  def search
    search_phrase = params[:search_phrase]
    users = User.select(:id, :name, :email).where("lower(name) LIKE ? OR lower(email) LIKE ?", "%#{search_phrase}%", "%#{search_phrase}%")

    return_list = []
    users.each do |friend|
      return_list << friend unless (@user.friends.include? friend) or friend == @user
    end

    render json: return_list
  end

  private

    def user_params
      params.permit(:name, :email, :password, :password_confirmation)
    end

    def check_logged_in
      user = User.find_by(email: params[:email])

      if user && user.authenticate(params[:password])
        @user = user
      else
        render json: "Please log in first"
      end
    end

    def set_default_response_format
      request.format = :json
    end
end
