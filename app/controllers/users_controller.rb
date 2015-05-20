class UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user = User.new(user_params)

    if user.save
      flash[:success] = "User #{user.email} created, please log in"
      redirect_to login_path
    else
      render :new
    end
  end

  def index
    @users = User.all
  end

  def show
    user = User.find(session[:user_id])
    @projects = user.projects.all

    respond_to do |format|
      format.json { render json: @projects }
      format.html { render }
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :name, :password, :password_confirmation)
    end
end
