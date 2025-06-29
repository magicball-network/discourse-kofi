# frozen_string_literal: true

DiscourseKofi::Engine.routes.draw do
  post "webhook" => "webhook#index"

  defaults format: :json do
    resources :payments, only: %i[index]

    namespace :users do
      resources :payments, only: %i[index show update] do
        post "claim", on: :collection
      end
      resources :accounts, only: %i[index show update]
    end

    namespace :admin, constraints: AdminConstraint.new do
      resources :rewards
      resources :payments, only: %i[index show update]
      resources :accounts
    end
  end
end

Discourse::Application.routes.draw do
  mount ::DiscourseKofi::Engine, at: "/ko-fi"
end
