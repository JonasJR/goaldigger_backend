class JsonsController < ApplicationController
  def hello
    respond_to do |format|
      format.json { render text: "hello android"}
      format.html { render }
    end
  end
end
