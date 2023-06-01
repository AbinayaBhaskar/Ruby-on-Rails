Rails.application.routes.draw do
  devise_for :employees,
             controllers: {
               sessions: 'employees/sessions',
               registrations: 'employees/registrations'
             },
             path_names: {
               sign_in: 'login',
               sign_out: 'logout'
             },
             defaults: {
               format: :json
             }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :statuses, only: %i[index create update]
  get '/current_employee', to: "current_employee#show"
  resources :today_statuses, only: [:index]
end
