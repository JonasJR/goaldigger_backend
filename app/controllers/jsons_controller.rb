class JsonsController < ApplicationController

  before_action :check_logged_in, except: [:signup, :login, :reset_password]
  before_action :set_default_response_format

  include ApplicationHelper

  def login
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)

    if (user && user.authenticate(password))
      render text: {name: user.name, email: email, success: true}.to_json
    else
      render text: {message: "Invalid username or password", success: false}.to_json
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

  def toggle_item
    item = Item.find(params[:item_id])

    item.done = !item.done
    item.save

    respond_to do |format|
      format.json { render text: "Done: #{item.done}".to_json }
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
    render text: render_projects(@user).to_json
  end

  def add_item
    item_hash = { name: params[:item_name], milestone_id: params[:milestone_id], user_id: @user.id }
    item = Item.new(item_hash)

    if item.save
      response = { success: true, item_name: item.name, item_id: item.id }
    else
      response = { success: false, message: item.errors.full_messages }
    end
    render text: response.to_json
  end

  def delete_item
    item = Item.find(params[:item_id])

    if item.user_id == @user.id && item.delete
      response = { success: true }
    else
      response = { success: false, message: item.errors.full_messages }
    end

    render text: response.to_json
  end

  def add_milestone
    project_id = params[:project_id]
    milestone_hash = { name: params[:milestone_name], project_id: project_id, }
    milestone = @user.projects.find(project_id).milestones.new(milestone_hash)

    if milestone.save
      response = { success: true, milestone_id: milestone.id, milestone_name: milestone.name }
    else
      response = { success: false, message: milestone.errors.full_messages }
    end

    render text: response.to_json
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

  def reset_password
    email = params[:email]
    new_pass = (("a".."z").to_a + (1..9).to_a).shuffle[0..6].join
    user = User.find_by(email: email)

    user.password = new_pass
    user.password_confirmation = new_pass
    

    if user.save
      UserMailer.send_recovery_password(email, new_pass).deliver_now
      render text: { success: true, message: "Password sent to email: #{email}" }.to_json
    else
      render text: { success: false, message: "Couldn't send email" }
    end
  end

  def change_password(new_password, old_password)
    user = @user

    if user.authenticate(old_password)
      user.password = new_password
      user.password_confirmation = new_password

      if user.save
        response = { success: true, message: "Password has been changed!" }
      else
        response = { success: false, message: user.errors.full_messages }
      end
    else
      response = { success: false, message: "Your old password doesn't match your current password" }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end
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
