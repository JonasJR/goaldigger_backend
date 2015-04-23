class JsonsController < ApplicationController

  before_action :check_logged_in, except: [:signup, :login]

  def login
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)

    if (user && user.authenticate(password))
      response = {name: user.name, email: email, success: true}
    else
      response = {message: "Invalid username or password", success: false}
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end
  end

  def signup
    user = User.new(user_params)

    if user.save
      response = {}
      response[:name] = user.name
      response[:email] = user.email
      response = response.to_json
    else
      response = user.errors.to_json
    end
    respond_to do |format|
      format.json { render text: response }
    end
  end

  def add_project
    project_name = { name: params[:project_name] }
    
    if @user.projects.create(project_name)
      response = { success: true }
    else
      response = { success: false, message: @user.projects.errors.full_messages }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end 
  end

  def delete_project
    if @user.projects.delete(params[:id])
      response = { success: true }
    else
      response = { success: false, message: "Project not found" }
    end
    respond_to do |format|
      format.json { render text: response.to_json }
    end 
  end

  def projects
    respond_to do |format|
      format.json { render text: render_projects.to_json }
    end
  end

  private 
    
    def render_projects
      projects = @user.projects.all

      projectList = []
      projects.each do |project|
        milestoneList = []

        project.milestones.all.each do |milestone|
          itemList = []

          milestone.items.all.each do |item|
            itemList << { id: item.id, name: item.name }
          end

          milestoneList << { id: milestone.id, name: milestone.name, items: itemList }

        end

        projectList << { id: project.id, name: project.name, description: project.description, milestones: milestoneList }
      end
      projectList
    end

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
end
