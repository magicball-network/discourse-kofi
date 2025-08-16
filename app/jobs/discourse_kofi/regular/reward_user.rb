# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class RewardUser < ::Jobs::Base
    sidekiq_options queue: "low"

    def execute(args)
      return unless SiteSetting.kofi_enabled
      payment = DiscourseKofi::Payment.find_by(id: args[:payment_id])
      return unless payment
      reward = DiscourseKofi::Reward.find_by(id: args[:reward_id]) if args[
        :reward_id
      ]
      DiscourseKofi::PaymentProcessor.new.reward_user(payment, reward)
    end
  end
end
