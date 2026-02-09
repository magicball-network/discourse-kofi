# frozen_string_literal: true

RSpec.describe DiscourseKofi::RewardProcessor do
  fab!(:account, :kofi_account)
  fab!(:account2, :kofi_account)

  before(:example) { allow(::Jobs).to receive(:enqueue) }

  describe "plain rewards" do
    fab!(:payment) { Fabricate(:kofi_payment, account: account) }
    fab!(:subscription) { Fabricate(:kofi_subscription, account: account) }

    fab!(:payment2) { Fabricate(:kofi_payment, account: account2) }

    fab!(:payment3, :kofi_payment)

    fab!(:reward) do
      Fabricate(:kofi_reward, payment_types: %i[donation subscription])
    end

    it "disabled rewards are not reprocessed" do
      reward.enabled = false
      reward.save!

      DiscourseKofi::RewardProcessor.reprocess(reward)
      expect(::Jobs).not_to have_received(:enqueue)
    end

    it "will schedule payments reprocessing matching a reward" do
      DiscourseKofi::RewardProcessor.reprocess(reward)

      expect(::Jobs).to have_received(:enqueue)
        .once
        .with(
          DiscourseKofi::Jobs::RewardUser,
          { payment_id: subscription.id, reward_id: reward.id }
        )
        .once
        .with(
          DiscourseKofi::Jobs::RewardUser,
          { payment_id: payment2.id, reward_id: reward.id }
        )

      expect(::Jobs).to_not have_received(:enqueue).with(
        DiscourseKofi::Jobs::RewardUser,
        { payment_id: payment.id }
      ).with(DiscourseKofi::Jobs::RewardUser, { payment_id: payment3.id })
    end
  end

  describe "subscription rewards" do
    fab!(:reward, :kofi_subscription_reward)

    fab!(:payment) do
      Fabricate(
        :kofi_subscription,
        account: account,
        tier_name: reward.tier_name
      )
    end

    fab!(:sub) do
      sub = DiscourseKofi::Subscription.new
      sub.user = payment.user
      sub.reward = reward
      sub.last_payment = payment
      sub.update_rewarded_fields
      sub.save!
      reward.group.add(sub.user)
      sub
    end

    fab!(:payment_no_sub) do
      Fabricate(
        :kofi_subscription,
        account: account,
        tier_name: reward.tier_name
      )
    end

    fab!(:payment_no_account) do
      Fabricate(:kofi_subscription, tier_name: reward.tier_name)
    end

    fab!(:payment_old) do
      Fabricate(
        :kofi_subscription,
        account: account,
        tier_name: reward.tier_name,
        timestamp: DateTime.now - 6.months
      )
    end

    fab!(:payment_other_tier) do
      Fabricate(:kofi_subscription, account: account2)
    end

    fab!(:sub_other_tier) do
      sub = DiscourseKofi::Subscription.new
      sub.user = payment_other_tier.user
      sub.reward = reward
      sub.last_payment = payment_other_tier
      sub.update_rewarded_fields
      sub.tier_name = payment_other_tier.tier_name
      sub.save!
      reward.group.add(sub.user)
      sub
    end

    it "will schedule payments reprocessing matching a subscription reward" do
      DiscourseKofi::RewardProcessor.reprocess(reward)

      reloaded_sub = DiscourseKofi::Subscription.find_by_id(sub_other_tier.id)
      # Expiration should have been reduced for the expired subscription handler to deal with
      expect(reloaded_sub.expires_at).to be < DateTime.now + 90.minutes

      expect(::Jobs).to have_received(:enqueue)
        .once
        .with(
          DiscourseKofi::Jobs::RewardUser,
          { payment_id: payment.id, reward_id: reward.id }
        )
        .once
        .with(
          DiscourseKofi::Jobs::RewardUser,
          { payment_id: payment_no_sub.id, reward_id: reward.id }
        )

      expect(::Jobs).to_not have_received(:enqueue).with(
        DiscourseKofi::Jobs::RewardUser,
        { payment_id: payment_old.id }
      ).with(
        DiscourseKofi::Jobs::RewardUser,
        { payment_id: payment_other_tier.id }
      )
    end
  end
end
