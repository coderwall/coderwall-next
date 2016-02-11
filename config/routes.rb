Rails.application.routes.draw do
  root 'protips#index'

  get    '/trending' => 'protips#index', order_by: :score,       as: :trending
  get    '/popular'  => 'protips#index', order_by: :score,       as: :popular
  get    '/fresh'    => 'protips#index', order_by: :created_at,  as: :fresh
  get    "/sign_in"  => "clearance/sessions#new",                as: :sign_in
  delete "/sign_out" => "clearance/sessions#destroy",            as: :sign_out
  get    "/sign_up"  => "clearance/users#new",                   as: :sign_up
  get    '/tos'      => 'pages#show',    page: 'tos',            as: :tos
  get    '/privacy'  => 'pages#show',    page: 'privacy',        as: :privacy

  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session, controller: "clearance/sessions", only: [:create]

  resources :badges
  resources :likes
  resources :comments
  resources :team
  resources :users
  resources :users, controller: "clearance/users", only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:create, :edit, :update]
  end

  resources :protips, path: '/p' do
    collection do
      get '/:id/:slug' => 'protips#show', as: :slug, :constraints => { slug: /(?!.*?edit).*/ }
    end
  end

  get '/:username'         => 'users#show', as: :profile
  get '/:username/protips' => 'users#show', as: :profile_protips, protips: true
  get '/p/u/:username'     => 'users#show', to: redirect("/%{username}/protips", status: 302)

end
