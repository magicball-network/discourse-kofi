# frozen_string_literal: true

require "faker"

Fabricator(:kofi_reward, from: "DiscourseKofi::Reward") do
  enabled true
  badge
  payment_types [:donation]
  amount { Faker::Commerce.price }
end

Fabricator(:kofi_subscription_reward, from: "DiscourseKofi::Reward") do
  enabled true
  subscription true
  group
  tier_name { Faker::Subscription.plan }
end
