map.namespace :admin do |admin|
  admin.resources :users, :member => {:generate_api_key => :put, :clear_api_key => :put}
end
map.namespace :api do |admin|
  admin.resources :shipments, {:member => {:event => :put}}
end
