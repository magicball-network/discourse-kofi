import RestrictedUserRoute from "discourse/routes/restricted-user";
import { i18n } from "discourse-i18n";

export default class UserKoFiAccountsRoute extends RestrictedUserRoute {
  setupController(controller) {
    if (controller.initialSearch) {
      controller.search = controller.initialSearch;
    }
    controller.resetFilters();
  }

  resetController(controller) {
    // We don't want to remember the deep link
    controller.set("initialSearch", "");
  }

  titleToken() {
    let controller = this.controllerFor(this.router.currentRouteName);
    let subpageTitle = controller?.subpageTitle;
    let title = `${i18n("discourse_kofi.title")} ${i18n("discourse_kofi.user.navigation.accounts")}`;
    return subpageTitle ? `${subpageTitle} - ${title}` : title;
  }
}
