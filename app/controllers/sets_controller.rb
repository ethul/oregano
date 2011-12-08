class SetsController < ApplicationController
  def create
    validate_name.(params[:name]).
      bind(make_list).
      fold ->left {head left}, ->right {redirect_to :root}
  end

  private

  def validate_name
    ->name {
      if name.nil? or name.empty? then Set.new :bad_request
      else Right.new name end
    }
  end

  def make_list
    ->name {
      Set.new(name).save.
      fold -> {Left.new :internal_server_error}, ->a {Right.new :created}
    }
  end
end
