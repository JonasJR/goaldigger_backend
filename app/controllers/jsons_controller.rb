class JsonsController < ApplicationController
  def hello
    response = {message: "hello android world"}
    respond_to do |format|
      format.json { render text: response.to_json}
      format.html { render }
    end
  end

  def login
    email = params[:request][:email]
    password = params[:request][:password]

    user = User.find_by(email: email)

    if (user && user.authenticate(password))
      response = {message: "Correct password"}
      respond_to do |format|
        format.json { render text: response.to_json } 
      end
    else
      response = {message: "Invalid username or password"}
      respond_to do |format|
        format.json { render text: response.to_json }
      end
    end

  end
end
