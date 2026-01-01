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

    # Expiration not set, so assume expired
    expect(subscription.expired?).to be true

    expect(subscription.save).to be true
    expect(subscription.expired?).to be false

    payment.timestamp = payment.timestamp - 1.month - 1.day
    expect(subscription.save).to be true
    expect(subscription.expired?).to be true
  end

  it "can be activated" do
    subscription = DiscourseKofi::Subscription.new
    subscription.user = user
    subscription.reward = reward
    subscription.last_payment = payment
    subscription.group = group
    subscription.tier_name = "premium"

    # Not saved yet, so cannot be activated yet
    expect(subscription.activated?).to be false

    expect(subscription.save).to be true
    expect(subscription.activated?).to be true

    # Expired, so it cannot be activated
    payment.timestamp = DateTime.now - 2.month
    expect(subscription.save).to be true
    expect(subscription.activated?).to be false

    # Need to reload it from the database to verify re-activation
    subscription = DiscourseKofi::Subscription.find_by_id(subscription.id)
    subscription.last_payment.timestamp = DateTime.now
    expect(subscription.save).to be true
    expect(subscription.activated?).to be true

    # If it was activate previously, changing the date makes no difference
    subscription = DiscourseKofi::Subscription.find_by_id(subscription.id)
    subscription.last_payment.timestamp = DateTime.now + 1.day
    expect(subscription.save).to be true
    expect(subscription.activated?).to be false
  end

  it "deletes subscriptions on user deletion" do
    subscription = DiscourseKofi::Subscription.new
    subscription.user = user
    subscription.reward = reward
    subscription.last_payment = payment
    subscription.group = group
    subscription.tier_name = "premium"
    subscription.save!

    user.destroy!

    reloaded = DiscourseKofi::Subscription.find_by_id(subscription.id)
    expect(reloaded).to be_nil
  end

  it "deletes subscriptions on group deletion" do
    subscription = DiscourseKofi::Subscription.new
    subscription.user = user
    subscription.reward = reward
    subscription.last_payment = payment
    subscription.group = group
    subscription.tier_name = "premium"
    subscription.save!

    group.destroy!

    reloaded = DiscourseKofi::Subscription.find_by_id(subscription.id)
    expect(reloaded).to be_nil
  end
end
