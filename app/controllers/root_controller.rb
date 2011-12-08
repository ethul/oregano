class RootController < ApplicationController
  def index
    if session[:user] then p "has user #{session[:user]}"
    else session[:user] = SecureRandom.uuid end
    @sets = Sets.all
    @entries = @sets.reduce({}) {|b,a| b.merge(a => Entry.for_list(a))}
  end
end
