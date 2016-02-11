Rails.application.routes.draw do

  root 'protips#index'
  get '/trending' => 'protips#index', order_by: :score,       as: :trending
  get '/popular'  => 'protips#index', order_by: :score,       as: :popular
  get '/fresh'    => 'protips#index', order_by: :created_at,  as: :fresh

  resources :badges
  resources :likes
  resources :comments
  resources :team

  resources :protips, path: '/p' do
    collection do
      get '/:id/:slug' => 'protips#show', as: :slug, :constraints => { slug: /(?!.*?edit).*/ }
    end    
  end

  get '/:username'         => 'users#show', as: :profile
  get '/:username/protips' => 'users#show', as: :profile_protips, protips: true
  get '/p/u/:username'     => 'users#show', to: redirect("/%{username}/protips", status: 302)
  resources :users, :only => [:index, :new, :create, :update, :destroy]

end
