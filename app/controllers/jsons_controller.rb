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

    if item.done
      item.done = false
      item.done_by = ""
    else
      item.done = true
      item.done_by = @user.name
    end
    item.save

    GCM.host = 'https://android.googleapis.com/gcm/send'
    # https://android.googleapis.com/gcm/send is default

    GCM.format = :json
    # :json is default and only available at the moment

    GCM.key = "AIzaSyDwrw6wnLg6N0eq73KBL6fWC97ChMG-AMQ"
    # this is the apiKey obtained from here https://code.google.com/apis/console/

    destination = @user.reg_id.to_s
    # can be an string or an array of strings containing the regIds of the devices you want to send

    data = {:test => "Se ifall detta kommer fram"}
    # must be an hash with all values you want inside you notification

    GCM.send_notification( destination, data )

    render json: "Done: #{item.done}"
  end

  def add_project
    project_name = { name: params[:project_name] }

    if project = @user.projects.create(project_name)
      response = { success: true, project_id: project.id, project_name: project.name, project_description: project.description }
    else
      response = { success: false, message: @user.projects.errors.full_messages }
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end
  end

  def delete_project
    if @user.projects.destroy(params[:id])
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
    milestone = Milestone.find(params[:milestone_id])

    if (milestone.project.user.id == @user.id) && item.save
      response = { success: true, item_name: item.name, item_id: item.id }
    else
      response = { success: false, message: item.errors.full_messages }
    end
    render text: response.to_json
  end

  def delete_item
    item = Item.find(params[:item_id])

    if item.user_id == @user.id && item.destroy
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

    if @user.projects.find(project_id).milestones.find(milestone_id).destroy
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

  def share_project
    project = Project.find(params[:project_id])
    share_friends = params[:share_friends].split(':')

    new_participants = share_friends.map { |friend| User.find(friend) }
    participants = project.participants

    participants_to_be_added = new_participants - participants
    participants_to_be_deleted = participants - new_participants

    participants_to_be_deleted.each do |part|
      project.participants.delete part
    end

    project.participants << participants_to_be_added

    render text: "Project got shared".to_json

  end

  def set_reg_id
    if @user.update_attribute(:reg_id, params[:reg_id])
      render json: "Regid set to: #{@user.reg_id}"
    else
      render json: "Regit could not be set"
    end
  end

  private

    def init_GCM
      GCM.host = 'https://android.googleapis.com/gcm/send'
      # https://android.googleapis.com/gcm/send is default

      GCM.format = :json
      # :json is default and only available at the moment

      GCM.key = "AIzaSyBGn6eZqajWPdx9QKRy1By2qAqYWiYEEg0"
      # this is the apiKey obtained from here https://code.google.com/apis/console/
    end

    def user_params
      params.permit(:name, :email, :password, :password_confirmation)
    end

    def check_logged_in
      user = User.find_by(email: params[:email])

      if user && user.authenticate(params[:password])
        @user = user
      else
        render text: "Please log in first".to_json
      end
    end

    def set_default_response_format
      request.format = :json
    end
end
