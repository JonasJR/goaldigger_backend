class JsonsController < ApplicationController
  def hello
    respond_to do |format|
      format.json { render text: "Hello".to_json }
    end
  end
end
