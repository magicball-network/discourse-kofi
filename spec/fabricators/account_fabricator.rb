# frozen_string_literal: true

require "faker"

Fabricator(:account, from: "DiscourseKofi::Account") do
  user
  email { Faker::Internet.email }
end
