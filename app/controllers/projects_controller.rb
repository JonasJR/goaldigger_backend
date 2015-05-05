class ProjectsController < ApplicationController
  def new
    @user = User.find(session[:user_id])
    @project = @user.projects.new
  end

  def create
    user = User.find(session[:user_id])
    project = user.projects.new(project_params)

    if project.save
      redirect_to user_projects_path(user)
    else
      rener :new
    end
  end

  def index
    @user = User.find(session[:user_id])
    @projects = @user.projects
  end

  def show
    @user = User.find(session[:user_id])
    @project = Project.find(params[:id])
    @milestones = @project.milestones
    #@milestone = @project.milestones.new
  end

  private
    def project_params
      params.require(:project).permit(:name, :description)
    end
end
