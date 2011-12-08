class UsersController < ApplicationController
  before_filter :reset_session, :only => :create

  def create
    validate_name.(params[:name]).
      bind(make_user).
      fold ->left {head left}, ->right {redirect_to :root}
  end

  private

  def validate_name
    ->name {
      Left.new :bad_request
    }
  end

  def make_user
    ->name {
      Left.new :internal_server_error
    }
  end
end
