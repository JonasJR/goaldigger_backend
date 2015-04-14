class JsonsController < ApplicationController
  def hello
    response = {message: "hello android world"}
    respond_to do |format|
      format.json { render text: response.to_json}
      format.html { render }
    end
  end
end
