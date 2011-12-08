Oregano::Application.routes.draw do
  resource :entries, :only => :create
  resource :sets, :only => :create
  resource :users, :only => :create
  root :to => "root#index"
end
