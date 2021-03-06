class JsonsController < ApplicationController

  before_action :check_logged_in, except: [:signup, :login, :reset_password]
  before_action :set_default_response_format

  include ApplicationHelper

  def login
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)

    if (user && user.authenticate(password))
      render json: { name: user.name, email: email, success: true }
    else
      render json: { message: "Invalid username or password", success: false }
    end
  end

  def signup
    user = User.new(user_params)

    if user.save
      response = { name: user.name, email: user.email, success: true }
    else
      response = { errors: user.errors.full_messages, success: false }
    end
      render json: response
  end

  def toggle_item
    item = Item.find(params[:item_id])

    if item.done
      item.done = false
      item.done_by = ""

      data = { message: "#{@user.name} has un-completed task #{item.name} in project #{item.milestone.project.name}" }
    else
      item.done = true
      item.done_by = @user.name

      data = { message: "#{@user.name} has completed task #{item.name} in project #{item.milestone.project.name}" }

    end
    item.save

    users_to_be_notified =  item.milestone.project.participants.to_a
    users_to_be_notified << item.milestone.project.user
    users_to_be_notified.delete(@user)

    if users_to_be_notified.length > 0
        notify_users(users_to_be_notified, data) if users_to_be_notified.length > 0
    end

    render json: "Done: #{item.done}"
  end

  def add_project
    project_name = { name: params[:project_name] }

    if project = @user.projects.create(project_name)
      response = { success: true, project_id: project.id, project_name: project.name, project_description: project.description }
      project.milestones.create(name: project.name)
    else
      response = { success: false, message: @user.projects.errors.full_messages }
    end

      render json: response
  end

  def delete_project
    if @user.projects.destroy(params[:id])
      response = { success: true }
    else
      response = { success: false, message: "Project not found" }
    end
      render json: response
  end

  def projects
    render json: render_projects(@user)
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
    render json: response
  end

  def delete_item
    item = Item.find(params[:item_id])

    if item.user_id == @user.id && item.destroy
      response = { success: true }
    else
      response = { success: false, message: item.errors.full_messages }
    end

    render json: response
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

    render json: response
  end

  def delete_milestone
    milestone_id = params[:milestone_id]
    project_id = params[:project_id]

    if @user.projects.find(project_id).milestones.find(milestone_id).destroy
      response = { success: true }
    else
      response = { success: false, message: milestone.errors.full_messages }
    end

      render json: response
  end

  def reset_password
    email = params[:email]
    new_pass = (("a".."z").to_a + (1..9).to_a).shuffle[0..6].join
    user = User.find_by(email: email)

    user.password = new_pass
    user.password_confirmation = new_pass

    if user.save
      UserMailer.send_recovery_password(email, new_pass).deliver_now
      render json: { success: true, message: "Password sent to email: #{email}" }
    else
      render json: { success: false, message: "Couldn't send email" }
    end
  end

  def change_password
    user = @user

    old_password = params[:old_password]
    new_password = params[:new_password]

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

    render json: response
  end

  def share_project
    project = Project.find(params[:project_id])
    share_friends = params[:share_friends].split(':')

    new_participants = share_friends.map { |friend| User.find(friend) }
    participants = project.participants

    participants_to_be_added = new_participants - participants
    participants_to_be_deleted = participants - new_participants

    users_to_be_notified = participants_to_be_added
    notify_data = { message: "#{project.user.name} has added you to project #{project.name}" }
    notify_users(users_to_be_notified, notify_data) unless (users_to_be_notified.nil? or users_to_be_notified.empty?)

    participants_to_be_deleted.each do |part|
      project.participants.delete part
    end

    project.participants << participants_to_be_added

    render json: "Project got shared"
  end

  def leave_project
    project = Project.find(params[:project_id])

    project.participants.delete(@user)
    users_to_be_notified =  project.participants.to_a
    users_to_be_notified << project.user

    if users_to_be_notified.length > 0
      notify_users(users_to_be_notified, { message: "#{@user.email} has left project #{project.name}" })
    end

    render json: "#{@user.email} has left project #{project.name}"
  end

  def set_reg_id
    if @user.update_attribute(:reg_id, params[:reg_id])
      render json: "Regid set to: #{@user.reg_id}"
    else
      render json: "Regit could not be set"
    end
  end

  private

    def notify_users(users, notify_data)
      GCM.host = 'https://android.googleapis.com/gcm/send'
      GCM.format = :json
      GCM.key = "AIzaSyDwrw6wnLg6N0eq73KBL6fWC97ChMG-AMQ"

      users_to_be_notified = users.dup
      users_to_be_notified.map! {|user| user.reg_id}
      GCM.send_notification(users_to_be_notified, notify_data)
    end

    def user_params
      params.permit(:name, :email, :password, :password_confirmation)
    end

    def check_logged_in
      user = User.find_by(email: params[:email])

      if user && user.authenticate(params[:password])
        @user = user
      else
        render json: "Please log in first"
      end
    end

    def set_default_response_format
      request.format = :json
    end
end
