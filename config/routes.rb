Rails.application.routes.draw do

  resources :users do
    resources :projects, only: [:index, :new, :show, :create] do
      resources :milestones, only: [:index, :new, :create]
    end
  end

  get 'signup'    => 'users#new'
  get 'login'     => 'sessions#new'
  get 'logout'    => 'sessions#destroy'
  post 'login'    => 'sessions#create'

  scope 'api' do
    scope 'v1' do
      post '/login'             => 'jsons#login'
      post '/projects'          => 'jsons#projects'
      post '/signup'            => 'jsons#signup'
      post '/add_project'       => 'jsons#add_project'
      post '/delete_project'    => 'jsons#delete_project'
      post '/toggle_item'       => 'jsons#toggle_item'
      post '/create_item'       => 'jsons#add_item'
      post '/delete_item'       => 'jsons#delete_item'
      post '/create_milestone'  => 'jsons#add_milestone'
      post '/delete_milestone'  => 'jsons#delete_milestone'
      post '/reset_password'    => 'jsons#reset_password'
      post '/change_password'   => 'jsons#change_password'
      post '/search_friends'    => 'friends#search'
      post '/show_friends'      => 'friends#index'
      post '/create_friend'     => 'friends#create'
      post '/destroy_friend'    => 'friends#destroy'

      get '/signup'             => 'jsons#signup'
    end
  end

  root "sessions#new"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
