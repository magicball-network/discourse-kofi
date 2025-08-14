# frozen_string_literal: true

RSpec.describe DiscourseKofi::Subscription, type: :model do
  let(:group) { Fabricate(:group) }
  let(:reward) { Fabricate(:kofi_subscription_reward, group: group) }
  let(:payment) { Fabricate(:kofi_payment) }

  let(:user) { Fabricate(:user) }

  it "can have a subscription" do
    subscription = DiscourseKofi::Subscription.new
    subscription.user = user
    subscription.reward = reward
    subscription.last_payment = payment
    subscription.group = group
    subscription.tier_name = "premium"

    expect(subscription.valid?).to be true
    expect(subscription.save).to be true
    expect(subscription.expires_at).not_to be_nil
  end

  it "can expire" do
    subscription = DiscourseKofi::Subscription.new
    subscription.user = user
    subscription.reward = reward
    subscription.last_payment = payment
    subscription.group = group
    subscription.tier_name = "premium"

    expect(subscription.save).to be true
    expect(subscription.expired?).to be false

    payment.timestamp = payment.timestamp - 1.month - 1.day
    expect(subscription.save).to be true
    expect(subscription.expired?).to be true
  end
end
