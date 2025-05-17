# frozen_string_literal: true

DiscourseKofi::Engine.routes.draw { post "/webhook" => "webhook#index" }

Discourse::Application.routes.draw do
  mount ::DiscourseKofi::Engine, at: "ko-fi"
end
