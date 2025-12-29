# frozen_string_literal: true

module ::DiscourseKofi::Jobs
  class SubscriptionCleanup < ::Jobs::Scheduled
    every 1.hours

    def execute(args)
      return unless SiteSetting.kofi_enabled
      DiscourseKofi::Subscription
        .where("expires_at <= ?", DateTime.now - 2.weeks)
        .each do |sub|
          sub.transaction { DiscourseKofi::SubscriptionProcessor.destroy!(sub) }
        end
    end
  end
end
