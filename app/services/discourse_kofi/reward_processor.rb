# frozen_string_literal: true

module DiscourseKofi
  class RewardProcessor
    #: (DiscourseKofi::Reward reward) -> void
    def self.reprocess(reward)
      raise "Not a Reward" unless reward.kind_of?(Reward)
      return unless reward.enabled
      if reward.subscription
        reprocess_subscription(reward)
      else
        reprocess_reward(reward)
      end
    end

    private

    def self.reprocess_reward(reward)
      # Reprocess the most recent payment which would match the reward
      payments =
        Payment
          .where("user_id is not null")
          .where("payment_type in (?)", reward.payment_types)
          .group("user_id")
          .select("max(id) as id")
      payments.each do |payment|
        ::Jobs.enqueue(
          Jobs::RewardUser,
          payment_id: payment.id,
          reward_id: reward.id
        )
      end
    end

    def self.reprocess_subscription(reward)
      # Expire subscriptions for the reward which no longer match the tier.
      # They might be reactivated by a different payment, so give some expiration process slack.
      Subscription
        .where(reward: reward)
        .where("lower(tier_name) != ?", reward.tier_name.downcase)
        .update_all(expires_at: DateTime.now + 1.hour)

      payments =
        Payment
          .where("user_id is not null")
          .where("lower(tier_name) = ?", reward.tier_name.downcase)
          .where("timestamp > ?", DateTime.now - 1.month - 1.day)
          .where("is_subscription_payment = true")
          .select(:id)
      payments.each do |payment|
        ::Jobs.enqueue(
          Jobs::RewardUser,
          payment_id: payment.id,
          reward_id: reward.id
        )
      end
    end
  end
end
