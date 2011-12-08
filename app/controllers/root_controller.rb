class RootController < ApplicationController
  def index
    @lists = List.all
    @things = @lists.reduce({}) {|b,a| b.merge(a => Thing.for_list(a))}
  end
end
