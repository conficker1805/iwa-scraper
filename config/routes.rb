Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root controller: :application, action: :index

  get :images, controller: :posts, action: :images

  resources :posts, only: %i[index show]

  # match 'posts/:id', to: 'posts#show', via: :get
end
