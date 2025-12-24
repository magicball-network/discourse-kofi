# frozen_string_literal: true

module DiscourseKofi
  class RewardProcessor
    def self.reprocess(reward)
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
      #TODO
      # find last_payment based on reward, and payments >= 1 month for the tier
    end
  end
end
