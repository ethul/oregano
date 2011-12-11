class ItemsController < ApplicationController
  respond_to :json, :only => :create

  def create
    User.load(session[:user_key]).
      fmap(->user {LockedItemProxy.new :secret => user.value, :value => params[:value]}).
      bind(->proxy {proxy.save}).
      fold ->_ {head :bad_request}, ->proxy {respond_with proxy, :status => :created}
  end
end
