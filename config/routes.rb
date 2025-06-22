# frozen_string_literal: true

DiscourseKofi::Engine.routes.draw do
  post "webhook" => "webhook#index"

  resources :payments, only: %i[index]

  namespace :admin, constraints: AdminConstraint.new do
    resources :rewards
    resources :payments, only: %i[index show update]
  end
end

Discourse::Application.routes.draw do
  mount ::DiscourseKofi::Engine, at: "/ko-fi"
end
