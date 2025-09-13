import { withPluginApi } from "discourse/lib/plugin-api";
import AccountLinkNotification from "../notifications/account-link-notification";

export default {
  name: "discourse-kofi",
  initialize() {
    withPluginApi((api) => {
      api.registerNotificationTypeRenderer(
        "kofi_account_link",
        () => AccountLinkNotification
      );
    });
  },
};
