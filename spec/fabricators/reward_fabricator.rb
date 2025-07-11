# frozen_string_literal: true

require "faker"

Fabricator(:reward, from: "DiscourseKofi::Reward") do
  enabled true
  badge
  payment_types [:donation]
  amount { Faker::Commerce.price }
end

Fabricator(:subscription_reward, from: "DiscourseKofi::Reward") do
  enabled true
  subscription true
  group
  tier_name { Faker::Subscription.plan }
end
