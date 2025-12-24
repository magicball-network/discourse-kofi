import { withPluginApi } from "discourse/lib/plugin-api";
import DashboardLink from "../misc/dashboard-link";
import AccountLinkNotification from "../notifications/account-link-notification";
import SubscriptionActivatedNotification from "../notifications/subscription-activated-notification";
import SubscriptionExpiredNotification from "../notifications/subscription-expired-notification";
import SubscriptionJoinedGroupNotification from "../notifications/subscription-joined-group-notification";
import SubscriptionLeftGroupNotification from "../notifications/subscription-left-group-notification";

export default {
  name: "discourse-kofi",
  initialize() {
    withPluginApi((api) => {
      api.registerNotificationTypeRenderer(
        "kofi_account_link",
        () => AccountLinkNotification
      );
      api.registerNotificationTypeRenderer(
        "kofi_subscription_activated",
        () => SubscriptionActivatedNotification
      );
      api.registerNotificationTypeRenderer(
        "kofi_subscription_expired",
        () => SubscriptionExpiredNotification
      );
      api.registerNotificationTypeRenderer(
        "kofi_subscription_joined_group",
        () => SubscriptionJoinedGroupNotification
      );
      api.registerNotificationTypeRenderer(
        "kofi_subscription_left_group",
        () => SubscriptionLeftGroupNotification
      );

      api.addCommunitySectionLink(() => DashboardLink, true);
    });
  },
};
