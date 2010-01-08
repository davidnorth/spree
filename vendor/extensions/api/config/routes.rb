map.namespace :admin do |admin|
  admin.resources :users, :member => {:generate_api_key => :put, :clear_api_key => :put}
end
map.namespace :api do |api|
  api.resources :shipments, :member => {:event => :put}
  api.resources :orders, :member => {:event => :put} do |orders|
    orders.resources :shipments
  end
end
