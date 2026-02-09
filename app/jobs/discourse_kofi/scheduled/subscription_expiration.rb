# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class SubscriptionExpiration < ::Jobs::Scheduled
    every 1.hour

    def execute(args)
      return unless SiteSetting.kofi_enabled
      DiscourseKofi::Subscription
        .where("expires_at <= ?", DateTime.now)
        .each do |sub|
          sub.transaction do
            DiscourseKofi::SubscriptionProcessor.expire_subscription(sub)
          end
        end
    end
  end
end
