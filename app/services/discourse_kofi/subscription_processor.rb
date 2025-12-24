# frozen_string_literal: true

module DiscourseKofi
  class SubscriptionProcessor
    def self.expire_subscription(subscription)
      return unless subscription.expired?

      Notification.create!(
        notification_type: Notification.types[:kofi_subscription_expired],
        user_id: subscription.user.id,
        data: { tier_name: subscription.tier_name }.to_json
      )

      group_subscription =
        Subscription
          .where(user: subscription.user)
          .where(group: subscription.group)
          .where("expires_at > ?", DateTime.now())
          .pluck(:group_id)

      if group_subscription.empty?
        subscription.group.remove(subscription.user)
        Notification.create!(
          notification_type: Notification.types[:kofi_subscription_left_group],
          user_id: subscription.user.id,
          data: {
            tier_name: subscription.tier_name,
            group_id: subscription.group.id,
            group_name: subscription.group.name
          }.to_json
        )
      end
    end
  end
end
