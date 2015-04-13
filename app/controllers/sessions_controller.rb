class SessionsController < ApplicationController

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      flash[:success] = 'User logged in'
      session[:user_id] = user.id
      redirect_to user_path(user)
    else
      flash[:danger] = 'Invalid email/password combination' # Not quite right!
      render :new
    end
  end

  def destroy
  end

  private

end
