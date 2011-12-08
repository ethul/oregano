Lot::Application.routes.draw do
  resource :things, :only => :create
  resource :lists, :only => :create
  root :to => "root#index"
end
