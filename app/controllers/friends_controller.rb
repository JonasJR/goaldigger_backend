class FriendsController < ApplicationController

  before_action :check_logged_in, except: [:signup, :login, :reset_password, :search_friends]
  before_action :set_default_response_format

  def search_friends
    search_phrase = params[:search_phrase]
    users = User.select(:name, :email).where("name like ? or email like ?", search_phrase, search_phrase)

    render text: users.to_json
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
