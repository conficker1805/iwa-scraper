class ApplicationController < ActionController::Base
  def index
  end

  protected

  def id
    params.require(:id)
  end

  def page
    params.fetch(:page, 1)
  end

  def keyword
    params.fetch(:keyword, '')
  end
end
