# frozen_string_literal: true

RSpec.describe DiscourseKofi::Jobs::SubscriptionExpiration do
  before { SiteSetting.kofi_enabled = true }

  fab!(:account) { Fabricate(:kofi_account) }
  fab!(:reward) { Fabricate(:kofi_subscription_reward) }
  fab!(:payment) do
    Fabricate(:kofi_subscription, account: account, tier_name: reward.tier_name)
  end
  fab!(:active_sub) do
    sub = DiscourseKofi::Subscription.new
    sub.user = payment.user
    sub.reward = reward
    sub.last_payment = payment
    sub.update_rewarded_fields
    sub.save!
    sub
  end
  fab!(:reward2) { Fabricate(:kofi_subscription_reward) }
  fab!(:old_payment) do
    Fabricate(
      :kofi_subscription,
      account: account,
      tier_name: reward2.tier_name,
      timestamp: DateTime.now - 40.days
    )
  end
  fab!(:expired_sub) do
    sub = DiscourseKofi::Subscription.new
    sub.user = payment.user
    sub.reward = reward2
    sub.last_payment = old_payment
    sub.update_rewarded_fields
    sub.save!
    sub
  end

  it "will expire subscriptions" do
    allow(DiscourseKofi::SubscriptionProcessor).to receive(:expire_subscription)

    described_class.new.execute({})

    expect(DiscourseKofi::SubscriptionProcessor).to have_received(
      :expire_subscription
    ).once

    expect(DiscourseKofi::SubscriptionProcessor).to have_received(
      :expire_subscription
    ).with(having_attributes(id: expired_sub.id))
  end
end
