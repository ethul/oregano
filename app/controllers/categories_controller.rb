class CategoriesController < ApplicationController
  respond_to :json, :only => :create

  def create
    User.load(session[:user_key]).
      fmap(->user {LockedCategoryProxy.new :secret => user.value}).
      fold ->_ {head :bad_request}, ->proxy {respond_with proxy, :status => :created}
  end
end
