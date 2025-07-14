# frozen_string_literal: true

require "faker"
require "securerandom"

Fabricator(:kofi_payment, from: "DiscourseKofi::Payment") do
  message_id { SecureRandom.uuid }
  timestamp { DateTime.new }
  type "Donation"
  is_public true
  from_name { Faker::Name.name }
  email { Faker::Internet.email }
  message { Faker::Lorem.sentence }
  amount { Faker::Number.between(from: 1.00, to: 999.00) }
  currency "USD"
  kofi_transaction_id { SecureRandom.uuid }
  is_subscription_payment false
  is_first_subscription_payment false
end

Fabricator(:kofi_subscription, from: "DiscourseKofi::Payment") do
  message_id { SecureRandom.uuid }
  timestamp { DateTime.new }
  type "Subscription"
  is_public true
  from_name { Faker::Name.name }
  email { Faker::Internet.email }
  message { Faker::Lorem.sentence }
  amount { Faker::Number.between(from: 1.00, to: 999.00) }
  currency "USD"
  kofi_transaction_id { SecureRandom.uuid }
  is_subscription_payment true
  is_first_subscription_payment false
  tier_name { Faker::Subscription.plan }
end
