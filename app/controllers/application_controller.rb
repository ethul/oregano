class ApplicationController < ActionController::Base
  before_filter :validate_session!
  protect_from_forgery

  protected

  def validate_session!
    if session[:user_key].blank? then head :forbidden end
  end
end
