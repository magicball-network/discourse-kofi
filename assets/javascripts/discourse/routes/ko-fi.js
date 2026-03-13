import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";
import StaticPage from "discourse/models/static-page";

export default class KoFiRoute extends Route {
  model() {
    return ajax("/ko-fi/dashboard");
  }

  async setupController(controller) {
    controller.set(
      "donationMessage",
      await StaticPage.find("ko-fi/dashboard-text")
    );
  }
}
