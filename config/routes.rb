Rails.application.routes.draw do

  devise_for :users, controllers: {
                       registrations: 'users/registrations',
                       sessions: 'users/sessions',
                       confirmations: 'users/confirmations',
                       omniauth_callbacks: 'users/omniauth_callbacks'
                     }
  devise_for :organizations, class_name: 'User',
             controllers: {
               registrations: 'organizations/registrations',
               sessions: 'devise/sessions',
             },
             skip: [:omniauth_callbacks]

  devise_scope :organization do
    get 'organizations/sign_up/success', to: 'organizations/registrations#success'
  end

  devise_scope :user do
    patch '/user/confirmation', to: 'users/confirmations#update', as: :update_user_confirmation
    get '/user/registrations/check_username', to: 'users/registrations#check_username'
    get 'users/sign_up/success', to: 'users/registrations#success'
    get 'users/registrations/delete_form', to: 'users/registrations#delete_form'
    delete 'users/registrations', to: 'users/registrations#delete'
    get :finish_signup, to: 'users/registrations#finish_signup'
    patch :do_finish_signup, to: 'users/registrations#do_finish_signup'
  end

  root 'welcome#index'
  get '/welcome', to: 'welcome#welcome'
  get '/cuentasegura', to: 'welcome#verification', as: :cuentasegura

  resources :debates do
    member do
      post :vote
      put :flag
      put :unflag
    end
    collection do
      get :map
      get :suggest
    end
  end

  resources :proposals do
    member do
      post :vote
      post :vote_featured
      put :flag
      put :unflag
      get :retire_form
      patch :retire
    end
    collection do
      get :map
      get :suggest
      get :summary
    end
  end

  resources :comments, only: [:create, :show], shallow: true do
    member do
      post :vote
      put :flag
      put :unflag
    end
  end

  scope '/participatory_budget' do
    resources :spending_proposals, only: [:index, :show, :destroy], path: 'investment_projects' do #[:new, :create] temporary disabled
      get :welcome, on: :collection
      post :vote, on: :member
    end
  end

  resources :open_plenaries, only: [] do
    get :results, on: :collection
  end

  resources :stats, only: [:index]

  resources :legislations, only: [:show]

  resources :annotations, only: [:index, :show] do
    get :search, on: :collection
  end

  resources :users, only: [:show]

  resource :account, controller: "account", only: [:show, :update, :delete] do
    get :erase, on: :collection
  end

  resources :notifications, only: [:index, :show] do
    put :mark_all_as_read, on: :collection
  end

  resource :verification, controller: "verification", only: [:show]

  scope module: :verification do
    resource :residence, controller: "residence", only: [:new, :create]
    resource :sms, controller: "sms", only: [:new, :create, :edit, :update]
    resource :verified_user, controller: "verified_user", only: [:show]
    resource :email, controller: "email", only: [:new, :show, :create]
    resource :letter, controller: "letter", only: [:new, :create, :show, :edit, :update]
  end
  get "/verifica", to: "verification/letter#edit"

  namespace :admin do
    root to: "dashboard#index"
    resources :organizations, only: :index do
      get :search, on: :collection
      member do
        put :verify
        put :reject
      end
    end

    resources :users, only: [:index, :show] do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :debates, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :proposals, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :spending_proposals, only: [:index, :show, :edit, :update] do
      member do
        patch :assign_admin
        patch :assign_valuators
      end

      get :summary, on: :collection
    end

    resources :comments, only: :index do
      member do
        put :restore
        put :confirm_hide
      end
    end

    resources :tags, only: [:index, :create, :update, :destroy]
    resources :officials, only: [:index, :edit, :update, :destroy] do
      get :search, on: :collection
    end

    resources :settings, only: [:index, :update]
    resources :moderators, only: [:index, :create, :destroy] do
      get :search, on: :collection
    end

    resources :valuators, only: [:index, :create] do
      get :search, on: :collection
    end

    resources :verifications, controller: :verifications, only: :index do
      get :search, on: :collection
    end

    resource :activity, controller: :activity, only: :show
    resources :newsletters, only: :index do
      get :users, on: :collection
    end
    resource :stats, only: :show

    namespace :api do
      resource :stats, only: :show
    end
  end

  namespace :moderation do
    root to: "dashboard#index"

    resources :users, only: :index do
      member do
        put :hide
        put :hide_in_moderation_screen
      end
    end

    resources :debates, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :proposals, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end

    resources :comments, only: :index do
      put :hide, on: :member
      put :moderate, on: :collection
    end
  end

  namespace :valuation do
    root to: "spending_proposals#index"

    resources :spending_proposals, only: [:index, :show, :edit] do
      patch :valuate, on: :member
    end
  end

  namespace :management do
    root to: "dashboard#index"

    resources :document_verifications, only: [:index, :new, :create] do
      post :check, on: :collection
    end

    resources :email_verifications, only: [:new, :create]

    resources :users, only: [:new, :create] do
      collection do
        delete :logout
        delete :erase
      end
    end

    resource :account, controller: "account", only: [:show]

    get 'sign_in', to: 'sessions#create'

    resource :session, only: [:create, :destroy]
    resources :proposals, only: [:index, :new, :create, :show] do
      post :vote, on: :member
      get :print, on: :collection
    end

    resources :spending_proposals, only: [:index, :show] do #[:new, :create] temporary disabled
      post :vote, on: :member
      get :print, on: :collection
    end

  end

  resources :forums, only: [:index, :create, :show]
  resources :representatives, only: [:create, :destroy]

  resources :survey_answers, only: [:new, :create]

  resources :open_answers, only: [:show, :index]

  get "encuesta-plaza-espana", to: "survey_answers#new", as: :encuesta_plaza_espana

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount Tolk::Engine => '/translate', :as => 'tolk'

  get "ordenanza-de-transparencia", to: "legislations#show", id: 1, as: :ordenanza_transparencia
  get '/blog' => redirect("http://diario.madrid.es/participa/")
  get 'participatory_budget', to: 'spending_proposals#welcome', as: 'participatory_budget'
  get 'delegacion', to: 'forums#index', as: 'delegation'
  get 'plenoabierto', to: 'pages#show', id: 'processes_open_plenary'
  get 'noticias', to: 'pages#show', id: 'news'
  resources :pages, path: '/', only: [:show]
  get 'participatory_budget/in_two_minutes', to: 'pages#show', id: 'participatory_budget/in_two_minutes'
end
