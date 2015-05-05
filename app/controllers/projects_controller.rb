class ProjectsController < ApplicationController
  def new
  end

  def index
    user = User.find(session[:user_id])
    @projects = user.projects
  end

  def show
  end
end
