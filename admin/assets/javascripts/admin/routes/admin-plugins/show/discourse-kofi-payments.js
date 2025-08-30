import DiscourseRoute from "discourse/routes/discourse";

export default class AdminPluginsShowDiscourseKofiPaymentsRoute extends DiscourseRoute {
  setupController(controller) {
    if (controller.initialSearch) {
      controller.search = controller.initialSearch;
    }
    controller.resetFilters();
    controller.emailsVisible = false;
  }

  resetController(controller) {
    // We don't want to remember the deep link
    controller.set("initialSearch", "");
  }
}
