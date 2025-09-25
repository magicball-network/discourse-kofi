import Route from "@ember/routing/route";

export default class UserKoFiAccountsRoute extends Route {
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
}
