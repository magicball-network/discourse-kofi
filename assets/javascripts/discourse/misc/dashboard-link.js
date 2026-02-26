import BaseCommunitySectionLink from "discourse/lib/sidebar/base-community-section-link";
import { i18n } from "discourse-i18n";

export default class extends BaseCommunitySectionLink {
  get name() {
    return "kofi-dashboard";
  }

  get shouldDisplay() {
    return (
      this.siteSettings.kofi_dashboard_in_menu &&
      this.siteSettings.kofi_dashboard_enabled
    );
  }

  get route() {
    return "ko-fi";
  }

  get title() {
    return i18n("discourse_kofi.dashboard.menu.description");
  }

  get text() {
    return i18n("discourse_kofi.dashboard.menu.title");
  }

  get defaultPrefixValue() {
    return "kofi";
  }
}
