import NotificationTypeBase from "discourse/lib/notification-types/base";
import { userPath } from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class extends NotificationTypeBase {
  get label() {
    return false;
  }

  get description() {
    return i18n("discourse_kofi.notifications.account_linked.description");
  }

  get linkTitle() {
    return i18n("discourse_kofi.notifications.account_linked.link_title");
  }

  get icon() {
    return "kofi-color";
  }

  get linkHref() {
    return userPath(
      `${this.currentUser.username}/ko-fi/accounts?q=aid:${this.notification.data.account_id}`
    );
  }
}
