Rails.application.routes.draw do
  # This disables serving any web requests other then /assets out of CloudFront
  match '*path', via: :all, to: 'pages#show', page: 'not_found',
    constraints: CloudfrontConstraint.new

  root 'protips#index'
  get   '/trending(/:page)' => 'protips#index', order_by: :score,       as: :trending
  get   '/popular(/:page)'  => 'protips#index', order_by: :views_count, as: :popular
  get   '/fresh(/:page)'    => 'protips#index', order_by: :created_at,  as: :fresh
  get   '/p/trending'       => redirect("/trending", status: 302)
  get   '/p/popular'        => redirect("/popular", status: 302)
  get   '/p/fresh'          => redirect("/fresh", status: 302)
  get    "/signin"     => "clearance/sessions#new",                as: :sign_in
  delete "/signout"    => "clearance/sessions#destroy",            as: :sign_out
  get    "/signup"     => "clearance/users#new",                   as: :sign_up
  get    'faq'         => 'pages#show',          page: 'faq',      as: :faq
  get    '/tos'        => 'pages#show',          page: 'tos',      as: :tos
  get    '/privacy_policy' => 'pages#show',    page: 'privacy',  as: :privacy
  get    '/404'            => "pages#show",    page: 'not_found'
  get    '/500'            => "pages#show",    page: 'server_error'
  get    '/helloworld'     => "users#edit",    finish_signup: true, as: :finish_signup
  get    '/styleguide'     => "pages#show",    page: 'styleguide'
  get    '/delete_account' => 'users#show',    delete_account: true
  get    '/p/u/:username',     to: redirect("/%{username}/protips", status:302)
  get    '/twitter/:username', to: redirect("/404", status:302)
  get    '/github/:username',  to: redirect("/404", status:302)
  get    '/team/:slug'     => 'teams#show'

  resources :passwords, controller: "clearance/passwords", only: [:create, :new]
  resource :session,    controller: "clearance/sessions",  only: [:create]

  resources :team

  resources :users do
    member do
      get '/endorsements' => 'users#show' #legacy url
      resources :likes, only: :index
    end
  end

  resources :users, controller: "clearance/users", only: [:create] do
    resource :password,
      controller: "clearance/passwords",
      only: [:create, :edit, :update]
  end

  resources :comments do |comment|
    resources :likes, only: :create
  end

  resources :protips, path: '/p' do
    resources :likes, only: :create
    collection do
      get '/spam'      => 'protips#spam'
      get '/:id/:slug' => 'protips#show', as: :slug      
    end
  end

  get '/:username'          => 'users#show', as: :profile
  get '/:username/protips'  => 'users#show', as: :profile_protips,  protips:  true
  get '/:username/comments' => 'users#show', as: :profile_comments, comments: true
  get '/:username/impersonate' => 'users#impersonate', as: :impersonate

  get '/stylesheets/jquery.coderwall.css', to: redirect(status: 301) {
    '/legacy.jquery.coderwall.css'
  }
  get '/javascripts/jquery.coderwall.js',  to: redirect(status: 301) {
    '/legacy.jquery.coderwall.js'
  }
end
