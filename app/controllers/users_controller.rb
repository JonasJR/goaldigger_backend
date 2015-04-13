class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    user = User.find(session[:user_id])
    @projects = user.projects.all

    respond_to do |format|
      format.json { render text: @projects.to_json}
      format.html { render }
    end
  end
end
