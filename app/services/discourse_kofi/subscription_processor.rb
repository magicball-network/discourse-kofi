# frozen_string_literal: true

module DiscourseKofi
  class SubscriptionProcessor
    #: (Discourse::Subscription subscription) -> void
    def self.expire_subscription(subscription)
      raise "Not a Subscription" unless subscription.kind_of?(Subscription)
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
          .where("id != ?", subscription.id)
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

    #: (Discourse::Subscription subscription) -> void
    def self.destroy!(subscription)
      raise "Not a Subscription" unless subscription.kind_of?(Subscription)
      subscription.expires_at = DateTime.now - 1 if !subscription.expired?
      expire_subscription(subscription)
      subscription.destroy!
    end
  end
end
