class RootController < ApplicationController
  skip_before_filter :validate_session!, :only => :index

  def index
  end
end
