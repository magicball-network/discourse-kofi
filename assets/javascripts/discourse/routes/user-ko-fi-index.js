import Route from "@ember/routing/route";
import { service } from "@ember/service";

export default class UserKoFiIndexRoute extends Route {
  @service router;

  redirect() {
    this.router.transitionTo("user.ko-fi.payments");
  }
}
