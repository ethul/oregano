class EntriesController < ApplicationController
  def create
    Either.pure(make_entry).
      ap(validate.(params[:list])).
      ap(validate.(params[:content])).
      fold ->left {head left}, ->right {redirect_to :root}
  end

  private

  def make_entry
    ->list,content {
      Entry.new(list,content).save.
      fold -> {Left.new :internal_server_error}, ->a {Right.new :created}
    }
  end

  def validate
    ->value {
      if value.nil? or value.empty? then Left.new :bad_request
      else Right.new value end
    }
  end
end
