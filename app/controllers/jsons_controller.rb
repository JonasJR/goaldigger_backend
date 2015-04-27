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

  def toggle_item_done
    item = Item.find(params[:item_id])

    item.done = !item.done
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

  def add_item
    item_hash = { name: params[:item_name], project_id: params[:project_id], 
                  milestone_id: params[:milestone_id], user_id: @user.id }
    item = Item.new(item_hash)

    if item.save
      response = { success: true }
    else
      response = { success: false, message: item.errors.full_messages }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end 
  end

  def delete_item
    item = Item.find(params[:id])

    if item.user_id == @user.id && item.delete
      response = { success: true }
    else
      response = { success: false, message: item.errors.full_messages }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end 
  end

  def add_milestone
    project_id = params[:project_id]
    milestone_hash = { name: params[:milestone_name], project_id: project_id, }
    milestone = @user.projects.find(project_id).milestones.new(milestone_hash)

    if milestone.save
      response = { success: true }
    else
      response = { success: false, message: milestone.errors.full_messages }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end 
  end

  def delete_milestone
    milestone_id = params[:milestone_id]
    project_id = params[:project_id]

    if @user.projects.find(project_id).milestones.find(milestone_id).delete
      response = { success: true }
    else
      response = { success: false, message: milestone.errors.full_messages }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
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
            itemList << { id: item.id, name: item.name, done: item.done }
          end

          milestoneList << { id: milestone.id, name: milestone.name, items: itemList }

        end
        itemList = []
        project.items.all.each do |item|
          itemList << { id: item.id, name: item.name, done: item.done }
        end
        projectList << { id: project.id, name: project.name, description: project.description, items: itemList, milestones: milestoneList }
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
