Oregano::Application.routes.draw do
  root :to => "root#index"

  resources :categories, :only => [:create,:show]
  resources :items, :only => [:create,:show]

  namespace :users do
    resource :local, :only => :create
  end

  namespace :relations do
    resources :user_categories, :only => :create
    resources :category_items, :only => :create
  end
end
