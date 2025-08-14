# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class RewardUser < ::Jobs::Base
    sidekiq_options queue: "low"

    def execute(args)
      return unless SiteSetting.kofi_enabled
      payment = Payment.find_by(id: args[:payment_id])
      return unless payment
      DiscourseKofi::PaymentProcessor.new.reward_user(payment)
    end
  end
end
