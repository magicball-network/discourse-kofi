# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class ResolvePayment < ::Jobs::Base
    sidekiq_options queue: "low"

    def execute(args)
      return unless SiteSetting.kofi_enabled
      PaymentProcessor.new.resolve_payment(args[:payment_id])
    end
  end
end
