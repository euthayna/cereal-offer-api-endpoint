Rails.application.routes.draw do
  post 'cart', to: 'carts#create', as: 'cart'
end
