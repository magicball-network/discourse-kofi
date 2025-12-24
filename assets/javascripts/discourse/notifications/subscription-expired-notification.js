import NotificationTypeBase from "discourse/lib/notification-types/base";
import { i18n } from "discourse-i18n";

export default class extends NotificationTypeBase {
  get label() {
    return false;
  }

  get description() {
    return i18n(
      "discourse_kofi.notifications.subscription_expired.description",
      this.notification.data
    );
  }

  get icon() {
    return "kofi-color";
  }

  get linkHref() {
    return null;
  }
}
