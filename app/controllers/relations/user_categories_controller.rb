module Relations
  class UserCategoriesController < ApplicationController
    def create
      User.load(session[:user_key]).
        fmap(->user {
          LockedUserCategoryProxy.new(
            :secret => user.value,
            :user => user.key,
            :private_user_key => user.key,
            :category => params[:category],
          )
        }).
        bind(->proxy {proxy.save}).
        fold ->_ {head :bad_request}, ->_ {head :created}
    end
  end
end
