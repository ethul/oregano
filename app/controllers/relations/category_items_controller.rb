module Relations
  class CategoryItemsController < ApplicationController
    def create
      User.load(session[:user_key]).
        fmap(->user {
          LockedCategoryItemProxy.new(
            :secret => user.value,
            :category => params[:category],
            :item => params[:item]
          )
        }).
        bind(->proxy {proxy.save}).
        fold ->_ {head :bad_request}, ->_ {head :created}
    end
  end
end
