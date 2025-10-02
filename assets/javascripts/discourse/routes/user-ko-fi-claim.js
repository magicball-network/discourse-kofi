import RestrictedUserRoute from "discourse/routes/restricted-user";
import { i18n } from "discourse-i18n";

export default class UserKoFiClaimRoute extends RestrictedUserRoute {
  titleToken() {
    let controller = this.controllerFor(this.router.currentRouteName);
    let subpageTitle = controller?.subpageTitle;
    let title = `${i18n("discourse_kofi.title")} - ${i18n("discourse_kofi.user.navigation.claim")}`;
    return subpageTitle ? `${subpageTitle} - ${title}` : title;
  }
}
