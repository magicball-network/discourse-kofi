import Route from "@ember/routing/route";
import { ajax } from "discourse/lib/ajax";
import StaticPage from "discourse/models/static-page";

export default class KoFiRoute extends Route {
  model() {
    return ajax("/ko-fi/dashboard");
  }

  async recentPayments() {
    return ajax("/ko-fi/payments")
      .then((result) => result.payments)
      .catch(() => []);
  }

  async setupController(controller) {
    if (controller.siteSettings.kofi_dashboard_count > 0) {
      controller.set("payments", await this.recentPayments());
    }
    controller.set(
      "donationMessage",
      await StaticPage.find("ko-fi/dashboard-text")
    );
  }
}
