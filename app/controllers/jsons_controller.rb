class JsonsController < ApplicationController
  def hello
    response = {message: "hello android world"}
    respond_to do |format|
      format.json { render text: response.to_json}
      format.html { render }
    end
  end

  def login
    email = params[:email]
    password = params[:password]

    user = User.find_by(email: email)

    if (user && user.authenticate(password))
      response = {message: "Correct password", success: true}
    else
      response = {message: "Invalid username or password", success: false}
    end

    respond_to do |format|
      format.json { render text: response.to_json }
    end

  end
end
