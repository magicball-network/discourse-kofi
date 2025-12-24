import NotificationTypeBase from "discourse/lib/notification-types/base";
import { groupPath } from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class extends NotificationTypeBase {
  get label() {
    return false;
  }

  get description() {
    return i18n(
      "discourse_kofi.notifications.subscription_joined_group.description",
      this.notification.data
    );
  }

  get icon() {
    return "kofi-color";
  }

  get linkHref() {
    return groupPath(this.notification.data.group_name);
  }
}
