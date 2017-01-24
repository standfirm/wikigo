Rails.application.routes.draw do
  resources :attachments, path: '/-/attachments'

  scope :settings do
    namespace :site do
      get 'export'
      post 'import'

      get 'settings'
      get 'activities'
      get 'members'
    end

    put 'site/update_settings'
    put 'site/update_user_role', as: 'update_user_role'

    resources :webhooks, except: [:show]

    devise_for :users, skip: :registrations, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
    devise_scope :user do
      resource :registration,
        only: [:new, :create, :edit, :update],
        path: 'users',
        path_names: { new: 'sign_up' },
        controller: 'users/registrations',
        as: :user_registration do
          get :cancel
        end
    end
  end


  root to: 'words#show', id: 1 # ID決め打ちは良くない

  get '/-/index', to: 'words#index', as: 'words_index'
  get '/tags', to: 'words#tags', as: 'tags_index'
  get '/tag::tag_list', to: 'words#tag', as: 'word_tag'

  resources :words, path: '/' do
    resources :comments, only: [:create]
    get '/versions', to: redirect('/%{word_id}/versions/0')
    resources :versions, only: [:show] do
      member do
        patch :rollback, to: 'versions#rollback'
      end
    end
  end

  #get '/:id/version/:version', to: 'words#version', as: 'word_version'
end
