module Users
  class LocalsController < ApplicationController
    before_filter :validate_local!, :only => :create
    before_filter :reset_session, :only => :create
    skip_before_filter :validate_session!, :only => :create

    def create
      User.new(USER_ID).save.
        fmap(->user {session[:user_key] = user.key}).
        fold ->_ {head :forbidden}, ->_ {head :created}
    end

    private

    def validate_local!
      if ! Rails.env.development? then head :forbidden end
    end

    USER_ID = "local"
  end
end
