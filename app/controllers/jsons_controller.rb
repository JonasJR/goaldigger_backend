class JsonsController < ApplicationController

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

  def projects
    user = User.find(1)

    proj = {name: "proj", milestones: [{name: "mile1", items: [{name: "todo1"}, {name: "todo2"}]}]}

    respond_to do |format|
      format.json { render text: render_projects.to_json }
    end
  end

  private 
    
    def render_projects
      projects = User.find(1).projects.all

      projectList = []
      projects.each do |project|
        milestoneList = []

        project.milestones.all.each do |milestone|
          itemList = []

          milestone.items.all.each do |item|
            itemList << { name: item.name }
          end

          milestoneList << { name: milestone.name, items: itemList }

        end

        projectList << { name: project.name, description: project.description, milestones: milestoneList }
      end
      projectList
    end

    def user_params
      params.permit(:name, :email, :password, :password_confirmation)
    end
end