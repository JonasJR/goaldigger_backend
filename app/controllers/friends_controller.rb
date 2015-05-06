class FriendsController < ApplicationController

  before_action :check_logged_in
  before_action :set_default_response_format

  def create
    friend = User.find_by(email: params[:friend_email])
    @friendship = @user.friendship.build(:friend_id => friend.id)

    if @friendship.save
      response = { success: true, message: "Friend #{friend.name} added" }
    else
      response = { success: false, message: "Could not add friend" }
    end
    render text: response.to_json
  end

  def index
    render text: @user.friends.to_json
  end

  def search
    search_phrase = params[:search_phrase]
    users = User.select(:id, :name, :email).where("lower(name) LIKE ? OR lower(email) LIKE ?", "%#{search_phrase}%", "%#{search_phrase}%")

    return_list = []
    users.each do |friend|
      return_list << friend unless @user.friends.include? friend
    end

    render text: return_list.to_json
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
        respond_to do |format|
          format.json { render text: "Please log in first".to_json }
        end
      end
    end

    def set_default_response_format
      request.format = :json
    end
end
