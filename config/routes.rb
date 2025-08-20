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
      resources :rewards do
        post "reprocess", on: :member
      end
      resources :payments, only: %i[index show update] do
        post "import", on: :collection
        post "anonymize", on: :collection
      end
      resources :accounts, only: %i[index show destroy]

      get "status" => "status#index"
    end
  end
end

Discourse::Application.routes.draw do
  mount ::DiscourseKofi::Engine, at: "/ko-fi"

  get "/admin/plugins/discourse-kofi/rewards" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/rewards/:reward_id" =>
        "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/payments" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/accounts" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/accounts/:account_id" =>
        "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/import" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/anonymize" => "admin/plugins#index",
      :constraints => AdminConstraint.new
  get "/admin/plugins/discourse-kofi/status" => "admin/plugins#index",
      :constraints => AdminConstraint.new
end
